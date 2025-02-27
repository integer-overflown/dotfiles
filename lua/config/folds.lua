vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("ovf-fold-setup", {}),
  callback = function()
    vim.opt.foldlevel = 1
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldmethod = "expr"
  end
})
