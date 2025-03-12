--- @class TerminalConfig module configuration and state
--- @field _groups TerminalGroup[] active terminal groups
local M = {
  _groups = {}
}

local function on_term_open()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt_local.spell = false
end

--- @class ToggleTermOpts window options
--- @field bufnr integer buffer to show; overrides the default buffer selection algorithm
--- @field group string terminal group; each group has a dedicated Harpoon list and configuration
--- @field strategy string how to open the terminal window (split, floating, etc.)

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

  group:open_terminal({ strategy = opts.strategy })
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("ovf-term-setup", {}),
  callback = on_term_open
})

vim.keymap.set("n", "<leader>tt", function() M:toggle_term() end, {})

vim.api.nvim_create_user_command("Term", function(args)
  print(args.name, vim.inspect(args.args))

  local opts = {}

  for k, v in string.gmatch(args.args, "(%w+)=(%w+)") do
    opts[k] = v
  end

  M:toggle_term(opts)
end, {
  nargs = "*",
  complete = function(lead)
    local arg_names = { "group=", "strategy=" }
    local completion_items = {
      ["strategy="] = require("extensions.terminal.window").available_strategies(),
      ["group="] = {}
    }

    local cat = function(lead, args)
      local res = {}

      for i, arg in ipairs(args) do
        res[i] = lead .. arg
      end

      return res
    end

    for item, completions in pairs(completion_items) do
      if string.find(lead, item) then
        return cat(item, completions)
      end
    end

    return arg_names
  end
})

require("extensions.terminal.group").init({
  default_strategy = "float",
  group_configs = {
  }
})

return M
