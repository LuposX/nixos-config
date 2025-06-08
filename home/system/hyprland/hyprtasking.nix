{
  inputs,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hyprtasking.packages.${pkgs.system}.hyprtasking
    ];
  };
}
