" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/vissort.vim	[[[1
261
" vissort.vim
"  Author:	Charles E. Campbell, Jr.
"			BISort() by Piet Delport
"  Date:	Sep 27, 2006
"  Version:	4c	ASTRO-ONLY

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_vissort")
 finish
endif
let g:loaded_vissort = "v4c"
let s:keepcpo        = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -range -nargs=0		Bisort		silent <line1>,<line2>call s:BISort()
com! -range -nargs=0 -bang	Vissort		silent <line1>,<line2>call s:VisSort(<bang>0)
com! -range -nargs=*		BS			silent <line1>,<line2>call BlockSort(<f-args>)
com! -range -nargs=*		CFuncSort	silent <line1>,<line2>call BlockSort('','^}','^[^/*]\&^[^ ][^*]\&^.*\h\w*\s*(','^.\{-}\(\h\w*\)\s*(.*$','')

" ---------------------------------------------------------------------
" BISort: Piet Delport's BISort2() function, modified to take a range {{{1
fun! s:BISort() range
  let i = a:firstline + 1
  while i <= a:lastline
    " find insertion point via binary search
    let i_val = getline(i)
    let lo    = a:firstline
    let hi    = i
    while lo < hi
      let mid     = (lo + hi) / 2
      let mid_val = getline(mid)
      if i_val < mid_val
        let hi = mid
      else
        let lo = mid + 1
        if i_val == mid_val | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfun

" ---------------------------------------------------------------------
" VisSort:  sorts lines based on visual-block selected portion of the lines {{{1
" Author: Charles E. Campbell, Jr.
fun! s:VisSort(isnmbr) range
"  call Dfunc("VisSort(isnmbr=".a:isnmbr.")")
  if visualmode() != "\<c-v>"
   " no visual selection, just plain sort it
   if v:version < 700
    exe a:firstline.",".a:lastline."Bisort"
   else
    exe "silent ".a:firstline.",".a:lastline."sort"
   endif
"   call Dret("VisSort : no visual selection, just plain sort it")
   return
  endif

  " do visual-block sort
  "   1) yank a copy of the visual selected region
  "   2) place @@@ at the beginning of every line
  "   3) put a copy of the yanked region at the beginning of every line
  "   4) sort lines
  "   5) remove ^...@@@  from every line
  let firstline= line("'<")
  let lastline = line("'>")
  let keeprega = @a
  silent norm! gv"ay

  " prep
  '<,'>s/^/@@@/
  silent norm! '<0"aP
  if a:isnmbr
   silent! '<,'>s/^\s\+/\=substitute(submatch(0),' ','0','g')/
  endif
  if v:version < 700
   '<,'>Bisort
  else
   silent '<,'>sort
  endif

  " cleanup
  exe "silent ".firstline.",".lastline.'s/^.\{-}@@@//'

  let @a= keeprega
"  call Dret("VisSort")
endfun

" ---------------------------------------------------------------------
" BlockSort: Uses either vim-v7's built-in sort or, for vim-v6, Piet Delport's {{{1
"            binary-insertion sort, to sort blocks of text based on tags
"            contained within them.
"              nextblock : text to search() to find the beginning of next block
"                          "" means to use the line following the endblock pattern
"              endblock  : text to search() to find end-of-current block
"                          "" means use just-before-the-nextblock
"              findtag   : text to search() to find the tag in the current block.
"                          "" means the nextblock began with the tag
"              tagpat    : text to use in substitute() to specify tag pattern
"              			   "" means to use "^.*$"
"              tagsub    : text to use in substitute() to eliminate non-tag
"                          from tag pattern
"                          "" means: if tagpat == "": use '&'
"                                    else             use '\1'
"
"  Usage:
"      :[range]call BlockSort(nextblock,endblock,findtag,tagpat,tagsub)
"
"      Any missing arguments will be queried for
"
" With endblock specified, text is allowed in-between blocks;
" such text will remain in-between the sorted blocks
fun! BlockSort(...) range

  " get input from argument list or query user
  let vars="nextblock,endblock,findtag,tagpat,tagsub"
  let ivar= 1
  while ivar <= 5
   let var = substitute(vars,'^\([^,]\+\),.*$','\1','e')
   let vars= substitute(vars,'^[^,]\+,\(.*\)$','\1','e')
"   call Decho("var<".var."> vars<".vars."> ivar=".ivar." a:0=".a:0)
   if ivar <= a:0
"	call Decho("(arglist) let ".var."='".a:{ivar}."'")
	exe "let ".var."='".a:{ivar}."'"
   else
   	let inp= input("Enter ".var.": ")
"	call Decho("(input)   let ".var."='".inp."'")
	exe "let ".var."='".inp."'"
   endif
   let ivar= ivar + 1
  endwhile

  " sanity check
  if nextblock == "" && endblock == ""
   echoerr "BlockSort: both nextblock and endblock patterns are empty strings"
   return
  endif

  " defaults for tagpat and tagsub
  if tagpat == ""
   let tagpat= '^.*$'
   if tagsub == ""
   	let tagsub= '&'
   endif
  endif
  if tagsub == ""
   let tagsub= '\1'
  endif
"  call Decho("nextblock<".nextblock."> endblock<".endblock."> findtag<".findtag."> tagpat<".tagpat."> tagsub<".tagsub.">")

  " don't allow wrapping around the end-of-file during searches
  " I put an empty "guard line" at the end to take care of fencepost issues
  " Its removed at the end of the function
  let akeep  = @a
  let wskeep = &ws
  set nows
  set lz
  let tagcnt = 0
  $put =''
  call cursor(a:firstline,1)
"  call Decho("block sorting range[".a:firstline.",".a:lastline."]")

  " extract tag information: blocktag blockbgn blockend
  let i= a:firstline
  while 0 < i && i < a:lastline
   let tagcnt = tagcnt + 1
   let inxt   = 0
   call cursor(i,1)

   " find tag
   if findtag != ""
    let t= search(findtag)
	if t == 0
	 echoerr "unable to find tag in block starting at line ".i
	 return
	endif
   endif
   let blocktag{tagcnt} = substitute(getline("."),tagpat,tagsub,"")." ".tagcnt
   let blockbgn{tagcnt} = i

   " find end-of-block and nextblock
   if endblock == ""
   	let blockend{tagcnt} = search(nextblock)
   	let inxt             = blockend{tagcnt}
    if blockend{tagcnt} == 0
     let blockend{tagcnt}= a:lastline
	else
   	 let blockend{tagcnt} = blockend{tagcnt} - 1
    endif
   else
   	let blockend{tagcnt}= search(endblock)
    if blockend{tagcnt} == 0
      let blockend{tagcnt} = a:lastline
     elseif nextblock == ""
	  let inxt= blockend{tagcnt} + 1
	 else
      let inxt = search(nextblock)
    endif
   endif

   " save block text
   exe "silent ".blockbgn{tagcnt}.",".blockend{tagcnt}."y a"
   let blocktxt{tagcnt}= @a
   
"   call Decho("tag<".blocktag{tagcnt}."> block[".blockbgn{tagcnt}.",".blockend{tagcnt}."] i=".i." inxt=".inxt)
   let i= inxt
  endwhile

  " set up a temporary buffer+window with sorted tags
  new
  set buftype=nofile
  let i= 1
  while i <= tagcnt
   put =blocktag{i}
   let i= i + 1
  endwhile
  1d
  if v:version >= 700
   %sort
  else
   1,$call s:BISort()
  endif
  let i= 1
  while i <= tagcnt
   let blocksrt{i}= substitute(getline(i),'^.* \(\d\+\)$','\1','')
"   call Decho("blocksrt{".i."}=".blocksrt{i}." <".blocktag{blocksrt{i}}.">")
   let i = i + 1
  endwhile
  q!

  " delete blocks and insert sorted blocks
  while tagcnt > 0
   exe "silent ".blockbgn{tagcnt}.",".blockend{tagcnt}."d"
   silent put! =blocktxt{blocksrt{tagcnt}}
   let tagcnt= tagcnt - 1
  endwhile

  " cleanup: restore setting(s) and register(s)
  let &ws= wskeep
  let @a = akeep
  set nolz
  $d
  call cursor(a:firstline,1)
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim:ts=4 fdm=marker
doc/vissort.txt	[[[1
232
*vissort.txt*	Visual-Mode Based Sorting		Aug 25, 2004

Authors:  Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamilyA.Mbiz>
	  Piet Delport (BISort())
Copyright: (c) 2004-2005 by Charles E. Campbell, Jr.	*vissort-copyright*
           The VIM LICENSE applies to vissort.vim and vissort.txt
           (see |copyright|) except use "vissort" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.

	  (remove NOSPAM from Campbell's email first)

==============================================================================
1. Contents						*vissort-contents*

	1. Contents.......................................: |vissort-contents|
	2. Bisort.........................................: |bisort|
	3. Vissort..(sorting lines based on a column).....: |vissort|
	4. Sorting A Column Only..........................: |vissort-column|
	5. BlockSort......................................: |blocksort|

==============================================================================
2. Bisort : binary search sort					*bisort*

   :[range]Bisort

   Applies an in-place binary-search sort.  Generally its faster than
   quicksort with Vim since its using Vim's interpreter.

   EXAMPLES

	Original Text:
	one      two      three   four
	five     six      seven   eight
	nine     ten      eleven  twelve
	thirteen fourteen fifteen sixteen

	Use Visual-Line (V) mode to select text, then Bisort - sorts lines:
		V to select lines
		:Bisort
	five     six      seven   eight
	nine     ten      eleven  twelve
	one      two      three   four
	thirteen fourteen fifteen sixteen

	Use <vis.vim>'s B command with Bissort - sorts the column only:
	    ctrl-v to select column
	    :'<,'>B Bisort
	one      fourteen three   four
	five     six      seven   eight
	nine     ten      eleven  twelve
	thirteen two      fifteen sixteen


==============================================================================
3. Vissort     							*vissort*
>
	sorting lines based on selected column
<
   :[range]Vissort   actually same as Bisort
   :'<,'>Vissort     apply sort to visual-block only

   Select a block of text with visual-block mode; use the Vissort command to
   sort the block.  This function sorts the lines *based on the selected
   column*.

   EXAMPLE

	Original Text:
	one      two      three   four
	five     six      seven   eight
	nine     ten      eleven  twelve
	thirteen fourteen fifteen sixteen

	Use ctrl-v (Visual-Block) to select two..fourteen column,
	then Vissort:
	thirteen fourteen fifteen sixteen
	five     six      seven   eight
	nine     ten      eleven  twelve
	one      two      three   four


==============================================================================
4. Sorting A Column Only				*vissort-column*
>
	sorting a column independently of the surrounding lines
<
   |vissort| provides the ability to sort lines based on a column; the
   technique described here allows one to sort columns independently of any
   line contents surrounding the column.

   To accomplish this you'll also need the <vis.vim> script; you may acquire
   a copy at:
>
	http://mysite.verizon.net/astronaut/vim/index.html#VimFuncs
	as "Visual Block Commands"
<
   This topic is also covered by the tip:
>
   http://vim.sourceforge.net/tips/tip.php?tip_id=588
<
   Select the column using |blockwise-visual| mode (use ctrl-v, move).  Then,
   assuming <vis.vim> has been installed as a plugin, type
>
	:B Bisort
<
   or you may often use an external sorting program; in such a case, the
   typical command is:
>
	:B !sort
<
  Since these methods use blockwise-visual selection, the command will appear
  as
>
	:'<,'>B Bisort


==============================================================================
5. BlockSort   							*blocksort*

   :'<,'>BS
   :'< '>BS nextblock endblock findtag tagpat tagsub
   :[range]call BlockSort(nextblock,endblock,findtag,tagpat,tagsub)
   :[range]call BlockSort(...)

              If any arguments are missing, BlockSort()
                    will query the user for them.

    This function's purpose is to sort blocks of text based on tags
    contained within the blocks.

    WARNING: this function can move lots of text around, so using it
    is use-at-your-own-risk!  Please check and verify that things
    have worked as you expected.  Backing up your file before
    modifying it would be advisable before doing such things as
    sorting C functions.

    nextblock:
      Blocks are assumed to begin on a line containing the nextblock pattern.

      If the nextblock pattern is "" (the empty string), then the next block is
      assumed to begin with the line following the line matching the endblock
      pattern.

    endblock:
      Blocks are assumed to end with a line containing the endblock pattern.

      If the endblock pattern is "" (the empty string), then the end of the
      block will be assumed to be the line preceding the line matching
      the nextblock pattern.

    findtag:
      Blocks are assumed to contain a tag findable by the findtag pattern.

      If the findtag pattern is "", then nextblock line will be assumed
      to contain the tag.

    tagpat, tagsub:
      The tagpat and tagsub are used by a |substitute()|; the tag is extracted
      by applying the tagpat to the line containing the tag and substitution
      is made with the tagsub pattern.

      If the tagpat is "", then it will default to '^.*$'.

      If the tagsub is "", then if the tagpat was "", then tagsub will
      take on the default value of "&".

      If the tagsub is "" but the tagpat wasn't "", then the tagsub will
      take on the default value of '\1'.

   EXAMPLES

    1. :[range]call BlockSort('^[a-z]','---$','\u','^.*\(\u\).*$','\1')

     Original Text: >
     	one
             	some
             	junk
             	B
             	appears
             	---
     	two
             	some more
             	junk
             	A
             	appears here.
             	---
<
     After BlockSort('^[a-z]','---$','\u','^.*\(\u\).*$','\1') >
     	two
             	some more
             	junk
             	A
             	appears here.
             	---
     	one
             	some
             	junk
             	B
             	appears
             	---
<
    2. Sorting C functions (see warning above!)  [USE AT YOUR OWN RISK]

	:[range]CFuncSort
	:[range]call BlockSort('','^}','^[^/*]\&^[^ ][^*]\&^.*\h\w*\s*(','^.\{-}\(\h\w*\)\s*(.*$','')

	CFuncSort is a command that does exactly the same thing as the
	BlockSort shown above; its just easier to type.

	Each function is a block; the nextblock is implied by being the endblock + 1.

	The endblock assumes that C functions end with a pattern matching '^}'.  This
	assumption is not required by the language, but it is typical use.

	The findtag pattern attempts to avoid comments; its not perfect:
	                 1         2
	        12345678901234567890  <--column
		/* something()
		 * somethingelse()
		 */
       		// something()
	Its looking for a C-word ('\h\w*') followed by possible white space
	and an open parenthesis.  It undoubtedly can be confused by prototypes,
	stuff that looks like functions but is inside comments, etc.

	Once such a line is found, the tagpat operates to identify the function name.
	Since tagsub is '', its default value of '\1' is used.


==============================================================================
vim:tw=78:ts=8:ft=help

