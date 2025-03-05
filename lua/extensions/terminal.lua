--- @class TerminalConfig module configuration and state
--- @field _win_id integer terminal window identifier
local M = {
  _win_id = -1
}

local function create_window()
  vim.cmd [[split]]
  vim.cmd [[wincmd J]]
  vim.api.nvim_win_set_height(0, 10)

  return vim.api.nvim_get_current_win()
end

local function on_term_open()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt_local.spell = false
end

function M.toggle_term(bufnr)
  bufnr = bufnr or -1

  if vim.api.nvim_win_is_valid(M._win_id) then
    vim.api.nvim_set_current_win(M._win_id)
  else
    M._win_id = create_window()
  end

  if bufnr < 0 then
    vim.cmd.term()

    require("harpoon"):list("term"):add()
  else
    vim.api.nvim_win_set_buf(0, bufnr)
  end

  vim.cmd [[startinsert!]]
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("ovf-term-setup", {}),
  callback = on_term_open
})

vim.keymap.set("n", "<leader>tt", M.toggle_term, {})

return M
