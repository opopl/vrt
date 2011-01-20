" An example for a vimrc file.	{{{1
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings. }}}2
if v:progname =~? "evim" | "{{{2
  finish
endif	"}}}2
" Use Vim settings, rather then Vi settings (much better!). {{{2
" This must be first, because it changes other options as a side effect.
set nocompatible	"	}}}2
" allow backspacing over everything in insert mode {{{2
set backspace=indent,eol,start	" }}}2
if has("vms")	" {{{2
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif		" }}}2
set history=50 | set ruler | set showcmd | set incsearch | map Q gq " {{{2 
"set history=50		" keep 50 lines of command line history
"set ruler		" show the cursor position all the time
"set showcmd		" display incomplete commands
"set incsearch		" do incremental searching		

" Don't use Ex mode, use Q for formatting 
"map Q gq			}}}2
" Switch syntax highlighting on, when the terminal has colors {{{2
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif				"}}}2
" Only do this part when compiled with support for autocommands. {{{2
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")		}}}2
" OPTIONAL: This enables automatic indentation as you type. {{{2
filetype indent on	" }}}2
" OPTIONAL: Starting with Vim 7, the filetype of empty .tex {{{2 
"files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'	" }}}2
"}}}1
" lasu  {{{1
" REQUIRED. This makes vim invoke Latex-Suite 
" when you open a tex file.
filetype plugin on

" (LASU)IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*
" }}}1
"tex 	{{{1
"In addition, the following settings could go
"in your ~/.vim/ftplugin/tex.vim
"file:
" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
set sw=2
" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
"set iskeyword+=:
"
let g:Tex_ViewRule_dvi = 'xdvi'
let g:tex_flavor='latex'
" }}}1
"fld {{{ 
"Added for saving folds 
au BufWinLeave * mkview
au BufWinEnter * silent loadview

" Fold method
"set fdm=indent
"set fdm=marker	}}}
"fold macros {{{
let g:cms={
	\	'fortran': '!',
	\	'vim':	   '"',
	\	'sh':	   '#',
	\}

let g:cm=get(g:cms,&ft)

"open markers
function! InsFold(i,str)
  	let flds={
		\	'bgn': '{{{',
		\	'end': '}}}',
	      	\}
	s/$/"g:cm  flds[a:str] a:i/	
endfunction

function! App(s)
  	s/$/a:s/
endfunction

for i in range(1,6) 
 	 	nmap <silent> ;i  :call InsBeginFold(i)<CR>
 	 	nmap <silent> ;;i :call InsEndFold(i)<CR>
endfor
"}}}
"make {{{
nmap <silent> <F1> :copen<CR>
nmap <silent> <F2> :cn<CR> 
nmap <silent> <F3> :cp<CR>
nmap <silent> <F4> :make<CR>
nmap <silent> <F5> :compiler gf<CR>

" }}}
" Resizing windows {{{1

if bufwinnr(1)
   map + <C-W>+
   map - <C-W>-
   map . <C-W>>
   map , <C-W><
endif

" resize horizontal split window
nmap <C-Left> <C-W>-<C-W>-
nmap <C-Right> <C-W>+<C-W>+
" resize vertical split window
nmap <C-Up> <C-W>><C-W>>
nmap <C-Down> <C-W><<C-W><
" }}}1
" html	{{{1
"function PreviewHTML_TextOnly()
"   let l:fname = expand("%:p" )
"   new
"   set buftype=nofile nonumber
"   exe "%!lynx " . l:fname . " -dump -nolist -underscore -width " . winwidth(0)
"endfunction

   map <Leader>pht : call PreviewHTML_TextOnly()<CR>
"XMLFolding 
au BufNewFile,BufRead *.xml,*.htm,*.html so $VIMRUNTIME/ftplugin/XMLFolding.vim

" autocmd Filetype tex source ~/.Vim/auctex.vim
"
" lasu Freeze/ Unfreeze Latex-suite macros
"
"command Fr set g:Imap_FreezeImap = 1 
"command Ufr set g:Imap_FreezeImap = 0
" }}}1
" er {{{1
" gf {{{2






" }}}2
" end er }}}1
"general {{{1
nmap <silent> ;;rc :so $MYVIMRC<CR>
nmap <silent> ;;ma :set fdm=marker<CR>
nmap <silent> ;;in :set fdm=indent<CR>
nmap <silent> ;;sy :set fdm=syntax<CR>
"nmap <silent> ;;mn :set fdm=manual<CR>
nmap <silent> ;;ex :set fdm=expr<CR>
