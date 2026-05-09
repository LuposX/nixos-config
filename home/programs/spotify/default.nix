# Spicetify is a spotify client customizer
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  accent = "${config.lib.stylix.colors.base0D}";
  background = "${config.lib.stylix.colors.base00}";
in {
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  stylix.targets.spicetify.enable = true;

  programs.spicetify = {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      playlistIcons
      lastfm
      historyShortcut
      hidePodcasts
      adblock
      fullAppDisplay
      keyboardShortcut
      shuffle
      songStats
      history
      betterGenres
    ];
  };
}
