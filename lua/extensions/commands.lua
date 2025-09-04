--- :Reveal, :Re
--- Reveal the project directory in a file explorer (Finder on macOS)
vim.api.nvim_create_user_command("Reveal", function()
  vim.ui.open(vim.fn.getcwd())
end, { desc = "Reveal the project directory in a file explorer" })

--- :SyncClipboard, :Sy
--- Sync Vim clipboard to the system clipboard
vim.api.nvim_create_user_command("SyncClipboard", function()
  vim.cmd [[let @+=@"]]
end, { desc = "Transfer Vim default register contents to the system clipboard register" })
