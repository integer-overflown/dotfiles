return {
  -- install telescope plugin
  { 
    "nvim-telescope/telescope.nvim", 
    tag = "0.1.8", 
    dependencies = { "nvim-lua/plenary.nvim" } 
  },
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

