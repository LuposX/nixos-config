# Configuration for RPi 3B
# Source: https://git.eisfunke.com/config/nixos/-/blob/main/devices/emerald.nix, https://www.eisfunke.com/posts/2023/nixos-on-raspberry-pi.html
{
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
    ../../server-modules/ssh.nix
    ../../server-modules/raspberry.nix
    ../../server-modules/glance.nix
    ../../server-modules/nginx.nix
    ../../server-modules/netbird.nix

    ./hardware-configuration.nix
    ./variables.nix

    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Do Not Change!
  system.stateVersion = "25.11";
  }
