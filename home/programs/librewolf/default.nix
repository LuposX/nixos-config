# LibreWolf, configured declaratively.
# Replaces the previous Zen setup: same extensions, same profiles,
# DuckDuckGo as default search engine.
{
  config,
  pkgs,
  ...
}: let
  domain = config.var.domain;
in {
  programs.librewolf = {
    enable = true;

    # ---- POLICIES ----
    # Check about:policies#documentation for options.
    policies = let
      mkLockedAttrs = builtins.mapAttrs (_: value: {
        Value = value;
        Status = "locked";
      });

      mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

      mkExtensionEntry = {
        id,
        pinned ? false,
      }: let
        base = {
          install_url = mkPluginUrl id;
          installation_mode = "force_installed";
        };
      in
        if pinned
        then base // {default_area = "navbar";}
        else base;

      # All extensions are wrapped here
      # Entries with their own install_url (e.g. GitHub release xpis)
      # are used as-is; everything else gets an AMO url from the id.
      mkExtensionSettings = builtins.mapAttrs (
        _: entry:
          if builtins.isAttrs entry && entry ? install_url
          then entry
          else if builtins.isAttrs entry
          then mkExtensionEntry entry
          else mkExtensionEntry {id = entry;}
      );
    in {
      SearchEngines = {
        Default = "DuckDuckGo";
        Add = [
          {
            Name = "SearXNG";
            URLTemplate = "http://127.0.0.1:8080/search?q={searchTerms}";
            Method = "GET";
            IconURL = "http://127.0.0.1:8080/favicon.ico";
            Alias = "@s";
            Description = "Self-Hosted SearXNG";
          }
        ];
      };
      # "always", "never" or "newtab"
      DisplayBookmarksToolbar = "newtab";
      # Check about:support for extension/add-on ID strings.
      ExtensionSettings = mkExtensionSettings {
        "uBlock0@raymondhill.net" = {
          id = "ublock-origin";
          pinned = true;
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          id = "bitwarden-password-manager";
          pinned = true;
        };
        "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = {
          id = "github-file-icons";
          pinned = false;
        };
        "zotero@zotero.org" = {
          id = "zotero-connector";
          pinned = true;
        };
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
          id = "return-youtube-dislikes";
          pinned = false;
        };
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          id = "clearurls";
          pinned = false;
        };
        "myallychou@gmail.com" = {
          id = "youtube-recommended-videos";
          pinned = false;
        };
        "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
          id = "old-reddit-redirect";
          pinned = false;
        };
        "github-no-more@ihatereality.space" = {
          id = "github-no-more";
          pinned = false;
        };
        "github-repository-size@pranavmangal" = {
          id = "gh-repo-size";
          pinned = false;
        };
        "@searchengineadremover" = {
          id = "searchengineadremover";
          pinned = false;
        };
        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          id = "decentraleyes";
          pinned = false;
        };
        "trackmenot@mrl.nyu.edu" = {
          id = "trackmenot";
          pinned = false;
        };
        "sponsorBlocker@ajay.app" = {
          id = "sponsorblock";
          pinned = false;
        };
        "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = {
          id = "videospeed";
          pinned = false;
        };
        "webextension@metamask.io" = {
          id = "ether-metamask";
          pinned = false;
        };
        # Not on AMO; installed from the GitHub release xpi.
        "auto-kit-login@rizecookey.net" = {
          install_url = "https://github.com/rizecookey/auto-kit-login/releases/download/v1.2.6/auto-kit-login-1.2.6-firefox.xpi";
          installation_mode = "force_installed";
          pinned = false;
        };
      };
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";

      # Re-enable Firefox captive portal detection.
      # LibreWolf disables it upstream (mozilla.cfg), which is why the
      # KA-WLAN login popup at uni never appeared. These user prefs
      # override that, so joining a hotspot opens the login page again.
      settings = {
        "network.captive-portal-service.enabled" = true;
        "network.connectivity-service.enabled" = true;
        # Reset the canonical URL LibreWolf blanks out.
        "captivedetect.canonicalURL" = "http://detectportal.firefox.com/success.txt";

        # LibreWolf clears cookies on shutdown by default, which logs
        # everything out. Keep cookies/sessions between restarts.
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.offlineApps" = false;
        "privacy.clearOnShutdown.siteSettings" = false;
        # Keep cache/history clearing? Only cookies matter for logins;
        # these stay at LibreWolf's defaults otherwise.
      };

      bookmarks = {
        force = true; # must be explicitly set to apply bookmarks
        # Bookmarks can be opened with: CTRL + B
        # toolbar = true makes this directory the bookmarks toolbar
        settings = [
          {
            name = "Bookmarks Toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "Home";
                url = "https://idk-this-is-test.duckdns.org";
              }
              {
                name = "KIT Illias";
                url = "https://ilias.studium.kit.edu/ilias.php?baseClass=ilrepositorygui&ref_id=1";
              }
              {
                name = "KIT CAS";
                url = "https://campus.studium.kit.edu/";
              }
              {
                name = "Teams";
                url = "https://teams.microsoft.com/v2/";
              }
              {
                name = "Discord Web";
                url = "https://discord.com/app";
              }
            ];
          }
        ];
      };
    };

    # YouTube profile — minimal, no login, no recommendations
    # Purpose: watch specific YouTube videos without getting sucked into the algorithm
    # The key is: NEVER log in to YouTube in this profile. No history, no recommendations.
    profiles.youtube = {
      id = 1;
      name = "youtube";
      isDefault = false;
      settings = {
        # YouTube-specific: kill recommendations
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.snippets" = false;

        # Disable autoplay
        "media.autoplay.default" = 5; # 5 = block all
        "media.autoplay.blocking_policy" = 2;

        # Blank start page — nothing to pull you in
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 0; # blank page on startup

        # Disable Pocket
        "extensions.pocket.enabled" = false;

        # Same: don't wipe cookies on shutdown (not used for logins,
        # but avoids the same surprise if that changes).
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.offlineApps" = false;
        "privacy.clearOnShutdown.siteSettings" = false;
      };

      bookmarks = {
        force = false;
        settings = [];
      };
    };
  };

  # Desktop entry for the YouTube profile
  home.packages = [
    (pkgs.makeDesktopItem {
      name = "librewolf-youtube";
      desktopName = "LibreWolf (YouTube)";
      comment = "LibreWolf — YouTube profile (no login, no recommendations)";
      exec = "librewolf -P youtube %u";
      icon = "librewolf";
      categories = ["Network" "WebBrowser"];
      mimeTypes = ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"];
      startupWMClass = "librewolf";
    })
  ];
}
