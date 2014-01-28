" ============================================================================
" File:        quotable.vim
" Description: autoload functions for vim-quotable plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Created:     December 25, 2013
" License:     The MIT License (MIT)
" ============================================================================

scriptencoding utf-8

if &cp || (exists('g:autoloaded_quotable')
      \ && !exists('g:force_reload_quotable'))
  finish
endif
let g:autoloaded_quotable = 1

" TODO support these constants
"let s:KEY_MODE_DOUBLE = 1
"let s:KEY_MODE_SINGLE = 0

function! s:unicode_enabled()
  return &encoding == 'utf-8'
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
  let l:xtra = '\ze\(\W\|$\)' " specialized closing pattern to ignore use of quote in contractions
  try
    call textobj#user#plugin('quotable', {
    \      'double-quotation-mark': {
    \         'pattern':   [ b:quotable_dl,
    \                        b:quotable_dr . (b:quotable_dr ==# '’' ? l:xtra : '') ],
    \         'select-a': 'a' . g:quotable#doubleMotion,
    \         'select-i': 'i' . g:quotable#doubleMotion,
    \      },
    \      'single-quotation-mark': {
    \         'pattern':   [ b:quotable_sl,
    \                        b:quotable_sr . (b:quotable_sr ==# '’' ? l:xtra : '') ],
    \         'select-a': 'a' . g:quotable#singleMotion,
    \         'select-i': 'i' . g:quotable#singleMotion,
    \      },
    \})
  catch /E117/
    " plugin likely not installed; fail silently
  endtry

  call quotable#educate#mapKeys(l:educate)
endfunction
