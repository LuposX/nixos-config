# Mirror Mirror (Noctalia v5)

Mirror one monitor to another using `wl-mirror` on Niri (and other wlroots-based
compositors). Port of Mathew-D's Noctalia v4 QML plugin (as distributed in
PaloMiku/noctalia-plugins) to the v5 Luau plugin API. MIT, original plugin by
Mathew-D.

## Features

- Bar icon (red tint while mirroring) opens the panel.
- Source and destination monitors picked from detected outputs
  (`noctalia.outputs()` replaces Quickshell's screen detection).
- Runs `wl-mirror --fullscreen-output <destination> <source>`.
- Stop mirror from the same panel. With fewer than 2 monitors the controls
  are disabled.

## Dependencies

- `wl-mirror`

## Usage

Add the bar widget (`monkeman/mirror-mirror:toggle`) or bind
`noctalia msg panel-toggle monkeman/mirror-mirror:mirror`. Pick source and
destination, then Start mirror.
