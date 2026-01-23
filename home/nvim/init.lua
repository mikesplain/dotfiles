-- Minimal Neovim config derived from pwnvim, trimmed for core languages.

vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.completeopt = "menu,menuone,noinsert,noselect"
vim.opt.grepprg = "rg --vimgrep --no-heading --hidden --smart-case --color never"
vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m,%f"
vim.opt.swapfile = true
vim.opt.directory = "/tmp/nvim-swap//"

vim.cmd("filetype plugin indent on")

local ok_catppuccin, catppuccin = pcall(require, "catppuccin")
if ok_catppuccin then
  catppuccin.setup({
    flavour = "macchiato",
    transparent_background = true,
  })
  vim.cmd("colorscheme catppuccin")
end

local ok_which_key, which_key = pcall(require, "which-key")
if ok_which_key then
  which_key.setup({})
  which_key.add({
    { "<leader>l", group = "lsp" },
    { "<leader>g", group = "git" },
  })
end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
  gitsigns.setup({
    signcolumn = true,
  })
end

local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({
    options = {
      theme = "catppuccin",
      section_separators = "",
      component_separators = "",
    },
  })
end

local ok_oil, oil = pcall(require, "oil")
if ok_oil then
  oil.setup({
    default_file_explorer = true,
  })
  vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
end

local ok_surround, surround = pcall(require, "nvim-surround")
if ok_surround then
  surround.setup({})
end

local ok_comment, comment = pcall(require, "Comment")
if ok_comment then
  comment.setup({})
end

local ok_autopairs, autopairs = pcall(require, "nvim-autopairs")
if ok_autopairs then
  autopairs.setup({})
end

local ok_treesitter, treesitter = pcall(require, "nvim-treesitter.configs")
if ok_treesitter then
  treesitter.setup({
    highlight = { enable = true },
    indent = { enable = true },
  })
end

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  severity_sort = true,
})

local function on_attach(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gD", vim.lsp.buf.type_definition, "Go to type definition")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format buffer")
  map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

local function enable_lsp(name, config)
  if vim.lsp and vim.lsp.config and vim.lsp.enable then
    if config then
      vim.lsp.config(name, config)
    end
    vim.lsp.enable(name)
    return
  end

  local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
  if ok_lspconfig and lspconfig[name] then
    lspconfig[name].setup(config or {})
  end
end

enable_lsp("gopls", { on_attach = on_attach })
enable_lsp("pyright", { on_attach = on_attach })
enable_lsp("bashls", { on_attach = on_attach })
enable_lsp("solargraph", { on_attach = on_attach })
enable_lsp("yamlls", {
  on_attach = on_attach,
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
enable_lsp("jsonls", { on_attach = on_attach })
enable_lsp("terraformls", { on_attach = on_attach })

local group = vim.api.nvim_create_augroup("msplain_filetypes", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  group = group,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  group = group,
})
