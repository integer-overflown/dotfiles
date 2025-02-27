--- Reveal the project directory in a file explorer (Finder on macOS)

vim.api.nvim_create_user_command("Reveal", function()
  vim.ui.open(vim.fn.getcwd())
end, { desc = "Reveal the propath-pickerject directory in a file explorer" })
