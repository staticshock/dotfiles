" Maintainer:  Patrick J. Anderson
" Version:      1.0.1
" Last Change:  February 23, 2009
" Credits:      This is a modification of Mustang.vim color scheme

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "busybee"

" Vim >= 7.0 specific colors
hi CursorLine    guibg=#1c1c1c ctermbg=234
hi CursorColumn  guibg=#1c1c1c ctermbg=234
hi MatchParen    guifg=#d0ffc0 guibg=#1c1c1c gui=bold ctermfg=157 ctermbg=237 cterm=bold
hi Pmenu         guifg=#ffffff guibg=#1c1c1c ctermfg=255 ctermbg=238
hi PmenuSel      guifg=#000000 guibg=#b1d631 ctermfg=0 ctermbg=148

" General colors
hi Cursor        guifg=NONE    guibg=#626262 gui=none ctermbg=241
hi Normal        guifg=#e2e2e5 guibg=#1c1c1c gui=none ctermfg=253 ctermbg=234
hi NonText       guifg=#808080 guibg=#1c1c1c gui=none ctermfg=244 ctermbg=235
hi LineNr        guifg=#808080 guibg=#1c1c1c gui=none ctermfg=244 ctermbg=232
hi StatusLine    guifg=#d3d3d5 guibg=#808080 gui=none ctermfg=253 ctermbg=238
hi StatusLineNC  guifg=#939395 guibg=#808080 gui=none ctermfg=246 ctermbg=238
hi VertSplit     guifg=#444444 guibg=#808080 gui=none ctermfg=238 ctermbg=238
hi Folded        guibg=#384048 guifg=#a0a8b0 gui=none ctermbg=4 ctermfg=248
hi Title         guifg=#f6f3e8 guibg=NONE  gui=bold ctermfg=254 cterm=bold
hi Visual        guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4
hi SpecialKey    guifg=#808080 guibg=#343434 gui=none ctermfg=244 ctermbg=236
hi Search        ctermbg=black ctermfg=yellow

" Syntax highlighting
hi Comment       guifg=#808080 gui=italic ctermfg=244
hi Todo          guifg=#8f8f8f gui=none ctermfg=245
hi Boolean       guifg=#b1d631 gui=none ctermfg=148
hi String        guifg=#afd702 gui=none ctermfg=148
hi Identifier    guifg=#b1d631 gui=none ctermfg=148
hi Function      guifg=#eeeeee gui=none ctermfg=255
hi Type          guifg=#8787af gui=none ctermfg=103
hi Statement     guifg=#8787af gui=none ctermfg=103
hi Keyword       guifg=#ff9800 gui=none ctermfg=208
hi Constant      guifg=#ff9800 gui=none  ctermfg=208
hi Number        guifg=#ff9800 gui=none ctermfg=208
hi Special       guifg=#ff9800 gui=none ctermfg=208
hi PreProc       guifg=#faf4c6 gui=none ctermfg=230
hi Todo          guifg=#ff9f00 guibg=#1c1c1c gui=none

" Code-specific colors
hi pythonImport    guifg=#009000 gui=none ctermfg=255
hi pythonException guifg=#f00000 gui=none ctermfg=200
hi pythonOperator  guifg=#8787af gui=none ctermfg=103
hi pythonBuiltinFunction guifg=#009000 gui=none ctermfg=200
hi pythonExClass   guifg=#009000 gui=none ctermfg=200
