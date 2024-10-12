return {
  -- install catpuccin colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  -- install telescope plugin
  { 
    "nvim-telescope/telescope.nvim", 
    tag = "0.1.8", 
    dependencies = { "nvim-lua/plenary.nvim" } 
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}

