--- @class TerminalConfig module configuration and state
--- @field _win_id integer terminal window identifier
--- @field _last_buf integer last accessed terminal buffer; used when reopening a term window
local M = {
  _win_id = -1,
  _last_buf = -1,
}

--- Create Harpoon list item for a given terminal buffer
local function create_item(bufnr)
  assert(bufnr)

  return {
    value = bufnr,
    context = {
    }
  }
end

local function create_buffer()
  vim.cmd.term()

  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = bufnr,
    callback = function(args)
      local log = require("utils.log")
      local harpoon = require("harpoon")

      log.debug("term: buf delete: ", args.buf)

      harpoon:list("term"):remove(create_item(args.buf))
    end
  })

  return bufnr
end

local function on_term_open()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt_local.spell = false
end

--- @class ToggleTermOpts window options
--- @field bufnr integer buffer to show; overrides the default buffer selection algorithm

--- Toggle a general-purpose terminal window.
--- By default, it shows the last accessed terminal buffer.
---
--- When a terminal is created, it is added to a harpoon "term" list.
--- The list can the be used to navigate the terminal.
---
--- @param opts ToggleTermOpts options (nullable)
function M.toggle_term(opts)
  opts = opts or {}

  if vim.api.nvim_win_is_valid(M._win_id) then
    vim.api.nvim_set_current_win(M._win_id)
  else
    M._win_id = require("extensions.terminal.window").create_window()
  end

  -- Buffer is provided explicitly
  if opts.bufnr and vim.api.nvim_buf_is_valid(opts.bufnr) then
    M._last_buf = opts.bufnr

    vim.api.nvim_win_set_buf(0, opts.bufnr)
  else
    -- Try opening the last accessed terminal first
    if vim.api.nvim_buf_is_valid(M._last_buf) then
      vim.api.nvim_win_set_buf(0, M._last_buf)
    else
      -- If unset, create a new one and remember it
      M._last_buf = create_buffer()

      require("harpoon"):list("term"):add(create_item(M._last_buf))
    end
  end

  vim.cmd [[startinsert!]]
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("ovf-term-setup", {}),
  callback = on_term_open
})

vim.keymap.set("n", "<leader>tt", M.toggle_term, {})

return M
