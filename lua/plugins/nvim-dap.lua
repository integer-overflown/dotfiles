local function configure_keymaps()
  local dap = require("dap")

  vim.keymap.set("n", "<F5>", function()
    dap.continue()
  end, { desc = "Continue" })

  vim.keymap.set("n", "<F10>", function()
    dap.step_over()
  end, { desc = "Step over" })

  vim.keymap.set("n", "<F11>", function()
    dap.step_into()
  end, { desc = "Step into" })

  vim.keymap.set("n", "<F12>", function()
    dap.step_out()
  end, { desc = "Step out" })

  vim.keymap.set("n", "<Leader>bb", function()
    dap.toggle_breakpoint()
  end, { desc = "Toggle breakpoint" })

  vim.keymap.set("n", "<Leader>B", function()
    dap.set_breakpoint()
  end, { desc = "Set breakpoint" })

  vim.keymap.set("n", "<Leader>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  end, { desc = "Set log point" })

  vim.keymap.set("n", "<Leader>bc", function()
    dap.set_breakpoint(vim.fn.input("Condition: "), nil, nil)
  end, { desc = "Set conditional breakpoint" })

  vim.keymap.set("n", "<Leader>dr", function()
    dap.repl.open()
  end, { desc = "Open repl" })

  vim.keymap.set("n", "<Leader>dl", function()
    dap.run_last()
  end, { desc = "Run last" })

  vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
    require("dap.ui.widgets").hover()
  end, { desc = "Open hover widget" })

  vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
    require("dap.ui.widgets").preview()
  end, { desc = "Open preview widget" })

  vim.keymap.set("n", "<Leader>df", function()
    local widgets = require("dap.ui.widgets")
    widgets.centered_float(widgets.frames)
  end, { desc = "Open frames window" })

  vim.keymap.set("n", "<Leader>ds", function()
    local widgets = require("dap.ui.widgets")
    widgets.centered_float(widgets.scopes)
  end, { desc = "Open scope view" })
end

local function configure_adapters()
  local dap = require("dap")
  local ports = {
    code_lldb = 13000,
  }

  dap.adapters.codelldb = {
    type = "server",
    port = ports.code_lldb,
    executable = {
      command = "codelldb",
      args = { "--port", ports.code_lldb },
    },
  }
end

local function configure_events()
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
end

local function get_terminal_buf()
  local nio = require("nio")

  local autoscroll = true
  local terminal_buf = -1

  local function get_buf()
    if nio.api.nvim_buf_is_valid(terminal_buf) then
      return terminal_buf
    end

    local prev_tab = vim.api.nvim_get_current_tabpage()
    local prev_win = vim.api.nvim_get_current_win()

    vim.cmd("tabnew")

    local window = vim.api.nvim_get_current_win()

    terminal_buf = vim.api.nvim_create_buf(true, true)

    vim.api.nvim_set_option_value("filetype", "log", {
      buf = terminal_buf,
    })

    vim.api.nvim_set_option_value("modifiable", false, {
      buf = terminal_buf,
    })

    vim.api.nvim_win_set_buf(window, terminal_buf)

    vim.api.nvim_set_current_tabpage(prev_tab)
    vim.api.nvim_set_current_win(prev_win)

    vim.keymap.set("n", "G", function()
      autoscroll = true
      vim.cmd("normal! G")
    end, { silent = true, buffer = terminal_buf })

    vim.api.nvim_buf_attach(terminal_buf, false, {
      on_lines = function(_, _, _, first, _, last_in_range)
        local active_buf = nio.api.nvim_win_get_buf(0)
        local ns_id = -1

        local lines = vim.api.nvim_buf_get_lines(active_buf, first, last_in_range, true)

        for idx, line in ipairs(lines) do
          local patterns = { "[WARNING]", "[ERROR]" }
          local found = false

          for _, pat in ipairs(patterns) do
            if string.find(line, pat, 0, true) then
              found = true
              break
            end
          end

          if not found then
            break
          end

          local line_no = first + idx - 1

          vim.api.nvim_buf_add_highlight(active_buf, ns_id, "CurSearch", line_no, 0, -1)
        end

        if autoscroll and vim.fn.mode() == "n" and active_buf == terminal_buf then
          vim.cmd("normal! G")
        end
      end,
    })

    return terminal_buf
  end

  return get_buf
end

local function configure_defaults()
  local dap = require("dap")
  dap.defaults.fallback.terminal_win_cmd = get_terminal_buf()
end

local function dap_ui_options()
  return {
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.25,
          },
          {
            id = "breakpoints",
            size = 0.25,
          },
          {
            id = "stacks",
            size = 0.25,
          },
          {
            id = "watches",
            size = 0.25,
          },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          {
            id = "repl",
            size = 1,
          },
        },
        position = "bottom",
        size = 10,
      },
    },
  }
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Runs preLaunchTask / postDebugTask if present
      { "stevearc/overseer.nvim",          config = true },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = true,
        opts = dap_ui_options(),
      },
      { "theHamsta/nvim-dap-virtual-text", config = true },
    },
    config = function()
      configure_keymaps()
      configure_adapters()
      configure_events()
      configure_defaults()
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = true,
    opts = {
      ensure_installed = { "codelldb" },
    },
  },
}
