call plug#begin()
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'sheerun/vim-polyglot'
  Plug 'preservim/nerdtree'
  Plug 'plasticboy/vim-markdown'
  Plug 'echasnovski/mini.nvim'
  Plug 'windwp/nvim-autopairs'
  Plug 'dgagn/diagflow.nvim'

  " autocomplete
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'dcampos/nvim-snippy'
  Plug 'dcampos/cmp-snippy'

  " themes
  Plug 'folke/tokyonight.nvim'
  Plug 'catppuccin/nvim'
call plug#end()

"colorscheme default
colorscheme catppuccin-frappe

map K <Nop>
map Q <Nop>
nnoremap <c-a> :NERDTreeToggle<CR>
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

filetype plugin indent on
syntax on

set t_8b=[48;2;%lu;%lu;%lum
set t_8f=[38;2;%lu;%lu;%lum
set encoding=utf-8
set nobackup
set nowritebackup
set nofoldenable
set updatetime=300
set signcolumn=yes
set background=dark
set wildmenu
set showcmd
set softtabstop=-1
set shiftwidth=0
set tabstop=4
set expandtab
set smarttab
set smartindent
set autoindent
set cinoptions=:0,l1,g0
set showmatch
set ignorecase
set wrapscan
set splitbelow
set splitright
set mouse=a
set hlsearch
set incsearch
set completeopt=noinsert,menu,menuone,noselect
set hidden
set inccommand=split
set nu
set title
set ttimeoutlen=0
set ruler
set cursorline
set so=3
set vb t_vb=
set backspace=indent,eol,start

let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
let g:python_recommended_style=v:false
let g:python_highlight_space_errors=0

if exists('python_highlight_all')
  unlet python_highlight_all
endif
if exists('python_space_error_highlight')
  unlet python_space_error_highlight
endif
let g:rust_recommended_style=v:false
let g:airline_theme='angr'
let g:airline_section_c='%F'
let g:airline_powerline_fonts = 0
let g:airline_highlighting_cache = 1
let g:airline_extensions = []
let g:NERDTreeShowHidden = 1
let g:NERDTreeStatusline='%#NonText#'
let g:NERDTreeMinimalUI = 0
let g:NERDTreeIgnore = []
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Colorscheme
if &background=="light"
  highlight CursorLine term=bold cterm=none ctermbg=255 ctermfg=none gui=bold
  highlight CursorLineNr term=bold cterm=none ctermbg=255 ctermfg=black gui=bold
  highlight ColorColumn term=bold cterm=none ctermbg=255 ctermfg=none gui=bold
else
  highlight CursorLine term=bold cterm=none ctermbg=238 ctermfg=none gui=bold
  highlight CursorLineNr term=bold cterm=none ctermbg=238 ctermfg=none gui=bold
  highlight LineNr term=bold cterm=none ctermbg=None ctermfg=darkgray gui=bold
  highlight ColorColumn term=bold cterm=none ctermbg=237 ctermfg=none gui=bold
endif

highlight Pmenu term=bold cterm=none ctermbg=236 ctermfg=None gui=bold
highlight PmenuSel term=bold cterm=none ctermbg=darkblue ctermfg=None gui=bold
highlight Comment ctermfg=green
highlight SignColumn ctermbg=None
highlight DiagnosticFloatingError ctermfg=Red       ctermbg=238
highlight DiagnosticFloatingWarn  ctermfg=Magenta   ctermbg=238
highlight DiagnosticFloatingInfo  ctermfg=Blue      ctermbg=238
highlight DiagnosticFloatingHint  ctermfg=Green     ctermbg=238

" Commands
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,cs,rust,go,java,kotlin,scala       let b:comment_leader = '// '
  autocmd FileType sh,ruby,python,conf,fstab,s,asm          let b:comment_leader = '# '
  autocmd FileType tex                                      let b:comment_leader = '% '
  autocmd FileType mail                                     let b:comment_leader = '> '
  autocmd FileType vim                                      let b:comment_leader = '" '
  autocmd FileType lua                                      let b:commnet_leader = '-- '
augroup END
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

lua <<EOF
vim.o.updatetime = 200
local cmp = require("cmp")
local lspconfig = require("lspconfig")
require('mason').setup{}
require('mason-lspconfig').setup{}
require('mini.align').setup{}
require('mini.operators').setup{}
require('mini.surround').setup{}
require('mini.hipatterns').setup{}
require('mini.comment').setup{}
require('mini.completion').setup{}
require('mini.indentscope').setup{ draw = { delay=0, animation=function(s, n) return 0 end}, symbol = '⎸' }
require('mini.pairs').setup{}
require('mini.trailspace').setup{}
require('mini.tabline').setup{}
require('nvim-autopairs').setup{}
require('diagflow').setup({
    enable = true,
    max_width = 60,  -- The maximum width of the diagnostic messages
    max_height = 10, -- the maximum height per diagnostics
    severity_colors = {  -- The highlight groups to use for each diagnostic severity level
      error = "DiagnosticFloatingError",
      warning = "DiagnosticFloatingWarn",
      info = "DiagnosticFloatingInfo",
      hint = "DiagnosticFloatingHint",
    },
    format = function(diagnostic)
      local s = {"#e", "#w", "#i", "#h"}
      local t = diagnostic.severity
      return string.format("%s: %s;", s[t], diagnostic.message)
    end,
    gap_size = 0,
    scope = 'line', -- 'cursor', 'line' this changes the scope, so instead of showing errors under the cursor, it shows errors on the entire line.
    padding_top = 0,
    padding_right = 0,
    text_align = 'left', -- 'left', 'right'
    placement = 'top', -- 'top', 'inline'
    inline_padding_left = 1, -- the padding left when the placement is inline
    update_event = { 'DiagnosticChanged', 'BufReadPost', }, -- the event that updates the diagnostics cache
    toggle_event = { }, -- if InsertEnter, can toggle the diagnostics on inserts
    show_sign = false, -- set to true if you want to render the diagnostic sign before the diagnostic message
    render_event = { 'DiagnosticChanged', 'CursorMoved' }
})

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "snippy" },
  }
  ),
  snippet = {
    expand = function(args)
      require("snippy").lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then 
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then 
        cmp.select_prev_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"}),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
})

local servers = { 'clangd', 'pyright', 'rust_analyzer' }
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup{}
end

EOF
