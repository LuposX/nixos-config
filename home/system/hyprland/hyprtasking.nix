{
  inputs,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hyprtasking.packages.${pkgs.stdenv.hostPlatform.system}.hyprtasking
    ];
  };
}
