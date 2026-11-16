# Flatpak, per https://wiki.nixos.org/wiki/Flatpak
# Declarative management via nix-flatpak (https://github.com/gmodena/nix-flatpak).
# Also installs yaabsa (https://github.com/Vito0912/yaabsa) from its own
# flatpak repo, which is the recommended Linux install for it.
{
  services.flatpak = {
    enable = true;

    # flathub is needed for the runtimes yaabsa depends on.
    remotes = [
      {name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo";}
      {name = "yaabsa"; location = "https://Vito0912.github.io/yaabsa/de.vito0912.yaabsa.flatpakrepo";}
    ];

    packages = [
      {appId = "de.vito0912.yaabsa"; origin = "yaabsa";}
    ];

    # Keep managed flatpaks up to date at boot/switch.
    update.onActivation = true;
  };

  # Portals are needed for sandboxed apps (file dialogs, etc.).
  xdg.portal.enable = true;
}
