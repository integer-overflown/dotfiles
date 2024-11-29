-- install telescope plugin
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
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
