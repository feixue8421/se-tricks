filetype plugin on
filetype indent on

set nocompatible
set autoread
set scrolloff=7
set cmdheight=2
set ruler
set hidden
set backspace=eol,start,indent
set ignorecase
set smartcase
set cursorline
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set matchtime=2
set noerrorbells
set novisualbell
set timeoutlen=500
set foldcolumn=1
set encoding=utf8
set fileformats=unix,dos,mac
set nobackup
set nowritebackup
set noswapfile
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set linebreak
set textwidth=500
set autoindent
set smartindent
set wrap
set number
set laststatus=2
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set shellcmdflag=-ic
set tags=auto.generated.ctags
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15
let mapleader = ","
let $LANG='en'

syntax enable
colorscheme darkblue

command W w !sudo tee % > /dev/null

nmap <leader>w :w!<cr>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>
map <leader>n :tn<cr>
map <leader>p :tp<cr>
map <leader>ss :setlocal spell!<cr>
map <leader>x :e! ~/.vi.buffer<cr>:w!<cr>
map <leader>z zf%
map <leader>q <Esc>:qa!<cr>
map <leader>v :Ve<cr>
map <leader><cr> :
map 0 ^
map 9 $
map <F3> <Esc>,x:% !grep -rn . --include=\*.{c,cc,cpp,h,hh,hpp} --exclude-dir={unit,models} -i -e
map <F4> yiw<F3><C-R>"<cr>:w<cr>
map <F5> :silent !make<CR>
map <F6> [I:let nr = input("choose: ")<Bar>exe "normal " . nr ."[\t"<CR>
map <F7> :silent !pwdctags >/dev/null 2>&1<CR>
map <F8> :silent !grep -rn %:h -i -e
map <F9> yiw<F8><C-R>" > ~/.vi.buffer 2>/dev/null<cr><Esc>,x

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

autocmd Filetype python set foldmethod=indent
autocmd Filetype python set foldlevel=30
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
autocmd BufWritePre *.bashrc,*.vimrc,*.txt,*.js,*.py,*.wiki,*.sh,*.coffee,*.h,*.hh,*.hpp,*.c,*.cc,*.cpp :call CleanExtraSpaces()

