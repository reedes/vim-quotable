" ============================================================================
" File:        quotable.vim
" Description: autoload functions for vim-quotable plugin
" Maintainer:  Reed Esau <github.com/reedes>
" Last Change: December 25, 2013
" License:     The MIT License (MIT)
" ============================================================================

scriptencoding utf-8

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
    let l:al = b:quotable_sl
  else
    let l:l = b:quotable_sl
    let l:r = b:quotable_sr
    let l:al = b:quotable_dl
  endif
  let mline = getline('.')
  let mcol = col('.')
  let leading_chars = split(strpart(mline, 0, mcol-1), '\zs')
  let leading_char_count = len(leading_chars)
  let left = leading_char_count > 0
        \ ? leading_chars[ leading_char_count - 1 ]
        \ : ''
  return left =~# '^\(\|\s\|{\|(\|\[\|&\|—\|—\|-\)$' || left ==# l:al
        \ ? l:l
        \ : l:r
endfunction

function! quotable#mapKeysToEducate(...)
  " Un/Map keys to un/educate quotes for current buffer
  if a:0
    let b:quotable_educate = a:1
  elseif !exists('b:quotable_educate')
    let b:quotable_educate = g:quotable#educateQuotesDefault
  endif
  if b:quotable_educate
    inoremap <buffer> " <C-R>=<SID>educateQuotes(1)<CR>
    inoremap <buffer> ' <C-R>=<SID>educateQuotes(0)<CR>
  else
    silent! iunmap <buffer> "
    silent! iunmap <buffer> '
  endif
endfunction

function! quotable#educateToggle()
  " Toggle educate behavior for current buffer
  let l:educate = !exists('b:quotable_educate')
            \ ? 1
            \ : !b:quotable_educate
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

  let l:args = a:0 > 0 ? a:1 : {}
  let l:double_pair = get(l:args, 'double', g:quotable#doubleDefault)
  let l:single_pair = get(l:args, 'single', g:quotable#singleDefault)
  let l:educate     = get(l:args, 'educate', g:quotable#educateQuotesDefault)

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

  call quotable#mapKeysToEducate(l:educate)
endfunction
