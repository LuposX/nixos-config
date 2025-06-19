{
  pkgs,
  config,
  ...
}: let
  hostname = config.var.hostname;
  keyboardLayout = config.var.keyboardLayout;
  configDir = config.var.configDirectory;
  timeZone = config.var.timeZone;
  defaultLocale = config.var.defaultLocale;
  extraLocale = config.var.extraLocale;
  autoUpgrade = config.var.autoUpgrade;
  username = config.var.username;
  backupFileExtension = config.var.backupFileExtension;
  isLaptop = config.var.isLaptop;
in {
  networking.hostName = hostname;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  system.autoUpgrade = {
    enable = autoUpgrade;
    dates = "04:00";
    flake = "${configDir}";
    flags = ["--update-input" "nixpkgs" "--commit-lock-file"];
    allowReboot = false;
  };

  # Automatically deletes configs, which are conflicting, so that home manager doesn't complain.
  # See: https://github.com/nix-community/home-manager/issues/4199
  system.userActivationScripts = {
    removeConflictingFiles = {
      text = ''
        rm -f /home/${username}/.config/mimeapps.list.${backupFileExtension}
        rm -f /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml.${backupFileExtension}
        rm -f /home/${username}/.config/hyprpanel/config.json.${backupFileExtension}
        rm -f /home/${username}/.ssh/config.${backupFileExtension}
        /home/monkeman/.ssh/config
      '';
    };
  };

  time = {timeZone = timeZone;};
  i18n.defaultLocale = defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = extraLocale;
    LC_IDENTIFICATION = extraLocale;
    LC_MEASUREMENT = extraLocale;
    LC_MONETARY = extraLocale;
    LC_NAME = extraLocale;
    LC_NUMERIC = extraLocale;
    LC_PAPER = extraLocale;
    LC_TELEPHONE = extraLocale;
    LC_TIME = extraLocale;
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = keyboardLayout;
      xkb.variant = "";
    };
    gnome.gnome-keyring.enable = true;
    # Helps with Browsers
    # See: https://wiki.archlinux.org/title/Profile-sync-daemon
    psd = {
      enable = true;
      resyncTimer = "10m";
    };
  };
  console.keyMap = keyboardLayout;

  # Annoying, will overwrite usage of other terminals for example in wofi.
  services.xserver.excludePackages = [pkgs.xterm];

  environment.variables = {
    XDG_DATA_HOME = "$HOME/.local/share";
    PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
    EDITOR = "nvim";
    TERMINAL = "kitty";
    TERM = "kitty";
    BROWSER = "firefox";
  };


  programs.dconf.enable = true;
  services = {
    dbus = {
      enable = true;
      implementation = "broker";
      packages = with pkgs; [gcr gnome-settings-daemon];
    };
    # Allows access network locations (like FTP, SFTP, SMB).
    gvfs.enable = true;
    # Switch between: power saving / balanced / performance profiles.
    power-profiles-daemon.enable = true;
    upower.enable = true;
    # daemon for managing disk drives.
    udisks2.enable = true;
  };

  # Faster rebuilding
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [
    hyprland-qtutils
    fd
    bc
    gcc
    git-ignore
    xdg-utils
    xdg-terminal-exec
    wget
    curl
    vim
    gparted

    # Ventoy with GUI override
    (ventoy.override {
      defaultGuiType = "qt5";
      withQt5 = true;
    })

    # Needed for weather api of hyprpanel
    glib-networking
    openssl
    nss
    gsettings-desktop-schemas

    imagemagick

    # For my Website
    hugo

    # Internet
    wpa_supplicant
  ];
  services.gnome.glib-networking.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
    "ventoy-qt5-1.1.05"
  ];
  # If you dual boot windows and linux, disable if you only use linux.
  time.hardwareClockInLocalTime = !isLaptop;

  # For terminal stuff, who knows.
  xdg.terminal-exec.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  xdg.terminal-exec.settings = {
    default = ["kitty.desktop"];
  };

  security = {
    # allow wayland lockers to unlock the screen
    pam.services.hyprlock.text = "auth include login";

    # userland niceness
    rtkit.enable = true;

    # don't ask for password for wheel group
    sudo.wheelNeedsPassword = false;
  };
  networking.nameservers = [ "192.168.12.100" ];
}
