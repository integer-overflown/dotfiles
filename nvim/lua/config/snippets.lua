local ls = require("luasnip")

local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

local extras = require("luasnip.extras")

vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

local function debug_choice_node(_, _, _, index)
  index = index or 1

  vim.print(index)

  local key = "message_text" .. index;

  return sn(nil, {
    c(1, {
      r(nil, key, i(nil, "message")),
      sn(nil, { r(2, key), t " << ", d(1, debug_choice_node, {}, {
        user_args = {
          index + 1
        }
      }) }),
    })
  })
end

local function get_debug_snippet(trigger)
  local macro_by_type = {
    ["debug"] = "qDebug",
    ["warn"] = "qWarning",
    ["crit"] = "qCritical",
    ["fatal"] = "qFatal",
    ["info"] = "qInfo",
  }

  return s(trigger, {
    t(macro_by_type[trigger]), t "(logging::", i(1, "category"), t ") << ", d(2, debug_choice_node, {}), t ";"
  })
end

ls.add_snippets("cpp", {
  get_debug_snippet("debug"),
  get_debug_snippet("warn"),
  get_debug_snippet("crit"),
  get_debug_snippet("fatal"),
  get_debug_snippet("info"),
})

ls.add_snippets("cpp", {
  s("emake", {
    t("auto *"), extras.rep(1), t " = ", t "gst_element_factory_make(\"", i(1, "element_name"), t "\", ", i(2, "nullptr"),
    t ");"
  }),
  s("eget", {
    t "g_autoptr(GstElement) ", extras.rep(2), t " = ", t "gst_bin_get_by_name(", i(1, "bin"), t ", ", t '"', i(2,
    "element_name"), t '"', t ");"
  }),
})

local function clear_snippets()
  require("luasnip").cleanup()
end

vim.api.nvim_create_user_command("ClearSnippets", clear_snippets, {})
