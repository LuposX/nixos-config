# Zathura is a PDF viewer with Vim-like keybindings
# Configured for LaTeX synctex (forward/inverse search with Neovim)
{
  programs.zathura = {
    enable = true;

    options = {
      # General UI
      guioptions = "v";
      adjust-open = "width";
      statusbar-basename = true;
      render-loading = false;
      scroll-step = 120;
      selection-clipboard = "clipboard";

      # Synctex for LaTeX inverse search (click in PDF → jump to source in Neovim)
      # Forward search (Neovim → Zathura) is handled by VimTeX
      synctex = "true";
      "synctex-editor-command" = "nvim --headless -c \"VimtexInverseSearch %{line} %{input}\"";
    };
  };
}
