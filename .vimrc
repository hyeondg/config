call plug#begin()
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'sheerun/vim-polyglot'
  Plug 'preservim/nerdtree'
call plug#end()

set nocompatible
filetype off               
filetype plugin indent on 
syntax on
set exrc
set secure
set hidden
set wildmenu
set showcmd
set softtabstop=-1
set shiftwidth=0
set tabstop=4
set expandtab
set smarttab
set smartindent
set autoindent
set number
set cinoptions=:0,l1,g0
set cindent
set hlsearch
set incsearch
set ruler
set cursorline
set ignorecase
set mouse=a
set so=5
set vb t_vb=
set statusline+=%F
set laststatus=2
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
map K <Nop>
map Q <Nop>
set backspace=indent,eol,start
set t_Co=256
set t_8b=[48;2;%lu;%lu;%lum
set t_8f=[38;2;%lu;%lu;%lum
let g:NERDTreeStatusline='%#NonText#'
let g:markdown_recommended_style=v:false
let g:python_recommended_style=v:false
let g:python_highlight_indent_errors=v:false
let g:rust_recommended_style=v:false
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.DS_Store$', '\.git$']
let g:NERDTreeWinPos="right"
highlight VertSplit term=bold cterm=none gui=bold

if exists('python_highlight_all')
    unlet python_highlight_all
endif
if exists('python_space_error_highlight')
    unlet python_space_error_highlight
endif

set background=dark
set fillchars=vert:\│

"" Colorscheme
"" ============================================================================
highlight Pmenu term=bold cterm=none ctermbg=darkgray ctermfg=None gui=bold
highlight PmenuSel term=bold cterm=none ctermbg=blue ctermfg=None gui=bold
highlight Comment ctermfg=green

if &background=="light"
  highlight StatusLine term=bold cterm=none ctermbg=255 ctermfg=none gui=bold
  highlight CursorLine term=bold cterm=none ctermbg=255 ctermfg=none gui=bold
  highlight CursorLineNr term=bold cterm=none ctermbg=255 ctermfg=black gui=bold
  highlight ColorColumn term=bold cterm=none ctermbg=255 ctermfg=none gui=bold
else
  highlight StatusLine term=bold cterm=none ctermbg=238 ctermfg=none gui=bold
  highlight CursorLine term=bold cterm=none ctermbg=238 ctermfg=none gui=bold
  highlight CursorLineNr term=bold cterm=none ctermbg=238 ctermfg=none gui=bold
  highlight LineNr term=bold cterm=none ctermbg=None ctermfg=darkgray gui=bold
  highlight ColorColumn term=bold cterm=none ctermbg=235 ctermfg=none gui=bold
endif

"" Commands
"" ============================================================================
"" Commenting blocks of code.
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,cs,rust,go,java,kotlin,scala       let b:comment_leader = '  // '
  autocmd FileType sh,ruby,python                           let b:comment_leader = '  # '
  autocmd FileType conf,fstab,s,asm                         let b:comment_leader = '  # '
  autocmd FileType tex                                      let b:comment_leader = '  % '
  autocmd FileType mail                                     let b:comment_leader = '  > '
  autocmd FileType vim                                      let b:comment_leader = '  " '
augroup END
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
