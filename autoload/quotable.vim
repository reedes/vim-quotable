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

  " sentence motion
  " TODO needs markdown support
  "let s:md_start = '[_\*\[]*'    " one or more markdown chars for bold/italic/link
  "let s:md_end   = '[_\*\]]*'
  let l:re_opening_quote = '[\' . b:quotable_sl . '\' . b:quotable_dl . ']*'
  let l:re_closing_quote = '[\' . b:quotable_sr . '\' . b:quotable_dr . ']*'
  " '\v\_.{-}[\.\!\?]+\s*\zs' .
  "let b:quotable_sentence_re_i =
  "      \ '\v\s*\zs' .
  "      \ '[[:upper:]]\_.{-}[\.\!\?]+'
        " l:re_opening_quote .
        " l:re_closing_quote
"# Match a sentence ending in punctuation or EOS.\n" +
"            "[^.!?\\s]    # First char is non-punct, non-ws\n" +
"            "[^.!?]*      # Greedily consume up to punctuation.\n" +
"            "(?:          # Group for unrolling the loop.\n" +
"            "  [.!?]      # (special) inner punctuation ok if\n" +
"            "  (?!['\"]?\\s|$)  # not followed by ws or EOS.\n" +
"            "  [^.!?]*    # Greedily consume up to punctuation.\n" +
"            ")*           # Zero or more (special normal*)\n" +
"            "[.!?]?       # Optional ending punctuation.\n" +
"            "['\"]?       # Optional closing quote.\n" +
"            "(?=\\s|$)",
"            Pattern.MULTILINE | Pattern.COMMENTS);
" String regex = "^\\s+[A-Za-z,;'\"\\s]+[.?!]$"
"                "^\\s+[a-zA-Z\\s]+[.?!]$"
" ["']?[A-Z][^.?!]+((?![.?!]['"]?\s["']?[A-Z][^.?!]).)+[.?!'"]+
" ^.*?[\.!\?](?:\s|$)
" http://cpansearch.perl.org/src/SHLOMOY/Lingua-EN-Sentence-0.25/lib/Lingua/EN/Sentence.pm
" http://cpansearch.perl.org/src/NEILB/HTML-Summary-0.019/lib/Text/Sentence.pm
"
" /\(.\{-}\zsFab\)\{3}
" Finds the third occurrence of "Fab".
"
" \{-}  matches 0 or more of the preceding atom, as few as possible
" \_.*  everything up to the end of the buffer
"
" Match within a "quoted string"
" /\v"\zs[^"]+\ze"
" Negative version:
" /\v"@<=[^"]+"@=
"
"Positive lookahead:
" \@= Matches the preceding atom with zero width. {not in Vi}
"    Like "(?=pattern)" in Perl.
"    Example             matches ~
"    foo\(bar\)\@=       "foo" in "foobar"
"    foo\(bar\)\@=foo    nothing
"
"Positive lookbehind:
" \@<=  Matches with zero width if the preceding atom matches just before what
"   follows. |/zero-width| {not in Vi}
"   Like "(?<=pattern)" in Perl, but Vim allows non-fixed-width patterns.
"   Example             matches ~
"   \(an\_s\+\)\@<=file "file" after "an" and white space or an end-of-line
"
"Negative lookahead
" \@! Matches with zero width if the preceding atom does NOT match at the
"   current position. |/zero-width| {not in Vi}
"   Like "(?!pattern)" in Perl.
"   Example                 matches ~
"   foo\(bar\)\@!           any "foo" not followed by "bar"
"   a.\{-}p\@!              "a", "ap", "app", "appp", etc. not immediately
"                           followed by a "p"
"   if \(\(then\)\@!.\)*$   "if " not followed by "then"
"
"Negative lookbehind
" \@<!  Matches with zero width if the preceding atom does NOT match just
"    before what follows.  Thus this matches if there is no position in the
"    current or previous line where the atom matches such that it ends just
"    before what follows.  |/zero-width| {not in Vi}
"    Like "(?<!pattern)" in Perl, but Vim allows non-fixed-width patterns.
"    The match with the preceding atom is made to end just before the match
"    with what follows, thus an atom that ends in ".*" will work.
"    Warning: This can be slow (because many positions need to be checked
"    for a match).  Use a limit if you can, see below.
"    Example           matches ~
"    \(foo\)\@<!bar    any "bar" that's not in "foobar"
"    \(\/\/.*\)\@<!in  "in" which is not after "//"
"
" \@>  Matches the preceding atom like matching a whole pattern. {not in Vi}
"    Like "(?>pattern)" in Perl.
"    Example     matches ~
"    \(a*\)\@>a  nothing (the "a*" takes all the "a"'s, there can't be
"                another one following)
"
" /id\(_\d$\)\@=
" /\vid(_\d$)@=  (very magic)
"
  let b:quotable_sentence_re_i =
        \ '\v([[:alnum:]]\_s*)@<![[:upper:]]\_.{-}([\.\!\?]|\ze\n\n)'
  let b:quotable_sentence_re_a =
        \ b:quotable_sentence_re_i . '($|\s*)'

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
    \      'sentence-select': {
    \         'select-a': 'a' . g:quotable#sentenceMotion,
    \         'select-i': 'i' . g:quotable#sentenceMotion,
    \         '*select-a-function*': 'quotable#sentence#select_a',
    \         '*select-i-function*': 'quotable#sentence#select_i',
    \      },
    \      'sentence-move': {
    \         'pattern': b:quotable_sentence_re_i,
    \         'move-p': '(',
    \         'move-n': ')',
    \         'move-P': 'g(',
    \         'move-N': 'g)',
    \      },
    \})
  catch /E117/
    " plugin likely not installed; fail silently
  endtry

  call quotable#educate#mapKeys(l:educate)
endfunction
