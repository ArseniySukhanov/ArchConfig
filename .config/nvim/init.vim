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
Plug 'iamcco/markdown-preview.nvim',{ 'do': 'cd app && yarn install' }
" Autocompletion
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
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

"---Markdown preview---
let g:mkdp_auto_start = 1
let g:mkdp_browser = 'firefox'

"---Completion----------------------------------------------------
set cot=menuone,noinsert,noselect

let g:coq_settings = {'auto_start': v:true, 'display.preview.border': [["", "NormalFloat"],["", "NormalFloat"],["", "NormalFloat"],[" ", "NormalFloat"],["", "NormalFloat"],["", "NormalFloat"],["", "NormalFloat"],[" ", "NormalFloat"]]}
lua << EOF
local lsp_installer_servers = require('nvim-lsp-installer.servers')
local nvim_lsp = require('lspconfig')
local coq = require('coq')

local servers = {'pylsp','tsserver','vimls', 'bashls'}

for _, server_name in pairs(servers) do
  local server_available, server = lsp_installer_servers.get_server(server_name)
  if server_available then
      server:on_ready(function ()
      server:setup(coq.lsp_ensure_capabilities{})
    end)
    if not server:is_installed() then
      server:install()
    end
  end
end
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

