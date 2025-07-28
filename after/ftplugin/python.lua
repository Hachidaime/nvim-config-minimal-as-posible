-- options {{{
vim.opt_local.number = true
vim.opt_local.relativenumber = true
vim.opt_local.shiftwidth = 4
-- }}}

-- keybindings {{{
local map = require("utils").map

-- formatting {{{
map("n", "<leader>uf", "<CMD>lua require('utils').format()<CR>", { desc = "Format", buffer = true })
-- }}}
-- }}}
