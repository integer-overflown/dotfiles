local filetype_filters = {
  "dapui_breakpoints",
  "dapui_console",
  "dapui_hover",
  "dap-repl", -- for some reason dap-ui uses dash for repl, not an underscore
  "dapui_scopes",
  "dapui_stack",
  "dapui_watches",
  "neo-tree",
  "neo-tree-popup",
  "notify",
}

return {
  "s1n7ax/nvim-window-picker",
  version = "2.*",
  config = function()
    require("window-picker").setup({
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = filetype_filters,
          -- if the buffer type is one of following, the window will be ignored
          buftype = { "terminal", "quickfix", "nofile" },
        },
      },
    })
  end,
}
