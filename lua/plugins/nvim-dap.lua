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

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Runs preLaunchTask / postDebugTask if present
    { "stevearc/overseer.nvim",          config = true },
    { "rcarriga/nvim-dap-ui",            dependencies = { "nvim-neotest/nvim-nio" }, config = true },
    { "theHamsta/nvim-dap-virtual-text", config = true },
  },
  config = function()
    configure_keymaps()
    configure_adapters()
    configure_events()
  end,
}
