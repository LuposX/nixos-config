# Sioyek — PDF viewer designed for research papers and technical books
# Keyboard-driven, vim-like, with true keyboard text selection (visual mode)
{
  pkgs,
  config,
  ...
}: {
  programs.sioyek = {
    enable = true;

    # Keybindings  →  ~/.config/sioyek/keys_user.config
    bindings = {
      # Vim-style movement (arrow keys also work by default)
      move_down = "j";
      move_up = "k";
      move_left = "h";
      move_right = "l";

      # Screen up/down (like Ctrl-d / Ctrl-u in vim)
      screen_down = "J";
      screen_up = "K";

      # Visual mode text selection
      keyboard_select = "v";
      copy = "y";

      # Table of contents
      goto_toc = "t";

      # Presentation mode
      toggle_presentation_mode = "F5";

      # Quit
      quit = "q";
    };

    # Preferences  →  ~/.config/sioyek/prefs_user.config
    config = {
      # ── Clipboard ─────────────────────────────────────
      selection_clipboard = "1";     # system clipboard (Ctrl+V), same as zathura

      # ── Behaviour ─────────────────────────────────────
      use_legacy_keybinds = "0";     # modern key parser (single-char binds)
      should_launch_new_window = "1"; # open new files in a new window
      super_fast_search = "1";       # indexed search (~50MB/1k pages RAM)
      scroll_step = "120";
      vertical_move_amount = "1.0";
      horizontal_move_amount = "1.0";
      move_screen_ratio = "0.5";     # screen_down moves half a screen

      # ── Reading aids ──────────────────────────────────
      ruler_mode = "1";              # rectangle around current line
      ruler_padding = "1.0";
      create_table_of_contents_if_not_exists = "1";

      # ── Synctex (LaTeX) ───────────────────────────────
      synctex = "2";                 # double-click to jump from PDF to source
    };
  };
}
