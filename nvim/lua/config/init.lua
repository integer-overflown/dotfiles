-- Load globals
require("config.globals")

-- Configure global vim options
require("config.options")

-- Load Lazy and the plugins
require("config.lazy")

-- Configure LSP auto-commands
require("config.lsp")

-- Configure fold auto-commands
require("config.folds")

-- Configure keyboard maps, now that all plugins are accessible
require("config.keymaps")

-- Configure spellcheck
require("config.spellcheck")

-- Configure snippets
require("config.snippets")
