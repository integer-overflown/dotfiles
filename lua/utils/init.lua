local M = {}

M.desc = function(options, description)
  options.desc = description
  return options
end

M.count_keys = function(table)
  local n = 0

  for _, _ in pairs(table) do
    n = n + 1
  end

  return n
end

return M
