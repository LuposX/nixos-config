{
  ...
}:

{
  programs.niri.settings.spawn-at-startup = [
    { command = [ "arrpc" ]; }
    { command = [ "xwayland-satellite" ]; }
    { command = [ "noctalia-shell" ]; }
    # Zen on workspace 1 (current workspace at startup)
    { command = [ "zen-twilight" ]; }
    # Focus workspace 2, then open terminal
    {
      command = [
        "bash"
        "-c"
        "sleep 0.5 && niri msg action focus-workspace 2 && kitty"
      ];
    }
    # Focus workspace 3, then start spotify last (delay for xwayland-satellite)
    {
      command = [
        "bash"
        "-c"
        "sleep 3 && niri msg action focus-workspace 3 && env NIXOS_OZONE_WL='' spotify"
      ];
    }
  ];
}
