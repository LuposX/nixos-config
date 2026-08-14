#!/usr/bin/env python3
"""aversion-status — print the current blocker state from state.json."""

import json
import os
import sys
import time
from pathlib import Path

STATE = Path(os.environ.get("AVERSION_STATE", "~/.local/state/aversion/state.json")).expanduser()


def main():
    try:
        st = json.loads(STATE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        st = {}
    now = time.time()

    print(f"Attempts today: {st.get('attempts_today', 0)}")
    print(f"Total attempts: {st.get('attempts_total', 0)}")

    iv = st.get("intervention")
    if iv:
        rem = max(0, int(iv.get("end_at", now) - now))
        print(f"Intervention: ACTIVE — attempt #{iv.get('attempt')} "
              f"({iv.get('target')}), {rem // 60:02d}:{rem % 60:02d} remaining")
    else:
        print("Intervention: none")

    g = st.get("grant")
    if g and now < g.get("expires_at", 0):
        rem = int(g["expires_at"] - now)
        print(f"Work access: {g.get('target')} — "
              f"{rem // 60:02d}:{rem % 60:02d} remaining")
    else:
        print("Work access: none")

    return 0


if __name__ == "__main__":
    sys.exit(main())
