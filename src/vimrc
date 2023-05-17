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

"remove textwidth for mail
autocmd Filetype mail setlocal tw=0

autocmd BufRead * if &readonly | setlocal number | endif

"
" previously this line was used to disable spell check for cli, but the color
" schemes handle cli better now
"

"autocmd Filetype c,cpp,java,html,perl,php,python,sh,xhtml if has('syntax_items') && !has('gui_running')|set nospell|endif

" Some general code ease of use settings
autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml,yaml setlocal autoindent

" set some extra syntax highlighting?
"autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml,yaml syn match LongLine '\%>79v.\+'
autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml,yaml syn match ExtraWhitespace '\s\+$'
"autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml,yaml highlight LongLine ctermbg=red guibg=red
autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml,yaml highlight ExtraWhitespace ctermbg=red guibg=red
"autocmd Filetype c,cpp,go,java,html,perl,php,python,ruby,sh,xhtml match ErrorMsg '\%>79v.\+'
"

autocmd Filetype c,cpp,go,java setlocal smartindent
autocmd Filetype c,cpp,go,java setlocal shiftwidth=4
autocmd Filetype c,cpp,go,java setlocal tabstop=4
autocmd Filetype c,cpp,java setlocal cindent
autocmd Filetype c,cpp,java setlocal cinoptions=N-s,g0,t0
autocmd Filetype c,cpp setlocal expandtab
autocmd Filetype go,java setlocal noexpandtab

autocmd Filetype python,ruby,sh,yaml setlocal shiftwidth=2
autocmd Filetype python,ruby,sh,yaml setlocal tabstop=2
autocmd Filetype python,ruby,sh,yaml setlocal smarttab
autocmd Filetype python,ruby,sh,yaml setlocal expandtab
autocmd Filetype python,ruby,sh,yaml setlocal smartindent

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

