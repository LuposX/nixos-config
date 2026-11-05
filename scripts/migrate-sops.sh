#!/usr/bin/env bash
# One-time migration from per-host sops files (single shared age key) to
# per-host keys + a shared secrets/common.yaml. See docs/sops-migration.md.
#
# Usage: ./scripts/migrate-sops.sh <stage>
#   stage-keys    generate per-host age keys, fill .sops.yaml, append the
#                 laptop identity to the local key file (old key kept!)
#   stage-common  build secrets/common.yaml from the existing host files
#   stage-rekey   re-encrypt all three host yamls to the new keys
#   stage-verify  decrypt-check everything possible from this machine
#   stage-cutover swap the local key file to the laptop-only key
#
# Stages must run in order on the laptop (pneuma), from the repo root.
# Remote steps (place keys on desktop/raspberry, rebuild there) are
# printed as commands but never executed here.
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"
KEYDIR="$REPO/secrets/.migration"
SOPS_YAML="$REPO/.sops.yaml"
KEYFILE="$HOME/.config/sops/age/keys.txt"
SHARED_KEYS=(kit-api-key openrouter-api-key hermes-env hindsight-env
  searxng-env netbird-setup-key weather-api smbcredentials sshconfig
  github-key-personal github-key-website gitlab-uni-key
  website-key-pgp website-key-pgp-pub)
REMOTE_USER="${REMOTE_USER:-$USER}"
mask() { umask 077; }

require_sops_yaml() {
  mask; mkdir -p "$KEYDIR"
  if grep -q "__.*_PUBKEY__" "$SOPS_YAML" 2>/dev/null; then
    echo "ERROR: .sops.yaml still contains placeholders — run stage-keys first" >&2
    exit 1
  fi
}

require_common() {
  if [ ! -f "$REPO/secrets/common.yaml" ]; then
    echo "ERROR: secrets/common.yaml missing — run stage-common first" >&2
    exit 1
  fi
}

require_stage_files() {
  require_sops_yaml
  require_common
}

gen_key() { # name -> writes $KEYDIR/$1.age, echoes pubkey
  local name="$1" out err
  out="$KEYDIR/$name.age"
  if [ -f "$out" ]; then
    echo "WARNING: $out already exists, keeping it" >&2
  else
    mask
    age-keygen -o "$out" 2>"$KEYDIR/$name.pub"
  fi
  grep -o 'age1[a-z0-9]*' "$KEYDIR/$name.pub" | head -1
}

append_identity() { # add a private key line to the local key file
  local priv="$1"
  mask
  if ! grep -q "$(grep -o 'AGE-SECRET-KEY-[A-Z0-9]*' "$priv")" "$KEYFILE" 2>/dev/null; then
    printf '\n# added by sops migration\n%s\n' "$(cat "$priv")" >> "$KEYFILE"
  fi
}

case "${1:-}" in

stage-keys)
  mask; mkdir -p "$KEYDIR"
  laptop_pub=$(gen_key laptop)
  desktop_pub=$(gen_key desktop)
  raspberry_pub=$(gen_key raspberry)
  recovery_pub=$(gen_key recovery)
  # Local key file: append the new laptop identity next to the old key.
  # The old identity must stay until stage-cutover (it still decrypts
  # everything during the rekey stages).
  [ -f "$KEYFILE" ] || { echo "ERROR: $KEYFILE not found" >&2; exit 1; }
  cp -n "$KEYFILE" "$KEYFILE.pre-migration" || true
  append_identity "$KEYDIR/laptop.age"
  # Fill the .sops.yaml placeholders.
  sed -i "s/__LAPTOP_PUBKEY__/$laptop_pub/;
          s/__DESKTOP_PUBKEY__/$desktop_pub/;
          s/__RASPBERRY_PUBKEY__/$raspberry_pub/;
          s/__RECOVERY_PUBKEY__/$recovery_pub/" "$SOPS_YAML"
  echo
  echo "Keys generated in $KEYDIR:"
  echo "  laptop:     $laptop_pub"
  echo "  desktop:    $desktop_pub"
  echo "  raspberry:  $raspberry_pub"
  echo "  recovery:   $recovery_pub"
  echo
  echo "MANUAL STEPS:"
  echo "  1. Move $KEYDIR/recovery.age offline NOW (USB drive/password"
  echo "     vault), then delete the file here."
  echo "  2. Later (stage-rekey finished), distribute private keys:"
  echo "     scp $KEYDIR/desktop.age $REMOTE_USER@logos:.config/sops/age/keys.txt"
  echo "     scp $KEYDIR/raspberry.age $REMOTE_USER@prohairesis:.config/sops/age/keys.txt"
  echo "     (on each host: back up the old keys.txt first)"
  echo "  3. Commit .sops.yaml and the module changes; pull on logos and"
  echo "     prohairesis before rebuilding them."
  ;;

stage-common)
  require_sops_yaml
  mask
  # Plaintext lives only in pipes. The laptop file carries all shared
  # keys except netbird-setup-key (historically only in the desktop
  # file); merging both sources covers the full set.
  filter=$(printf '{ "%s": .["%s"]' "${SHARED_KEYS[0]}" "${SHARED_KEYS[0]}")
  for k in "${SHARED_KEYS[@]:1}"; do filter+=", \"$k\": .[\"$k\"]"; done
  filter+=' }'
  jq -s 'add' \
    <(sops -d --output-type json hosts/laptop/secrets/secrets.yaml | jq "$filter") \
    <(sops -d --output-type json hosts/desktop/secrets/secrets.yaml | jq "$filter") \
    > "$KEYDIR/common.plain.json"
  # Refuse half-built output: every shared key must exist and be non-null.
  missing=$(jq -r 'to_entries | map(select(.value == null) | .key) | join(", ")' "$KEYDIR/common.plain.json")
  if [ -n "$missing" ]; then
    echo "ERROR: missing in source files: $missing" >&2
    rm -f "$KEYDIR/common.plain.json"; exit 1
  fi
  cp "$KEYDIR/common.plain.json" secrets/common.yaml
  # In-place encrypt: the path (secrets/common.yaml) drives the
  # creation-rule lookup, so the plaintext must sit at its final path.
  trap 'rm -f secrets/common.yaml.tmp' EXIT
  # The merge ran through jq (JSON); the file sits at its final .yaml path
  # so the creation rule matches, and sops converts it to encrypted YAML.
  sops -i -e --input-type json --output-type yaml secrets/common.yaml
  # sops-nix resolves sopsFile through the git tree: untracked files fail
  # evaluation. Safe to add here — the file is encrypted at this point.
  git add secrets/common.yaml
  rm -f "$KEYDIR/common.plain.json"
  echo "Created secrets/common.yaml (${#SHARED_KEYS[@]} keys). Review it:"
  echo "  sops -d --output-type json secrets/common.yaml | jq 'keys'"
  ;;

stage-rekey)
  require_stage_files
  # All three files are decryptable from here: everything is still
  # encrypted to the old shared key, which is still in $KEYFILE.
  for f in hosts/laptop/secrets/secrets.yaml \
           hosts/desktop/secrets/secrets.yaml \
           hosts/raspberry/secrets/secrets.yaml; do
    echo "== updatekeys $f"
    echo y | sops updatekeys "$f"
  done
  echo
  echo "Host files are now encrypted to their per-host keys. Next:"
  echo "  - distribute $KEYDIR/desktop.age and raspberry.age (commands"
  echo "    printed by stage-keys),"
  echo "  - commit + pull, rebuild logos and prohairesis,"
  echo "  - verify remotely, then run stage-verify and stage-cutover here."
  ;;

stage-verify)
  require_stage_files
  fail=0
  echo "== secrets/common.yaml decrypts locally:"
  sops -d secrets/common.yaml > /dev/null && echo "  OK" || fail=1
  for k in "${SHARED_KEYS[@]}"; do
    if sops -d --output-type json --extract "[\"$k\"]" secrets/common.yaml > /dev/null 2>&1; then
      echo "  $k OK"
    else
      echo "  $k MISSING/UNREADABLE"; fail=1
    fi
  done
  echo "== host yaml decrypts locally:"
  # Only the laptop file is locally decryptable now — desktop and
  # raspberry files are encrypted to their own keys by design.
  sops -d hosts/laptop/secrets/secrets.yaml > /dev/null 2>&1 \
    && echo "  hosts/laptop/... OK" || { echo "  hosts/laptop/... FAIL"; fail=1; }
  echo "  desktop/raspberry yamls: verify on the respective hosts:"
  echo "    sops -d hosts/desktop/secrets/secrets.yaml > /dev/null && echo OK"
  echo "    sops -d hosts/raspberry/secrets/secrets.yaml > /dev/null && echo OK"
  echo
  echo "Remote spot-checks (run on each host after rebuild):"
  echo "  cat /run/secrets/openrouter-api-key > /dev/null && echo OK"
  echo "  journalctl -u sops-nix --no-pager | tail -5"
  exit $fail
  ;;

stage-cutover)
  require_stage_files
  [ -f "$KEYFILE.pre-migration" ] || { echo "ERROR: no pre-migration backup found" >&2; exit 1; }
  mask
  # Local key file: laptop identity only. Old key stays recoverable from
  # the .pre-migration backup until you delete it deliberately.
  cp "$KEYDIR/laptop.age" "$KEYFILE"
  echo "Local key file now holds only the laptop identity."
  echo "  backup: $KEYFILE.pre-migration (keep until every host verifies)"
  echo "  old shared key must also be removed from any other place you"
  echo "  used it (other repos, other sops files) before retiring it."
  echo
  echo "Final step: sudo nixos-rebuild switch --flake .#pneuma"
  ;;

*)
  echo "Usage: $0 {stage-keys|stage-common|stage-rekey|stage-verify|stage-cutover}" >&2
  echo "Run stages in order, on the laptop, from the repo root." >&2
  exit 2
  ;;
esac
