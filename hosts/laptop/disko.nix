# Declarative disk layout for the laptop, installed via nixos-anywhere.
#
# 1G EFI (systemd-boot) + one LUKS2 partition holding ext4 root.
# Swap lives in a swapfile on the encrypted root (see luks.nix).
#
# Boot the laptop from a live ISO, then run from logos without sudo:
#   bash scripts/install-host.sh pneuma root@<laptop-ip> \
#     /home/monkeman/pneuma-preinstall-backup/extra-files
# The script asks for the LUKS passphrase locally and uploads it for disko.
# Keep it as the fallback after TPM2+PIN enrollment (see nixos/luks.nix).
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
              # Upstream race (disko#739): partprobe and udevadm settle can
              # return before udev recreates the by-partlabel symlinks, and
              # mkfs then fails with "unable to open". Wait for the link
              # itself (the fix vigil applied: udevadm wait --settle).
              preCreateHook = "udevadm wait --settle --timeout=30 /dev/disk/by-partlabel/disk-main-boot";
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
              # Uploaded by install-host.sh for formatting and opening the
              # container in the live session. This is not an initrd keyFile;
              # keep the declaration for future installs. No passphrase is
              # embedded in the Nix store or needed in this file at boot.
              passwordFile = "/tmp/luks-pass";
              # Same race as the boot partition, on the cryptsetup
              # format/open path.
              preCreateHook = "udevadm wait --settle --timeout=30 /dev/disk/by-partlabel/disk-main-luks";
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
