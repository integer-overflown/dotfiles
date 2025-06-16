-- install telescope plugin
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            -- For symmetry with built-in window commands: Ctrl-W_s/Ctrl-W_v
            ["<C-s>"] = actions.select_horizontal,
            ["<C-x>"] = false,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-f>"] = nil,
            ["<Down>"] = actions.cycle_history_next,
            ["<Up>"] = actions.cycle_history_prev,
            ["<C-k>"] = nil,
          },
          n = {
            ["<C-s>"] = actions.select_horizontal,
            ["<C-x>"] = false,
            ["<C-v>"] = actions.select_vertical,
            ["q"] = actions.close,
          },
        },
      },
    })

    telescope.load_extension("ui-select")
  end,
}
