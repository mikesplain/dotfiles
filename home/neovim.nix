# Based on https://github.com/zmre/pwnvim but more lightweight
{ pkgs, ... }:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    p: with p; [
      bash
      go
      gomod
      gowork
      gosum
      nix
      python
      ruby
      yaml
      json
      javascript
      typescript
      tsx
      css
      html
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
      snacks-nvim
      nvim-autopairs
      catppuccin-nvim
      nvim-lspconfig
      conform-nvim
      nvim-lint
      blink-cmp
      friendly-snippets
      nvim-notify
      noice-nvim
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
      nixd
      alejandra
      statix
      pyright
      bash-language-server
      yaml-language-server
      vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier
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
