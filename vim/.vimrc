set nocompatible              " be iMproved, required
filetype off                  " required
set encoding=UTF-8

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Yggdroot/indentLine'
Plugin 'junegunn/goyo.vim'
Plugin 'morhetz/gruvbox'
Plugin 'mattn/emmet-vim'
Plugin 'vimwiki/vimwiki'
Plugin 'vim/killersheep'
Plugin 'nikvdp/ejs-syntax'
Plugin 'dracula/vim', { 'name': 'dracula' }
Plugin 'sonph/onehalf', { 'rtp': 'vim' }
Plugin 'preservim/nerdtree'
Plugin 'preservim/nerdcommenter'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'ryanoasis/vim-devicons'

" All of your Plugins must be added before the following line
call vundle#end()            " required
"filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"

"Indentline plugin customizations"
let g:indentLine_char = '|'

"NERDTree customizations"
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-b> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
autocmd VimEnter * NERDTree | wincmd p " Start NERDTree and put the cursor back in the other window.
autocmd BufWinEnter * silent NERDTreeMirror " Open the existing NERDTree on each new tab.

"NERDCommenter customization
nnoremap cc :call NERDComment(0,"toggle")<CR>
vnoremap cc :call NERDComment(0,"toggle")<CR>
nnoremap cs :call NERDComment(0,"sexy")<CR>
vnoremap cs :call NERDComment(0,"sexy")<CR>


"--------------------------------------------------------NON-PLUGIN STUFF------------------------------------------------------------"

"Colors
"blue.vim      default.vim  desert.vim   evening.vim   koehler.vim  murphy.vim  peachpuff.vim  ron.vim    slate.vim  zellner.vim
"gruvbox.vim  darkblue.vim  delek.vim    elflord.vim  industry.vim  morning.vim  pablo.vim   README.txt     shine.vim  torte.vim

colorscheme onehalfdark
let g:airline_theme='onehalfdark'
"colorscheme dracula
"set bg=dark
syntax enable

"Spaces and Tabs
set expandtab  "tabs are spaces
set tabstop=4   "number of visual spaces per TAB
set softtabstop=4   "number of spaces in tab when editing
set shiftwidth=4
set smarttab
set autoindent
set smartindent

"UI Config

"Hybrid Line Numbering
set number relativenumber
:augroup numbertoggle
:   autocmd!
:   autocmd BufEnter, FocusGained, InsertLeave * set relativenumber "relative line number for non-insert mode
:   autocmd BufLeave, FocusLost, InsertEnter * set norelativenumber "absolute line number for insert mode
:augroup END

set showcmd      "show command in bottom bar
set cursorline      "highlight current line
set cursorcolumn    "for indentation
filetype indent on  "load filetype specific indent files
set wildmenu    "visual autocomplete for command menu
set showmatch   "highlight matching [{()}]

"Searching
set incsearch   "search as characters are entered
"set hlsearch    "highlight matches

"Movement
"move to beginning/end of line
nnoremap B ^
nnoremap E $

"Exit insert mode
:imap ;; <Esc>

"Enter insert mode
:nmap ;;  i

"Autobracket
:inoremap ( ()<Esc>i
:inoremap { {}<Esc>i
:inoremap [ []<Esc>i
:inoremap " ""<Esc>i
:inoremap ' ''<Esc>i

set mouse=a

"Move among tabs
map <C-Right> gt
map <C-Left> gT

" .ejs file syntax highlighting
au BufNewFile,BufRead *.ejs set filetype=html
