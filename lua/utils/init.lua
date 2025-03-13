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

--- Check if the given path is syntactically valid
---
--- This does not check if the path actually refers to an
--- existing file on a disk, only the syntax correctness.
---
--- @param path string the file path
--- @return boolean is_valid
M.is_valid_path = function(path)
  return vim.fn.match(path, [[^\f\+$]]) >= 0
end

return M
