# My NixOS Configuration

My current NixOS configuration, which I use for daily driving, it is cobbled together from various online resources, primarily the Nixy repository. This repository is not intended for general use, as it is too specific to my setup. Instead, I recommend using the aforementioned Nixy repository.

## Usage

1. The repository is meant to be cloned into your home folder.
2. Adjust the `hardware-configuration.nix` and other parts of the configuration as needed.
3. If you make changes, add them to Git first.
4. After that, run:
   ```sh
   sudo nixos-rebuild switch --flake .
   ```
   to build the system.
5. To update the system, run:
   ```sh
   nix flake update
   ```

## Fresh install of a host (nixos-anywhere)

For hosts with a `disko.nix`, the target can be wiped and installed over SSH from logos. Run the script as the normal user, without sudo, and pass the extra-files directory as the third argument:

```sh
bash scripts/install-host.sh pneuma root@<laptop-ip> \
  /home/monkeman/pneuma-preinstall-backup/extra-files
```

The target must be booted from a NixOS live ISO in UEFI mode. Join the network, start sshd and put the public key for logos's `~/.ssh/id_laptop` in `/root/.ssh/authorized_keys`. Check `test -d /sys/firmware/efi` and `lsblk -o NAME,SIZE,MODEL,SERIAL,MOUNTPOINTS` on the laptop before installing. The layout in `hosts/laptop/disko.nix` erases `/dev/nvme0n1`; verify its identity against the internal SSD.

The extra-files directory must contain `home/monkeman/.config/sops/age/keys.txt`, with the laptop's existing age identity and mode `0600`. Its contents are copied to the installed root through `--extra-files` before activation. The script checks that the key is present and private, and restores staged home files to their declared UID and GID. A fixed UID is required for any staged user's home. Keep an independent backup of the age key before wiping the old installation.

The script prints the target and disks, then requires the host name as confirmation. If a LUKS container declares a `passwordFile`, the passphrase is requested locally and uploaded through `--disk-encryption-keys`. Empty input is rejected, and the local plaintext file is held in the runtime directory and removed when the installer exits. Without a `passwordFile`, disko requests the passphrase in the target session. The uploaded `/tmp/luks-pass` belongs to the live environment and disappears when it reboots; it is not a boot-time key file.

nixos-anywhere runs in two steps here. The disko phase (wipe, LUKS format, mounts) is retried up to three times: pneuma's NVMe can register new partitions about a second after `partprobe` returns, and disko's `mkfs` then races the `/dev/disk/by-partlabel` symlinks. The layout also waits for each partition link with `udevadm wait --settle` before formatting (upstream [disko#739](https://github.com/nix-community/disko/issues/739)). The install phase (closure copy, activation, reboot) runs once. If it fails midway, rerun the script; disko wipes and starts over.

The first boot requires the full LUKS passphrase. Enroll TPM2+PIN on pneuma after booting into the installed system:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
  --tpm2-with-pin=yes --tpm2-pcrs=7 \
  /dev/disk/by-partlabel/disk-main-luks
```

Keep the full passphrase as a fallback and test the PIN with a reboot. The PCR policy is explicit because systemd 262 defaults to no PCR binding. Secure Boot is currently disabled and signed boot is not configured by this setup. PCR 7 tracks Secure Boot policy but does not authenticate the bootloader or initrd while Secure Boot is disabled. Enabling signed Secure Boot later requires separate signing and firmware-key setup, followed by TPM re-enrollment.

I have disabled Nix channels, if you want to temporarily install a program use:
    ```sh
    nix shell nixpkgs#program_name
    ```

## Credits

- [Nixy](https://github.com/anotherhadi/nixy)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Vimjoyer](https://www.youtube.com/@vimjoyer)
