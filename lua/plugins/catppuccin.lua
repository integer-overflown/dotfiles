-- install catpuccin colorscheme
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function() 
    -- Set the default color scheme
    vim.cmd [[colorscheme catppuccin-macchiato]] 
  end
}

