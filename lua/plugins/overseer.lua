return {
  "stevearc/overseer.nvim",
  config = true,
  opts = {
    -- Configure toggleterm integration
    strategy = {
      "toggleterm",
      use_shell = false,
      auto_scroll = true,
      quit_on_exit = "success",
      open_on_start = true,
    },
  },
}
