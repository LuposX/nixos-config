# Lazygit is a simple terminal UI for git commands.
{
  config,
  lib,
  ...
}: let
  stylixExists = builtins.hasAttr "stylix" config.lib;
  accent = if stylixExists then "#${config.lib.stylix.colors.base0D}" else "#FF0000";  # fallback color
  muted = if stylixExists then "#${config.lib.stylix.colors.base03}" else "#888888";   # fallback color
in {
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        theme = {
          activeBorderColor = [accent "bold"];
          inactiveBorderColor = [muted];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = true;
        nerdFontsVersion = "3";
      };
    };
  };
}
