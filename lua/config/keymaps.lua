local builtin = require("telescope.builtin")

-- Utils
vim.keymap.set("n", "<leader><leader>x", ":source %<cr>", { desc = "Source the current file" })

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
