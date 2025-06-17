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

## Credits

- [Nixy](https://github.com/anotherhadi/nixy)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Vimjoyer](https://www.youtube.com/@vimjoyer)
