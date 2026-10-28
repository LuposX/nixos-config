# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # System Related Stuff
    ../../nixos/pi.nix
    ../../nixos/home-manager.nix
    ../../nixos/fonts.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/audio.nix
    ../../nixos/boot.nix
    ../../nixos/nix.nix
    ../../nixos/bluetooth.nix
    # ../../nixos/hyprland.nix  # Switched to Niri
    ##../../nixos/sddm.nix # Switched to greetd with Noctalia
    ../../nixos/greetd.nix
    ../../nixos/automount-nas.nix
    ../../nixos/kdeconnect.nix
    ../../nixos/blockedsites.nix
    ../../nixos/netbird.nix
    ../../nixos/media-monitor.nix
    ../../nixos/sops.nix
    # ../../nixos/nvix.nix
    # ../../nixos/ventoy.nix # For USB flashing, to start `ventoy-gui` the `.desktop` doesnt work for me.

    # Service
    ../../nixos/syncthing.nix
    ../../nixos/searxng.nix
    # ../../nixos/hindsight.nix

    # Don't change this.
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Enables emulation of arm system to compile NixOS for Raspberry device.
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Build packages with ROCm/HIP support (e.g. Blender HIP, ffmpeg)
  nixpkgs.config.rocmSupport = true;

  networking.firewall.allowedTCPPorts = [8888]; # For jupyter
  services.fail2ban.enable = true;
  services.media-consumption-monitor.enable = true;
  services.openssh = {
    enable = true;
    ports = [22];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Kills processes when too much ram is used
  systemd.oomd.enable = true;
  systemd.oomd.enableUserSlices = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  virtualisation.docker.enable = true;

  # Patch spotify-player: authenticate subcommand never saves credentials.json
  nixpkgs.overlays = [
    # noctalia-shell + its quickshell fork, from the noctalia flake overlay.
    # Home module defaults to the flake's own package; pkgs.noctalia-shell
    # lets us patch it below.
    inputs.noctalia.overlays.default

    # Qt 6.12 breaks noctalia-qs: QMetaType::fromType on moc'd hyprland/i3
    # types fails "Meta Types must be fully defined" because the PCH
    # instantiates the completeness check while the type is still
    # forward-declared. Fixed upstream in quickshell commit 5d5d498
    # "all: use MOC includes instead of opaque pointer definitions".
    (final: prev: {
      quickshell = prev.quickshell.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            ./../../patches/noctalia-qs-qt612-moc.patch
          ];
      });
    })

    (final: prev: {
      spotify-player = prev.spotify-player.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            ./../../patches/spotify-player-save-credentials.patch
          ];
      });
    })
  ];

  # Stylix kmscon module uses removed options in current nixpkgs
  stylix.targets.kmscon.enable = false;

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Do Not Change!
  system.stateVersion = "25.05";
}
