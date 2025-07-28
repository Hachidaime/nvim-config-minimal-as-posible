local M = {}

-- override highlight {{{
local function override_hl(key, value, groups)
    for _, group in ipairs(groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })

        if ok and hl then
            hl[key] = value
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end
-- }}}

-- keep highlight on colorscheme changed {{{
function M.keep_hl()
    -- Definisikan palet warna untuk tema gelap (cerah dan terang)
    local dark_mode_colors = {
        fg = "#282c34", -- Warna teks yang gelap agar kontras dengan latar cerah
        Normal = "#61afef", -- Biru cerah
        Insert = "#98c379", -- Hijau cerah
        Visual = "#c678dd", -- Ungu cerah (untuk Visual biasa)
        VisualLine = "#b48ead", -- Ungu kebiruan yang sedikit lebih kalem untuk Visual Line
        VisualBlock = "#8a7ba0", -- Ungu kebiruan yang lebih gelap untuk Visual Block
        Replace = "#e06c75", -- Merah cerah
        Select = "#d19a66", -- Oranye cerah
        CmdLine = "#56b6c2", -- Cyan cerah
        Terminal = "#abb2bf", -- Abu terang
    }

    -- Definisikan palet warna untuk tema terang (kalem dan monokrom)
    local light_mode_colors = {
        fg = "#4c566a", -- Warna teks abu (digunakan untuk foreground)
        Normal = "#cfe2f3", -- Biru pastel lembut
        Insert = "#d9ead3", -- Hijau pastel lembut
        Visual = "#ead1dc", -- Ungu pastel lembut
        VisualLine = "#c9daf8", -- Ungu kebiruan pastel yang sedikit lebih gelap
        VisualBlock = "#b3bfe6", -- Ungu kebiruan pastel yang lebih gelap
        Replace = "#f4cccc", -- Merah pastel lembut
        Select = "#fce5cd", -- Oranye pastel lembut
        CmdLine = "#cce5ff", -- Biru muda pastel
        Terminal = "#e0e0e0", -- Abu terang netral untuk terminal
    }

    -- Tentukan palet warna yang akan digunakan berdasarkan background Neovim
    local statusline_accents
    if vim.o.background == "dark" then
        statusline_accents = dark_mode_colors
    else -- Asumsi 'light' jika bukan 'dark'
        statusline_accents = light_mode_colors
    end

    for hl_suffix, bg_color in pairs(statusline_accents) do
        if hl_suffix ~= "fg" then
            vim.api.nvim_set_hl(0, "Statusline" .. hl_suffix, { fg = statusline_accents.fg, bg = bg_color })
        end
    end
    -- }}}

    -- skip colorscheme {{{
    local skip = {
        ["kanagawa-paper"] = true,
        ["kanagawa-paper-canvas"] = true,
        ["kanagawa-paper-ink"] = true,
    }

    if skip[vim.g.colors_name] then
        return
    end
    -- }}}

    -- override highlight {{{
    override_hl("bg", "NONE", {
        "SignColumn",
    })

    override_hl("fg", "brown", {
        "@markup.strong",
        "@markup.italic",
    })

    override_hl("bold", false, {
        "@markup.heading",
    })

    override_hl("italic", true, {
        "Comment",
    })
    -- }}}
end
-- }}}

return M
