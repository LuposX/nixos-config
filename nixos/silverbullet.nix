{
  config,
  pkgs,
  ...
}: {
  # SilverBullet — markdown-first PKM web app, editing the synced
  # research-notes space over the browser.
  #
  # Notes on both machines live in the same folder, kept in sync by
  # Syncthing (folder "ResearchNotes" in nixos/syncthing.nix). Each
  # host serves its local copy on localhost:3002, so edits always hit
  # a live file and Syncthing propagates them.
  #
  # Bound to 127.0.0.1 only — no firewall port, no auth needed. If it
  # ever needs to be reachable from the LAN, add an envFile with
  # `SB_USER=<user>:<password>` (sops) and set
  # listenAddress = "0.0.0.0" + openFirewall.

  services.silverbullet = {
    enable = true;
    spaceDir = "/home/${config.var.username}/Projects/research-notes";
    listenPort = 3002;
    listenAddress = "127.0.0.1";
    # Run as the login user so the service can write into the Syncthing
    # folder without extra group/permission plumbing.
    user = config.var.username;
    group = "users";
  };
}
