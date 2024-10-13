return {
  {
    "williamboman/mason.nvim",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "clangd", "rust_analyzer" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- setup lua_ls (Lua LSP)
      require("lspconfig").lua_ls.setup({})

      -- setup clangd (C/C++/ObjC/ObjC++ support)
      require("lspconfig").clangd.setup({})

      -- setup rust_analyzer (Rust LSP)
      require("lspconfig").rust_analyzer.setup({})
    end,
  },
}
