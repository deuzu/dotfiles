" System
" set mouse+=a
set nobackup
set noswapfile

" Keyboard
set backspace=indent,eol,start
"set iskeyword+=

" Visual
set cursorline
set scrolloff=8
set sidescrolloff=8
set showmatch
set number
set ruler
set showcmd
set nowrap
set guifont=Monospace\ 14
set textwidth=0 
set wrapmargin=0
syntax on

" Coding
set shiftround
set ignorecase
set smartcase
set tabstop=4
set shiftwidth=4
set expandtab

" Disabling arrow keys
nnoremap <Up> :echomsg "use k"<cr>
nnoremap <Down> :echomsg "use j"<cr>
nnoremap <Left> :echomsg "use h"<cr>
nnoremap <Right> :echomsg "use l"<cr>

" Vunble
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'tristen/vim-sparkup'
Plugin 'othree/html5.vim'
Plugin 'tpope/vim-surround'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'rking/ag.vim'
Plugin 'shawncplus/phpcomplete.vim'
Plugin 'joonty/vdebug'
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " Closes win when NERDTree is the last tab
autocmd BufWinEnter * NERDTreeMirro

" PHP Complete
" ctags -R --fields=+laimS --languages=php

" Vdebug
" Remote Debugger Setup                                                                                                                                                                                                                   
let g:vdebug_options = {                                                                                                                                                                                                                  
\    "port" : 80,                                                                                                                                                                                                                       
\    "timeout" : 20,                                                                                                                                                                                                                      
\    "server" : '10.0.0.10',                                                                                                                                                                                                                       
\    "on_close" : 'stop',                                                                                                                                                                                                                 
\    "break_on_open" : 0,                                                                                                                                                                                                                 
\    "ide_key" : 'XDEBUG',                                                                                                                                                                                                                
\    "debug_window_level" : 0,                                                                                                                                                                                                            
\    "debug_file_level" : 0,                                                                                                                                                                                                              
\    "debug_file" : "~/.xdebug.log",                                                                                                                                                                                                      
\    "path_maps" : {"/home/fltou/Documents/babylone/babylone-products": "/var/www/babylone-products/current"},                                                                                                                                                                   
\    "watch_window_style" : 'expanded',                                                                                                                                                                                                   
\    "marker_default" : '⬦',                                                                                                                                                                                                              
\    "marker_closed_tree" : '▸',                                                                                                                                                                                                          
\    "marker_open_tree" : '▾',                                                                                                                                                                                                            
\    "continuous_mode"  : 0                                                                                                                                                                                                               
\} 
