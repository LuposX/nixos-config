# My NixOS Configuration

My current NixOS configuration, which I use for daily driving, it is cobbled together from various online resources, primarily the Nixy repository. This repository is not intended for general use, as it is too specific to my setup. Instead, I recommend using the aforementioned Nixy repository.

## Usage

1. The repository is meant to be cloned into your home folder.
2. Adjust the `hardware-configuration.nix` and other parts of the configuration as needed.
3. If you make changes, add them to Git first.
4. After that, run:
   ```nix
   sudo nixos-rebuild switch --flake .
   ```
   to build the system.
5. To update the system, run:
   ```nix
   nix flake update
   ```


## Credits

- [Nixy](https://github.com/anotherhadi/nixy)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Vimjoyer](https://www.youtube.com/@vimjoyer)
