{config, ...} :
{
  # RasperryPi has its own bootloader.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Needed for remote building.
  # Else I get error when building problems with sandbox.
  nix.settings.trusted-users = [ "${config.var.username}" ];
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };
}
