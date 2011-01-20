
" O.P.: New macros {{{
call s:Tex_SpecialMacros('ZNC', '', 'newcommand',     '\newcommand{<++>}[<++>]{<++>}<++>', 0)
call s:Tex_SpecialMacros('ZIT', 'Env&Commands.&Lists.', '&item',     '\item', 0)
call s:Tex_SpecialMacros('ZIT', 'Env&Commands.&Lists.', 'i&tem[]',    '\item[<++>]<++>', 0)
call s:Tex_SpecialMacros('ZBIT', 'Env&Commands.&Lists.', '&bibitem{}', '\bibitem{<++>}<++>', 0)
call s:Tex_SpecialMacros('ZHL', 'EnvCommands.&Tabular.', '&hline', '\hline', 0)
call s:Tex_SpecialMacros('ZCL', 'EnvCommands.&Tabular.', '&cline', '\cline', 0) 
call s:Tex_SpecialMacros('ZMC', 'EnvCommands.&Tabular.', '&multicolumn{}{}{}', '\multicolumn{<++>}{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('ZIG', 'EnvCommands.&Tabular.', '&ig{}{}{}', '\ig{\sz<++>}{pics}{<++>.eps}<++>', 0)
call s:Tex_SpecialMacros('ZTAB33', '', '&tab33', '\tabthreethree', 0) 

" }}}


