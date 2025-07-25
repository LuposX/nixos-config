# Configuration for my Laptop: `Lenovo Yoga 9 Series`
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # System Related Stuff
    ../../nixos/home-manager.nix
    ../../nixos/fonts.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/audio.nix
    ../../nixos/boot.nix
    ../../nixos/nix.nix
    ../../nixos/bluetooth.nix
    ../../nixos/hyprland.nix
    ../../nixos/sddm.nix
    ../../nixos/automount-nas.nix
    ../../nixos/kdeconnect.nix
    ../../nixos/blockedsites.nix
    ../../nixos/netbird.nix
    # ../../nixos/nvix.nix
    # ../../nixos/ventoy.nix # For USB flashing, to start `ventoy-gui` the `.desktop` doesnt work for me.
    ../../nixos/laptop.nix

    # Service
    ../../nixos/syncthing.nix

    # Don't change this.
    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Enables emulation of arm system to compile NixOS for Raspberry device.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Do Not Change!
  system.stateVersion = "25.05";
}
