" Things below appear in the order in which they were introduced, which is
" basically the order in which I missed them when I moved from vim to neovim.
" That means that almost nothing is logically grouped yet. It alos means that
" the lower you go, the more experimental it gets.

call plug#begin('~/.config/nvim/bundle')

" Colors
colorscheme busybee

" Permit unsaved background buffers
set hidden

" Use system clipboard
set clipboard+=unnamedplus

" Use <space> as <leader> instead of '\'
let mapleader = ' '

" Save current buffer
nmap <silent> <leader><leader> :update<cr><c-l>

" Use the system fzf executable instead of a separate version
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" Show hidden buffers and MRU history with fzf
nnoremap <leader>l :Buffers<cr>
nnoremap <c-p> :History<cr>

" Case insensitive search
set ignorecase

Plug 'tpope/vim-surround'
Plug 'dahu/vim-fanfingtastic'

function! s:RedrawExtra()
  if expand("%") !~# '^/dev/fd/\d\+$' | checktime | endif
  diffupdate
  if exists('b:sy') && b:sy.active
    call sy#start()
  endif
endfunction

" When forcing a screen redraw:
"   - Stop highlighting current search term
"   - Update the diff
"   - Reset signs for vim-signify
nnoremap <silent> <c-l> :<c-u>nohlsearch \| call <sid>RedrawExtra()<cr><c-l>

" Save changes and unload buffer on QQ
nnoremap <silent> QQ :<c-u>update <bar> bdel<cr>
xnoremap <silent> QQ :<c-u>update <bar> bdel<cr>

function! s:ViewportMappings()
  let [ystep, xstep] = [5, 10]
  " Move viewport
  execute 'nnoremap <left> '.xstep.'zh'
  execute 'nnoremap <right> '.xstep.'zl'
  execute 'nnoremap <up> '.ystep.'<c-y>'
  execute 'nnoremap <down> '.ystep.'<c-e>'
  " Move viewport a bit faster
  execute 'nnoremap <s-left> '.xstep*3.'zh'
  execute 'nnoremap <s-right> '.xstep*3.'zl'
  execute 'nnoremap <s-up> '.ystep*3.'<c-y>'
  execute 'nnoremap <s-down> '.ystep*3.'<c-e>'
endfunction
call <sid>ViewportMappings()

Plug 'tpope/vim-unimpaired'
" Unimpaired-style mappings to toggle mouse state
nnoremap [om :set mouse=a<cr>
nnoremap ]om :set mouse=<cr>
nnoremap yom :normal <c-r>=&mouse == 'a' ? ']om' : '[om'<cr><cr>

" Number every line
set number

" Search the file system using ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep --smart-case'
nnoremap <expr> <leader>a ":Ack! -- '\\b\\b'<left><left><left>"
" Search word under cursor
nnoremap <expr> <leader>A ":Ack! -- '\\b'".expand('<cword>')."'\\b'<cr>"

function! s:GetVisualSelection()
  let orig_a = ['a', getreg('a'), getregtype('a')]
  normal! gv"ay
  let selection = [@a, getregtype('a')]
  call call('setreg', orig_a)
  return selection
endfunction

function! s:GetVisualSelectionAsRegex()
  let [value, regtype] = <sid>GetVisualSelection()
  let [p_start, p_linesep, p_end] =
        \ regtype =~ '\d\+' ? ['\V', '\.\*\n\.\*', ''] :
        \ regtype ==# 'V'   ? ['\V\^', '\n', '\$'] :
        \                     ['\V', '\n', '']
  return p_start.join(split(escape(value, '\'), "\n"), p_linesep).p_end
endfunction

function! DoSearch(expr, flags)
  let @/ = a:expr
  call histadd("/", @/)
  execute 'normal! '.(a:flags =~# 'r' ? 'N' : 'n')
endfunction

" Search for line under cursor
nnoremap <silent> <leader>n :<c-u>call DoSearch('\V\^'.escape(getline('.'), '\').'\$', '') <bar> let v:hlsearch=&hlsearch<cr>
nnoremap <silent> <leader>N :<c-u>call DoSearch('\V\^'.escape(getline('.'), '\').'\$', 'r') <bar> let v:hlsearch=&hlsearch<cr>

" Search for visual selection
xnoremap <silent> <leader>n :<c-u>call DoSearch(<sid>GetVisualSelectionAsRegex(), '') <bar> let v:hlsearch=&hlsearch<cr>
xnoremap <silent> <leader>N :<c-u>call DoSearch(<sid>GetVisualSelectionAsRegex(), 'r') <bar> let v:hlsearch=&hlsearch<cr>

" Search for word under cursor (case sensitive)
nnoremap <silent> * :<c-u>silent call DoSearch('\V\C\<'.escape(expand('<cword>'), '\').'\>', '') <bar> let v:hlsearch=&hlsearch<cr>
nnoremap <silent> # :<c-u>silent call DoSearch('\V\C\<'.escape(expand('<cword>'), '\').'\>', 'r') <bar> let v:hlsearch=&hlsearch<cr>

" Search for word under cursor (case insensitive; follows 'ignorecase')
nnoremap <silent> <leader>* *
nnoremap <silent> <leader># #

" Search for visual selection
xmap <silent> * <space>n
xmap <silent> # <space>N

" Put diff information into the sign column
Plug 'mhinz/vim-signify'

" Diff against master by default.
let g:signify_vcs_cmds = {
      \  'git': 'git diff master --no-color --no-ext-diff -U0 -- %f'
      \ }

" Auto-close quotes, parens, etc
Plug 'cohama/lexima.vim'

" Create the 'vimrc' autocmd group, used below, and immediately clear it in
" case this file is being sourced a second time
augroup vimrc | execute 'autocmd!' | augroup END

function! s:VimFileType()
  setlocal tabstop=2 shiftwidth=2 expandtab
  " Show a line at 79
  setlocal colorcolumn=79
  " Save and source current vim buffer
  nnoremap <silent> <buffer> <leader>X
        \ :silent update <bar>
        \ source % <bar>
        \ execute 'setf '.&ft <bar>
        \ PlugInstall
        \ <cr>
endfunction

autocmd vimrc FileType vim call s:VimFileType()

set listchars=nbsp:¬,tab:>-,trail:·,eol:$

" Toggle list mode
function! s:ToggleListMode()
  if !&list
    let whitespace_settings =
          \ 'filetype=' . &ft .
          \ ' tabstop=' . &ts .
          \ ' softtabstop=' . &sts .
          \ ' shiftwidth=' . &sw .
          \ (&et ? ' ' : ' no') . 'expandtab'
    echo whitespace_settings
  else
    echo
  endif
  set list!
endfunction

" Toggle list mode and look at whitespace settings
nnoremap <silent> <leader>s :call <sid>ToggleListMode()<cr>

" Credit: http://vimcasts.org/episodes/tidying-whitespace/
function! s:Preserve(command)
  " Save last search and cursor position
  let search=@/
  let [line, column] = [line("."), col(".")]
  " Do the business
  execute a:command
  " Restore previous search history and cursor position
  let @/=search
  call cursor(line, column)
endfunction

" Strip trailing whitespace
nnoremap <leader>S :call <sid>Preserve("%s/\\s\\+$//e")<cr>

" Replace unicode quotes with plain ASCII quotes
nnoremap <leader>Q :call <sid>Preserve("%s/[‘’]/'/g \| %s/[“”]/\"/g")<cr>

" Exit insert mode via Ctrl-C
inoremap <c-c> <esc>

" Persist undo history across sessions
set undofile

call plug#end()
