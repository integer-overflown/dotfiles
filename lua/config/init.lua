-- Load globals
require("config.globals")

-- Configure global vim options
require("config.options")

-- Load Lazy and the plugins
require("config.lazy")

-- Configure LSP autocommands
require("config.lsp")

-- Configure keyboard maps, now that all plugins are accessible
require("config.keymaps")
