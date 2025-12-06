{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;
}
