local options = {
  "absolute",
  "basename",
  "directory",
  "relative directory",
  "relative",
}

local function get_path(path, type)
  local pickers = {
    absolute = function()
      return vim.fn.fnamemodify(path, ":p")
    end,
    relative = function()
      return vim.fn.fnamemodify(path, ":~:.")
    end,
    directory = function()
      return vim.fn.fnamemodify(path, ":p:h")
    end,
    basename = function()
      return vim.fn.fnamemodify(path, ":p:t")
    end,
    ["relative directory"] = function()
      return vim.fn.fnamemodify(path, ":.:h")
    end,
  }

  local picker = pickers[type]

  if picker then
    return picker()
  end
end

local function confirm_selection(result, out_reg)
  if #result == 0 then
    print("No file path")
    return
  end

  local reg = out_reg or '"'

  vim.fn.setreg(reg, result)

  if out_reg and out_reg ~= '"' then
    print("Picked", result, "to", string.format('"%s', out_reg))
  else
    print("Picked", result)
  end
end

local function pick_path(type, out_reg)
  local path = vim.fn.getreg("%")
  local result = get_path(path, type)

  confirm_selection(result, out_reg)
end

local function open_path_picker(out_reg)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local preview = require("telescope.previewers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- since the picker is a separate buffer, we need to save and
  -- recall the actual buffer name later
  local path = vim.fn.getreg("%")
  local opts = {}

  pickers
    .new(
      opts,
      require("telescope.themes").get_dropdown({
        finder = finders.new_table(options),
        previewer = preview.new_buffer_previewer({
          define_preview = function(entry, status)
            local type = status[1]
            local result = get_path(path, type)

            vim.api.nvim_buf_set_lines(entry.state.bufnr, 0, -1, true, { result })
          end,
        }),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()

            local type = selection[1]
            local result = get_path(path, type)

            confirm_selection(result, out_reg)
          end)
          return true
        end,
      })
    )
    :find()
end

vim.api.nvim_create_user_command("PickPath", function(cmd)
  -- the function is nil-safe, so we're fine if no args were passed
  open_path_picker(cmd.reg)
end, {
  desc = "Open file path picker",
  register = true,
})

vim.keymap.set("n", "<leader>fp<cr>", function()
  open_path_picker(vim.v.register)
end, { desc = "Open file path picker" })

-- can use a register form, e.g. "+<leader>fpa will copy the path to the + register
vim.keymap.set("n", "<leader>fpa", function()
  pick_path("absolute", vim.v.register)
end, { desc = "Pick an absolute path to the current file" })

vim.keymap.set("n", "<leader>fpr", function()
  pick_path("relative", vim.v.register)
end, { desc = "Pick an absolute path to the current file" })

vim.keymap.set("n", "<leader>fpn", function()
  pick_path("basename", vim.v.register)
end, { desc = "Pick an absolute path to the current file" })
