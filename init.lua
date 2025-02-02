local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{
  "preservim/vim-markdown",
  ft = { "markdown", "python" },  -- Load only for these file types
  config = function()
    vim.g.vim_markdown_folding_disabled = 1   -- Optional: Disable markdown folding
    vim.g.vim_markdown_new_list_item_indent = 0  -- Optional: Fix list indentation
    vim.g.vim_markdown_math = 1
    vim.g.vim_markdown_frontmatter = 1
    vim.g.vim_markdown_strikethrough = 1
  end
},
  {'folke/tokyonight.nvim'},
  {'rafi/awesome-vim-colorschemes'},
  {"AlexvZyl/nordic.nvim"},
  {"rcarriga/nvim-notify"},
  {'nvim-lualine/lualine.nvim'},
  {'akinsho/bufferline.nvim'},
  {'goolord/alpha-nvim'},
  { 'echasnovski/mini.comment', version = '*' },
  { 'echasnovski/mini.pairs', version = '*' },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    }
  },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'}
    },
  },
  {
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
   {"onsails/lspkind.nvim"},
    {
  "hkupty/iron.nvim",
  config = function(plugins, opts)
    local iron = require("iron.core")

    iron.setup({
      config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
          python = {
            -- Can be a table or a function that
            -- returns a table (see below)
            command = { "python" },
          },
        },
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = require("iron.view").right(60),
      },
      -- Iron doesn't set keymaps by default anymore.
      -- You can set them here or manually add keymaps to the functions in iron.core
      keymaps = {
        send_motion = "<space>rc",
        visual_send = "<space>rc",
        send_file = "<space>rf",
        send_line = "<space>rl",
        send_mark = "<space>rm",
        mark_motion = "<space>rmc",
        mark_visual = "<space>rmc",
        remove_mark = "<space>rmd",
        cr = "<space>r<cr>",
        interrupt = "<space>r<space>",
        exit = "<space>rq",
        clear = "<space>rx",
      },
      -- If the highlight is on, you can change how it looks
      -- For the available options, check nvim_set_hl
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    })

    -- iron also has a list of commands, see :h iron-commands for all available commands
    vim.keymap.set("n", "<space>rs", "<cmd>IronRepl<cr>")
    vim.keymap.set("n", "<space>rr", "<cmd>IronRestart<cr>")
    vim.keymap.set("n", "<space>rF", "<cmd>IronFocus<cr>")
    vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
  end,
}
  }
)

require('mini.comment').setup()
require('mini.pairs').setup()

vim.opt.termguicolors = true
require("tokyonight").setup({
	style="storm",
	styles = {
	    -- Style to be applied to different syntax groups
	    -- Value is any valid attr-list value for `:help nvim_set_hl`
	    comments = { italic = false }
	}
})
vim.cmd.colorscheme('tokyonight')
require('notify').setup{
    background_colour = "NotifyBackground",
    fps = 30,
    icons = {
      DEBUG = "",
      ERROR = "",
      INFO = "",
      TRACE = "✎",
      WARN = ""
    },
    level = 2,
    minimum_width = 50,
    render = "default",
    stages = "static",
    timeout = 1000,
    top_down = true
  }
vim.notify = require("notify")
vim.wo.number = true

require('lualine').setup{
	options = {
          theme = "auto",
          globalstatus = true,
	  component_separators = { left = '', right = ''},
    	  section_separators = { left = '', right = ''},
        },
	sections = {
	  lualine_a = {"mode"},
	  lualine_b = {"filename"},
          lualine_c = {"diagnostics"},
		lualine_x = {},
	  lualine_y = {"location"},
	  lualine_z = {"progress"}
	}
}
require("bufferline").setup{}


local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').pylsp.setup{
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false }, -- Or true if you're a masochist
                pylint = { enabled = true },
                pyflakes = {enabled = true},
                pylsp_mypy = { enabled = true }
            }
        }
    }
}

local cmp = require('cmp')

local cmp_action = require('lsp-zero').cmp_action()
local lspkind = require('lspkind')

cmp.setup(

    {
      performance = {
        debounce = 10, -- Milliseconds to wait before showing completions
        throttle = 10, -- Limit how often requests are sent to LSP
        fetching_timeout = 100 -- Max time to wait for results
    },
    mapping = cmp.mapping.preset.insert({
      -- `Enter` key to confirm completion
      ['<CR>'] = cmp.mapping.confirm({select = false}),
    }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  }
})


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
"███╗   ███╗████████╗███████╗██╗   ██╗            ██████╗ ██╗   ██╗██╗     ███████╗███████╗",
"████╗ ████║╚══██╔══╝██╔════╝██║   ██║            ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝",
"██╔████╔██║   ██║   ███████╗██║   ██║            ██████╔╝██║   ██║██║     █████╗  ███████╗",
"██║╚██╔╝██║   ██║   ╚════██║██║   ██║            ██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║",
"██║ ╚═╝ ██║   ██║   ███████║╚██████╔╝            ██║  ██║╚██████╔╝███████╗███████╗███████║",
"╚═╝     ╚═╝   ╚═╝   ╚══════╝ ╚═════╝             ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝",
"                 (I'm not sure what to think now... I guess Vandy's cool)                 ",
}

local fortune = require("alpha.fortune")
dashboard.section.footer.val = fortune()
alpha.setup(dashboard.opts)

vim.o.shell = '"C:/Program Files/Git/bin/bash.exe"'
vim.opt.shellcmdflag = '-c'

-- https://www.reddit.com/r/neovim/comments/16ji91p/how_to_change_the_diagnostics_icons/
local symbols = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }

for name, icon in pairs(symbols) do
	local hl = "DiagnosticSign" .. name
	vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.py",
  callback = function()
    vim.cmd [[
      syntax include @Markdown syntax/markdown.vim
      syntax region markdownBlock start=/# %% \[markdown\]/ end=/$/ contains=@Markdown
    ]]
  end,
})
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>bm", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]  -- Get current line number
  vim.api.nvim_buf_set_lines(0, line, line, false, {
    "",
    "# %% [markdown]",
    "# ",
    ""
  })  -- Insert markdown cell
  vim.api.nvim_win_set_cursor(0, {line + 3, 4})  -- Move cursor inside the cell
  vim.cmd("startinsert")
end, { noremap = true, silent = true, desc = "Insert new markdown cell" })
vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.breakindent = true  -- Indents wrapped lines like continuation lines
