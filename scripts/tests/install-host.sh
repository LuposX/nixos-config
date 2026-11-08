#!/usr/bin/env bash
# Regression tests with a fake nix executable. No SSH or disk operations.
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
real_nix=$(command -v nix)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/home/.ssh" "$work/runtime" "$work/extra files/home/test-user/.config/sops/age"
printf 'dummy identity\n' > "$work/home/.ssh/id_laptop"
key="$work/extra files/home/test-user/.config/sops/age/keys.txt"
printf 'dummy age key\n' > "$key"
chmod 600 "$key"

export HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime"
export MOCK_CONFIG="$work/config.json" MOCK_LOG="$work/args" MOCK_CALLED="$work/called"
export MOCK_COUNT="$work/count" MOCK_FAIL_FIRST="$work/fail-first"
export MOCK_EXIT=0 MOCK_SIGNAL='' EXPECT_PASS=' test passphrase with spaces '
printf 0 > "$MOCK_COUNT"
: > "$MOCK_LOG"
export PATH="$work/bin:$PATH"

# The mock validates passphrase bytes and permissions without logging them,
# and simulates a disko-phase failure once when MOCK_FAIL_FIRST exists.
# shellcheck disable=SC2016
printf '%s\n' '#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  eval) printf "%s\n" "$(<"$MOCK_CONFIG")" ;;
  run)
    printf "%s" "$(( $(<"$MOCK_COUNT") + 1 ))" > "$MOCK_COUNT"
    printf "%s\n" "$@" >> "$MOCK_LOG"
    phases=()
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == --disk-encryption-keys ]]; then
        [[ -f "$3" && $(stat -c %a "$3") == 600 ]]
        [[ $(stat -c %a "$(dirname "$3")") == 700 ]]
        [[ $(<"$3") == "$EXPECT_PASS" ]]
        shift 3
      elif [[ "$1" == --phases ]]; then
        phases+=("$2")
        shift 2
      else
        shift
      fi
    done
    if [[ ${phases[0]:-} == kexec,disko && -e "$MOCK_FAIL_FIRST" ]]; then
      rm -f "$MOCK_FAIL_FIRST"
      exit 1
    fi
    touch "$MOCK_CALLED"
    if [[ -n "$MOCK_SIGNAL" ]]; then
      kill -s "$MOCK_SIGNAL" "$PPID"
    fi
    exit "$MOCK_EXIT"
    ;;
  *) exit 99 ;;
esac' > "$work/bin/nix"
chmod +x "$work/bin/nix"

base_config='{
  "disks": ["/dev/nvme0n1"],
  "passwordFiles": ["/tmp/luks-pass"],
  "ageKeyFile": "/home/test-user/.config/sops/age/keys.txt",
  "users": [{"name":"test-user", "home":"/home/test-user", "uid":1000, "gid":100}]
}'
printf '%s\n' "$base_config" > "$MOCK_CONFIG"

run_case() {
  local expected=$1 input=$2 actual=0
  shift 2
  rm -f "$MOCK_CALLED"
  : > "$MOCK_LOG"
  printf 0 > "$MOCK_COUNT"
  printf '%s' "$input" | bash "$repo/scripts/install-host.sh" "$@" > "$work/output" 2>&1 || actual=$?
  if [[ "$actual" -ne "$expected" ]]; then
    printf 'Expected exit %s, got %s\n' "$expected" "$actual" >&2
    printf '%s\n' "$(<"$work/output")" >&2
    exit 1
  fi
  [[ -z $(find "$XDG_RUNTIME_DIR" -mindepth 1 -print -quit) ]] || { printf 'passphrase leftovers\n' >&2; exit 1; }
}

assert_count() {
  [[ $(<"$MOCK_COUNT") == "$1" ]] || { printf 'Expected %s nix invocations, got %s\n' "$1" "$(<"$MOCK_COUNT")" >&2; exit 1; }
}

args=(pneuma root@review.invalid "$work/extra files")
valid_input=$(printf 'pneuma\n%s\n%s\n' "$EXPECT_PASS" "$EXPECT_PASS")$'\n'

# Happy path: disko phase, then install phase.
run_case 0 "$valid_input" "${args[@]}"
[[ -f "$MOCK_CALLED" ]]
assert_count 2
grep -Fxq -- '--extra-files' "$MOCK_LOG"
grep -Fxq -- "$work/extra files" "$MOCK_LOG"
grep -Fxq -- '--chown' "$MOCK_LOG"
grep -Fxq -- '1000:100' "$MOCK_LOG"
[[ $(grep -Fxq -- 'kexec,disko' "$MOCK_LOG"; grep -Fxc -- 'kexec,disko' "$MOCK_LOG") == 1 ]]
grep -Fxq -- 'kexec,install,reboot' "$MOCK_LOG"
printf 'PASS: two-phase run with extra-files and ownership\n'

# First disko attempt fails once; the script retries and proceeds.
touch "$MOCK_FAIL_FIRST"
run_case 0 "$valid_input" "${args[@]}"
assert_count 3
[[ $(grep -Fxc -- 'kexec,disko' "$MOCK_LOG") == 2 ]]
grep -Fxq -- 'kexec,install,reboot' "$MOCK_LOG"
printf 'PASS: disko phase retried after a failure\n'

# All disko attempts fail; the install phase never starts.
MOCK_EXIT=1
run_case 1 "$valid_input" "${args[@]}"
assert_count 3
if grep -Fxq -- 'kexec,install,reboot' "$MOCK_LOG"; then
  printf 'Install phase started despite formatting failure\n' >&2
  exit 1
fi
MOCK_EXIT=0
printf 'PASS: exhausted retries stop before the install phase\n'

MOCK_SIGNAL=TERM
run_case 143 "$valid_input" "${args[@]}"
assert_count 1
MOCK_SIGNAL=''
printf 'PASS: termination signal cleanup\n'

for input in $'pneuma\n\n' $'pneuma\n   \n' $'pneuma\none\ntwo\n' $'wrong-host\n'; do
  run_case 1 "$input" "${args[@]}"
  [[ ! -e "$MOCK_CALLED" ]]
done
assert_count 0
printf 'PASS: empty, whitespace-only, mismatched, and cancelled input rejected\n'

run_case 1 '' pneuma root@review.invalid
run_case 1 '' "${args[@]}" ignored-argument
run_case 1 '' pneuma local-user@review.invalid "$work/extra files"
run_case 1 '' pneuma root@review.invalid "$work/missing-directory"
printf 'PASS: invalid arguments rejected\n'

mv "$key" "$key.backup"
run_case 1 '' "${args[@]}"
[[ ! -e "$MOCK_CALLED" ]]
ln -s "$key.backup" "$key"
run_case 1 '' "${args[@]}"
[[ ! -e "$MOCK_CALLED" ]]
rm "$key"
mv "$key.backup" "$key"
chmod 644 "$key"
run_case 1 '' "${args[@]}"
[[ ! -e "$MOCK_CALLED" ]]
chmod 600 "$key"
printf 'PASS: missing, symlinked, and public age keys rejected\n'

jq '.users[0].uid = null' <<< "$base_config" > "$MOCK_CONFIG"
run_case 1 '' "${args[@]}"
[[ ! -e "$MOCK_CALLED" ]]
jq '.disks = []' <<< "$base_config" > "$MOCK_CONFIG"
run_case 1 '' "${args[@]}"
[[ ! -e "$MOCK_CALLED" ]]
printf 'PASS: unknown home ownership and missing disko disks rejected\n'

jq '.passwordFiles = []' <<< "$base_config" > "$MOCK_CONFIG"
run_case 0 $'pneuma\n' "${args[@]}"
assert_count 2
if grep -Fxq -- '--disk-encryption-keys' "$MOCK_LOG"; then
  printf 'Unexpected disk-encryption-keys argument\n' >&2
  exit 1
fi
printf 'PASS: no password files leaves prompting to disko\n'

# Exercise the actual Nix inspector against a minimal config. This only
# evaluates Nix expressions; it never builds or runs an installer.
inspect=$(awk '
  /^install_config=\$\(nix eval/ { copying = 1; next }
  copying && $0 == "\047)" { exit }
  copying { print }
' "$repo/scripts/install-host.sh")
"$real_nix" eval --json --expr "
  let
    inspect = $inspect;
    makeConfig = password: {
      users.users = {};
      disko.devices.disk.main = {
        device = \"/dev/test\";
        content = {
          type = \"gpt\";
          partitions.root.content = {
            type = \"luks\";
            passwordFile = password;
            content.type = \"filesystem\";
          };
        };
      };
    };
  in {
    withoutPassword = inspect (makeConfig null);
    withPassword = inspect (makeConfig \"/tmp/luks pass\");
  }
" | jq -e '.withoutPassword.passwordFiles == [] and .withPassword.passwordFiles == ["/tmp/luks pass"]' > /dev/null
printf 'PASS: Nix inspector handles null passwordFile and paths containing spaces\n'