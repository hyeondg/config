-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local option = {
	spell = false,
	wrap = false,
	backup = false,
	foldenable = false,
	background = "dark",
	wildmenu = true,
	showcmd = true,
	softtabstop = -1,
	shiftwidth = 0,
	tabstop = 2,
	expandtab = true,
	smarttab = true,
	smartindent = true,
	cinoptions = ":0,l1,g0",
	showmatch = true,
	ignorecase = true,
	wrapscan = true,
	splitbelow = true,
	splitright = true,
	mouse = "nvi",
	hlsearch = true,
	completeopt = "noinsert,menu,menuone,noselect,preview",
	hidden = true,
	incsearch = true,
	inccommand = "split",
	number = true,
	relativenumber = false, -- sets vim.opt.relativenumber
	title = true,
	cursorline = true,
	scrolloff = 3,
	backspace = "indent,eol,start",
}

for k, v in pairs(option) do
	vim.opt[k] = v
end

vim.cmd([[
let g:python_recommended_style=v:false
let g:rust_recommended_style=v:false
let g:python_highlight_space_errors=0
if exists('python_highlight_all')
	unlet python_highlight_all
endif
if exists('python_space_error_highlight')
	unlet python_space_error_highlight
endif

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
  autocmd FileType lua                                      let b:comment_leader = '-- '
augroup END
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
]])
