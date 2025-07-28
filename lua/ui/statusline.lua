local icons = require("ui.icons")

-- mode {{{
local modes = {
    ["n"] = " NORMAL", -- Neovim icon
    ["no"] = " NORMAL",
    ["v"] = "󰒉 VISUAL", -- File icon
    ["V"] = "󰩭 VISUAL LINE", -- File Line icon
    [""] = "󱊃 VISUAL BLOCK", -- Block icon
    ["s"] = " SELECT", -- Screen icon (or similar)
    ["S"] = " SELECT LINE",
    [""] = " SELECT BLOCK",
    ["i"] = " INSERT", -- Pencil icon
    ["ic"] = " INSERT",
    ["R"] = "𒄞 REPLACE", -- Replace icon (or similar)
    ["Rv"] = "𒄞 VISUAL REPLACE",
    ["c"] = " COMMAND", -- Terminal/Command icon
    ["cv"] = " VIM EX",
    ["ce"] = " EX",
    ["r"] = " PROMPT", -- Prompt/Question icon
    ["rm"] = " MOAR",
    ["r?"] = " CONFIRM",
    ["!"] = " SHELL", -- Shell icon
    ["t"] = " TERMINAL",
}

local function mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(" %s ", modes[current_mode]):upper()
end

local function update_mode_colors()
    local current_mode = vim.api.nvim_get_mode().mode

    -- Map various Neovim modes to their corresponding statusline highlight groups
    local mode_map = {
        n = "Normal",
        i = "Insert",
        ic = "Insert", -- Input-char mode also uses Insert highlight
        v = "Visual",
        V = "VisualLine",
        ["\22"] = "VisualBlock", -- '\22' is the internal representation for Ctrl-V block mode
        R = "Replace",
        s = "Select",
        S = "Select",
        ["\19"] = "Select", -- '\19' is the internal representation for Ctrl-S select mode
        c = "CmdLine",
        t = "Terminal",
    }

    -- Get the highlight group from the map, or default to "Normal"
    local highlight_suffix = mode_map[current_mode] or "Normal"
    return "%#Statusline" .. highlight_suffix .. "#"
end
-- }}}

-- file {{{
local function filepath()
    local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")

    if fpath == "" or fpath == "." then
        return " "
    end

    return string.format(" %%<%s/", fpath)
end

local function filename()
    local fname = vim.fn.expand("%:t")

    if fname == "" then
        return ""
    end

    return fname .. " "
end

local function flag()
    if vim.bo.readonly then
        return icons.ui.Lock
    end

    if vim.bo.modified then
        return icons.ui.Pencil
    end

    return ""
end

local function filetype()
    local icon, icon_highlight_group
    local ok, devicons = pcall(require, "nvim-web-devicons")

    if ok then
        icon, icon_highlight_group = devicons.get_icon(vim.fn.expand("%:t"))
        if icon == nil then
            icon, icon_highlight_group = devicons.get_icon_by_filetype(vim.bo.filetype)
        end

        if icon == nil and icon_highlight_group == nil then
            icon = icons.ui.File
            icon_highlight_group = "DevIconDefault"
        end
    else
        ok = vim.fn.exists("*WebDevIconsGetFileTypeSymbol")

        if ok ~= 0 then
            icon = vim.fn.WebDevIconsGetFileTypeSymbol()
        end
    end
    return string.format(" %s ", icon)
end
-- }}}

-- line info {{{
local function lineinfo()
    return " " .. icons.misc.MapMarker .. " %l:%c %P "
end
-- }}}

-- search count {{{
local function search_count()
    if vim.v.hlsearch == 1 then -- Check if 'hlsearch' is active
        local result = vim.fn.searchcount({ recompute = 1, maxcount = 9999 })

        if result.total > 0 then
            return string.format(" %s %d/%d ", icons.ui.Search, result.current, result.total)
        end
    end

    return "" -- Return nothing if no search is active
end
-- }}}

-- recording indicator {{{
local function recording_indicator()
    local recording_register = vim.fn.reg_recording()

    if recording_register ~= "" then
        return string.format(" 🔴 REC @%s ", recording_register):upper()
    end

    return ""
end
-- }}}

-- showcmd {{{
local function showcmd()
    return " %S "
end
-- }}}

-- word counter {{{
local function words_counter(start_line, end_line)
    local word_count = 0
    local patterns_to_exclude = {
        "^%s*<!--", -- HTML comments
        "^%s*//", -- C-style comments
        "^%s*#", -- Shell or Python comments
        "^%s*;", -- Assembly comments
        "^%s*---", -- Lua comments
        "%s*◆", -- Specific symbol ◆
        "%s*★", -- Specific symbol ★
        "^%s*title:", -- Metadata fields
        "^%s*weight:",
        "^%s*bookToc:",
    }

    for i = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if line then
            local exclude = false

            for _, pattern in ipairs(patterns_to_exclude) do
                if line:find(pattern) then
                    exclude = true
                    break
                end
            end

            if not exclude then
                -- Split the line by whitespace and count words
                for word in line:gmatch("%S+") do
                    word_count = word_count + 1
                end
            end
        end
    end

    return word_count
end

-- TODO: counter colors

local function word_count()
    local current_dir = vim.fn.getcwd()
    if
        (current_dir:find("/novel", 1, true))
        and (vim.bo.filetype == "md" or vim.bo.filetype == "text" or vim.bo.filetype == "markdown")
    then
        local count = words_counter(1, vim.api.nvim_buf_line_count(0))

        return string.format(" %s %d ", icons.kind.Text, count)
    end

    return ""
end
-- }}}

-- wrap indicator {{{
local function wrap_indicator()
    if vim.wo.wrap then
        return " ✓ WRAP "
    end

    return " ✗ WRAP "
end
-- }}}

-- buffer count {{{
local function buffer_count()
    -- Get all listed buffers (not hidden, not temporary)
    local bufs = vim.api.nvim_list_bufs()
    local active_buffers = 0

    for _, buf_id in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf_id) and vim.bo[buf_id].buflisted then
            active_buffers = active_buffers + 1
        end
    end

    return string.format(" %s %d ", icons.ui.Files, active_buffers)
end
-- }}}

-- build statusline {{{
Statusline = {}

Statusline.active = function()
    if vim.bo.filetype == "NvimTree" or vim.bo.filetype == "alpha" then
        return ""
    end

    return table.concat({
        "%#Statusline#",
        recording_indicator(),
        update_mode_colors(),
        mode(),
        "%#Normal# ",
        filetype(),
        filepath(),
        filename(),
        flag(),
        "%=%#StatusLineExtra#",
        "%#Normal#",
        -- update_counter_color(),
        showcmd(),
        buffer_count(),
        wrap_indicator(),
        -- search_count(),
        word_count(),
        lineinfo(),
    })
end

function Statusline.inactive()
    return " %F"
end

function Statusline.short()
    return "%#StatusLineNC#   NvimTree"
    -- return ""
end
-- }}}

-- show statusline {{{
vim.api.nvim_exec(
    [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
  augroup END
]],
    false
)

-- }}}
