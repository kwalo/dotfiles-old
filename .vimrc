" --> [generals]
"
" this must be first, because it changes other options as a side effect
set nocompatible

" keep x lines of command line history
set history=150

" enable filetype plugins
filetype plugin on
filetype indent on

" Disable GUI toolbar
set guioptions-=T

" set to auto read when a file is changed from the outside
set autoread

" autowrite buffer before executing most commands
set autowrite

" have the mouse enabled all the time:
set mouse=a

" set mapleader
let mapleader = ","
let g:mapleader = ","

" fast saving
nmap <leader>w :w!<cr>
nmap <leader>q :q<cr>
nmap <leader>f :find<cr>

" Switch to prevoius buffer
nmap <leader>b :b#<cr>

" set rational tabs & co.
set expandtab
set softtabstop=4
set shiftwidth=4

" set text wraping
set textwidth=78

" --> [visuals]
"
" show the cursor position all the time
set ruler

" highlight syntax
syntax on

" show line nuber
set number

" laeve some space when moving vertical
set scrolloff=2

" always show statusline
set laststatus=2
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" set statusline=\ %F%m%r%h\ %w\ \ cwd:\ %r%{getcwd()}%h\ \ \ Line:\ %l/%L:%c

if has("gui_running")
    set guifont=Monospace\ 12
    set columns=122
    set lines=43
endif
" set some nice colors
colorscheme desert
set background=dark
hi statusline ctermfg=grey

" --> [others]
"
" display incomplete commands
set showcmd

" do incremental searching
set incsearch
set ignorecase
set hlsearch

" don't use Ex mode, use Q for formatting
map Q gq

" Completion popup menu
inoremap <expr> <c-n> pumvisible() ? "\<lt>c-n>" : "\<lt>c-n>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"
inoremap <expr> <m-;> pumvisible() ? "\<lt>c-n>" : "\<lt>c-x>\<lt>c-o>\<lt>c-n>\<lt>c-p>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>" 

" Cursor movement in Insert mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
" no sound on errors
set noerrorbells
set novisualbell
set t_vb=

" set some magic
set magic

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" set nice 'list' symbols (to actualy see them use :list)
set listchars=tab:>.,trail:.,eol:<

" set nice completion menu
set wildmenu
set wildmode=longest,full
set completeopt=longest,menu

" --> [mappings]
"
" prompt for spelllanguage and turn spellchecker on
nmap <F7> :setlocal spell spelllang=

" turn on NERDTree
nmap <leader>n :NERDTreeToggle<CR>

" quick make
map <leader>m :make<CR>

" quick :noh
map <leader>h :noh<CR>

" see list of buffers
map <leader>l <F4>

" ctags shortcut
map <leader>t :!ctags -R<CR>

" use F1 for something useful
map <F1> <esc>
imap <F1> <esc>

" Taglist
map <leader>b  :TlistToggle<CR>
map <F12>  :TlistToggle<CR>
let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Close_On_Select = 1

" --> [autocommands]
"
" for all text files set 'textwidth' to 78 characters.
au FileType text setlocal textwidth=78

" load python extended functions
"au FileType python source ~/.vim/scripts/python.vim

au FileType python compiler pyunit
au FileType python set makeprg=nosetests


" when editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ 	exe "normal g`\"" |
\ endif


" --> [functions]
"
"  diff current buffer with same file from disk
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  " new | r # | normal 1Gdd - for horizontal split
  vnew | r # | normal 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! Diff call s:DiffWithSaved()

" I don't like this any more, but don't want to remove
"
" function! CleverTab()
"     if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
"         return "\<Tab>"
"     else
"         return "\<C-N>"
" endfunction
" inoremap <Tab> <C-R>=CleverTab()<CR>
