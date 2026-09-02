{
  config,
  lib,
  pkgs,
  pkgsStable,
  ...
}: {
  # steam temporarily disabled (its fhsenv container chain blocked rebuilds
  # via the broken nanoemoji fetch; re-enable after `nix flake update`)
  # programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs;
    [
      lutris
      mesa-demos
      steam-run
      wine-wayland
      protonup-qt
    ]
    ++ (with pkgsStable; [
      ]);
}
