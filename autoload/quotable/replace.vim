if exists('g:loaded_quotable_replace') && g:loaded_quotable_replace
  fini
en
let g:loaded_quotable_replace = 1

function! quotable#replace#replace(mode, visual)
  if !exists('b:quotable_dl') | return | endif
  " Extract the target text...
  if len(a:visual) > 0
      silent normal gvy
  else
      silent normal vipy
  endif
  let l:text = getreg('')

  if a:mode ==# 0     " replace curly with straight
    let l:rtext = substitute(l:text , '[' . b:quotable_sl . b:quotable_sr . ']',"'","g")
    let l:rtext = substitute(l:rtext, '[' . b:quotable_dl . b:quotable_dr . ']','"',"g")
  else
    " a:mode ==# 1    " replace straight with curly
    let l:items = split(l:text, '\zs')
    let l:prev_char = ''
    let l:n = 0
    let l:count = len(l:items)
    while l:n < l:count
      let l:ch = l:items[l:n]
      if l:ch ==# '"'
        let l:items[l:n] = s:educate(1, l:prev_char)
      elseif l:ch ==# "'"
        let l:items[l:n] = s:educate(0, l:prev_char)
      endif
      let l:prev_char = l:ch
      let l:n += 1
    endwhile
    let l:rtext = join(l:items, '')
  endif

  " Paste back into buffer in place of original...
  call setreg('', l:rtext, mode())
  silent normal gvp
endfunction
