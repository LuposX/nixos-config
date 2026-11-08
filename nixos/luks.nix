# TPM2 + PIN unlock for the LUKS device defined in disko.nix, plus swap
# and TRIM. Import from hosts/laptop/configuration.nix.
#
# First boot uses the full LUKS passphrase. Enroll the PIN on the laptop:
#   sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
#     --tpm2-with-pin=yes --tpm2-pcrs=7 \
#     /dev/disk/by-partlabel/disk-main-luks
# The PIN requirement is stored in the LUKS2 token by --tpm2-with-pin=yes.
# Set PCRs explicitly: systemd 262 defaults to no PCR binding. PCR 7 tracks
# Secure Boot policy, so changing firmware Secure Boot settings may require
# the fallback passphrase and re-enrollment. With Secure Boot disabled this
# does not authenticate the bootloader or initrd. Keep the fallback slot.
{
  # Since nixpkgs 26.11 systemd stage 1 is the only initrd, so the
  # crypttabExtraOpts below are always honored. If you pin an older
  # nixpkgs, set boot.initrd.systemd.enable = true here or the TPM2
  # unlock is silently ignored and the initrd asks for the passphrase
  # on every boot.
  boot.initrd.availableKernelModules = [ "tpm_crb" ];

  boot.initrd.luks.devices."cryptroot" = {
    crypttabExtraOpts = [
      "tpm2-device=auto"
    ];
  };

  # Swapfile on the encrypted root instead of a separate partition.
  # No hibernation, so no extra resume config needed.
  swapDevices = [{ device = "/swapfile"; size = 16384; }];

  # Periodic TRIM for the SSD.
  services.fstrim.enable = true;
}
