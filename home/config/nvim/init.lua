-- vim-plug configuration
-- Reload .vimrc with :so[urce]
-- reload with `luafile %`
-- % can be used for current file, or $MYVIMRC
-- and :PlugInstall to install plugins.
-- Specify a directory for plugins
-- - For Neovim: stdpath('data') . '/plugged'
-- - Avoid using standard Vim directory names like 'plugin'
vim.cmd([[
call plug#begin('~/.local/share/nvim/plugged')
]])


-- Make sure you use single quotes
-- Plug 'LucHermitte/lh-vim-lib'
-- Plug 'LucHermitte/local_vimrc'
-- Plug 'mfulz/cscope.nvim'
-- Plug 'mxw/vim-prolog'
local Plug = vim.fn['plug#']
Plug 'jasonccox/vim-wayland-clipboard'
Plug 'ntpeters/vim-better-whitespace' -- :help better-whitespace
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
-- Plug 'ayu-theme/ayu-vim' -- https://github.com/ayu-theme/ayu-vim
Plug 'morhetz/gruvbox' -- Another theme
Plug 'vim-airline/vim-airline'
Plug 'neomake/neomake'
Plug 'plasticboy/vim-markdown'
Plug 'cespare/vim-toml'
vim.cmd([[
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
]])
--  :checkhealth gives warnings
-- if filereadable("/usr/bin/node")
--     Plug 'neoclide/coc.nvim', {'branch': 'release'}
-- endif
HOME = os.getenv("HOME")
vim.g.python3_host_prog = HOME .. '/.local/share/nvim/venv/bin/python'
vim.cmd([[
Plug 'averms/black-nvim', {'do': ':UpdateRemotePlugins'}
]])
Plug 'neovim/nvim-lspconfig'
-- Initialize plugin system
vim.call('plug#end')

-- ### vim-markdown
-- taken from https://jdhao.github.io/2019/01/15/markdown_edit_preview_nvim/
-- disable header folding
vim.g.vim_markdown_folding_disabled = 1
-- do not use conceal feature, the implementation is not so good
vim.g.vim_markdown_conceal = 0

-- disable math tex conceal feature
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1

-- support front matter of various format
vim.g.vim_markdown_frontmatter = 1  -- for YAML format
vim.g.vim_markdown_toml_frontmatter = 1  -- for TOML format
vim.g.vim_markdown_json_frontmatter = 1  -- for JSON format

-- #### NEOMAKE ####
-- when to activate neomake
vim.cmd([[
call neomake#configure#automake('rw')
]])

-- which linter to enable for Python source file linting
-- vim.g.neomake_python_enabled_makers = ['pylint', 'mypy', 'vulture']
-- vim.g.neomake_python_enabled_makers = ['pylint', 'mypy']
vim.g.neomake_python_enabled_makers = {'mypy'}
-- vim.g.neomake_javascript_enablem_makers = ['eslint_d']

-- ######################
-- cscope.nvim configuration
-- Path to store the cscope files (cscope.files and cscope.out)
-- Defaults to '~/.cscope'
-- vim.g.cscope_dir = '~/.local/share/nvim/cscope'

-- Map the default keys on startup
-- These keys are prefixed by CTRL+\ <cscope param>
-- A.e.: CTRL+\ d for goto definition of word under cursor
-- Defaults to off
-- vim.g.cscope_map_keys = 1

-- Update the cscope files on startup of cscope.
-- Defaults to off
-- vim.g.cscope_update_on_start = 1

-- ########################
-- local_vimrc configuration
-- whitelist pintos config so we always source without asking
-- call lh#local_vimrc#munge('whitelist', $HOME.'/Courses/tdiu16/pintos')
--
--
-- ###############
-- AYU-THEME config
-- set termguicolors     " enable true colors support
--let ayucolor="light"  " for light version of theme
--let ayucolor="mirage" " for mirage version of theme
-- let ayucolor="dark"   " for dark version of theme
-- colorscheme ayu

-- ### Gruvbox
-- set termguicolors     " enable true colors support
-- autocmd vimenter * ++nested colorscheme gruvbox
-- set background=dark    " Setting dark mode
-- vim.g.gruvbox_contrast_dark = 'hard'
vim.o.background = 'light'
vim.cmd([[colorscheme gruvbox]])
-- #### black-nvim
--
--
--
-- ### airline
vim.cmd([[
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_powerline_fonts = 1
]])
-- let g:airline#extensions#default#section_truncate_width = {
--   \ 'b': 79,
--   \ 'x': 60,
--   \ 'y': 88,
--   \ 'z': 45,
--   \ 'warning': 80,
--   \ 'error': 80,
--   \ }
-- #######################
-- General configuration
vim.cmd([[
syntax on
filetype plugin indent on
]])
vim.opt.expandtab=true
vim.opt.shiftwidth=4
vim.opt.softtabstop=4

vim.cmd([[
autocmd FileType javascript,typescript,typescriptreact set shiftwidth=2
autocmd FileType javascript,typescript,typescriptreact set softtabstop=2
]])

-- keep the cursor in the middle of the window at all times
-- https://stackoverflow.com/questions/59408739/how-to-bring-the-marker-to-middle-of-the-screen
vim.opt.scrolloff=999
-- Allow hidden modified buffers, to let us navigate without prompting to save
vim.opt.hidden=true

--set colorcolumn=81
-- doesn't work in nvim?
--autocmd FileType python 2mat ErrorMsg '\%81v.'
-- mark characters in the 80th column red, according to PEP-8
-- https://vi.stackexchange.com/a/658

-- match ColorColumn "\%89v."


-- colorscheme desert

-- defunct?
-- let pintos_vimrc_local = 0

-- https://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
-- When you type the first tab hit, it will complete as much as possible. The
-- second tab hit will provide a list. The third and subsequent tabs will cycle
-- through completion options so you can complete the file without further keys.
vim.opt.wildmode={'longest','list','full'}
vim.opt.wildmenu = true

-- cscope
-- set cscopeverbose
-- set cscopequickfix=s-,c-,d-,i-,t-,e-

--enable folds
vim.opt.foldmethod='syntax'
-- Start with open folds
vim.cmd([[
autocmd FileType * exe "normal zR"
]])

-- enable line numbers
vim.opt.number = true
--set norelativenumber

-- load same-folder init.vim
-- if filereadable("init.vim")
--     if getcwd() != "/home/h/.config/nvim"
--         so init.vim
--     endif
-- endif
vim.api.nvim_create_user_command(
    'MySo',
    "source $MYVIMRC",
    {bang = true}
    )
vim.api.nvim_create_user_command(
    'MySed',
    "vimgrep /\\<'iw'\\>/gj' *.py",
    {bang = true}
    )

-- vim.api.nvim_create_user_command(
--     'MySo',
--     function()
--         source $MYVIMRC
--     end,
--     {bang = true, desc = 'source vimrc'}
-- )

-- vim.cmd([[
-- function MySed(replace = 10)
--     vimgrep /\<'iw'\>/gj' *.py
-- endfunction
--
-- function MySo()
--     source $MYVIMRC
-- endfunction
-- ]])
-- local my_sed = function(a)
--     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'NUUUUU', '"wyiw', opts)
-- end

-- map <leader>s :execute "noautocmd vimgrep /\\<" . expand("<cword>") . "\\>/gj **/*." .  expand("%:e") <Bar> cw<CR>
-- map <leader>s :execute "noautocmd vimgrep /\\<" . expand("<cword>") . "\\>/gj **/*." . expand("%:e") <Bar> cfdo "cfdo %s/" . expand("<cword>") . "/"

lspconfig = require("lspconfig")
lspconfig.pylsp.setup {
on_attach = custom_attach,
settings = {
    pylsp = {
    plugins = {
        -- formatter options
        black = { enabled = true },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        -- linter options
        pylint = { enabled = false, executable = "pylint" },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        -- type checker
        pylsp_mypy = { enabled = true },
        -- auto-completion options
        jedi_completion = { fuzzy = true },
        -- import sorting
        pyls_isort = { enabled = true },
    },
    },
},
flags = {
    debounce_text_changes = 200,
},
capabilities = capabilities,
}

-- Setup language servers.
--local lspconfig = require('lspconfig')
--lspconfig.pylsp.setup {}
    --settings = {
    --    pylsp = {
    --        plugins = {
    --            pyflakes = { enabled = false },
    --            pycodestyle = { enabled = false },
    --            jedi_completion = { fuzzy = true },
    --            pyls_isort = { enabled = true },
    --        }
    --    }
    --}
--}
--lspconfig.pyright.setup {}
--lspconfig.pyre.setup {}
lspconfig.ruff_lsp.setup {
    init_options = {
         settings = {
            args = { '--line-length=120' },
         }
    }
}
-- lspconfig.pylsp_mypy.setup {}
-- lspconfig.tsserver.setup {}
-- lspconfig.rust_analyzer.setup {
--   -- Server-specific settings. See `:help lspconfig-setup`
--   settings = {
--     ['rust-analyzer'] = {},
--   },
-- }

-- vim.lsp.start({
--   name = 'python_language_server',
--   cmd = {'pyls'},
--   root_dir = vim.fs.dirname(vim.fs.find({'setup.py', 'pyproject.toml'}, { upward = true })[1]),
-- })

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

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
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
