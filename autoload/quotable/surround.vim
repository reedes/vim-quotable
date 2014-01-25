if exists('g:loaded_quotable_surround') && g:loaded_quotable_surround
  fini
en
let g:loaded_quotable_surround = 1

function! quotable#surround#surround(mode, visual)
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

