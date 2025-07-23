{ config, ... }: let
  domain = config.var.domain;
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
                { type = "rss";
                  title = "Lainchan";
                  collapse-after = 8;
                  style = "vertical-list";
                  feeds = [
                    { url = "https://gapandfriends.neocities.org/blog/feed.rss"; title = "Gap and friends"; }
                    { url = "https://0x19.org/posts/feed.php"; title = "0x19.org"; }
                    { url = "https://b4rkod.net.tr/rss.xml"; title = "Barkods Basement"; }
                    { url = "https://bendersteed.tech/feed.xml"; title = "Bendersteed"; }
                    { url = "https://321cosmica.neocities.org/en/cosmica-en.xml"; title = "Cosmica"; }
                    { url = "https://cabbagesorter.neocities.org/rss.xml"; title = "Cabbage Sorter"; }
                    { url = "https://confusion.codeberg.page/rss.xml"; title = "Confusions Blog"; }
                    { url = "https://www.cozynet.org/feed/feed.xml"; title = "CozyNet"; }
                    { url = "https://flammableduck.xyz/feed.xml"; title = "Flammable Duck"; }
                    { url = "https://glowbox.cc/rss.php"; title = "dshells notes"; }
                    { url = "https://grafo.zone/index.xml"; title = "Grafo Zone"; }
                    { url = "https://swindlesmccoop.xyz/rss.xml"; title = "Home of Swindles"; }
                    { url = "https://andresz.xyz/index.xml"; title = "Ándros"; }
                    { url = "https://www.idelides.xyz/rss/"; title = "Idelides"; }
                    { url = "https://jahanrashidi.com/rss/"; title = "Jahans site"; }
                    { url = "https://blog.jjakke.com/rss.xml"; title = "Jakes thoughts"; }
                    { url = "https://kassy.neocities.org/miscfeed.xml"; title = "kassy"; }
                    { url = "https://kinisis.xyz/rss.xml"; title = "Kinisis web"; }
                    { url = "https://kirillov.neocities.org/feed.xml"; title = "Kirillov"; }
                    { url = "https://lainnet.arcesia.net/rss.xml"; title = "LainNet"; }
                    { url = "https://blog.libertywitch.com/rss.xml"; title = "Liberty Witch"; }
                    { url = "https://lyricaltokarev.com/blog/rss"; title = "Lyrical Tokarev"; }
                    { url = "https://mayvaneday.org/feed.xml"; title = "MayVaneDay Studios"; }
                    { url = "https://midnightmountain.xyz/index.xml"; title = "midnight mountain"; }
                    { url = "https://newdigitalera.org/feed.xml"; title = "New Digital Era"; }
                    { url = "https://nosleepforme.neocities.org/rss.xml"; title = "No Sleep"; }
                    { url = "https://seapunk.xyz/atom.xml"; title = "Seapunk"; }
                    { url = "https://skumsoft.ltd/slimenet/chamber.rss"; title = "Slime-Net"; }
                    { url = "https://slushbin.net/feed.rss"; title = "slushbin"; }
                    { url = "https://sor.neocities.org/rss.xml"; title = "Sorzitos Layer"; }
                    { url = "http://extramundane.xyz/rss.xml"; title = "The Extramundane"; }
                    { url = "https://torpus.info/index.xml"; title = "torpus"; }
                    { url = "https://voicedrew.xyz/rss.xml"; title = "voicedrew"; }
                    { url = "https://world-playground-deceit.net/global.xml"; title = "World Playground Deceit"; }
                    { url = "https://yukinu.com/feed/rss.xml"; title = "Yukinu"; }
                    { url = "https://mouse.services/rss.xml"; title = "a7th Layer"; }
                    { url = "https://blogelogeluren.netlify.app/rss.xml"; title = "turpelurpeluren"; }
                    { url = "https://chknz.org/feed.xml"; title = "chknz"; }
                    { url = "https://cool-website.xyz/rss.xml"; title = "cool-website.xyz"; }
                    { url = "https://eyetower.xyz/blog/feed.xml"; title = "eyetower"; }
                    { url = "https://foreverliketh.is/blog/index.xml"; title = "foreverliketh.is"; }
                    { url = "https://gau7ilu.xyz/atom.xml"; title = "gau7ilu.xyz"; }
                    { url = "https://getimiskon.xyz/rss.xml"; title = "getimiskons space"; }
                    { url = "https://lckdscl.xyz/feed.xml"; title = "lckdscl"; }
                    { url = "https://maerk.xyz/index.html"; title = "maerk.xyz"; }
                    { url = "https://minugahana.neocities.org/feeds/blog.xml"; title = "minugahana"; }
                    { url = "https://miredo.neocities.org/atom.xml"; title = "miredo"; }
                    { url = "https://monkemanx.github.io/index.xml"; title = "monkemanx"; }
                    { url = "https://orizuru.neocities.org/atom.xml"; title = "orizuru"; }
                    { url = "https://dataswamp.org/~lich/rss.xml"; title = "lichs website"; }
                    { url = "https://psychool.org/index.xml"; title = "psychool"; }
                    { url = "https://risingthumb.xyz/Writing/Blog/index.rss"; title = "Rising Thumb"; }
                    { url = "https://strlst.myogaya.jp/rss.xml"; title = "satorialistic"; }
                    { url = "https://blog.shr4pnel.com/feed.xml"; title = "shrapnelnet"; }
                    { url = "https://sizeof.cat/index.xml"; title = "sizeof(cat)"; }
                    { url = "https://blog.tinfoil-hat.net/index.xml"; title = "tinfoil-hat"; }
                    { url = "https://www.tohya.net/feed.rss"; title = "saturnexplorers"; }
                    { url = "https://trrb.xyz/blog/feed.rss"; title = "trrb"; }
                    { url = "https://urof.net/blog/feed.xml"; title = "urof.net"; }
                    { url = "https://vendell.online/blog/feed.xml"; title = "Vendell"; }
                    { url = "https://ful4n.bearblog.dev/feed/"; title = "ful4n"; }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                # Search stays at the top by default
                { type = "search"; search-engine = "duckduckgo"; new-tab = true; }

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
                        { title = "Netbird"; url = "https://app.netbird.io/peers"; icon = "sh:netbird"; }
                        { title = "NAS"; url = "https://nas.${domain}"; icon = "si:openmediavault"; }
                        { title = "Adguard"; url = "https://adguard.${domain}"; icon = "si:adguard"; }
                        { title = "I2PD"; url = "https://i2pd-web.${domain}"; icon = "di:i2pd"; }
                        { title = "Grafana"; url = "https://grafana.${domain}"; icon = "si:grafana"; }
                        { title = "Prometheus"; url = "https://prometheus.${domain}"; icon = "si:prometheus"; }
                        { title = "KVM"; url = "https://kvm.${domain}"; icon = "sh:pikvm-dark"; }
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
                    { title = "Socials"; same-tab = false; color = "200 50 50";
                      links = [
                        { title = "ProtonMail"; url = "https://proton.me/mail"; }
                        { title = "Github"; url = "https://github.com"; }
                      ];
                    }
                    { title = "Docs"; same-tab = false; color = "200 50 50";
                      links = [
                        { title = "Nixpkgs repo"; url = "https://github.com/NixOS/nixpkgs"; }
                        { title = "Hyprland wiki"; url = "https://wiki.hyprland.org/"; }
                        { title = "Search NixOS"; url = "https://search.nixos.org/packages"; }
                        { title = "Search HomeManager"; url = "https://home-manager-options.extranix.com/"; }
                      ];
                    }
                    { title = "Homelab"; same-tab = false; color = "100 50 50";
                      links = [ { title = "Router"; url = "http://192.168.12.1/"; } ];
                    }
                    { title = "Misc"; same-tab = false;
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
            {
            size = "small";
            widgets = [
              { type = "weather"; location = "Karlsruhe, Germany"; }
              { type = "calendar"; first-day-of-week = "monday"; }
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
