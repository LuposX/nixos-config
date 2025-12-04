{ config, pkgs, ... }:

let
  macAddress = "80:E8:2C:C7:83:56";
  wolTime = "18:00";
in
{
  environment.systemPackages = [
    pkgs.wakeonlan
  ];

  ########################################
  ## Systemd service: send magic packet ##
  ########################################
  systemd.services.wake-proxmox = {
    description = "Wake Proxmox server via Wake-on-LAN";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.wakeonlan}/bin/wakeonlan ${macAddress}";
    };
  };

  ####################################
  ## Systemd timer for daily wake  ##
  ####################################
  systemd.timers.wake-proxmox = {
    description = "Timer to wake Proxmox daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* ${wolTime}:00";
      Persistent = true;
    };
  };
}
