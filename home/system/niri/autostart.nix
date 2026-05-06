{
  ...
}:

{
  programs.niri.settings.spawn-at-startup = [
    {
      command = [
        "systemctl"
        "--user"
        "start"
        "hyprpolkitagent"
      ];
    }
    { command = [ "arrpc" ]; }
    { command = [ "xwayland-satellite" ]; }
    { command = [ "noctalia-shell" ]; }
    { command = [ "bash" "-c" "sleep 2; zen-twilight &" ]; }
    { command = [ "bash" "-c" "sleep 2; kitty &" ]; }
    { command = [ "bash" "-c" "sleep 2; spotify &" ]; }
  ];
}
