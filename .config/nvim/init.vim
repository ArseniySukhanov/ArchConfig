call plug#begin('~/.config/.vim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'sheerun/vim-polyglot'
Plug 'lambdalisue/fern.vim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'joshdick/onedark.vim'
Plug 'lambdalisue/fern-hijack.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'lambdalisue/fern-renderer-devicons.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-mapping-git.vim'
Plug 'yuki-yano/fern-preview.vim'
Plug 'jiangmiao/auto-pairs'
" Autocompletion
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
call plug#end()


filetype plugin on

"---Mouse---
set mouse=a

"---Line numbering---
set number
set relativenumber

"---Colors---
syntax on
colorscheme onedark

let g:lightline = {
			\ 'colorscheme': 'onedark',
			\ }

set termguicolors
 
"---Completion----------------------------------------------------
set cot=menuone,noinsert,noselect

:lua << EOF
  local lsp = require('lspconfig')
  local coq = require('coq')

  lsp.tsserver.setup{}
  lsp.tsserver.setup(coq.lsp_ensure_capabilities{})
  vim.cmd('COQnow -s')
EOF
  
"---Fern settings--------------------------------------------------
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * ++nested Fern -drawer %:h | if argc() > 0 || exists("s:std_in") | wincmd p | endif

"---Fern icons---
let g:fern#renderer = "devicons"

"---Fern preview---
function! s:fern_settings() abort
  nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
  nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
  nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
  nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
endfunction

augroup fern-settings
  autocmd!
  autocmd FileType fern call s:fern_settings()
augroup END

