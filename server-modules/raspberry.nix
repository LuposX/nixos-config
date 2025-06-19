{config, ...} : let
    hostname = config.var.hostname;
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

  networking.interfaces.eth0.ipv4.addresses = [
    { address = "192.168.12.100"; prefixLength = 24; }
  ];

  networking.interfaces.edns0.dhcp = {
    useDNS = false;  # Ignore DNS from DHCP
  };
  networking.hostName = hostname;
}
