{ config, lib, ... }: {
  imports = [
  ];

  config.var = {
    hostname = "nixos";
    username = "monkeman";
    configDirectory = "/home/" + config.var.username
      + "/nixos-config"; # The path of the nixos configuration directory

    keyboardLayout = "us";

    location = "Berlin";
    timeZone = "Europe/Berlin";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "de_DE.UTF-8";

    git = {
      username = "LuposX";
      email = "36456825+LuposX@users.noreply.github.com";
    };

    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  # Let this here
  # This lets us in other files refer to the variables in this file bz using `var` e.g. `config.var.username`
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
