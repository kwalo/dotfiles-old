" File: maroloccio.vim

" Description: a colour scheme for Vim (GUI only)

" Scheme: maroloccio
" Maintainer: Marco Ippolito < m a r o l o c c i o [at] g m a i l . c o m >

" Comment: only works in GUI mode

" Version: v0.1.8, inspired by watermark
" Date: 14 December 2008
" History:
" 0.1.8 Added minimal cterm support
" 0.1.7 Uploaded to vim.org
" 0.1.6 Removed redundant highlight definitions
" 0.1.5 Improved display of folded sections
" 0.1.4 Removed linked sections for improved compatibility, more Python friendly
" 0.1.3 Removed settings which usually belong to .vimrc (as in 0.1.1)
" 0.1.2 Fixed versioning system, added .vimrc -like commands
" 0.1.1 Corrected typo in header comments, changed colour for Comment
" 0.1.0 Inital upload to vim.org

" ------------------------------------------------------------------------------

highlight clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name="maroloccio"

" ------------------------------------------------------------------------------

highlight  Normal          guifg=#8b9aaa  guibg=#1a202a  gui=none   "watermark

highlight  StatusLine      guifg=#8b9aaa  guibg=#0e1219             "maroloccio
highlight  TabLine         guifg=#8b9aaa  guibg=#0e1219             "maroloccio
highlight  WildMenu        guifg=#8b9aaa  guibg=#0e1219             "maroloccio

highlight  LineNr          guifg=#2c3138  guibg=#0e1219  gui=italic "maroloccio
highlight  VertSplit       guifg=#2c3138  guibg=#0e1219             "maroloccio
highlight  StatusLineNC    guifg=#2c3138  guibg=#0e1219             "maroloccio

highlight  Folded          guifg=#8b9aaa  guibg=#2c3138             "maroloccio
highlight  Pmenu           guifg=#8b9aaa  guibg=#2c3138             "maroloccio

highlight  Visual          guifg=#1a202a  guibg=#8b9aaa             "maroloccio
highlight  PmenuSel        guifg=#1a202a  guibg=#8b9aaa             "maroloccio
highlight  Search          guifg=#1a202a  guibg=#8b9aaa             "maroloccio
highlight  IncSearch       guifg=#1a202a  guibg=#8b9aaa             "maroloccio

highlight  Cursor          guifg=#0e1219  guibg=#8b9aaa             "maroloccio

highlight  CursorLine      guibg=#0e1219  "guifg=                   "maroloccio
highlight  CursorColumn    guibg=#0e1219  "guifg=                   "maroloccio

highlight  NonText         guifg=#2c3138  "guibg=                   "maroloccio
highlight  SpecialKey      guifg=#2c3138  "guibg=                   "maroloccio

highlight  Todo            guifg=#8f3231  guibg=#0e1219             "maroloccio
highlight  Todo            guisp=#cbc32a  gui=bold,italic,undercurl "maroloccio

highlight  Conditional     guifg=#d88e49  gui=italic     "orange    "maroloccio

highlight  Repeat          guifg=#78ba42  gui=italic     "lit green "maroloccio

highlight  Constant        guifg=#82ade0  "guibg=        "cyan      "maroloccio
highlight  String          guifg=#82ade0  "guibg=        "cyan      "maroloccio
highlight  Character       guifg=#82ade0  "guibg=        "cyan      "maroloccio
highlight  Number          guifg=#82ade0  "guibg=        "cyan      "maroloccio
highlight  Boolean         guifg=#82ade0  "guibg=        "cyan      "maroloccio
highlight  Float           guifg=#82ade0  "guibg=        "cyan      "maroloccio

highlight  Type            guifg=#cbc32a  gui=italic     "yellow    "maroloccio
highlight  StorageClass    guifg=#cbc32a  gui=italic     "yellow    "maroloccio
highlight  Structure       guifg=#cbc32a  gui=italic     "yellow    "maroloccio
highlight  Typedef         guifg=#cbc32a  gui=italic     "yellow    "maroloccio
highlight  Function        guifg=#cbc32a  gui=italic     "yellow    "maroloccio

highlight  PreProc         guifg=#107040  gui=italic     "green     "maroloccio
highlight  Include         guifg=#107040  gui=italic     "green     "maroloccio
highlight  Define          guifg=#107040  gui=italic     "green     "maroloccio
highlight  Macro           guifg=#107040  gui=italic     "green     "maroloccio
highlight  PreCondit       guifg=#107040  gui=italic     "green     "maroloccio

highlight  Error           guifg=#8b9aaa  guibg=#8f3231  "red bkgr  "maroloccio
highlight  Error           gui=italic                               "maroloccio

highlight  Underlined      gui=bold,underline            "underline "maroloccio

highlight  Exception       guifg=#8f3231  gui=italic     "red       "maroloccio

highlight  Statement       guifg=#9966ff  gui=italic     "lavender  "maroloccio

highlight  Comment         guifg=#006666  gui=italic     "teal      "maroloccio
highlight  SpecialComment  guifg=#2680af  gui=italic     "blue2     "maroloccio

highlight  Operator        guifg=#6d5279  gui=italic     "pink      "maroloccio

highlight  Special         guifg=#3741ad  gui=italic     "blue      "maroloccio
highlight  SpecialChar     guifg=#3741ad  gui=italic     "blue      "maroloccio
highlight  Tag             guifg=#3741ad  gui=italic     "blue      "maroloccio
highlight  Delimiter       guifg=#3741ad  gui=italic     "blue      "maroloccio

highlight  Label           guifg=#4e00c3  gui=italic     "purple    "maroloccio

" ------------------------------------------------------------------------------

highlight  Normal          ctermfg=lightgrey ctermbg=darkgrey

highlight  StatusLine      ctermfg=lightgrey ctermbg=black
highlight  TabLine         ctermfg=lightgrey ctermbg=black
highlight  WildMenu        ctermfg=lightgrey ctermbg=black

highlight  LineNr          ctermfg=darkgrey  ctermbg=black
highlight  VertSplit       ctermfg=darkgrey  ctermbg=black
highlight  StatusLineNC    ctermfg=darkgrey  ctermbg=black

highlight  Folded          ctermfg=lightgrey ctermbg=darkgrey
highlight  Pmenu           ctermfg=lightgrey ctermbg=darkgrey

highlight  Visual          ctermfg=darkgrey  ctermbg=lightgrey
highlight  PmenuSel        ctermfg=darkgrey  ctermbg=lightgrey
highlight  Search          ctermfg=darkgrey  ctermbg=lightgrey
highlight  IncSearch       ctermfg=darkgrey  ctermbg=lightgrey

highlight  Cursor          ctermfg=black     ctermbg=lightgrey

highlight  Todo            ctermfg=red       ctermbg=black

highlight  CursorLine      ctermbg=black     cterm=underline
highlight  CursorColumn    ctermbg=black

highlight  NonText         ctermfg=darkgrey
highlight  SpecialKey      ctermfg=darkgrey

highlight  Repeat          ctermfg=green

highlight  Constant        ctermfg=cyan
highlight  String          ctermfg=cyan
highlight  Character       ctermfg=cyan
highlight  Number          ctermfg=cyan
highlight  Boolean         ctermfg=cyan
highlight  Float           ctermfg=cyan

highlight  Type            ctermfg=yellow
highlight  StorageClass    ctermfg=yellow
highlight  Structure       ctermfg=yellow
highlight  Typedef         ctermfg=yellow
highlight  Function        ctermfg=yellow

highlight  Exception       ctermfg=red

highlight  Error           ctermbg=red
highlight  Underlined      cterm=underline

highlight  Statement       ctermfg=magenta

highlight  Comment         ctermfg=white
highlight  SpecialComment  ctermfg=white

highlight  Special         ctermfg=blue
highlight  SpecialChar     ctermfg=blue
highlight  Tag             ctermfg=blue
highlight  Delimiter       ctermfg=blue

highlight  Operator        ctermfg=darkmagenta
highlight  Label           ctermfg=darkred

" ------------------------------------------------------------------------------
