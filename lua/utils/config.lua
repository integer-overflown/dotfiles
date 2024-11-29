local M = {}

local config_future

---@class LoggingHighlight a highlight setting for matching tokens, see vim.fn.matchadd
---@field group_name string a vim highlight group name (see :highlight)
---@field pattern string a pattern to be highlighted, in vim format, see :h search-pattern
---@see vim.fn.matchadd

---@class LoggingConfig
---@field highlights LoggingHighlight[]

---@class GitConfig
---@field task_template string ($task) Task ID pattern, expressed as a Lua pattern.
---@field message_template string Git message template. Can use $variables from GitConfig
---@class UserConfig
---@field logging LoggingConfig
---@field git GitConfig

--Lua language server does not seem to allow linking to nio.control.Future directly
---@class Future nio future, see nio.control.Future
---@field wait fun() wait for the completion, returning the result

-- internal function: always called from the main thread
-- this allows using vimscript functions before entering an async context
function do_load_config()
  local nio = require("nio")
  local cwd = vim.fn.getcwd()

  local config_dir = cwd .. "/nvim"

  nio.run(function()
    local log_conf = config_dir .. "/init.lua"
    local file = nio.file.open(log_conf, "r")

    if not file then
      config_future.set({})
      return
    end

    local content = file.read(nil, 0)
    local mod_func, error = load(content)

    local e = function(message)
      config_future.set_error(message)

      vim.schedule(function()
        vim.notify(message, vim.log.levels.ERROR)
      end)
    end

    if not mod_func then
      e("Failed to load the project-local config: " .. error)
      return
    end

    local mod = mod_func()

    if type(mod) ~= "table" then
      e("Config JSON must be an object")
      return
    end

    config_future.set(mod)
  end)
end

---Asynchronously load a project-local user config.
---The config is a Lua table returned by an entry-point script,
---which must be located at <cwd>/nvim/init.lua.
---Thus, it's assumed that nvim is started from the project workspace root.
---
---The loading and parsing happens once, when the function is first called.
---
---Each subsequent invocation will return a cached future.
---
---This allows accessing the config from any script, as well as starting the
---config loading in advance.
---
---@return Future # a nio future to UserConfig
---@see UserConfig
M.load_config = function()
  if config_future then
    return config_future
  end

  local nio = require("nio")
  config_future = nio.control.future()

  vim.schedule(do_load_config)

  return config_future
end

---Read a config field, potentially nested in sub-config objects.
---The function behaves as follows: for each variadic argument k set config to config[k].
---This repeats until all keys are processed, in which case the final value is returned,
---or breaks early if at any iteration config becomes nil, returning nil from the function.
---
---The function also does type validation based on field_type parameter.
---If the requested field exists, but is of a wrong type, nil is returned.
---
---@param config table a config table, acquired from load_config().wait()
---@param field_type string required field type
---@param ... string a list of keys
M.read_field = function(config, field_type, ...)
  for _, key in ipairs({ ... }) do
    config = config[key]

    -- Explicit comparison against nil is used to ensure that we get nil,
    -- and not a falsy value like a boolean false, which might be a valid
    -- config value
    if config == nil then
      return
    end
  end

  local actual = type(config)

  if actual ~= field_type then
    local pretty_name = table.concat({ ... }, ".")

    -- Async-friendly notification
    vim.schedule(function()
      vim.notify(
        "Field " .. pretty_name .. "has a wrong type: expected " .. field_type .. "got: " .. actual,
        vim.logging.levels.ERROR
      )
    end)

    return
  end

  return config
end

return M
