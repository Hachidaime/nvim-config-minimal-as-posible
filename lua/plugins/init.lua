return {
	-- core {{{
	{
		"nvim-lua/plenary.nvim",
	},
	{
		enabled = false,
		"dstein64/vim-startuptime",
		-- event = "StartupTime",
	},
	-- }}}
  -- ui {{{
	-- dressing {{{
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
	},
	-- }}}
	-- stay centered {{{
	{
		{
			"arnamak/stay-centered.nvim",
			event = "BufReadPost",
			opts = function()
				require("stay-centered").setup({
					enabled = false,
					-- Add any configurations here, like skip_filetypes if needed
					skip_filetypes = { "lua", "typescript", "NvimTree", "alpha" },
				})
			end,
		},
	},
	-- }}}
	-- outline {{{
	{
		"hedyhli/outline.nvim",
		lazy = true,
		cmd = { "Outline", "OutlineOpen" },
		keys = { -- Example mapping to toggle outline
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
		},
		opts = {
			-- Your setup opts here
			outline_window = {
				width = 25,
				relative_width = true,
				show_numbers = true,
				show_relative_numbers = true,
				-- wrap = true,
				-- hide_cursor = true,
			},
			guides = {
				markers = {
					bottom = "╰",
					middle = "├",
					vertical = "│",
				},
			},
			symbol_folding = {
				-- markers = { "", "" },
				markers = { "", "󰍷" },
			},
			preview_window = {
				auto_preview = false,
			},
		},
	},
	-- }}}
	-- noice {{{
	{
		"folke/noice.nvim",
		enabled = false,
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			local noice = require("noice")

			noice.setup({
				cmdline = {
					format = {
						cmdline = {
							pattern = "^:",
							icon = "󰅂▁",
							lang = "vim",
						},
						search_down = {
							view = "cmdline",
						},
						search_up = {
							view = "cmdline",
						},
					},
				},
				routes = {
					{
						filter = {
							event = "notify",
							min_height = 15,
						},
						view = "split",
					},
					{
						filter = {
							event = "msg_show",
							kind = "",
							find = "written",
						},
						opts = { skip = true },
					},
					{
						filter = {
							event = "msg_show",
							min_height = 15,
						},
						view = "split",
					},
				},
				views = {
					cmdline_popup = {
						position = {
							row = 10,
							col = "50%",
						},
						size = {
							width = 60,
							height = "auto",
						},
					},
					confirm = {
						position = {
							row = 3,
							col = "50%",
						},
						size = {
							width = 80,
							height = "auto",
						},
					},
					popupmenu = {
						relative = "editor",
						position = {
							row = 13,
							col = "50%",
						},
						size = {
							width = 60,
							height = 10,
						},
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
						win_options = {
							winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
						},
					},
				},
			})
		end,
	},
	-- }}}
  -- }}}
  -- syntax {{{
	-- treesitter {{{
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				indent = { enable = true },
				autotag = { enable = true },
				ensure_installed = {
					-- "json",
					-- "javascript",
					-- "typescript",
					-- "yaml",
					"html",
					"css",
					"markdown",
					"markdown_inline",
					-- "bash",
					"lua",
					"norg",
					-- "vim",
					-- "gitignore",
					-- "vimdoc",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})
		end,
	},
	-- }}}
	-- vim markdown {{{
	{
		"plasticboy/vim-markdown",
		branch = "master",
		ft = "markdown",
		-- require = {'godlygeek/tabular'},
    config = function()
      vim.cmd([[
      let g:vim_markdown_auto_insert_bullets = 0
      let g:vim_markdown_new_list_item_indent = 0
      ]])
    end
	},
	-- }}}
  -- }}}
  -- editing {{{
	-- comment {{{
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		init = function()
			require("Comment").setup({
				pre_hook = function(ctx)
					local U = require("Comment.utils")

					local status_utils_ok, utils = pcall(require, "ts_context_commentstring.utils")
					if not status_utils_ok then
						return
					end

					local location = nil
					if ctx.ctype == U.ctype.block then
						location = utils.get_cursor_location()
					elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
						location = utils.get_visual_start_location()
					end

					local status_internals_ok, internals = pcall(require, "ts_context_commentstring.internals")
					if not status_internals_ok then
						return
					end

					return internals.calculate_commentstring({
						key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
						location = location,
					})
				end,
				ignore = "^$",
			})
		end,
	},
  -- }}}
  -- todo comments {{{
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		init = function()
			require("todo-comments").setup({
				signs = true, -- show icons in the signs column
				sign_priority = 8, -- sign priority
				keywords = {
					FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
					TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
					MARK = { icon = " ", color = "default" },
					ASK = { icon = "", color = "info" },
				},
				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},
				merge_keywords = true,
				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 10,
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true,
					max_line_len = 400,
					exclude = {},
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
					test = { "Identifier", "#FF00FF" },
				},
				search = {
					command = "rg",
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
					pattern = [[\b(KEYWORDS):]],
				},
			})
		end,
	},
	-- }}}
	-- surround {{{
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require("nvim-surround").setup({
				aliases = {
					["p"] = ")",
					["b"] = "**",
				},
				surrounds = {
					-- Remap parentheses to "p" instead of "b"
					-- ["p"] = require("nvim-surround.config").get_surround(")"),
					["p"] = {
						add = { "(", ")" },
						find = "%b()",
						delete = "^(%()().-(%))()$",
					},
					-- Custom surround for bold text in Markdown
					["b"] = {
						add = function()
							return { "**", "**" }
						end,
						find = "%*%*.-%*%*", -- Finds text surrounded by `**`
						delete = "^(%*%*)().-(%*%*)()$", -- Deletes `**` on both sides
					},
					-- Custom surround for italic text in Markdown
					["i"] = {
						add = function()
							return { "_", "_" }
						end,
						find = "%_.-%_", -- Finds text surrounded by `_`
						delete = "^(%_)().-(%_)()$", -- Deletes `_` on both sides
					},
				},
			})
		end,
	},
	-- }}}
  -- }}}
  -- file & navigation {{{
	-- telescope {{{
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons",
			"folke/todo-comments.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				-- defaults {{{
				defaults = {
					vimgrep_arguments = {
						"rg",
						"-L",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--sort=path",
					},
					prompt_prefix = "   ",
					selection_caret = " ",
					entry_prefix = "  ",
					initial_mode = "insert",
					selection_strategy = "reset",
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					file_ignore_patterns = { "node_modules", "themes", ".git" },
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					path_display = { "smart" },
					winblend = 0,
					border = {},
					-- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					color_devicons = true,
					set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
					-- Developer configurations: Not meant for general override
					buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
					mappings = {
						n = { ["q"] = require("telescope.actions").close },
					},
				},
				-- }}}
				-- extensions {{{
				extensions_list = { "themes", "terms" },
				-- }}}
				-- pickers {{{
				pickers = {
					find_files = {
						hidden = true,
					},
					live_grep = {
						--@usage don't include the filename in the search results
						only_sort_text = true,
					},
					grep_string = {
						only_sort_text = true,
					},
					buffers = {
            previewer = false,
						initial_mode = "normal",
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer,
							},
							n = {
								["dd"] = actions.delete_buffer,
							},
						},
					},
					planets = {
						show_pluto = true,
						show_moon = true,
					},
					git_files = {
						hidden = true,
						show_untracked = true,
					},
					colorscheme = {
						enable_preview = true,
					},
				},
				-- }}}
				-- mappings {{{
				mappings = {
					i = {
						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,

						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,

						["<C-c>"] = actions.close,

						["<Down>"] = actions.move_selection_next,
						["<Up>"] = actions.move_selection_previous,

						["<CR>"] = actions.select_default,
						["<C-x>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-t>"] = actions.select_tab,

						["<C-u>"] = actions.preview_scrolling_up,
						["<C-d>"] = actions.preview_scrolling_down,

						["<PageUp>"] = actions.results_scrolling_up,
						["<PageDown>"] = actions.results_scrolling_down,

						["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
						["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
						["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
						["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-l>"] = actions.complete_tag,
						["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
					},

					n = {
						["<esc>"] = actions.close,
						["<CR>"] = actions.select_default,
						["<C-x>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-t>"] = actions.select_tab,

						["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
						["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
						["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
						["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

						["j"] = actions.move_selection_next,
						["k"] = actions.move_selection_previous,
						["H"] = actions.move_to_top,
						["M"] = actions.move_to_middle,
						["L"] = actions.move_to_bottom,

						["<Down>"] = actions.move_selection_next,
						["<Up>"] = actions.move_selection_previous,
						["gg"] = actions.move_to_top,
						["G"] = actions.move_to_bottom,

						["<C-u>"] = actions.preview_scrolling_up,
						["<C-d>"] = actions.preview_scrolling_down,

						["<PageUp>"] = actions.results_scrolling_up,
						["<PageDown>"] = actions.results_scrolling_down,

						["?"] = actions.which_key,
					},
				},
				-- }}}
			})
			-- TODO: fzf sorting
		end,
	},
	-- }}}
	-- explorer {{{
	{
		"kyazdani42/nvim-tree.lua",
		dependencies = "kyazdani42/nvim-web-devicons",
		cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
		config = function()
			local icons = require("ui.icons")
			local nvimtree = require("nvim-tree")
			local api = require("nvim-tree.api")

			-- on attach {{{
			-- edit or open
			local function edit_or_open()
				local node = api.tree.get_node_under_cursor()

				if node.nodes ~= nil then
					-- expand or collapse folder
					api.node.open.edit()
				else
					-- open file
					api.node.open.edit()
					-- Close the tree if file was opened
					api.tree.close()
				end
			end

			-- open as vsplit on current node
			local function vsplit_preview()
				local node = api.tree.get_node_under_cursor()

				if node.nodes ~= nil then
					-- expand or collapse folder
					api.node.open.edit()
				else
					-- open file as vsplit
					api.node.open.vertical()
				end

				-- Finally refocus on tree if it was lost
				api.tree.focus()
			end

			local function my_on_attach(bufnr)
				-- local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- custom mappings
				vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
				vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
				vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
				-- vim.keymap.set("n", "h", api.tree.close, opts("Close"))
				vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Collapse"))
				-- vim.keymap.set("n", "<C-h>", api.tree.collapse_all, opts("Collapse All"))
			end
			-- }}}

			-- setup {{{
			nvimtree.setup({
				on_attach = my_on_attach,
				select_prompts = true,
				sort = {
					sorter = "name",
					folders_first = true,
					files_first = false,
				},
				view = {
					cursorline = true,
					-- hide_root_folder = false,
					-- side = "right",
					side = "left",
					number = true,
					relativenumber = true,
					-- width = 40,
					width = {
						min = 40,
					},
				},
				renderer = {
					root_folder_modifier = ":t",
					highlight_opened_files = "name",
					symlink_destination = false,
					indent_markers = {
						enable = true,
						inline_arrows = true,
						icons = {
							corner = "┗",
							edge = "┃",
							item = "┃",
							bottom = "━",
							none = " ",
						},
					},
					icons = {
						web_devicons = {
							file = {
								enable = true,
								color = true,
							},
							folder = {
								enable = false,
								color = true,
							},
						},
						symlink_arrow = " ➛ ",
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = false,
							diagnostics = true,
							modified = true,
						},
						glyphs = {
							default = icons.ui.Text,
							symlink = icons.ui.FileSymlink,
							folder = {
								-- arrow_closed = icons.ui.ChevronShortDown,
								-- arrow_open = icons.ui.ChevronShortRight,
								arrow_closed = icons.ui.SquarePlus,
								arrow_open = icons.ui.SquareMinus,
								default = icons.ui.Folder,
								open = icons.ui.FolderOpen,
								empty = icons.ui.EmptyFolder,
								empty_open = icons.ui.EmptyFolderOpen,
								symlink = icons.ui.FolderSymlink,
								symlink_open = icons.ui.FolderSymlink,
							},
							git = {
								deleted = icons.git.FileDeleted,
								ignored = icons.git.FileIgnored,
								renamed = icons.git.FileRenamed,
								staged = icons.git.FileStaged,
								unmerged = icons.git.FileUnmerged,
								unstaged = icons.git.FileUnstaged,
								untracked = icons.git.FileUntracked,
							},
						},
					},
				},
				diagnostics = {
					enable = false,
					show_on_dirs = false,
					show_on_open_dirs = true,
					debounce_delay = 50,
					severity = {
						min = vim.diagnostic.severity.HINT,
						max = vim.diagnostic.severity.ERROR,
					},
					icons = {
						hint = "",
						info = "",
						warning = "",
						error = "",
					},
				},
				-- disable window_picker for
				-- explorer to work well with
				-- window splits
				actions = {
					open_file = {
						window_picker = {
							enable = false,
						},
					},
				},
				filters = {
					dotfiles = true,
					-- custom = { "_index.md", "vx*" },
				},
				git = {
					ignore = false,
				},
			})
			-- }}}
		end,
	},
	-- }}}
  -- }}}
  -- keybinding {{{
	-- which-key {{{
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500

			local wk = require("which-key")
			local icons = require("ui.icons")

			-- setup {{{
			wk.setup({
				preset = "helix",
				spec = {
					{
						mode = { "n" },
						{ "<leader>b", desc = "Buffer", nowait = true, remap = false },
						{ "<leader>t", desc = "Comments tag", nowait = true, remap = false },
						{ "<leader>f", desc = "Find", nowait = true, remap = false },
						{ "<leader>p", desc = "Plugins", nowait = true, remap = false },
						{ "<leader>s", desc = "Split Window", nowait = true, remap = false },
						{ "<leader>u", desc = "User", nowait = true, remap = false },
						{ "<leader>ut", desc = "Tab", nowait = true, remap = false },
					},
					-- {
					-- 	mode = { "n", "v" },
					-- 	{ "<leader>m", desc = "Markdown", nowait = true, remap = false },
					-- 	{ "<leader>ms", desc = "Status", nowait = true, remap = false },
					-- 	{ "<leader>mh", desc = "Heading", nowait = true, remap = false },
					-- },
				},
				icons = {
					mappings = false,
					breadcrumb = icons.ui.ChevronRight, -- symbol used in the command line area that shows your active key combo
					separator = icons.ui.BoldArrowRight, -- symbol used between a key and it's label
					group = icons.ui.BigPlus .. " ", -- symbol prepended to a group
				},
				win = {
					padding = { 1, 1 },
					height = { min = 5, max = 26 },
				},
				show_help = true,
			})
			-- }}}

      -- mapping {{{
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown", -- Apply only to markdown file type
				callback = function()
					wk.add({
						mode = { "n", "v" },
						{ "<leader>m", group = "Markdown", nowait = true, remap = false },
						{ "<leader>mc", desc = "Clean", nowait = true, remap = false },
						{ "<leader>ms", desc = "Status", nowait = true, remap = false },
						{ "<leader>mh", desc = "Heading", nowait = true, remap = false },
					})
				end,
			})
      -- }}}
		end,
		-- opts = {
		-- 	-- TODO: fix prefix
		-- },
	},
	-- }}}
  -- }}}
	-- autocompletion {{{
  -- nvim-cmp {{{
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		-- event = "BufWinEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			{
				"L3MON4D3/LuaSnip",
			},
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local new_kind_icon = require("ui.icons")

			require("luasnip/loaders/from_vscode").lazy_load()

			local lpath = vim.fn.stdpath("config") .. "/my-snippets"
			require("luasnip.loaders.from_vscode").lazy_load({ paths = lpath .. "/snippets" })

			local check_backspace = function()
				local col = vim.fn.col(".") - 1
				return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
			end

			cmp.setup({
				-- completion {{{
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				-- }}}
				-- snippet {{{
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				-- }}}
				-- mapping {{{
				mapping = cmp.mapping.preset.insert({
					["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable,
					["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expandable() then
							luasnip.expand()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif check_backspace() then
							fallback()
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				-- }}}
				-- formatting {{{
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind = string.format("%s", new_kind_icon["kind"][vim_item.kind])
						vim_item.menu = ({
							nvim_lsp = "(LSP)",
							luasnip = "(Snippet)",
							buffer = "(Buffer)",
							path = "(Path)",
						})[entry.source.name]
						return vim_item
					end,
				},
				-- }}}
				-- sources for autocompletion {{{
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
				}),
				-- }}}
				-- window {{{
				window = {
					completion = {
						-- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						-- border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
						border = nil,
					},
					documentation = {
						-- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						-- border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
						-- border = { "╒", "═", "╕", "│", "┘", "─", "└", "│" },
						border = nil,
					},
				},
				-- }}}
			})
		end,
	},
  -- }}}
	-- }}}
  -- colorschemes {{{
	-- catppuccin {{{
	{
		"catppuccin/nvim",
		enabled = false,
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "latte",
				background = {
					light = "latte",
					dark = "macchiato",
				},
				transparent_background = false,
				show_end_of_buffer = false,
				term_colors = false,
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},
				no_italic = false,
				no_bold = false,
				no_underline = false,
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
				},
				color_overrides = {
					latte = {
						base = "#faf4ed",
					},
				},
				default_integrations = false,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = false,
					treesitter = true,
					notify = false,
					indent_blankline = {
						enabled = false,
						scope_color = "lavender",
						colored_indent_levels = false,
					},
					mini = {
						enabled = false,
						indentscope_color = "",
					},
					render_markdown = false,
					telescope = {
						enabled = false,
					},
					which_key = false,
				},
			})
		end,
	},
	-- }}}
	-- kanagawa-paper {{{
	{
		"thesimonho/kanagawa-paper.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		-- init = function()
		config = function()
			require("kanagawa-paper").setup({
				overrides = function(colors)
					return {
						["@markup.italic"] = { fg = colors.palette.canvasOrange, italic = true },
						["@markup.strong"] = { fg = colors.palette.canvasOrange, bold = true },
					}
				end,
			})

			vim.cmd.colorscheme("kanagawa-paper")
		end,
		opts = {},
	},
	-- }}}
	-- nightfox {{{
	{
		"EdenEast/nightfox.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		config = function()
			local groups = {
				all = {
					["@markup.italic"] = { fg = "palette.red", style = "italic" },
				},
			}

			local nightfox = require("nightfox")
			nightfox.setup({
				options = {
					styles = {
						comments = "italic",
						keywords = "italic",
						types = "italic,bold",
					},
					transparent = false,
				},
				groups = groups,
			})
		end,
	},
	-- }}}
	-- rose pine {{{
	{
		"rose-pine/neovim",
		enabled = false,
		lazy = false,
		priority = 1000,
		config = function()
			local rose_pine = require("rose-pine")
			rose_pine.setup({
				variant = "dawn",
			})
		end,
	},
	-- }}}
  -- }}}
	-- disabled {{{
	-- alpha {{{
	{
		"goolord/alpha-nvim",
		enabled = false,
		lazy = false,
		event = "VimEnter",
		config = function() end,
	},
	-- }}}
	-- render-markdown {{{
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
		-- event = "BufRead",
		ft = "markdown",
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"kyazdani42/nvim-web-devicons",
		}, -- if you prefer nvim-web-devicons
		opts = function() end,
	},
	-- }}}
  -- norg {{{
  {
	"nvim-neorg/neorg",
  enabled = false,
	lazy = false, 
  ft = "neorg",
	version = "*", 
	dependencies = {
		"nvim-neorg/lua-utils.nvim",
		"pysan3/pathlib.nvim",
	},
	config = function(_, _)
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {}, 
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Documents/dataa-workplace/notes/notes/",
							tracker = "~/Documents/dataa-workplace/notes/tracker/",
							work = "~/Documents/dataa-workplace/notes/work/",
						},
						default_workspace = "tracker",
					},
				},
				["core.keybinds"] = {},
				["core.summary"] = {},
				["core.syntax"] = {},
				["core.tempus"] = {},
			},
		})
	end,
  },
  -- }}}
	-- }}}
}
