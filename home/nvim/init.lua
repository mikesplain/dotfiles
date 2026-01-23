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
    { "<leader>q", group = "trouble" },
    { "<leader>f", group = "find" },
    { "<leader>b", group = "buffer" },
    { "<leader>t", group = "terminal" },
    { "<leader>z", group = "zen" },
  })
end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
  gitsigns.setup({
    signcolumn = true,
  })
end

local ok_diffview, diffview = pcall(require, "diffview")
if ok_diffview then
  diffview.setup({})
end

vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Diffview close" })

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

local ok_snacks, snacks = pcall(require, "snacks")
if ok_snacks then
  snacks.setup({
    bufdelete = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    picker = { enabled = true },
    terminal = { enabled = true },
    zen = { enabled = true },
  })
  vim.keymap.set("n", "<leader>ff", function()
    snacks.picker.files()
  end, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fe", function()
    snacks.explorer()
  end, { desc = "File explorer" })
  vim.keymap.set("n", "<leader>fg", function()
    snacks.picker.grep()
  end, { desc = "Grep" })
  vim.keymap.set("n", "<leader>fb", function()
    snacks.picker.buffers()
  end, { desc = "Buffers" })
  vim.keymap.set("n", "<leader>/", function()
    snacks.picker.grep()
  end, { desc = "Grep" })
  vim.keymap.set("n", "<leader>bd", function()
    snacks.bufdelete()
  end, { desc = "Delete buffer" })
  vim.keymap.set("n", "<leader>tt", function()
    snacks.terminal()
  end, { desc = "Toggle terminal" })
  vim.keymap.set("n", "<leader>zz", function()
    snacks.zen()
  end, { desc = "Zen mode" })
end

local ok_colorizer, colorizer = pcall(require, "colorizer")
if ok_colorizer then
  colorizer.setup({})
end

local ok_marks, marks = pcall(require, "marks")
if ok_marks then
  marks.setup({
    default_mappings = false,
    builtin_marks = { "<", ">", "^", ";", "'" },
    cyclic = true,
    force_write_shada = false,
    refresh_interval = 250,
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
  })
end

local ok_flash, flash = pcall(require, "flash")
if ok_flash then
  flash.setup({})
end

local ok_notify, notify = pcall(require, "notify")
if ok_notify then
  notify.setup({
    stages = "static",
    timeout = 5000,
  })
  vim.notify = notify
end

local ok_noice, noice = pcall(require, "noice")
if ok_noice then
  noice.setup({
    lsp = {
      override = {
        ["vim.lsp.util.stylize_markdown"] = false,
      },
      progress = {
        enabled = true,
        view = "mini",
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30,
      },
      hover = {
        enabled = true,
        silent = false,
      },
      signature = {
        enabled = true,
        auto_open = { enabled = true, trigger = true, throttle = 50 },
      },
      message = {
        enabled = true,
        view = "notify",
      },
    },
    presets = {
      bottom_search = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    cmdline = { enabled = true, view = "cmdline" },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },
    popupmenu = { enabled = true, backend = "nui" },
    notify = { enabled = true, view = "notify" },
  })
end

local ok_trouble, trouble = pcall(require, "trouble")
if ok_trouble then
  trouble.setup({})
  vim.keymap.set("n", "<leader>qd", function()
    trouble.toggle("diagnostics")
  end, { desc = "Diagnostics (Trouble)" })
  vim.keymap.set("n", "<leader>qf", function()
    trouble.toggle("qflist")
  end, { desc = "Quickfix (Trouble)" })
  vim.keymap.set("n", "<leader>ql", function()
    trouble.toggle("loclist")
  end, { desc = "Loclist (Trouble)" })
end

local ok_navbuddy, navbuddy = pcall(require, "nvim-navbuddy")
if ok_navbuddy then
  navbuddy.setup({})
end

local ok_dropbar, dropbar = pcall(require, "dropbar")
if ok_dropbar then
  dropbar.setup({})
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

local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  blink.setup({
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = false },
    },
    fuzzy = { implementation = "lua" },
  })
end

local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    format_on_save = {
      timeout_ms = 800,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      go = { "gofmt" },
      python = { "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      terraform = { "terraform_fmt" },
      hcl = { "hcl" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "yamlfmt" },
      nix = { "alejandra" },
    },
  })
end

local ok_lint, lint = pcall(require, "lint")
if ok_lint then
  lint.linters_by_ft = {
    python = { "ruff" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    zsh = { "shellcheck" },
    nix = { "statix" },
  }

  local lint_group = vim.api.nvim_create_augroup("msplain_lint", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = lint_group,
    callback = function()
      lint.try_lint()
    end,
  })
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
    if ok_conform then
      conform.format({ timeout_ms = 800, lsp_fallback = true })
    else
      vim.lsp.buf.format({ async = true })
    end
  end, "Format buffer")
  map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

  if client.server_capabilities.documentSymbolProvider then
    local ok_navic, navic = pcall(require, "nvim-navic")
    if ok_navic then
      navic.attach(client, bufnr)
    end
    local ok_navbuddy, navbuddy = pcall(require, "nvim-navbuddy")
    if ok_navbuddy then
      navbuddy.attach(client, bufnr)
      map("n", "<leader>ls", navbuddy.open, "Symbols")
    end
  end
end

local function with_blink_capabilities(config)
  local ok_blink_caps, blink_caps = pcall(require, "blink.cmp")
  if not ok_blink_caps then
    return config
  end

  config = config or {}
  config.capabilities = blink_caps.get_lsp_capabilities(config.capabilities)
  return config
end

local function enable_lsp(name, config)
  config = with_blink_capabilities(config)
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
enable_lsp("nixd", { on_attach = on_attach })
enable_lsp("yamlls", {
  on_attach = on_attach,
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
enable_lsp("jsonls", { on_attach = on_attach })
enable_lsp("ts_ls", { on_attach = on_attach })
enable_lsp("html", { on_attach = on_attach })
enable_lsp("cssls", { on_attach = on_attach })
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
