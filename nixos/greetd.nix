{ pkgs, ... }:

{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "niri-session";
        user = "monkeman";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";

    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
