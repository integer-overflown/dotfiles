local function save_group_data(data)
  vim.g.ext_term_group_data = data
end

local function restore_group_data()
  if not vim.g.ext_term_group_data then
    return {}
  end

  local ret = {}

  for name, group in pairs(vim.g.ext_term_group_data) do
    local TerminalGroup = require("extensions.terminal.group").TerminalGroup
    ret[name] = TerminalGroup:_new_from_data(group)
  end

  return ret
end

--- @class TerminalConfig module configuration and state
--- @field _groups TerminalGroup[] active terminal groups
local M = {
  _groups = restore_group_data()
}

local log = require("plenary.log").new({
  plugin = "terminal_group",
  level = "debug",
})

log.debug("Initialized with groups:", vim.inspect(M._groups))

local function on_term_open()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt_local.spell = false
end

--- @class ToggleTermOpts window options
--- @field bufnr integer buffer to show; overrides the default buffer selection algorithm
--- @field group string terminal group; each group has a dedicated Harpoon list and configuration
--- @field strategy string? how to open the terminal window (split, floating, etc.)
--- @field new boolean? create a new terminal, instead of opening the existing one

--- Toggle a general-purpose terminal window.
--- By default, it shows the last accessed terminal buffer.
---
--- When a terminal is created, it is added to a harpoon "term" list.
--- The list can the be used to navigate the terminal.
---
--- @param opts ToggleTermOpts? options
function M:toggle_term(opts)
  opts = opts or {}

  local group_name = opts.group or "term"
  local TerminalGroup = require("extensions.terminal.group").TerminalGroup

  if self._groups[group_name] == nil then
    self._groups[group_name] = TerminalGroup:new(group_name)
  end

  local group = self._groups[group_name]

  group:toggle_terminal({ strategy = opts.strategy, new = opts.new })
end

function M:toggle_group(name)
  local group = self._groups[name]

  if group == nil then
    vim.notify("No such group: " .. name, vim.log.levels.ERROR)
    return
  end

  group:toggle_list()
end

function M:active_groups()
  return vim.tbl_keys(self._groups)
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("ovf-term-setup", {}),
  callback = on_term_open
})

local script = debug.getinfo(1, "S")
log.trace("script", vim.inspect(script))

local script_path = script.short_src
local utils = require("utils")

if utils.is_valid_path(script_path) then
  log.debug("Setting up a SourcePre handler")

  vim.api.nvim_create_autocmd("SourcePre", {
    pattern = script_path,
    group = vim.api.nvim_create_augroup("ovf-term-source", {}),
    callback = function()
      log.debug("We're about to be sourced")
      log.debug("Saving group data", vim.inspect(M._groups))
      save_group_data(M._groups)
    end
  })
end

require("extensions.terminal.group").init({
  default_strategy = "float",
  group_configs = {
  }
})

return M
