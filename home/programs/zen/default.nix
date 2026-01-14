# Zen is a minimalistic web browser.
# From: https://github.com/luisnquin/nixos-config
{
  inputs,
  config,
  libx,
  pkgs,
  ...
}: let
    domain = config.var.domain;
in {
  imports = [
    inputs.zen-browser.homeModules.twilight
    ./xdg.nix
  ];

  programs.zen-browser = {
    enable = true;

    policies = let
      mkLockedAttrs = builtins.mapAttrs (_: value: {
        Value = value;
        Status = "locked";
      });

      mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

      mkExtensionEntry = { id, pinned ? false }: let
        base = {
          install_url = mkPluginUrl id;
          installation_mode = "force_installed";
        };
      in if pinned then base // { default_area = "navbar"; } else base;

      # All extensions are wrapped here
      mkExtensionSettings = builtins.mapAttrs (_: entry:
        if builtins.isAttrs entry
        then mkExtensionEntry entry
        else mkExtensionEntry { id = entry; }
      );
    in {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true; # save webs for later reading
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      SanitizeOnShutdown = {
        FormData = true;
        Cache = true;
      };
      ExtensionSettings = mkExtensionSettings {
        "uBlock0@raymondhill.net" = { id = "ublock-origin"; pinned = true; };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = { id = "bitwarden-password-manager"; pinned = true; };
        "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = { id = "github-file-icons"; pinned = false; };
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = { id = "return-youtube-dislikes"; pinned = false; };
        "{74145f27-f039-47ce-a470-a662b129930a}" = { id = "clearurls"; pinned = false; };
        "github-no-more@ihatereality.space" = { id = "github-no-more"; pinned = false; };
        "github-repository-size@pranavmangal" = { id = "gh-repo-size"; pinned = false; };
        "@searchengineadremover" = { id = "searchengineadremover"; pinned = false; };
        "jid1-BoFifL9Vbdl2zQ@jetpack" = { id = "decentraleyes"; pinned = false; };
        "trackmenot@mrl.nyu.edu" = { id = "trackmenot"; pinned = false; };
        "sponsorBlocker@ajay.app" = { id = "sponsorblock"; pinned = false; };
        "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = { id = "videospeed"; pinned = false; };
      };
      Preferences = mkLockedAttrs {
        "browser.startup.homepage" = "https://${domain}|https://chatgpt.com";
        "browser.aboutConfig.showWarning" = false;
        "browser.tabs.warnOnClose" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
        # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
        "browser.gesture.swipe.left" = "";
        "browser.gesture.swipe.right" = "";
        "browser.tabs.hoverPreview.enabled" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.topsites.contile.enabled" = false;

        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
        "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
        "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "privacy.spoof_english" = 1;

        "privacy.firstparty.isolate" = true;
        "network.cookie.cookieBehavior" = 5;
        "dom.battery.enabled" = false;

        "gfx.webrender.all" = true;
        "network.http.http3.enabled" = true;
        "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0
      };
    };

    profiles.default = rec {
      id = 0;
      isDefault = true;
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.animate-sidebar" = false;
        "zen.welcome-screen.seen" = true;
        "zen.urlbar.behavior" = "float";
      };

      bookmarks = {
        force = true; # must be explicitly set to apply bookmarks
        settings = [
          { name = "KIT Illias"; url = "https://ilias.studium.kit.edu/ilias.php?baseClass=ilrepositorygui&ref_id=1"; }
          { name = "Teams"; url = "https://teams.microsoft.com/v2/"; }
        ];
      };

      pinsForce = false;
      # pins = {};

      containersForce = false;
      # containers = {};

      spacesForce = false;
      # spaces = {};
    };
  };
}
