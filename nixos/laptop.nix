{
  pkgs,
  config,
  ...
}: {

  # Enable touchpad support
  services.libinput.enable = true;

  # Battery
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [powertop];
}
