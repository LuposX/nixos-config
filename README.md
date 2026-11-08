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

I have disabled Nix channels, if you want to temporarily install a program use:
    ```sh
    nix shell nixpkgs#program_name
    ```



## Fresh install of a host (nixos-anywhere)

For hosts with a `disko.nix`, the target can be wiped and installed over SSH from another machine. Run the script as the normal user, without sudo:

```sh
bash scripts/install-host.sh <host> root@<target-ip> <extra-files-dir>
```

Requirements:

- Target booted from a NixOS live ISO in UEFI mode, network joined, sshd started, installing machine's public key in `/root/.ssh/authorized_keys`. Verify the disk identity first — disko erases the internal disk.
- Extra-files dir must contain the target's age identity at `home/<user>/.config/sops/age/keys.txt`, mode `0600`. Back it up independently before wiping; a fixed UID is required for any staged user's home.
- If a LUKS container declares a `passwordFile`, the passphrase is requested locally and uploaded for the install; it lives only in the live environment and disappears on reboot. Otherwise disko asks for the passphrase in the target session.

The disko phase is retried up to three times (partitions can register a second after `partprobe`, racing the `/dev/disk/by-partlabel` symlinks; see [disko#739](https://github.com/nix-community/disko/issues/739)). The install phase runs once; if it fails midway, rerun the script and disko wipes and starts over.

The first boot requires the full LUKS passphrase. Enroll TPM2+PIN afterwards:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
  --tpm2-with-pin=yes --tpm2-pcrs=7 \
  /dev/disk/by-partlabel/disk-main-luks
```

Keep the full passphrase as a fallback and test the PIN with a reboot. PCR 7 tracks Secure Boot policy but does not authenticate the bootloader or initrd while Secure Boot is disabled; enabling signed Secure Boot later requires re-enrollment.

## Credits

- [Nixy](https://github.com/anotherhadi/nixy)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Vimjoyer](https://www.youtube.com/@vimjoyer)
