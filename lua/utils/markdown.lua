local M = {}

-- heading level {{{
function M.heading_level(level)
    local curpos = vim.fn.getcurpos()
    local current_line_num = curpos[2] -- Baris saat ini (indeks 2 dari array curpos)
    local current_line_content = vim.api.nvim_buf_get_lines(0, current_line_num - 1, current_line_num, false)[1]

    -- Periksa apakah baris saat ini dimulai dengan '#'
    if
        (level == "demote" or level == "promote")
        and (current_line_content and not current_line_content:match("^#"))
    then
        vim.fn.search("^#", "bW")
    end

    local commands = {
        demote = "s/^#/##/",
        demote_all = "%s/^#/##/",
        promote = "s/^#//",
        promote_all = "%s/^#//",
    }

    if commands[level] then
        vim.cmd(commands[level])
    end

    vim.cmd("noh")
    vim.fn.setpos(".", curpos)
end
-- }}}

-- clear heading formatting {{{
function M.clear_heading_formatting()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    for i, line in ipairs(lines) do
        if line:match("^%s*#+") then
            lines[i] = line:gsub("%*%*", ""):gsub("%*", ""):gsub("_", "")
        end
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end
-- }}}

-- set status {{{
function M.set_status(name)
    local patterns = {
        new = "★",
        finished = "✓",
        working = "▷",
        todo = "",
        ready = "⊚",
    }

    local list = {}
    for key, value in pairs(patterns) do
        table.insert(list, value)
    end

    vim.cmd("g/^# /s/\\(" .. table.concat(list, "\\|") .. "\\)/" .. patterns[name] .. "/")
    vim.cmd("noh")
end
-- }}}

-- jump to separator {{{
function M.jump_separator(flag)
    local flags = {
        next = "W",
        prev = "bW",
    }

    local separators = { "---", "★★★", "◆◆◆", "≪ ◆◇◆ ≫" }

    if vim.fn.search("\\v(" .. table.concat(separators, "|") .. ")", flags[flag]) == 0 then
        vim.notify("No more separator to jump", vim.log.levels.INFO)
    end
end
-- }}}

-- fix non-standard characters {{{
function M.fix_character()
    local curpos = vim.fn.getcurpos()

    local replacements = {
        {
            pattern = "%s/\\.\\.\\./…/g",
            error_msg = 'Error replacing "..." with "…"',
        },
        { pattern = '%s/“/"/g', error_msg = 'Error replacing “ with "' },
        { pattern = '%s/”/"/g', error_msg = 'Error replacing ” with "' },
        { pattern = "%s/‘/'/g", error_msg = "Error replacing ‘ with '" },
        { pattern = "%s/’/'/g", error_msg = "Error replacing ’ with '" },
    }

    for _, rep in ipairs(replacements) do
        if not pcall(vim.cmd, rep.pattern) then
            vim.notify(rep.error_msg, vim.log.levels.ERROR)
        end
    end

    vim.cmd("noh")
    vim.fn.setpos(".", curpos)
end
-- }}}

-- wrap below cursor {{{
function M.wrap_all_below()
    local curpos = vim.fn.getcurpos()

    if not pcall(vim.api.nvim_exec, "normal! " .. curpos[2] + 1 .. "ggVGgw", false) then
        vim.notify("Error wrapping", vim.log.levels.ERROR)
    end

    vim.cmd("noh")

    vim.fn.setpos(".", curpos)
end
-- }}}

-- wrap all paragraphs {{{
function M.wrap_all_paragraphs()
    local curpos = vim.fn.getcurpos() -- Simpan posisi kursor awal

    -- Dapatkan semua baris dari buffer saat ini
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local num_lines = #lines

    for i = 1, num_lines do
        local line_content = lines[i]
        local line_num_vim = i -- Baris Vimscript berbasis 1

        -- Pengecualian
        local is_heading = line_content:match("^#+")
        local is_title_line = line_content:match("^title:")
        local is_weight_line = line_content:match("^weight:")
        local is_separator = line_content:match("^%s*---%s*$")

        if not (is_heading or is_title_line or is_weight_line or is_separator) then
            -- Hanya jika baris bukan pengecualian, coba wrap paragrafnya
            -- Kita akan melompat ke baris tersebut, bungkus paragrafnya, lalu melanjutkan
            -- Menggunakan :normal! agar gw beroperasi pada paragraf di baris tersebut
            pcall(vim.cmd, string.format("%dnormal! Va}gw", line_num_vim))
        end
    end

    vim.cmd("noh") -- Hapus highlight
    vim.fn.setpos(".", curpos) -- Kembali ke posisi kursor semula
    vim.notify("Finished wrapping paragraphs.", vim.log.levels.INFO)
end
-- }}}

-- one line paragraphs {{{
function M.one_line_paragraphs()
    local curpos = vim.fn.getcurpos()

    vim.cmd(curpos[2] + 1 .. ",$normal! vipJ")
    vim.cmd("noh")

    vim.fn.setpos(".", curpos)
end
-- }}}

-- toggle checkbox {{{
function M.toggle_checkbox()
    local line = vim.api.nvim_get_current_line()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local col = curpos[2]

    if line:find("^%s*%- %[x%]") then -- If checked, uncheck it
        line = line:gsub("^%s*%- %[x%]", "- [ ]")
    elseif line:find("^%s*%- %[ %]") then -- If unchecked, check it
        line = line:gsub("^%s*%- %[ %]", "- [x]")
    elseif line:find("^%s*%-%s") then -- If unordered list, convert to unchecked checkbox
        line = line:gsub("^%s*%-%s", "- [ ] ")
    else -- Add a checkbox to the line
        line = "- [ ] " .. line
    end

    vim.api.nvim_set_current_line(line) -- Update the line
    vim.api.nvim_win_set_cursor(0, { curpos[1], math.min(col, #line) }) -- Preserve cursor position
end
-- }}}

-- remove checkbox {{{
function M.remove_checkbox()
    local line = vim.api.nvim_get_current_line()
    local curpos = vim.api.nvim_win_get_cursor(0)
    local col = curpos[2]

    if line:find("^%s*%- %[x%]") then -- If checked, uncheck it
        line = line:gsub("^%s*%- %[x%]", "-")
    elseif line:find("^%s*%- %[ %]") then -- If unchecked, check it
        line = line:gsub("^%s*%- %[ %]", "-")
    end

    vim.api.nvim_set_current_line(line) -- Update the line
    vim.api.nvim_win_set_cursor(0, { curpos[1], math.min(col, #line) }) -- Preserve cursor position
end
-- }}}

-- clean spacing hyphen {{{
-- Akan membersihkan spasi di sekitar tanda hubung pada seleksi visual atau baris saat ini
function M.apply_clean_spacing_around_hyphen()
    local curpos = vim.fn.getcurpos()

    vim.cmd("%s/\\(\\S\\)\\ -\\(\\S\\)/\\1-\\2/g")
    vim.cmd("noh")

    vim.fn.setpos(".", curpos)
end
-- }}}
return M
