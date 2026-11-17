---@diagnostic disable: undefined-global

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
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.g.nosmartindent = true
vim.o.autoindent = true
vim.o.cursorline = true

-- TODO: need to look how to set this... apparently it's not vim.o.nofoldenable.
vim.cmd [[ set nofoldenable ]]

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

local vscode = require('vscode-neovim')

vscode.notify("Loaded settings from ~/.config/nvim/vscode.lua", "vim.log.levels.INFO")
vim.notify = vscode.notify


-- Neovim API mappings
for _, mapping in ipairs({
    -- leader
    { "n", "<leader>ve", ":! codium ~/.config/nvim/vscode.lua<cr>" },
    -- -- better `j` and `k`
    { "n", "j",          "gj" },
    { "v", "j",          "gj" },
    { "n", "k",          "gk" },
    { "v", "k",          "gk" },
    -- -- copy from the cursor to the end of line using Y (matches D behavior)
    -- { "n", "Y",          "y$" },
    -- -- reselect visual block after indent
    -- { "v", "<",          "<gv" },
    -- { "v", ">",          ">gv" },
    -- -- absolute path (/something/src/foo.txt)
    { "n", "<leader>cF", ":let @+=expand(\"%:p\")<CR>" },
    -- -- relative path
    { "n", "<leader>cf", ":let @+=expand(\"%\")<CR>" },
    -- -- keep the cursor in place while joining lines
    -- { "n", "J",          "mZJ`Z" },
}) do
    vim.keymap.set(mapping[1], mapping[2], mapping[3], { remap = true, silent = true })
end

-- VS Code API mappings
for _, mapping in ipairs({
    -- Neovim Extension
    { "n", "<leader>vr", "vscode-neovim.restart" },
    -- File stuffs
    { "n", "<cr>",       "workbench.action.files.save" },
    -- Folds
    { "n", "zM",         "editor.foldAll" },
    { "n", "zR",         "editor.unfoldAll" },
    { "n", "zc",         "editor.fold" },
    { "n", "zC",         "editor.foldRecursively" },
    { "n", "zo",         "editor.unfold" },
    { "n", "z0",         "editor.unfoldRecursively" },
    { "n", "za",         "editor.toggleFold" },
    -- Find stuff
    { "n", "<leader>d",  "workbench.action.showCommands" },
    { "n", "fi",         "actions.find" },
    { "n", "fr",         "editor.action.startFindReplaceAction" },
    { "n", "fg",         "workbench.action.findInFiles" },
    { "n", "fs",         "workbench.action.gotoSymbol" },
    { "n", "<leader>e",  "workbench.action.toggleSidebarVisibility" },
    -- { "n", "<leader>x",  "workbench.actions.view.problems" },
    -- code actions
    { "n", "ff",         "editor.action.formatDocument" },
    { "n", "gy",         "editor.action.revealDefinition" },
    { "n", "gi",         "editor.action.goToImplementation" },
    { "n", "go",         "editor.action.goToReferences" },
    { "n", "gr",         "references-view.findReferences" },
    -- git
    { "n", "<leader>gg", "workbench.view.scm" },
    { "n", "<leader>gc", "git.commit" },
    { "n", "<leader>gs", "git.stageAll" },
    { "n", "<leader>gl", "gitlens.copyRemoteFileUrlToClipboard" },
    { "n", "-",          "workbench.view.explorer" },
}) do
    vim.keymap.set(mapping[1], mapping[2], function()
        vscode.call(mapping[3])
    end, { noremap = true, silent = true })
end
