-- options {{{
vim.opt_local.spell = true
vim.opt_local.spelllang = "id,en"
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.textwidth = 80
vim.opt_local.conceallevel = 2
-- }}}

-- folding {{{
-- Use Treesitter for folding
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"

-- Customize fold text to show the first line (heading)
vim.opt_local.foldtext = "v:lua.CustomFoldText()"

-- Configure folding options for Markdown
vim.opt_local.foldlevelstart = 99 -- Start with all folds open
vim.opt_local.foldenable = true -- Enable folding by default
vim.opt_local.foldminlines = 1 -- Folds with at least 1 line

-- Ensure all folds are expanded when opening the file
vim.opt_local.foldlevel = 99 -- Expand all folds
vim.opt_local.foldcolumn = "0" -- Remove the fold column
vim.opt_local.fillchars = "fold: " -- Remove fold markers in text

-- Ensure syntax highlighting is turned on
vim.opt_local.syntax = "on" -- Ensure syntax highlighting is enabled

-- Limit folds to only headings (folds start at #)
vim.cmd("setlocal foldexpr=nvim_treesitter#foldexpr()")

-- Ensure that the fold region doesn't override syntax highlighting
vim.api.nvim_set_hl(0, "Folded", { fg = "NONE", bg = "NONE", default = true })

-- Define the custom fold text function
function _G.CustomFoldText()
    -- Show the first line of the fold, typically the Markdown heading
    return vim.fn.getline(vim.v.foldstart)
end
-- }}}

-- keybindings {{{
local map = require("utils").map

-- utils {{{
-- key, function_to_call, arg_for_function, description_suffix
local maps = {
    -- heading level
    { "n", "<leader>m>", "heading_level", "demote", "Demote heading" },
    { "n", "<leader>m<", "heading_level", "promote", "Promote heading" },
    { "n", "<leader>mh>", "heading_level", "demote_all", "Demote all heading" },
    { "n", "<leader>mh<", "heading_level", "promote_all", "Promote all heading" },
    -- clear heading formatting
    { "n", "<leader>mhc", "clear_heading_formatting", nil, "Clear heading formatting" },
    -- status
    { "n", "<leader>msn", "set_status", "new", "Mark as new file" },
    { "n", "<leader>msw", "set_status", "working", "Mark as current working" },
    { "n", "<leader>msd", "set_status", "todo", "Mark as fix todo" },
    { "n", "<leader>msr", "set_status", "ready", "Mark as ready to post" },
    { "n", "<leader>msf", "set_status", "finished", "Mark as finished" },
    -- separator
    { { "n", "v" }, "[b", "jump_separator", "prev", "Previous separator" },
    { { "n", "v" }, "]b", "jump_separator", "next", "Next separator" },
    -- editing
    { "n", "<leader>mf", "fix_character", nil, "Fix non-standard character" },
    { "n", "<leader>mp", "wrap_all_below", nil, "Wrap all paragraph below" },
    { "n", "<leader>mj", "one_line_paragraphs", nil, "One line paragraph below" },
    -- checkbox
    { "n", "<leader>x", "toggle_checkbox", nil, "Toggle checkbox" },
    { "n", "<leader>X", "remove_checkbox", nil, "Remove checkbox" },
    -- clean spacing arround hyphen
    { {"n", "v"}, "<leader>mch", "apply_clean_spacing_around_hyphen", nil, "Spacing arround hyphen"},
}

for _, map_info in ipairs(maps) do
    local mode = map_info[1]
    local key_suffix = map_info[2]
    local func_name = map_info[3]
    local arg = map_info[4]
    local desc = map_info[5]

    map(mode, key_suffix, function()
        if arg ~= nil then
            require("utils.markdown")[func_name](arg)
        else
            require("utils.markdown")[func_name]()
        end
    end, { desc = desc, buffer = true })
end
-- }}}

-- format file {{{
map("n", "<leader>uf", "<CMD>lua require('utils').format()<CR>", { desc = "Format", buffer = true })
-- }}}

-- format block {{{
map("v", "<leader>b", "<esc>`>a**<esc>`<i**<esc>", { desc = "Bold", buffer = true })
map("v", "<leader>i", "<esc>`>a_<esc>`<i_<esc>", { desc = "Italic", buffer = true })
-- }}}

-- wrap {{{
map("n", "gp", "vipgw", { desc = "Wrap paragraph", buffer = true })
-- }}}

-- split paragraph into sentences {{{
local end_punctuation = table.concat({ "\\.", "!", "?", "…" }, "\\|")
map(
    "n",
    "gs",
    "vip:s/\\(" .. end_punctuation .. "\\)\\([^\"']\\)/\\1\\r\\r\\2/g | %s/^ \\+// | noh | normal! gvgw<CR>",
    { desc = "Split paragraph into sentences", buffer = true }
)
-- }}}

-- clear excess lines {{{
map(
    "n",
    "<leader>mcl",
    [[m` :g/^\s*$/,/^\S/ s/^\(\n\s*\)\{2,}/\r/ | normal! j ``<CR>]],
    { desc = "Excess lines", buffer = true }
)
-- }}}

-- clean spacing arround hyphen {{{
-- }}}
-- }}}
