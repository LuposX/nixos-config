# Media Consumption Monitor & Blocker
#
# Monitors time spent on media/social sites by checking Niri active window titles.
# After exceeding the daily limit (default: 30min), blocks sites via /etc/hosts
# for a cooldown period (default: 2h), then auto-releases.
#
# NixOS side: sudo rule, libnotify, block/unblock script, and the home-manager
#             systemd user service for the monitor daemon.
#
# Requires Niri (Wayland) for window title detection.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.media-consumption-monitor;
  inherit (config.var) username;

  # Default window-title keywords → site mapping
  defaultSiteKeywords = {
    youtube = [ "youtube" "youtu.be" ];
    reddit  = [ "reddit" ];
    kick    = [ "kick.com" "kick" ];
    "9gag"  = [ "9gag" ];
    twitch  = [ "twitch" ];
  };

  # Default domains to block in /etc/hosts
  defaultBlockedDomains = [
    "youtube.com"       "www.youtube.com"       "m.youtube.com"
    "youtu.be"          "www.youtu.be"
    "reddit.com"        "www.reddit.com"        "old.reddit.com"
    "new.reddit.com"    "reddit.de"             "www.reddit.de"
    "twitch.tv"         "www.twitch.tv"
    "kick.com"          "www.kick.com"
    "9gag.com"          "www.9gag.com"
  ];

  # ─── Block/unblock shell script for /etc/hosts ─────────────────────────
  blockScript = pkgs.writeShellScriptBin "media-blocker" ''
    MARKER_START="# MEDIA-BLOCKER-START"
    MARKER_END="# MEDIA-BLOCKER-END"
    HOSTS="/etc/hosts"

    case "''${1:-}" in
      block)
        sed -i "/^$MARKER_START$/,/^$MARKER_END$/d" "$HOSTS"
        {
          echo "$MARKER_START"
          ${concatStringsSep "\n" (map (d: "          echo \"0.0.0.0 ${d}\"\n          echo \"::1 ${d}\"") cfg.blockedDomains)}
          echo "$MARKER_END"
        } >> "$HOSTS"
        echo "Media sites blocked. ($(date))"
        ;;
      unblock)
        sed -i "/^$MARKER_START$/,/^$MARKER_END$/d" "$HOSTS"
        echo "Media sites unblocked. ($(date))"
        ;;
      status)
        if grep -q "$MARKER_START" "$HOSTS" 2>/dev/null; then echo "blocked"
        else echo "unblocked"
        fi
        ;;
      *)
        echo "Usage: $0 {block|unblock|status}"
        exit 1
        ;;
    esac
  '';

  # ─── Python monitor script ────────────────────────────────────────────
  monitorScript = pkgs.writeScriptBin "media-monitor" ''
    #!${pkgs.python3}/bin/python
    """Monitor Niri active window and block media sites after daily limit."""

    import json, os, subprocess, time
    from datetime import datetime, timedelta
    from pathlib import Path

    STATE_DIR = Path(os.environ.get("XDG_STATE_HOME",
        Path.home() / ".local" / "state")) / "media-monitor"
    STATE_FILE = STATE_DIR / "state.json"

    DAILY_LIMIT_MIN = ${toString cfg.dailyLimit}
    BLOCK_DURATION_MIN = ${toString cfg.blockDuration}
    POLL_SEC = ${toString cfg.pollInterval}
    SITE_KEYWORDS = ${builtins.toJSON cfg.siteKeywords}
    BLOCKER = "${blockScript}/bin/media-blocker"

    def get_active_window():
        try:
            r = subprocess.run(["niri", "msg", "-j", "focused-window"],
                capture_output=True, text=True, timeout=3)
            if r.returncode == 0:
                return json.loads(r.stdout).get("title", "")
        except: pass
        return None

    def detect_site(title):
        if not title: return None
        lower = title.lower()
        for site, kw in SITE_KEYWORDS.items():
            for k in kw:
                if k in lower: return site
        return None

    def load_state():
        try:
            if STATE_FILE.exists(): return json.loads(STATE_FILE.read_text())
        except: pass
        return {"usage": {}, "blocked_until": None}

    def save_state(s):
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        STATE_FILE.write_text(json.dumps(s, indent=2))

    def notify(title, body, urgency="normal", ms=5000):
        subprocess.run(["notify-send", "-u", urgency, "-t", str(ms), title, body],
                       capture_output=True)

    session_start = None
    last_site = None

    while True:
        try:
            s = load_state()
            today = datetime.now().strftime("%Y-%m-%d")
            if today not in s["usage"]:
                s["usage"][today] = 0.0
                cutoff = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
                for d in list(s["usage"]):
                    if d < cutoff: del s["usage"][d]

            # Block expired?
            if s.get("blocked_until"):
                if datetime.now() >= datetime.fromisoformat(s["blocked_until"]):
                    s["blocked_until"] = None
                    save_state(s)
                    subprocess.run(["sudo", BLOCKER, "unblock"])
                    notify("✅ Unblocked", "Media sites are accessible again.")
                else:
                    time.sleep(POLL_SEC); continue

            # Check active window
            title = get_active_window()
            site = detect_site(title)

            if site:
                now = time.time()
                if session_start is None:
                    session_start, last_site = now, site
                elif site != last_site:
                    elapsed = (now - session_start) / 60.0
                    s["usage"][today] += elapsed; save_state(s)
                    session_start, last_site = now, site

                elapsed = (time.time() - session_start) / 60.0 if session_start else 0
                if s["usage"][today] + elapsed >= DAILY_LIMIT_MIN:
                    s["usage"][today] += elapsed
                    s["blocked_until"] = (datetime.now() + timedelta(minutes=BLOCK_DURATION_MIN)).isoformat()
                    save_state(s)
                    subprocess.run(["sudo", BLOCKER, "block"])
                    notify("⛔ Media Limit Reached",
                        f"Slow down buddy with the media consumption!\\n"
                        f"Blocked for {BLOCK_DURATION_MIN//60}h{BLOCK_DURATION_MIN%60:02d}.",
                        urgency="critical", ms=12000)
                    session_start, last_site = None, None
            else:
                if session_start is not None:
                    elapsed = (time.time() - session_start) / 60.0
                    s["usage"][today] += elapsed; save_state(s)
                    session_start, last_site = None, None

            save_state(s)
            time.sleep(POLL_SEC)
        except Exception as e:
            STATE_DIR.mkdir(parents=True, exist_ok=True)
            with open(STATE_DIR / "error.log", "a") as f:
                f.write(f"[{datetime.now().isoformat()}] {e}\n")
            time.sleep(POLL_SEC * 3)
  '';
in {
  options.services.media-consumption-monitor = {
    enable = mkEnableOption "media consumption monitor and automatic blocker";

    dailyLimit = mkOption {
      type = types.int;
      default = 30;
      example = 45;
      description = "Daily media consumption limit in minutes before sites get blocked.";
    };

    blockDuration = mkOption {
      type = types.int;
      default = 120;
      example = 60;
      description = "How long to block access (in minutes) after the limit is exceeded.";
    };

    pollInterval = mkOption {
      type = types.int;
      default = 10;
      example = 5;
      description = "Polling interval in seconds for checking the active window.";
    };

    siteKeywords = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = defaultSiteKeywords;
      defaultText = literalMD ''
        ```nix
        {
          youtube = [ "youtube" "youtu.be" ];
          reddit  = [ "reddit" ];
          kick    = [ "kick.com" "kick" ];
          "9gag"  = [ "9gag" ];
          twitch  = [ "twitch" ];
        }
        ```
      '';
      description = ''
        Keywords to match against the active Niri window title for each site category.
        If the window title contains any keyword, time is counted toward that category's limit.
      '';
    };

    blockedDomains = mkOption {
      type = types.listOf types.str;
      default = defaultBlockedDomains;
      defaultText = literalMD "comprehensive list of youtube.com, reddit.com, kick.com, 9gag.com, twitch.tv domains";
      description = "Domains to add to /etc/hosts → 0.0.0.0 when blocking.";
    };
  };

  config = mkIf cfg.enable {
    # Provide notify-send
    environment.systemPackages = with pkgs; [ libnotify ];

    # Passwordless sudo for the block/unblock script
    security.sudo.extraRules = [
      {
        users = [ username ];
        commands = [
          {
            command = "${blockScript}/bin/media-blocker";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # ─── Monitor daemon: defined via home-manager (for correct user service type) ───
    home-manager.users."${username}" = { pkgs, ... }: {
      systemd.user.services.media-consumption-monitor = {
        Unit = {
          Description = "Media Consumption Monitor & Blocker";
          After = [ "graphical-session.target" ];
          Wants = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${monitorScript}/bin/media-monitor";
          Restart = "on-failure";
          RestartSec = "10s";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
