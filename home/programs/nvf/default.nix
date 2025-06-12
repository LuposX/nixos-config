# Source: https://github.com/JaKooLit/Ja-ZaneyOS/blob/ja-edited/modules/home/nvf.nix
# For otpions see: https://notashelf.github.io/nvf/options
{
  inputs,
  config,
  ...
}: {
  imports = [inputs.nvf.homeManagerModules.default];

  programs.nvf = {
    enable = true;

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      clipboard = {
        enable = true;
        registers = "unnamedplus";
      };

      options = {
        tabstop = 2;
        shiftwidth = 2;
        wrap = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          mappings.open = "<leader>ot";

          lazygit.enable = true;
          lazygit.mappings.open = "<leader>gg";
        };
      };

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      keymaps = [
      ];
    };
  };
}
