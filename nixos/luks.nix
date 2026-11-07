# LUKS2 root encryption with TPM2 + PIN unlock.
#
# Import this from hosts/laptop/configuration.nix AFTER the disk is
# reinstalled with the encrypted layout. The UUID below must be the UUID
# of the LUKS partition itself (nvme0n1p2), not of the filesystem inside
# it. Find it with `lsblk -f` — it's the `luks-...` entry.
{
  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/REPLACE-ME-LUKS-PARTITION-UUID";

    # Ask for a PIN, then let the TPM release the key.
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pin=yes"
    ];

    # NVMe SSD: pass TRIM through.
    allowDiscards = true;

    # Skip dm-crypt workqueues for lower latency on fast NVMe.
    bypassWorkqueues = true;
  };

  # Swapfile on the encrypted root instead of a separate partition.
  # No hibernation, so no extra resume config needed.
  swapDevices = [{ device = "/swapfile"; size = 16384; }];

  # Periodic TRIM for the SSD.
  services.fstrim.enable = true;
}
