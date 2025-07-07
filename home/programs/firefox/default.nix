# Source firefox: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
# For settings: https://github.com/witchof0x20/nix-cfg-jade/blob/448efb5921013f907020a1a953d0988e6f12c896/home/desktop/firefox.nix
{config, lib, ...}: let
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

    "sidebar.verticalTabs" = true;
    "browser.ml.chat.enabled" = false;

    # Extensions are managed with Nix, so don't update.
    "extensions.update.autoUpdateDefault" = false;
    "extensions.update.enabled" = false;

    # Disable search suggestions
    "browser.search.suggest.enabled" = false;
    "browser.urlbar.suggest.searched" = false;
    "browser.urlbar.trending.featureGate" = false;
    "browser.urlbar.addons.featureGate" = false;
    "browser.urlbar.mdn.featureGate" = false;
    "browser.urlbar.pocket.featureGate" = false;
    "browser.urlbar.weather.featureGate" = false;
    "browser.urlbar.yelp.featureGate" = false;
    "extensions.getAddons.showPane" = false;

    # Enable DRM
    "media.eme.enabled" = true;

    # Don't ask for download dir
    "browser.download.useDownloadDir" = false;

    # Disable crappy home activity stream page
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
    "browser.newtabpage.blocked" = lib.genAttrs [
      # Youtube
      "26UbzFJ7qT9/4DhodHKA1Q=="
      # Facebook
      "4gPpjkxgZzXPVtuEoAL9Ig=="
      # Wikipedia
      "eV8/WsSLxHadrTL1gAxhug=="
      # Reddit
      "gLv0ja2RYVgxKdp0I5qwvA=="
      # Amazon
      "K00ILysCaEq8+bEqV/3nuw=="
      # Twitter
      "T9nJot5PurhJSy8n038xGA=="
    ] (_: 1);

    # Disable fx accounts
    "identity.fxaccounts.enabled" = false;

    # Disable Synch Tabs
    "services.sync.engine.tabs" = false;
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
        settings = commonSettings // {
          "browser.startup.homepage" = "https://${domain}";

          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.search.defaultenginename" = "DuckDuckGo";
          "browser.search.selectedEngine" = "DuckDuckGo";
          "browser.search.order.1" = "DuckDuckGo";
        };
    };

    profiles.i2p = {
      id = 1;
      name = "i2p";
      settings = commonSettings // {
        "browser.profiles.enabled" = true;
        "network.proxy.type" = 1;
        "network.proxy.http" = "192.168.12.100";
        "network.proxy.http_port" = 4444;
        "network.proxy.ssl" = "192.168.12.100";
        "network.proxy.ssl_port" = 4444;
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

      SearchEngines.Default = "DuckDuckGo";

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
