{
  inputs,
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    # Universal Wayland Manager, recommended way to start Hyprland.
    withUWSM = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
}
