-- KEYMAPS ----------------------------------


-- leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- 在copy后高亮
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})


local km = vim.keymap

km.set("n", "<Leader>vs", "<C-w>v", opt)
km.set("n", "<Leader>vh", "<C-w>s", opt)
km.set("n", "<Leader>ww", "<C-w>w", opt)

-- vim.keymap.set("n", "<Leader>[", "<C-i>", opt)
-- vim.keymap.set("n", "<Leader>]", "<C-o>", opt)

-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
km.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
km.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

-- visual 模式单行多行移动 
km.set("v", "J", ":m '>+1<CR>gv=gv")
km.set("v", "K", ":m '<-2<CR>gv=gv")

--  取消高亮
km.set("n", "<Leader>nh", ":nohl<CR>")



-- OPTIONS ----------------------------------


vim.opt.backup = false
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"

vim.opt.showtabline = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.fileencoding = "utf-8"
vim.opt.autoread = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.clipboard:append("unnamedplus")

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.cursorline = true

vim.opt.mouse:append("a")

-- 根据文件类型来加载插件
vim.api.nvim_command(':filetype plugin on')


-- PLUGINS ----------------------------------



-- lazy plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({

    { -- start screen

        'goolord/alpha-nvim',
        config = function()
            require'alpha'.setup(require'alpha.themes.dashboard'.config)
        end
    },

    { -- themes

        'liuchengxu/space-vim-theme',
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins

        config = function()
            vim.g.space_vim_transp_bg = 1
            vim.cmd("colorscheme space_vim_theme")
        end
    }, 

    { -- which-key
        
        event = "VeryLazy",
        "folke/which-key.nvim",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },

    { -- Telescope

        'nvim-telescope/telescope.nvim',
        event = "VeryLazy",
        cmd = 'Telescope',
        dependencies = 'nvim-lua/plenary.nvim',
        keys = {
            { "<leader>ff", ":Telescope find_files<CR>", desc = "find files" },
            { "<leader>gf", ":Telescope live_grep<CR>", desc = "grep files" },
            { "<leader>rs", ":Telescope resume<CR>", desc = "resume" },
            { "<leader>ol", ":Telescope oldfiles<CR>", desc = "oldfiles" },
        }
    },
    
    { -- lazygit

        "kdheepak/lazygit.nvim",
        dependencies = "nvim-lua/plenary.nvim",

        keys = {
            { "<leader>lz", ":LazyGit<CR>", desc = "LazyGit" }
        }
    },

    { -- toggleterm

        'akinsho/toggleterm.nvim',
        event = "VeryLazy",
        config = function()
            -- keybindings
            vim.keymap.set('n', '<leader>tt', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', {noremap = true, silent = true}, opts)
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)

            require("toggleterm").setup({})
        end
    },

    { -- indent-blankline

        "lukas-reineke/indent-blankline.nvim",
        config = function()
            vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
            vim.g.indent_blankline_filetype_exclude = {
                "help",
                "startify",
                "dashboard",
                "packer",
                "neogitstatus",
                "NvimTree",
                "Trouble",
            }
            vim.g.indentLine_enabled = 1
            -- vim.g.indent_blankline_char = "│"
            vim.g.indent_blankline_char = "▏"
            -- vim.g.indent_blankline_char = "▎"
            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_first_indent_level = true
            vim.g.indent_blankline_use_treesitter = true
            vim.g.indent_blankline_show_current_context = true
            vim.g.indent_blankline_context_patterns = {
                "class",
                "return",
                "function",
                "method",
                "^if",
                "^while",
                "jsx_element",
                "^for",
                "^object",
                "^table",
                "block",
                "arguments",
                "if_statement",
                "else_clause",
                "jsx_element",
                "jsx_self_closing_element",
                "try_statement",
                "catch_clause",
                "import_statement",
                "operation_type",
            }
            -- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
            vim.wo.colorcolumn = "99999"

            -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]]
            -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]]
            -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
            -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]]
            -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]]
            -- vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
            -- vim.opt.list = true
            -- vim.opt.listchars:append "space:⋅"
            -- vim.opt.listchars:append "space:"
            -- vim.opt.listchars:append "eol:↴"

            require("indent_blankline").setup({

                -- show_end_of_line = true,
                -- space_char_blankline = " ",
                show_current_context = true,
                -- show_current_context_start = true,
                -- char_highlight_list = {
                --   "IndentBlanklineIndent1",
                --   "IndentBlanklineIndent2",
                --   "IndentBlanklineIndent3",
                -- },
            })
        end
    },
    
    { -- todo-comments

        "folke/todo-comments.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        opts = {
            signs = true, -- show icons in the signs column
            sign_priority = 8, -- sign priority
            -- keywords recognized as todo comments
            keywords = {
                FIX = {
                    icon = " ", -- icon used for the sign, and in search results
                    color = "error", -- can be a hex color, or a named color (see below)
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                    -- signs = false, -- configure signs for some keywords individually
                },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            gui_style = {
                fg = "NONE", -- The gui style to use for the fg highlight group.
                bg = "BOLD", -- The gui style to use for the bg highlight group.
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
                multiline = true, -- enable multine todo comments
                multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
                multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
                before = "", -- "fg" or "bg" or empty
                keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                after = "fg", -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
                comments_only = true, -- uses treesitter to match keywords in comments only
                max_line_len = 400, -- ignore lines longer than this
                exclude = {}, -- list of file types to exclude highlighting
            },

            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" }
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
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            },
        }
    },

    { -- lualine

        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()

            local hide_in_width = function()
                return vim.fn.winwidth(0) > 80
            end

            local diagnostics = {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                sections = { "error", "warn" },
                symbols = { error = " ", warn = " " },
                colored = false,
                update_in_insert = false,
                always_visible = true,
            }

            local diff = {
                "diff",
                colored = true,
                symbols = { added = "  ", modified = " ", removed = " " },
                diff_color = {
                    added = { fg = "#98be65" },
                    modified = { fg = "#ecbe7b" },
                    removed = { fg = "#ec5f67" },
                },
                cond = hide_in_width
            }

            local mode = {
                "mode",
                fmt = function(str)
                    return "-- " .. str .. " --"
                end
            }


            local file_name = {
                'filename',
                file_status = true, -- Displays file status (readonly status, modified status)
                path = 1, -- 0: Just the filename
                -- 1: Relative path
                -- 2: Absolute path

                shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                -- for other components. (terrible name, any suggestions?)
                symbols = {
                    modified = '[+]', -- Text to show when the file is modified.
                    readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
                    unnamed = '[No Name]', -- Text to show for unnamed buffers.
                },
            }

            local filetype = {
                "filetype",
                icons_enabled = false,
                icon = nil,
            }

            local branch = {
                "branch",
                icons_enabled = true,
                icon = "",
            }

            local location = {
                "location",
                padding = 0,
            }

            -- cool function for progress
            local progress = function()
                local current_line = vim.fn.line(".")
                local total_lines = vim.fn.line("$")
                -- local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
                local chars = { "██", "▇▇", "▆▆", "▅▅", "▄▄", "▃▃", "▂▂", "▁▁", " ", }
                local line_ratio = current_line / total_lines
                local index = math.ceil(line_ratio * #chars)
                return chars[index]
            end

            local spaces = function()
                return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
            end

            -- add gps module to get the position information
            -- local gps = require("nvim-gps")

            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    -- component_separators = { left = "", right = "" },
                    -- section_separators = { left = "", right = "" },
                    disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = { branch, diagnostics },
                    lualine_b = { mode },
                    lualine_c = { file_name },
                    lualine_x = { diff, spaces, "encoding", filetype, "fileformat" },
                    lualine_y = { location },
                    lualine_z = { progress },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { file_name },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
                extensions = {},
            })
        end
    },

    { -- trouble

        "folke/trouble.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("trouble").setup({
                position = "bottom", -- position of the list can be: bottom, top, left, right
                height = 10, -- height of the trouble list when position is top or bottom
                width = 50, -- width of the list when position is left or right
                icons = true, -- use devicons for filenames
                mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
                fold_open = "", -- icon used for open folds
                action_keys = {
                fold_closed = "", -- icon used for closed folds
                    -- key mappings for actions in the trouble list
                    -- map to {} to remove a mapping, for example:
                    -- close = {},
                    close = "q", -- close the list
                    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
                    refresh = "r", -- manually refresh
                    jump = { "o", "<tab>" }, -- jump to the diagnostic or open / close folds
                    open_split = { "<c-x>" }, -- open buffer in new split
                    open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
                    open_tab = { "<c-t>" }, -- open buffer in new tab
                    jump_close = { "<cr>" }, -- jump to the diagnostic and close the list
                    toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
                    toggle_preview = "p", -- toggle auto_preview
                    hover = "K", -- opens a small popup with the full multiline message
                    preview = "P", -- preview the diagnostic location
                    close_folds = { "zM", "zm" }, -- close all folds
                    open_folds = { "zR", "zr" }, -- open all folds
                    toggle_fold = { "zA", "zo", "zc" }, -- toggle fold of current file
                    previous = "k", -- preview item
                    next = "j", -- next item
                },
                indent_lines = true, -- add an indent guide below the fold icons
                auto_open = false, -- automatically open the list when you have diagnostics
                auto_close = true, -- automatically close the list when you have no diagnostics
                auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
                auto_fold = false, -- automatically fold a file trouble list at creation
                signs = {
                    -- icons / text used for a diagnostic
                    error = "",
                    warning = "",
                    hint = "",
                    information = "",
                    other = "﫠",
                },
                use_lsp_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
            })
        end
    },


    { -- null-ls

        "jose-elias-alvarez/null-ls.nvim",
        dependencies = 'nvim-lua/plenary.nvim',

        config = function()
            local nl = require("null-ls")
            local sources = {
                nl.builtins.diagnostics.clang_check,
                nl.builtins.formatting.clang_format,
            }
            nl.setup({
                sources = sources,
                on_attach = on_attach,
            })
        end
    },


    { -- gitsigns

        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup {
                signs = {
                    add          = { text = '│' },
                    change       = { text = '│' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                    untracked    = { text = '┆' },
                },
                signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
                numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
                linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir = {
                    interval = 1000,
                    follow_files = true
                },
                attach_to_untracked = true,
                current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                    delay = 1000,
                    ignore_whitespace = false,
                },
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil, -- Use default
                max_file_length = 40000, -- Disable if file is longer than this (in lines)
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = 'single',
                    style = 'minimal',
                    relative = 'cursor',
                    row = 0,
                    col = 1
                },
                yadm = {
                    enable = false
                },
            }
        end
    },

    { -- nvim tree

        event = "VeryLazy",
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-tree").setup{}
        end,
        keys = {
            { "<leader>nn", ":NvimTreeToggle<CR>", desc = "nvim tree toggle" },
        }
    },

    { -- bufferline

        'akinsho/bufferline.nvim',
        version = "*",
        lazy = false,
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers", -- set to "tabs" to only show tabpages instead
                    numbers = "ordinal", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
                    --- @deprecated, please specify numbers as a function to customize the styling
                    -- number_style = "superscript", --| "subscript" | "" | { "none", "subscript" }, -- buffer_id at index 1, ordinal at index 2
                    close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
                    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
                    left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
                    middle_mouse_command = nil,          -- can be a string | function, see "Mouse actions"
                    -- NOTE: this plugin is designed with this icon in mind,
                    -- and so changing this is NOT recommended, this is intended
                    -- as an escape hatch for people who cannot bear it for whatever reason
                    indicator_icon = '▎',
                    buffer_close_icon = '',
                    modified_icon = '●',
                    close_icon = '',
                    left_trunc_marker = '',
                    right_trunc_marker = '',
                    --- name_formatter can be used to change the buffer's label in the bufferline.
                    --- Please note some names can/will break the
                    --- bufferline so use this at your discretion knowing that it has
                    --- some limitations that will *NOT* be fixed.
                    name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
                        -- remove extension from markdown files for example
                        if buf.name:match('%.md') then
                            return vim.fn.fnamemodify(buf.name, ':t:r')
                        end
                    end,
                    max_name_length = 18,
                    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                    tab_size = 18,
                    diagnostics = false, --| "nvim_lsp" | "coc",
                    diagnostics_update_in_insert = false,
                    diagnostics_indicator = function(count, level, diagnostics_dict, context)
                        return "("..count..")"
                    end,
                    -- NOTE: this will be called a lot so don't do any heavy processing here
                    custom_filter = function(buf_number, buf_numbers)
                        -- filter out filetypes you don't want to see
                        if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                            return true
                        end
                        -- filter out by buffer name
                        if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                            return true
                        end
                        -- filter out based on arbitrary rules
                        -- e.g. filter out vim wiki buffer from tabline in your work repo
                        if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                            return true
                        end
                        -- filter out by it's index number in list (don't show first buffer)
                        if buf_numbers[1] ~= buf_number then
                            return true
                        end
                    end,
                    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align="center"}}, -- | function , text_align = "left" | "center" | "right",
                    show_buffer_icons = true, --| false, -- disable filetype icons for buffers
                    show_buffer_close_icons = true, --| false,
                    show_close_icon = true, --| false,
                    show_tab_indicators = true, -- | false,
                    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
                    -- can also be a table containing 2 custom separators
                    -- [focused and unfocused]. eg: { '|', '|' }
                    separator_style = "thin", --| "slant" | "thick" | "thin" | { 'any', 'any' },
                    enforce_regular_tabs = false, --| true,
                    always_show_bufferline = true, -- | false,
                    sort_by =  'directory',  -- ,'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                }
            })
	    end,

	    keys = {
            { "<leader>rr", ":BufferLineCycleNext<CR>", desc = "next buffer" },
            { "<leader>ll", ":BufferLineCyclePrev<CR>", desc = "prev buffer" },
	    }
    },

    { -- nvim-autopairs

        'windwp/nvim-autopairs',
        config = function()
            local rule = require('nvim-autopairs.rule')
            local status_ok, npairs = pcall(require, 'nvim-autopairs')
        
            if not status_ok then
                vim.notify("auto-paris don't exists")
                return
            end
        
            require('nvim-autopairs').setup({
                check_ts = true,
                ts_config = {
                    lua = {'string'},-- it will not add a pair on that treesitter node
                    javascript = {'template_string'},
                },
                fast_wrap = {
                    map = '<m-e>',
                    chars = { '{', '[', '(', '"', "'" },
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
                    end_key = '$',
                    keys = 'qwertyuiopzxcvbnmasdfghjkl',
                    check_comma = true,
                    highlight = 'pmenusel',
                    highlight_grey='linenr'
                },
                disable_filetype = { "telescopeprompt" },
            })
        
            -- if you want insert `(` after select function or method item
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
        end
    },


    { -- nvim-lspconfig

        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = "p00f/clangd_extensions.nvim",

        config = function()
            local lspconfig = require("lspconfig")

            -- basic diagnostic config
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = true,
                severity_sort = false,
            })

            -- show symbols in line column
            local signs = { error = " ", warn = " ", hint = " ", info = " " }
            for type, icon in pairs(signs) do
                local hl = "diagnosticsign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- mappings.
            -- see `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap=true, silent=true }
            vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
            vim.api.nvim_set_keymap('n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
            vim.api.nvim_set_keymap('n', ']g', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
            vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)

            -- use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
                -- enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- mappings.
                -- see `:help vim.lsp.*` for documentation on any of the below functions
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>f', '<cmd>lua vim.lsp.buf.formatting_sync()<cr>', opts)
            end

            -- nvim-cmp supports additional completion capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            servers = { 'clangd' }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup {
                    on_attach = on_attach,
                        flags = {
                            -- this will be the default in neovim 0.7+
                            debounce_text_changes = 100,
                        },
                    capabilities = capabilities
                }
            end

            ---- clangd extensions config
            local clangdext = require("clangd_extensions")

            -- use clangd extensions to init clangd lsp
            clangdext.setup {
                server = {
                    -- options to pass to nvim-lspconfig
                    -- i.e. the arguments to require("lspconfig").clangd.setup({})
                    on_attach = on_attach,
                    flags = {
                        -- this will be the default in neovim 0.7+
                        debounce_text_changes = 100,
                    },
                    capabilities = capabilities
                },
                extensions = {
                    -- defaults:
                    -- automatically set inlay hints (type hints)
                    autosethints = true,
                    -- whether to show hover actions inside the hover window
                    -- this overrides the default hover handler
                    hover_with_actions = true,
                    -- these apply to the default clangdsetinlayhints command
                    inlay_hints = {
                        -- only show inlay hints for the current line
                        only_current_line = false,
                        -- event which triggers a refersh of the inlay hints.
                        -- you can make this "cursormoved" or "cursormoved,cursormovedi" but
                        -- not that this may cause  higher cpu usage.
                        -- this option is only respected when only_current_line and
                        -- autosethints both are true.
                        only_current_line_autocmd = "cursorhold",
                        -- whether to show parameter hints with the inlay hints or not
                        show_parameter_hints = false,
                        -- prefix for parameter hints
                        parameter_hints_prefix = "<- ",
                        -- prefix for all the other hints (type, chaining)
                        other_hints_prefix = "=> ",
                        -- whether to align to the length of the longest line in the file
                        max_len_align = false,
                        -- padding from the left if max_len_align is true
                        max_len_align_padding = 1,
                        -- whether to align to the extreme right or not
                        right_align = true,
                        -- padding from the right if right_align is true
                        right_align_padding = 7,
                        -- the color of the hints
                        highlight = "comment",
                        -- the highlight group priority for extmark
                        priority = 100,
                    },
                    ast = {
                        role_icons = {
                            type = "",
                            declaration = "",
                            expression = "",
                            specifier = "",
                            statement = "",
                            ["template argument"] = "",
                        },

                        kind_icons = {
                            compound = "",
                            recovery = "",
                            translationunit = "",
                            packexpansion = "",
                            templatetypeparm = "",
                            templatetemplateparm = "",
                            templateparamobject = "",
                        },

                        highlights = {
                            detail = "comment",
                        },
                        memory_usage = {
                            border = "none",
                        },
                        symbol_info = {
                            border = "none",
                        },
                    },
                }
            }
        end,
    }, 

    { -- nvim-treesitter

        'nvim-treesitter/nvim-treesitter',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "lua", "cpp", "cmake", "markdown", "javascript", "rust" },

                sync_install = true,
                auto_install = true,

                highlight = {
                      enable = true,

                      -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to

                      -- list of language that will be disabled
                      disable = { },

                      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                      -- Using this option may slow down your editor, and you may see some duplicate highlights.
                      -- Instead of true it can also be a list of languages
                      additional_vim_regex_highlighting = false,
                },
            }
        end
    },

    { -- Luasnip

        "L3MON4D3/Luasnip",
        dependencies = "rafamadriz/friendly-snippets",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },

    { -- nvim-cmp
        
        'hrsh7th/nvim-cmp',
        event = "insertenter",
        dependencies = {
            -- snippets
            "L3MON4D3/Luasnip",
            
            -- cmp
            'hrsh7th/cmp-nvim-lua',
            "petertriho/cmp-git",
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lsp-document-symbol',
            "hrsh7th/cmp-cmdline",
            'saadparwaiz1/cmp_luasnip',
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
        },

        config = function()
            vim.cmd [[set completeopt=menu,menuone,noselect]]

            -- setup nvim-cmp.
            local cmp = require('cmp')
            local luasnip = require("luasnip")

            local has_words_before = function()
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local kind_icons = {
                Text = "",
                Method = "",
                Function = "",
                Constructor = "",
                Field = "",
                Variable = "",
                Class = "ﴯ",
                Interface = "",
                Module = "",
                Property = "ﰠ",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = ""
            }

            cmp.setup({
                snippet = {
                    -- required - you must specify a snippet engine
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- for `luasnip` users.
                    end,
                },

                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- accept currently selected item. set `select` to `false` to only confirm explicitly selected items.
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

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

                sources = cmp.config.sources(
                    {
                        { name = 'nvim_lsp_document_symbol' },
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' }, -- for luasnip users.
                    }, 
                    {
                        { name = 'buffer' },
                        { name = 'nvim_lsp_signature_help' },
                        { name = 'path'},
                    }
                ),

                formatting = {
                format = function(entry, vim_item)
                  -- kind icons
                  vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- this concatonates the icons with the name of the item kind
                  -- source
                  vim_item.menu = ({
                    buffer = "[Buffer]",
                    nvim_lsp = "[Lsp]",
                    luasnip = "[Luasnip]",
                    nvim_lua = "[Lua]",
                    latex_symbols = "[Latex]",
                  })[entry.source.name]
                  return vim_item
                end
              },
              sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.recently_used,
                        require("clangd_extensions.cmp_scores"),
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
            })

            -- set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'cmp_git' }, -- you can specify the `cmp_git` source if you were installed it.
                }, {
                    { name = 'buffer' },
                })
            })

            -- use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    },

    { -- coderunner

        "CRAG666/code_runner.nvim",
        config = function()
            vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
            vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })
            require('code_runner').setup({
                filetype = {
                    java = {
                        "cd $dir &&",
                        "javac $fileName &&",
                        "java $fileNameWithoutExt"
                    },
                    python = "python -u",
                    rust = {
                        "cd $dir &&",
                        "rustc $fileName &&",
                        "$dir/$fileNameWithoutExt"
                    },
                    cpp = {
                        "cd $dir &&",
                        "clang++ -std=c++2a -Wall $fileName -o $fileNameWithoutExt &&",
                        "$dir/$fileNameWithoutExt"
                    },
                    c = {
                        "cd $dir &&",
                        "clang $fileName -o $fileNameWithoutExt -lpthread -Wall -std=c17 &&",
                        "$dir/$fileNameWithoutExt" 
                    },
                }
            })
        end
    },

}, {})
