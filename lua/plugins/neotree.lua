local function navigate_to_parent(state)
  local node = state.tree:get_node()

  local parent_node = node:get_parent_id()

  if parent_node == nil then
    return
  end

  local path = state.tree:get_node(parent_node):get_id()
  require("neo-tree.sources.filesystem").navigate(state, state.path, path)
end

local function reveal_in_file_explorer(state)
  local node = state.tree:get_node()
  local path

  if node.type == "directory" then
    path = node.path
  else
    local parent_node = node:get_parent_id()

    if parent_node then
      path = parent_node
    end
  end

  if path then
    vim.ui.open(path)
  end
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
      ["reveal_in_file_explorer"] = reveal_in_file_explorer,
    },
    window = {
      mappings = {
        ["<cr>"] = "open_with_window_picker",
        ["g<cr>"] = "open",
        ["v"] = "vsplit_with_window_picker",
        ["s"] = "split_with_window_picker",
        ["K"] = "navigate_to_parent",
        ["R"] = "reveal_in_file_explorer",
      },
    },
  },
}
