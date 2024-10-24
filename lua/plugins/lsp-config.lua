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
      require("lspconfig").clangd.setup({
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=bundled",
        },
      })

      -- setup rust_analyzer (Rust LSP)
      require("lspconfig").rust_analyzer.setup({})

      vim.keymap.set(
        "n",
        "<leader>sh",
        ":ClangdSwitchSourceHeader<CR>",
        { desc = "Switch to corresponding C/C++ header/source file" }
      )
    end,
  },
}
