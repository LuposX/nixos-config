# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
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

     # Don't change this.
     ./hardware-configuration.nix
     ./variables.nix
    ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Do Not Change!
  system.stateVersion = "25.05";

}

