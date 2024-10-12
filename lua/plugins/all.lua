return {
  -- install catpuccin colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  -- install telescope plugin
  { 
    "nvim-telescope/telescope.nvim", 
    tag = "0.1.8", 
    dependencies = { "nvim-lua/plenary.nvim" } 
  },
  -- install treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- install neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  },
}

