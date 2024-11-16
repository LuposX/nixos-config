{ inputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  # Extra kernel Parameter are for silent boot
  boot.kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" "vt.global_cursor_default=0"];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";

  environment.systemPackages = with pkgs; [
     jellyfin-media-player # Media Player
  ];
  
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Change light level of display
  programs.light.enable = true;
  
  # power savings laptop
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
 };
}
