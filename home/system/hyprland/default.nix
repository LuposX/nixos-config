# So best window tiling manager
{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  border-size = config.theme.border-size;
  gaps-in = config.theme.gaps-in;
  gaps-out = config.theme.gaps-out;
  active-opacity = config.theme.active-opacity;
  inactive-opacity = config.theme.inactive-opacity;
  rounding = config.theme.rounding;
  blur = config.theme.blur;
  shadow = config.theme.shadow;
  keyboardLayout = config.var.keyboardLayout;
  background = "rgb(" + config.lib.stylix.colors.base00 + ")";

  primary_monitor = config.var.primary_monitor;

  isLaptop = config.var.isLaptop;
in {
  imports = [
    ./animations.nix
    ./hyprtasking.nix
    ./polkitagent.nix
    ./bindings.nix
    ./hyprpicker.nix
  ];

  home.packages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qt5ct
    qt6ct
    hyprshot
    hyprpicker
    swappy
    imv
    wf-recorder
    wlr-randr
    wl-clipboard
    brightnessctl
    gnome-themes-extra
    libva
    dconf
    wayland-utils
    wayland-protocols
    glib
    direnv
    meson
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = false;
      variables = [
        "--all"
      ]; # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
    };
    package = null;
    portalPackage = null;

    settings = {
      "$mod" = "SUPER";
      "$shiftMod" = "SUPER_SHIFT";

      exec-once = [
        # System related
        "dbus-update-activation-environment --systemd --all &"
        "systemctl --user enable --now hyprpaper.service &"
        "systemctl --user enable --now hypridle.service &"
        "systemctl --user enable --now hyprpolkitagent.service &"
        "systemctl --user enable --now udiskie.service &"
        "systemctl --user enable --now clipman.service &"
        # "systemctl --user enable --now ssh-agent &"
        "hyprpanel &"

        # Start sessions in background
        "sh -c 'zellij delete-all-sessions --yes'"
        "sh -c 'zellij kill-all-sessions --yes'"
        "sh -c 'zellij --new-session-with-layout notes --session Notes'"
        "sh -c 'zellij --new-session-with-layout university --session University'"
        "sh -c 'zellij --new-session-with-layout website --session Website'"
        "sh -c 'zellij --new-session-with-layout nixos_config --session NixOS_Config'"
        "sh -c 'zellij --new-session-with-layout SpikeSynth --session SpikeSynth'"

        # User Related
        "[workspace 9 silent] spotify"
        ]
        ++ (if isLaptop then [
          "[workspace 2 silent] kitty"
          "hyprctl dispatch exec '[workspace 1 silent] firefox'"
        ] else [
          "[workspace 1 silent] kitty"
          "hyprctl dispatch exec '[workspace 2 silent] firefox'"
        ]);

      monitor = [
        "${primary_monitor},preferred,auto,1" # default eDP-1
        ",preferred,auto,1,mirror,${primary_monitor}"
      ];

      env = [
        "GRIMBLAST_HIDE_CURSOR, 0" # See: https://github.com/Jas-SinghFSU/HyprPanel/issues/888
        "NNN_FIFO,/tmp/nnn.fifo" # For NNN-Preview to work.
        "NNN_TMPFILE,/tmp/nnn-lastdir"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "MOZ_ENABLE_WAYLAND,1"
        "ANKI_WAYLAND,1"
        "DISABLE_QT5_COMPAT,0"
        "NIXOS_OZONE_WL,1"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM=wayland,xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "__GL_GSYNC_ALLOWED,0"
        "__GL_VRR_ALLOWED,0"
        "DISABLE_QT5_COMPAT,0"
        "DIRENV_LOG_FORMAT,"
        "WLR_DRM_NO_ATOMIC,1"
        "WLR_BACKEND,vulkan"
        "WLR_RENDERER,vulkan"
        "WLR_NO_HARDWARE_CURSORS,1"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      general = {
        resize_on_border = true;
        gaps_in = gaps-in;
        gaps_out = gaps-out;
        border_size = border-size;
        layout = "master";
        "col.inactive_border" = lib.mkForce background;
      };

      decoration = {
        active_opacity = active-opacity;
        inactive_opacity = inactive-opacity;
        rounding = rounding;
        shadow = {
          enabled =
            if shadow
            then "true"
            else "false";
          range = 20;
          render_power = 3;
        };
        blur = {
          enabled =
            if blur
            then "true"
            else "false";
          size = 18;
        };
      };

      master = {
        new_status = true;
        allow_small_split = true;
        mfact = 0.5;
      };

      misc = {
        vfr = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        disable_autoreload = true;
        focus_on_activate = true;
        new_window_takes_over_fullscreen = 2;
      };

      windowrulev2 = [
        "float, tag:modal"
        "pin, tag:modal"
        "center, tag:modal"
        # telegram media viewer
        "float, title:^(Media viewer)$"

        # FZF Script
        "float, class:^(fzffloat)$"
        "center, class:^(fzffloat)$"
        "size 1200 600, class:^(fzffloat)$"

        # Bitwarden extension
        "float, title:^(.*Bitwarden Password Manager.*)$"

        # gnome calculator
        "float, class:^(org.gnome.Calculator)$"
        "size 360 490, class:^(org.gnome.Calculator)$"

        # make Firefox/Zen PiP window floating and sticky
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        # idle inhibit while watching videos
        "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
        "idleinhibit focus, class:^(zen)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(zen)$"

        "dimaround, class:^(gcr-prompter)$"
        "dimaround, class:^(xdg-desktop-portal-gtk)$"
        "dimaround, class:^(polkit-gnome-authentication-agent-1)$"
        "dimaround, class:^(zen)$, title:^(File Upload)$"

        # fix xwayland apps
        "rounding 0, xwayland:1"
        "center, class:^(.*jetbrains.*)$, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
        "size 640 400, class:^(.*jetbrains.*)$, title:^(splash)$"
      ];

      layerrule = ["noanim, launcher" "noanim, ^ags-.*"];

      input = {
        kb_layout = keyboardLayout;

        kb_options = "caps:escape";
        follow_mouse = 1;
        sensitivity = 0.5;
        repeat_delay = 300;
        repeat_rate = 50;
        numlock_by_default = true;
      };
    };
  };
}
