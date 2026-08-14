# Aversion Conditioning Blocker (Niri / Wayland)

A self-accountability tool: whenever you focus a blocked application or a
blocked website (detected via the browser window title, i.e. the *active tab*),
a fullscreen, unclosable intervention covers every monitor. The countdown
escalates with your daily attempt count. Afterwards you must consciously pick
one of five reasons. Only **"I need this for work"** grants 10 minutes of
consequence-free access to that one target.

No X11, no browser extension, no debug ports. Detection uses only Niri IPC:
the focused window's `app_id` (apps) and `title` (websites — the active tab's
title IS the browser window title). Background tabs never change the title, so
they never trigger — exactly as specified.

## Configuration

Edit `services.aversion.settings` in `home/programs/aversion/default.nix` (or
the generated `~/.config/aversion/config.toml`):

```nix
services.aversion.settings = {
  blocked_applications = [ ];                        # app_id, e.g. "discord"
  blocked_title_substrings = [ "youtube" "reddit" ]; # case-insensitive, matches the focused window title
  durations = [ 10 30 120 300 ];                     # 1st..4th attempt; 5th+ uses last (seconds)
  work_access_duration = 600;                        # 10 minutes
  poll_interval = 0.5;                               # seconds
  reset_daily = true;
};
```

- **Apps**: find app_ids with `niri msg -j windows | jq '.[].app_id'`.
- **Websites**: use a distinctive title token, e.g. `"youtube"`, `"netflix"`,
  `"twitch"`. Title matching is approximate by design: it can never distinguish
  domains, and a page whose title merely *contains* the token (e.g. a GitHub
  page titled "youtube-dl fork") also counts. That is the price of having zero
  browser integration.

## Behavior

| Attempt | Duration  |
|---------|-----------|
| 1st     | 10 s      |
| 2nd     | 30 s      |
| 3rd     | 2 min     |
| 4th     | 5 min     |
| 5th+    | 5 min     |

- Attempts are counted per day (reset at midnight) plus a lifetime total.
- The overlay cannot be minimized, closed, covered, or outrun via workspaces
  (it is a layer-shell surface above everything, on every workspace and
  monitor). Keyboard input is exclusively routed to it.
- No grace period before the *first* intervention. After one completes, the
  same target stays silent for `re_trigger_cooldown` seconds (default 15) so
  you can switch away instead of being instantly re-locked; staying on the
  target then triggers the next, longer intervention.
- Choosing "I need this for work" additionally requires typing the
  `confirmation_phrase` (default "Yes, I really need this for work") exactly —
  a second, deliberate step before access is granted.
- State survives restarts: `~/.local/state/aversion/state.json` (counters,
  active intervention, active work-access grant). A killed overlay is
  respawned by the daemon; a killed daemon is restarted by systemd
  (`aversion-daemon.service`, user scope).
- Stopping the daemon disables blocking — by design, this is an
  accountability tool, not a jail. A notification tells you when it stops.
- All interventions are silent (no sounds, no notifications).

## Usage

```bash
aversion status            # attempts today / total, intervention, work access
systemctl --user status aversion-daemon
journalctl --user -u aversion-daemon -f
```

## How it works

```
focused window (niri IPC: event-stream wake-ups + 0.5 s polling fallback)
        │  app_id or title matches a blocked target?
        ▼
attempt counter +1  →  escalation duration
        │
        ▼
aversion-overlay  (GTK4 layer-shell, overlay layer, exclusive keyboard)
        │  countdown → "What exactly am I going to do…?" → 5 buttons
        ├── "I need this for work" → type confirmation phrase → 10-min grant
        │                            + countdown chip
        └── any other answer       → remain blocked (cooldown, then next
                                     focus = next attempt)
```

## Enabling on another host

Import the module in that host's `home.nix` (e.g. `../../home/programs/aversion`)
and set `services.aversion.enable = true` in its home config. Both hosts use
the same `default.nix`, so keep personal block lists per-host if needed.

## Limitations (honest)

- Compositor keybinds (e.g. `super+1`) still switch workspaces at the niri
  level; the overlay keeps covering everything, so nothing is visible or
  reachable, but the compositor itself cannot be fully locked by a third-party
  app on Wayland.
- Killing the daemon/overlay is a real bypass; systemd restarts it and the
  state machine resumes, but a determined user can always `systemctl --user
  stop aversion-daemon`. The stop notification is the only guard.
- Title matching is not domain-exact. Exact URL detection (WebDriver BiDi on
  the browser) is a possible future upgrade and would drop in behind
  `match_target` in `daemon.py` without touching anything else.
