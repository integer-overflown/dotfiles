local function on_lsp_attach(event)
  local opts = { buffer = event.buf }
  local client = vim.lsp.get_client_by_id(event.data.client_id)

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
    require "telescope.builtin".lsp_references()
  end, opts)

  vim.keymap.set({ "n", "i" }, "<c-p>", vim.lsp.buf.signature_help, opts)
end

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = on_lsp_attach
})
