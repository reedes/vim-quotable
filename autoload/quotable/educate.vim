if exists('g:loaded_quotable_educate') && g:loaded_quotable_educate
  fini
en
let g:loaded_quotable_educate = 1

function! s:unicode_enabled()
  return &encoding == 'utf-8'
endfunction

function! s:educateQuotes(mode)
  " intelligently insert curly quotes
  " mode=1 is double; mode=0 is single
  " Can't use simple byte offset to find previous character,
  " due to unicode characters having more than one byte!
  return
  \ s:educate(a:mode,
            \ get( split(strpart(getline('.'), 0, col('.')-1), '\zs'),
            \ -1,
            \ '')
            \ )
endfunction

function! s:educate(mode, prev_char)
  return a:prev_char =~# '^\(\|\s\|r\|\n\|{\|(\|\[\|&\)$' ||
       \ a:prev_char ==# (a:mode ? b:quotable_sl : b:quotable_dl)
       \ ? (a:mode ? b:quotable_dl : b:quotable_sl)
       \ : (a:mode ? b:quotable_dr : b:quotable_sr)
endfunction

function! quotable#educate#mapKeys(...)
  " Un/Map keys to un/educate quotes for current buffer
  let b:quotable_educate_mapped = a:0 ? !!a:1 : 1
  if !exists('b:quotable_dl')
    call quotable#init()
    if !s:unicode_enabled() | return | endif
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

function! quotable#educate#toggleMappings()
  " Toggle mapped keys for current buffer
  let l:educate =
    \ !exists('b:quotable_educate_mapped')
    \ ? 1
    \ : !b:quotable_educate_mapped
  call quotable#educate#mapKeys(l:educate)
endfunction

