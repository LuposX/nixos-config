{ config, lib, pkgs, ... }: let
  username = config.var.username;
in {
  programs.nnn= {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });

    extraPackages = with pkgs; [
      bat
      eza
      fzf
      imv
      ffmpegthumbnailer
      mediainfo
      sxiv
    ];

    bookmarks = {
        n = "/home/${username}/Projects/Notes";
        u = "/home/${username}/Projects/Notes/University/Bachelor/Semester_8";
        c = "/home/${username}/Projects/nixos-config";
        w = "/home/${username}/Projects/Website_MonkeMan";
    };

    plugins = {
      src = "${pkgs.nnn.src}/plugins";
      mappings = {
         c = "fzcd";
         o = "fzopen";
         p = "preview-tui";
      };
    };
  };
}
