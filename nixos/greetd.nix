{
  config,
  pkgs,
  ...
}: {
  # GNOME keyring + PAM integration:
  # the password typed at the greeter unlocks the keyring automatically.
  services.gnome.gnome-keyring.enable = true;

  security.pam.services.greetd = {
    enableGnomeKeyring = true;
  };

  # Noctalia Greeter (login screen) — declarative module from nixpkgs.
  # Replaces the previous greetd auto-login to niri-session.
  services.displayManager.noctalia-greeter = {
    enable = true;

    settings = {
      keyboard = {
        layout = config.var.keyboardLayout;
      };
    };
  };
}
