# Aversion Conditioning Blocker — home-manager module
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.aversion;

  # The program package:
  #  - aversion-overlay / aversion-chip: C (GTK4 + gtk4-layer-shell) — no
  #    GObject typelibs needed, so no cairo/GI dependency at all.
  #  - aversion-daemon / aversion-status: plain Python 3 (stdlib only).
  pkg = pkgs.stdenv.mkDerivation {
    pname = "aversion";
    version = "0.1.0";
    src = ./src;

    nativeBuildInputs = [pkgs.pkg-config pkgs.makeWrapper];
    buildInputs = [pkgs.gtk4 pkgs.gtk4-layer-shell];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cc -O2 -o $out/bin/aversion-overlay $src/overlay.c \
        $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0)
      cc -O2 -o $out/bin/aversion-chip $src/chip.c \
        $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0)
      for name in daemon status; do
        makeWrapper ${pkgs.python3}/bin/python3 $out/bin/aversion-$name \
          --add-flags "$src/$name.py"
      done
      runHook postInstall
    '';

    meta = {
      description = "Aversion conditioning blocker for Niri/Wayland (blocked apps and sites trigger escalating fullscreen interventions)";
      mainProgram = "aversion-status";
    };
  };

  defaultSettings = {
    # app_id of windows (see `niri msg -j windows` to find them)
    blocked_applications = [];
    # substrings matched (case-insensitive) against the focused window title,
    # e.g. "youtube" matches "YouTube - Zen Twilight"
    blocked_title_substrings = ["youtube" "reddit" "moviejoy" "yandex" "f95zone" "pornhub" "comix" "archiveofourown" "ao3" "Kick" "Destiny" "scribblehub" "9gag" "aznude"];
    # intervention durations per attempt: 1st, 2nd, 3rd, 4th; 5th+ uses the last
    durations = [10 30 120 240];
    # temporary access granted for "I need this for work"
    work_access_duration = 600;
    # seconds a target stays silent after an intervention ended, so you can
    # switch away instead of being instantly re-locked
    re_trigger_cooldown = 15.0;
    # phrase that must be typed after choosing "I need this for work"
    confirmation_phrase = "Yes, I really need this for work";
    # cap on kept attempt-history entries in state.json
    history_limit = 500;
    poll_interval = 0.5;
    reset_daily = true;
  };
in {
  options.services.aversion = {
    enable = lib.mkEnableOption "aversion conditioning blocker";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Settings serialized to ~/.config/aversion/config.toml.
        Merged over the spec defaults (see defaultSettings in this module).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkg];

    xdg.configFile."aversion/config.toml".source =
      (pkgs.formats.toml {}).generate
      "config.toml"
      (lib.recursiveUpdate defaultSettings cfg.settings);

    systemd.user.services.aversion-daemon = {
      Unit = {
        Description = "Aversion conditioning blocker (Niri/Wayland)";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkg}/bin/aversion-daemon";
        ExecStopPost = "${pkgs.libnotify}/bin/notify-send 'Aversion blocker stopped' 'Blocking is no longer active — stay focused.'";
        Restart = "always";
        RestartSec = "2s";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
