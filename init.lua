-- ★ OPTIONS {{{
local options = {
    -- line number
    numberwidth = 6,
    -- statusline
    cmdheight = 1,
    showcmdloc = "statusline",
    laststatus = 2,
    showmode = false,
    -- tabs & text
    tabstop = 2,
    shiftwidth = 2,
    expandtab = true,
    autoindent = true,
    smarttab = true,
    linebreak = true,
    breakindent = true,
    wrap = true,
    textwidth = 0,
    colorcolumn = "81",
    -- scrolling
    scrolloff = 12,
    sidescrolloff = 8,
    -- searching
    ignorecase = true,
    smartcase = true,
    hlsearch = true,
    incsearch = true,
    -- split window behaviour
    splitbelow = true,
    splitright = true,
    -- color & gui
    termguicolors = true,
    signcolumn = "yes",
    cursorline = true,
    cursorlineopt = "screenline,number",
    guicursor = "i:hor25",
    fillchars = "eob: ",
    -- file handling
    swapfile = false,
    backup = false,
    fileencoding = "utf-8",
    -- miscellenaous
    title = true,
    hidden = true,
    syntax = "ON",
    mouse = "a",
    pumheight = 10,
    shell = "fish",
    backspace = "indent,eol,start",
    foldmethod = "marker",
}

for key, value in pairs(options) do
    vim.o[key] = value
end

-- mapping
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- miscellenaous
vim.cmd("filetype plugin on")
vim.cmd("set wildmenu")

-- disable built-in plugins
local disabled_built_ins = {
    "gzip",
    "netrw",
    "netrwPlugin",
    "tarPlugin",
    "tohtml",
    "zipPlugin",
    "matchit",
    "matchparen",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
-- }}}

-- ★ KEYBINDINGS {{{
local map = require("utils").map

-- save, quit, exit {{{
map("n", "<leader>w", "<CMD>w!<CR>", { desc = "Save file" })
map("n", "<leader>q", "<CMD>q!<CR>", { desc = "Quit NeoVim" })

map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map("v", "aa", "<ESC>")
-- }}}

-- editing {{{
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>v", [["+P]], { desc = "Paste from system clipboard" })
map("n", "go", "o<ESC>", { desc = "Insert line below" })
map("n", "gO", "O<ESC>", { desc = "Insert line above" })
map("v", "<", "<gv", { desc = "Demote indent" })
map("v", ">", ">gv", { desc = "Promote indent" })
map("n", "gj", "<ESC>:m .+1<CR>", { desc = "Move line down" })
map("n", "gk", "<ESC>:m .-2<CR>", { desc = "Move line up" })
map("v", "gj", ":m '>+1<CR>gv-gv", { desc = "Move line down" })
map("v", "gk", ":m '<-2<CR>gv-gv", { desc = "Move line up" })

-- autopair
map("i", "(", "()<Left>")
map("i", "[", "[]<Left>")
map("i", "{", "{}<Left>")
map("i", '"', '""<Left>')
map("i", "'", "''<Left>")
map("i", "`", "``<Left>")
-- }}}

-- window {{{
map("n", "<leader>sx", "<C-w>q", { desc = "Quit window" })
-- split window
map("n", "<leader>sh", "<C-w>s", { desc = "Split window" })
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertially" })
map("n", "<leader>se", "<C-w>=", { desc = "Equally high and wide" })
-- go to window
map("n", "<C-h>", "<C-w>h", { desc = "Go to the left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to the right window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to the up window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to the down window" })
-- resize window
map("n", "<C-Left>", "<C-w><", { desc = "Decrease width" })
map("n", "<C-Right>", "<C-w>>", { desc = "Increase width" })
map("n", "<C-Down>", "<C-w>-", { desc = "Decrease height" })
map("n", "<C-Up>", "<C-w>+", { desc = "Increase height" })
-- }}}

-- buffer {{{
map("n", "<TAB>", "<CMD>bn<CR>", { desc = "Go to next buffer" })
map("n", "<S-TAB>", "<CMD>bp<CR>", { desc = "Go to previous buffer" })
map("n", "<leader>bx", "<CMD>bd!<CR>", { desc = "Delete buffer" })
-- }}}

-- serach & navigation {{{
-- scroll {{{
local lines = 10
map("n", "[r", lines .. "<C-e>", { desc = "Scroll-up " .. lines .. " lines" })
map("n", "]r", lines .. "<C-e>", { desc = "Scroll-down " .. lines .. " lines" })
-- }}}

-- clear search
map("n", "<leader>h", "<CMD>nohl<CR>", { desc = "Clear search highlights" })

-- cursor movement {{{
map({"n", "v"}, "<C-d>", "<C-d>zz")
map({"n", "v"}, "<C-u>", "<C-u>zz")
map({"n", "v"}, "<C-f>", "<C-f>zz")
map({"n", "v"}, "<C-b>", "<C-b>zz")
-- }}}

-- find {{{
-- Key, command_suffix, theme (optional), description
require("utils").telescope_map({
    b = { "buffers", "dropdown", "Buffers" },
    C = { "commands", nil, "Commands" },
    R = { "registers", nil, "Registers" },
    c = { "colorscheme", "dropdown", "Colorscheme" },
    f = { "find_files", "ivy", "Files" },
    g = { "live_grep", "ivy", "Text" },
    h = { "help_tags", nil, "Help" },
    j = { "jumplist", nil, "Jump Locations" },
    k = { "keymaps", nil, "Keymaps" },
    r = { "oldfiles", "ivy", "Recent File" },
    s = { "grep_string", "ivy", "grep string" },
})
-- }}}

-- explorer
map("n", "<leader>e", "<CMD>NvimTreeFindFileToggle<CR>", { desc = "File explorer" })

-- todo-comments {{{
map("n", "<leader>fd", "<CMD>TodoTelescope theme=ivy<CR>", { desc = "Todo" })
map({ "n", "v" }, "[t", "<CMD>lua require('todo-comments').jump_prev()<CR>", { desc = "Previous todo comment" })
map({ "n", "v" }, "]t", "<CMD>lua require('todo-comments').jump_next()<CR>", { desc = "Next todo comment" })
-- }}}
-- }}}

-- user {{{
map("n", "<leader>us", "<CMD>lua require('stay-centered').toggle()<CR>", { desc = "Toggle stay centered" })
map("n", "<leader>uw", "<CMD>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>un", "<CMD>set nu! | set rnu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>ut2", "<CMD>lua require('utils').set_tab(2)<CR>", { desc = "2" })
map("n", "<leader>ut4", "<CMD>lua require('utils').set_tab(4)<CR>", { desc = "4" })
map("n", "<leader>ut8", "<CMD>lua require('utils').set_tab(8)<CR>", { desc = "8" })
-- }}}

-- plugin {{{
-- Key, command_suffix, description
require("utils").lazy_map({
    c = { "clean", "Clean" },
    d = { "debug", "Debug" },
    h = { "home", "Home" },
    i = { "install", "Install" },
    l = { "log", "Log" },
    p = { "profile", "Profile" },
    s = { "sync", "Sync" },
    u = { "update", "Update" },
})
-- }}}

-- miscellenaous {{{
-- folding
map("n", "<space>", "<CMD>lua require('utils').toggle_fold()<CR>", { desc = "Toggle fold" })

-- comment tag {{{
-- cycle tag
map("n", "<leader>d", "<CMD>lua require('utils').cycle_tag()<CR>", { desc = "Cycle comment tag" })

-- set tag
require("utils").comment_tag_map({
    b = "bug",
    F = "failed",
    P = "passed",
    a = "ask",
    d = "todo",
    f = "fix",
    h = "hack",
    i = "info",
    m = "mark",
    n = "note",
    o = "optimize",
    p = "perf",
    t = "test",
    w = "warn",
})
-- }}}
-- }}}
-- }}}

-- ★ AUTOCOMMAND {{{
-- cursor on quit {{{
vim.api.nvim_create_autocmd({ "VimLeave" }, {
    pattern = { "*" },
    command = "set guicursor=a:hor25",
})
-- }}}

-- Auto-capitalize {{{
vim.cmd([[
  func! WordProcessorMode()
      " Auto-capitalize script
      augroup SENTENCES
          au!
          autocmd InsertCharPre * if search('\v(%^|[.!?]\_s+|\_^\-\s|\_^title\:\s|\n\n)%#', 'bcnw') != 0 | let v:char = toupper(v:char) | endif
      augroup END
  endfu

  com! WP call WordProcessorMode()
  au BufNewFile,BufRead *.md call WordProcessorMode()
]])
-- }}}

-- custom highlights {{{
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = require("utils.ui").keep_hl,
})

-- }}}
-- }}}

-- ★ PLUGINS {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "plugins" },
}, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
-- }}}

-- ★ UI {{{
-- statusline {{{
require("ui.statusline")
-- }}}

-- colorscheme {{{
local current_dir = vim.fn.getcwd()

if current_dir:find("/novel", 1, true) then
    vim.o.background = "light"
    vim.cmd("colorscheme comrade-light")
elseif current_dir:find("/lang", 1, true) then
    vim.o.background = "light"
    vim.cmd("colorscheme onehalflight")
elseif current_dir:find("/python", 1, true) then
    vim.cmd("colorscheme materialbox")
else
    vim.cmd("colorscheme ayu")
end
-- }}}
-- }}}
