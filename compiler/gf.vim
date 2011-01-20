" Vim compiler file
" Compiler:     gfortran 
" Maintainer:   o. poplavskyy 
" Last Change:  28-05-2010 

if exists("current_compiler") "{{{1
  finish
endif
"}}}1

let current_compiler = "gf"

CompilerSet makeprg="gfortran"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
	  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet efm=
       \%E%f:%l.%c:,
       \%E%f:%l:,
       \%C,
       \%C%p%*[0123456789^],
       \%ZError:\ %m
       "\%C%.%#






"%E%f:%l.%c:Â Â  to parse "FILENAME:LINENUMBER.COLNUMBER:".
"%E%f:%l:Â Â  to parse "FILENAME:LINENUMBER:".
"%C:Â to pass over the empty line.
"%C%p%*[0123456789^]:Â Â  to get the column number from the indicator line (" 1").
"%ZError:\Â %m:Â Â  to parse the error message ("Error: ERROR_MESSAGE").
"%C%.%#:Â Â  to pass over the source code line (and ignore it).

"CompilerSet errorformat=
"        \%Omake:\ %r,
"        \%f:%l:\ warning:\ %m,
"        \%A%f:%l:\ (continued):,
"        \%W%f:%l:\ warning:,
"        \%A%f:%l:\ ,
"        \%-C\ \ \ %p%*[0123456789^]%.%#,
"        \%-C\ \ \ %.%#,
"        \%D%*\\a[%*\\d]:\ Entering\ directory\ `%f',
"          \%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f',
"        \%DMaking\ %*\\a\ in\ %f,
"        \%Z%m

let &cpo = s:cpo_save
unlet s:cpo_save
