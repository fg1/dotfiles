
if !has("packages")
    execute pathogen#infect('pack/plugins/start/{}')
endif

set nocompatible
set encoding=utf-8
set noerrorbells
set novisualbell

set nospell
set hidden

set nobackup
set noswapfile

if &t_Co> 2 || has("gui_running")
    syntax on
    set hlsearch

    set title
    set icon
    colorscheme molokai
endif

set autochdir
set clipboard^=unnamed

if has("statusline")
    set laststatus=2
endif

set bs=2
set ruler
set cursorline

set showcmd
set ttyfast

set wildmenu
set wildmode=list:full
set wildignore=*.swp,*.bak,*.pyc,*.class,*.log

" Autowraping for too long text
set formatoptions=tcrq
set wrapmargin=0    " Set to a number > 0 for activating

set showmatch
set matchtime=2
set incsearch
set smartcase

" Indentation
set autoindent
set copyindent

set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
"set expandtab

" Run current file if it has a shebang
function! <SID>CallInterpreter()
    if match(getline(1), '^\#!') == 0
        let l:interpreter = getline(1)[2:]
        if empty($TMUX_PANE)
            exec ("!".l:interpreter." %:p")
        else
            VimuxRunCommand(l:interpreter . " " . bufname("%"))
        endif
    else
        echohl ErrorMsg | echo "Err: No shebang present in file, canceling execution" | echohl None
    endif
endfun
map <F5> :call <SID>CallInterpreter()<CR>

filetype on
filetype plugin on
if has('autocmd')
    autocmd filetype python set tabstop=4
    autocmd filetype python set expandtab
    autocmd filetype python set list
    autocmd filetype python set listchars=tab:>.,trail:.,extends:#,nbsp:.

    autocmd filetype c nmap <F5> :make<CR>
    autocmd filetype cpp nmap <F5> :make<CR>
    autocmd filetype latex nmap <F5> :make<CR>

    autocmd BufRead,BufNewFile *.go set filetype=go

    autocmd BufRead,BufNewFile *.md set filetype=markdown
endif

let g:VimuxHeight = 50
let g:VimuxOrientation = "h"
let g:airline#extensions#tabline#enabled = 1


" Integration with fzf
if filereadable("/usr/share/doc/fzf/examples/plugin/fzf.vim")
	" Debian/Ubuntu
	set rtp+=/usr/share/doc/fzf/examples
elseif filereadable("/usr/local/opt/fzf/plugin/fzf.vim")
	" Homebrew
	set rtp+=/usr/local/opt/fzf
endif

function FZFgit()
	call fzf#run({'source': 'git ls-files', 'sink': 'e'})
endfun
command FZFgit :call FZFgit()
