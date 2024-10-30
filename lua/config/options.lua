-- Set the tab width to 4
vim.opt.shiftwidth = 4
-- Enable line numbers by default
vim.opt.number = true
-- Enable syntax highlighting
vim.opt.syntax = "on"
-- Expand tabs to spaces
vim.opt.expandtab = true
-- Enable relative numbers by default
vim.opt.relativenumber = true
-- Automatically read from disk when file is changed
-- externally (by VCS, for example)
vim.opt.autoread = true
-- Write the file when switching buffers or quitting vim
vim.opt.autowriteall = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("setlocal spell spelllang=en_us")
