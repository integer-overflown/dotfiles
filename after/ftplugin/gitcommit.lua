local nio = require("nio")

nio.run(function()
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
  end

  local exit_code = process.result(false)

  if exit_code ~= 0 then
    e("non-zero exit code")
  end

  local branch_name = process.stdout.read()

  local conf = require("utils.config")
  local task_template = conf.read_field(conf.load_config().wait(), "string", "git", "task_template")
  local message_template = conf.read_field(conf.load_config().wait(), "string", "git", "message_template")

  if not (task_template and message_template) then
    return
  end

  local task = string.match(branch_name, task_template)

  if not task then
    return
  end

  local message = string.gsub(message_template, "%$task", task)

  vim.schedule(function()
    vim.api.nvim_buf_set_lines(0, 0, 1, true, { message })
    vim.cmd("startinsert!")
  end)

  process.close()
end)
