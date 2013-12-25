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
  return left =~# '^\(\|\s\|{\|(\|\[\|&\)$' || left ==# l:al
        \ ? l:l
        \ : l:r
endfunction

function! quotable#stuff(visual)
  if a:visual ==# 'visual'
    "exe "normal! c“\<C-r>\"” \<Esc>"
    "normal! c“<C-r>"” <Esc>
    execute "normal! c“\<C-r>\"” \<Esc>"
  else
    " works!
    exe "normal! ciw“\<c-r>\"”\<esc>"
  endif
endfunction

" worked
"nnoremap <silent> <Plug>quotableSurroundSingle ciw‘<C-r>"’<Esc>
"vnoremap <silent> <Plug>quotableSurroundSingle c‘<C-r>"’ <Esc>
"nnoremap <silent> <Plug>quotableSurroundDouble ciw“<C-r>"”<Esc>
"vnoremap <silent> <Plug>quotableSurroundDouble c“<C-r>"” <Esc>

function! quotable#surround(mode, visual)
  " mode=1 is double; mode=0 is single
  " wrap word/selection in curly quotes
  " A simple alternative to Tim Pope's vim-surround
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
    execute "normal! gvc“\<C-r>\"” \<Esc>"
  elseif a:visual ==# ''
    execute "normal! ciw“\<C-r>\"”\<Esc>"
  endif
endfunction

" set up mappings for current buffer only
" initialize buffer-scoped variables
function! quotable#initialize(...)
  if !s:unicode_enabled() | return | endif

  " obtain the quote pairs, from args or defaults
  let l:d_arg = a:0 > 0 ? split(a:1, '\zs') : []
  let l:s_arg = a:0 > 1 ? split(a:2, '\zs') : []
  let l:d_m = len(l:d_arg) == 2
  let l:s_m = len(l:s_arg) == 2
  let l:d_def = split(g:quotable#doubleDefault, '\zs')
  let l:s_def = split(g:quotable#singleDefault, '\zs')
  let l:d_n = len(l:d_def) == 2
  let l:s_n = len(l:s_def) == 2
  let b:quotable_dl = l:d_m ? l:d_arg[0] : (l:d_n ? l:d_def[0] : '“')
  let b:quotable_dr = l:d_m ? l:d_arg[1] : (l:d_n ? l:d_def[1] : '”')
  let b:quotable_sl = l:s_m ? l:s_arg[0] : (l:s_n ? l:s_def[0] : '‘')
  let b:quotable_sr = l:s_m ? l:s_arg[1] : (l:s_n ? l:s_def[1] : '’')

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
  let b:surround_113 = b:quotable_dl . '\r' . b:quotable_dr
  let b:surround_81  = b:quotable_sl . '\r' . b:quotable_sr

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

  if g:quotable#educateQuotes
    inoremap <buffer> " <C-R>=<SID>educateQuotes(1)<CR>
    inoremap <buffer> ' <C-R>=<SID>educateQuotes(0)<CR>
  endif
endfunction
