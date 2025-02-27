local fold_level_by_pattern = {
  -- include guards create a fold
  -- since headers always contain them, having a larger
  -- fold level helps see the contents
  [".h$"] = 2,
}

local fold_level_fallback = 1

local function get_buffer_fold_level(buffer)
  local bufname = vim.api.nvim_buf_get_name(buffer)

  if not bufname then
    return
  end

  for pt, level in pairs(fold_level_by_pattern) do
    if string.match(bufname, pt) then
      return level
    end
  end

  return fold_level_fallback
end

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("ovf-fold-setup", {}),
  callback = function(event)
    vim.opt.foldlevel = get_buffer_fold_level(event.buf)
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldmethod = "expr"
  end
})
