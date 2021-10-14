" syntax hilight

set tabstop=4
set expandtab
set shiftwidth=4
set clipboard+=unnamed
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set laststatus=2
set wildmenu
set ruler
set showcmd
set laststatus=2
set number 
set title
set formatoptions=qro
set showmatch
set foldmethod=marker foldmarker={{{,}}}
set incsearch 
set hlsearch 
set encoding=utf-8
set guifont=Ricty\ 10
set pastetoggle=<F10>
set completeopt=menuone,preview

"カラースキーマを設定
colorscheme hybrid
syntax on
let g:molokai_original = 1
let g:rehash256 = 1
set background=dark

nnoremap ; :
vnoremap ; :

"paste時はブラックホールレジスタへ
vnoremap p "_dP
vnoremap <S-p> "_dP

"vim-plug Start
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'w0ng/vim-hybrid'
Plug 'tomasr/molokai'
Plug 'itchyny/lightline.vim'
Plug 'osyo-manga/vim-over'
Plug 'tpope/vim-surround'
Plug 'tell-k/vim-autopep8'
Plug 'fatih/vim-go'
Plug 'Shougo/vinarise.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'hashivim/vim-terraform'
Plug 'cohama/lexima.vim'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
"vim-plug End

" makes * and # work on visual mode too.
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" recursively vimgrep for word under cursor or selection if you hit leader-star
nmap <leader>* :execute 'noautocmd vimgrep /\V' . substitute(escape(expand("<cword>"), '\'), '\n', '\\n', 'g') . '/ **'<CR>
vmap <leader>* :<C-u>call <SID>VSetSearch()<CR>:execute 'noautocmd vimgrep /' . @/ . '/ **'<CR>

" fatih/vim-go
let g:go_highlight_functions=1
let g:go_highlight_methods=1
let g:go_highlight_structs=1
let g:go_fmt_command="goimports"

autocmd FileType go :highlight goErr cterm=bold ctermfg=214
autocmd FileType go :match goErr /\<err\>/
autocmd FileType go nmap <Leader>gi :GoImport 
autocmd FileType go nmap <Leader>gl :GoLint<CR>
autocmd FileType go nmap <leader>gr <Plug>(go-run)
autocmd FileType go nmap <leader>gb <Plug>(go-build)
autocmd FileType go nmap <leader>gt <Plug>(go-test)
" }}} fatih/vim-go

" auto comment off
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

"Terraform
let g:terraform_fmt_on_save = 1

" fzf settings
let $FZF_DEFAULT_OPTS="--layout=reverse"
let $FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**'"
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'border': 'sharp' } }

let mapleader = "\<Space>"

" fzf
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>g :GFiles<CR>
"nnoremap <silent> <leader>G :GFiles?<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>r :Rg<CR>
nnoremap <silent> <leader>G :Ghq<CR>

" Ghq
command! Ghq call s:fzf_ghq_sink()
function! s:fzf_ghq_sink(...)
    call fzf#run(fzf#wrap({
                \ 'source': 'ghq list -p',
                \ 'sink': 'e'
                \ }))
endfunction
