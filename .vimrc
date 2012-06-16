" Vim
" An example for a vimrc file.
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"             for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc

set nocompatible	" Use Vim defaults (much better!)
set bs=2		" allow backspacing over everything in insert mode
set ai			" always set autoindenting on
set tw=80		" always limit the width of text to 80
set nobackup	" don't keep a backup file
set viminfo='20,\"75	" read/write a .viminfo file, don't store more
			" than 75 lines of registers
set ts=4		"tab stop"
set incsearch	"incremental searching"
set hlsearch "highlight all"
set shiftwidth=4
set cino=g0		"C/C++ auto-indent"
set noerrorbells "damn this beep  ;-)" to quote Sven's rc.
set path=.,../include,../src,$PATH
set ruler		"Display line and column number at bottom of screen.
set showcmd
set showmatch
set suffixes=.swp
set visualbell	"Take the beep down another step or two.
set wildchar=<TAB>
set guioptions-=T  " No toolbar please.

" Support iabs for macros.
iab INSERTCLASSNAMEHERE <C-R>=expand("%:t:r")<cr>
iab INSERTFILEDEFINEHERE <C-R>=expand("%:t")<cr>

" Map * and # to search for selected text in visual mode
" Search for selected text in visual mode with */# 
" effect: overrides unnamed register 
" Simplest version: vnoremap * y/<C-R>"<CR> 
" Better one: vnoremap * y/\V<C-R>=escape(@@,"/\\")<CR><CR> 
" This is so far the best, allowing all selected characters and multiline selection: 
"
" Atom \V sets following pattern to "very nomagic", i.e. only the backslash has special meaning. 
" As a search pattern we insert an expression (= register) that 
" calls the 'escape()' function on the unnamed register content '@@', 
" and escapes the backslash and the character that still has a special 
" meaning in the search command (/|?, respectively). 
" This works well even with <Tab> (no need to change ^I into \t), 
" but not with a linebreak, which must be changed from ^M to \n. 
" This is done with the substitute() function. 
vnoremap * y/\V<C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
vnoremap # y?\V<C-R>=substitute(escape(@@,"?\\"),"\n","\\\\n","ge")<CR><CR>
" These are for vim5. Hmmm... The \V wasn't recognized as special.  It seems to work without it.
"vnoremap * y/<C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
"vnoremap # y?<C-R>=substitute(escape(@@,"?\\"),"\n","\\\\n","ge")<CR><CR>



function! SwapExtensionFindAndSP(filename,ext)
  if ( a:ext == "mod" )
    let n_ext = "def"
    let cmd = "cmvcfind -cwd ".a:filename.".".n_ext
  elseif ( a:ext == "def" )
    let n_ext = "mod"
    let cmd = "cmvcfind -cwd " . a:filename . "." . n_ext
  else
        echohl WarningMsg | 
        \ echomsg "Error: Unsupported extension " . n_ext . " specified" | 
        \ echohl None
        return
  endif

   let cmd_output = system(cmd)

    if cmd_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: File " . a:filename . "." . n_ext . " not found" | 
        \ echohl None
        return
    else
      exec 'split ' . cmd_output
    endif
endfunction

function! s:RunCmdAndSP(cmd, pattern)
    let cmd_output = system(a:cmd)

    if cmd_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: Pattern " . a:pattern . " not found" | 
        \ echohl None
        return
    else
      exec 'split ' . cmd_output
    endif
endfunction

command! -nargs=1 Fndm2def      call s:RunCmdAndSP("cmvcfind -cwd ".<f-args>.".def", <f-args>.".def")
command! -nargs=1 Fndm2mod      call s:RunCmdAndSP("cmvcfind -cwd ".<f-args>.".mod", <f-args>.".mod")
"command! -nargs=1 Fndm2otr      call s:SwapExtensionFindAndSP(<f-args>)
			
" Don't use Ex mode, use Q for formatting
map Q gq

" Get past the darn weird RS/6000 right-ctrl
map w 

syntax on

let $VIM_GZIPfiles = "*.gz"

" gzip group first so that files are gzipped before other commands are processed
augroup gzip
  " Remove all gzip autocommands
  au!

  " Enable editing of gzipped files
  "	  read:	set binary mode before reading the file
  "		uncompress text in buffer after reading
  "	 write:	compress file after writing
  "	append:	uncompress file, append, compress file
  autocmd BufReadPre,FileReadPre	$VIM_GZIPfiles set bin
  autocmd BufReadPost,FileReadPost	$VIM_GZIPfiles '[,']!gunzip
  autocmd BufReadPost,FileReadPost	$VIM_GZIPfiles set nobin
  autocmd BufReadPost,FileReadPost	$VIM_GZIPfiles execute ":doautocmd BufReadPost " . expand("%:r")

  autocmd BufWritePost,FileWritePost	$VIM_GZIPfiles !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost	$VIM_GZIPfiles !gzip <afile>:r

  autocmd FileAppendPre			$VIM_GZIPfiles !gunzip <afile>
  autocmd FileAppendPre			$VIM_GZIPfiles !mv <afile>:r <afile>
  autocmd FileAppendPost		$VIM_GZIPfiles !mv <afile> <afile>:r
  autocmd FileAppendPost		$VIM_GZIPfiles !gzip <afile>:r
augroup END

augroup restoreLine
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END


let $NO_TAB_files = "*/PROJ/*,*/projcvs/*,*/thatproject.cscvs/*,*/git/sandbox/*,*/prj.git/*,*/rxv2400server/webControl*"

augroup ibis
  " Remove all ibis autocommands
  au!

  autocmd BufNewFile,BufRead $NO_TAB_files	set ts=4
  autocmd BufNewFile,BufRead $NO_TAB_files	set expandtab " Do not write tab character.  Spaces instead.
  autocmd BufNewFile,BufRead $NO_TAB_files	set softtabstop=4 " Still let backspace work as though they were tabs.
  autocmd BufNewFile,BufRead $NO_TAB_files match WhitespaceErrors /\(\s\+$\|\t\)/
  autocmd BufNewFile,BufRead $NO_TAB_files map z :!open https://viewvcserver.local/scm/viewvc.php%:p:s/.*thatproject\.cscvs//?root=thatproject\&view=log
  autocmd BufNewFile,BufRead $NO_TAB_files map Z :let @a = system("open https://viewvcserver.local/scm/viewvc.php" . fnamemodify(@%,":p:s/.*thatproject\.cscvs//") . '?root=thatproject\&view=annotate#l' . line("."))

augroup END

let $VIM_CCHfiles = "*.c,*.h"
let $VIM_CPPCHfiles = "*.cpp,*.hpp,*.C,*.H"
let $VIM_CCPPCHfiles = "$VIM_CCHfiles,$VIM_CPPCHfiles"

augroup cprog
  " Remove all cprog autocommands
  au!

  " When starting to edit a file:
  "   For *.c and *.h files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  autocmd BufRead *       set formatoptions=tcql nocindent comments&
  autocmd BufRead $VIM_CCPPCHfiles set formatoptions=cql cindent comments=sr:/*,mb:*,el:*/,:// ts=2 shiftwidth=2

" C autocmd Macros
	autocmd BufRead $VIM_CPPCHfiles map #5 :!g++
" Copyright, comment head, double include protect, and basic class.
  autocmd BufRead $VIM_CCPPCHfiles map #9 :set nocindentA/* Copyright (c) 1999 by Mark Jerde. All Rights Reserved *//69A*oDOCUMENT$Revision$$Date$$RCSfile$ENDDOCUMENT69A*A/#ifndef INSERTFILEDEFINEHERE#define INSERTFILEDEFINEHERE/69A*oDOCUMENTCLASS: INSERTCLASSNAMEHEREOWNER: Mark JerdePURPOSE:USAGE:STATES:MEMBER FUNCTIONS:public:protected:MEMBER DATA:EXCEPTIONS:REQUIREMENTS:ENDDOCUMENT69A*A/class INSERTCLASSNAMEHERE{public:protected:private:};#endif // INSERTFILEDEFINEHERE:2,$s/\./_/g:set cindent

" Comment head.
  autocmd BufRead $VIM_CCPPCHfiles map #8 :set nocindentA/69A*oDOCUMENTCLASS:OWNER: Mark JerdePURPOSE:USAGE:STATES:MEMBER FUNCTIONS:public:protected:MEMBER DATA:EXCEPTIONS:REQUIREMENTS:ENDDOCUMENT69A*A/:set cindent

" Insert raw class name.
  autocmd BufRead $VIM_CCPPCHfiles map #6 iINSERTCLASSNAMEHERE
" Insert class name with "::".
  autocmd BufRead $VIM_CCPPCHfiles map #5 iINSERTCLASSNAMEHERE::

" Open other file function.  Contains work around for *pp 'press enter' bug.
"Alternative incomplete function demonstrating how to check if the file exists.
  autocmd BufRead $VIM_CCPPCHfiles map #4 :if expand("%:e") == "hpp"if filereadable("..\\src\\" . expand("%:t:r") . ".cpp")e ../src/%:t:r.cppelseif expand("%:e") == "cpp"e ../include/%:t:r.hppelseif expand("%:e") == "h"e ../src/%:t:r.celseif expand("%:e") == "c"e ../include/%:t:r.hendif
"The real working function.
  autocmd BufRead $VIM_CCPPCHfiles map #4 :if expand("%:e") == "hpp"we ../src/%:t:r.cppelseif expand("%:e") == "cpp"we ../include/%:t:r.hppelseif expand("%:e") == "h"we ../src/%:t:r.celseif expand("%:e") == "c"we ../include/%:t:r.hendif
"The other version.
  autocmd BufRead *.C,*.h map #4 :if expand("%:e") == "h"we %:t:r.Celseif expand("%:e") == "C"we %:t:r.hendif

" Add new changelog entry.
"  autocmd BufRead $VIM_CCPPCHfiles map #9 /^\/\/ Log of changes made/^\/\/[ 	]*$nko// :let @" = strftime("%m/%d/%y")pa :let @" = $USERpa		 
augroup END

let $VIM_Lispfiles = "*.lisp"

augroup lispprog
  " Remove all lisp autocommands
  au!

  autocmd BufRead $VIM_Lispfiles  set ts=2
  autocmd BufRead $VIM_Lispfiles  so $VIM/syntax/lisp.vim

" Lisp compile command
  autocmd BufRead $VIM_Lispfiles  map #4 :w! %.clisp~:!clisp -i %.clisp~:!rm %.clisp~
augroup END

augroup javaprog
  " Remove all java autocommands
  au!

" Java compile command
  autocmd BufRead *.java  map #9 :!javac *.java
augroup END

let $VIM_DPXCCPPCfiles = "*/dpx/*.C"
let $VIM_DPXCCPPHfiles = "*/dpx/*.h"
let $VIM_DPXCCPPCHfiles = "$VIM_DPXCCPPCfiles,$VIM_DPXCCPPHfiles"

augroup templates
  " Remove all template autocommands
  au!

  autocmd BufNewFile *.UnitMakefile	source $VIM/templates/UnitMakefile.vim
  autocmd BufNewFile *.EnvMakefile	source $VIM/templates/EnvMakefile.vim
  autocmd BufNewFile $VIM_DPXCCPPCHfiles		set ts=2 shiftwidth=2
  autocmd BufNewFile $VIM_DPXCCPPCfiles			source $VIM/templates/C.vim
  autocmd BufNewFile $VIM_DPXCCPPHfiles			source $VIM/templates/h.vim
augroup END

augroup mail
  " Remove all mail autocommands
  au!

  autocmd BufRead /tmp/snd.*	set noautoindent ts=8 nobackup writebackup
augroup END

let $VIM_Modula2files = "*.mod,*.def"

augroup modula2
	autocmd BufRead $VIM_Modula2files	set ts=2
	autocmd BufRead $VIM_Modula2files	set expandtab
" Modula2 find-import macro. (normal and visual modes)
  autocmd BufRead $VIM_Modula2files noremap #1 viwy:sp?^\s*FROM\s\+\S\+\s\+IMPORT\s\+\(\S\+\s*,\s*\n*\s*\)*\V<C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
  autocmd BufRead $VIM_Modula2files vnoremap #1 y:sp?^\s*FROM\s\+\S\+\s\+IMPORT\s\+\(\S\+\s*,\s*\n*\s*\)*\V<C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
" Modula2 find-defintion-module macro. (normal and visual modes)
  autocmd BufRead $VIM_Modula2files noremap #2 viwy:Fndm2def <C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
  autocmd BufRead $VIM_Modula2files vnoremap #2 y:Fndm2def <C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
  autocmd BufRead $VIM_Modula2files map #3 <F1>eeb<F2>
" Modula2 find-complement-file macro.
  "autocmd BufRead *.mod	noremap #4 :let @@ = expand("%:t:r"):Fndm2def <C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
  "autocmd BufRead *.def	noremap #4 :let @@ = expand("%:t:r"):Fndm2mod <C-R>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<CR><CR>
  autocmd BufRead $VIM_Modula2files	noremap #4 :let @@ = expand("%:t:r"):let ext = expand("%:t:e"):let @@=substitute(escape(@@,"/\\"),"\n","\\\\n","ge"):let ext=substitute(escape(ext,"/\\"),"\n","\\\\n","ge"):call SwapExtensionFindAndSP(@@,ext)<CR>
  autocmd BufRead $VIM_Modula2files noremap #6 :let @9 = @/:3sp?^PROCEDURE:let @/ = @9
" Run make and debug compile errors from within vim.
  autocmd BufRead $VIM_Modula2files set makeprg=m2remake
  autocmd BufRead $VIM_Modula2files set errorformat=%C\ %m,%E\"%f\"\\,\ line\ %#%l%n,%Z%m
" 'Protect' macro to protect TD Trace code.
  autocmd BufRead $VIM_Modula2files vmap p <Esc>`<OI#if  _TD_TRACE'>oA#endif
" Macro to comment a block of code.
  autocmd BufRead $VIM_Modula2files vmap c <Esc>`<I(*'>A*)
augroup END

augroup ABCdebugging
	autocmd BufRead *.SUM,		set syntax=yacc
"	autocmd BufRead *.SUM,		norm /SIMERR
	autocmd BufRead *.SUM,		norm /^USBERR
"	autocmd BufRead *ppc*.SUM	source ~/sandbox/vistuff
"	autocmd BufRead *rnd*.SUM	w ~/sandbox/RomeoSim/%:t
augroup END

augroup pdiff
" for highlighting and 'n'
	autocmd BufRead *.pdiff let @/ = "^.\\{92,92}[<|>]"
	"autocmd BufRead *.pdiff norm n
" for search history
	autocmd BufRead *.pdiff norm /^.\{92,92}[<|>]
	autocmd BufRead *.pdiff norm 32G
augroup END

augroup m2remake
	autocmd BufRead m2remake.out let @/ = "(E)"
	autocmd BufRead m2remake.out norm n
augroup END

highlight WhitespaceErrors term=standout ctermbg=red guibg=red
match WhitespaceErrors /\(\s\+$\|[^\t]\zs\t\+\|^\t*\zs \+\)/
match WhitespaceErrors /\(\s\+\%#\@<!$\|[^\t]\zs\t\+\|^\t*\zs \+\)/

let @q='1Gjviwyww:norm 0G%'
let @z='viwyww:read !~/bin/scanSortTagger.pl 0.pdf debug'

