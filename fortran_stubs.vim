" forstubs.vim: stub/abbrevations for fortran
" Ajit J. Thakkar (ajit AT unb.ca)
" URL: http://www.unb.ca/chem/ajit/vim.htm
" Last change: 2003 Feb. 12
" Based on Charles E. Campbell, Jr.'s DrChipCStubs
" Use at your own risk.
"
inoremap  ;vr        real(kind=dr), dimension(:) ::
inoremap  ;vi        integer, dimension(:) ::
inoremap  ;pi        integer, parameter ::
inoremap  ;pr        real(kind=dr), parameter ::
inoremap  ;i         integer ::
inoremap  ;c         character(len=) ::
inoremap  ;r         real(kind=dr) ::
inoremap  ;ar        real(kind=dr), intent(in out) ::
inoremap  ;ai        integer, intent(in out) ::
inoremap  ;av        real(kind=dr), dimension(:), intent(in out) ::

inoremap `	<Esc>:call FortranStubs()<CR>a

" Typing one of the keywords (if, else, do, sub, fun, mod, sel, read, wri, op)
" followed by a ` expands to a code snippet
function! FortranStubs()
 let wrd=expand("<cWORD>")

 if     wrd == "if"
  exe "norm! bdWaif () then\<CR>\<c-d>else\<CR>\<c-d>end if\<Esc>kkF("

 elseif wrd == "else"
  exe "norm! bdWaelse if () then\<Esc>F("

 elseif wrd == "do"
  exe "norm! bdWado \<CR>\<c-d>end do\<Esc>kFo"

 elseif wrd == "sub"
  exe "norm! bdWasubroutine ()\<cr>!\<cr>implicit none\<CR>return\<cr>end subroutine\<Esc>4kF "

 elseif wrd == "fun"
  exe "norm! bdWafunction () result()\<cr>!\<cr>implicit none\<CR>return\<cr>end function\<Esc>4kF "

 elseif wrd == "mod"
  exe "norm! bdWamodule \<CR>implicit none\<cr>public :: \<cr>private :: <cr>contains\<cr>end module\<Esc>4kFe"

 elseif wrd == "sel"
  exe "norm! bdWaselect case()\<CR>case()\<cr>\<c-d>end select\<Esc>2kF("

 elseif wrd == "read"
  exe "norm! bdWaread(unit=,fmt=\"()\")\<Esc>2F="

 elseif wrd == "wri"
  exe "norm! bdWawrite(unit=,fmt=\"()\")\<Esc>2F="

 elseif wrd == "op"
  exe "norm! bdWaopen(unit=,file=,status=,action=,position=)\<Esc>F(f="

 endif
endfunction
