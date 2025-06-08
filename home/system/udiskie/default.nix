# Udiskie is a simple daemon that uses udisks to automatically mount removable storage devices.
{pkgs, ...}: {
  home.packages = with pkgs; [udiskie];

  services.udiskie = {
    enable = true;
    notify = true;
    automount = true;
  };
}
