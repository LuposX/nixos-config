# Declarative disk layout for the laptop, installed via nixos-anywhere.
#
# 1G EFI (systemd-boot) + one LUKS2 partition holding ext4 root.
# Swap lives in a swapfile on the encrypted root (see luks.nix).
#
# Install from the live ISO with:
#   sudo nixos-anywhere --flake .#laptop root@localhost
# You will be prompted for a LUKS passphrase during the disko phase —
# remember it, it stays as the fallback unlock slot.
{
  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
