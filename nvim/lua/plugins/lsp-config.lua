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
      -- setup clangd (C/C++/ObjC/ObjC++ support)
      vim.lsp.config.clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=bundled",
        },
      }

      -- switching between .h/{.c,.cpp}
      vim.keymap.set(
        "n",
        "<leader>sh",
        ":ClangdSwitchSourceHeader<CR>",
        { desc = "Switch to corresponding C/C++ header/source file" }
      )
    end,
  },
}
