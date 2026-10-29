# Configuration for my Laptop: `Lenovo Yoga 9 Series`
{
  config,
  pkgs,
  inputs,
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
    # ../../nixos/hyprland.nix  # Switched to Niri
    ../../nixos/greetd.nix
    # ../../nixos/sddm.nix
    ../../nixos/automount-nas.nix
    ../../nixos/kdeconnect.nix
    ../../nixos/blockedsites.nix
    ../../nixos/media-monitor.nix
    ../../nixos/netbird.nix
    ../../nixos/pi.nix
    ../../nixos/sops.nix
    # ../../nixos/nvix.nix
    # ../../nixos/ventoy.nix # For USB flashing, to start `ventoy-gui` the `.desktop` doesnt work for me.
    ../../nixos/laptop.nix
    ../../nixos/games.nix

    # Service
    ../../nixos/syncthing.nix
    ../../nixos/searxng.nix
    # ../../nixos/hindsight.nix

    # Don't change this.
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Patch spotify-player: authenticate subcommand never saves credentials.json
  nixpkgs.overlays = [
    # noctalia-shell + its quickshell fork, from the noctalia flake overlay.
    # Home module defaults to the flake's own package; pkgs.noctalia-shell
    # lets us patch it below.
    inputs.noctalia.overlays.default

    # Qt 6.12 fixes for the noctalia stack, needed since the Oct 2026 flake
    # update pulled qtbase 6.12:
    #
    # 1. quickshell fork (noctalia-qs) fails to compile: QMetaType::fromType
    #    on moc'd hyprland/i3 types hits "Meta Types must be fully defined"
    #    because the PCH instantiates the completeness check while the type
    #    is still forward-declared. Fixed upstream in quickshell commit
    #    5d5d498 "all: use MOC includes instead of opaque pointer definitions".
    #
    # 2. noctalia v4's QML singleton `Color` collides with the NEW `Color`
    #    singleton Qt 6.12 added to QtQuick (exports "QtQuick/Color 6.12",
    #    class QQuickColor). Every `Color.mSurface` lookup then resolves to
    #    Qt's object and returns undefined -> white panels, black wallpaper.
    #    Rename the singleton (file + all references) to NoctColors.
    #
    # Remove both overlays once noctalia legacy-v4 supports Qt 6.12 natively.
    (final: prev: {
      quickshell = prev.quickshell.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            ./../../patches/noctalia-qs-qt612-moc.patch
          ];
      });

      # NOTE: noctalia overrides installPhase without running the postInstall
      # hook, so the rename must be appended to installPhase itself.
      noctalia-shell = prev.noctalia-shell.overrideAttrs (oldAttrs: {
        installPhase =
          (oldAttrs.installPhase or "")
          + ''
            cd $out/share/noctalia-shell
            mv Commons/Color.qml Commons/NoctColors.qml
            find . -name '*.qml' -exec sed -i 's/\([^A-Za-z0-9_.]\)Color\./\1NoctColors./g' {} +
            sed -i 's/\([^A-Za-z0-9_.]\)Color\./\1NoctColors./g' Commons/NoctColors.qml
          '';
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
    # TEMP: googlefonts re-tagged the nanoemoji v0.16.0 tarball, breaking the
    # pinned hash (cascades: nanoemoji -> openmoji -> fontconfig -> steam).
    # Remove this overlay after `nix flake update` lands a nixpkgs with the
    # corrected hash.
    (final: prev: {
      python3Packages = prev.python3Packages.overrideScope (pf: pp: {
        nanoemoji = pp.nanoemoji.overrideAttrs (old: {
          src = old.src.overrideAttrs (_: {
            outputHash = "sha256-FysyKC01XBnRiur5RR9fcsTxQqE8x0JJHSoe3q6JtKc=";
          });
        });
      });
    })
  ];

  # Stylix kmscon module uses removed options in current nixpkgs
  stylix.targets.kmscon.enable = false;
  # stylix.targets.gnome.enable = false;

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Enables emulation of arm system to compile NixOS for Raspberry device.
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Do Not Change!
  system.stateVersion = "25.05";
}
