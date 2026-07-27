" nextflow.vim sources $VIMRUNTIME/syntax/groovy.vim, which has
" `syntax spell default` at line 226 and `let b:spell_options="contained"`
" at line 446. Both restrict spell checking to regions with @Spell in
" their contains list (comments and strings only). Undoing both makes
" Vim spell-check the entire buffer (code included).
"
" after/syntax/ files run reliably after the main syntax file and can't
" be interfered with by plugin autocmd management, unlike the Syntax
" autocmd approach which was getting deleted/reset during startup.
unlet! b:spell_options
syntax spell toplevel
