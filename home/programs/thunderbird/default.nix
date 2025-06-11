# From: https://github.com/bytemouse/config/blob/48d9be51a9666c9b62f4b8e84322b9d892ee0aea/home/mail.nix#L5
{
  config,
  lib,
  ...
}: {
  programs.thunderbird = {
    enable = true;
    settings = {
      "privacy.donottrackheader.enable" = true;
    };
    profiles.default.isDefault = true;
  };
}
