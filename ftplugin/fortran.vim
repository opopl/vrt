" Vim settings file
" Language:	Fortran90 (and Fortran95, Fortran77, F and elf90) {{{1
" Version:	0.45
" Last Change:	2006 Apr. 03
" URL:		http://www.unb.ca/chem/ajit/ftplugin/fortran.vim
" Maintainer:	Ajit J. Thakkar <ajit@unb.ca>; <http://www.unb.ca/chem/ajit/>
" Usage:	Do :help fortran-plugin from Vim
" Credits:      Useful suggestions were made by Stefano Zacchiroli

" Only do these settings when not done yet for this buffer
if exists("b:did_ftplugin") "{{{1
  finish
endif


" Don't do other file type settings for this buffer {{{1
let b:did_ftplugin = 1

" Determine whether this is a fixed or free format source file {{{1
" if this hasn't been done yet
if !exists("b:fortran_fixed_source")
  if exists("fortran_free_source")
    " User guarantees free source form
    let b:fortran_fixed_source = 0
  elseif exists("fortran_fixed_source")
    " User guarantees fixed source form
    let b:fortran_fixed_source = 1
  else
    " f90 and f95 allow both fixed and free source form
    " assume fixed source form unless signs of free source form
    " are detected in the first five columns of the first 250 lines
    " Detection becomes more accurate and time-consuming if more lines
    " are checked. Increase the limit below if you keep lots of comments at
    " the very top of each file and you have a fast computer
    let s:lmax = 250
    if ( s:lmax > line("$") )
      let s:lmax = line("$")
    endif
    let b:fortran_fixed_source = 1
    let s:ln=1
    while s:ln <= s:lmax
      let s:test = strpart(getline(s:ln),0,5)
      if s:test[0] !~ '[Cc*!#]' && s:test !~ '^ \+[!#]' && s:test =~ '[^ 0-9\t]'
	let b:fortran_fixed_source = 0
	break
      endif
      let s:ln = s:ln + 1
    endwhile
  endif
endif
" }}}1
" Set comments and textwidth according to source type {{{1
if (b:fortran_fixed_source == 1)
  setlocal comments=:!,:*,:C
  " Fixed format requires a textwidth of 72 for code
  setlocal tw=72
  setlocal tw=255
  " If you need to add "&" on continued lines so that the code is
  " compatible with both free and fixed format, then you should do so
  " in column 73 and uncomment the next line
  " setlocal tw=73
else
  setlocal comments=:!
  " Free format allows a textwidth of 132 for code but 80 is more usual
  setlocal tw=80
endif
" }}}1
" Set commentstring for foldmethod=marker {{{1
setlocal cms=!%s

" Tabs are not a good idea in Fortran so the default is to expand tabs {{{1
if !exists("fortran_have_tabs")
  setlocal expandtab
endif

" Set 'formatoptions' to break comment and text lines but allow long lines {{{1
setlocal fo+=tcql

setlocal include=^\\c#\\=\\s*include\\s\\+
setlocal suffixesadd+=.f95,.f90,.for,.f,.F,.f77,.ftn,.fpp

let s:cposet=&cpoptions
set cpoptions-=C

" Define patterns for the matchit plugin {{{1
if !exists("b:match_words")
  let s:notend = '\%(\<end\s\+\)\@<!'
  let s:notselect = '\%(\<select\s\+\)\@<!'
  let s:notelse = '\%(\<end\s\+\|\<else\s\+\)\@<!'
  let s:notprocedure = '\%(\s\+procedure\>\)\@!'
  let b:match_ignorecase = 1
  let b:match_words =
    \ '\<select\s*case\>:' . s:notselect. '\<case\>:\<end\s*select\>,' .
    \ s:notelse . '\<if\s*(.\+)\s*then\>:' .
    \ '\<else\s*\%(if\s*(.\+)\s*then\)\=\>:\<end\s*if\>,'.
    \ 'do\s\+\(\d\+\):\%(^\s*\)\@<=\1\s,'.
    \ s:notend . '\<do\>:\<end\s*do\>,'.
    \ s:notelse . '\<where\>:\<elsewhere\>:\<end\s*where\>,'.
    \ s:notend . '\<type\s*[^(]:\<end\s*type\>,'.
    \ s:notend . '\<interface\>:\<end\s*interface\>,'.
    \ s:notend . '\<subroutine\>:\<end\s*subroutine\>,'.
    \ s:notend . '\<function\>:\<end\s*function\>,'.
    \ s:notend . '\<module\>' . s:notprocedure . ':\<end\s*module\>,'.
    \ s:notend . '\<program\>:\<end\s*program\>'
endif
" }}}1
" File filters for :browse e {{{1
if has("gui_win32") && !exists("b:browsefilter")
  let b:browsefilter = "Fortran Files (*.f;*.F;*.for;*.f77;*.f90;*.f95;*.fpp;*.ftn)\t*.f;*.F;*.for;*.f77;*.f90;*.f95;*.fpp;*.ftn\n" .
    \ "All Files (*.*)\t*.*\n"
endif
" }}}1
let b:undo_ftplugin = "setl fo< com< tw< cms< et< inc<" | "{{{1
	\ . "| unlet! b:match_ignorecase b:match_words b:browsefilter"

let &cpoptions=s:cposet
unlet s:cposet
"}}}1
"

" vim:sw=2
