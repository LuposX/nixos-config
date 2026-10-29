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

  # Enable touchpad support
  services.libinput.enable = true;

  # Battery
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [powertop];
}
