#!/usr/bin/env bash
# Wipe a machine and install a host from this flake via nixos-anywhere.
# Usage: bash scripts/install-host.sh <host> root@<ip> <extra-files-directory>
# Run as the normal user on the source machine, not with sudo.
# The target must be a live ISO reachable as root with SSH key auth.
set -euo pipefail

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 3 ]] || fail "usage: $0 <host> root@<ip> <extra-files-directory>"
host=$1
target=$2
[[ "$host" =~ ^[[:alnum:]_-]+$ ]] || fail "invalid host name: $host"
[[ "$target" == root@?* && "$target" != *[[:space:]]* ]] || fail "target must be root@<ip-or-hostname>"

# Resolve relative paths before changing to the repository root.
extra_files=$(realpath -e -- "$3")
[[ -d "$extra_files" && -r "$extra_files" && -x "$extra_files" ]] || fail "extra-files must be a readable directory"
identity="$HOME/.ssh/id_laptop"
[[ -f "$identity" && -r "$identity" ]] || fail "SSH identity not readable: $identity"
command -v jq >/dev/null || fail "jq is required"

cd "$(dirname "$0")/.."

# Inspect evaluated options, including defaults. In particular, an omitted
# passwordFile evaluates to null and must not be coerced to a string.
# shellcheck disable=SC2016 # The interpolation inside --apply is Nix syntax.
install_config=$(nix eval --json ".#nixosConfigurations.$host.config" --apply '
  cfg:
  let
    disks = builtins.attrValues (cfg.disko.devices.disk or {});
    passwords = content:
      (if (content.type or "") == "luks" && (content.passwordFile or null) != null
       then [ content.passwordFile ] else [])
      ++ (if (content.content or null) != null then passwords content.content else [])
      ++ builtins.concatLists (map (p: passwords (p.content or {}))
           (builtins.attrValues (content.partitions or {})));
    users = builtins.filter (u: u.isNormalUser) (builtins.attrValues cfg.users.users);
  in {
    disks = map (d: d.device) disks;
    passwordFiles = builtins.concatLists (map (d: passwords (d.content or {})) disks);
    ageKeyFile = cfg.sops.age.keyFile or null;
    users = map (u: {
      inherit (u) name home uid;
      gid = cfg.users.groups.${u.group}.gid or null;
    }) users;
  }
')
[[ $(jq '.disks | length' <<< "$install_config") -gt 0 ]] || fail "$host has no disko disks"
mapfile -t password_files < <(jq -r '.passwordFiles | unique[]' <<< "$install_config")

args=(--flake ".#$host" -i "$identity" --extra-files "$extra_files")

# sops decrypts the login password during installation, before users exist.
# Tar copies symlinks as links, so the staged key must be an actual file.
age_key=$(jq -r '.ageKeyFile // empty' <<< "$install_config")
if [[ -n "$age_key" ]]; then
  staged_key="$extra_files$age_key"
  [[ -f "$staged_key" && -s "$staged_key" && -r "$staged_key" ]] || fail "missing or unreadable sops age key: $staged_key"
  [[ $(realpath -e -- "$staged_key") == "$staged_key" ]] || fail "stage the age key as a regular file, without symlinks"
  mode=$(stat -c '%a' -- "$staged_key")
  (( (8#$mode & 077) == 0 )) || fail "age key must not be accessible to group or others: $staged_key"
fi

# nixos-anywhere extracts extra-files as root. Restore staged home files
# to their declared owners so Home Manager and user-level sops can use them.
while IFS=$'\t' read -r name home uid gid; do
  if [[ -d "$extra_files$home" ]]; then
    [[ "$uid" != unset && "$gid" != unset ]] || fail "declare a fixed UID and primary-group GID for $name before restoring its home"
    args+=(--chown "$home" "$uid:$gid")
  fi
done < <(jq -r '.users[] | [.name, .home, (.uid // "unset"), (.gid // "unset")] | @tsv' <<< "$install_config")

passdir=""
cleanup() {
  if [[ -n "$passdir" ]]; then
    rm -rf -- "$passdir"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

printf 'Host: %s\nSSH target: %s\nExtra files: %s\nTarget disks to WIPE:\n' "$host" "$target" "$extra_files"
jq -r '.disks[] | "  " + .' <<< "$install_config"
printf 'Verify the target and disk identities before continuing. All data on these disks will be lost.\n'
IFS= read -r -p "Type '$host' to confirm: " confirmation
[[ "$confirmation" == "$host" ]] || fail "installation cancelled"

if [[ ${#password_files[@]} -gt 0 ]]; then
  IFS= read -r -s -p "LUKS passphrase: " p1
  printf '\n'
  [[ -n "${p1//[[:space:]]/}" ]] || fail "LUKS passphrase must not be empty or only whitespace"
  IFS= read -r -s -p "Repeat: " p2
  printf '\n'
  [[ "$p1" == "$p2" ]] || fail "passphrases do not match"

  # Keep the plaintext off disk and remove it when the installer returns.
  umask 077
  passdir=$(mktemp -d "${XDG_RUNTIME_DIR:-/dev/shm}/nixos-install.XXXXXXXX")
  passfile="$passdir/luks-pass"
  printf '%s' "$p1" > "$passfile"
  unset p1 p2
  for f in "${password_files[@]}"; do
    args+=(--disk-encryption-keys "$f" "$passfile")
  done
fi

# nixos-anywhere runs as two invocations. The disko phase (wipe, LUKS
# format, filesystems, mounts) is retried: on pneuma's NVMe the kernel can
# register the new partitions a second after partprobe and udevadm settle
# return, and disko's mkfs then loses the race to the /dev/disk/by-partlabel
# symlinks. Every attempt wipes the disk again, so retrying is safe at any
# point of failure. The install phase is a single run; if it fails midway,
# rerun this script and disko starts over.
anywhere=github:nix-community/nixos-anywhere
attempts=3
disko_ok=1
for ((attempt = 1; attempt <= attempts; attempt++)); do
  printf 'Wiping and formatting the target (attempt %d of %d)\n' "$attempt" "$attempts"
  # Do not exec: this shell must stay alive for its cleanup trap.
  if nix run "$anywhere" -- "${args[@]}" --phases kexec,disko "$target"; then
    disko_ok=0
    break
  fi
  printf 'Formatting attempt %d failed\n' "$attempt" >&2
done
if (( disko_ok )); then
  fail "formatting failed after $attempts attempts"
fi

printf 'Installing %s onto %s\n' "$host" "$target"
nix run "$anywhere" -- "${args[@]}" --phases kexec,install,reboot "$target"
