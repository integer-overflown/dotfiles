local options = { "absolute", "relative" }

local function pick_path(type, out_reg)
  local reg = out_reg or "@"

  local pickers = {
    ["absolute"] = function()
      local val = vim.fn.expand("%:p")

      vim.fn.setreg(reg, val)
      return val
    end,
    ["relative"] = function()
      local val = vim.fn.expand("%:.")

      vim.fn.setreg(reg, val)
      return val
    end,
  }

  local picker = pickers[type]

  if picker == nil then
    return
  end

  local picked = picker()

  if #picked == 0 then
    print("No file path")
    return
  end

  if out_reg then
    print("Picked", picked, "to", out_reg)
  else
    print("Picked", picked)
  end
end

local function open_path_picker(out_reg)
  vim.ui.select(options, {
    prompt = "Select path type",
  }, function(item)
    if item ~= nil then
      pick_path(item, out_reg)
    end
  end)
end

vim.api.nvim_create_user_command("PickPath", function(cmd)
  -- the function is nil-safe, so we're fine if no args were passed
  vim.print(cmd)
  open_path_picker(cmd.fargs[1])
end, {
  desc = "Open file path picker",
  nargs = "?",
})

vim.keymap.set("n", "<leader>fp<cr>", open_path_picker, { desc = "Open file path picker" })

vim.keymap.set("n", "<leader>fpa", function()
  pick_path("absolute")
end, { desc = "Pick an absolute path to the current file" })

vim.keymap.set("n", "<leader>fpr", function()
  pick_path("relative")
end, { desc = "Pick an absolute path to the current file" })
