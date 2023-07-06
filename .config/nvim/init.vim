" Things below appear in the order in which they were introduced, which is
" basically the order in which I missed them when I moved from vim to neovim.
" That means that almost nothing is logically grouped yet. It also means that
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

" Create the 'vimrc' autocmd group, used below, and immediately clear it in
" case this file is being sourced a second time
augroup vimrc | execute 'autocmd!' | augroup END

" Use the system fzf executable instead of a separate version
Plug '/opt/homebrew/opt/fzf'
Plug 'junegunn/fzf.vim'

" Fuzzy find hidden buffers, MRU history, and profile files (with fzf)
nnoremap <leader>l :Buffers<cr>
nnoremap <c-p> :History<cr>
nnoremap <leader>: :Commands<cr>
nnoremap <leader>t :Tags<cr>

function GetProjectRoot(flags)
  let path = finddir(".git", expand("%:p:h").";")
  let path = fnamemodify(substitute(path, ".git", "", ""), ":p:h")
  " e = escape: /foo bar -> /foo\ bar
  let path = a:flags =~# 'e' ? fnameescape(path) : path
  return path
endfun

" Switch from any fzf mode to :Files on the fly and transfer the search query.
" Inspiration: https://github.com/junegunn/fzf.vim/issues/289#issuecomment-447369414
function s:FzfFallback()
  " If possible, extract the search query from the previous fzf mode.
  " :Files queries are ignored here because they use a different, harder to
  " match prompt format.
  let line = getline('.')
  let query = substitute(line, '\v^(Hist|Buf|GitFiles|Locate)\> ?', '', '')
  let query = query != line ? query : ''
  close
  sleep 100m
  call fzf#vim#files(GetProjectRoot(''), {'options': ['-q', query]})
endfunction

function s:FzfFileType()
  tnoremap <buffer> <silent> <c-f> <c-\><c-n>:call <sid>FzfFallback()<cr>
endfunction

autocmd vimrc FileType fzf call s:FzfFileType()

" Match lower-case search inputs in a case-insensitive way
set ignorecase smartcase

Plug 'tpope/vim-surround'
Plug 'dahu/vim-fanfingtastic'

function s:RedrawExtra()
  if expand("%") !~# '^/dev/fd/\d\+$' | checktime | endif
  diffupdate
  if exists('b:sy')
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

function s:ViewportMappings()
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

function GetVisualSelection()
  " Back up the 'a' register, clobber it, and then restore it.
  let orig_a = ['a', getreg('a'), getregtype('a')]
  normal! gv"ay
  let selection = [@a, getregtype('a')]
  call call('setreg', orig_a)
  return selection
endfunction

function s:EscapeAsPythonRegex(value)
  " Escape most of the special characters for a python regex...
  " - Minus \v (vertical tab) and \f (form feed), because they're different
  "   enough and probably won't come up.
  " - Plus ", to push the result through an intermediate parser.
  " - Plus %, because Ack seems to interpret # and % as vim registers instead
  "   of literals.
  let value = escape(a:value, "()[]{}?*+-|^$\\.&~# \"%")
  for pattern in ['\t', '\r', '\n']
    let value = substitute(value, pattern, '\'.pattern, 'g')
  endfor
  return value
endfunction

function s:EscapeShellArgument(value)
  " Replace single quotes with '"'"', assuming the final value will be wrapped
  " in single quotes by the caller. This is a bit ugly.
  return substitute(a:value, "'", "'\"'\"'", 'g')
endfunction

" Search the file system using ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep --smart-case'

" Search project for word under cursor (auto-submits)
nnoremap <expr> <leader>A ":Ack! -- '\\b".<sid>EscapeAsPythonRegex(expand('<cword>'))."\\b' ".GetProjectRoot('e')."<cr>"
" Search project for any expression (doesn't auto-submit)
nnoremap <expr> <leader>a ":Ack! --literal -- '".<sid>EscapeShellArgument(input("Pattern: "))."' ".GetProjectRoot('e')."<c-f>0WWl"

" Search project for visual selection (auto-submits)
xnoremap <expr> <leader>A ":<c-u>Ack! -- \"<c-r>=<sid>EscapeAsPythonRegex(GetVisualSelection()[0])<cr>\" ".GetProjectRoot('e')."<cr>"
" Search project for visual selection (doesn't auto-submit)
xnoremap <expr> <leader>a ":<c-u>Ack! -- \"<c-r>=<sid>EscapeAsPythonRegex(GetVisualSelection()[0])<cr>\" ".GetProjectRoot('e')."<c-f>0WWl"

function s:GetVisualSelectionAsVimRegex()
  let [value, regtype] = GetVisualSelection()
  let [p_start, p_linesep, p_end] =
        \ regtype =~ '\d\+' ? ['\V', '\.\*\n\.\*', ''] :
        \ regtype ==# 'V'   ? ['\V\^', '\n', '\$'] :
        \                     ['\V', '\n', '']
  return p_start.join(split(escape(value, '\'), "\n"), p_linesep).p_end
endfunction

function DoSearch(expr, flags)
  let @/ = a:expr
  call histadd("/", @/)
  execute 'normal! '.(a:flags =~# 'r' ? 'N' : 'n')
endfunction

" Search for line under cursor
nnoremap <silent> <leader>n :call DoSearch('\V\^'.escape(getline('.'), '\').'\$', '') <bar> let v:hlsearch=&hlsearch<cr>
nnoremap <silent> <leader>N :call DoSearch('\V\^'.escape(getline('.'), '\').'\$', 'r') <bar> let v:hlsearch=&hlsearch<cr>

" Search for visual selection
xnoremap <silent> <leader>n :<c-u>call DoSearch(<sid>GetVisualSelectionAsVimRegex(), '') <bar> let v:hlsearch=&hlsearch<cr>
xnoremap <silent> <leader>N :<c-u>call DoSearch(<sid>GetVisualSelectionAsVimRegex(), 'r') <bar> let v:hlsearch=&hlsearch<cr>

" Search for word under cursor (case sensitive)
nnoremap <silent> * :silent call DoSearch('\V\C\<'.escape(expand('<cword>'), '\').'\>', '') <bar> let v:hlsearch=&hlsearch<cr>
nnoremap <silent> # :silent call DoSearch('\V\C\<'.escape(expand('<cword>'), '\').'\>', 'r') <bar> let v:hlsearch=&hlsearch<cr>

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
      \  'git': 'git diff main --no-color --no-ext-diff -U0 -- %f'
      \ }

" Orig  +Delta = Result:
" ''        +1 = 'HEAD~1'
" 'HEAD'    +1 = 'HEAD~1'
" 'HEAD~10' +1 = 'HEAD~11'
" 'HEAD^2'  +1 = 'HEAD^2~1'
" 'HEAD~1'  -1 = ''
function s:IncSignifyDiffScope(delta)
  let options = g:signify_diffoptions
  " TODO this isn't quite right; the default base is the index, not HEAD
  let base = get(options, 'git', 'HEAD')
  let parts = split(base, '\~\ze\d\+$')
  let offset = str2nr(get(parts, 1)) + a:delta
  let options.git = offset > 0 ? get(parts, 0, 'HEAD') . '~' . offset : ''
  call sy#start()
  echo 'let g:signify_diffoptions.git =' options.git
endfunction

function s:DiffMappings()
  nnoremap <silent> <up> :call <sid>IncSignifyDiffScope(-1)<cr>
  nnoremap <silent> <down> :call <sid>IncSignifyDiffScope(+1)<cr>
endfunction
nnoremap <silent> <leader>kd :call <sid>DiffMappings()<cr>

" Auto-close quotes, parens, etc
Plug 'cohama/lexima.vim'
" Lexima throws an error if you hit enter from here: [|], {|}, (|).
" https://github.com/cohama/lexima.vim/issues/97
" Disable newline rules until that's fixed.
let g:lexima_enable_newline_rules = 0

function s:VimFileType()
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
  setlocal tags+=$HOME/.config/nvim/bundle/*/tags
  setlocal tags+=/usr/local/opt/fzf/tags
endfunction

autocmd vimrc FileType vim call s:VimFileType()

set listchars=nbsp:¬,tab:>-,trail:·,eol:$

" Toggle list mode
function s:ToggleListMode()
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
function Preserve(command)
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
nnoremap <leader>S :call Preserve("%s/\\s\\+$//e")<cr>

" Replace unicode quotes with plain ASCII quotes
nnoremap <leader>Q :call Preserve("%s/[‘’]/'/g \| %s/[“”]/\"/g")<cr>

" Exit insert mode via Ctrl-C
inoremap <c-c> <esc>

" Persist undo history across sessions
set undofile

" Don't move cursor to the start of the line on gg, G, and various friends
set nostartofline

" Jump to the last known cursor position when opening a file, unless the
" position is invalid, or we're inside an event handler (happens when dropping
" a file on gvim), or when jumping to the first line, or when opening
" gitcommit or gitrebase buffers.
function s:JumpToLastKnownCursorPosition()
  if line("'\"") <= 1 | return | endif
  if line("'\"") > line("$") | return | endif
  " Ignore git commit messages and git rebase scripts.
  if expand("%") =~# '\v(^|[\/])\.git[\/]' | return | endif
  execute "normal! g`\"" |
endfunction

autocmd vimrc BufReadPost * call s:JumpToLastKnownCursorPosition()

" Avoid some "hit enter" prompts and other messages
set shortmess=astTI

" By default, indent with 2 spaces and don't use softtabstop.
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
" Deviate from that norm for some file types.
autocmd vimrc FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd vimrc FileType gitconfig setlocal noexpandtab
autocmd vimrc FileType mysql setlocal autoindent

" Don't wrap lines. If lines *are* wrapped, don't break in the middle of a
" word.
set nowrap linebreak

function s:PythonFileType()
  " Use black as the default formatter.
  setlocal equalprg=black\ -q\ -
  setlocal textwidth=88 colorcolumn=89 wrap
  nmap <buffer> <silent> <leader><leader> :update %<cr><c-l>
  " Save and run current buffer.
  nmap <leader>X <space>x
  nnoremap <buffer> <leader>x :nmap <lt>leader>X :w \\| sp +terminal!\ bpython\ -i\ ./%<lt>cr><c-f>4h
  " Add a breakpoint before the line with the cursor on it.
  nnoremap <silent> <leader>b :call Preserve("normal obreakpoint()")<cr>:update<cr><c-l>
  nnoremap <silent> <leader>B :call Preserve("normal Obreakpoint()")<cr>:update<cr><c-l>
endfunction

autocmd vimrc FileType python call s:PythonFileType()

" Auto-switch to insert in terminal buffers.
autocmd vimrc TermOpen * startinsert

Plug 'nvie/vim-flake8'

" Auto-generate tags for the active buffer's repo. Hide the output from git.
nmap <leader>T :execute "!cd ".GetProjectRoot('e')." && "
      \ "ctags -R . && "
      \ "gsed -i '/^tags$/d' .git/info/exclude && "
      \ "echo tags >> .git/info/exclude"<cr><cr>

set tags+=$HOME/src/newsela/*/tags
set tags+=$HOME/src/*/tags

" Replace the built-in python syntax highlighter with a 3rd party one,
" primarily to parse f"{}" more intelligently.
Plug 'vim-python/python-syntax'
let g:python_highlight_all = 1

" Vertically align text.
Plug 'godlygeek/tabular'

" Pretty-print JSON.
autocmd vimrc FileType json setlocal equalprg=python\ -c\ '
      \import\ sys,json,collections;
      \data=json.load(sys.stdin,object_pairs_hook=collections.OrderedDict);
      \json.dump(data,sys.stdout,indent=2,separators=(\",\",\":\ \"));
      \'

" Pretty-print SQL.
autocmd vimrc FileType sql,mysql setlocal equalprg=python\ -c\ '
      \import\ sys,sqlparse;
      \input=sys.stdin.read();
      \formatted=sqlparse.format(input,reindent=True,keyword_case=\"upper\");
      \sys.stdout.write(formatted)
      \'

" Credit: tpope
" Delete swapfiles for unmodified buffers. This means you won't get warnings
" when you load the same file in multiple vim instances.
autocmd vimrc CursorHold,BufWritePost,BufReadPost,BufLeave *
      \ if !$VIMSWAP && isdirectory(expand("<amatch>:h")) |
      \   let &swapfile = &modified |
      \ endif

function s:GetExpressionToCenterViewport()
  let expression = "zz"
  " zz doesn't center the cursor when the cursor is at or near the very top of
  " the buffer. In that situation, the 'deficit' is the number of lines by
  " which it falls short.
  let zz_deficit = max([0, winheight(0)/2 - line('.')])
  " Instead of landing smack in the middle of the screen, let's put 3/8ths of
  " the viewport above the cursor and 5/8ths below.
  let bias_lines = max([0, winheight(0)/8 - zz_deficit])
  " Do this conditionally, because 0<c-e> is secretly the same as 1<c-e>
  if bias_lines > 0
    let expression = expression.bias_lines."\<c-e>"
  endif
  return expression
endfunction

" Bias zz just a little bit towards the bottom of the screen.
nnoremap <expr> zz <sid>GetExpressionToCenterViewport()

Plug 'b4winckler/vim-angry'

Plug 'tpope/vim-repeat'

" Don't separate joined sentences by two spaces
set nojoinspaces

" SQL
" Disable <c-c> insert-mode sql mappings
let g:omni_sql_no_default_maps = 1

" Case-insensitive file name completion
set wildignorecase

" Enables Gblame
Plug 'tpope/vim-fugitive'
" Adds github handler for Gbrowse
Plug 'tpope/vim-rhubarb'

Plug 'SirVer/ultisnips'

" Make it easier to leave nvim terminal's insert mode
tnoremap <esc> <c-\><c-n>

" Insert comma after every 3 digits for number under cursor.
nmap <leader>, ciw<c-r>=substitute(@", '\v(\d)((\d\d\d)+\d@!)@=', '\1,', 'g')<cr><esc>

Plug 'kchmck/vim-coffee-script'

" Load $PWD/.nvimrc, but disallow autocmd, shell, and write commands.
set exrc secure

" Splitting the window places new window below or to the right.
set splitbelow splitright

Plug 'keith/swift.vim'

Plug 'tpope/vim-abolish'

" Prevent F12 from issuing a literal <F12> sequence in insert + command mode.
" I literally never want <F12> inserted into a file, but the macbook's
" touchbar very helpfully inserts this sequence almost every time that I try
" to use the delete key.
inoremap <f12> <nop>
cnoremap <f12> <nop>

" Pretty-print HTML.
autocmd vimrc FileType html setlocal equalprg=tidy
      \\ -indent\ -wrap\ 0
      \\ -quiet\ --show-errors\ 0
      \\ --show-body-only\ auto
      \\ --tidy-mark\ no
      \\ -
      \\ \|\|\ true

" Improve default python indentation for multi-line [], {}, () expressions.
Plug 'Vimjas/vim-python-pep8-indent'

" Improve quickfix usability (:Keep, <Left>/<Right>)
Plug 'romainl/vim-qf'
let g:qf_shorten_path = 0

Plug 'cespare/vim-toml'

" Use more context for syntax highlighting Makefiles.
autocmd FileType make syn sync minlines=500

function s:GitRebaseFileType()
  " Override Neovim's terrible built-in `K` behavior, which is `!git show`.
  " This *has* to be run after the built-in filetype handlers in order to win.
  setlocal keywordprg=:Git\ show
  " Add some highly experimental mappings that will certainly backfire any
  " minute now.
  nmap <buffer> r :Reword<cr>
  nmap <buffer> e :Edit<cr>
  nmap <buffer> f :Fixup<cr>
  nmap <buffer> s :Squash<cr>
endfunction

" Use BufWinEnter instead of FileType to configure gitrebase buffers after the
" relevant built-in handlers (ftplugin/git.vim and ftplugin/gitrebase.vim)
" have already run. Using FileType would have let them trample &keywordprg.
autocmd vimrc BufWinEnter *
      \ if &filetype == 'gitrebase' |
      \   call s:GitRebaseFileType() |
      \ elseif &filetype == 'fugitiveblame' |
      \   setlocal keywordprg=:Git\ show |
      \ endif

nnoremap <silent> ++ :call Preserve("normal gg=G")<cr>zz

" Syntax highlighting for "JSON with Comments"
Plug 'kevinoid/vim-jsonc'

" Pull up netrw on <leader>e
nnoremap <leader>e :Explore<cr>

" Don't let me make changes to a file if I don't have write access to it.
autocmd BufRead * let &l:modifiable = !&readonly

" Syntax highlighting for *.graphql, *.graphqls, and *.gql
Plug 'jparise/vim-graphql'

call plug#end()
