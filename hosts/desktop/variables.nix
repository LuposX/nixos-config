{
  config,
  lib,
  ...
}: {
  imports = [
    ../../themes/default-theme.nix
  ];

  config.var = {
    hostname = "nixos";
    username = "monkeman";
    configDirectory =
      "/home/"
      + config.var.username
      + "/nixos-config"; # The path of the nixos configuration directory

    keyboardLayout = "us";

    location = "Karlsruhe";
    timeZone = "Europe/Berlin";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "de_DE.UTF-8";

    git = {
      username = "LuposX";
      email = "36456825+LuposX@users.noreply.github.com";
    };

    backupFileExtension = "hm-backup";

    autoUpgrade = false;
    autoGarbageCollector = true;

    profile-picture =
      config.var.configDirectory
      + "/ressources/"
      + config.theme.profile-picture-name;
  };

  # Let this here
  # This lets us in other files refer to the variables in this file bz using `var` e.g. `config.var.username`
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
