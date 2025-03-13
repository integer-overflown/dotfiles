return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup()

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
