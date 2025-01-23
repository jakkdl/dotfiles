-- reload with `luafile %`

-- TODO: undo history (for mksession, and others)

-- TODO: fugitive status line
--STATUSLINE                                      *fugitive-statusline*
--
--                                *FugitiveStatusline()* *fugitive#statusline()*
--Add %{FugitiveStatusline()} to your statusline to get an indicator including
--the current branch and the currently edited file's commit.  If you don't have
--a statusline, this one matches the default when 'ruler' is set:
-->
--        set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P

-- yay -S nvim-lazy
require("config.lazy")


HOME = os.getenv("HOME")
vim.g.python3_host_prog = HOME .. "/.local/share/nvim/venv/bin/python"

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
-- cscope
-- set cscopeverbose
-- set cscopequickfix=s-,c-,d-,i-,t-,e-

--
--
-- ###############
-- AYU-THEME config
-- set termguicolors     " enable true colors support
--let ayucolor="light"  " for light version of theme
--let ayucolor="mirage" " for mirage version of theme
-- let ayucolor="dark"   " for dark version of theme
-- colorscheme ayu

-- ### airline
--vim.cmd([[
--let g:airline#extensions#branch#displayed_head_limit = 10
--let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
--let g:airline_powerline_fonts = 1
--]])

-- let g:airline#extensions#default#section_truncate_width = {
--   \ 'b': 79,
--   \ 'x': 60,
--   \ 'y': 88,
--   \ 'z': 45,
--   \ 'warning': 80,
--   \ 'error': 80,
--   \ }
--

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

-- https://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
-- When you type the first tab hit, it will complete as much as possible. The
-- second tab hit will provide a list. The third and subsequent tabs will cycle
-- through completion options so you can complete the file without further keys.
vim.opt.wildmode = { "longest", "list", "full" }
vim.opt.wildmenu = true

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
                                            "E117",
                                            "E203",
                                            "E226", --
                                            "E227",
                                            "E231", -- missing-whitespace
                                            "E251", -- unexpected-spaces-around-keyword-parameter-equals
                                            "E301",
                                            "E302", -- newlines
                                            "E303",
                                            "E305",
                                            "E306",
                                            "E501", -- line-too-long
                                            "F401", -- unused-import
                                            "W293",
                                            "W391",
                                            "Q000", -- bad-quotes-inline-string (single instead of double)
                                            "I001", -- unsorted-imports
                                            -- "UP034", -- extraneous parantheses (not fixed by black)
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

-- ######## MUcomplete
-- mandatory
vim.opt.completeopt:append("menuone")
---- "automatic completion" (don't know what it does)
vim.opt.completeopt:append("noselect")
vim.opt.completeopt:append("noinsert")
---- "shut off completion messages" (don't know what it does)
--vim.opt.shortmess:append("c")
--
-- -- Enable auto-completion at startup
vim.g.mucomplete_enable_auto_at_startup = 1
