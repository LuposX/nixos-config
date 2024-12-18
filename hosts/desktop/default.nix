{ inputs, config, pkgs, pkgs-stable, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  # Boot
  # boot.loader.systemd-boot.enable = true;
  # For Grub
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.timeout = 5;
  boot.loader.grub.useOSProber = true;

  # Extra kernel Parameter are for silent boot
  boot.kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" "vt.global_cursor_default=0"];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";

  environment.systemPackages = with pkgs; [
     jellyfin-media-player # Media Player
  ];
}
