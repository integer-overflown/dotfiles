P = function(object)
  print(vim.inspect(object))
end

Util = {}

Util.unload = function(modname)
  package.loaded[modname] = nil
end

Util.reload = function(modname)
  Util.unload(modname)
  return require(modname)
end
