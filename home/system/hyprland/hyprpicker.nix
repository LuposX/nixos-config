{pkgs, ...}: {
  home.packages = [
    pkgs.hyprpicker

    (pkgs.writeShellScriptBin "hyprpicker-clip" ''
      sleep 0.5
      hyprpicker -a
    '')
  ];

  xdg.desktopEntries.hyprpicker = {
    name = "Hyprpicker";
    genericName = "Color Picker";
    comment = "Pick a color from the screen";
    exec = "hyprpicker-clip";
    terminal = false;
    categories = ["Utility"];
    icon = "color-picker";
  };
}
