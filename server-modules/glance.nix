{ config, ... }: let
  domain = "idk-this-is-test.duckdns.org";
in {
  users.groups.glance = {};
  users.users.glance = {
    isSystemUser = true;
    group = "glance";
  };

  services.glance = {
    enable = true;
    settings = {
      theme.contrast-multiplier = 1.3;
      pages = [
        {
          hide-desktop-navigation = true;
          columns = [
            {
              size = "small";
              widgets = [
                { type = "clock"; hour-format = "24h"; }
                { type = "weather"; location = "Karlsruhe, Germany"; }
                { type = "dns-stats";
                  service = "adguard";
                  url = "https://adguard.${domain}";
                  username = "monkeman";
                  password = "${secret:adguard-pwd}";
                }
              ];
            }
            {
              size = "full";
              widgets = [
                # Search stays at the top by default
                { type = "search"; search-engine = "duckduckgo"; }

                # Domain service monitors
                { type = "group";
                  widgets = [
                    { type = "monitor";
                      title = "Services";
                      cache = "1m";
                      sites = [
                        { title = "Vaultwarden"; url = "https://vault.${domain}"; icon = "si:bitwarden"; }
                        { title = "Tandoor"; url = "https://tandoor.${domain}"; icon = "si:mealie"; }
                        { title = "Syncthing"; url = "https://syncthing.${domain}"; icon = "si:syncthing"; }
                        { title = "Paperless"; url = "https://paper.${domain}"; icon = "sh:paperless-ngx"; }
                        { title = "Immich"; url = "https://immich.${domain}"; icon = "si:immich"; }
                      ];
                    }
                    { type = "monitor";
                      title = "*arr-movies";
                      cache = "1m";
                      sites = [
                        { title = "Jellyfin"; url = "https://jellyfin.${domain}"; icon = "si:jellyfin"; }
                        { title = "Jellyseerr"; url = "https://request.${domain}"; icon = "si:odysee"; }
                        { title = "Jellystats"; url = "https://jellystat.${domain}"; icon = "auto-invert https://cdn.jsdelivr.net/gh/selfhst/icons/png/jellystat.png"; }
                        { title = "Radarr"; url = "https://radarr.${domain}"; icon = "si:radarr"; }
                        { title = "Sonarr"; url = "https://sonarr.${domain}"; icon = "si:sonarr"; }
                        { title = "Prowlarr"; url = "https://prowlarr.${domain}"; icon = "si:podcastindex"; }
                        { title = "qBittorrent"; url = "https://torrent.${domain}"; icon = "sh:qbittorrent"; }
                      ];
                    }
                    { type = "monitor";
                      title = "*arr-books";
                      cache = "1m";
                      sites = [
                        { title = "Audiobookshelve"; url = "https://audiobook.${domain}"; icon = "si:audiobookshelf"; }
                        { title = "Calibre"; url = "https://calibre.${domain}"; icon = "sh:calibre"; }
                        { title = "qBittorrent"; url = "https://read_torrent.${domain}"; icon = "sh:qbittorrent"; }
                        { title = "MyAnonaMouse"; url = "https://www.myanonamouse.net"; icon = "sh:cwa-book-downloader.png";}
                      ];
                    }
                    { type = "monitor";
                      title = "System";
                      cache = "1m";
                      sites = [
                        { title = "Proxmox"; url = "https://prox.${domain}"; icon = "si:proxmox"; }
                        { title = "Gotify"; url = "https://gotify.${domain}"; icon = "sh:gotify"; }
                        { title = "Wireguard"; url = "https://wg.${domain}"; icon = "si:wireguard"; }
                        { title = "NAS"; url = "https://nas.${domain}"; icon = "si:openmediavault"; }
                        { title = "Adguard"; url = "https://adguard.${domain}"; icon = "si:adguard"; }
                      ];
                    }
                  ];
                }

                # Server stats
                { type = "server-stats";
                  servers = [ { type = "local"; name = "prohairesis"; } ];
                }

                # Bookmarks at the bottom
                { type = "bookmarks";
                  groups = [
                    { title = ""; same-tab = true; color = "200 50 50";
                      links = [
                        { title = "ProtonMail"; url = "https://proton.me/mail"; }
                        { title = "Github"; url = "https://github.com"; }
                      ];
                    }
                    { title = "Docs"; same-tab = true; color = "200 50 50";
                      links = [
                        { title = "Nixpkgs repo"; url = "https://github.com/NixOS/nixpkgs"; }
                        { title = "Hyprland wiki"; url = "https://wiki.hyprland.org/"; }
                        { title = "Search NixOS"; url = "https://search.nixos.org/packages"; }
                      ];
                    }
                    { title = "Homelab"; same-tab = true; color = "100 50 50";
                      links = [ { title = "Router"; url = "http://192.168.12.1/"; } ];
                    }
                    { title = "Misc"; same-tab = true;
                      links = [
                        { title = "Svgl"; url = "https://svgl.app/"; }
                        { title = "Excalidraw"; url = "https://excalidraw.com/"; }
                        { title = "Cobalt (Downloader)"; url = "https://cobalt.tools/"; }
                        { title = "Mazanoke (Image optimizer)"; url = "https://mazanoke.com/"; }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
          name = "Home";
        }
      ];
      server = { host = "0.0.0.0"; port = 5678; };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5678 ];
}
