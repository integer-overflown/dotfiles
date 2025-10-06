local M = {}

local function create_split()
  vim.cmd [[split]]
  vim.cmd [[wincmd J]]
  vim.api.nvim_win_set_height(0, 10)

  return vim.api.nvim_get_current_win()
end

local function create_float()
  local function create_config()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded"
    }
  end

  local function update_window(win)
    if not vim.api.nvim_win_is_valid(win) then
      return
    end

    vim.api.nvim_win_set_config(win, create_config())
  end

  local win = vim.api.nvim_open_win(0, true, create_config())

  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("ovf-float-term-resize", { clear = true }),
    callback = function()
      update_window(win)
    end
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    callback = function()
      vim.api.nvim_del_augroup_by_name("ovf-float-term-resize")
    end
  })

  return win
end

local strategies = {
  split = create_split,
  float = create_float
}

---@alias CreateWindowStrategy
--- | "split" # horizonal split, a small window at the bottom of the editor
--- | "float" # a floating window, centered at the editor boundaries

---@class CreateWindowOpts
---@field strategy CreateWindowStrategy window appearance style

---Create a terminal window
---
---A strategy can be used to specify the window appearance, such
---as a horizontal or vertical split, float, tab, etc.
---
---Regardless of the strategy, a new window will be made current.
---
---@param opts CreateWindowOpts? options
---@return integer window_id new window id
function M.create_window(opts)
  opts = opts or {}

  local strategy = opts.strategy and strategies[opts.strategy] or strategies.split

  return strategy()
end

function M.available_strategies()
  local names = {}

  for key, _ in pairs(strategies) do
    table.insert(names, key)
  end

  return names
end

return M
