" vim-plug configuration
" Reload .vimrc with :so[urce]
" % can be used for current file, or $MYVIMRC
" and :PlugInstall to install plugins.
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes
" Plug 'LucHermitte/lh-vim-lib'
" Plug 'LucHermitte/local_vimrc'
" Plug 'mfulz/cscope.nvim'
Plug 'ntpeters/vim-better-whitespace' " :help better-whitespace
Plug 'tpope/vim-fugitive'
Plug 'ayu-theme/ayu-vim' " https://github.com/ayu-theme/ayu-vim
Plug 'morhetz/gruvbox' " Another theme
Plug 'mxw/vim-prolog'

" Initialize plugin system
call plug#end()

" ######################
" cscope.nvim configuration
" Path to store the cscope files (cscope.files and cscope.out)
" Defaults to '~/.cscope'
" let g:cscope_dir = '~/.local/share/nvim/cscope'

" Map the default keys on startup
" These keys are prefixed by CTRL+\ <cscope param>
" A.e.: CTRL+\ d for goto definition of word under cursor
" Defaults to off
" let g:cscope_map_keys = 1

" Update the cscope files on startup of cscope.
" Defaults to off
" let g:cscope_update_on_start = 1

" ########################
" local_vimrc configuration
" whitelist pintos config so we always source without asking
" call lh#local_vimrc#munge('whitelist', $HOME.'/Courses/tdiu16/pintos')
"
"
" ###############
" AYU-THEME config
" set termguicolors     " enable true colors support
"let ayucolor="light"  " for light version of theme
"let ayucolor="mirage" " for mirage version of theme
" let ayucolor="dark"   " for dark version of theme
" colorscheme ayu

" ### Gruvbox
set termguicolors     " enable true colors support
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark    " Setting dark mode
let g:gruvbox_contrast_dark = 'hard'

" #######################
" General configuration
syntax on
filetype plugin indent on
set expandtab
set shiftwidth=4
set softtabstop=4

" keep the cursor in the middle of the window at all times
" https://stackoverflow.com/questions/59408739/how-to-bring-the-marker-to-middle-of-the-screen
set scrolloff=999

" Allow hidden modified buffers, to let us navigate without prompting to save
set hidden

"set colorcolumn=81
" doesn't work in nvim?
"autocmd FileType python 2mat ErrorMsg '\%81v.'
" mark characters in the 80th column red, according to PEP-8
" https://vi.stackexchange.com/a/658
match ColorColumn "\%80v."


" colorscheme desert

" defunct?
" let pintos_vimrc_local = 0

" https://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
" When you type the first tab hit, it will complete as much as possible. The
" second tab hit will provide a list. The third and subsequent tabs will cycle
" through completion options so you can complete the file without further keys.
set wildmode=longest,list,full
set wildmenu

" cscope
set cscopeverbose
set cscopequickfix=s-,c-,d-,i-,t-,e-

" load same-folder init.vim
if filereadable("init.vim")
    if getcwd() != "/home/h/.config/nvim"
        so init.vim
    endif
endif
