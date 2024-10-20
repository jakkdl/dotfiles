-- vim-plug configuration
-- Reload .vimrc with :so[urce]
-- reload with `luafile %`

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	--spec = {
	--	{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
	--	{ import = "lazyvim.plugins.extras.coding.copilot" },
	--	--{ import = "plugins" },
	--},
	"neovim/nvim-lspconfig",
	"jasonccox/vim-wayland-clipboard",
	"ntpeters/vim-better-whitespace", -- :help better-whitespace
	"tpope/vim-fugitive", -- git aliases
	"tpope/vim-eunuch", -- shell helpers
	"morhetz/gruvbox", -- Another theme
	--"vim-airline/vim-airline",
	"plasticboy/vim-markdown",
	"cespare/vim-toml",
	--'github/copilot-vim',
        {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
        "f-person/auto-dark-mode.nvim"
})
--require("lazy").setup(plugins, opts)

-- % can be used for current file, or $MYVIMRC
-- and :PlugInstall to install plugins.
-- Specify a directory for plugins
-- - For Neovim: stdpath('data') . '/plugged'
-- - Avoid using standard Vim directory names like 'plugin'
--vim.cmd([[
--call plug#begin('~/.local/share/nvim/plugged')
--]])

-- Make sure you use single quotes
-- Plug 'LucHermitte/lh-vim-lib'
-- Plug 'LucHermitte/local_vimrc'
-- Plug 'mfulz/cscope.nvim'
-- Plug 'mxw/vim-prolog'
--local Plug = vim.fn['plug#']
-- Plug 'ayu-theme/ayu-vim' -- https://github.com/ayu-theme/ayu-vim
--Plug 'neomake/neomake'
--vim.cmd([[
--Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
--]])
--  :checkhealth gives warnings
-- if filereadable("/usr/bin/node")
--     Plug 'neoclide/coc.nvim', {'branch': 'release'}
-- endif
HOME = os.getenv("HOME")
vim.g.python3_host_prog = HOME .. "/.local/share/nvim/venv/bin/python"
-- vim.cmd([[
-- Plug 'averms/black-nvim', {'do': ':UpdateRemotePlugins'}
-- ]])
-- Initialize plugin system
--vim.call('plug#end')

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
vim.g.vim_markdown_frontmatter = 1 -- for YAML format
vim.g.vim_markdown_toml_frontmatter = 1 -- for TOML format
vim.g.vim_markdown_json_frontmatter = 1 -- for JSON format

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
vim.g.gruvbox_contrast_dark = "light"
vim.o.background = "light"
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
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.cmd([[
autocmd FileType javascript,typescript,typescriptreact set shiftwidth=2
autocmd FileType javascript,typescript,typescriptreact set softtabstop=2
]])

-- xml
vim.g.xml_syntax_folding = 1

vim.cmd([[
  augroup XMLFolding
    autocmd!
    autocmd FileType xml setlocal foldmethod=syntax
  augroup end
]])

-- keep the cursor in the middle of the window at all times
-- https://stackoverflow.com/questions/59408739/how-to-bring-the-marker-to-middle-of-the-screen
vim.opt.scrolloff = 999
-- Allow hidden modified buffers, to let us navigate without prompting to save
vim.opt.hidden = true

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
vim.opt.wildmode = { "longest", "list", "full" }
vim.opt.wildmenu = true

-- cscope
-- set cscopeverbose
-- set cscopequickfix=s-,c-,d-,i-,t-,e-

--enable folds
vim.opt.foldmethod = "syntax"
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
vim.api.nvim_create_user_command("MySo", "source $MYVIMRC", { bang = true })
vim.api.nvim_create_user_command("MySed", "vimgrep /\\<'iw'\\>/gj' *.py", { bang = true })

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

-- pip install pylsp-mypy python-lsp-ruff pylsp-rope python-lsp-black
-- pyls-isort

lspconfig = require("lspconfig")
lspconfig.pylsp.setup({
	on_attach = custom_attach,
	settings = {
		pylsp = {
			plugins = {
				black = { enabled = true },
				pylsp_mypy = { enabled = true },
				pylsp_rope = { enabled = true },
				--rope_autoimport = { enabled = true, memory = true },
				-- auto-completion
				jedi_completion = { fuzzy = true },
				-- import sorting (disabled if ruff is available)
				pyls_isort = { enabled = true },

				ruff = {
					enabled = true,
                                        formatEnabled = false,
                                        extendIgnore = {
                                            "E501", -- line too long
                                            "Q000", -- single quotes
                                        },
					lineLength = 120,
				},

				-- disabled
				-- formatters
				autopep8 = { enabled = false },
				yapf = { enabled = false },
				-- linters
				pylint = { enabled = false, executable = "pylint" },
				pyflakes = { enabled = false },
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
			},
		},
	},
	flags = {
		debounce_text_changes = 200,
	},
	capabilities = capabilities,
})

-- Setup language servers.
-- being a bit conservative and keeping these commented out lines for the moment, in case
-- I want to play around more with pyright/pyre/etc
--lspconfig.pyright.setup {}
--lspconfig.pyre.setup {}
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
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
		vim.keymap.set("n", "<space>test", function()
			vim.lsp.buf.completion({})
		end, opts)
	end,
})

-- Dynamic switching of theme depending on org.freedesktop.appearance.color-scheme
return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    update_interval = 3000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd("colorscheme gruvbox")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd("colorscheme gruvbox")
    end,
  },
}
