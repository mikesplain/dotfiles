{ pkgs, ... }:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    p: with p; [
      bash
      go
      gomod
      gowork
      gosum
      python
      ruby
      yaml
      json
      hcl
      terraform
      lua
      markdown
      markdown_inline
    ]
  );
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;

    extraLuaConfig = builtins.readFile ./nvim/init.lua;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-web-devicons
      gitsigns-nvim
      lualine-nvim
      which-key-nvim
      nvim-surround
      vim-abolish
      vim-unimpaired
      vim-repeat
      comment-nvim
      oil-nvim
      nvim-autopairs
      catppuccin-nvim
      nvim-lspconfig
      conform-nvim
      nvim-lint
      blink-cmp
      friendly-snippets
      trouble-nvim
      nvim-navic
      nui-nvim
      nvim-navbuddy
      dropbar-nvim
      treesitter
    ];

    extraPackages = with pkgs; [
      gopls
      go
      pyright
      bash-language-server
      yaml-language-server
      vscode-langservers-extracted
      terraform-ls
      terraform
      hclfmt
      jq
      yamlfmt
      shfmt
      shellcheck
      ruff
      solargraph
      ruby
    ];
  };
}
