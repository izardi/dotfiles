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
        event = "VimEnter",
        -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins

        config = function()
            vim.g.space_vim_transp_bg = 1
            vim.cmd("colorscheme space_vim_theme")
        end
    }, 

    { -- which-key
        
        "folke/which-key.nvim",
        event = "VeryLazy",
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
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]])

            require("toggleterm").setup({})
        end,
        keys = {
            {'<leader>tt', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', {noremap = true, silent = true}},
            {'<leader>tt', '<Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>', 'i', {noremap = true, silent = true}}
        }
    },

    { -- indent-blankline

        "lukas-reineke/indent-blankline.nvim",
        lazy = false,
        config = function()
            vim.g.indent_blankline_char_list = {'|', '¦', '┆', '┊'}
            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_first_indent_level = true
            vim.g.indent_blankline_use_treesitter = true
            vim.g.indent_blankline_show_current_context = true
            require("indent_blankline").setup({
                show_end_of_line = true,
                show_current_context = true,
            })
        end
    },
    
    { -- todo-comments

        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufNewFile" },
        config = true,
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
        event = "VeryLazy",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("lualine").setup({
                sections = {
                    lualine_b = {
                        {"branch"},
                        {
                            'diff',
                            colored = true,
                            symbols = {added = ' ', modified = ' ', removed = ' '}, -- Changes the symbols used by the diff.
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            sections = { "error", "warn" },
                            symbols = { error = " ", warn = " " },
                            colored = true,
                            update_in_insert = true,
                            always_visible = true,
                        },
                    }
                }
            })
        end
    },

    { -- trouble

        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostic_signs = true },
        keys = {
            { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
            { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
            {
                "[q",
                function()
                  if require("trouble").is_open() then
                    require("trouble").previous({ skip_groups = true, jump = true })
                  else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                      vim.notify(err, vim.log.levels.ERROR)
                    end
                  end
                end,
                desc = "Previous trouble/quickfix item",
            },
            {
                "]q",
                function()
                  if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true })
                  else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                      vim.notify(err, vim.log.levels.ERROR)
                    end
                  end
                end,
                desc = "Next trouble/quickfix item",
            },
        },
    },

    { -- gitsigns

        'lewis6991/gitsigns.nvim',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require('gitsigns').setup();
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
                underline = true,
                update_in_insert = true,
                severity_sort = true,

                virtual_text = {
                    spacing = 8,
                    prefix = "",
                }
            })

            -- show symbols in line column
            local signs = { Error = "❌", Warn = "⚠️", Hint = "💡", Info = "ℹ️" }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float)
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
                    vim.keymap.set('n', '<leader>fm', function()
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
                    "--clang-tidy-checks=\"clang-analyzer-*,cppcoreguidelines-*,modernize-*,performance-*,readability-*,bugprone-*\"",
                    "--fallback-style=llvm",
                    "--all-scopes-completion",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--header-insertion-decorators",
                    "--pch-storage=memory",
                },
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

    { -- LuaSnip

        "L3MON4D3/LuaSnip",
        build = (not jit.os:find("Windows"))
            and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
          or nil,
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
        opts = {
          history = true,
          delete_check_events = "TextChanged",
        },
        keys = {
            {
              "<tab>",
              function()
                return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
              end,
              expr = true, silent = true, mode = "i",
            },
            { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
	},

    { -- nvim-cmp

        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            "petertriho/cmp-git",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "saadparwaiz1/cmp_luasnip",
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
                Array = " ",
                Boolean = " ",
                Class = " ",
                Color = " ",
                Constant = " ",
                Constructor = " ",
                Copilot = " ",
                Enum = " ",
                EnumMember = " ",
                Event = " ",
                Field = " ",
                File = " ",
                Folder = " ",
                Function = " ",
                Interface = " ",
                Key = " ",
                Keyword = " ",
                Method = " ",
                Module = " ",
                Namespace = " ",
                Null = " ",
                Number = " ",
                Object = " ",
                Operator = " ",
                Package = " ",
                Property = " ",
                Reference = " ",
                Snippet = " ",
                String = " ",
                Struct = " ",
                Text = " ",
                TypeParameter = " ",
                Unit = " ",
                Value = " ",
                Variable = " ",
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
}, 
{
    defaults = {
        lazy = true, -- should plugins be lazy-loaded?
    }
})
