-- Set the tab width to 4
vim.opt.shiftwidth = 4
-- Enable line numbers by default
vim.opt.number = true
-- Enable syntax highlighting
vim.opt.syntax = "on"
-- Expand tabs to spaces
vim.opt.expandtab = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load Lazy and the plugins
require("config.lazy")

-- Set the default color scheme
vim.cmd [[colorscheme catppuccin-macchiato]] 

-- Configure keyboard maps, now that all plugins are accessible
require("config.keymaps")

require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "lua", "rust", "markdown", "cpp" },
  highlight = { enable = true },
  indent = { enable = true },
}

