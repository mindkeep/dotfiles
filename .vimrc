"
" vimrc
"

set noautoindent
set nosmartindent
set nocindent
set background&
set nohlsearch
set noignorecase
set incsearch
set wrap
set linebreak
set showbreak=\ +
set spell
set ruler
set modeline
set bs=2

syntax on

"remove textwidth for mail, man this pissed me off for a while...
autocmd Filetype mail setlocal tw=0

au BufRead,BufNewFile *.part setlocal filetype=php
"au Syntax tin runtime! syntax/tintin.vim
au Syntax tin runtime! syntax/tt.vim
au BufRead,BufNewFile *.tin setlocal filetype=tintin
au BufRead,BufNewFile *.rem setlocal filetype=remind

autocmd BufRead * if &readonly | setlocal number | endif

"autocmd Filetype c,cpp,java,html,perl,php,python,sh,tintin,xhtml if has('syntax_items') && !has('gui_running')|set nospell|endif
autocmd Filetype c,cpp,java,html,perl,php,python,sh,tintin,xhtml setlocal autoindent
autocmd Filetype c,cpp,java,html,perl,php,python,sh,tintin,xhtml match ErrorMsg '\%>79v.\+'
autocmd Filetype c,cpp,java setlocal smartindent
autocmd Filetype c,cpp,java setlocal cindent

"wow.. what a PITA, never touch this!
autocmd Filetype python setlocal smarttab
autocmd Filetype python setlocal expandtab
autocmd Filetype python setlocal sw=4
autocmd Filetype python setlocal smartindent
autocmd Filetype python setlocal cinwords=dummy,if,elif,else,for,while,try,except,finally,def,class
autocmd Filetype python setlocal indentkeys-=0#
autocmd Filetype python setlocal cinkeys-=0#
autocmd Filetype python inoremap # X#
autocmd Filetype python let python_highlight_all = 1

"minibufexplorer
"let g:miniBufExplMapWindowNavVim = 1
"let g:miniBufExplMapWindowNavArrows = 1
"let g:miniBufExplMapCTabSwitchBufs = 1
"let g:miniBufExplModSelTarget = 1

" omni complete...
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
"autocmd FileType css set omnifunc=csscomplete#CompleteCSS
"autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
"autocmd FileType php set omnifunc=phpcomplete#CompletePHP
"autocmd FileType c set omnifunc=ccomplete#Complete

"if has("gui_running")
"	colorscheme torte
"else
"	"colorscheme torte
"	colorscheme desert
"	"colorscheme evening
"endif
"colorscheme desert256
colorscheme oceandeep256

