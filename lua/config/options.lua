-- Set the tab width to 4
vim.opt.shiftwidth = 4
-- Enable line numbers by default
vim.opt.number = true
-- Enable syntax highlighting
vim.opt.syntax = "on"
-- Expand tabs to spaces
vim.opt.expandtab = true
-- Enable relative numbers by default
vim.opt.relativenumber = true
-- Automatically read from disk when file is changed
-- externally (by VCS, for example)
vim.opt.autoread = true

-- Set the leader key to Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Configure how new splits should be opened
vim.opt.splitright = false
vim.opt.splitbelow = false

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Live command substitution (for substitute and user commands)
vim.opt.inccommand = "split"

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("ovf-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.opt.fillchars = { foldopen = "▶", foldclose = "▼", foldsep = "│" }

local function get_fold(lnum)
    local fcs = vim.opt.fillchars:get()

    if vim.fn.foldlevel(lnum) == 0 then
        return ' '
    end

    -- we're inside an unfolded fold
    if vim.fn.foldlevel(lnum) == vim.fn.foldlevel(lnum - 1) then
        return fcs.foldsep
    end

    local is_closed_fold = vim.fn.foldclosed(lnum) >= 0
    local is_fold_boundary = vim.fn.foldlevel(lnum) >= vim.fn.foldlevel(lnum - 1)

    if is_fold_boundary then
        if is_closed_fold then
            return fcs.foldopen
        else
            return fcs.foldclose
        end
    end

    return fcs.foldsep
end

_G.get_statuscol = function()
    local win_id = vim.g.statusline_winid
    local number = vim.api.nvim_win_get_option(win_id, "number")
    local relnum = vim.api.nvim_win_get_option(win_id, "relativenumber")

    if not number then return "" end

    local line_no = ""
    if number then
        if relnum then
            line_no = "%=%{v:relnum?v:relnum:v:lnum}"
        else
            line_no = "%{v:lnum}"
        end
    end

    return "%s" .. line_no .. " %=" .. (get_fold(vim.v.lnum) or "") .. " "
end

vim.opt.signcolumn = "yes:1"
vim.o.statuscolumn = "%!v:lua.get_statuscol()"

-- Enable project-local config files
vim.o.exrc = true
