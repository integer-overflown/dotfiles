--- @class HarpoonMethods
--- @field create_list_item fun(buf: integer): { value: integer, context: table } create_item function

--- @class GroupEvents
--- @field buf_opened fun() fired when a buffer is presented in a window

--- @class GroupConfig
--- @field create_buf fun(): integer create a terminal buffer
--- @field strategy string? default strategy to use (split, float, etc.); if nil, follow the global strategy from ModuleConfig
--- @field harpoon HarpoonMethods harpoon2 configuration
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

--- @type GroupConfig
local DEFAULT_CONFIG = {
  strategy = nil,
  create_buf = function()
    vim.cmd.term()
    return vim.api.nvim_get_current_buf()
  end,
  harpoon = {
    encode = false,
    create_list_item = function(bufnr)
      return {
        value = bufnr,
        context = {
        }
      }
    end,
    select = function(list_item)
      print("TODO")
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
  },
  events = {
    buf_opened = function()
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
  local partial_config = { [name] = config.harpoon }
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

--- Add a terminal buffer to the group
---
--- The buffer will automatically be removed when deleted.
---
--- @param buf integer the terminal buffer
function TerminalGroup:add_terminal(buf)
  local item = self._config.harpoon.create_list_item(buf)

  log.trace("Adding buffer", buf, "to group", self._name)

  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = buf,
    callback = function(args)
      log.debug("term: buf delete:", args.buf)

      self:remove_terminal(buf)
    end
  })

  self:_get_harpoon_list():add(item)
end

--- Remove a terminal buffer from the group
--- @param buf integer terminal buffer
function TerminalGroup:remove_terminal(buf)
  local item = self._config.harpoon.create_list_item(buf)

  self:_get_harpoon_list():remove(item)
end

--- @class OpenTerminalOpts
--- @field strategy string? strategy to use; if nil, the module-config default will be used

--- Open the last accessed terminal from this group
--- @param opts OpenTerminalOpts? options
function TerminalGroup:open_terminal(opts)
  opts = opts or {}

  local strategy = opts.strategy or self._config.strategy or M.config.default_strategy

  if not vim.api.nvim_win_is_valid(self._win_id) then
    self._win_id = require("extensions.terminal.window").create_window({ strategy = strategy })
  end

  local win = self._win_id
  local item = self:_get_harpoon_list():get(1)
  local buf = item and item.value

  if buf == nil then
    buf = self._config.create_buf()
    self:add_terminal(buf)
  end

  vim.api.nvim_win_set_buf(win, buf)

  self._config.events.buf_opened()
end

function TerminalGroup:open_list()
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
