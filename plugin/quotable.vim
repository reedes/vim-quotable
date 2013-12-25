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

if !exists('g:quotable#doubleMotion')
  let g:quotable#doubleMotion = 'q'
endif
if !exists('g:quotable#singleMotion')
  let g:quotable#singleMotion = 'Q'
endif

if !exists('g:quotable#doubleDefault')
  "  “double”
  let g:quotable#doubleDefault = '“”'
endif
if !exists('g:quotable#singleDefault')
  "  ‘single’
  let g:quotable#singleDefault = '‘’'
endif

if !exists('g:quotable#educateQuotes')
  " translate "straight quotes" to “typographical quotes”
  let g:quotable#educateQuotes = 1
endif

" needed for smart quote support (via tpope/vim-sensible)
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" works!
"nmap <Plug>quotableSurroundDouble ciwXX<c-r>"AA<esc>
"vmap <Plug>quotableSurroundDouble cXX<c-r>"BB<esc>

" worky!
"nmap <silent> <Plug>quotableSurroundDouble :call quotable#stuff('')<cr>

" worky!
"vnoremap <silent> <Plug>quotableSurroundDouble c“<C-r>"” <Esc>
"vnoremap <silent> <Plug>quotableSurroundDouble c“<C-r>"” <Esc>

" no worky
"nmap <Plug>quotableSurroundDouble <c-r>=quotable#surround(1, '')<cr>
"vmap <Plug>quotableSurroundDouble <c-r>=quotable#surround(1, 'visual')<cr>

"nmap <Plug>quotableSurroundDouble :echo "aaaa"<cr>
"vmap <Plug>quotableSurroundDouble :echo "bbbb"<cr>
"nmap <Plug>quotableSurroundDouble :call quotable#surround(1, '')<cr>
"vmap <Plug>quotableSurroundDouble :call quotable#surround(1, 'visual')<cr>
"nnoremap <silent> <Plug>quotableSurroundDouble :call quotable#surround(1, '')<cr>
"vnoremap <silent> <Plug>quotableSurroundDouble :call quotable#surround(1, 'visual')<cr>
"nnoremap <silent> <Plug>quotableSurroundSingle :call quotable#surround(0, '')<cr>
"vnoremap <silent> <Plug>quotableSurroundSingle :call quotable#surround(0, 'visual')<cr>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:ts=2:sw=2:sts=2
