# Configuration for RPi 3B
# Source: https://git.eisfunke.com/config/nixos/-/blob/main/devices/emerald.nix, https://www.eisfunke.com/posts/2023/nixos-on-raspberry-pi.html
{
  lib,
  config,
  ...
}: {
  imports = [
      # System Related Stuff
    ../../nixos/home-manager.nix
    ../../nixos/users.nix
    ../../nixos/nix.nix

    # Modules
    ../../server-modules/adguard.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1; # else i get erros when building problems with sandbox
  };
  nix.settings.trusted-users = [ "${config.var.username}" ]; # Needed for remote building

  services.openssh.enable = true;

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Do Not Change!
  system.stateVersion = "25.11";
  }
