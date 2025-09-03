# Not working
{pkgs, ...}:
{
  programs.dconf.enable = true;

  services.gnome.evolution-data-server.enable = true;

  # Needed for Google Calendar integration
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
  ];

  environment.systemPackages = with pkgs; [
    gnome-control-center
  ];
}
