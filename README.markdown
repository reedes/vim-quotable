# vim-quotable

> “Extending Vim to better support typographic (‘curly’) quote characters.”

![demo](screenshots/demo.gif)

While Vim is renown for its text manipulation capabilities, it nevertheless
retains a bias towards ASCII that stretches back to its vi roots on Unix. This
can limit Vim’s appeal for those who prefer typographic characters like “curly
quotes” over ASCII "straight quotes" in the prose and documentation they write.

Features of this plugin:

* Automatic entry of ‘typographic quotes’ from the 'straight quote' keys
* Motion support for typographic quote pairs
* Matchit `%` matching for typographic quote pairs
* User can define alternative typographic quote pairs
* Support for the [vim-surround][] plugin

[vim-surround]: https://github.com/tpope/vim-surround

## Requirements

Requires a recent version of Vim compiled with Unicode support.

## Installation

Install using Pathogen, Vundle, Neobundle, or your favorite Vim package
manager.

*Strongly recommended* - To support typographic quotes as text objects, the
following dependency should be installed.

* [kana/vim-textobject-user](https://github.com/kana/vim-textobj-user) - a Vim plugin to create your own text objects without pain

## Configuration

Because you won't want typographic quotes in your code, the behavior of this
plugin can be configured per file type. For example, to enable typographic
quote support in `markdown` and `textile` files, place in your `.vimrc`:

  ```vim
  augroup quotable
    autocmd!
    autocmd FileType markdown call quotable#init()
    autocmd FileType textile call quotable#init()
    autocmd FileType python call quotable#init({ 'educate': 0 })
  augroup END
  ```

The last statement initializes the plugin for buffers of `python` file type, but
disables the ‘educate’ feature by default. More on that below.

## Educating straight quotes

This plugin will ‘educate’ quotes, meaning that it will dynamically transform
straight quote key presses (`"` or `'`) into corresponding typographic quote
characters.

For example, entering the following sentence without this plugin using the
straight quote keys:

  ```
  "It's Dr. Evil. I didn't spend six years in Evil Medical School to be called 'mister,'
  thank you very much."
  ```

As expected all the quotes are straight ones. But with this plugin, the
straight quotes are transformed into the appropriate typographic equivalent
as you type:

  ```
  “It’s Dr. Evil. I didn’t spend six years in Evil Medical School to be called ‘mister,’
  thank you very much.”
  ```

### Entering straight quotes

In some cases, straight (ASCII) quotes are needed, such as:

  ```
  “print "Hello World!"” is a simple program you can write in Python.
  ```

To insert a straight quote while educating, enter `«Ctrl-V»` before the quote key:

* `«Ctrl-V» "` - straight double quote
* `«Ctrl-V» '` - straight single quote

Note that for units of measurement you’ll want to use the prime symbol rather
than straight quotes, as in:

  ```
  Standing at 7′3″ (2.21 m), Hasheem Thabeet of the Oklahoma City Thunder is the tallest
  player in the NBA.
  ```

### Commands

You can enable (or toggle) the educating behavior with the following 
commands:

  ```vim
  QuotableEducateOn
  QuotableEducateOff
  QuotableEducateToggle
  ```

`QuotableEducateOn` will map the quote keys for transformation. Or better yet,
map to keys via your `.vimrc`:

  ```vim
  nmap <silent> <leader>q1 :QuotableEducateOn<cr>
  nmap <silent> <leader>q0 :QuotableEducateOff<cr>
  nmap <silent> <leader>qq :QuotableEducateToggle<cr>
  ```

## Motion commands

Motion commands are a powerful feature of Vim.

By default, for motion commands, `q` denotes “double” quotes and `Q` denotes
‘single’ quotes.

* `ciq` - [Change Inside “double” quotes] - excludes quote chars
* `ciQ` - [Change Inside ‘single’ quotes] - excludes quote chars
* `caq` - [Change Around “double” quotes] - includes quote chars
* `caQ` - [Change Around ‘single’ quotes] - includes quote chars

Apart from `c` for change, you can `v` for visual selection, `d` for deletion,
`y` for yanking to clipboard, etc.

If you don’t like the defaults, you can redefine these by adding the following
to your `.vimrc`, changing the motion characters as you desire:

  ```vim
  let g:quotable#doubleMotion = 'q'
  let g:quotable#singleMotion = 'Q'
  ```

## Matchit support

Matchit enables jumping to matching quotes.

* `%` - jump to the matching typographic quote character

## Surround support

This plugin supports basic surround capabilities. Add to your `.vimrc`:

  ```vim
  " NOTE: be sure to remove these mappings if using the tpope/vim-surround plugin!
  map <silent> Sq <Plug>QuotableSurroundDouble
  map <silent> SQ <Plug>QuotableSurroundSingle
  ```

Then you can use motion commands to surround your text with quotes:

(an asterisk is used to denote the cursor position)

* `visSq` - My senten*ce. => “My sentence.”
* `visSQ` - My senten*ce. => ‘My sentence.’

Alternatively, if you’ve installed Tim Pope’s [vim-surround][] plugin you also
have replace abilities on pairs of characters:

* `cs'q` - 'Hello W*orld' => “Hello World”
* `cs"q` - "Hello W*orld" => “Hello World”
* `cs(q` - (Hello W*orld) => “Hello World”
* `cs(Q` - (Hello W*orld) => ‘Hello World’

[vim-surround]: https://github.com/tpope/vim-surround

## Entering special characters

Sometimes you must enter special characters (like typographic quotes)
manually, such as in a search expression. You can do so through Vim’s digraphs
or via your operating system’s keyboard shortcuts.

| Glyph | Vim Digraph | OS X               | Description
| ----- | ----------- | ------------------ | ----------------------------
| `‘`   | `'6`        | `Opt-]`            | left single quotation mark
| `’`   | `'9`        | `Shift-Opt-]`      | right single quotation mark
| `“`   | `"6`        | `Opt-[`            | left double quotation mark
| `”`   | `"9`        | `Shift-Opt-[`      | right double quotation mark
| `‚`   | `.9`        |                    | single low-9 quote
| `„`   | `:9`        | `Shift-Opt-w`      | double low-9 quote
| `‹`   | `1<`        | `Opt-\`            | left pointing single quotation mark
| `›`   | `1>`        | `Shift-Opt-\`      | right pointing single quotation mark
| `«`   | `<<`        | `Opt-\`            | left pointing double quotation mark
| `»`   | `>>`        | `Shift-Opt-\`      | right pointing double quotation mark
| `′`   | `1'`        |                    | single prime
| `″`   | `2'`        |                    | double prime
| `–`   | `-N`        | `Opt-hyphen`       | en dash
| `—`   | `-M`        | `Shift-Opt-hyphen` | em dash
| `…`   | `..`        | `Opt-;`            | horizontal ellipsis
| ` `   | `NS`        |                    | non-breaking space
| `ï`   | `i:`        | `Opt-U` `i`        | lowercase i, umlaut
| `æ`   | `ae`        | `Opt-'`            | lowercase ae

For example, to enter left double quotation mark `“`, precede the digraph code
`"6` with `Ctrl-K`, like

* `«Ctrl-K» "6`

Alternatively, if you’re on OS X, you can enter `Opt-[` to enter this
character.

For more details, see:

* `:help digraphs`

## International support

Many international keyboards feature keys to allow you to input the desired
typographic quote directly. In such cases, you won’t need to change the
behavior of the straight quote keys.

But if you do, a standard convention is used by default:

  ```vim
  let g:quotable#doubleDefault = '“”'     " “double”
  let g:quotable#singleDefault = '‘’'     " ‘single’
  ```

Those users editing all of their prose in German may want to change their
defaults to:

  ```vim
  let g:quotable#doubleDefault = '„“'     " „doppel“
  let g:quotable#singleDefault = '‚‘'     " ‚einzel‘
  ```

International users who desire maximum control can switch between quote
pairings within a single buffer, adding the following key mappings to
their `.vimrc`:

  ```vim
  nmap <silent> <leader>qd :call quotable#init()<cr>    " forces defaults
  nmap <silent> <leader>qs :call quotable#init({ 'double':'“”', 'single':'‘’' })<cr>
  nmap <silent> <leader>qg :call quotable#init({ 'double':'„“', 'single':'‚‘' })<cr>
  nmap <silent> <leader>qx :call quotable#init({ 'double':'„”', 'single':'‚’' })<cr>
  nmap <silent> <leader>qf :call quotable#init({ 'double':'«»', 'single':'‹›' })<cr>
  ```

## See also

If you like this plugin, you might like these others from the same author:

* [vim-lexical](http://github.com/reedes/vim-lexical) - Building on Vim’s spell-check and thesaurus/dictionary completion
* [vim-litecorrect](http://github.com/reedes/vim-litecorrect) - Lightweight auto-correction for Vim
* [vim-thematic](http://github.com/reedes/vim-thematic) — Conveniently manage Vim’s appearance to suit your task and environment 
* [vim-pencil](http://github.com/reedes/vim-pencil) - Rethinking Vim as a tool for writers
* [vim-colors-pencil](http://github.com/reedes/vim-colors-pencil) — A color scheme for Vim inspired by IA Writer

* [quotable at vim.org](http://www.vim.org/scripts/script.php?script_id=4811)

## Future development

If you’ve spotted a problem or have an idea on improving this plugin,
please post it to the github project issue page.

<!-- vim: set tw=74 :-->
