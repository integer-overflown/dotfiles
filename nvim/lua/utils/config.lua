local M = {
}

local Project = {
}

M.Project = Project

---@class FormatOpts
---@field capitalize boolean capitalize letters in the task ID

---@class GitConfig
---@field task_template string? ($task) Task ID pattern, expressed as a Lua pattern.
---@field message_template string? Git message template. Can use $variables from GitConfig
---@field format_opts FormatOpts task formatting options
---@class ProjectConfig
---@field git GitConfig

---@type ProjectConfig
local DEFAULT_CONFIG = {
  git = {
    format_opts = {
      capitalize = false,
    }
  },
}

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
  self._config = vim.tbl_deep_extend("keep", config, DEFAULT_CONFIG)
end

---Read a config field
---
---Each member in the key array nests into the config structure; see key_spec param description for
---more info.
---
---If the keys point to a value, it's returned.
---If the value is found, but is on an incorrect type, nil is returned
---
---@param field_type string required field type
---@param key_spec table config key spec, effectively means config[key[0]][key[1]]...[key[n]]
---
---@return any|nil value
function Project:read_field(field_type, key_spec)
  local config = self._config

  if config == nil then
    require("utils.log").warn("Project config is not set")
    return
  end

  for _, key in ipairs(key_spec) do
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
    local pretty_name = table.concat(key_spec, ".")

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
