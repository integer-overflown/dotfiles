return {
  {
    "williamboman/mason.nvim",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "clangd", "rust_analyzer", "cmake" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- setup lua_ls (Lua LSP)
      lspconfig.lua_ls.setup({})

      -- setup clangd (C/C++/ObjC/ObjC++ support)
      lspconfig.clangd.setup({
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=bundled",
        },
      })

      -- setup rust_analyzer (Rust LSP)
      lspconfig.rust_analyzer.setup({})

      -- switching between .h/{.c,.cpp}
      vim.keymap.set(
        "n",
        "<leader>sh",
        ":ClangdSwitchSourceHeader<CR>",
        { desc = "Switch to corresponding C/C++ header/source file" }
      )

      lspconfig.cmake.setup({})
    end,
  },
}
