# Keybindings

## Hyprland

> [!NOTE]
> SUPER is the windows key by default

### **Keyboard Bindings**

| Description                       | Keybinding       |
| --------------------------------- | ---------------- |
| Launch Kitty                      | Mod + RETURN     |
| Launch Thunar                     | Mod + E          |
| Launch Firefox                    | Mod + B          |
| Launch NNN                        | MOD + N          |
| Launch FZF                        | MOD + D          |
| Lock Screen (Hyprlock)            | Mod + L          |
| Open App Launcher (menu)          | Mod + SPACE      |
| Toggle Hyprtasking                | Mod + tab        |
| Close Active Window               | Mod + Q          |
| Toggle Floating                   | Mod + T          |
| Toggle Fullscreen                 | Mod + F          |
| Move focus left                   | Mod + left       |
| Move focus right                  | Mod + right      |
| Move focus up                     | Mod + up         |
| Move focus down                   | Mod + down       |
| Focus previous monitor            | ShiftMod + up    |
| Focus next monitor                | ShiftMod + down  |
| Add to master                     | ShiftMod + left  |
| Remove from master                | ShiftMod + right |
| Screenshot region                 | Mod + P          |
| Screenshot monitor                | Mod + CTRL + P   |
| Screenshot active window          | ShiftMod + P     |
| Screenshot region + edit (Swappy) | ALT + CTRL + P   |
| Toggle Hyprpanel                  | ShiftMod + T     |
| Clipboard picker (wofi)           | ShiftMod + C     |
| [Emoji](2025-07-05_emoji.md) picker (wofi-emoji)         | ShiftMod + E     |

---

### **Workspace Bindings**

| Description                  | Keybinding        |
| ---------------------------- | ----------------- |
| Switch to workspace 1–9      | Mod + 1–9         |
| Move window to workspace 1–9 | Mod + Shift + 1–9 |

---

### **Mouse Bindings**

| Description   | Keybinding                   |
| ------------- | ---------------------------- |
| Move window   | Mod + Left Click (mouse:272) |
| Resize window | Mod + R                      |

---

### **Hardware Keys (bindl + bindle)**

| Description       | Keybinding            |
| ----------------- | --------------------- |
| Toggle mute       | XF86AudioMute         |
| Play/Pause        | XF86AudioPlay         |
| Next track        | XF86AudioNext         |
| Previous track    | XF86AudioPrev         |
| Lock on lid close | Lid Switch            |
| Volume up         | XF86AudioRaiseVolume  |
| Volume down       | XF86AudioLowerVolume  |
| Brightness up     | XF86MonBrightnessUp   |
| Brightness down   | XF86MonBrightnessDown |

## Shell

### **Custom `fzf.fish` Keybindings**

| Description                                           | Keybinding                           |
| ----------------------------------------------------- | ------------------------------------ |
| Open selected file using `smart_open_fzf`, then abort | Ctrl + O _(within directory search)_ |
| Fuzzy search file contents via `ripgrep_fzf`          | Ctrl + G                             |

### **fzf.fish Default Keybindings**

| Description                                                     | Keybinding     |
| --------------------------------------------------------------- | -------------- |
| Search Directory – fuzzy find files/dirs, insert relative paths | Ctrl + Alt + F |
| Search Git Log – fuzzy find Git commits, insert hashes          | Ctrl + Alt + L |
| Search Git Status – fuzzy find Git changes, insert file paths   | Ctrl + Alt + S |
| Search History – fuzzy find past commands                       | Ctrl + R       |
| Search Processes – fuzzy find running processes, insert PIDs    | Ctrl + Alt + P |
| Search Variables – fuzzy find shell variables in scope          | Ctrl + V       |

### Kitty

| Description                       | Keybinding   |
| --------------------------------- | ------------ |
| Kitty Terminal Increase Font Size | Ctrl + PLUS  |
| Kitty Terminal Decrease Font Size | Ctrl + MINUS |


## NNN - File Manager

| Description                           | Keybinding            |
| ------------------------------------- | --------------------- |
| Go Upwards                            | k / Up-Arrow          |
| Go Downwards                          | j / Down-Arrow        |
| Enter a folder                        | Enter                 |
| Open current entry in EDITOR          | e                     |
| Open current entry in xdg-open        | o                     |
| Go to Parent Directory                | h                     |
| Go to Home Directory                  | ~                     |
| Toggle detail View                    | d                     |
| Toggle help and settings screen       | ?                     |
| Toggle hide .dot files                | .                     |
| Rename a folder                       | r                     |
| Bookmark                              | b + LETTER (c, w, n, u)|
| Search with FZF and enter Directory   | Alt + c               |
| Search with FZF and Open File         | Alt + o               |
| Image Preview in Console              | Alt + p               |



## Neovim

> [!NOTE]
> For easy mode switch, bind `CAPS LOCK` to `ESCAPE`


## Firefox

| Description        | Keybinding |
| ------------------ | ---------- |
| New Tab            | STRG + t   |
| Close Tab          | STRG + w   |
| Switch to next Tab | STRG + TAB |
| Go to Tab *i*      | ALT + *i*  |
