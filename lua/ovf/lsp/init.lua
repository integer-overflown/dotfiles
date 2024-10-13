local function format()
  vim.lsp.buf.format({
    formatting_options = {
      tabSize = vim.opt_local.shiftwidth:get(),
      insertSpaces = vim.opt.expandtab:get(),
      trimTrailingWhitespace = true,
      insertFinalNewline = true,
      trimFinalNewlines = true,
    },
    async = false,
  })
end

Lsp = {
  format = format,
}

return Lsp
