scriptencoding utf-8

function! s:unicode_enabled()
  return &encoding == 'utf-8'
endfunction

function! s:educateQuotes(mode)
  " mode=1 is double; mode=0 is single
  " Can't use simple byte offset to find previous character,
  " due to unicode characters having more than one byte!
  " intelligently insert curly quotes
  if a:mode
    let l:l = g:quotable#double[0]
    let l:r = g:quotable#double[1]
    let l:al = g:quotable#single[0]
  else
    let l:l = g:quotable#single[0]
    let l:r = g:quotable#single[1]
    let l:al = g:quotable#double[0]
  endif
  let mline = getline('.')
  let mcol = col('.')
  let leading_chars = split(strpart(mline, 0, mcol-1), '\zs')
  let leading_char_count = len(leading_chars)
  let left = leading_char_count > 0
        \ ? leading_chars[ leading_char_count - 1 ]
        \ : ''
  return left =~# '^\(\|\s\|{\|(\|\[\|&\)$' || left ==# l:al
        \ ? l:l
        \ : l:r
endfunction

" set up mappings for current buffer only
function! quotable#initialize()
  if s:unicode_enabled()
    " obtain the quote pairs, per the user's configuration
    let l:dl = g:quotable#double[0]
    let l:dr = g:quotable#double[1]
    let l:sl = g:quotable#single[0]
    let l:sr = g:quotable#single[1]

    " support '%' navigation of quotable pairs
    if exists("b:match_words")
      if l:dl != l:dr
        let b:match_words .= ',' . l:dl . ':' . l:dr
      endif
      if l:sl != l:sr
        let b:match_words .= ',' . l:sl . ':' . l:sr
      endif
    endif

    " q/Q support for tpope/vim-surround
    let b:surround_113 = l:dl . '\r' . l:dr
    let b:surround_81  = l:sl . '\r' . l:sr

    " add text object support
    call textobj#user#plugin('quotable', {
    \      'double-quotation-mark': {
    \         '*pattern*': g:quotable#double,
    \         'select-a': 'aq',
    \         'select-i': 'iq'
    \      },
    \      'single-quotation-mark': {
    \         '*pattern*': g:quotable#single,
    \         'select-a': 'aQ',
    \         'select-i': 'iQ'
    \      },
    \})

    if g:quotable#educateQuotes
      inoremap <buffer> " <C-R>=<SID>educateQuotes(1)<CR>
      inoremap <buffer> ' <C-R>=<SID>educateQuotes(0)<CR>
    endif
  endif
endfunction
