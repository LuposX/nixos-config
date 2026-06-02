{ pkgs, ... }:

{
  # GNOME keyring + PAM integration
  services.gnome.gnome-keyring.enable = true;

  security.pam.services.greetd = {
    enableGnomeKeyring = true;
  };

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