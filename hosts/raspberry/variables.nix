{
  config,
  lib,
  ...
}: {
  config.var = {
    isLaptop = true;

    hostname = "prohairesis";
    username = "monkeman";
    configDirectory =
      "/home/"
      + config.var.username
      + "/nixos-config"; # The path of the nixos configuration directory

    keyboardLayout = "de";

    location = "Karlsruhe";
    timeZone = "Europe/Berlin";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "de_DE.UTF-8";

    ipAddress = "192.168.12.100";

    git = {
      username = "LuposX";
      email = "36456825+LuposX@users.noreply.github.com";
    };

    backupFileExtension = "hm-backup";

    autoUpgrade = false;
    autoGarbageCollector = true;
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
