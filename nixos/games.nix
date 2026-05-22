{ config, lib, pkgs, pkgsStable, ... }: {
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    steam-run
    wine-wayland
    protonup-qt
  ] ++ (with pkgsStable; [
    heroic
    lutris
  ]);
}