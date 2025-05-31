{ pkgs, lib, config, ... }: {
  imports =
    [ ./eza.nix ./zoxide.nix ./fish.nix ./starship.nix ];

   home.packages = with pkgs; [ 
     bat
   ];
}
