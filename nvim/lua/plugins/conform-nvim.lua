local function format_buffer(bufnr)
  bufnr = bufnr or 0

  require("conform").format({ bufnr = bufnr, lsp_format = "fallback" })
end

local function setup_conform()
  local conform = require("conform")

  conform.setup({
    formatters_by_ft = {
      yaml = { "yamlfmt" },
      xml = { "xmlformatter" },
    }
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
      format_buffer(args.buf)
    end,
  })

  vim.keymap.set("n", "<leader>F", function()
    format_buffer()
  end, {})
end

return {
  "stevearc/conform.nvim",
  config = setup_conform,
}
