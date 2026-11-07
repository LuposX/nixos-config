{
  pkgs,
  config,
  ...
}: {

  # tiny_power_button sends SIGRTMIN+4 directly to PID 1 on ACPI wake
  # notifications, powering off the laptop on resume. Keep the normal
  # button driver so power-key handling stays with logind/niri.
  # https://github.com/NixOS/nixpkgs/issues/577729
  boot.blacklistedKernelModules = ["tiny_power_button"];

  # Hardware bits that used to live in hosts/laptop/hardware-configuration.nix.
  # Kept here so the import can be swapped for disko.nix at install time.
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # Battery
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [powertop];
}
