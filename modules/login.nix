# yoinked from https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
# xoxo love this
{
  inputs,
  pkgs,
  vars,
  ...
}: let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions";
in {
  environment.systemPackages = [pkgs.greetd.tuigreet];

  services.greetd = {
    enable = true;
    settings = rec {
      inital_session = {
        command = "Hyprland > /dev/null";
        user = "${vars.user}";
      };
      default_session = inital_session;
    };
  };
}
