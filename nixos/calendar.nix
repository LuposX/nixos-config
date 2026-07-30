# Not working
{pkgs, ...}: {
  programs.dconf.enable = true;

  services.gnome.evolution-data-server.enable = true;

  # Needed for Google Calendar integration
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-control-center
  ];
}
