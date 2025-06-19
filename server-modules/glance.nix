{
  services = {
    glance = {
      enable = true;
      settings = {
        pages = [
          {
            hide-desktop-navigation = true;
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                    hour-format = "24h";
                  }
                  {
                    type = "weather";
                    location = "Karlsruhe, Germany";
                  }
                  {
                    type = "markets";
                    markets = [
                      {
                        symbol = "FTSE-Dev-World";
                        name = "Developed World";
                        chat-link = "https://www.tradingview.com/chart/?symbol=MIL%3AVEVE";
                      }
                      {
                        symbol = "BTC-USD";
                        name = "Bitcoin";
                        chart-link = "https://www.tradingview.com/chart/?symbol=INDEX:BTCUSD";
                      }
                      {
                        symbol = "ETH-USD";
                        name = "Ethereum";
                        chart-link = "https://www.tradingview.com/chart/?symbol=INDEX:ETHUSD";
                      }
                    ];
                  }
                  {
                    type = "dns-stats";
                    service = "adguard";
                    url = "http://192.168.12.100:3000/";
                    username = "monkeman";
                    password = "\${secret:adguard-pwd}";
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "duckduckgo";
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "";
                        same-tab = true;
                        color = "200 50 50";
                        links = [
                          {
                            title = "ProtonMail";
                            url = "https://proton.me/mail";
                          }
                          {
                            title = "Github";
                            url = "https://github.com";
                          }
                        ];
                      }
                      {
                        title = "Docs";
                        same-tab = true;
                        color = "200 50 50";
                        links = [
                          {
                            title = "Nixpkgs repo";
                            url = "https://github.com/NixOS/nixpkgs";
                          }
                          {
                            title = "Hyprland wiki";
                            url = "https://wiki.hyprland.org/";
                          }
                          {
                            title = "Search NixOS";
                            url = "https://search.nixos.org/packages";
                          }
                        ];
                      }
                      {
                        title = "Homelab";
                        same-tab = true;
                        color = "100 50 50";
                        links = [
                          {
                            title = "Router";
                            url = "http://192.168.12.1/";
                          }
                        ];
                      }
                      {
                        title = "Misc";
                        same-tab = true;
                        # color = rgb-to-hsl "base01";
                        links = [
                          {
                            title = "Svgl";
                            url = "https://svgl.app/";
                          }
                          {
                            title = "Excalidraw";
                            url = "https://excalidraw.com/";
                          }
                          {
                            title = "Cobalt (Downloader)";
                            url = "https://cobalt.tools/";
                          }
                          {
                            title = "Mazanoke (Image optimizer)";
                            url = "https://mazanoke.com/";
                          }
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
        server = {
          port = 5678;
        };
      };
    };
  };
}
