" ============================================================================
" File:        quotable.vim
" Description: autoload functions for vim-quotable plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Last Change: December 25, 2013
" License:     The MIT License (MIT)
" ============================================================================

scriptencoding utf-8

if exists("autoloaded_quotable")
  finish
endif
let autoloaded_quotable = 1

" TODO support these constants
"let s:KEY_MODE_DOUBLE = 1
"let s:KEY_MODE_SINGLE = 0

function! s:unicode_enabled()
  return &encoding == 'utf-8'
endfunction

function! s:educateQuotes(mode)
  " intelligently insert curly quotes
  " mode=1 is double; mode=0 is single
  " Can't use simple byte offset to find previous character,
  " due to unicode characters having more than one byte!
  let l:prev_chars = split(strpart(getline('.'), 0, col('.')-1), '\zs')
  let l:prev_char_count = len(l:prev_chars)
  let l:prev_char =
    \ l:prev_char_count > 0
    \ ? l:prev_chars[ l:prev_char_count - 1 ]
    \ : ''
  return
    \ l:prev_char =~# '^\(\|\s\|{\|(\|\[\|&\)$' ||
    \ l:prev_char ==# (a:mode ? b:quotable_sl : b:quotable_dl)
    \ ? (a:mode ? b:quotable_dl : b:quotable_sl)
    \ : (a:mode ? b:quotable_dr : b:quotable_sr)
endfunction

function! quotable#mapKeysToEducate(...)
  " Un/Map keys to un/educate quotes for current buffer
  let b:quotable_educate_mapped = a:0 ? !!a:1 : 1
  if !exists('b:quotable_dl')
    call quotable#init()
  endif
  if b:quotable_educate_mapped
    " For details on the leading <C-R>, see :help ins-special-special
    inoremap <buffer> " <C-R>=<SID>educateQuotes(1)<CR>
    inoremap <buffer> ' <C-R>=<SID>educateQuotes(0)<CR>
  else
    silent! iunmap <buffer> "
    silent! iunmap <buffer> '
  endif
endfunction

function! quotable#educateToggleMappings()
  " Toggle mapped keys for current buffer
  let l:educate =
    \ !exists('b:quotable_educate_mapped')
    \ ? 1
    \ : !b:quotable_educate_mapped
  call quotable#mapKeysToEducate(l:educate)
endfunction

function! quotable#surround(mode, visual)
  " A simple alternative to Tim Pope's vim-surround
  " wrap word/selection in curly quotes
  " mode=1 is double; mode=0 is single
  if !exists('b:quotable_dl') | return | endif
  if a:mode
    let l:l = b:quotable_dl
    let l:r = b:quotable_dr
  else
    let l:l = b:quotable_sl
    let l:r = b:quotable_sr
  endif
  if a:visual ==# 'v'
    " note: the gv re-establishes the visual selection that <C-u> removed
    execute "normal! gvc" . l:l . "\<C-r>\"" . l:r ." \<Esc>"
  elseif a:visual ==# ''
    execute "normal! ciw" . l:l . "\<C-r>\"" . l:r . "\<Esc>"
  endif
endfunction

" set up mappings for current buffer only
" initialize buffer-scoped variables
" args: { 'double':'“”', 'single':'‘’', 'educate':1 }
function! quotable#init(...)
  if !s:unicode_enabled() | return | endif

  let l:args = a:0 ? a:1 : {}
  let l:double_pair = get(l:args, 'double', g:quotable#doubleDefault)
  let l:single_pair = get(l:args, 'single', g:quotable#singleDefault)
  let l:educate     = get(l:args, 'educate', 1)

  " obtain the individual quote characters
  let l:d_arg = split(l:double_pair, '\zs')
  let l:s_arg = split(l:single_pair, '\zs')
  let b:quotable_dl = l:d_arg[0]
  let b:quotable_dr = l:d_arg[1]
  let b:quotable_sl = l:s_arg[0]
  let b:quotable_sr = l:s_arg[1]

  " support '%' navigation of quotable pairs
  if exists("b:match_words")
    if b:quotable_dl != b:quotable_dr
      let b:match_words .= ',' . b:quotable_dl . ':' . b:quotable_dr
    endif
    if b:quotable_sl != b:quotable_sr
      let b:match_words .= ',' . b:quotable_sl . ':' . b:quotable_sr
    endif
  endif

  " q/Q support for tpope/vim-surround
  " TODO support letters other than q/Q
  let b:surround_113 = b:quotable_dl . "\r" . b:quotable_dr
  let b:surround_81  = b:quotable_sl . "\r" . b:quotable_sr

  " add text object support
  try
    call textobj#user#plugin('quotable', {
    \      'double-quotation-mark': {
    \         '*pattern*': [ b:quotable_dl, b:quotable_dr ],
    \         'select-a': 'a' . g:quotable#doubleMotion,
    \         'select-i': 'i' . g:quotable#doubleMotion,
    \      },
    \      'single-quotation-mark': {
    \         '*pattern*': [ b:quotable_sl, b:quotable_sr ],
    \         'select-a': 'a' . g:quotable#singleMotion,
    \         'select-i': 'i' . g:quotable#singleMotion,
    \      },
    \})
  catch /E117/
    " plugin likely not installed; fail silently
  endtry

  call quotable#mapKeysToEducate(l:educate)
endfunction
