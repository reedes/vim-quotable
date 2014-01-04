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
"let s:LEVEL_BASIC     = 1
"let s:LEVEL_ADVANCED  = 2

function! s:unicode_enabled()
  return &encoding == 'utf-8'
endfunction

function! s:educateQuotes(mode)
  " intelligently insert curly quotes
  " mode=1 is double; mode=0 is single
  " Can't use simple byte offset to find previous character,
  " due to unicode characters having more than one byte!
  if a:mode
    let l:l = b:quotable_dl
    let l:r = b:quotable_dr
  else
    let l:l = b:quotable_sl
    let l:r = b:quotable_sr
  endif
  let l:mline = getline('.')
  let l:mcol = col('.')
  let l:next_chars = split(strpart(l:mline, l:mcol-1, 4), '\zs')
  let l:next_char_count = len(l:next_chars)
  let l:next_char = l:next_char_count > 0 ? l:next_chars[0] : ''
  if g:quotable#educateLevel == 2 && l:next_char ==# l:r
    " next char is the closer, where we'll skip over it
    if l:next_char_count > 1
      normal! l
    else
      startinsert!
    endif
  else
    " we'll open or close as need be
    let l:prev_chars = split(strpart(l:mline, 0, l:mcol-1), '\zs')
    let l:prev_char_count = len(l:prev_chars)
    let l:prev_char =
      \ l:prev_char_count > 0
      \ ? l:prev_chars[ l:prev_char_count - 1 ]
      \ : ''
    if l:prev_char =~# '^\(\|\s\|{\|(\|\[\|&\)$' ||
     \ l:prev_char ==# (a:mode ? b:quotable_sl : b:quotable_dl)
      let l:is_paired =
        \ g:quotable#educateLevel == 2 &&
        \   (l:next_char =~# '^\(\s\|\)$' ||
        \    l:next_char ==# (a:mode ? b:quotable_sr : b:quotable_dr))
      let @z = l:l . (l:is_paired ? l:r : '')
    else
      let l:is_paired = 0
      let @z = l:r
    endif
    let l:is_all = &virtualedit =~# 'all'
    let l:is_block = &virtualedit =~# 'block'
    let l:is_all_but_not_block = l:is_all && !l:is_block
    " Now paste the quote char(s) and move as needed
    if l:next_char_count
      " one or more characters to the right
      " Be sure to test dropping quote in middle of text
      if l:is_paired
        normal! "zgPh
      else
        normal! "zgP
      endif
    else
      " no characters to the right
      if l:is_all_but_not_block
        " avoid inserting an extra space before the pasted text
        if l:is_paired
          normal! "zgPh
        else
          normal! "zgP
        endif
      else
        normal! "zp
        if ! l:is_paired
          " need to force insert to get past entered character
          startinsert!
        endif
      endif
    endif
  endif
endfunction

function! quotable#mapKeysToEducate(...)
  " Un/Map keys to un/educate quotes for current buffer
  let b:quotable_educate_mapped = a:0 ? !!a:1 : 1
  if b:quotable_educate_mapped
    inoremap <buffer> " <C-\><C-O>:call <SID>educateQuotes(1)<CR>
    inoremap <buffer> ' <C-\><C-O>:call <SID>educateQuotes(0)<CR>
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
