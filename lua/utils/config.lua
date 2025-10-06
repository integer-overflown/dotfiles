local M = {
}

local Project = {
}

M.Project = Project

---@class FormatOpts
---@field capitalize boolean capitalize letters in the task ID

---@class GitConfig
---@field task_template string ($task) Task ID pattern, expressed as a Lua pattern.
---@field message_template string Git message template. Can use $variables from GitConfig
---@field format_opts FormatOpts task formatting options
---@class ProjectConfig
---@field git GitConfig

---Set project config to the provided table
---
---This function is expected to be used in conjunction with nvim's exrc feature,
---which is enabled for this config.
---
---Project-local config should call this function to configure the specifics of
---nvim behavior for this project.
---
---@param config ProjectConfig config table
function Project:set_config(config)
  local log = require("utils.log")

  if self._config ~= nil then
    log.debug("Overriding project config")
  end

  log.debug("Set project config to", config)
  self._config = config
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
function Project:read_field(field_type, ...)
  local config = self._config

  if config == nil then
    require("utils.log").warn("Project config is not set")
    return
  end

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
