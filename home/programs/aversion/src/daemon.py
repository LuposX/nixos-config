#!/usr/bin/env python3
"""aversion-daemon — Aversion conditioning blocker for Niri/Wayland.

Watches the *focused* window via niri IPC (app_id + title). Whenever the user
attempts to access a blocked application or website, it runs a fullscreen
layer-shell intervention (aversion-overlay) whose duration escalates with the
daily attempt counter. Answering "I need this for work" grants 10 minutes of
consequence-free access to that one target.

No X11, no browser integration: the active tab's title IS the browser window
title, which niri already exposes. Background tabs never change it, so they
never trigger an intervention.

State:  ~/.local/state/aversion/state.json   (survives restarts; intervention
        and work-access grants are restored)
Config: ~/.config/aversion/config.toml        (or $AVERSION_CONFIG)
"""

import json
import os
import shutil
import subprocess
import sys
import threading
import time
import tomllib
from pathlib import Path

ANSWERS_WORK = "I need this for work"

CONFIG_PATH = Path(os.environ.get("AVERSION_CONFIG", "~/.config/aversion/config.toml")).expanduser()
STATE_PATH = Path(os.environ.get("AVERSION_STATE", "~/.local/state/aversion/state.json")).expanduser()
OVERLAY_BIN = os.environ.get("AVERSION_OVERLAY", "aversion-overlay")
CHIP_BIN = os.environ.get("AVERSION_CHIP", "aversion-chip")

DEFAULTS = {
    "blocked_applications": [],
    "blocked_title_substrings": [],
    "durations": [10, 30, 120, 300],
    "work_access_duration": 600,
    "poll_interval": 0.5,
    "reset_daily": True,
    # seconds a target stays silent after an intervention ended, so the user
    # has a moment to switch away instead of being instantly re-locked
    "re_trigger_cooldown": 15.0,
    # phrase that must be typed after choosing "I need this for work"
    "confirmation_phrase": "Yes, I really need this for work",
    # cap on kept attempt-history entries in state.json
    "history_limit": 500,
}


# --------------------------------------------------------------------------- #
# config / state
# --------------------------------------------------------------------------- #

def load_config() -> dict:
    cfg = dict(DEFAULTS)
    try:
        data = tomllib.loads(CONFIG_PATH.read_text())
    except (FileNotFoundError, tomllib.TOMLDecodeError) as e:
        print(f"aversion: config not readable ({e}); using defaults", file=sys.stderr)
        data = {}
    for k in DEFAULTS:
        if k in data:
            cfg[k] = data[k]
    return cfg


def default_state() -> dict:
    return {
        "date": time.strftime("%Y-%m-%d"),
        "attempts_today": 0,
        "attempts_total": 0,
        "history": [],
        "grant": None,          # {"target": str, "expires_at": float}
        "intervention": None,   # {"target","kind","attempt","started_at","end_at","phase","answer"}
    }


def load_state() -> dict:
    try:
        st = json.loads(STATE_PATH.read_text())
        for k, v in default_state().items():
            st.setdefault(k, v)
    except (FileNotFoundError, json.JSONDecodeError):
        st = default_state()
    return st


def save_state(st: dict) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE_PATH.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(st, indent=2))
    tmp.rename(STATE_PATH)


# --------------------------------------------------------------------------- #
# niri
# --------------------------------------------------------------------------- #

def focused_window():
    """Return the focused window dict from niri, or None."""
    niri = shutil.which("niri")
    if niri is None:
        return None
    try:
        r = subprocess.run(
            [niri, "msg", "-j", "focused-window"],
            capture_output=True, text=True, timeout=3,
        )
    except (subprocess.SubprocessError, OSError):
        return None
    if r.returncode != 0:
        return None
    try:
        data = json.loads(r.stdout)
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, dict) else None


def match_target(cfg: dict, win: dict):
    """Return ("app"|"site", matched-name) if the focused window is an attempt."""
    app_id = (win.get("app_id") or "").strip().lower()
    title = (win.get("title") or "").strip().lower()
    for a in cfg["blocked_applications"]:
        if a.strip().lower() == app_id:
            return ("app", a.strip())
    for s in cfg["blocked_title_substrings"]:
        if s.strip().lower() and s.strip().lower() in title:
            return ("site", s.strip())
    return None


def duration_for(cfg: dict, attempt: int) -> float:
    d = cfg["durations"]
    if not d:
        return 10.0
    return float(d[-1] if attempt > len(d) else d[attempt - 1])


# --------------------------------------------------------------------------- #
# daemon
# --------------------------------------------------------------------------- #

class Daemon:
    def __init__(self, cfg: dict):
        self.cfg = cfg
        self.state = load_state()
        self.overlay_proc = None
        self.overlay_answer = None
        self.chip_proc = None
        self.running = True
        self.last_trigger = {}   # target -> timestamp of last completed intervention
        self._wake = threading.Event()  # set by the niri event-stream watcher

    # -- persistence -------------------------------------------------------- #

    def save(self):
        save_state(self.state)

    # -- overlay supervision ------------------------------------------------ #

    def _spawn_overlay(self, remaining: float):
        iv = self.state["intervention"]
        args = [
            OVERLAY_BIN,
            "--attempt", str(iv["attempt"]),
            "--remaining", str(max(0.0, remaining)),
            "--target", iv["target"],
            "--attempts-today", str(self.state["attempts_today"]),
            "--total", str(self.state["attempts_total"]),
            "--confirm-phrase", str(self.cfg.get("confirmation_phrase", "")),
        ]
        proc = subprocess.Popen(args, stdout=subprocess.PIPE, text=True)
        self.overlay_proc = proc
        self.overlay_answer = None
        threading.Thread(target=self._read_overlay, args=(proc,), daemon=True).start()

    def _read_overlay(self, proc):
        try:
            out = proc.stdout.read().strip()
        except Exception:
            out = ""
        if self.overlay_proc is proc:
            self.overlay_answer = out or None

    def _spawn_chip(self):
        g = self.state.get("grant")
        if not g:
            return
        self.chip_proc = subprocess.Popen([
            CHIP_BIN,
            "--until", str(g["expires_at"]),
            "--attempts", str(self.state["attempts_today"]),
            "--total", str(self.state["attempts_total"]),
        ])

    # -- state machine ------------------------------------------------------ #

    def _begin_intervention(self, target):
        self.state["attempts_today"] += 1
        self.state["attempts_total"] += 1
        attempt = self.state["attempts_today"]
        dur = duration_for(self.cfg, attempt)
        now = time.time()
        self.state["history"].append({
            "ts": now, "kind": target[0], "target": target[1],
        })
        limit = max(1, int(self.cfg.get("history_limit", 500)))
        self.state["history"] = self.state["history"][-limit:]
        self.state["intervention"] = {
            "target": target[1], "kind": target[0],
            "attempt": attempt, "started_at": now,
            "end_at": now + dur, "phase": "countdown", "answer": None,
        }
        self.save()
        print(f"aversion: attempt #{attempt} ({target[1]}) — {int(dur)}s intervention")
        self._spawn_overlay(dur)

    def _maybe_trigger(self):
        win = focused_window()
        if win is None:
            return
        target = match_target(self.cfg, win)
        if target is None:
            return
        now = time.time()
        g = self.state.get("grant")
        if g and g.get("target") == target[1] and now < g.get("expires_at", 0):
            return  # work access: consequence-free for this target
        cooldown = max(0.0, float(self.cfg.get("re_trigger_cooldown", 15.0)))
        if now - self.last_trigger.get(target[1], -1e9) < cooldown:
            return  # just went through an intervention for this target
        self._begin_intervention(target)

    def _supervise_intervention(self, now):
        iv = self.state["intervention"]
        proc = self.overlay_proc
        if proc is not None and proc.poll() is None:
            return  # overlay still up

        # overlay process ended
        answer = self.overlay_answer
        self.overlay_proc = None
        self.overlay_answer = None

        if answer is None:
            # killed / crashed before answering -> respawn from persisted phase
            remaining = iv["end_at"] - now
            if remaining > 0:
                iv["phase"] = "countdown"
            else:
                iv["phase"] = "question"
            self.save()
            print("aversion: overlay died — respawning")
            self._spawn_overlay(remaining)
            return

        # answered
        iv["answer"] = answer
        iv["phase"] = "answered"
        self.save()
        self.last_trigger[iv["target"]] = now
        if answer == ANSWERS_WORK:
            self.state["grant"] = {
                "target": iv["target"],
                "expires_at": now + self.cfg["work_access_duration"],
            }
            print(f"aversion: work access granted for {iv['target']} "
                  f"({self.cfg['work_access_duration']}s)")
            self._spawn_chip()
        else:
            print(f"aversion: answer '{answer}' — access remains blocked")
        self.state["intervention"] = None
        self.save()

    def _supervise_grant(self, now):
        g = self.state.get("grant")
        if not g:
            return
        if now >= g.get("expires_at", 0):
            self.state["grant"] = None
            self.save()
            print("aversion: work access expired")
            return
        if self.chip_proc is not None and self.chip_proc.poll() is not None:
            self._spawn_chip()  # chip died early — respawn

    def _daily_rollover(self):
        today = time.strftime("%Y-%m-%d")
        if self.state.get("date") != today:
            self.state["date"] = today
            self.state["attempts_today"] = 0
            self.save()
            print("aversion: new day — attempts reset")

    def _resume_pending(self):
        """Restore an active intervention / grant after a restart."""
        now = time.time()
        iv = self.state.get("intervention")
        if iv:
            if iv.get("answer"):
                # daemon died between answer and completion
                if iv["answer"] == ANSWERS_WORK:
                    self.state["grant"] = {
                        "target": iv["target"],
                        "expires_at": now + self.cfg["work_access_duration"],
                    }
                    print("aversion: restored work access (unfinished answer)")
                self.state["intervention"] = None
                self.save()
            else:
                remaining = iv["end_at"] - now
                print(f"aversion: resuming intervention #{iv['attempt']} "
                      f"({max(0, int(remaining))}s left)")
                self._spawn_overlay(remaining)
        g = self.state.get("grant")
        if g:
            if now >= g.get("expires_at", 0):
                self.state["grant"] = None
                self.save()
            else:
                self._spawn_chip()

    # -- niri event stream --------------------------------------------------- #
    # Instant wake-ups on window/focus/title events (title changes matter:
    # switching tabs in the browser changes the title without a focus change).
    # The regular poll stays as a fallback, so a broken event stream degrades
    # to the old behaviour instead of failing.

    # niri's event stream (26.x) emits full state snapshots per change:
    # {"WindowsChanged": ...} / {"WorkspacesChanged": ...} — no granular
    # events. Waking on either covers focus, title, open and close changes.
    _WAKE_EVENTS = ("WindowsChanged", "WorkspacesChanged")

    def _event_watcher(self):
        niri = shutil.which("niri")
        if niri is None:
            return
        while self.running:
            try:
                proc = subprocess.Popen(
                    [niri, "msg", "-j", "event-stream"],
                    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
                )
            except OSError:
                time.sleep(5)
                continue
            try:
                for line in proc.stdout:
                    if not self.running:
                        break
                    if any(k in line for k in self._WAKE_EVENTS):
                        self._wake.set()
            except Exception:
                pass
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
            if self.running:
                time.sleep(1)  # event stream ended (niri restart?) — reconnect

    # -- main loop ---------------------------------------------------------- #

    def run(self):
        threading.Thread(target=self._event_watcher, daemon=True).start()
        self._resume_pending()
        interval = max(0.1, float(self.cfg["poll_interval"]))
        while self.running:
            now = time.time()
            try:
                if self.cfg.get("reset_daily"):
                    self._daily_rollover()
                if self.state["intervention"] is None:
                    self._maybe_trigger()
                else:
                    self._supervise_intervention(now)
                self._supervise_grant(now)
            except Exception as e:
                print(f"aversion: error in loop: {e}", file=sys.stderr)
            self._wake.wait(interval)
            self._wake.clear()


def main():
    # single-instance lock: prevents a manually started daemon from running
    # alongside the systemd one and double-counting attempts
    import fcntl
    lock_path = STATE_PATH.parent / "daemon.lock"
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    lock_fd = open(lock_path, "a+")
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        print("aversion: another instance is already running (lock held)",
              file=sys.stderr)
        sys.exit(1)

    cfg = load_config()
    print(f"aversion: starting — config={CONFIG_PATH} state={STATE_PATH}")
    print(f"aversion: niri={shutil.which('niri')} overlay={shutil.which('aversion-overlay')}")
    print(f"aversion: blocked_applications={cfg['blocked_applications']} "
          f"blocked_title_substrings={cfg['blocked_title_substrings']}")
    if not shutil.which("niri"):
        print("aversion: WARNING niri not found in PATH — will retry", file=sys.stderr)

    def stop(signum, _frame):
        print("aversion: shutting down")
        d.running = False
        if d.overlay_proc:
            try:
                d.overlay_proc.terminate()
            except Exception:
                pass
        d.save()

    import signal
    d = Daemon(cfg)
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    d.run()


if __name__ == "__main__":
    main()
