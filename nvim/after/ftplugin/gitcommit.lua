local lines = vim.api.nvim_buf_get_lines(0, 0, 1, true)
assert(#lines > 0)

-- don't overwrite the contents if there is already a message
-- (for example, when amending, rebasing or merging)
-- git leaves the first line empty for user's message if one is required,
-- so we can rely on its length.
if #lines[1] > 0 then
  return
end

local nio = require("nio")
local Project = require("utils.config").Project

local function get_task_id()
  local log = require("utils.log")

  -- Strategy 1: env variable
  local env_task = os.getenv("TASK")

  if env_task then
    return env_task
  end

  -- Strategy 2: parse a task id from a branch name, according to the config
  local process, err = nio.process.run({
    cmd = "git",
    args = { "branch", "--show-current" },
  })

  local e = function(message)
    vim.schedule(function()
      vim.notify("Failed to query the current branch: " .. message, vim.log.levels.ERROR)
    end)
    process.close()
  end

  if not process then
    e(err)
    return
  end

  local exit_code = process.result(false)

  if exit_code ~= 0 then
    e("non-zero exit code")
    return
  end

  local branch_name = process.stdout.read()

  process.close()

  local task_template = Project:read_field("string", { "git", "task_template" })
  local opts = Project:read_field("table", { "git", "format_opts" })

  log.debug("task_template: ", task_template, "opts", opts)

  if not task_template then
    return
  end

  local match = string.match(branch_name, task_template)

  log.debug("match returned: ", match)

  if match and opts.capitalize then
    match = string.upper(match)
  end

  return match
end

nio.run(function()
  local task_id = get_task_id()
  local message_template = Project:read_field("string", { "git", "message_template" })

  vim.schedule(function()
    vim.fn.setreg("t", task_id)

    -- There's no data to auto-fill, but let's save pressing a single letter and
    -- enter insert mode anyway
    vim.cmd("startinsert!")

    if not (task_id and message_template) then
      return
    end

    local message = string.gsub(message_template, "%$task", task_id)

    vim.api.nvim_buf_set_lines(0, 0, 1, true, { message })
    vim.cmd("startinsert!")
  end)
end)
