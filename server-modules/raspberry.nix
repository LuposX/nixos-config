{config, pkgs, ...} : let
    hostname = config.var.hostname;
in {
  # RasperryPi has its own bootloader.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  virtualisation.docker.enable = true;

  # SD card health checks (smartctl).
  environment.systemPackages = [ pkgs.smartmontools ];

  # Needed for remote building.
  # Else I get error when building problems with sandbox.
  nix.settings.trusted-users = [ "${config.var.username}" ];
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };

  # Keep userspace responsive under memory pressure on the 1GB Pi.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # No hardcoded network settings: DHCP assigns address, gateway and DNS.
  # The router pins 192.168.12.100 to this Pi via a DHCP reservation,
  # so the address stays stable without being configured here.
  networking.useDHCP = true;

  networking.hostName = hostname;
}
