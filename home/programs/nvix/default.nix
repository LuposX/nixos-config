{ pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    # --- basic editor options ---
    opts = {
      wrap = lib.mkForce true;
      linebreak = lib.mkForce true;
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
    };

    # --- Nvix modules ---
    imports = [
      inputs.nvix.nvixPlugins.common
      inputs.nvix.nvixPlugins.lsp
      inputs.nvix.nvixPlugins.lang
      inputs.nvix.nvixPlugins.snacks
      inputs.nvix.nvixPlugins.lualine
    ];
  };
}