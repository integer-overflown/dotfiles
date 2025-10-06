-- install catpuccin colorscheme
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local theme = require("catppuccin")

    local opts = {
      transparent_background = true,
      show_end_of_buffer = false,
    }

    theme.setup(opts)

    -- Set the default color scheme
    vim.cmd([[colorscheme catppuccin-macchiato]])

    local dn = require("dark_notify")

    dn.run({
      schemes = {
        dark = "catppuccin-macchiato",
        light = "catppuccin-latte",
      },
    })
  end,
}
