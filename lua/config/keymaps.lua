local builtin = require("telescope.builtin")

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Show and search help" })

vim.keymap.set("n", "<F1>", ":help <C-r><C-w><cr>", { desc = "Show help for a word under the cursor" })

-- Neo-tree keymaps
vim.keymap.set("n", "<leader>bf", ":Neotree toggle show buffers right<cr>", { desc = "Show currently opened buffers" })
vim.keymap.set("n", "<leader>s", ":Neotree float git_status<cr>", { desc = "Open git status in a floating window" })
vim.keymap.set("n", "|", ":Neotree toggle<cr>", { desc = "Toggle neo-tree file view" })
vim.keymap.set("n", "g|", ":Neotree reveal<cr>", { desc = "Focus on neo-tree file view" })

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client.supports_method("textDocument/rename") then
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end

    if client.supports_method("textDocument/implementation") then
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    end

    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", function()
      builtin.lsp_references()
    end, opts)
    vim.keymap.set({ "n", "i" }, "<c-p>", vim.lsp.buf.signature_help, opts)
  end,
})

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

local function resize_horizonally(expand)
  local wins = vim.api.nvim_tabpage_list_wins(0)

  table.sort(wins, function(lhs, rhs)
    local lhs_pos = vim.api.nvim_win_get_position(lhs)
    local rhs_pos = vim.api.nvim_win_get_position(rhs)

    return lhs_pos[2] < rhs_pos[2]
  end)

  local cur_win = vim.api.nvim_get_current_win()
  local invert = cur_win == wins[#wins]

  if invert then
    if expand then
      vim.cmd("vertical resize -5")
    else
      vim.cmd("vertical resize +5")
    end
  else
    if expand then
      vim.cmd("vertical resize +5")
    else
      vim.cmd("vertical resize -5")
    end
  end
end

local function resize_vertically(expand)
  local wins = vim.api.nvim_tabpage_list_wins(0)

  table.sort(wins, function(lhs, rhs)
    local lhs_pos = vim.api.nvim_win_get_position(lhs)
    local rhs_pos = vim.api.nvim_win_get_position(rhs)

    return lhs_pos[1] < rhs_pos[1]
  end)

  local cur_win = vim.api.nvim_get_current_win()
  local invert = cur_win == wins[1]

  if invert then
    if expand then
      vim.cmd("resize -5")
    else
      vim.cmd("resize +5")
    end
  else
    if expand then
      vim.cmd("resize +5")
    else
      vim.cmd("resize -5")
    end
  end
end

-- Window keymaps
vim.keymap.set("n", "<C-l>", function()
  -- Bob Martin wouldn't like this (sorry)
  resize_horizonally(true)
end, { desc = "Shrink a window horizontally" })

vim.keymap.set("n", "<C-h>", function()
  resize_horizonally(false)
end, { desc = "Expand a window horizontally" })

vim.keymap.set("n", "<C-k>", function()
  resize_vertically(true)
end, { desc = "Shrink a window vertically" })

vim.keymap.set("n", "<C-j>", function()
  resize_vertically(false)
end, { desc = "Expand a window vertically" })
