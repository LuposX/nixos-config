# Hyprpanel is the bar on top of the screen
# Display informations like workspaces, battery, wifi, ...
# For documentation see: https://hyprpanel.com/getting_started/installation.html#nixos
{
  inputs,
  config,
  ...
}: let
  transparentButtons = config.theme.bar.transparentButtons;
  accent = "#${config.lib.stylix.colors.base0D}";
  accent-alt = "#${config.lib.stylix.colors.base03}";
  background = "#${config.lib.stylix.colors.base00}";
  background-alt = "#${config.lib.stylix.colors.base01}";
  foreground = "#${config.lib.stylix.colors.base05}";
  foregroundOnWallpaper = "#${config.theme.textColorOnWallpaper}";
  font = "${config.stylix.fonts.serif.name}";
  fontSizeForHyprpanel = "${toString config.stylix.fonts.sizes.desktop}px";
  rounding = config.theme.rounding;
  border-size = config.theme.border-size;
  gaps-out = config.theme.gaps-out;
  gaps-in = config.theme.gaps-in;
  floating = config.theme.bar.floating;
  transparent = config.theme.bar.transparent;
  position = config.theme.bar.position; # "top" or "bottom"
  notificationOpacity = 90;
  location = config.var.location;
  profile-pic = config.var.profile-picture;
  username = config.var.username;
  isLaptop = config.var.isLaptop;
in {
  programs.hyprpanel = {
    enable = true;

    settings = {
      layout = {
        "bar.layouts" = {
          "*" = {
            "left" = ["dashboard" "workspaces" "windowtitle"];
            "middle" = ["media" "cava"];
            "right" = [
              "systray"
              "volume"
              "bluetooth"
            ] ++ (if isLaptop then ["battery"] else []) ++ [
              "network"
              "clock"
              "notifications"
            ];
          };
        };
      };

      theme.font.name = font;
      theme.font.size = fontSizeForHyprpanel;

      theme.bar.outer_spacing =
        if floating && transparent
        then "0px"
        else "8px";
      theme.bar.buttons.y_margins =
        if floating && transparent
        then "0px"
        else "8px";
      theme.bar.buttons.spacing = "0.3em";
      theme.bar.buttons.radius =
        (
          if transparent
          then toString rounding
          else toString (rounding - 8)
        )
        + "px";
      theme.bar.floating = floating;
      theme.bar.buttons.padding_x = "0.8rem";
      theme.bar.buttons.padding_y = "0.4rem";

      theme.bar.margin_top =
        (
          if position == "top"
          then toString (gaps-in * 2)
          else "0"
        )
        + "px";
      theme.bar.margin_bottom =
        (
          if position == "top"
          then "0"
          else toString (gaps-in * 2)
        )
        + "px";
      theme.bar.margin_sides = toString gaps-out + "px";
      theme.bar.border_radius = toString rounding + "px";
      theme.bar.transparent = transparent;
      theme.bar.location = position;
      theme.bar.dropdownGap = "4.5em";
      theme.bar.menus.shadow =
        if transparent
        then "0 0 0 0"
        else "0px 0px 3px 1px #16161e";
      theme.bar.buttons.style = "default";
      theme.bar.buttons.monochrome = true;
      theme.bar.menus.monochrome = true;
      theme.bar.menus.card_radius = toString rounding + "px";
      theme.bar.menus.border.size = toString border-size + "px";
      theme.bar.menus.border.radius = toString rounding + "px";
      theme.bar.menus.menu.media.card.tint = 90;

      bar.launcher.icon = "";
      bar.workspaces.show_numbered = false;
      bar.workspaces.workspaces = 5;
      bar.workspaces.numbered_active_indicator = "color";
      bar.workspaces.monitorSpecific = false;
      bar.workspaces.applicationIconEmptyWorkspace = "";
      bar.workspaces.showApplicationIcons = true;
      bar.workspaces.showWsIcons = true;

      bar.windowtitle.label = true;
      bar.volume.label = false;
      bar.network.truncation_size = 12;
      bar.bluetooth.label = false;
      bar.clock.format = "%a %b %d %H:%M"; # Alternative 12h: "%a %b %d  %I:%M %p";
      menus.clock.time.military = true;
      bar.notifications.show_total = true;
      bar.media.show_active_only = true;

      bar.customModules.updates.pollingInterval = 1440000;
      bar.customModules.cava.showIcon = false;
      bar.customModules.cava.stereo = true;
      bar.customModules.cava.showActiveOnly = true;

      notifications.position = "top right";
      notifications.showActionsOnHover = true;
      theme.notification.opacity = notificationOpacity;
      theme.notification.enableShadow = true;
      theme.notification.border_radius = toString rounding + "px";

      theme.osd.enable = true;
      theme.osd.orientation = "vertical";
      theme.osd.location = "left";
      theme.osd.radius = toString rounding + "px";
      theme.osd.margins = "0px 0px 0px 10px";
      theme.osd.muted_zero = true;

      menus.clock.weather.location = location;
      menus.clock.weather.unit = "metric";
      bar.customModules.weather.unit = "metric";
      menus.clock.weather.key = config.sops.secrets.weather-api.path;
      menus.dashboard.powermenu.confirmation = false;
      menus.dashboard.powermenu.avatar.image = profile-pic;

      menus.dashboard.shortcuts.enabled = false;

      menus.power.lowBatteryNotification = isLaptop;

      wallpaper.enable = false;
    };
  };
}
