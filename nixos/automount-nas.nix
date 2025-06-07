{
  pkgs,
  config,
  ...
}: let
  username = config.var.username;
in {
  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems."/mnt/nas" = {
    device = "//192.168.12.92/nas";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/home/${username}/.smbcredentials"];
  };
}
