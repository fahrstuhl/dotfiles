set nocompatible              " be iMproved, required
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-salve'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-classpath'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-tbone'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rhysd/vim-clang-format'
Plug 'airblade/vim-gitgutter'
Plug 'AndrewRadev/linediff.vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'luochen1990/rainbow'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'easymotion/vim-easymotion'
Plug 'ntpeters/vim-better-whitespace'

Plug 'Matt-Deacalion/vim-systemd-syntax'
Plug 'justinmk/vim-syntax-extra'
Plug 'pseewald/vim-anyfold'

Plug 'lervag/vimtex'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

Plug 'tmhedberg/SimpylFold'
Plug 'python-rope/ropemode'
Plug 'python-rope/ropevim'
Plug 'nvie/vim-flake8'
Plug 'wilywampa/vim-ipython'

" Initialize plugin system
call plug#end()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" set leader to space
map <Space> \

if has("vms")
    set nobackup		" do not keep a backup file, use versions instead
else
    set backup		" keep a backup file
endif

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
    set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
syntax on
set hlsearch

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$") |
                \   exe "normal! g`\"" |
                \ endif

augroup END

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif
" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4
" make "tab" insert indents instead of tabs at the beginning of a line
set smarttab
" insert spaces instead of tab
set expandtab
set copyindent
set preserveindent


" set solarized color scheme
" let g:solarized_menu=0
" set termguicolors
" set background=light
colorscheme solarized

"max number of tabs opened with vim -p
set tabpagemax=50

" Show line numbers
set number
set relativenumber
autocmd InsertEnter * :set norelativenumber
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
autocmd FocusLost * :set norelativenumber
autocmd FocusLost * :set number
autocmd FocusGained * :set relativenumber

" IgnoreCase
set smartcase
set ignorecase

" split below and right, how is this not the intuitive way
set splitright
set splitbelow

"netrw
let g:netrw_liststyle = 3
let g:netrw_winsize   = 30
let g:netrw_preview   = 1
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

"folding
set foldmethod=syntax
nnoremap z<Up> zk
nnoremap z<Down> zj

" Octave syntax
augroup filetypedetect
  au! BufRead,BufNewFile *.m,*.oct set filetype=octave
augroup END

" Rust autoformat on save
let g:rustfmt_autosave = 1

" Python show docstring on fold
let g:SimpylFold_docstring_preview = 1

" commandline autocompletion
set wildmenu
set wildmode=longest:full,full
set wildignorecase

command -nargs=1 Gwm call GitWriteAndCommitWithMessage(<q-args>)")

function! GitWriteAndCommitWithMessage(message) abort
    let a:GcoArgs = "-m '" . a:message . "'"
    execute 'Gwrite'
    execute 'Gcommit' . a:GcoArgs
endfunction

" yapf
autocmd FileType python set formatprg=yapf
    
" vimtex

let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique @pdf\#src:@line@tex'

let g:vimtex_fold_enabled = 1
let g:vimtex_quickfix_open_on_warning = 0

"vim-pandoc
let g:pandoc#command#autoexec_on_writes = 0
let g:pandoc#command#autoexec_command = "Pandoc pdf"
"let g:pandoc#command#autoexec_command = "Pandoc pdf --filter pandoc-citeproc"

"modeline
set modeline
"help in new tab
cnoreabbrev <expr> help getcmdtype() == ":" && getcmdline() == 'help' ? 'tab help' : 'help'

"X11 clipboard integration
set clipboard=unnamedplus

"Rainbow parentheses
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\	'ctermfgs': [136, 125, 37, 166, 61, 64, 160, 33],
\}

let g:ycm_add_preview_to_completeopt="popup"
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:ycm_goto_buffer_command = 'split'
" let g:ycm_key_list_stop_completion = ['<Enter>']
let g:UltiSnipsExpandTrigger = '<C-j>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
nnoremap <leader>gd :YcmCompleter GoTo<CR> 
nnoremap <leader>gi :YcmCompleter GoToImplementation<CR> 
nnoremap <leader>gr :YcmCompleter GoToReferences<CR> 
" let g:ycm_semantic_triggers =  {
"   \   'c,cpp,objc': [ 're!\w{3}', '_' ],
"   \ }

nnoremap <leader>cd :lcd %:p:h<CR>

nnoremap <leader>f :Files<CR>
nnoremap <leader>r :Rg<CR>
nnoremap <leader>b :Buffers<CR>

let g:indent_guides_enable_on_vim_startup = 1
let g:better_whitespace_enabled=1
