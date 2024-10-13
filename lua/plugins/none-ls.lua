return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.completion.spell,
        null_ls.builtins.formatting.clang_format,
      },
      on_attach = function(client, bufnr)
        if not client.supports_method("textDocument/formatting") then
          return
        end

        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            local lsp = require("ovf.lsp")
            lsp.format()
          end,
        })
      end,
    })
  end,
}
