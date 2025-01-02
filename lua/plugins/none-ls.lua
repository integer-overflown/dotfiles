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

        local format = function()
          vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
        end

        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = format,
        })

        vim.keymap.set("n", "<leader>ll", function()
          format()
        end, { buffer = bufnr })
      end,
    })
  end,
}
