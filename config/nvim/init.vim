syntax on
set number
set hidden
set encoding=utf-8 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab 
set autoindent 
set smartindent
set smarttab
set cursorline
set mouse=a

call plug#begin('~/.config/nvim/plugged')
Plug 'Yggdroot/indentLine'
Plug 'preservim/tagbar'
Plug 'mhinz/vim-startify'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline' 
Plug 'vim-airline/vim-airline-themes' 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/space-vim-theme'
Plug 'liuchengxu/space-vim-dark'
Plug 'preservim/nerdtree'
Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

let g:coc_global_extensions = ["coc-json", "coc-vimlsp", "coc-marketplace", "coc-snippets", "coc-clangd", "coc-sh"]

"use tab to complete"
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"use ctrl + o 
inoremap <silent><expr> <c-o> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" IndentLine
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

""""""""""""snippets"""""""""""""""""
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)


""""""""""""colorscheme""""""""""""""
colorscheme space-vim-dark
hi Normal     ctermbg=NONE guibg=NONE
hi LineNr     ctermbg=NONE guibg=NONE
hi SignColumn ctermbg=NONE guibg=NONE
"""""""""""""""""""""""""""""""""""""

""""""""""""Airline themes""""""""""""""
let g:airline_theme='soda'
""""""""""""""""""""""""""""""""""""""""


""""""""""""NERDTree""""""""""""""""""

"""nvim startup disply
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

"""open directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

"""specific key to startup 
map <C-n> :NERDTreeToggle<CR>
"""auto closede when only left a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
""""""""""""""""""""""""""""""""""""""



""""""""ctags""""""""
"set tags=/home/yu/ws/cpp/tags
"


map <C-b> :call CompileRunGcc()<CR>
func! CompileRunGcc()
	exec "w"
	if &filetype == 'c'
		exec "!clang % -o %<"
		exec "!time ./%<"
	elseif &filetype == 'cpp'
		exec "!clang++ -std=c++2a -Wall -lpthread  % -o %<"
		exec "!time ./%<"
	elseif &filetype == 'java' 
		exec "!javac %" 
		exec "!time java %<"
	elseif &filetype == 'sh'
		:!time bash %
	elseif &filetype == 'python'
		exec "!time python %"
    elseif &filetype == 'go'
        exec "!time go run %"
    elseif &filetype == 'md'
        exec "!~/.vim/markdown.pl % > %.html &"
        exec "!chromium %.html &"
	endif
endfunc
