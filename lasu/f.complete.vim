" Main completion function
" ==============================================================================
" Tex_Complete(what,where) {{{

function! Tex_Complete(what, where)

	" Get info about current window and position of cursor in file
	let s:winnum = winnr()

	" Change to the directory of the file being edited before running all the
	" :grep commands. We will change back to the original directory after we
	" finish with the grep.
	let s:origdir = fnameescape(getcwd())
	exe 'cd '.fnameescape(expand('%:p:h'))

	let s:pos = Tex_GetPos()

	unlet! s:type
	unlet! s:typeoption

	if Tex_GetVarValue('Tex_WriteBeforeCompletion') == 1
		wall
	endif

	if a:where == "text"
		" What to do after <F9> depending on context
		let s:curline = strpart(getline('.'), 0, col('.'))
		let s:prefix = matchstr(s:curline, '.*{\zs.\{-}\(}\|$\)')
		" a command is of the type
		" \psfig[option=value]{figure=}
		" Thus
		" 	s:curline = '\psfig[option=value]{figure='
		" (with possibly some junk before \psfig)
		" from which we need to extract
		" 	s:type = 'psfig'
		" 	s:typeoption = '[option=value]'
		let pattern = '.*\\\(\w\{-}\)\(\[.\{-}\]\)*{\([^ [\]\t]\+\)\?$'
		if s:curline =~ pattern
			let s:type = substitute(s:curline, pattern, '\1', 'e')
			let s:typeoption = substitute(s:curline, pattern, '\2', 'e')
			call Tex_Debug('Tex_Complete: s:type = '.s:type.', typeoption = '.s:typeoption, 'view')
		endif

		if exists("s:type") && s:type =~ 'ref'
			if Tex_GetVarValue('Tex_UseOutlineCompletion') == 1
				call Tex_Debug("Tex_Complete: using outline search method", "view")
				call Tex_StartOutlineCompletion()

			elseif Tex_GetVarValue('Tex_UseSimpleLabelSearch') == 1
				call Tex_Debug("Tex_Complete: searching for \\labels in all .tex files in the present directory", "view")
				call Tex_Debug("Tex_Complete: silent! grep! ".Tex_EscapeForGrep('\\label{'.s:prefix)." *.tex", 'view')
				call Tex_Grep('\\label{'.s:prefix, '*.tex')
				call <SID>Tex_SetupCWindow()

			elseif Tex_GetVarValue('Tex_ProjectSourceFiles') != ''
				call Tex_Debug('Tex_Complete: searching for \\labels in all Tex_ProjectSourceFiles', 'view')
				exec 'cd '.fnameescape(Tex_GetMainFileName(':p:h'))
				call Tex_Grep('\\label{'.s:prefix, Tex_GetVarValue('Tex_ProjectSourceFiles'))
				call <SID>Tex_SetupCWindow()

			else
				call Tex_Debug("Tex_Complete: calling Tex_GrepHelper", "view")
				silent! grep! ____HIGHLY_IMPROBABLE___ %
				call Tex_GrepHelper(s:prefix, 'label')
				call <SID>Tex_SetupCWindow()
			endif

			redraw!

		elseif exists("s:type") && s:type =~ 'cite'

			let s:prefix = matchstr(s:prefix, '\([^,]\+,\)*\zs\([^,]\+\)\ze$')
			call Tex_Debug(":Tex_Complete: using s:prefix = ".s:prefix, "view")

			if has('python') && Tex_GetVarValue('Tex_UsePython') 
				\ && Tex_GetVarValue('Tex_UseCiteCompletionVer2') == 1

				exe 'cd '.s:origdir
				silent! call Tex_StartCiteCompletion()

			elseif Tex_GetVarValue('Tex_UseJabref') == 1

				exe 'cd '.s:origdir
				let g:Remote_WaitingForCite = 1
				let citation = input('Enter citation from jabref (<enter> to leave blank): ')
				let g:Remote_WaitingForCite = 0
				call Tex_CompleteWord(citation, strlen(s:prefix))
			
			else
				" grep! nothing % 
				" does _not_ clear the search history contrary to what the
				" help-docs say. This was expected. So use something improbable.
				" TODO: Is there a way to clear the search-history w/o making a
				"       useless, inefficient search?
				silent! grep! ____HIGHLY_IMPROBABLE___ %
				if g:Tex_RememberCiteSearch && exists('s:citeSearchHistory')
					call <SID>Tex_SetupCWindow(s:citeSearchHistory)
				else
					call Tex_GrepHelper(s:prefix, 'bib')
					redraw!
					call <SID>Tex_SetupCWindow()
				endif
				if g:Tex_RememberCiteSearch && &ft == 'qf'
					let _a = @a
					silent! normal! ggVG"ay
					let s:citeSearchHistory = @a
					let @a = _a
				endif
			endif

		elseif exists("s:type") && (s:type =~ 'includegraphics' || s:type == 'psfig') 
			call Tex_SetupFileCompletion(
				\ '', 
				\ '^\.\\|\.tex$\\|\.bib$\\|\.bbl$\\|\.zip$\\|\.gz$', 
				\ 'noext', 
				\ Tex_GetVarValue('Tex_ImageDir', '.'), 
				\ Tex_GetVarValue('Tex_ImageDir', ''))
			
		elseif exists("s:type") && s:type == 'bibliography'
			call Tex_SetupFileCompletion(
				\ '\.b..$',
				\ '',
				\ 'noext',
				\ '.', 
				\ '')

		elseif exists("s:type") && s:type =~ 'include\(only\)\='
			call Tex_SetupFileCompletion(
				\ '\.t..$', 
				\ '',
				\ 'noext',
				\ '.', 
				\ '')

		elseif exists("s:type") && s:type == 'input'
			call Tex_SetupFileCompletion(
				\ '', 
				\ '',
				\ 'ext',
				\ '.', 
				\ '')

		elseif exists('s:type') && exists("g:Tex_completion_".s:type)
			call <SID>Tex_CompleteRefCiteCustom('plugin_'.s:type)

		else
			let s:word = expand('<cword>')
			if s:word == ''
				call Tex_SwitchToInsertMode()
				return
			endif
			call Tex_Debug("silent! grep! ".Tex_EscapeForGrep('\<'.s:word.'\>')." *.tex", 'view')
			call Tex_Grep('\<'.s:word.'\>', '*.tex')

			call <SID>Tex_SetupCWindow()
		endif
		
	elseif a:where == 'tex'
		" Process :TLook command
		call Tex_Grep(a:what, "*.tex")
		call <SID>Tex_SetupCWindow()

	elseif a:where == 'bib'
		" Process :TLookBib command
		call Tex_Grep(a:what, "*.bib")
		call Tex_Grepadd(a:what, "*.bbl")
		call <SID>Tex_SetupCWindow()

	elseif a:where == 'all'
		" Process :TLookAll command
		call Tex_Grep(a:what, "*")
		call <SID>Tex_SetupCWindow()
	endif

endfunction 
" }}}
" ==============================================================================
" Tex_CompleteWord (completeword,prefixlength) {{{
" inserts a word at the chosen location 
" Description: This function is meant to be called when the user press
" 	``<enter>`` in one of the [Error List] windows which shows the list of
" 	matches. completeword is the rest of the word which needs to be inserted.
" 	prefixlength characters are deleted before completeword is inserted
function! Tex_CompleteWord(completeword, prefixlength)
	call Tex_SetPos(s:pos)

	" Complete word, check if add closing }
	if a:prefixlength > 0
		if a:prefixlength > 1
			exe 'normal! '.(a:prefixlength-1).'h'
		endif
		exe 'normal! '.a:prefixlength.'s'.a:completeword."\<Esc>"
	else
		exe 'normal! a'.a:completeword."\<Esc>"
	endif

	if getline('.')[col('.')-1] !~ '{' && getline('.')[col('.')] !~ '}'
		exe "normal! a}\<Esc>"
	endif
	
	" Return to Insert mode
	call Tex_SwitchToInsertMode()
endfunction " }}}
" ==============================================================================


