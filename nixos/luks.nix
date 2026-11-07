# TPM2 + PIN unlock for the LUKS device defined in disko.nix, plus swap
# and TRIM. Import from hosts/laptop/configuration.nix.
#
# The PIN is enrolled manually after first boot:
#   sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
#     --tpm2-with-pin=yes /dev/disk/by-uuid/<LUKS-PARTITION-UUID>
# (find the UUID with `lsblk -f`, the `luks-...` entry)
# `tpm2-pin=yes` here is what makes the initrd ask for the PIN at boot.
{
  boot.initrd.luks.devices."cryptroot" = {
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pin=yes"
    ];
  };

  # Swapfile on the encrypted root instead of a separate partition.
  # No hibernation, so no extra resume config needed.
  swapDevices = [{ device = "/swapfile"; size = 16384; }];

  # Periodic TRIM for the SSD.
  services.fstrim.enable = true;
}
