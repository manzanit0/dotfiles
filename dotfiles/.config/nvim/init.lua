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
vim.o.wildignore = table.concat({
  "*.o,*.obj,*.so,*.a,*.dylib,*.pyc,*.hi", -- compiled
  "*.zip,*.gz,*.xz,*.tar,*.rar",           -- compressed
  "*/.git/*,*/.hg/*,*/.svn/*",             -- SCM
  "*.png,*.jpg,*.jpeg,*.gif",              -- images
  "*.pdf,*.dmg",                           -- binary
  ".*.sw*,*~",                             -- editor
  ".DS_Store",                             -- OS
}, ",")

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

-- wrapping
vim.o.textwidth = 80 -- This breaks lines at 80 characters when typing
vim.o.linebreak = true -- wrap at word boundaries instead of mid-word

-- numbers in the side
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
vim.keymap.set({'n', 'o', 'x'}, '<', '[', { remap = true })
vim.keymap.set({'n', 'o', 'x'}, '>', ']', { remap = true })

-- In case you use :terminal, bring back ESC.
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

local function toggle_quickfix()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end
vim.api.nvim_create_user_command('ToggleQuickFix', toggle_quickfix, { bar = true })
vim.keymap.set('n', 'cq', toggle_quickfix, { silent = true })

vim.api.nvim_create_user_command("PrView", function()
  vim.fn.system("gh pr view --web")
end, { desc = "Open current PR in web browser" })

vim.api.nvim_create_user_command("PrCreate", function()
  vim.fn.system("wk pr --draft")
end, { desc = "Push branch and create a PR in draft mode" })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = vim.highlight.on_yank,
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
  { "n", "<leader>cF", function() vim.fn.setreg('+', vim.fn.expand('%:p')) end },
  -- relative path
  { "n", "<leader>cf", function() vim.fn.setreg('+', vim.fn.expand('%')) end },
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

vim.o.termguicolors = true

vim.loader.enable()

vim.pack.add({
  -- Themes
  "https://github.com/projekt0n/github-nvim-theme",
  "https://github.com/ayu-theme/ayu-vim",
  -- Libs for plugins
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  "https://github.com/MunifTanjim/nui.nvim",
  -- Behaviour
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-unimpaired",
  "https://github.com/tpope/vim-rhubarb",
  "https://github.com/yasuhiroki/github-actions-yaml.vim",
  "https://github.com/onsails/lspkind.nvim",
  "https://github.com/stevearc/dressing.nvim",
  "https://github.com/rhysd/conflict-marker.vim",
  "https://github.com/kosayoda/nvim-lightbulb",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/j-hui/fidget.nvim", -- TODO: this isn't working any more since 0.11 lsp migration
  "https://github.com/Joorem/vim-haproxy",
  -- "https://github.com/manzanit0/k8s-whisper.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/vim-test/vim-test",
  -- "https://github.com/numToStr/Comment.nvim",
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = "v3.x" },
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/hedyhli/outline.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/ruifm/gitlinker.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  -- run :call mkdp#util#install()
  "https://github.com/aznhe21/actions-preview.nvim",
  "https://github.com/akinsho/flutter-tools.nvim",
  "https://github.com/folke/todo-comments.nvim",
  "https://github.com/quolpr/quicktest.nvim",
  -- "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/iamcco/markdown-preview.nvim",
  "https://github.com/andrewferrier/wrapping.nvim",
  "https://github.com/junegunn/goyo.vim",
  "https://github.com/nosduco/remote-sshfs.nvim",
})

-- vim.pack doesn't support build hooks, so we need to manually build telescope-fzf-native
-- This compilation step is necessary for the FZF sorter to work with native performance
local fzf_lib = vim.fn.stdpath('data') .. '/site/pack/core/opt/telescope-fzf-native.nvim'
if vim.fn.isdirectory(fzf_lib) == 1 and vim.fn.filereadable(fzf_lib .. '/build/libfzf.so') == 0 then
  vim.fn.system('cd ' .. fzf_lib .. ' && make')
end

-- Plugin configurations

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "markdown-preview.nvim"
      and (d.kind == "install" or d.kind == "update") then
      vim.notify("Building markdown-preview.nvim...")
      vim.system(
        { "sh", "-c", "npx --yes yarn install && npx --yes yarn build" },
        { cwd = d.path }
      )
    end
  end,
})

require('remote-sshfs').setup()

require('mason').setup()

require("wrapping").setup()
vim.keymap.set("n", "<leader>wt", "<Plug>(wrapping-toggle-wrap-mode)")

require("oil").setup()
vim.keymap.set("n", "_", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.g.neo_tree_remove_legacy_commands = 1

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

local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

local telescope = require("telescope")
telescope.setup {
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

require('outline').setup({})
vim.keymap.set("n", "<leader>m", "<cmd>Outline<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>te", "<cmd>TestNearest<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>Te", "<cmd>TestFile<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<Leader>gs", "<cmd>Git<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gpu", "<cmd>Git push<cr>", { desc = "Git push" })

require('gitsigns').setup()

local gitlinker = require("gitlinker")
gitlinker.setup({ mappings = nil })

vim.keymap.set("n", "<leader>gb", function()
  gitlinker.get_repo_url({ action_callback = gitlinker.actions.open_in_browser })
end, { silent = true, desc = "browse repo in browser" })

vim.keymap.set({ "n", "v" }, "<leader>gl", function()
  gitlinker.get_buf_range_url(string.lower(vim.fn.mode()))
end, { silent = true, desc = "get git permlink" })


local treesitter = require("nvim-treesitter")
treesitter.setup({
		highlight = { enable = true }, -- enable treesitter syntax highlighting
})

local languages = {
    'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc',
    "proto",
    "yaml", "json",
    "go", "gomod", "gowork",
    "dockerfile", "hcl", "terraform",
    "gotmpl", "helm",
    "elixir",
    "starlark",
    "javascript", "typescript"
  }
treesitter.install(languages)

vim.treesitter.language.register("starlark", "tiltfile")

vim.filetype.add({
  filename = { Tiltfile = 'tiltfile' },
  extension = {
    gotmpl = 'gotmpl',
  },
  pattern = {
    [".*%.Jenkinsfile"] = "groovy",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    -- pcall to silently skip filetypes without a treesitter parser (e.g. qf, help)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tiltfile',
  callback = function()
    vim.bo.syntax = 'starlark'
  end,
})

vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)

require('flutter-tools').setup({})

require("todo-comments").setup()

-- TODO: need to figure out how to remove stupid comments
-- require('k8s-whisper').setup({
--   -- This is a GitHub repository
--   schemas_catalog = 'datreeio/CRDs-catalog',
--   -- This is a git ref, branch, tag, sha, etc.
--   schema_catalog_ref = 'main',
-- })

local qt = require("quicktest")

qt.setup({
  adapters = {
    require("quicktest.adapters.golang")({}),
    -- The pytest adapter uses local tools, which doesn't work if we're using something like poetry.
    require("quicktest_adapter_poetry")({}),
    -- require("quicktest.adapters.pytest")({}),
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

vim.keymap.set("n", "<leader>tl", qt.run_line, { desc = "[T]est Run [L]line" })
vim.keymap.set("n", "<leader>tf", qt.run_file, { desc = "[T]est Run [F]ile" })
vim.keymap.set("n", '<leader>td', qt.run_dir, { desc = '[T]est Run [D]ir' })
vim.keymap.set("n", '<leader>ta', qt.run_all, { desc = '[T]est Run [A]ll' })
vim.keymap.set("n", "<leader>tp", qt.run_previous, { desc = "[T]est Run [P]revious" })
vim.keymap.set("n", "<leader>tt", function() qt.toggle_win("split") end, { desc = "[T]est [T]oggle Window" })
vim.keymap.set("n", "<leader>tc", qt.cancel_current_run, { desc = "[T]est [C]ancel Current Run" })

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

vim.o.winborder = 'rounded'

-- LSP config
-- ref: https://neovim.io/doc/user/news-0.11.html#_defaults

-- Not sure if I like virtual lines over EOL
vim.diagnostic.config({ virtual_text = true })

vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist, { noremap = true, silent = true })
-- vim.diagnostic.config({
--   virtual_lines = {
--     current_line = true,
--   },
-- })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client.server_capabilities.completionProvider then
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[ev.buf].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- Rely exclusively on treesitter highlighting.
    client.server_capabilities.semanticTokensProvider = nil

    local lsp = vim.lsp
    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { silent = true, buffer = ev.buf, desc = desc })
    end

    map("ff",         lsp.buf.format,                                                                        "Format")
    map("<F2>",       lsp.buf.rename,                                                                        "Rename")
    map("gd",         lsp.buf.definition,                                                                    "Go to definition")
    map("gD",         lsp.buf.declaration,                                                                   "Go to declaration")
    map("gI",         function() lsp.buf.implementation({ border = "single" }) end,                          "Go to implementation")
    map("gr",         lsp.buf.references,                                                                    "Show references")
    map("gl",         vim.diagnostic.open_float,                                                             "Open diagnostic float")
    map("K",          function() lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 }) end, "Hover")
    map("<leader>gr", builtin.lsp_references,                                                                "References")
    map("<leader>gI", builtin.lsp_implementations,                                                           "Implementations")
    map("<leader>ds", builtin.lsp_document_symbols,                                                          "Document symbols")
    map("<leader>D",  builtin.lsp_type_definitions,                                                          "Type definition")
    map("<leader>ca", lsp.buf.code_action,                                                                   "Code actions")
    map("<leader>lh", function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({})) end,               "Toggle inlay hints")
    map("<leader>li", vim.cmd.LspInfo,                                                                       "LSP info")
    map("<leader>ll", lsp.codelens.run,                                                                      "Run codelens")
    map("<leader>lS", lsp.buf.workspace_symbol,                                                              "Workspace symbols")
    map("<leader>lI", vim.cmd.Mason,                                                                         "Mason")
    map("<F8>",       function() vim.diagnostic.jump({ count = 1 }) end,                                     "Next diagnostic")
    map("<F7>",       function() vim.diagnostic.jump({ count = -1 }) end,                                    "Prev diagnostic")
    map("<Leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end,                       "Next diagnostic (float)")
    map("<Leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end,                      "Prev diagnostic (float)")
    map("<Leader>dq", vim.diagnostic.setloclist,                                                             "Set loclist")
    map("<Leader>dv", function()
      vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
    end, "Toggle virtual lines")
  end,
})

local lsp_configs = {
  marksman    = {},
  tilt_ls     = {},
  terraformls = { mason = "terraform-ls" },
  ocamlls     = {},
  clojure_lsp = { mason = "clojure-lsp" },
  dartls      = {},
  bashls      = { mason = "bash-language-server" },
  -- vale_ls     = { mason = "vale-ls" },
  sqls        = { mason = "sqls" },
  elixirls    = { mason = "elixir-ls" },
  ruff        = { mason = "ruff" },
  ts_ls       = { mason = "typescript-language-server" },
  docker_language_server    = { mason = "docker-language-server" },
  lua_ls = {
    mason = "lua-language-server",
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
      '.luarc.json', '.luarc.jsonc', '.luacheckrc',
      '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git',
    },
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config')
            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
      })
    end,
    settings = { Lua = { telemetry = { enable = false } } },
  },
  gopls = {
    mason = "gopls",
    cmd = { "gopls" },
    filetypes = { "go", "gotempl", "gowork", "gomod" },
    root_markers = { ".git", "go.mod", "go.work", vim.uv.cwd() },
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = { unusedparams = true },
        ["ui.inlayhint.hints"] = {
          compositeLiteralFields = true,
          constantValues = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },
  helm_ls = {
    mason = "helm-ls",
    cmd = { 'helm_ls', 'serve' },
    filetypes = { 'helm' },
    root_markers = { 'Chart.yaml' },
    capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
    settings = {
      ['helm-ls'] = {
        valuesFiles = {
          mainValuesFile = "values.yaml",
          lintOverlayValuesFile = "values.lint.yaml",
          additionalValuesFilesGlobPattern = "values*.yaml",
        },
        yamlls = {
          path = "yaml-language-server",
          enabled = false,
          diagnosticsLimit = 50,
          showDiagnosticsDirectly = false,
          config = { schemas = { kubernetes = "templates/**" }, completion = true, hover = true },
        },
      },
    },
  },
  yamlls = {
    mason = "yaml-language-server",
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    root_markers = { '.git' },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/github-action.json"] = "/action.yaml",
        },
      },
    },
  },
  pylsp = {
    mason = "python-lsp-server",
    settings = { pylsp = { plugins = { pycodestyle = { enabled = true, maxLineLength = 500 } } } },
  },
}

--- Make sure all abouve listed LSP configs are setup and the appropriate LSP
--- binaries are installed through Mason.
--- CAVEAT: updates need to be manually kicked-off through the Mason UI.
local registry = require("mason-registry")
for name, config in pairs(lsp_configs) do
  local pkg_name = config.mason
  if pkg_name then
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end

  local lsp_config = vim.tbl_extend("force", config, { mason = nil })
  if next(lsp_config) then
    vim.lsp.config[name] = lsp_config
  end
  vim.lsp.enable(name)
end

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
  complete = function()
    local client_names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
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

vim.cmd.colorscheme('github_dark')

