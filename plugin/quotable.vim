" =============================================================================
" File:        plugin/quotable.vim
" Description: TODO
" Maintainer:  Reed Esau <github.com/reedes>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" =============================================================================
"
scriptencoding utf-8

if exists('g:loaded_quotable') || &cp | finish | endif
let g:loaded_quotable = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:quotable#single')
  "  ‘single’
  let g:quotable#single = ['‘', '’']
endif

if !exists('g:quotable#double')
  "  “double”
  let g:quotable#double = ['“', '”']
endif

if !exists('g:quotable#educateQuotes')
  " translate 'straight quotes' to “quotableal quotes”
  let g:quotable#educateQuotes = 1
endif

" needed for smart quote support (via tpope/vim-sensible)
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" create mappings for current buffer only
command -nargs=0 QuotableInit  call quotable#initialize()

" wrap word/selection in curly quotes
" A simple alternative to Tim Pope's vim-surround
" TODO adapt to configured pairs
nnoremap <silent> <Plug>quotableSurroundSingle ciw‘<C-r>"’<Esc>
vnoremap <silent> <Plug>quotableSurroundSingle c‘<C-r>"’ <Esc>
nnoremap <silent> <Plug>quotableSurroundDouble ciw“<C-r>"”<Esc>
vnoremap <silent> <Plug>quotableSurroundDouble c“<C-r>"” <Esc>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:ts=2:sw=2:sts=2
