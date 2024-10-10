return {
    -- install rose-pine colorscheme
    { "rose-pine/neovim", name = "rose-pine" },
    -- install telescope plugin
    { 
        "nvim-telescope/telescope.nvim", 
        tag = "0.1.8", 
        dependencies = { "nvim-lua/plenary.nvim" } 
    },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
