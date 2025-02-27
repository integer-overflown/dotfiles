local function navigate_to_parent(state)
  local node = state.tree:get_node()
  print(vim.inspect(node))

  local parent_node = node:get_parent_id()

  if parent_node == nil then
    return
  end

  local path = state.tree:get_node(parent_node):get_id()
  require("neo-tree.sources.filesystem").navigate(state, state.path, path)
end

-- install neo-tree
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = true,
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    document_symbols = {
      follow_cursor = true,
    },
    filesystem = {
      use_libuv_file_watcher = true,
      follow_current_file = true,
    },
    commands = {
      ["navigate_to_parent"] = navigate_to_parent,
    },
    window = {
      mappings = {
        ["<cr>"] = "open_with_window_picker",
        ["g<cr>"] = "open",
        ["v"] = "vsplit_with_window_picker",
        ["s"] = "split_with_window_picker",
        ["K"] = "navigate_to_parent",
      },
    },
  },
}
