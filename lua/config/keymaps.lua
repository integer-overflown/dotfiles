local builtin = require('telescope.builtin')

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })

-- Utility keymaps
vim.keymap.set('n', '<leader>fp', function()
  vim.cmd "let @+=@%"
end, { desc = 'Copy current file path to the system clipboard' })

