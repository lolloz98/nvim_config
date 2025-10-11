vim.cmd("set number relativenumber")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      'nvim-telescope/telescope.nvim', -- fuzzy finder support
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
      "nvim-treesitter/nvim-treesitter" -- linting support
    },
    {
      "tpope/vim-fugitive"       -- git support
    },
    { "neovim/nvim-lspconfig" }, -- core LSP support

    -- Autocompletion start
    { "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    -- Autocompletion end

    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    { "ellisonleao/gruvbox.nvim", priority = 1000,  config = true },
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
  },
})



-- Default keymaps on LSP attach
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
  end

  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "K", vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
end

local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      -- Using LuaSnip or any snippet engine if installed
      -- require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),         -- next suggestion
    ["<C-p>"] = cmp.mapping.select_prev_item(),         -- prev suggestion
    ["<tab>"] = cmp.mapping.confirm({ select = true }), -- enter to confirm
    ["<CR>"] = cmp.mapping.complete(),                  -- trigger completion
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP completions
    { name = "buffer" },   -- current buffer
    { name = "path" },     -- file paths
    { name = "cmdline" },  -- command line completion
  }),
})

-- Enable completion for command-line mode too (optional)
cmp.setup.cmdline("/", {
  sources = { { name = "buffer" } }
})
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('clangd', { -- c++
  on_attach = on_attach,
  autostart = true,
  capabilities = capabilities,
})

vim.lsp.config('rust_analyzer', {
  on_attach = on_attach,
  cmd = { "/opt/homebrew/bin/rust-analyzer" }, -- if needed
  autostart = true,
  capabilities = capabilities,
})

vim.lsp.config('jdtls', { -- java
  on_attach = on_attach,
  autostart = true,
  capabilities = capabilities,
})

local lua_runtime = vim.api.nvim_get_runtime_file("*.lua", true)
vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  autostart = true,
  capabilities = capabilities,
  -- settings for enabling vim variable
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = lua_runtime,
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("jdtls")
vim.lsp.enable("lua_ls")

-- Telescope
local builtinTelescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtinTelescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtinTelescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtinTelescope.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtinTelescope.help_tags, { desc = 'Telescope help tags' })
