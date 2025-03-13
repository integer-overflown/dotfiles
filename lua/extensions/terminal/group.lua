--- @class GroupEvents
--- @field terminal_opened fun(group: TerminalGroup, buf: integer) fired when a buffer is presented in a window
--- @field buffer_entered fun(buf: integer) fired when a buffer is displayed in a window

--- @class GroupConfig
--- @field strategy string? default strategy to use (split, float, etc.); if nil, follow the global strategy from ModuleConfig
--- @field create_buffer fun(): integer create an empty buffer
--- @field open_terminal fun() open terminal in the current buffer
--- @field events GroupEvents event handlers

--- @class ModuleConfig
--- @field default_strategy string default strategy to use for all groups, unless overridden by a group setting
--- @field group_configs table<string, GroupConfig> custom configuration for terminal groups

--- @class TerminalGroupModule
--- @field config ModuleConfig module config
local M = {
  config = {
    default_strategy = "float",
    group_configs = {}
  }
}

--- @class TerminalGroup
--- @field _name string terminal group name
--- @field _win_id integer terminal window identifier
--- @field _last_buf integer last accessed terminal buffer; used when reopening a term window
--- @field _config GroupConfig group local config
local TerminalGroup = {}

TerminalGroup.__index = TerminalGroup

local HARPOON_CONFIG = {
  encode = false,
  create_list_item = function()
    assert(false, "default create_list_item unexpectedly reached")
  end,
  select = function(list_item)
    local manager = require("extensions.terminal.manager")
    manager:toggle_term({ buffer = list_item.value, group = list_item.context.group_name })
  end,
  equals = function(lhs_item, rhs_item)
    if lhs_item == nil and rhs_item == nil then
      return true
    end

    if lhs_item == nil or rhs_item == nil then
      return false
    end

    return lhs_item.value == rhs_item.value
  end,
  display = function(list_item)
    return vim.api.nvim_buf_get_name(list_item.value)
  end
}

--- @type GroupConfig
local DEFAULT_CONFIG = {
  strategy = nil,
  create_buffer = function()
    return vim.api.nvim_create_buf(false, false)
  end,
  open_terminal = function()
    vim.fn.termopen(vim.o.shell)
  end,
  events = {
    terminal_opened = function(group, buf)
      vim.keymap.set({ "n", "t" }, "<c-n>", function()
        print("next")
        group:_get_harpoon_list():next()
      end, {
        buffer = buf
      })

      vim.keymap.set({ "n", "t" }, "<c-p>", function()
        print("prev")
        group:_get_harpoon_list():prev()
      end, {
        buffer = buf
      })
    end,
    buffer_entered = function()
      vim.cmd [[startinsert!]]
    end
  }
}

local function get_group_config(name)
  return M.config.group_configs[name] or {}
end

local log = require("plenary.log").new({
  plugin = "terminal_group",
  level = "trace",
})

---Create a new terminal group
---@param name string the terminal group name
---@return TerminalGroup group the terminal group object
function TerminalGroup:new(name)
  --- @type GroupConfig
  local config = vim.tbl_deep_extend("keep", get_group_config(name), DEFAULT_CONFIG)

  local harpoon = require("harpoon")
  local partial_config = { [name] = HARPOON_CONFIG }
  harpoon.config = require("harpoon.config").merge_config(partial_config, harpoon.config)

  for _, existing_config in pairs(harpoon.lists) do
    if existing_config[name] ~= nil then
      log.debug("Cleaning", name, "was", vim.inspect(existing_config[name]))
      existing_config[name] = nil
    end
  end

  return setmetatable({
    _name = name,
    _win_id = -1,
    _last_buf = -1,
    _config = config
  }, self)
end

function TerminalGroup:_new_from_data(data)
  return setmetatable(data, self)
end

function TerminalGroup:_get_harpoon_list()
  return require("harpoon"):list(self._name)
end

function TerminalGroup:_create_harpoon_item(buf)
  return {
    value = buf,
    context = {
      group_name = self._name
    }
  }
end

--- Add a terminal buffer to the group
---
--- The buffer will automatically be removed when deleted.
---
--- @param buf integer the terminal buffer
function TerminalGroup:_add_terminal(buf)
  local item = self:_create_harpoon_item(buf)

  log.trace("Adding buffer", buf, "to group", self._name)

  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = buf,
    callback = function(args)
      log.debug("term: buf delete:", args.buf)

      self:_remove_terminal(buf)
    end
  })

  self:_get_harpoon_list():prepend(item)
end

--- Remove a terminal buffer from the group
--- @param buf integer terminal buffer
function TerminalGroup:_remove_terminal(buf)
  local item = self:_create_harpoon_item(buf)

  self:_get_harpoon_list():remove(item)
end

--- @class ToggleTerminalOpts
--- @field strategy string? strategy to use; if nil, the module-config default will be used
--- @field new boolean? create a new terminal in this group and open it; if false or absent the first terminal will be accessed
--- @field buffer integer? buffer ID

--- Open the last accessed terminal from this group
---
--- If no terminal is in the group, a new one will be created, regardless of the opts.new setting.
---
--- @param opts ToggleTerminalOpts? options
function TerminalGroup:toggle_terminal(opts)
  opts = opts or {}

  local strategy = opts.strategy or self._config.strategy or M.config.default_strategy

  if not vim.api.nvim_win_is_valid(self._win_id) then
    self._win_id = require("extensions.terminal.window").create_window({ strategy = strategy })
  end

  local win = self._win_id
  local buf

  if opts.buffer and vim.api.nvim_buf_is_valid(opts.buffer) then
    buf = opts.buffer
  else
    local item = self:_get_harpoon_list():get(1)
    buf = item and item.value
  end

  local create_new = buf == nil or opts.new == true

  if create_new then
    buf = self._config.create_buffer()

    vim.api.nvim_create_autocmd("BufWinEnter", {
      buffer = buf,
      callback = function(args)
        log.trace("buffer entered: buf", args.buf, "group", self._name)
        self._config.events.buffer_entered(args.buf)
      end
    })

    vim.api.nvim_create_autocmd("TermOpen", {
      buffer = buf,
      callback = function(args)
        log.trace("terminal opened: buf", args.buf, "group", self._name)
        self._config.events.terminal_opened(self, args.buf)
      end
    })

    self:_add_terminal(buf)
  end

  vim.api.nvim_win_set_buf(win, buf)

  if create_new then
    self._config.open_terminal()
  end
end

function TerminalGroup:toggle_list()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list(self._name))
end

--- Initialize the module.
--- In order to take effect, this function
--- should be called **before** accessing any of the module API.
---
--- If not called, the default values will be used.
---
--- The config that this function accepts can be used to configure
--- the behavior of custom terminal categories.
---
--- @param config ModuleConfig module config table
function M.init(config)
  M.config = config
end

M.TerminalGroup = TerminalGroup

return M
