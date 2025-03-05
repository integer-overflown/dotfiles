return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      term = {
        -- don't persist the state on disk
        encode = false,
        create_list_item = function()
          return {
            value = vim.api.nvim_get_current_buf(),
            context = {
            }
          }
        end,
        select = function(list_item)
          if list_item == nil then
            return
          end

          require("extensions.terminal").toggle_term(list_item.value)
        end,
        equals = function(lhs_item, rhs_item)
          if lhs_item == nil and rhs_item == nil then
            return true
          end

          if lhs_item == nil or rhs_item == nil then
            return false
          end

          return lhs_item.value == rhs_item.value
        end,
        display = function(list_item)
          return vim.api.nvim_buf_get_name(list_item.value)
        end
      }
    })

    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end)

    vim.keymap.set("n", "<leader>m", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set("n", "<leader>tm", function()
      harpoon.ui:toggle_quick_menu(harpoon:list("term"))
    end)

    for i = 1, 9 do
      local cmd = string.format("<leader>h%d", i)
      vim.keymap.set("n", cmd, function()
        harpoon:list():select(i)
      end, { desc = string.format("Switch to Harpoon file %d", i) })
    end
  end,
}
