{config, ...} : let
    hostname = config.var.hostname;
    ipAddress = config.var.ipAddress;
in {
  # RasperryPi has its own bootloader.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Needed for remote building.
  # Else I get error when building problems with sandbox.
  nix.settings.trusted-users = [ "${config.var.username}" ];
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };

  programs.command-not-found.enable = true;

  networking.interfaces.eth0.ipv4.addresses = [
    { address = ipAddress; prefixLength = 24; }
  ];
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.defaultGateway = "192.168.12.1";

  networking.hostName = hostname;
}
