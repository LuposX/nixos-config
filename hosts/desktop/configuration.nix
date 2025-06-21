# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
    ../../nixos/nvidia.nix
    ../../nixos/bluetooth.nix
    ../../nixos/hyprland.nix
    ../../nixos/sddm.nix
    ../../nixos/automount-nas.nix
    ../../nixos/kdeconnect.nix
    ../../nixos/blockedsites.nix
    ../../nixos/netbird.nix
    # ../../nixos/nvix.nix
    # ../../nixos/ventoy.nix # For USB flashing, to start `ventoy-gui` the `.desktop` doesnt work for me.

    # Service
    ../../nixos/syncthing.nix

    # Don't change this.
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Enables emulation of arm system to compile NixOS for Raspberry device.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Do Not Change!
  system.stateVersion = "25.05";
}
