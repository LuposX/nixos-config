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
        "laptop" = {
          id = "5SQ6H5H-IIURK6E-NC2FKIE-Q2EXBV4-3OWN7YL-5JVTD42-EWIMSOF-ZH5IYQ6";
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
            "laptop"
            "server"
            "phone"
          ];
          id = "z6qwq-2hblb";
          ignorePerms = true;
          path = "/home/${config.var.username}/Notes";
        };

        "ReactionImg" = {
          devices = [
            "laptop"
            "server"
            "phone"
          ];
          ignorePerms = true;
          id = "cgpft-aw9cu";
          path = "/home/${config.var.username}/ReactionImg";
        };

        "Website_MonkeMan" = {
          devices = [
            "laptop"
            "server"
          ];
          ignorePerms = true;
          id = "27pjd-yfu36";
          path = "/home/${config.var.username}/ReactionImg";
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
