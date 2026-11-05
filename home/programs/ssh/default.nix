# SSH: agent + declarative ~/.ssh/config via programs.ssh.matchBlocks.
# The match blocks themselves are host-specific (different keys and
# destinations per machine), so each hosts/<name>/home.nix sets them.
{
  lib,
  ...
}: {
  services.ssh-agent.enable = true;

  programs.ssh.enable = true;

  # The implicit HM "Host *" defaults are deprecated. The old sshconfig
  # never had global options and every block sets identitiesOnly with an
  # explicit identityFile, so nothing needs to be preserved. Add global
  # options here under programs.ssh.settings."*" if that ever changes.
  programs.ssh.enableDefaultConfig = false;

  # One-time migration cleanup: ~/.ssh/config used to be a sops-nix
  # symlink (secret "sshconfig", now declarative plaintext). Remove the
  # stale link before home-manager checks its targets, so the
  # declarative file can take its place. Safe: only removes symlinks
  # pointing into the sops-nix secret directory.
  home.activation.removeOldSopsSshConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    target="$HOME/.ssh/config"
    if [ -L "$target" ] && readlink "$target" | grep -q "sops-nix"; then
      rm -f "$target"
    fi
  '';
}
