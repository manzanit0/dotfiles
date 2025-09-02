---@diagnostic disable: undefined-global

if vim.g.vscode then
  return
end

-- encoding
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

-- timeouts
vim.o.ttyfast = true    -- we have a fast terminal
vim.o.ttimeout = true   --time out for key codes
vim.o.ttimeoutlen = 100 -- wait up to 100ms after Esc for special key
vim.o.lazyredraw = true

-- safety net
vim.o.undofile = true  -- store undos on disk
vim.o.updatetime = 300 -- flush swap files to disk on a regular basis

-- search and replace
vim.o.showmatch = true                                                         -- sm: flashes matching brackets or parentheses
vim.o.hlsearch = true                                                          -- Highlights the areas that you search for.
vim.o.incsearch = true                                                         --Searches incrementally as you type.
vim.o.ignorecase = true                                                        -- ignore case when searching
vim.o.smartcase = true                                                         -- smarter search case
vim.o.wildignorecase = true                                                    -- ignore case in file completion
vim.o.wildignore = ""                                                          -- remove default ignores
vim.o.wildignore = vim.o.wildignore .. "*.o,*.obj,*.so,*.a,*.dylib,*.pyc,*.hi" -- ignore compiled files
vim.o.wildignore = vim.o.wildignore .. "*.zip,*.gz,*.xz,*.tar,*.rar"           -- ignore compressed files
vim.o.wildignore = vim.o.wildignore .. "*/.git/*,*/.hg/*,*/.svn/*"             -- ignore SCM files
vim.o.wildignore = vim.o.wildignore .. "*.png,*.jpg,*.jpeg,*.gif"              -- ignore image files
vim.o.wildignore = vim.o.wildignore .. "*.pdf,*.dmg"                           -- ignore binary files
vim.o.wildignore = vim.o.wildignore .. ".*.sw*,*~"                             -- ignore editor files
vim.o.wildignore = vim.o.wildignore .. ".DS_Store"                             -- ignore OS files

-- folding
-- https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldenable = true
vim.o.foldcolumn = "0" -- don't take extra room telling me how many lines are folded
vim.o.foldtext = ""
vim.o.foldlevel = 99
-- vim.o.foldnestmax = 1
-- vim.o.foldlevelstart = 0

vim.g.nosmartindent = true
vim.o.autoindent = true
vim.o.cursorline = true


-- spacing
vim.o.backspace = "indent,eol,start"
vim.o.laststatus = 2    -- Shows the current status of the file.
vim.o.expandtab = true  -- Replaces a <TAB> with spaces
vim.o.shiftwidth = 2    -- The amount to block indent when using < and >
vim.o.shiftround = true -- Shift to the next round tab stop
vim.o.tabstop = 2       -- 2 space tab
vim.o.softtabstop = 2   -- Causes backspace to delete 2 spaces = converted <TAB>
vim.o.smarttab = true   -- Uses shiftwidth instead of tabstop at start of lines

-- numbers in the side
vim.o.nu = true
vim.o.number = true
vim.o.numberwidth = 5

-- copy&paste works with the system too.
-- @see https://vim.fandom.com/wiki/Accessing_the_system_clipboard
vim.o.clipboard = "unnamedplus" -- In case of Linux
-- set clipboard=unnamed " This would be for OSx.

-- when scrolling off-screen do so 3 lines at a time, not 1
vim.o.scrolloff = 3

-- open new split panes to right and bottom, which feels more natural
vim.o.splitbelow = true
vim.o.splitright = true

-- vim.o.diffopt = vim.o.diffopt .. "vertical"

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- tpope/vim-unimpaired uses '[' and ']', however, they're not too comfortable on my
-- layout. '<' and '>' are much better.
vim.cmd [[
  nmap < [
  nmap > ]
  omap < [
  omap > ]
  xmap < [
  xmap > ]
]]

-- In case you use :terminal, bring back ESC.
vim.cmd [[ tnoremap <Esc> <C-\><C-n> ]]

vim.cmd [[
  function! ToggleQuickFix()
  if getqflist({'winid':0}).winid
  cclose
  else
  copen
  endif
  endfunction

  command! -nargs=0 -bar ToggleQuickFix call ToggleQuickFix()
  nnoremap <silent> cq :ToggleQuickFix<CR>
]]

vim.cmd([[
  autocmd BufNewFile,BufRead *.Jenkinsfile set filetype=groovy
]])

vim.cmd [[ autocmd BufRead Tiltfile set filetype=tiltfile ]]
vim.cmd [[ au FileType tiltfile set syntax=starlark ]]

vim.api.nvim_create_user_command("PrView", function()
  vim.fn.system("gh pr view --web")
end, { desc = "Open current PR in web browser" })

vim.api.nvim_create_user_command("PrCreate", function()
  vim.fn.system("wk pr --draft")
end, { desc = "Push branch and create a PR in draft mode" })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- mappings
for _, mapping in ipairs({
  -- save current buffer
  { "n", "<cr>",       "<cmd>w<cr>" },
  -- better `j` and `k`
  { "n", "j",          "gj" },
  { "v", "j",          "gj" },
  { "n", "k",          "gk" },
  { "v", "k",          "gk" },
  -- copy from the cursor to the end of line using Y (matches D behavior)
  { "n", "Y",          "y$" },
  -- keep the cursor in place while joining lines
  { "n", "J",          "mZJ`Z" },
  -- reselect visual block after indent
  { "v", "<",          "<gv" },
  { "v", ">",          ">gv" },
  -- clean screen and reload file
  { "n", "<c-l>",      "<cmd>nohl<cr>:redraw<cr>:checktime<cr><c-l>gjgk" },
  -- emulate permanent global marks
  { "n", "<leader>nc", "<cmd>edit ~/.config/nvim/init.lua<cr>" },
  -- absolute path (/something/src/foo.txt)
  { "n", "<leader>cF", ":let @+=expand(\"%:p\")<CR>" },
  -- relative path
  { "n", "<leader>cf", ":let @+=expand(\"%\")<CR>" },
  -- keep the cursor in place while joining lines
  { "n", "J",          "mZJ`Z" },
  { "n", "<leader>qq", ":qa!<CR>" },
}) do
  vim.keymap.set(mapping[1], mapping[2], mapping[3], { noremap = true, silent = true })
end

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- " Highlights with a small shadow all code surpassing 80 characters.
-- highlight OverLength ctermbg=red ctermfg=white guibg=#592929
-- match OverLength /\%81v.\+/

-- enable ayu?
-- vim.cmd([[
--   let ayucolor="mirage"
--   colorscheme ayu
-- ]])

vim.o.termguicolors = true

vim.loader.enable()

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- {
  --   'projekt0n/github-nvim-theme',
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require('github-theme').setup({})
  --     vim.cmd('colorscheme github_dark')
  --   end,
  -- },
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "tpope/vim-rhubarb",
  "yasuhiroki/github-actions-yaml.vim",
  "onsails/lspkind.nvim",
  "stevearc/dressing.nvim",
  'rhysd/conflict-marker.vim',
  'kosayoda/nvim-lightbulb',
  "neovim/nvim-lspconfig",
  "j-hui/fidget.nvim", -- TODO: this isn't working any more since 0.11 lsp migration
  'projekt0n/github-nvim-theme',
  "romainl/Apprentice",
  "ayu-theme/ayu-vim",
  'Joorem/vim-haproxy',
  {
    dir = "~/repositories/manzanit0/k8s-whisper.nvim",
    config = function()
      require('k8s-whisper').setup({
        -- This is a GitHub repository
        schemas_catalog = 'datreeio/CRDs-catalog',
        -- This is a git ref, branch, tag, sha, etc.
        schema_catalog_ref = 'main',
      })
    end
  },
  {
    "mason-org/mason.nvim",
    config = function()
      require('mason').setup()
    end
  },
  {
    'kaiuri/nvim-juliana',
    opts = {},
    config = true,
  },
  {
    "vim-test/vim-test",
    config = function()
      vim.keymap.set("n", "<leader>te", "<cmd>TestNearest<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>Te", "<cmd>TestFile<CR>", { noremap = true, silent = true })
    end
  },
  {
    'numToStr/Comment.nvim',
    opts = {}
  },
  {
    "s1n7ax/nvim-terminal",
    -- lazy = true,          -- not using much these days
    config = function()
      vim.o.hidden = true -- this is needed to be set to reuse terminal between toggles
      require('nvim-terminal').setup({
        toggle_keymap = '<C-,>',
        increase_height_keymap = '<leader>t=',
        decrease_height_keymap = '<leader>t-',
        window_height_change_amount = 25,
      })
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",              -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

      vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "-", "<cmd>Neotree reveal<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "\\", "<cmd>Neotree toggle current reveal_force_cwd<cr>",
        { noremap = true, silent = true })

      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          position = "right",
        },
        filesystem = {
          hijack_netrw_behavior = "open_default",
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              ".git",
            },
          },
          window = {
            mappings = {
              ["h"] = "toggle_hidden",
            }
          },
        }
      })
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- don't use this, it's more annoying than anything else.
      -- 'jonarrien/telescope-cmdline.nvim',
    },
    config = function()
      local builtin = require('telescope.builtin')
      local arena = require("arena")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      -- vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fb", arena.toggle, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      local trouble = require("trouble.sources.telescope")
      local telescope = require("telescope")
      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
          },
        },
        pickers = {
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      }

      -- require('telescope').load_extension('fzf')
    end
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "simrat39/symbols-outline.nvim",
    opts = {},
    config = function()
      vim.keymap.set("n", "<leader>m", "<cmd>SymbolsOutline<cr>", { noremap = true, silent = true })
    end
  },
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<Leader>gs", "<cmd>Git<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gpu", "<cmd>Git push<cr>", { desc = "Git push" })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local gitlinker = require("gitlinker")
      gitlinker.setup({ mappings = nil })

      vim.keymap.set("n", "<leader>gb", "", {
        silent = true,
        desc = "browse repo in browser",
        callback = function()
          gitlinker.get_repo_url({
            action_callback = gitlinker.actions.open_in_browser
          })
        end
      })

      vim.keymap.set({ "n", "v" }, "<leader>gl", "", {
        silent = true,
        desc = "get git permlink",
        callback = function()
          local mode = string.lower(vim.fn.mode())
          gitlinker.get_buf_range_url(mode)
        end,
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function(_, opts)
      -- Prefer git instead of curl in order to improve connectivity in some environments
      -- require('nvim-treesitter.install').prefer_git = true

      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc',
          "proto",
          "lua",
          "bash",
          "yaml", "json",
          "go", "gomod", "gowork",
          "dockerfile", "hcl", "terraform",
          "gotmpl", "helm",
          "elixir",
          "starlark",
          "javascript", "typescript"
        },
        -- auto_install = true,
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })

      vim.treesitter.language.register("starlark", "tiltfile")

      vim.filetype.add({
        extension = {
          gotmpl = 'gotmpl',
        },
        pattern = {
          [".*/templates/.*%.tpl"] = "helm",
          [".*/templates/.*%.ya?ml"] = "helm",
          ["helmfile.*%.ya?ml"] = "helm",
        },
      })
    end,
  },
  {
    "aznhe21/actions-preview.nvim",
    config = function()
      vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)
    end,
  },
  {
    'akinsho/flutter-tools.nvim',
    opts = {},
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
  },
  {
    "natecraddock/workspaces.nvim",
    config = function()
      require("workspaces").setup()
      require("telescope").load_extension('workspaces')

      vim.keymap.set("n", "<leader>dw", "<cmd>Telescope workspaces<CR>",
        { noremap = true, silent = true })
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
    "dlants/magenta.nvim",
    lazy = false, -- you could also bind to <leader>mt
    build = "npm install --frozen-lockfile",
    opts = {},
  },
  {
    "quolpr/quicktest.nvim",
    config = function()
      local qt = require("quicktest")

      qt.setup({
        adapters = {
          require("quicktest.adapters.golang")({}),
          -- The pytest adapter uses local tools, which doesn't work if we're using something like poetry.
          require("quicktest_adapter_poetry")({}),
          -- require("quicktest.adapters.pytest")({
          -- require("quicktest.adapters.vitest")({}),
          -- require("quicktest.adapters.playwright")({}),
          -- require("quicktest.adapters.elixir"),
          -- require("quicktest.adapters.criterion"),
          -- require("quicktest.adapters.dart"),
          -- require("quicktest.adapters.rspec"),
        },
        -- split or popup mode, when argument not specified
        default_win_mode = "split",
        use_builtin_colorizer = true
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>tl",
        function()
          local qt = require("quicktest")
          -- current_win_mode return currently opened panel, split or popup
          qt.run_line()
          -- You can force open split or popup like this:
          -- qt.run_line('split')
          -- qt.run_line('popup')
        end,
        desc = "[T]est Run [L]line",
      },
      {
        "<leader>tf",
        function()
          local qt = require("quicktest")

          qt.run_file()
        end,
        desc = "[T]est Run [F]ile",
      },
      {
        '<leader>td',
        function()
          local qt = require 'quicktest'

          qt.run_dir()
        end,
        desc = '[T]est Run [D]ir',
      },
      {
        '<leader>ta',
        function()
          local qt = require 'quicktest'

          qt.run_all()
        end,
        desc = '[T]est Run [A]ll',
      },
      {
        "<leader>tp",
        function()
          local qt = require("quicktest")

          qt.run_previous()
        end,
        desc = "[T]est Run [P]revious",
      },
      {
        "<leader>tt",
        function()
          local qt = require("quicktest")

          qt.toggle_win("split")
        end,
        desc = "[T]est [T]oggle Window",
      },
      {
        "<leader>tc",
        function()
          local qt = require("quicktest")

          qt.cancel_current_run()
        end,
        desc = "[T]est [C]ancel Current Run",
      },
    },
  },
  {
    "tobyshooters/palimpsest",
    config = function()
      require('palimpsest').setup({

        -- LLM setup
        api_key = os.getenv("ANTHROPIC_API_KEY"),
        model = "claude-3-5-sonnet-latest",
        system = "Be concise and direct in your responses. Respond without unnecessary explanation.",

        -- Visual display of context markers
        signs = {
          context = "∙",
          highlight = "DiagnosticInfo"
        },

        -- Keymap for marking context and querying
        keymaps = {
          mark = "<leader>m",
          ask = "<leader>c",
        }
      })
    end
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end
  },
  {
    "rest-nvim/rest.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    }
  },
  {
    "dzfrias/arena.nvim",
    event = "BufWinEnter",
    -- Calls `.setup()` automatically
    config = true,
  },
})

local function org_imports()
  local clients = vim.lsp.get_clients()
  for _, client in pairs(clients) do
    local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end

  -- after organising imports, format.
  vim.lsp.buf.format()
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.ex", "*.exs" },
  callback = vim.lsp.buf.format,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go" },
  callback = org_imports,
})

vim.cmd([[colorscheme github_dark]])

vim.o.winborder = 'rounded'

-- LSP config
-- ref: https://neovim.io/doc/user/news-0.11.html#_defaults

-- Not sure if I like virtual lines over EOL
vim.diagnostic.config({ virtual_text = true })
-- vim.diagnostic.config({
--   virtual_lines = {
--     current_line = true,
--   },
-- })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    -- NOTE: this is the set up I had before 0.11
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func,
        { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    -- code actions
    map("ff", vim.lsp.buf.format, '[F]ormat')
    -- vim.keymap.set('n', '<C-i>', vim.lsp.buf.code_action, opts) -- handled by aznhe21/actions-preview.nvim
    map('<F2>', vim.lsp.buf.rename, 'Rename')

    -- code navigation
    map('gd', vim.lsp.buf.definition, '[G]o [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]o [D]eclaration')
    map("K", vim.lsp.buf.hover, 'Hover Documentation')

    -- references code navigation (quickfix list)
    map("gr", vim.lsp.buf.references, '[G]o [R]eferences')
    map("<leader>gr", require('telescope.builtin').lsp_references,
      '[G]o [R]eferences')

    map("gI", vim.lsp.buf.implementation, '[G]o [I]mplementation')
    map("<leader>gI", require('telescope.builtin').lsp_implementations,
      '[G]o [I]mplementation')

    -- references code navigation (Telescope)
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols,
      '[D]ocument [S]ymbols')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions,
      '[D]efinition')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ctions')
    -- ENDNOTE

    -- NOTE: copied from https://github.com/Rishabh672003/Neovim/blob/main/lua/rj/lsp.lua
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- Enable autocompletion when typing
    -- NOTE: it picks the first option
    -- if client:supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    -- end

    -- <C-x> <C-o> to also trigger autocompletion
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    --- Disable semantic tokens
    client.server_capabilities.semanticTokensProvider = nil

    -- All the keymaps
    -- stylua: ignore start
    local lsp = vim.lsp
    local opts = { silent = true }
    local function opt(desc, others)
      return vim.tbl_extend("force", opts, { desc = desc }, others or {})
    end

    -- diagnostics
    vim.keymap.set('n', '<F8>', vim.diagnostic.goto_next, { noremap = true, silent = true })
    -- FIXME: the Shift+F8 isn't quite working. Too bad I don't use it much.
    vim.keymap.set('n', '<S-F8>', vim.diagnostic.goto_prev, { noremap = true, silent = true })
    -- Note: By leveraging the quickfix list instead of location, we get
    -- project wide diagnostics instead of bufferwise.
    vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist, { noremap = true, silent = true })

    vim.keymap.set("n", "gd", lsp.buf.definition, opt("Go to definition"))
    vim.keymap.set("n", "gD", lsp.buf.declaration, opt("Go to declaration"))
    vim.keymap.set("n", "gI", function() lsp.buf.implementation({ border = "single" }) end, opt("Go to implementation"))
    vim.keymap.set("n", "gr", lsp.buf.references, opt("Show References"))
    vim.keymap.set("n", "gl", vim.diagnostic.open_float, opt("Open diagnostic in float"))
    -- keymap("n", "<C-k>", lsp.buf.signature_help, opts)
    -- -- disable the default binding first before using a custom one
    -- pcall(vim.keymap.del, "n", "K", { buffer = ev.buf })
    vim.keymap.set("n", "K", function() lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 }) end,
      opt("Toggle hover"))
    vim.keymap.set("n", "<Leader>lF", vim.cmd.FormatToggle, opt("Toggle AutoFormat"))
    vim.keymap.set("n", "<Leader>lI", vim.cmd.Mason, opt("Mason"))
    vim.keymap.set("n", "<Leader>lS", lsp.buf.workspace_symbol, opt("Workspace Symbols"))
    vim.keymap.set("n", "<Leader>la", lsp.buf.code_action, opt("Code Action"))
    vim.keymap.set("n", "<Leader>lh", function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({})) end,
      opt("Toggle Inlayhints"))
    vim.keymap.set("n", "<Leader>li", vim.cmd.LspInfo, opt("LspInfo"))
    vim.keymap.set("n", "<Leader>ll", lsp.codelens.run, opt("Run CodeLens"))
    vim.keymap.set("n", "<Leader>lr", lsp.buf.rename, opt("Rename"))
    vim.keymap.set("n", "<Leader>ls", lsp.buf.document_symbol, opt("Doument Symbols"))

    -- diagnostic mappings
    vim.keymap.set("n", "<Leader>dD", function()
      local ok, diag = pcall(require, "rj.extras.workspace-diagnostic")
      if ok then
        for _, cur_client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          diag.populate_workspace_diagnostics(cur_client, 0)
        end
        vim.notify("INFO: Diagnostic populated")
      end
    end, opt("Popluate diagnostic for the whole workspace"))
    vim.keymap.set("n", "<Leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end,
      opt("Next Diagnostic"))
    vim.keymap.set("n", "<Leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end,
      opt("Prev Diagnostic"))
    vim.keymap.set("n", "<Leader>dq", vim.diagnostic.setloclist, opt("Set LocList"))
    vim.keymap.set("n", "<Leader>dv", function()
      vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
    end, opt("Toggle diagnostic virtual_lines"))
    -- stylua: ignore end
  end,
})

-- Might want to look into? https://github.com/folke/lazydev.nvim
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  -- This config is simply to be use lua for Neovim
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      }
    })
  end,
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.lsp.config.gopls = {
  cmd = { "gopls" },
  filetypes = { "go", "gotempl", "gowork", "gomod" },
  root_markers = { ".git", "go.mod", "go.work", vim.uv.cwd() },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      ["ui.inlayhint.hints"] = {
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

vim.lsp.config.helm_ls = {
  cmd = { 'helm_ls', 'serve' },
  filetypes = { 'helm' },
  root_markers = { 'Chart.yaml' },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  settings = {
    ['helm-ls'] = {
      valuesFiles = {
        mainValuesFile = "values.yaml",
        lintOverlayValuesFile = "values.lint.yaml",
        additionalValuesFilesGlobPattern = "values*.yaml"
      },
      yamlls = {
        path = "yaml-language-server",
        enabled = false,
        diagnosticsLimit = 50,
        showDiagnosticsDirectly = false,
        config = {
          schemas = {
            kubernetes = "templates/**",
          },
          completion = true,
          hover = true,
          -- any other config from https://github.com/redhat-developer/yaml-language-server#language-server-settings
        }
      }
    }
  }
}

vim.lsp.config.yamlls = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
  root_markers = { '.git' },
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = "/action.yaml"
      },
    },
  }
}
vim.lsp.config.pylsp = {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true,
          maxLineLength = 500
        }
      }
    }
  }
}

vim.lsp.enable({
  -- LSPs with default configuration
  'tilt_ls',
  'terraformls',
  'denols',
  "ocamlls",
  "clojure_lsp",
  "dartls",
  "bashls",
  "vale_ls",
  "sqls",
  "elixirls",
  "pylsp",
  "ruff",
  "ts_ls",
  -- Fine-tuned lsps
  "lua_ls",
  "gopls",
  "helm_ls",
  "yamlls",
})

-- Start, Stop, Restart, Log commands {{{
vim.api.nvim_create_user_command("LspStart", function()
  vim.cmd.e()
end, { desc = "Starts LSP clients in the current buffer" })

vim.api.nvim_create_user_command("LspStop", function(opts)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped")
    end
  end
end, {
  desc = "Stop all LSP clients or a specific client attached to the current buffer.",
  nargs = "?",
  complete = function(_, _, _)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

vim.api.nvim_create_user_command("LspRestart", function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify("Servers are stopped but havent been restarted")
  end
  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })
        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end
          vim.notify(name .. ": restarted")
        end
        detach_clients[name] = nil
      end
      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = "Get all the lsp logs",
})

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("silent checkhealth vim.lsp")
end, {
  desc = "Get all the information about all LSP attached",
})

-- HTTP request plugin
-- require('http_request').setup()
