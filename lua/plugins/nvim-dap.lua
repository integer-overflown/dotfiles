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
  local log = require("utils.log")

  log.debug("Configuring adapters")

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
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

  local terminal_buf = -1
  local tab_index = -1

  local function get_buf()
    if nio.api.nvim_buf_is_valid(terminal_buf) then
      return terminal_buf
    end

    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new({
      display_name = "DAP process output",
      auto_scroll = true,
      hidden = true,
      close_on_exit = false,
      direction = "tab",
      on_create = function(term)
        assert(nio.api.nvim_buf_is_valid(term.bufnr), "on_create must provide a valid buffer")
        terminal_buf = term.bufnr
      end,
      on_open = function()
        tab_index = vim.api.nvim_get_current_tabpage()

        vim.api.nvim_set_option_value("filetype", "log", {
          buf = terminal_buf,
        })
      end,
      on_close = function()
        tab_index = -1
      end,
    })

    -- This should trigger on_create() callback
    term:spawn()

    vim.keymap.set({ "n", "t" }, "<Leader>lg", function()
      if vim.api.nvim_tabpage_is_valid(tab_index) then
        vim.api.nvim_set_current_tabpage(tab_index)
        return
      end

      term:toggle()
    end, { desc = "Open the debugee process output" })

    assert(nio.api.nvim_buf_is_valid(terminal_buf), "buffer must be created after :spawn()")

    local conf = require("utils.config")
    local highlight = conf.read_field(conf.load_config().wait(), "table", "logging", "highlights")

    -- Derived from CurSearch
    vim.cmd("highlight LogErrorMessage guifg=#1e2030 guibg=#ed8796")

    if highlight then
      vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TermEnter" }, {
        buffer = terminal_buf,
        desc = "ToggleTerm highlight setup for logging",
        callback = function()
          local e = function(part, value)
            vim.notify("Invalid " .. part .. ": " .. vim.inspect(value), vim.log.levels.ERROR)
          end

          for group_name, pattern in pairs(highlight) do
            if type(group_name) ~= "string" then
              e("group_name", group_name)
              goto continue
            end

            if type(pattern) ~= "string" then
              e("pattern", pattern)
              goto continue
            end

            vim.fn.matchadd(group_name, pattern)

            ::continue::
          end
        end,
      })
    end

    return terminal_buf
  end

  return get_buf
end

local function configure_defaults()
  local dap = require("dap")
  dap.defaults.fallback.terminal_win_cmd = get_terminal_buf()

  local ui = require("dapui")

  vim.api.nvim_create_user_command("DapUiOpen", function(config)
    local reset = config[1] == "reset" or false
    ui.open({ reset = reset })
  end, {
    nargs = "?",
    desc = "Open DAP UI",
    complete = function()
      return { "reset" }
    end,
  })

  vim.api.nvim_create_user_command("DapUiClose", function()
    ui.close()
  end, { desc = "Close DAP UI" })
end

local dap_ui_layouts = {
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
}

local function on_select_window()
  return require("window-picker").pick_window()
end

local function configure_dap()
  -- Start loading the config asynchronously
  -- TODO: revisit this, now that logging is async
  require("utils.config").load_config()

  local nio = require("nio")

  nio.run(function()
    configure_adapters()
  end)

  configure_keymaps()
  configure_events()
  configure_defaults()
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Runs preLaunchTask / postDebugTask if present
      { "theHamsta/nvim-dap-virtual-text", config = true, lazy = true },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = true,
        opts = {
          layouts = dap_ui_layouts,
          select_window = on_select_window,
        },
      },
    },
    config = configure_dap,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = true,
    opts = {
      ensure_installed = { "codelldb" },
    },
  },
}
