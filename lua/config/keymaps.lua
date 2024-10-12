local builtin = require('telescope.builtin')

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })

-- Utility keymaps
vim.keymap.set('n', '<leader>fp', function()
  vim.cmd "let @+=@%"
end, { desc = 'Copy current file path to the system clipboard' })

vim.keymap.set('n', '<leader>m', 'o<ESC>', { desc = 'Add a new line under the cursor' })
vim.keymap.set('n', '<leader>M', 'O<ESC>', { desc = 'Add a new line above the cursor' })

vim.keymap.set('n', '<leader>b', ':Neotree toggle show buffers right<cr>', { desc = 'Show currently opened buffers' })
vim.keymap.set('n', '<leader>s', ':Neotree float git_status<cr>', { desc = 'Open git status in a floating window' })
vim.keymap.set('n', '|', ':Neotree reveal<cr>', { desc = 'Open neo-tree file view' })

