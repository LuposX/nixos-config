# sops migration: per-host keys + shared common file

One-time migration away from three sops files that are all encrypted to a
single shared age key. Target state:

- `secrets/common.yaml` — user-scoped secrets that follow the machines
  (API keys, ssh/gpg identity, smb, service env files). Encrypted to all
  personal-machine keys plus recovery.
- `hosts/<name>/secrets/secrets.yaml` — only what is bound to that host.
  Each file encrypted to that host's own key plus recovery.
- One age key per host; a fifth recovery key exists offline only.

The laptop currently carries the key that decrypts every host's secrets,
including the internet-facing raspberry. That is the problem this fixes.

## What moved where

Into `secrets/common.yaml` (from the laptop and desktop yaml):

    kit-api-key, openrouter-api-key, hermes-env, hindsight-env,
    searxng-env, netbird-setup-key, weather-api, smbcredentials,
    sshconfig, github-key-personal, github-key-website, gitlab-uni-key,
    website-key-pgp, website-key-pgp-pub

Staying host-bound: laptop keeps `ssh-logos`, `ssh-prohairesis`;
desktop keeps `ssh-logos-pub`; raspberry keeps everything in its file
(`adguard-pwd`, `duckdns-dns-token`, `air-vpn`, `miniflux-admin-credentials`,
`ssh-prohairesis-pub`, `netbird-setup-key` is shared now but its copy in
the raspberry file is harmless to keep).

Module changes already applied in this repo: `nixos/sops.nix`
(defaultSopsFile now common.yaml — this also fixes the old bug where the
laptop decrypted system secrets from the desktop's yaml), `nixos/pi.nix`
(openrouter + kit keys), and both desktop-machine user secret modules.

## How to run it

All stages run on the laptop, from the repo root:

```sh
./scripts/migrate-sops.sh stage-keys     # generate keys, fill .sops.yaml
./scripts/migrate-sops.sh stage-common   # build + encrypt common.yaml
./scripts/migrate-sops.sh stage-rekey    # re-encrypt the three host yamls
```

Manual steps between and after stages (the script prints them again):

1. After `stage-keys`: move `secrets/.migration/recovery.age` offline and
   delete it from the repo working tree.
2. After `stage-rekey`: `scp secrets/.migration/{desktop,raspberry}.age`
   to the respective hosts as `~/.config/sops/age/keys.txt` (back up the
   old file there first).
3. Commit everything, pull on logos and prohairesis, rebuild both there:
   `sudo nixos-rebuild switch --flake .#logos` / `.#prohairesis`.
4. `./scripts/migrate-sops.sh stage-verify` on the laptop, then the
   printed remote spot-checks.
5. `./scripts/migrate-sops.sh stage-cutover` — replaces the local
   `keys.txt` with the laptop-only identity (old key preserved in
   `keys.txt.pre-migration`).
6. `sudo nixos-rebuild switch --flake .#pneuma`.

Two evaluation constraints to know about, both enforced by sops-nix:

- Until `stage-common` has run, every host rebuild fails at Nix
  evaluation because the modules reference the not-yet-created
  `secrets/common.yaml`. Run stages keys + common before planning any
  other rebuild.
- sops-nix resolves `sopsFile` through the git tree, so untracked files
  fail evaluation with “not tracked by Git”. `stage-common` runs
  `git add secrets/common.yaml` for you; make sure it is committed
  before rebuilding the other hosts.

## Rollback

Every rekeyed file is re-encryptable from the old key, which survives in
`~/.config/sops/age/keys.txt.pre-migration` and in `secrets/.migration/`
until cleanup. Git history holds the old ciphertext. Nothing is lost as
long as neither backup is deleted.

## Cleanup after verification

- Delete `secrets/.migration/` (after `recovery.age` is safely offline).
- Delete `~/.config/sops/age/keys.txt.pre-migration`.
- Retire the old shared key everywhere: the old yaml entries remain as
  stale encrypted keys inside the host files; remove them manually with
  `sops hosts/<name>/secrets/secrets.yaml` (delete the lines, save).
- The age key generation also invalidated nothing else — but check other
  repos/tools using the old key file before the final deletion.
