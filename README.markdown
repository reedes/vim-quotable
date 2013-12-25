`vim-quotable`

`“Extend Vim to better support ‘typographic’ quote characters.” —Me`

While Vim is renown for its text editing capabilities, it nevertheless retains
a bias towards ASCII that stretches back to its roots. This can limit its
appeal to those who prefer typographic characters like “curly quotes” over
"straight quotes" in the prose or technical documentation they write.

Features of this plugin:

* Automatic entry of ‘typographic quotes’ from the 'straight quote' key
* Buffer-scoped—affects only those buffers in which you enable it
* Motion support for “double quotes” and ‘single quotes’
* Matchit `%` matching for typographic character pairs
* Support for alternative quote pairings

## Requirements

Requires Vim to be compiled with Unicode support.

A recent version of Vim may be needed to make full use of this plugin.

## Installation

Install using Pathogen, Vundle, Neobundle, or your favorite Vim package
manager.

To support typographic characters as text objects, the following dependency
must be installed.

  ```
  textobject-user (https://github.com/kana/vim-textobj-user)
  ```

## Configuration

You will typically want the capabilities of this plugin applied only to
certain file types, such as markdown or textile.

  ```
  augroup quotable
    autocmd!
    autocmd FileType markdown QuotableInit
    autocmd FileType textile QuotableInit
  augroup END
  ```

That will ensure that only buffers of the file types you specify will get
the capabilities offered by this plugin.

Alternatively, you can place the following in your
`~/.vim/after/ftplugin/markdown.vim`:

  ```
  if exists(':QuotableInit')
    QuotableInit
  endif
  ```

## Usage

### Remapping quote keys

This plugin will ‘educate’ quotes, meaning that it will dynamically
translate your straight quote key press (['] or ["]) into a corresponding
typographical quote character.

For example, entering the following sentence without this plugin:

  ```
  "I'm still infected," cautioned O'Malley.
  ```

All the quotes are straight. But with this plugin, the straight quotes you
enter are transformed into the appropriate typographical equivalent:

  ```
  “I’m still infected,” cautioned O’Malley.
  ```

However, in some cases you will want to retain the straight quote, such
as:

  ```
  “It snowed 12" overnight,” said Bob, who loathes the metric system.
  ```

To avoid expansion and insert a "straight" quote character, precede key with
`«Ctrl-V»`:

  `«Ctrl-V»'` - straight single quote
  `«Ctrl-V»"` - straight double quote

If you prefer to enter your typographical quotes manually while using the other
features of this plugin, you can disable automatic expansion by adding the
following line to your `.vimrc` file:

  ```
  let g:quotable#educateQuotes = 0
  ```

### Motion commands

Motion commands are a powerful feature of Vim.

For motion commands, `q` denotes “double” quotes and `Q` denotes ‘single’
quotes.

`ciq` - [Change Inside “double” quotes] - excludes quote chars
`ciQ` - [Change Inside ‘single’ quotes] - excludes quote chars
`caq` - [Change Around “double” quotes] - includes quote chars
`caQ` - [Change Around ‘single’ quotes] - includes quote chars

Apart from `c` for change, you can `v` for visual selection, `d` for deletion, `y` for yanking to clipboard, etc.

### Matchit support

Matchit enables jumping to matching quotes.

  `%` - jump to the matching quote character

It should work with the quote characters you’ve configured for the buffer.

### Surround support

This plugin supports basic surround capabilities. Add to your `.vimrc`:

  ```
  " NOTE: be sure to remove these mappings if using tpope/vim-surround plugin!
  map <silent> Sq <Plug>QuotableSurroundDouble
  map <silent> SQ <Plug>QuotableSurroundSingle
  ```

Then you can use motion commands to surround your text with quotes:

(an asterisk is used to denote the cursor position)

  ```
  visSq     My senten*ce. => “My sentence.”
  visSQ     My senten*ce. => ‘My sentence.’
  ```

Alternatively, if you’ve installed Tim Pope’s [vim-surround][] plugin you also
have replace abilities on pairs of characters:

  ```
  cs'q      'Hello W*orld' => “Hello World”
  cs"q      "Hello W*orld" => “Hello World”
  cs(q      (Hello W*orld) => “Hello World”
  cs(Q      (Hello W*orld) => ‘Hello World’
  ```

[vim-surround]: https://github.com/tpope/vim-surround

### Entering special characters

Sometimes you will have to enter special characters (like typographical quotes)
manually, such as in a search expression. You can do so through Vim’s digraphs
or via operating system keyboard shortcuts.

| Glyph | Digraph | OS X             | Description
| ----- | ------- | ---------------- | ----------------------------
| ‘     | '6      | Opt-`]`          | left single quotation mark
| ’     | '9      | Shift-Opt-`]`    | right single quotation mark
| “     | "6      | Opt-`[`          | left double quotation mark
| ”     | "9      | Shift-Opt-`[`    | right double quotation mark
| ‚     | .9      |                  | single low-9 quote
| „     | :9      | Shift-Opt-w      | double low-9 quote
| ‹     | 1<      | Opt-\            | left pointing single quotation mark
| ›     | 1>      | Shift-Opt-\      | right pointing single quotation mark
| «     | <<      | Opt-\            | left pointing double quotation mark
| »     | >>      | Shift-Opt-\      | right pointing double quotation mark
| –     | -N      | Opt-hyphen       | en dash
| —     | -M      | Shift-Opt-hyphen | em dash
| …     | ..      | Opt-;            | horizontal ellipsis
| ï     | i:      | Opt-U i          | lowercase i, umlaut
| æ     | ae      | Opt-'            | lowercase ae

For example, to enter left double quotation mark (“), precede the digraph code
("6) with Ctrl-K, like

  ```
  «Ctrl-K»"6
  ```

Alternatively, if you’re on OS X, you can enter Opt-`[` to enter this character.

For more details, see:

  `:help digraphs`

### International support

By default, the common convention is used:

  ```
  let g:quotable#single = ['‘','’']     " ‘single’
  let g:quotable#double = ['“','”']     " “double”
  ```

But if you’re editing prose in German, you may want

  ```
  let g:quotable#single = ['‚','‘']     " ‚einzel‘
  let g:quotable#double = ['„','“']     " „doppel“
  ```

### Switching to other quote pairs

  You may want the ability to switch quickly between quote pairs within the
  current buffer. If so, simply create key mappings to reinitialize the buffer:

  ```
  nmap <silent> <leader>rs :call quotable#initialize()<cr>
  nmap <silent> <leader>rd :call quotable#initialize('„“','‚‘')<cr>
  nmap <silent> <leader>rx :call quotable#initialize('„”','‚’')<cr>
  ```

## FAQ

Q: Why not support «guillemets» and other quote pairs?

A: For those who use these quote pairs, chances are that they appear on their
keyboard where the characters can be entered directly. There is no need to
translate from the ['] and ["] keys.

## TODO

This plugin can benefit from additional work.

* Better support for motion.
* Tools for converting between typographic and typewriter characters.
* Not working on replace or on command line.
* Right to left support.

If you have any ideas on improving this plugin, please post them to the github project issue page.

