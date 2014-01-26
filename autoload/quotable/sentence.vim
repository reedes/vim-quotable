if exists('g:loaded_quotable_sentence') && g:loaded_quotable_sentence
  fini
en
let g:loaded_quotable_sentence = 1


" sentence motion/select
function! s:select(pattern)
  call search(a:pattern, 'bc')
  let l:start = getpos('.')
  call search(a:pattern, 'ce')
  let l:end = getpos('.')
  return ['v', l:start, l:end]
endfunction

function! quotable#sentence#select_a()
  return s:select(b:quotable_sentence_re_a)
endfunction

function! quotable#sentence#select_i()
  return s:select(b:quotable_sentence_re_i)
endfunction
