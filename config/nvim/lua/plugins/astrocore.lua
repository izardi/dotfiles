-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        ["<Leader>tr"] = {
          function()
            vim.cmd "w"
            local filename = vim.fn.expand "%:t:r" -- 获取当前文件名（无扩展名）
            local filepath = vim.fn.expand "%:p" -- 获取完整路径
            local cmd = string.format(
              "clang++ -std=c++26 -stdlib=libc++ -Wall -pedantic -fsanitize=address -g %s -o %s && ./%s",
              filepath,
              filename,
              filename
            )
            -- require("toggleterm").exec(cmd, 1, 10, "float")  -- 在浮动终端中运行
            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new { cmd = cmd, direction = "float", close_on_exit = false }
            term:toggle() -- 打开终端
          end,
          desc = "Compile & Run C++",
        },

        ["<Leader>tc"] = {
          function()
            vim.cmd "w"
            local cmd = string.format "cmake --build build --parallel && ./build/app"
            -- 提示：将 `your_executable_name` 替换为实际生成的可执行文件名
            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new { cmd = cmd, direction = "float", close_on_exit = false }
            term:toggle()
          end,
          desc = "CMake Build & Run",
        },

        ["<Leader>tp"] = {
          function()
            vim.cmd "w" -- 保存当前文件
            local filepath = vim.fn.expand "%:p" -- 获取完整路径
            local cmd = string.format("python %s", filepath)

            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new { cmd = cmd, direction = "float", close_on_exit = false }
            term:toggle() -- 打开终端
          end,
          desc = "Run Python File",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
