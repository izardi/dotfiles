-- OPTIONS ----------------------------------

local op = vim.opt

op.showmode = false

op.backup = false
op.hlsearch = true
op.ignorecase = true
op.smartcase = true
op.signcolumn = "yes"

op.showtabline = 2
op.smartindent = true
op.autoindent = true
op.expandtab = true
op.shiftwidth = 4
op.tabstop = 4

op.fileencoding = "utf-8"
op.autoread = true

op.number = true
op.relativenumber = true
op.numberwidth = 4
op.clipboard:append("unnamedplus")

op.splitbelow = true
op.splitright = true

op.termguicolors = true
op.background = "dark"
op.cursorline = true

op.mouse:append("a")



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



-- PLUGINS ----------------------------------

-- 根据文件类型来加载插件
vim.api.nvim_command(':filetype plugin on')


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
        event = "VimEnter",
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
        config = function()
            require("toggleterm").setup({})
        end,
        keys = {
            {'<leader>tt', '<Cmd>exe v:count1 . "ToggleTerm"<CR>'},
        }
    },

    { -- indent-blankline

        "lukas-reineke/indent-blankline.nvim",
        lazy = false,
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
      cmd = { "TodoTrouble", "TodoTelescope" },
      event = { "BufReadPost", "BufNewFile" },
      config = true,
      -- stylua: ignore
      keys = {
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
        { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
        { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
        { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
        { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
      },
    },

    { -- lualine

        'nvim-lualine/lualine.nvim',
        lazy = false,
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

            local opts = {silent = true, noremap = true}
            vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
            vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)
            vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", opts);
            vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", opts)
            vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", opts);
            vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", opts);

            require("trouble").setup({})
        end
    },


    { -- null-ls

        "jose-elias-alvarez/null-ls.nvim",
        event = "InsertEnter",
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
        event = { "BufReadPre", "BufNewFile" },
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

        "nvim-tree/nvim-tree.lua",
        cmd = "Neotree",
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
        event = "VeryLazy",
        config = function()
            require("bufferline").setup({
                options = {
                    modified_icon = '●',
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(count, level)
                        local icon = level:match("error") and " " or ""
                        return " " .. icon .. count
                    end,
                }
            })
	    end,
	    keys = {
            { "<leader>br", ":BufferLineCycleNext<CR>", desc = "next buffer" },
            { "<leader>bl", ":BufferLineCyclePrev<CR>", desc = "prev buffer" },
	    }
    },

    { -- nvim-autopairs

        'windwp/nvim-autopairs',
        event = "InsertEnter",
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
        event = { "BufReadPre", "BufNewFile" },

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

            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('UserLspConfig', {}),
              callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<leader>wl', function()
                  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<leader>f', function()
                  vim.lsp.buf.format { async = true }
                end, opts)
              end,
            })

            lspconfig.clangd.setup({
                cmd = {
                    "clangd",
                    "-j=4",
                    "--background-index",
                    "--clang-tidy",
                    "--fallback-style=llvm",
                    "--all-scopes-completion",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--header-insertion-decorators",
                    "--pch-storage=memory",
                }
            })
        end
    }, 

    { -- nvim-treesitter

        'nvim-treesitter/nvim-treesitter',
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSUpdateSync" },
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "lua", "cpp", "cmake", "markdown", "javascript", "rust" },

                sync_install = true,
                auto_install = true,

                highlight = {
                      enable = true,
                      disable = { },
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
        event = "InsertEnter",
        dependencies = {
            { "onsails/lspkind-nvim" }, -- 为补全添加类似 vscode 的图标
			{ "hrsh7th/vim-vsnip" }, -- vsnip 引擎，用于获得代码片段支持
			{ "hrsh7th/cmp-vsnip" }, -- 适用于 vsnip 的代码片段源
			{ "hrsh7th/cmp-nvim-lsp" }, -- 替换内置 omnifunc，获得更多补全
			{ "hrsh7th/cmp-path" }, -- 路径补全
			{ "hrsh7th/cmp-buffer" }, -- 缓冲区补全
			{ "hrsh7th/cmp-cmdline" }, -- 命令补全
			{ "f3fora/cmp-spell" }, -- 拼写建议
			{ "rafamadriz/friendly-snippets" }, -- 提供多种语言的代码片段
			{ "lukas-reineke/cmp-under-comparator" }, -- 让补全结果的排序更加智能}}
        },

        config = function()
            local lspkind = require("lspkind")
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                -- 补全源的排序
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                    { name = "path" },
                    { name = "buffer" },
                    { name = "cmdline" },
                    { name = "spell" },
                }),
                -- 格式化补全菜单
                formatting = {
                    format = lspkind.cmp_format({
                        with_text = true,
                        maxwidth = 50,
                        before = function(entry, vim_item)
                            vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
                            return vim_item
                        end,
                    }),
                },
                -- 对补全建议排序
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        require("cmp-under-comparator").under,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                -- 补全相关的按键
                mapping = {

                    -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    -- 选择下一个
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<Up>"] = cmp.mapping.select_prev_item(),
                    ["<Down>"] = cmp.mapping.select_next_item(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
                },
            })

            -- vim的"/"命令模式提示
            cmp.setup.cmdline({ "/", "?" }, {
                sources = {
                    { name = "buffer" },
                },
            })
            -- vim的":"命令模式提示
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
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
}, 
{
  defaults = {
    lazy = true, -- should plugins be lazy-loaded?
  }
})
