

function! Tex_GetVarValue(varname, ...)
    if exists('w:'.a:varname)
        return w:{a:varname}
    elseif exists('b:'.a:varname)
        return b:{a:varname}
    elseif exists('g:'.a:varname)
        return g:{a:varname}
    elseif a:0 > 0
        return a:1
    else
        return ''
    endif
endfunction 

function! Tex_Grep(string, where)
    if v:version >= 700
        exec 'silent! vimgrep! /'.a:string.'/ '.a:where
    else
        exec 'silent! grep! '.Tex_EscapeForGrep(a:string).' '.a:where
    endif
endfunction

function! Tex_EscapeForGrep(string)
    let retVal = a:string

    " The shell halves the backslashes.
    if &shell =~ 'sh'
        let retVal = escape(retVal, "\\")

        " If shellxquote is set, then the backslashes are halved yet again.
        if &shellxquote == '"'
            let retVal = escape(retVal, "\"\\")
        endif

    endif
    " escape special characters which bash/cmd.exe might interpret
    let retVal = escape(retVal, "<>")

    return retVal
endfunction 
