local bufname = vim.api.nvim_buf_get_name(0)

if not string.match(bufname, "invoke") then
  return
end

vim.api.nvim_create_autocmd("BufEnter", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function()
    vim.cmd [[syntax match YamlPasswordKey /^ *password: */ nextgroup=YamlPasswordValue]]
    vim.cmd [[syntax region YamlPasswordValue start=+'+ end=+'+ conceal cchar=* contained]]
    vim.cmd [[set conceallevel=2]]
    vim.cmd [[set concealcursor=n]]
    vim.cmd [[set nospell]]
  end
})
