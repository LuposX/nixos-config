{ config, inputs, pkgs, ... }:
let
  autoGarbageCollector = config.var.autoGarbageCollector;

  pkgsStable = import inputs.nixpkgs-stable {
    system = pkgs.system;
    config.allowUnfree = true;
    config.allowBroken = false;

     config.permittedInsecurePackages = [
        "electron-36.9.5"
    ];
  };
in {
  # Make pkgsStable available everywhere
  _module.args.pkgsStable = pkgsStable;

  # Grants passwordless sudo permission for nixos-rebuild
  security.sudo.extraRules = [{
    users = [ config.var.username ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    channel.enable = false;

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
	"https://niri.cachix.org"
	"https://vicinae.cachix.org"
      ];

      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      ];
    };

    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}