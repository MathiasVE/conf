execute pathogen#infect()
scriptencoding utf-8
set encoding=utf-8

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible                 " Vim defaults
set bs=indent,eol,start          " Allow backspacing over everything in insert mode
set viminfo='20,\"50             " use .viminfo file (not longer then 50 lines)
set history=50                   " Max 50 vim history commands
set ruler                        " Always show the cursor

" Switch syntax highlighting on
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

filetype plugin indent on

" nice colorscheme
" execute pathogen#infect('bundle/{}')
colorscheme koehler

" list tabs and newlines
set list
set listchars=tab:>-,trail:.,precedes:<,extends:>,eol:¬

" Shade non-visible characters that might be causing problems
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

" auto reload the vimrc on safe
if has("autocmd")
	autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Handy status line.
set laststatus=2

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'powerlineish'
if has ('win32unix') && !has('gui_running')
	set guifont=DejaVu\ Sans\ Mono\ 10
	let g:airline_powerline_fonts = 1
endif
