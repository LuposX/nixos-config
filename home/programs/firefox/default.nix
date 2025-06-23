# Source firefox: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
# For settings: https://github.com/witchof0x20/nix-cfg-jade/blob/448efb5921013f907020a1a953d0988e6f12c896/home/desktop/firefox.nix
{config, ...}: let
  domain = config.var.domain;
  commonSettings = {
    "browser.profiles.enabled" = true;
    "loop.enabled" = false;
    "browser.newtabpage.directory.source" = "";
    "browser.pocket.enabled" = false;

    # Settings from https://github.com/K3V1991/Disable-Firefox-Telemetry-and-Data-Collection
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.sessions.current.clean" = true;
    "devtools.onboarding.telemetry.logged" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.prompted" = 2;
    "toolkit.telemetry.rejected" = true;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.unifiedIsOptIn" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
  };
in {
  programs.firefox = {
    enable = true;
    languagePacks = [
      "de"
      "en-US"
    ];

    # Stylix needs a profile.
    profiles.default = {
        id = 0;
        isDefault = true;
        settings = commonSettings;
    };

    profiles.i2p = {
      id = 1;
      name = "i2p";
      settings = commonSettings // {
        "browser.profiles.enabled" = true;
        "network.proxy.type" = 1;
        "network.proxy.http" = "i2pd-proxy.${domain}";
        "network.proxy.http_port" = 4444;
        "network.proxy.ssl" = "i2pd-proxy.${domain}";
        "network.proxy.ssl_port" = 4444;
        "network.proxy.no_proxies_on" = "localhost, i2pd-proxy.${domain}";
        "media.peerconnection.ice.proxy_only" = true;
      };
      bookmarks = {
        force = true;
        settings = [
          {
            toolbar = true;
            bookmarks = [
              {
                name = "I2P Router Console";
                url = "http://i2pd-web.${domain}";
              }
              {
                name = "reg.i2p";
                url = "http://reg.i2p/";
              }
              {
                name = "stats.i2p";
                url = "http://stats.i2p/";
              }
              {
                name = "notbob.i2p";
                url = "http://notbob.i2p/";
              }
            ];
          }
        ];
      };
    };

    # ---- POLICIES ----
    # Check about:policies#documentation for options.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccount = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "newtab"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"

      # ---- EXTENSIONS ----
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      ExtensionSettings = {
        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below

        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          default_area = "navbar";
          installation_mode = "force_installed";
        };

        # SponsorBlock
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };

        # VideoSpeedController
        "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/videospeed/latest.xpi";
          installation_mode = "force_installed";
        };

        # Privacy Badger
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          default_area = "navbar";
          installation_mode = "force_installed";
        };

        # Vimium<D-d>
        # "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
        #   installation_mode = "force_installed";
        # };
      };
    };
  };
  stylix.targets.firefox.profileNames = [ "default" ];

  # Desktop Entry
  xdg.desktopEntries.firefox-i2p = {
    name = "Firefox (I2P)";
    genericName = "Web Browser";
    comment = "Browse I2P network";
    exec = "firefox -P i2p --no-remote";
    icon = "firefox";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
  };
}
