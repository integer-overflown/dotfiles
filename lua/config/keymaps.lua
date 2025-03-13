local builtin = require("telescope.builtin")

-- Utils
vim.keymap.set("n", "<leader><leader>x", function()
  local path = vim.api.nvim_buf_get_name(0)

  if path == "" then
    vim.cmd [[source]]
  else
    vim.cmd [[source %]]
  end
end, { desc = "Source the current file" })

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Show and search help" })

vim.keymap.set("n", "<F1>", ":help <C-r><C-w><cr>", { desc = "Show help for a word under the cursor" })

-- Neo-tree keymaps
vim.keymap.set(
  "n",
  "<leader>bf",
  ":Neotree toggle show buffers right<cr>",
  { desc = "Show currently opened buffers", silent = true }
)
vim.keymap.set(
  "n",
  "<leader>bbf",
  ":Neotree reveal show buffers right focus<cr>",
  { desc = "Show currently opened buffers", silent = true }
)
vim.keymap.set(
  "n",
  "<leader>ss",
  ":Neotree float git_status<cr>",
  { desc = "Open git status in a floating window", silent = true }
)
vim.keymap.set("n", "|", ":Neotree toggle<cr>", { desc = "Toggle neo-tree file view", silent = true })
vim.keymap.set("n", "g|", ":Neotree reveal<cr>", { desc = "Focus on neo-tree file view", silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>dq", function()
  vim.diagnostic.setqflist()
end, { desc = "Open project-wide diagnostic in a quick-fix list" })

vim.keymap.set("n", "<leader>or", ":OverseerRun<cr>", { desc = "Select and run an Overseer task" })
vim.keymap.set("n", "<leader>ot", ":OverseerToggle<cr>", { desc = "Toggle Overseer task view" })

local function set_terminal_keymaps()
  local opts = { buffer = 0 }
  local desc = require("utils").desc

  vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], desc(opts, "Exit terminal mode"))
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], desc(opts, "Enter a command mode"))
  vim.keymap.set("t", "<C-v>", function()
    vim.api.nvim_paste(vim.fn.getreg('"'), false, -1) -- paste from the default " register
  end, desc(opts, "Enter a command mode"))
end

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = set_terminal_keymaps,
})
