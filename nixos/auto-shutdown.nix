# Shuts the desktop down silently every day at 22:30, 23:00 and 23:15,
# so it is off at the latest by 23:15 even if it was switched on again.
# No warning or wall message is sent. `systemctl poweroff` skips the
# delay and the broadcast that plain `shutdown` would do.
{
  pkgs,
  ...
}: let
  poweroff = pkgs.systemd;
in {
  systemd.services.auto-shutdown-22-30 = {
    description = "Automatic daily shutdown at 22:30";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${poweroff}/bin/systemctl poweroff";
    };
  };
  systemd.timers.auto-shutdown-22-30 = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # Not persistent: if the PC is off at the scheduled time, it
      # should not power off again right after being switched on.
      Persistent = false;
      OnCalendar = "*-*-* 22:30";
      Unit = "auto-shutdown-22-30.service";
    };
  };

  systemd.services.auto-shutdown-23-00 = {
    description = "Automatic daily shutdown at 23:00";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${poweroff}/bin/systemctl poweroff";
    };
  };
  systemd.timers.auto-shutdown-23-00 = {
    wantedBy = ["timers.target"];
    timerConfig = {
      Persistent = false;
      OnCalendar = "*-*-* 23:00";
      Unit = "auto-shutdown-23-00.service";
    };
  };

  systemd.services.auto-shutdown-23-15 = {
    description = "Automatic daily shutdown at 23:15";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${poweroff}/bin/systemctl poweroff";
    };
  };
  systemd.timers.auto-shutdown-23-15 = {
    wantedBy = ["timers.target"];
    timerConfig = {
      Persistent = false;
      OnCalendar = "*-*-* 23:15";
      Unit = "auto-shutdown-23-15.service";
    };
  };
}
