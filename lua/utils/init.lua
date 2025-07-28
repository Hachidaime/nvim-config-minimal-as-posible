local M = {}

-- map {{{
function M.map(mode, lhs, rhs, extra)
    local opts = { silent = true, noremap = true }

    if extra then
        opts = vim.tbl_extend("force", extra, opts)
    end

    vim.keymap.set(mode, lhs, rhs, opts)
end
-- }}}

-- folding {{{
function M.toggle_fold()
    if vim.fn.foldlevel(vim.fn.line(".")) == 0 then
        vim.notify("No fold found", vim.log.levels.INFO)
        return
    end

    vim.cmd("normal! za")
end
-- }}}

-- todo-comments {{{
local tags = {
    "ASK",
    "BUG",
    "FAILED",
    "FIX",
    "HACK",
    "INFO",
    "ISSUE",
    "MARK",
    "NOTE",
    "OPTIM",
    "PASSED",
    "PERF",
    "TEST",
    "TODO",
    "WARN",
    "XXX",
}

-- cycle tag
function M.cycle_tag()
    local current_line = vim.api.nvim_get_current_line()
    local new_line = current_line

    for i, tag in ipairs(tags) do
        if current_line:match(tag) then
            local next_tag = tags[(i % #tags) + 1]

            new_line = current_line:gsub(tag, next_tag, 1)
            break
        end
    end

    if new_line ~= current_line then
        vim.api.nvim_set_current_line(new_line)
    end
end

-- set tag
function M.set_tag(new_tag)
    local current_line = vim.api.nvim_get_current_line()
    local updated = false

    for _, tag in ipairs(tags) do
        if current_line:match(tag) then
            current_line = current_line:gsub(tag, new_tag:upper(), 1)
            updated = true
            break
        end
    end

    if not updated then
        current_line = new_tag:upper() .. ": " .. current_line
    end

    vim.api.nvim_set_current_line(current_line)
end
-- }}}

-- telescope {{{
function M.telescope_map(maps)
    for key, map_info in pairs(maps) do
        local command_suffix = map_info[1]
        local theme = map_info[2]
        local description = map_info[3]

        local telescope_cmd = "Telescope " .. command_suffix
        if theme then
            telescope_cmd = telescope_cmd .. " theme=" .. theme
        end

        M.map("n", "<leader>f" .. key, function()
            vim.cmd(telescope_cmd) -- Execute the constructed Telescope command
        end, { desc = description })
    end
end
-- }}}

-- lazy {{{
function M.lazy_map(maps)
    for key, map_info in pairs(maps) do
        local command_suffix = map_info[1]
        local description = map_info[2]

        M.map("n", "<leader>p" .. key, function()
            vim.cmd("Lazy " .. command_suffix)
        end, { desc = description })
    end
end
-- }}}

-- set comment tag {{{
function M.comment_tag_map(maps)
    for key, tag_name in pairs(maps) do
        local description = string.upper(tag_name) -- Convert tag name to uppercase for description

        M.map("n", "<leader>t" .. key, function()
            require("utils").set_tag(tag_name)
        end, { desc = description })
    end
end
-- }}}

-- set tabstop {{{
function M.set_tab(value)
    vim.cmd("set tabstop=" .. value)
    vim.cmd("set shiftwidth=" .. value)
end
-- }}}

-- format {{{
function M.format()
    print(vim.bo.filetype)
    local formatters = {
        lua = "stylua",
        markdown = "prettier --write",
        json = "prettier --write",
        python = "black",
    }

    vim.cmd("write")
    vim.cmd("silent !" .. formatters[vim.bo.filetype] .. " %")
end
-- }}}
return M
