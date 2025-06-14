{
  config,
  pkgs,
  lib,
  ...
}: {
  services.syncthing = {
    enable = true;

    dataDir = "/home/${config.var.username}";
    settings = {
      devices = {
        "desktop-logos" = {
          id = "3D5FFPZ-RE6WJJH-5P4GNAE-Y3C6ZGF-JYTFM4C-BPLSH47-KMTS5S4-5TFOCA6";
          introducer = false;
        };
        "laptop-pneuma" = {
          id = "LJIDAUP-SG6U6UQ-SU4OEGL-3T6ZRXY-PUYDEAB-4JI7EKC-VYMYMQY-YY42SQH";
          introducer = false;
        };
        "phone" = {
          id = "RMIA3ZL-ZAFQA7K-ZEZYAJW-TAK3Z7F-XNRDMWG-PBB6YZQ-22ZHM76-QIUX4A7";
          introducer = false;
        };
        "server" = {
          id = "DYKZ7ZD-IWVKWX3-BA5KO26-VWRNJFF-R5FMJOD-C4QJTFZ-Q62XIRQ-TUZCRA4";
          introducer = false;
        };
      };

      folders = {
        "Notes" = {
          devices = [
            "laptop-pneuma"
            "desktop-logos"
            "server"
            "phone"
          ];
          id = "z6qwq-2hblb";
          ignorePerms = true;
          path = "/home/${config.var.username}/Notes";
        };

        "ReactionImg" = {
          devices = [
            "laptop-pneuma"
            "desktop-logos"
            "server"
            "phone"
          ];
          ignorePerms = true;
          id = "cgpft-aw9cu";
          path = "/home/${config.var.username}/ReactionImg";
        };

        "Website_MonkeMan" = {
          devices = [
            "laptop-pneuma"
            "desktop-logos"
            "server"
          ];
          ignorePerms = true;
          id = "27pjd-yfu36";
          path = "/home/${config.var.username}/Website_MonkeMan";
        };
      };

      gui = {
        theme = "black";
        tls = true;
      };
    };
    user = "${config.var.username}";
  };
}
