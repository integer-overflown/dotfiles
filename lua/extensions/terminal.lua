local manager = require("extensions.terminal.manager")

vim.keymap.set("n", "<leader>tt", function() manager:toggle_term() end, {})

vim.api.nvim_create_user_command("Term", function(args)
  print(args.name, vim.inspect(args.args))

  local opts = {}

  for k, v in string.gmatch(args.args, "(%w+)=(%w+)") do
    opts[k] = v
  end

  opts.new = args.bang

  manager:toggle_term(opts)
end, {
  nargs = "*",
  bang = true,
  complete = function(lead)
    local completion_items = {
      ["strategy="] = require("extensions.terminal.window").available_strategies(),
      ["group="] = manager:active_groups()
    }

    local cat = function(start, args)
      local res = {}

      for i, arg in ipairs(args) do
        res[i] = start .. arg
      end

      return res
    end

    for item, completions in pairs(completion_items) do
      if string.find(lead, item) then
        return cat(item, completions)
      end
    end

    return vim.tbl_keys(completion_items)
  end
})

vim.api.nvim_create_user_command("GroupMenu", function(args)
  manager:toggle_group(args.args)
end, {
  nargs = 1,
  desc = "Toggle the terminal group UI menu",
  complete = function()
    return manager:active_groups()
  end
})
