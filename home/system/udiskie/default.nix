# Udiskie is a simple daemon that uses udisks to automatically mount removable storage devices.
{
  services.udiskie = {
    tray = "never";
    enable = true;
    notify = true;
    automount = true;
  };
}
