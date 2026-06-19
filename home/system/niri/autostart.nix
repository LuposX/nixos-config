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
    # Focus workspace 3, then open terminal with vim on todo.md
    {
      command = [
        "bash"
        "-c"
        "sleep 1 && niri msg action focus-workspace 3 && kitty -e vim /home/monkeman/Projects/Notes/General_Notes/todo.md"
      ];
    }
    # Focus workspace 4, then start spotify last (delay for xwayland-satellite)
    {
      command = [
        "bash"
        "-c"
        "sleep 3 && niri msg action focus-workspace 4 && env NIXOS_OZONE_WL='' spotify"
      ];
    }
  ];
}
