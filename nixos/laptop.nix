{
  pkgs,
  config,
  ...
}: {

  # Enable touchpad support
  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    # For Battery
    powertop
  ];

  # Battery
  services.thermald.enable = true;
}
