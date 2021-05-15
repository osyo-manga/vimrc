
" let g:quickrun_config = {
" \	"javascript/watchdogs_checker" : {
" \		"type" : "watchdogs_checker/eslint",
" \	},
" \}
"
" call watchdogs#setup(g:quickrun_config)
let s:Buffer = vital#of("vital").import("Coaster.Buffer")


" finish


function! s:get_vimlint_ynkdir()
	let n = 10
	return substitute(globpath(&rtp, "vimlint/vimlint.py"), '\\', '/', "g")
endfunction


function! s:executable_vimlint_ynkdir()
	return executable("python") && !empty(s:get_vimlint_ynkdir())
endfunction




function! s:quickrun_config()
	return unite#sources#quickrun_config#quickrun_config_all()
endfunction


function! s:remove(path, pattern, ...)
	let step = get(a:, 1, ';')
	return join(filter(split(a:path, step), "v:val !~# a:pattern"), step)
endfunction


" quickrun-runner {{{

" vimscript_all {{{
let s:runner = {}
let s:runner.name = "vimscript_all"
let s:runner.kind = "runner"

let g:is_quickrun_vimscript_all_running = 0

function! s:runner.run(commands, input, session)
" 	echom getcwd()
	let code = 0
	for cmd in a:commands
		let [result, code] = s:execute(cmd)
		call a:session.output(result)
		if code != 0
			break
		endif
	endfor
	return code
endfunction


" :QuickRun vim で呼び出しているので
" if !exists("quickrun_running")
if !get(g:, "quickrun_running", 0)
	function! s:execute(cmd)
		let result = ''
		let error = 0
		let temp = tempname()

		let save_vfile = &verbosefile
		let &verbosefile = temp

		let old_errmsg = v:errmsg
		let v:errmsg = ""

		try
			silent! execute a:cmd
		catch
			let error = 1
			silent echo v:throwpoint
			silent echo matchstr(v:exception, '^Vim\%((\w*)\)\?:\s*\zs.*')
		finally
			let error = !empty(v:errmsg)
			let v:errmsg = old_errmsg
			if &verbosefile ==# temp
				let &verbosefile = save_vfile
			endif
		endtry

		if filereadable(temp)
			let result .= join(readfile(temp, 'b'), "\n")
			let result =  substitute(result, "\n行", "行", "g")
			call delete(temp)
		endif

		return [result, error]
	endfunction
endif

call quickrun#module#register(s:runner, 1)
silent! unlet s:runner
" }}}

" codepad {{{
let s:runner = {}
let s:runner.name = "codepad"
let s:runner.kind = "runner"

function! s:runner.run(commands, input, session)
	let def_region = { 'first': [1, 1, 0], 'last': [line("$"), 1, 0] }
	let line1 = get(a:session.config, "region", def_region).first[0]
	let line2 = get(a:session.config, "region", def_region).last[0]
	redir => result
		call CodePadRun(line1, line2)
	redir END

	let error = 0
	let error_pattern = '<a href="#line-\(\d\+\)">Line \1</a>'
	if result =~ error_pattern
		let error = 1
		let filename = substitute(a:session.config.srcfile, '\\', '/', "g")
		let result = substitute(result, error_pattern, filename . ':\1', "g")
	endif

	call a:session.output(result)

	return error
endfunction

call quickrun#module#register(s:runner, 1)
silent! unlet s:runner
" }}}

" vimshell {{{
let s:runner = {}
let s:runner.name = "vimshell"
let s:runner.kind = "runner"

function! s:runner.run(commands, ...)
	execute "VimShellInteractive " . get(a:commands, 0, "")
	stopinsert
endfunction

call quickrun#module#register(s:runner, 1)
silent! unlet s:runner
" }}}

" }}}

" quickrun-outputter {{{

" location-list {{{
let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.name = "location_list"
let s:outputter.kind = "outputter"
let s:outputter.config = {
\	'errorformat': '',
\ }


let s:outputter.init_buffered = s:outputter.init

function! s:outputter.init(session)
	call self.init_buffered(a:session)
	let self.config.errorformat = empty(self.config.errorformat) ? &g:errorformat : self.config.errorformat
endfunction

function! s:outputter.finish(session)
	try
		let errorformat = &g:errorformat
		if !empty(self.config.errorformat)
			let &g:errorformat = self.config.errorformat
		endif

		lgetexpr self._result
		lwindow
		for winnr in range(1, winnr('$'))
			if getwinvar(winnr, '&buftype') ==# 'quickfix'
				call setwinvar(winnr, 'quickfix_title', 'quickrun: ' .
				\	 join(a:session.commands, ' && '))
				break
			endif
		endfor
	finally
		let &g:errorformat = errorformat
	endtry
endfunction

call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" quickfix {{{
let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.name = "quickfix2"
let s:outputter.kind = "outputter"
let s:outputter.config = {
\	'errorformat': '',
\	'open_cmd': 'cwindow',
\ }

let s:outputter.init_buffered = s:outputter.init

function! s:outputter.init(session)
	call self.init_buffered(a:session)

	let self.config.errorformat
\		= !empty(self.config.errorformat) ? self.config.errorformat
\		: !empty(&l:errorformat)          ? &l:errorformat
\		: &g:errorformat
endfunction


function! s:outputter.finish(session)
	try
		let errorformat = &g:errorformat
		let &g:errorformat = self.config.errorformat

" 		Debug &g:errorformat
		Debug self._result
		cgetexpr self._result
		sleep 100ms
		Debug getqflist()
		silent execute self.config.open_cmd
		for winnr in range(1, winnr('$'))
			if getwinvar(winnr, '&buftype') ==# 'quickfix'
				call setwinvar(winnr, 'quickfix_title', 'quickrun: ' .
				\	 join(a:session.commands, ' && '))
				break
			endif
		endfor
	finally
" 		cwindow
		let &g:errorformat = errorformat
	endtry
endfunction
call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" quickfix_vim_script {{{
let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.name = "quickfix_vim_script"
let s:outputter.kind = "outputter"
let s:outputter.config = {
\	'open_cmd': 'cwindow',
\ }


function! s:vsqf_funcname(line)
	let funcname  = matchstr(a:line, 'function.*<SNR>\d*_\zs[A-z|_]*\ze')
	return empty(funcname) ? matchstr(a:line, 'function \zs.*\ze,') : funcname
endfunction


function! s:vsqf_lnum(filelines, line)
	let funcname = s:vsqf_funcname(a:line)
	let lnum = matchstr(a:line, '.*行\s*\zs\d*\ze')
	if empty(lnum)
		return -1
	else
		return (empty(funcname) ? 0 : match(a:filelines, 'function.*'.funcname.'\s*(') + 1) + lnum
	endif
endfunction

function! s:make_vim_script_qflist(filename, errors)
	let filelines = readfile(a:filename)
	let errors    = a:errors
	let bufnr     = bufnr(a:filename)
	return map(a:errors, '{
\		"bufnr" : bufnr == -1 ? 0 : bufnr,
\		"lnum" : s:vsqf_lnum(filelines, v:val),
\		"text" : v:val,
\}')
endfunction


function! s:outputter.finish(session)
	let messages = self._result

	let file = a:session.config.srcfile

	let qflist= s:make_vim_script_qflist(file, split(messages, "\n"))
	call setqflist(qflist, 'r')

	silent execute self.config.open_cmd
	for winnr in range(1, winnr('$'))
		if getwinvar(winnr, '&buftype') ==# 'quickfix'
			call setwinvar(winnr, 'quickfix_title', 'quickrun: ' .
			\	 join(a:session.commands, ' && '))
			break
		endif
	endfor
endfunction
call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" replace-region {{{
let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.name = "replace_region"
let s:outputter.kind = "outputter"
let s:outputter.config = {
\	'errorformat': '',
\		"first" : "0",
\		"last"  : "0",
\		"back_cursor" : "0"
\ }

let s:outputter.init_buffered = s:outputter.init

function! s:outputter.init(session)
	call self.init_buffered(a:session)
endfunction


function! s:pos(lnum, col, ...)
	let bufnr = get(a:, 1, 0)
	let off   = get(a:, 2, '.')
	return [bufnr, a:lnum, a:col, off]
endfunction


function! s:delete(first, last)
	let pos = getpos(".")
	call setpos('.', a:first)
	normal! v
	call setpos('.', a:last)
	normal! d
	call setpos(".", pos)
endfunction


function! s:outputter.finish(session)
	let data = self._result
	let region = a:session.config.region
	let first = self.config.first == 0 ? [0] + region.first : s:pos(self.config.first, 0)
	let last  = self.config.last  == 0 ? [0] + region.last  : s:pos(self.config.last,  0)

	if first[1] > last[1]
		return
	endif
	try
		let tmp = @*
		call s:delete(first, last)
		let data = substitute(data, "\r\n", "\n", "g")
		let @* = join(split(data, "\n"), "\n")
		if empty(@*)
			return
		endif
		normal! "*P

		if self.config.back_cursor
			call setpos('.', first)
		endif
	catch /.*/
		echoerr v:exception
	finally
		let @* = tmp
	endtry
endfunction


call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" append {{{
let s:outputter = {
\	"name" : "append",
\	"kind" : "outputter",
\	"config" : {
\		"line" : "0"
\	}
\}


function! s:outputter.init(session)
	let self.config.line = self.config.line == 0 ?  line('.') : self.config.line
endfunction

function! s:outputter.output(data, session)
	let data = substitute(a:data, "\r\n", "\n", "g")
	call append(self.config.line-1, split(data, "\n"))
endfunction

function! s:outputter.finish(session)
endfunction

call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" setbufline {{{
let s:outputter = {}
let s:outputter.name = "setbufline"
let s:outputter.kind = "outputter"
let s:outputter.config = {
\   'name': '[quickrun output]',
\   'filetype': 'quickrun',
\   'append': 0,
\   'split': '%{winwidth(0) * 2 < winheight(0) * 5 ? "" : "vertical"}',
\   'into': 0,
\   'running_mark': ':-)',
\   'close_on_empty': 0,
\ }

function! s:outputter.init(session) abort
	let self._append = self.config.append
	let self._line = 0
	let self._crlf = 0
" 	let self._lf = 0
	let self._lf = 1
endfunction


function! s:escape_file_pattern(pat) abort
  return join(map(split(a:pat, '\zs'), '"[" . v:val . "]"'), '')
endfunction

function! s:outputter.start(session)
	let split = self.config.split
	let sname = s:escape_file_pattern(self.config.name)
	let buffer = s:Buffer.get(bufnr(sname))

	if !buffer.is_exists()
		let buffer = s:Buffer.new(self.config.name)
		call buffer.tap()
		nnoremap <buffer> q <C-w>c
		setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
		setlocal fileformat=unix
		call buffer.untap()
	endif

	if !self._append
		call buffer.clear()
	endif

" 	call buffer.setline(1, self.config.running_mark)
" 	call buffer.setline(2, "")

	if !buffer.is_opened_in_current_tabpage()
		call buffer.open(split . " split")
		execute "normal! \<C-w>p"
	endif

	let self._buffer = buffer
endfunction


function! s:outputter.output(data, session)
	let buffer = self._buffer

	let lines = buffer.getline(1, "$")
	let oneline = len(lines) == 1

	let data = buffer.getline("$")[0] . a:data
	call setbufline(buffer.number(), "$", "")
	call buffer.setline("$", "")

	if data =~# '\n$'
		" :put command do not insert the last line.
		let data .= "\n"
	endif
" 	call setbufline(buffer.number(), "$", "homu")
	call buffer.setline("$", split(data, "\n"))

" 	Debug buffer.is_opened_in_current_tabpage()
" 	if buffer.is_opened_in_current_tabpage()
" 		call buffer.tap()
" 		normal! G
" 		redraw
" 		call buffer.untap()
" 	endif

	return
endfunction

function! s:outputter.finish(session)
endfunction

function! s:is_empty_buffer()
  return line('$') == 1 && getline(1) =~# '^\s*$'
endfunction

function! s:escape_file_pattern(pat) abort
  return join(map(split(a:pat, '\zs'), '"[" . v:val . "]"'), '')
endfunction

call quickrun#module#register(s:outputter, 1)
unlet s:outputter
" }}}


" }}}


" quickrun-hook {{{

" {{{
function! s:make_hook_points_module(base)
	return shabadou#make_hook_points_module(a:base)
endfunction
" }}}


" quickrun-hook-make_hook_command {{{
function! s:make_hook_command(base)
	return shabadou#make_hook_command(a:base)
endfunction
" }}}


" quickrun-hook-close_location-list {{{
let s:hook = s:make_hook_points_module({
\	"name" : "close_location_list",
\	"kind" : "hook",
\	"config" : {
\		"enable_exit" : 1
\	}
\})

function! s:hook.priority(point)
	return a:point == "exit"
\		? -999
\		: 0
endfunction

function! s:hook.hook_apply(context)
	lclose
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-clear_quickfix {{{
let s:hook = s:make_hook_points_module({
\	"name" : "clear_quickfix",
\	"kind" : "hook",
\})

function! s:hook.hook_apply(context)
	call setqflist([])
" 	if !empty(&g:errorformat)
" 		cgetexpr ""
" 	endif
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-clear_location_list {{{
let s:hook = s:make_hook_points_module({
\	"name" : "clear_location_list",
\	"kind" : "hook",
\})

function! s:hook.hook_apply(context)
	if !empty(&g:errorformat)
		lgetexpr ""
	endif
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-clear_bufixlist {{{
let s:hook = s:make_hook_points_module({
\	"name" : "clear_bufixlist",
\	"kind" : "hook",
\})

function! s:hook.hook_apply(context)
	if !empty(&g:errorformat)
		Bgetexpr ""
	endif
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-omnisharp {{{
let s:hook = {
\	"name" : "omnisharp",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\	},
\}

function! s:hook.on_module_loaded(session, context)
	python buildcommand()
	let command = substitute(b:buildcommand, '\\', '\/', 'g')

	if type(a:session.config.exec) == type([])
		let a:session.config.exec[0] = command
	else
		let a:session.config.exec = command
	endif
	echom command
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun_running {{{
let s:hook = {
\	"name" : "quickrun_running",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"variable_name" : "quickrun_running",
\	}
\}

function! s:hook.init(...)
	if self.config.enable
		execute "let g:".self.config.variable_name."=1"
	endif
endfunction

function! s:hook.on_exit(...)
	execute "unlet g:".self.config.variable_name
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-banban {{{
let s:hook = {
\	"name" : "banban",
\	"kind" : "hook",
\	"index_counter" : 0,
\	"config" : {
\		"enable" : 0
\}
\}

function! s:hook.on_ready(session, context)
	let self.index_counter = -2
endfunction

function! s:hook.on_output(session, context)
	let self.index_counter += 1
	if self.index_counter < 0
		return
	endif
	let aa_list = [
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\   'ﾊﾞﾝ（⊃`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝ',
	\]
	echo aa_list[ self.index_counter / 5 % len(aa_list)  ]
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" make_quickrun_hook_anim {{{
function! s:make_quickrun_hook_anim(name, aa_list, wait)
	return shabadou#make_quickrun_hook_anim(a:name, a:aa_list, a:wait)
endfunction
" }}}


" santi_pinch {{{
call quickrun#module#register(s:make_quickrun_hook_anim(
\	"santi_pinch",
\	['＼(・ω・＼)　SAN値！', '　(／・ω・)／ピンチ！',],
\	12,
\), 1)
" }}}


" quickrun-run_prevconfig {{{
let s:prev_config={}

let s:hook = {
\	"name" : "run_prevconfig",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\	}
\}

function! s:hook.init(session)
	if self.config.enable
		if has_key(s:prev_config, "input") && empty(s:prev_config.input)
			call remove(s:prev_config, "input")
		endif
		call extend(a:session.config, s:prev_config, "force")
	endif
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook


let s:hook = {
\	"name" : "save_prevconfig",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 1,
\	}
\}

function! s:hook.on_normalized(session, context)
	let s:prev_config = deepcopy(a:session.config)
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-add_cmdopt {{{
let s:hook = {
\	"name" : "add_cmdopt",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 1,
\		"option" : "",
\		"priority" : 10,
\	}
\}

function! s:hook.on_normalized(session, context)
" function! s:hook.on_hook_loaded(session, context)
	if self.config.enable && has_key(a:session.config, "cmdopt")
		let a:session.config.cmdopt .= " ".self.config.option
	endif
endfunction

function! s:hook.priority(...)
	return self.config.priority
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-add-include-option {{{
let s:hook = {
\	"name" : "add_include_option",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"priority" : 0,
\		"option_format" : "-I%s",
\		"ignore" : ""
\	},
\}

function! s:hook.on_normalized(session, context)
	let paths = split(&path, ",")

	let ignore = self.config.ignore
	if !empty(ignore)
		call filter(paths, "v:val !~ ignore")
	endif

	if len(paths)
" 		let a:session.config.cmdopt .= " " . join(map(paths, "printf(self.config.option_format, v:val)")) . " "
	endif
endfunction

function! s:hook.priority(...)
	return self.config.priority
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-dogrun {{{
function! s:resize(str, len)
	if  a:len <= 0
		return ""
	endif
	let result = a:str
	while (strwidth(result) > a:len)
		let list = split(result, '\zs')
		if len(list) == 1
			return ""
		endif
		let result = join(list[ :len(list)-2], "")
	endwhile
	return result
endfunction


let s:hook = {
\	"name" : "dogrun",
\	"kind" : "hook",
\	"counter" : 0,
\	"config" : {
\		"enable" : 0
\}
\}

function! s:hook.on_ready(session, context)
	let self.counter = -6
endfunction

function! s:hook.on_output(session, context)
	let self.counter += 1
	if self.counter < 0
		return
	endif

	let dog = ['-', '-', '-', '-', '=', '=', '≡', '(', '(', '(', 'Ｕ', '＾', 'ω', '＾', '）']
	let dog_str = "----==≡(((Ｕ＾ω＾）"
	let width = &columns-5
	let counter = self.counter/2
	let len = len(dog)

	if len > counter
		echo join(dog[ (counter * -1)-1 : ], "")
	else
" 		echo repeat(" ", counter - len+1) . dog_str
		echo s:resize(repeat(" ", counter - len+1) . dog_str, width)
	endif
	if counter - len+1 > width
		let self.counter = -1
	endif
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-hook-is_started {{{
let g:is_quickrun_started = 0

let s:hook = {
\	"name" : "is_started",
\	"kind" : "hook",
\}

function! s:hook.init(...)
	let g:is_quickrun_started = 1
endfunction

function! s:hook.sweep(...)
	let g:is_quickrun_started = 0
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-location_list_replace_tempname_to_bufnr {{{
let s:hook = shabadou#make_hook_points_module({
\	"name" : "location_list_replace_tempname_to_bufnr",
\	"kind" : "hook",
\	"config" : {
\		"priority" : 0,
\		"bufnr" : 0,
\		"winnr" : 0,
\	},
\})

function! s:hook.init(...)
	let self.config.bufnr = self.config.bufnr ? self.config.bufnr : bufnr("%")
	let self.config.bufnr = self.config.winnr ? self.config.winnr : winnr()
endfunction


function! s:remove_ext(filename)
	let ext = fnamemodify(a:filename, ':p:e')
	if ext == "tmp"
		return a:filename
	endif
	return fnamemodify(a:filename, ':p:r')
endfunction

function! s:slashpath(path)
	return substitute(a:path, '\\', '/', "g")
endfunction


function! s:replace_temp_to_bufnr(qf, tempname, bufnr)
	if fnamemodify(bufname(a:qf.bufnr), ":p:t") =~ a:tempname . '$'
		let a:qf.bufnr = a:bufnr
	endif
	return a:qf
endfunction


function! s:hook.priority(...)
	return self.config.priority
endfunction


function! s:hook.on_exit(session, context)
	let session = a:session
	let winnr = self.config.winnr
	let tempname = s:remove_ext(session.config.srcfile)
	if !has_key(session, "_temp_names")
\	|| index(map(copy(session._temp_names), 's:remove_ext(v:val)'), tempname) == -1
		return
	endif
	let qflist = getloclist(winnr)
	let bufnr  = self.config.bufnr
	let tempname = s:slashpath(tempname)
	call map(qflist, "s:replace_temp_to_bufnr(v:val, tempname, bufnr)")
	call setloclist(winnr, qflist)
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-boost_link {{{
let s:hook = {
\	"name" : "boost_link",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"lib_path" : "",
\		"libs" : [],
\		"version" : "",
\		"priority" : 0,
\		"suffix" : 0,
\	}
\}

function! s:hook.on_normalized(session, context)
	if !empty(self.config.lib_path)
" 		let a:session.config.exec .= 
\			" -L ". self.config.lib_path . " "
\		  . join(map(copy(self.config.libs), "'-lboost_'.v:val.'-'.self.config.suffix.'-'.self.config.version"), " ")
	
	endif
endfunction

function! s:hook.priority(...)
	return self.config.priority
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" quickrun-redraw_exit{{{
let s:hook = {
\	"name" : "redraw_exit",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 1,
\	}
\}

function! s:hook.on_exit(...)
	redraw
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" qmake {{{
let s:hook = {
\	"name" : "qmake",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"directory" : "",
\		"qmake_cmd" : "qmake",
\	}
\}

function! s:hook.init(session)
	if !empty(self.config.directory)
		let a:session.config["hook/cd/enable"] = 1
		let a:session.config["hook/cd/directory"] = self.config.directory
	endif
	if self.config.enable
		let self.path = $PATH
		let $PATH = "D:/qt/Qt5.0.2/Tools/MinGW/bin;D:/qt/Qt5.0.2/5.0.2/mingw47_32/bin"
	endif
endfunction

function! s:get_qmake_profile(dir)
	let dir = empty(a:dir) ? "" : a:dir."/"
	return fnamemodify(get(split(glob(dir."*.pro"), "\n"), 0, ""), ":p")
endfunction


" .pro が無ければ           : exec = ["qmake -project", "qmake", "make"]
" .pro が更新されていれば   : exec = ["qmake", "make"]
" .pro が更新されて無ければ : exec = ["make"]
let s:qmake_profile_timestamps = {}
function! s:hook.on_normalized(session, context)
	echom $PATH
	let qmake = self.config.qmake_cmd
	let profile = s:get_qmake_profile(self.config.directory)
	
	if filereadable(profile)
		let timestamp = getftime(profile)
		if get(s:qmake_profile_timestamps, profile, -1) == timestamp
			let exec = [a:session.config.exec]
		else
			let exec = [qmake, a:session.config.exec]
			let s:qmake_profile_timestamps[profile] = timestamp
		endif
	else
		let exec = [qmake." -project", qmake, a:session.config.exec]
	endif

	unlet a:session.config.exec
	let a:session.config.exec = exec
endfunction

function! s:hook.sweep(...)
	if !self.config.enable
		return
	endif
	let $PATH = self.path
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" remove_mingw {{{
let s:hook = {
\	"name" : "remove_mingw",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\	}
\}

function! s:hook.init(session)
	if self.config.enable
		let self.path = $PATH
		let $PATH = s:remove($PATH, '.*MinGW.*')
	endif
endfunction


function! s:hook.sweep(...)
	if !self.config.enable
		return
	endif
	let $PATH = self.path
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}


" vimlint {{{
let s:hook = {
\	"name" : "vimlint",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"vimlint_path" : "",
\		"vimlparser_path" : "",
\	}
\}


function! s:hook.on_normalized(session, context)
	if !empty(a:session.config.exec)
		return
	endif

	if empty(self.config.vimlint_path)
		let vimlint = substitute(fnamemodify(globpath(&rtp, "autoload/vimlint.vim"), ":h:h"), '\\', '/', "g")
	else
		let vimlint = self.config.vimlint_path
	endif

	if empty(self.config.vimlparser_path)
		let vimlparser = substitute(fnamemodify(globpath(&rtp, "autoload/vimlparser.vim"), ":h:h"), '\\', '/', "g")
	else
		let vimlparser = self.config.vimlparser_path
	endif

	let a:session.config.exec = '%C -N -u NONE -i NONE -V1 -e -s -c "set rtp+=' . vimlparser . ',' . vimlint . '" -c "call vimlint#vimlint(''%s'', {})" -c "qall!"'
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}

" restore_updatetime {{{
" let s:hook = {
" \	"name" : "restore_updatetime",
" \	"kind" : "hook",
" \	"config" : {
" \		"updatetime" : 500,
" \	}
" \}
"
" function! s:hook.on_exit(...)
" 	let &updatetime = self.config.updatetime
" endfunction
"
" function! s:hook.sweep(...)
" 	let &updatetime = self.config.updatetime
" endfunction
"
" call quickrun#module#register(s:hook, 1)
" unlet s:hook
" }}}

" }}}


" quickrun-config {{{

" g:quickrun_config の初期化
if exists("quickrun_running") || !exists("g:quickrun_config")
	let g:quickrun_config = {}
endif

function! Set_quickrun_config(name, base, config)
	let base = type(a:base) == type("") ? g:quickrun_config[a:base] : a:base
	let result = deepcopy(base)
	call extend(result, a:config, "force")
	let g:quickrun_config[a:name] = deepcopy(result)
endfunction


"\	"_" : {
"\		"outputter/buffer/split" : ":botright 8sp",
"\		"hook/unite_quickfix/unite_options" : "-no-quit -direction=botright -winheight=4 -max-multi-lines=32 -wrap",

"\		"runner" : "vimproc",
" \		"runner/vimproc/updatetime" : 500,
" \		"runner/vimproc/sleep" : 10,
" \		"outputter" : "multi:buffer:quickfix:bufixlist",
" \		"outputter/buffer/split" : ":botright 12sp",
" \		"outputter/setbufline/split" : ":botright 12sp",
" デフォルト {{{
let s:config = {
\	"_" : {
\		"outputter/buffer/split" : ":botright 8sp",
\		"outputter/setbufline/split" : ":botright 8sp",
\		"outputter" : "multi:setbufline:quickfix:bufixlist",
\		"outputter/buffer/running_mark" : "ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾞﾝ",
\		"outputter/setbufline/running_mark" : "ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾞﾝ",
\		"outputter/quickfix/open_cmd" : "",
\		"outputter/bufixlist/open_cmd" : "",
\		"runner" : "job",
\		"hook/santi_pinch/enable" : 0,
\		"hook/santi_pinch/wait" : 5,
\		"hook/sweep/enable" : 0,
\		"hook/extend_config/enable" : 1,
\		"hook/extend_config/force" : 1,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/unite_quickfix/enable_failure" : 1,
\		"hook/unite_quickfix/priority_exit" : 0,
\		"hook/unite_quickfix/unite_options" : "-no-quit -direction=botright -winheight=12 -max-multi-lines=32 -wrap",
\		"hook/close_unite_quickfix/enable_module_loaded" : 1,
\		"hook/echo/enable" : 1,
\		"hook/echo/enable_output_exit" : 1,
\		"hook/echo/priority_exit" : 10000,
\		"hook/echo/output_success" : "（＾ω＾U 三 U＾ω＾）",
\		"hook/echo/output_failure" : "(∪´;ﾟ;ω;ﾟ)･;'.､･;'.･;';ﾌﾞﾌｫ",
\		"hook/clear_quickfix/enable_hook_loaded" : 1,
\		"hook/clear_bufixlist/enable_hook_loaded" : 1,
\		"hook/clear_location_list/enable_hook_loaded" : 1,
\		"hook/hier_update/enable_exit" : 1,
\		"hook/quickfix_status_enable/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/priority_exit" : -10,
\		"hook/unite_quickfix/no_focus" : 1,
\		"hook/quickrunex/enable" : 1,
\		"hook/back_tabpage/enable" : 0,
\		"hook/back_window/enable" : 0,
\		"hook/back_tabpage/enable_exit" : 0,
\		"hook/back_tabpage/priority_exit" : -2000,
\		"hook/back_window/enable_exit" : 0,
\		"hook/back_window/priority_exit" : -1000,
\		"hook/gift_back_start_window/enable" : 0,
\	},
\	"wandbox" : {
\		"runner/wandbox/enable_output_every_polling" : 1,
\		"runner" : "wandbox",
\	},
\	"wandbox_post" : {
\		"command" : "wandbox",
\		"exec": "%c run %o %s:p",
\		"cmdopt": "--save --lang=%{&filetype}",
\	}
\}


call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" 実行 {{{
let s:config = {
\	"run/vimproc" : {
\		"exec": "%s:p:r %a",
\		"hook/output_encode/encoding" : "utf-8",
\		"runner" : "vimproc",
\		"outputter" : "buffer",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 0,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\	},
\
\	"run/cmd" : {
\		"exec": "cmd /c %s:p:r %a",
\		"runner" : "vimproc",
\		"outputter" : "buffer",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\	},
\
\	"run/start_exec" : {
\		"exec": "start %s:p:r.exe",
\		"runner" : "shell",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\	},
\
\	"run/qmake_debug" : {
\		"exec": "cmd /c %s:p:h:t %a",
\		"runner" : "vimproc",
\		"hook/cd/directory" : "debug",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\	},
\
\	"run/qmake_release" : {
\		"exec": "cmd /c %s:p:h:t %a",
\		"runner" : "vimproc",
\		"hook/cd/directory" : "release",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\		"hook/remove_mingw/enable" : 1,
\	},
\
\	"run/boost_test" : {
\		"exec": "%s:p:r %a",
\		"hook/output_encode/encoding" : "utf-8",
\		"runner" : "vimproc",
\		"outputter" : "error:buffer:quickfix",
\		"hook/close_buffer/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 0,
\		"hook/unite_quickfix/enable_failure" : 1,
\	},
\
\	"run/browser/cat" : {
\		"command" : "cat",
\		"outputter" : "browser",
\	},
\
\	"run/browser/type" : {
\		"command" : "cat",
\		"outputter" : "browser",
\	},
\
\	"run/vimshell" : {
\		"exec": "%s:p:r %a",
\		"hook/output_encode/encoding" : "utf-8",
\		"runner" : "vimshell",
\		"outputter" : "null",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/failure_close_buffer/enable" : 0,
\		"hook/close_buffer/enable_empty_data" : 0,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/extend_config/enable" : 0,
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" vim {{{
let s:config = {
\	"vim/_" : {
\	},
\	"vim/homu" : {
\		'command': ':source',
\		'exec': '%C %s',
\		'hook/eval/template': "echo %s",
\		"outputter" : "multi:buffer:quickfix_vim_script",
\		"outputter/open_cmd" : "",
\		"runner" : "vimscript_all",
\		"hook/quickrun_running/enable" : 1,
\	},
\	"vim/mami" : {
\		'command': ':source',
\		'exec': '%C %s',
\	},
\	"vim/test2" : {
\		'command': ':source',
\		'exec': ["%C %s", "call owl#run('%s')"],
\		"outputter" : "buffer",
\		"runner" : "vimscript",
\	},
\	"vim/test" : {
\		'command': ':source',
\		'exec': ["%C %s", "call owl#run('%s')"],
\		"outputter" : "quickfix",
\		"outputter/open_cmd" : "",
\		"runner" : "vimscript_all",
\		"hook/quickrun_running/enable" : 1,
\		"hook/unite_quickfix/enable_exist_data" : 1,
\	},
\	"vim/async" : {
\		'command': 'vim',
\		'exec': '%C -N -u NONE -i NONE -V1 -e -s --cmd "set fileformat=unix" --cmd "source %s" --cmd qall!',
\		"runner" : "vimproc",
\		"hook/output_encode/encoding" : "sjis",
\	},
\	"vim/vimlint" : {
\		'command': 'vim',
\		'exec': '%C -N -u  C:/vim/vim74-kaoriya-win32/_vimrc -i NONE -V1 -e -s -c "set fileformat=unix" -c "call vimlint#vimlint(''%s'', {})" -c "qall!"',
\		"runner" : "vimproc",
\		'outputter/quickfix/errorformat': '%f:%l:%c:%trror: %m,%f:%l:%c:%tarning: %m,%f:%l:%c:%m',
\		"hook/output_encode/encoding" : "sjis",
\	},
\	"vim/vimlint_no_vimrc" : {
\		'command': 'vim',
\		'exec': '%C -N -u  NONE -i NONE -V1 -e -s -c "set rtp+=D:/home/.vim/neobundle/vim-vimlparser,D:/home/.vim/neobundle/vim-vimlint" -c "call vimlint#vimlint(''%s'', {})" -c "qall!"',
\		"runner" : "vimproc",
\		'outputter/quickfix/errorformat': '%f:%l:%c:%trror: %m,%f:%l:%c:%tarning: %m,%f:%l:%c:%m',
\		"hook/output_encode/encoding" : "sjis",
\	},
\	"vim/lint" : {
\		'command': 'python',
\		'exec': '%C ' . s:get_vimlint_ynkdir() . ' %s',
\		"runner" : "vimproc",
\		"hook/output_encode/encoding" : "sjis",
\		'outputter/quickfix/errorformat': '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m',
\	},
\}

" set rtp+=D:/home/.vim/neobundle/vim-vimlparser,D:/home/.vim/neobundle/vim-vimlint
" \		'exec' : '%c -N -c "call vimlint#vimlint(%s, {})" -c "qall!"',
" \		'exec': '%C -N -u  C:/vim/vim73-kaoriya-win32_dev/_vimrc -i NONE -V1 -e -s -c "set fileformat=unix" -c "call vimlint#vimlint(''%s'', {})" -c "qall!"',

command! -nargs=* OwlRun call owl#run(<q-args>)

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" cpp {{{
let s:msvc_debug_option =
	\"/nologo /W3 /WX- /Od /Ob1 /Oy- /DWIN32 ".
	\"/D_DEBUG /D_CONSOLE /D_UNICODE /DUNICODE ".
	\"/Gm /Zi /EHsc /RTC1 /MTd /GS "

let s:msvc_debug_MD_option =
	\"/nologo /W3 /WX- /Od /Ob1 /Oy- /DWIN32 ".
	\"/D_DEBUG /D_CONSOLE /D_UNICODE /DUNICODE ".
	\"/Gm /Zi /EHsc /RTC1 /MDd /GS "

let s:msvc_release_option =
	\" /DWIN32 /D_CONCOLE /DNDEBUG ".
	\"/nologo /MT /EHsc /GR /O2 "

let s:msvc_release_link_option=
\	" /link ".
\	" -LIBPATH:".$BOOST_LATEST_ROOT."/stage/lib ".
\	" 'kernel32.lib' 'user32.lib' 'gdi32.lib' ".
\	"'comdlg32.lib' 'advapi32.lib' 'shell32.lib' 'ole32.lib' ".
\	"'oleaut32.lib' 'uuid.lib' 'odbc32.lib' 'odbccp32.lib' "

" let s:msvc_release_link_option=
" \	" /link ".
" \	" -LIBPATH:".$BOOST_LATEST_ROOT."/stage/lib ".
" \	" -LIBPATH:D:/home/work/software/lib/cpp/github/cpp-netlib_0.9-devel/cpp-netlib-build/libs/network/src/Debug ".
" \	' /NODEFAULTLIB:"LIBCMTD.lib" /NODEFAULTLIB:"libcpmtd.lib" '.
" \	" 'kernel32.lib' 'user32.lib' 'gdi32.lib' ".
" \	"'comdlg32.lib' 'advapi32.lib' 'shell32.lib' 'ole32.lib' ".
" \	"'oleaut32.lib' 'uuid.lib' 'odbc32.lib' 'odbccp32.lib' "

let s:msvc_debug_link_option = s:msvc_release_link_option."/DEBUG "

let s:gcc_option = " -Wall"
" let s:gcc_option = " -Wall -L" . $BOOST_LATEST_ROOT . "/stage/lib"
let s:clang_option = s:gcc_option . " -stdlib=libstdc++ "

let s:gcc_errorformat = "%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:"


let s:config = {
\	"c/clang" : {
\		"command" : "clang-5.0",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"comdopt" : "-std=gnu11",
\		"hook/quickrunex/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 1,
\		"hook/close_buffer/enable_exit" : 1,
\	},
\
\	"c/gcc" : {
\		"command" : "gcc",
\		'exec': ['%c %o %s -o %s:p:r', '%s:p:r %a'],
\		"hook/quickrunex/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 1,
\		"hook/close_buffer/enable_exit" : 1,
\	},
\
\	"cpp" : {
\		"type" : "cpp/gem-wandbox",
\		"hook/extend_config/enable" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\	},
\
\	"cpp/_" : {
\		"hook/quickrunex/enable" : 0,
\		"hook/add_include_option/enable" : 1,
\		"hook/add_include_option/ignore" : '^/usr/',
\		"hook/unite_quickfix/enable_exist_data" : 1,
\		"hook/close_buffer/enable_exit" : 1,
\		"hook/boost_link/version" : "1_53",
\		"hook/boost_link/suffix" : "mgw48-mt",
\		"hook/boost_link/lib_path" : $BOOST_LATEST_ROOT."/stage/lib",
\		"hook/boost_link/libs" : ["regex"],
\		"subtype" : "run/vimproc",
\	},
\
\	"cpp/msvc2012-debug" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option,
\		"cmdopt"  : s:msvc_debug_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/msvc_compiler/enable" : 1,
\		"hook/msvc_compiler/target" : "C:/Program Files/Microsoft Visual Studio 11.0",
\	},
\
\	"cpp/msvc2013-debug" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option,
\		"cmdopt"  : s:msvc_debug_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS120COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\
\	"cpp/msvc2010-debug-netlib" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option
\			. ' /NODEFAULTLIB:"LIBCMTD.lib" /NODEFAULTLIB:"libcpmtd.lib" '
\			. " -LIBPATH:D:/home/work/software/lib/cpp/github/cpp-netlib_0.9-devel/cpp-netlib-build/libs/network/src/Debug ",
\		"cmdopt"  : s:msvc_debug_MD_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS100COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\
\	"cpp/msvc2010-debug" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option,
\		"cmdopt"  : s:msvc_debug_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS100COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\	"cpp/msvc2010-release" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_release_link_option,
\		"cmdopt"  : s:msvc_release_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS100COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\	"cpp/msvc2008-debug" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option,
\		"cmdopt"  : s:msvc_debug_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS90COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\	"cpp/msvc2005-debug" : {
\		"command" : "cl",
\		"exec"    : "%c %o %s:p".s:msvc_debug_link_option,
\		"cmdopt"  : s:msvc_debug_option,
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS80COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\	},
\
\
\	"cpp/clang++3.3" : {
\		"command"   : $LLMV_WORK_ROOT."/BUILD_3_3/bin/clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=gnu++0x ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++03" : {
\		"command"   : "clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:clang_option,
\		"outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++-pedantic" : {
\		"command"   : "clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=gnu++0x -pedantic -pedantic-errors".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++" : {
\		"command"   : "clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=gnu++0x ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++1y" : {
\		"command"   : "clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=c++1y -pedantic ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++1z" : {
\		"command"   : "clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=c++1z -pedantic ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++-5.0 1z" : {
\		"command"   : "clang++-5.0",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=c++1z -pedantic ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++-6.0 1z" : {
\		"command"   : "clang++-6.0",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=c++1z -pedantic ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%m\ %f:%l:',
\	},
\
\	"cpp/clang++glambda" : {
\		"command"   : $LLMV_WORK_ROOT."/BUILD_msvc/bin/release/generic-lambda-clang",
\		"exec" : "%c %o %s -emit-llvm -o %s:p:r.bc",
\		"cmdopt"    : "-std=c++1y -c -IC:/Program\\ Files/Microsoft\\ Visual\\ Studio\\ 10.0/VC/include ".s:clang_option,
\		"subtype" : "cpp/run/glambda",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m',
\	},
\
\	"cpp/clang++glambda2" : {
\		"command"   : $LLMV_WORK_ROOT."/BUILD_glambda/bin/release/clang++",
\		"exec" : "%c %o %s -emit-llvm -o %s:p:r.bc",
\		"cmdopt"    : "-std=c++1y -c -IC:/Program\\ Files/Microsoft\\ Visual\\ Studio\\ 10.0/VC/include ".s:clang_option,
\		"subtype" : "cpp/run/glambda",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m',
\	},
\
\	"cpp/run/glambda" : {
\		"command"   : $LLMV_WORK_ROOT."/BUILD_msvc/bin/release/lli.exe",
\		"exec" : "%c %s:p:r.bc",
\	},
\
\	"cpp/clang++msvc" : {
\		"command"   : $LLMV_WORK_ROOT."/BUILD_msvc/bin/release/clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : " -std=gnu++0x ".s:clang_option,
\		"outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m',
\		"outputter/location_list/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m',
\	},
\
\	"cpp/clang++EXPERIMENTA" : {
\		"command"   : $LLMV_WORK_ROOT."/clang_EXPERIMENTAL/bin/clang++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : "-std=gnu++0x ".s:clang_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m',
\	},
\
\	"cpp/g++03" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s:p -o %s:p:r ",
\		"cmdopt"    : s:gcc_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++-preprocessor" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s:p  ",
\		"cmdopt"    : s:gcc_option." -P -E -MMD -std=gnu++0x",
\		"outputter" : "buffer",
\		"buffer/filetype" : "cpp",
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_success" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\
\	"cpp/g++9.2 C++20" : {
\		"command"   : "g++-9",
\		"exec" : "%c %o %s:p -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -pedantic-errors -std=gnu++2a",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++1z" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++1z",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++7.1 1z" : {
\		"command"   : "g++-7",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++1z",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++7.1 1z SDL" : {
\		"command"   : "g++-7",
\		"exec" : "%c %o %s " . system("sdl2-config --cflags --libs") . " -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++1z",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++7.1 1z SFML" : {
\		"command"   : "g++-7",
\		"exec" : "%c %o %s -lsfml-graphics -lsfml-window -lsfml-system -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++1z",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.6.3" : {
\		"command"   : $GCCS_ROOT."/gcc4_6_3/_bin/g++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"hook/boost_link/enable" : 1,
\	},
\
\	"cpp/g++4.6.3-03" : {
\		"command"   : $GCCS_ROOT."/gcc4_6_3/_bin/g++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.7.2" : {
\		"command"   : $GCCS_ROOT."/gcc4_7_2/_bin/g++",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x",
\		"hook/boost_link/enable" : 0,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x",
\		"hook/boost_link/enable" : 1,
\		"errorformat" : s:gcc_errorformat.',%mfrom\ %f:%l\,',
\	},
\
\	"cpp/g++4.8-03" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option,
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8-O2" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -O2 -std=gnu++0x",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8-O3" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -O3 -std=gnu++0x",
\		"outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"outputter/location_list/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8-OpenGL" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r -lglut32 -lglu32 -lopengl32 -lglew32 ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8-pedantic" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x -pedantic -pedantic-errors",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++4.8-preprocessor" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec" : "%c %o %s:p  ",
\		"cmdopt"    : s:gcc_option." -P -E -std=gnu++0x",
\		"outputter" : "buffer",
\		"buffer/filetype" : "cpp",
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_success" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\
\	"cpp/g++4.9" : {
\		"command"   : $GCCS_ROOT."/gcc4_9/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++0x",
\		"hook/boost_link/enable" : 1,
\		"outputter/quickfix/errorformat" : s:gcc_errorformat.',%mfrom\ %f:%l\,',
\		"outputter/location_list/errorformat" : s:gcc_errorformat,
\	},
\
\	"cpp/g++4.9-1y" : {
\		"command"   : $GCCS_ROOT."/gcc4_9/_bin/g++.exe",
\		"exec" : "%c %o %s -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -std=gnu++1y",
\		"hook/boost_link/enable" : 1,
\		"outputter/quickfix/errorformat" : s:gcc_errorformat.',%mfrom\ %f:%l\,',
\		"outputter/location_list/errorformat" : s:gcc_errorformat,
\	},
\
\	"cpp/g++-Qt4.8" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s -o %s:p:r -L'd:/home/work/software/sdk/qt/Qt/4.8.4/lib' -lmingw32 -lqtmaind -lQtWebKitd4 -lQtNetworkd4 -lQtGuid4 -lQtCored4 ",
\		"cmdopt"    : s:gcc_option." -mthreads -std=gnu++0x -mwindows -DUNICODE -DQT_LARGEFILE_SUPPORT -DQT_DLL -DQT_GUI_LIB -DQT_CORE_LIB -DQT_HAVE_MMX -DQT_HAVE_3DNOW -DQT_HAVE_SSE -DQT_HAVE_MMXEXT -DQT_HAVE_SSE2 -DQT_THREAD_SUPPORT -DQT_NEEDS_QMAIN",
\		"outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"outputter/location_list/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"subtype" : "run/vimproc",
\	},
\
\	"cpp/g++-Qt4.8withConsole" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s -o %s:p:r -L'd:/home/work/software/sdk/qt/Qt/4.8.4/lib' -lmingw32 -lqtmaind -lQtWebKitd4 -lQtNetworkd4 -lQtGuid4 -lQtCored4 ",
\		"cmdopt"    : s:gcc_option." -mthreads -std=gnu++0x  -DUNICODE -DQT_LARGEFILE_SUPPORT -DQT_DLL -DQT_GUI_LIB -DQT_CORE_LIB -DQT_HAVE_MMX -DQT_HAVE_3DNOW -DQT_HAVE_SSE -DQT_HAVE_MMXEXT -DQT_HAVE_SSE2 -DQT_THREAD_SUPPORT -DQT_NEEDS_QMAIN",
\		"outputter/quickfix/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"outputter/location_list/errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\		"subtype" : "run/start_exec",
\	},
\
\	"cpp/syntax_check" : {
\		"command"   : $GCCS_ROOT."/gcc4_8/_bin/g++.exe",
\		"exec"      : "%c %o %s:p ",
\		"outputter" : "quickfix",
\		"cmdopt"    : "-fsyntax-only -std=gnu++0x -fconstexpr-depth=4096 -Wall ",
\		"runner"    : "vimproc",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/redraw_unite_quickfix/enable_exit" : 1,
\		"hook/u_nya_/enable" : 0,
\		"hook/back_buffer/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\
\	"cpp/make" : {
\		"command"   : "mingw32-make",
\		"exec" : "%c %o",
\		"hook/output_encode/encoding" : "sjis",
\		"hook/add_include_option/enable" : 0,
\	},
\
\	"cpp/qmake" : {
\		"exec"   : "mingw32-make",
\		"hook/qmake/enable" : 1,
\		"subtype" : "run/qmake_debug",
\	},
\
\	"cpp/qmake5" : {
\		"exec"   : "D:/qt/Qt5.0.2/Tools/MinGW/bin/mingw32-make",
\		"hook/qmake/enable" : 1,
\		"hook/qmake_cmd" : "D:/qt/Qt5.0.2/5.0.2/mingw47_32/bin/qmake.exe",
\		"subtype" : "run/qmake_release",
\	},
\
\	"cpp/qmake5-msvc" : {
\		"exec"   : "D:/home/work/software/sdk/qt/Qt5.0.1_msvc/Tools/QtCreator/bin/jom.exe",
\		"hook/qmake/enable" : 1,
\		"hook/qmake_cmd" : "D:/home/work/software/sdk/qt/Qt5.0.1_msvc/5.0.1/msvc2010/bin/qmake -r -spec win32-msvc2010",
\		"hook/output_encode/encoding" : "sjis",
\		"hook/msvc_compiler/enable" : 1,
\		"hook/msvc_compiler/target" : "C:/Program Files/Microsoft Visual Studio 10.0",
\
\		"subtype" : "run/qmake_debug",
\	},
\
\	"cpp/bjam" : {
\		"command"   : $BOOST_ROOT."/bjam",
\		"exec" : "%c %o",
\		"hook/output_encode/encoding" : "sjis",
\		"hook/add_include_option/enable" : 0,
\	},
\
\	"cpp/wandbox" : {
\		"type" : "wandbox",
\	},
\
\	"cpp/gem-wandbox" : {
\		"command" : "wandbox",
\		"exec" : '%c run --options="gnu++2a" %s:p',
\		"cmdopt"  : "gnu++2a",
\		"hook/close_buffer/enable" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 0,
\		"hook/unite_quickfix/enable_failure" : 0,
\	},
\
\	"cpp/wandbox_gcc" : {
\		"command"   : "wandbox",
\		"exec" : "%c %o",
\	},
\
\
\	"cpp/catch-g++ 7" : {
\		"command" : "g++-7",
\		"exec" : "%c %o %s:p \\&\\& ./a.out",
\		"cmdopt" : "-std=gnu++1z -Wall -Wextra -pedantic"
\	},
\
\
\}
let s:config = {
\	"c/gcc-preprocessor" : {
\		"command" : "gcc",
\		"exec" : "%c %o %s:p",
\		"cmdopt" : "-P -E",
\		"buffer/filetype" : "c",
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_success" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\	"c/clang-preprocessor" : {
\		"command" : "clang",
\		"exec" : "%c %o %s:p",
\		"cmdopt" : "-P -E",
\		"buffer/filetype" : "c",
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_success" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\
\	"cpp/g++-preprocessor" : {
\		"command"   : "g++",
\		"exec" : "%c %o %s:p  ",
\		"cmdopt"    : s:gcc_option." -P -E -MMD -std=gnu++0x",
\		"outputter" : "buffer",
\		"buffer/filetype" : "cpp",
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_success" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\	},
\
\	"cpp/g++9.2 C++20" : {
\		"command"   : "g++-9",
\		"exec" : "%c %o %s:p -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -fconcepts -pedantic-errors -std=gnu++2a",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/g++9.2 C++17" : {
\		"command"   : "g++-9",
\		"exec" : "%c %o %s:p -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -pedantic-errors -std=gnu++1z",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/clang-8 C++20" : {
\		"command"   : "clang-8",
\		"exec" : "%c %o %s:p -o %s:p:r ",
\		"cmdopt"    : s:gcc_option." -fconcepts -pedantic-errors -std=gnu++2a",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"cpp/gem-wandbox-gcc-head" : {
\		"command" : "wandbox",
\		"exec" : '%c run --options="gnu++2a" %s:p',
\		"cmdopt"  : "gnu++2a",
\		"hook/close_buffer/enable" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 0,
\		"hook/unite_quickfix/enable_failure" : 0,
\	},
\
\	"cpp/gem-wandbox-clang-head" : {
\		"command" : "wandbox",
\		"exec" : '%c run --compiler=clang-head --options="gnu++2a" %s:p',
\		"cmdopt"  : "gnu++2a",
\		"hook/close_buffer/enable" : 0,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/unite_quickfix/enable_exist_data" : 0,
\		"hook/unite_quickfix/enable_failure" : 0,
\	},
\}
call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" python {{{
let s:config = {
\	"python" : {
\		"cmdopt" : "-u"
\	},
\	"python/windows" : {
\		"hook/output_encode/encoding" : "sjis",
\		"cmdopt" : "-u"
\	},
\	"python/line_profile" : {
\		"command" : "python",
\		"cmdopt" : " -u C:/Python27/Scripts/kernprof.py -l -v"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
"}}}


" jsx {{{
let s:config = {
\	"jsx" : {
\		"type" : "jsx/run",
\	},
\	"jsx/run" : {
\		"command"   : "jsx",
\		"exec"      : "%c --run %s:p",
\		"quickfix/errorformat" : '[%f:%l] %m',
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
"}}}



" ruby {{{
let s:config = {
\	"ruby" : {
\		"cmdopt" : "-Ku",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby/ruby" : {
\		"type" : "ruby",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby/2.0" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.0.0-p648 %c %o %s:p",
\	},
\	"ruby/2.0 -y" : {
\		"command" : "ruby",
\		"cmdopt" : "-y",
\		"exec" : "RBENV_VERSION=2.0.0-p648 %c %o %s:p",
\	},
\	"ruby/2.5" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.5.6 %c %o %s:p",
\	},
\	"ruby/2.6" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.6.6 %c %o %s:p",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby/2.7.0" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.7.0 %c %o %s:p",
\	},
\	"ruby/2.7.1" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.7.1 %c %o %s:p",
\	},
\	"ruby/2.7.1 within warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-w",
\		"exec" : "RBENV_VERSION=2.7.1 %c %o %s:p",
\	},
\	"ruby/2.7.1 without warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-Ku -W:no-deprecated -W:no-experimental ",
\		"exec" : "RBENV_VERSION=2.7.1 %c %o %s:p",
\	},
\	"ruby/2.7.2" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=2.7.2 %c %o %s:p",
\	},
\	"ruby/3.0.0" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=3.0.0 %c %o %s:p",
\	},
\	"ruby/3.0.0 with deprecated-warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-Ku -W:deprecated",
\		"exec" : "RBENV_VERSION=3.0.0 %c %o %s:p",
\	},
\	"ruby/3.0.0 without warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-Ku -W:no-deprecated -W:no-experimental ",
\		"exec" : "RBENV_VERSION=3.0.0 %c %o %s:p",
\	},
\	"ruby/3.1.0-dev" : {
\		"command" : "ruby",
\		"exec" : "RBENV_VERSION=3.1.0-dev %c %o %s:p",
\	},
\	"ruby/3.1.0-dev with deprecated-warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-Ku -W:deprecated",
\		"exec" : "RBENV_VERSION=3.1.0-dev %c %o %s:p",
\	},
\	"ruby/3.1.0-dev without warning" : {
\		"command" : "ruby",
\		"cmdopt" : "-Ku -W:no-deprecated -W:no-experimental ",
\		"exec" : "RBENV_VERSION=3.1.0-dev %c %o %s:p",
\	},
\	"ruby/all" : {
\		"command" : "docker",
\		"cmdopt" : "run --rm rubylang/all-ruby ./all-ruby ",
\		"exec" : '%c %o -e %{shellescape(getline(1, "$")->join(";"))}',
\	},
\	"ruby/jruby-1.7.27" : {
\		"command" : "jruby-1.7.27",
\		"exec" : "%c %o %s:p",
\	},
\	"ruby/mruby-dev" : {
\		"command" : "mruby",
\		"exec" : "RBENV_VERSION=mruby-dev %c %o %s:p",
\	},
\	"ruby/rake test without warning" : {
\		"command" : "rake",
\		"exec" : "bundle exec %c test %s:p",
\	},
\	"ruby/rake TEST without warning" : {
\		"command" : "rake",
\		"exec" : "bundle exec %c TEST=%s:p",
\	},
\	"ruby/trunk" : {
\		"exec" : "%c %o %s:p",
\		"command" : "/home/worker/build/ruby/ruby",
\		"hook/cd" : 1,
\		"hook/cd/directory" : "/home/worker/build/ruby",
\	},
\	"ruby/ruby-test" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : "/Users/worker/build/ruby/ruby",
\	},
\	"ruby/ruby-test2" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" :  expand("~/build/ruby/build"),
\	},
\	"ruby/ruby-test3" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : expand("~/build/ruby/build"),
\	},
\	"ruby/make-run" : {
\		"exec" : "%c run",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/make-run2" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 run %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/make-run3" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 run %s:p",
\		"command" : "make",
\	},
\	"ruby/make-runruby" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 runruby %s:p",
\		"command" : "make",
\	},
\	"ruby/make-runruby2" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 runruby %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/make-runruby_with_make" : {
\		"exec" : "make -j && %c DEFS=-DVM_CHECK_MODE=2 runruby %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/make-run_with_miniruby" : {
\		"exec" : "%c miniruby && %c run %o %s:p",
\		"command" : "make",
\	},
\	"ruby/make-run_with_miniruby2" : {
\		"exec" : "%c miniruby && %c run %o %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/bundle" : {
\		"exec" : "%c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle ruby 2.6" : {
\		"exec" : "RBENV_VERSION=2.6 %c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle ruby 2.7.1" : {
\		"exec" : "RBENV_VERSION=2.7.1 %c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle ruby 2.7.2" : {
\		"exec" : "RBENV_VERSION=2.7.2 %c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle ruby 3.0.0" : {
\		"exec" : "RBENV_VERSION=3.0.0 %c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle ruby 3.1.0-dev" : {
\		"exec" : "RBENV_VERSION=3.1.0-dev %c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/bundle without warning" : {
\		"exec" : "%c exec ruby %o %s:p",
\		"cmdopt" : "-Ku -W:no-deprecated -W:no-experimental ",
\		"command" : "bundle",
\	},
\	"ruby/rails runner" : {
\		"exec" : "%c runner %s:p",
\		"command" : "rails",
\		"hook/cd/directory" : '%{vital#of("vital").import("Prelude").path2project_directory(expand("%:p"))}'
\	},
\	"ruby/utf8" : {
\		"cmdopt" : "-Ku",
\		"type" : "ruby"
\	},
\	"ruby/foreman" : {
\		"exec"    : "%c %o",
\		"command" : "foreman",
\		"cmdopt" : "start",
\	},
\	"ruby/goreman" : {
\		"exec"    : "%c %o",
\		"command" : "goreman",
\		"cmdopt" : "start",
\	},
\	"ruby/syntax_check" : {
\		"command" : "ruby",
\		"exec"    : "%c %s:p %o",
\		"cmdopt"  : "-c",
\		"outputter" : "quickfix",
\		"vimproc/sleep"    : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable_exit" : 1,
\		"hook/u_nya_/enable" : 0,
\	},
\	"watchdogs_checker/rubocop" : {
\		"command" : "bundle",
\		"exec"    : "%c exec rubocop %o %s:p",
\		"errorformat" : '%f:%l:%c:%m,%f:%l:%m,%-G%.%#',
\	},
\	"ruby/bundle exec with rails-6.1" : {
\		"exec" : "%c exec appraisal rails-6.1 ruby %o %s:p",
\		"cmdopt" : "-Ku ",
\		"command" : "bundle",
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby/bundle exec with rails main" : {
\		"exec" : "%c exec appraisal rails-main ruby %o %s:p",
\		"cmdopt" : "-Ku ",
\		"command" : "bundle",
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby/bundle exec with rails 5.2" : {
\		"exec" : "%c exec appraisal rails-5.2 ruby %o %s:p",
\		"cmdopt" : "-Ku ",
\		"command" : "bundle",
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\}

" let s:config = {
" \	"ruby/utf8" : {
" \		"cmdopt" : "-Ku",
" \		"type" : "ruby"
" \	},
" \}

call extend(g:quickrun_config, s:config)
unlet s:config

autocmd BufEnter,FocusGained,WinEnter schema.rb let b:watchdogs_checker_type = "ruby/syntax_check"
"}}}


" ruby.rspec {{{
let s:config = {
\	"ruby.rspec" : {
\		"command" : "rspec",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"cmdopt"  : "-b",
\		"outputter" : "quickfix",
\	},
\	"ruby.rspec/single_on_cursor 2.5.6" : {
\		"command" : "rspec",
\		"exec"    : "RBENV_VERSION=2.5.6 %c %s:p\\:%{line('.')}",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/single_on_cursor 2.6" : {
\		"command" : "rspec",
\		"exec"    : "RBENV_VERSION=2.6.6 %c %s:p\\:%{line('.')}",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/single_on_cursor 2.7" : {
\		"command" : "rspec",
\		"exec"    : "RBENV_VERSION=2.7.1 %c %s:p\\:%{line('.')}",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/single_on_cursor 3.0" : {
\		"command" : "rspec",
\		"exec"    : "RBENV_VERSION=3.0.0 %c %s:p\\:%{line('.')}",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle" : {
\		"command" : "rake",
\		"exec"    : "bundle exec %c spec %s:p",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\	},
\	"ruby.rspec/bundle_single" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor 2.6.6" : {
\		"command" : "rake",
\		"exec"    : "RBENV_VERSION=2.6.6 bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor 2.7.1" : {
\		"command" : "rake",
\		"exec"    : "RBENV_VERSION=2.7.1 bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor 2.7.2" : {
\		"command" : "rake",
\		"exec"    : "RBENV_VERSION=2.7.2 bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor 3.0.0" : {
\		"command" : "rake",
\		"exec"    : "RBENV_VERSION=3.0.0 bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_rspec_single_on_cursor" : {
\		"command" : "rspec",
\		"exec"    : "bundle exec %c %s:p\\:%{line('.')}",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor with rails 5.2" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} RUBYOPT=\"-W:no-deprecated\" bundle exec appraisal rails-5.2 %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby.rspec/bundle_single_on_cursor with rails 6.0" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec appraisal rails-6.0 %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby.rspec/bundle_single_on_cursor with rails 6.1" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec appraisal rails-6.1 %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby.rspec/bundle_single_on_cursor with rails main" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec appraisal rails-main %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/cd/directory" : "/home/worker/Dropbox/work/software/development/forked/smarthr/activerecord-bitemporal",
\	},
\	"ruby.rspec/bundle_single_on_cursor with rails main2" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} bundle exec appraisal rails-main %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/cd/directory" : "/home/worker/Dropbox/work/worker/smarthr/activerecord-multi-tenant",
\	},
\	"ruby.rspec/bundle_single_on_cursor2" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} SPEC_OPTS=\"-b\" bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor_without_warning" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} RUBYOPT=\"-W:no-deprecated\" bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/bundle_single_on_cursor_with_foreground" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} SPEC_OPTS=\"--tag \\@foreground\" bundle exec %c spec'",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/unite_quickfix/enable" : 0,
\	},
\	"ruby.rspec/ruby-test" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : "/Users/mayu/build/ruby/build",
\	},
\	"ruby.rspec/syntax_check" : {
\		"command" : "ruby",
\		"exec"    : "%c %s:p %o",
\		"cmdopt"  : "-c",
\		"outputter" : "quickfix",
\		"vimproc/sleep"    : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable_exit" : 1,
\		"hook/u_nya_/enable" : 0,
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
"}}}


" JavaScript {{{
let s:config = {
\	"javascript" : {
\		"quickfix/errorformat" : '%A%f:%l,%Z%p%m'
\	},
\	"javascript/syntax_check" : {
\		"command" : "jshint",
\		"exec"    : "%c %s:p",
\		"outputter" : "quickfix",
\		"quickfix/errorformat" : "%f: line %l\\,\ col %c\\, %m",
\		"vimproc/sleep"    : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable_exit" : 1,
\		"hook/u_nya_/enable" : 0,
\	},
\	'javascript/jscript' : {
\		"command" : "cscript",
\		"cscript"    : "%c %o %s:p",
\		"cmdopt"  : "/Nologo",
\		"hook/output_encode/encoding" : "sjis",
\	},
\	"javascript/watchdogs_checker" : {
\		"type" : "watchdogs_checker/eslint",
\	},
\}


call extend(g:quickrun_config, s:config)
unlet s:config
"}}}


" haskell {{{
let s:errorformat = '%-G\\s%#,%f:%l:%c:%trror: %m,%f:%l:%c:%tarning: %m,'.
                \ '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c:%m,'.
                \ '%E%f:%l:%c:,%Z%m,'

" \		"vimproc/updatetime" : 40
let s:config = {
\	'haskell' : {
\		"type" : "haskell/runghc"
\	},
\	"haskell/_" : {
\		"outputter/buffer/split" : ":botright 8sp",
\	},
\	"haskell/runghc" : {
\		"command" : "runghc",
\		"exec"    : "%c -- %o %s:p",
\		"cmdopt"  : "-fno-warn-tabs"
\	},
\	"haskell/stack_runghc" : {
\		"command" : "stack",
\		"exec"    : "%c exec -- runghc -- %o %s:p",
\		"cmdopt"  : "-fno-warn-tabs"
\	},
\}
unlet s:errorformat

call extend(g:quickrun_config, s:config)
unlet s:config
"}}}


" Lua {{{
let s:config = {
\	"lua" : {
\		"quickfix/errorformat" : '%.%#: %#%f:%l: %m',
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
"}}}


" C# {{{
let s:config = {
\	'cs' : {
\		'command' : 'C:/WINDOWS/Microsoft.NET/Framework/v4.0.30319/csc',
\		"hook/output_encode/encoding" : "sjis",
\		"subtype" : "run/vimproc"
\	},
\	'cs/omnisharp' : {
\		"hook/omnisharp/enable" : 1,
\		"hook/output_encode/encoding" : "sjis",
\		"outputter/quickfix/errorformat" : '%f(%l\\,%c):\ error\ CS%n:\ %m',
\		"outputter" : "quickfix",
\		"subtype" : "run/vimproc"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" Rus {{{
let s:config = {
\	'rust' : {
\		"cmdopt" : "-A dead_code"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" HTML {{{
let s:config = {
\	'html' : {
\		"type" : "run/browser/cat"
\	},
\	'html/haml' : {
\		"command" : "html2haml"
\	},
\	'html/haml_repace' : {
\		"outputter" : "error",
\		"outputter/success" : "replace_region",
\		"outputter/error"   : "message",
\		"outputter/message/log"   : 1,
\		"hook/unite_quickfix/enable" : 0,
\		"runner" : "system",
\		"type" : "html/haml"
\	},
\	'html/pug' : {
\		"command" : "html2pug",
\		"exec" : "%c --fragment < %s:p"
\	},
\	'html/pug_repace' : {
\		"outputter" : "error",
\		"outputter/success" : "replace_region",
\		"outputter/error"   : "message",
\		"outputter/message/log"   : 1,
\		"hook/unite_quickfix/enable" : 0,
\		"runner" : "system",
\		"type" : "html/pug"
\	},
\	'html/pasha_slicer' : {
\		"command" : "ruby",
\		"exec" : "%c /home/worker/Dropbox/work/worker/momonga/script/momonga/pasha_slicer.rb %s:p"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" xHTML {{{
let s:config = {
\	'xhtml' : {
\		"type" : "html/pasha_slicer"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" haml {{{
let s:config = {
\	'haml' : {
\		"type" : "haml/buffer"
\	},
\	'haml/buffer' : {
\		"command" : "haml",
\		"outputter" : "buffer"
\	},
\	'haml/browser' : {
\		"command" : "haml",
\		"outputter" : "browser"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" TypeScript {{{
let s:config = {
\	'typescript' : {
\		"type" : "typescript/tsc"
\	},
\	'typescript/tsc': {
\		'command': 'tsc',
\		'exec': ['%c --target es2020 --module commonjs %o %s', 'node %s:r.js'],
\		'tempfile': '%{tempname()}.ts',
\		'hook/sweep/files': ['%S:p:r.js'],
\	},
\	'typescript/compile' : {
\		'command': 'tsc',
\		'exec': ['%c --target es2020 --module commonjs %o %s', 'cat %s:r.js'],
\		'tempfile': '%{tempname()}.ts',
\		'hook/sweep/files': ['%S:p:r.js'],
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


" replace_region {{{
let s:config = {
\	'replace_region' : {
\		"outputter" : "error",
\		"outputter/success" : "replace_region",
\		"outputter/error"   : "message",
\		"outputter/message/log"   : 1,
\		"hook/unite_quickfix/enable" : 0,
\		"type" : "ruby"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config


let s:config = {
\	'clojure/test' : {
	\ 'command' : 'lein',
	\ "cmdopt" : "repl",
	\ 'runner': 'process_manager',
	\ 'runner/process_manager/load': '(load-file "%s")',
	\ 'runner/process_manager/prompt': 'user=> '
\ }
\}

call extend(g:quickrun_config, s:config)
unlet s:config



command! -nargs=* -range -complete=customlist,quickrun#complete
\	ReplaceRegion
\	QuickRun
\		-mode v
\		-outputter error
\		-outputter/success replace_region
\		-outputter/error message
\		-outputter/message/log 1
\		-hook/unite_quickfix/enable 0
\		-hook/echo/enable 0
\		<args>
" }}}

" マッピング
vnoremap <Space>rp :ReplaceRegion ruby/utf8<CR>


" }}}


" マッピング {{{
" QuickRun

" 1つ前にコンパイルしたファイルでコンパイル
nnoremap <silent> <Leader><C-r> :QuickRun -hook/run_prevconfig/enable 1<CR>

function! GetNowQuickrunConfig(...)
	let base_type = get(a:, 1, &filetype)
	return extend(copy(get(g:quickrun_config, base_type."/_", {})), get(unite#sources#quickrun_config#quickrun_config_all(), unite#sources#quickrun_config#config_type(), {}), "force")
endfunction

" 実行
" nnoremap <Leader>R :QuickRun run/vimproc -hook/close_buffer/enable_exit 0<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
" }}}


" watchdogs.vim {{{
" let g:watchdogs_check_BufWritePost_enable = 1
let g:watchdogs_check_BufWritePost_enable_on_wq = 0
" let g:watchdogs_check_BufWritePost_enables = {
" \	"ruby" : 1,
" \}

let g:watchdogs_check_CursorHold_enable = 1
" let g:watchdogs_check_CursorHold_enables = {
" \	"cpp" : 1,
" \	"cs"  : 1
" \}


" set updatetime=2000


let s:config = {
\	"watchdogs_checker/_" : {
\		"runner" : "job",
\		"hook/extend_config/enable" : 0,
\		"outputter" : "bufixlist",
\		"outputter/bufixlist/open_cmd" : "",
\		"hook/inu/enable" : 0,
\		"hook/santi_pinch/enable" : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable" : 0,
\		"hook/close_quickfix/enable_exit" : 1,
\		"hook/redraw_unite_quickfix/enable_exit" : 0,
\		"hook/close_unite_quickfix/enable_exit" : 1,
\		"hook/location_list_replace_tempname_to_bufnr/enable_exit" : 1,
\		"hook/location_list_replace_tempname_to_bufnr/priority_exit" : -10,
\		"hook/back_buffer/enable" : 0,
\		"hook/back_tabpage/enable" : 0,
\		"hook/back_window/enable" : 0,
\		"hook/gift_back_start_window/enable" : 0,
\		"hook/clear_quickfix/enable_hook_loaded" : 0,
\		"hook/echo/enable" : 0,
\	},
\
\	"ruby/watchdogs_checker" : {
\		"type" : "watchdogs_checker/ruby",
\	},
\
\	"cpp/watchdogs_checker" : {
\		"hook/add_include_option/enable" : 1,
\		"type" : "watchdogs_checker/clang++",
\	},
\	
\	"watchdogs_checker/msvc" : {
\		"hook/output_encode/encoding" : "sjis",
\		"hook/vcvarsall/enable" : 1,
\		"hook/vcvarsall/bat" : shellescape($VS100COMNTOOLS  . '..\..\VC\vcvarsall.bat'),
\		"cmdopt" : "/zs",
\	},
\
\	"watchdogs_checker/g++" : {
\		"command"   : $gccs_root."/gcc4_8/_bin/g++.exe",
\		"cmdopt" : "-Wall",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"watchdogs_checker/g++03" : {
\		"command"   : $gccs_root."/gcc4_8/_bin/g++.exe",
\		"cmdopt" : "-Wall",
\		"errorformat" : '%f:%l:%c:\ %t%*[^:]:%m,%f:%m',
\	},
\
\	"watchdogs_checker/clang_check" : {
\		"command" : "clang-check",
\		"exec"    : "%c %s:p -- %o",
\		"cmdopt" : "--std=c++1y",
\	},
\
\	"watchdogs_checker/clang++" : {
\		"command" : "clang++-5.0",
\		"cmdopt" : "-Wall -Wunreachable-code --std=c++1z",
\	},
\
\	"watchdogs_checker/clang++03" : {
\		"cmdopt" : "-Wall",
\	},
\
\	"watchdogs_checker/ruby_" : {
\		"cmdopt" : "-w",
\	},
\
\	"python/watchdogs_checker" : {
\		"type" : "watchdogs_checker/pyflakes",
\	},
\
\	"cs/watchdogs_checker" : {
\		"type" : "watchdogs_checker/Omnisharp",
\	},
\
\	"watchdogs_checker/Omnisharp" : {
\		"hook/extend_config/force" : 0,
\		"runner" : "vimscript",
\		"outputter" : "null",
\		"exec" : ":OmniSharpFindSyntaxErrors",
\		"hook/close_quickfix/enable_exit" : 1,
\	},
\
\
\	"haskell/watchdogs_checker" : {
\		"type" : "watchdogs_checker/hdevtools",
\	},
\
\	"watchdogs_checker/hdevtools" : {
\		"command" : "/home/worker/.cabal/bin/hdevtools",
\	},
\
\}
	
" \	"watchdogs_checker/pyflakes" : {
" \		"command" : "c:/python27/scripts/pyflakes",
" \	},


" \		'exec': '%C -N -u NONE -i NONE -V1 -e -s -c "set rtp+=D:/home/.vim/neobundle/vim-vimlparser,D:/home/.vim/neobundle/vim-vimlint" -c "call vimlint#vimlint(''%s'', {})" -c "qall!"',
call extend(g:quickrun_config, s:config)
unlet s:config

" watchdogs.vim の設定を追加
call watchdogs#setup(g:quickrun_config)
" }}}



command! -nargs=* -range=0 -complete=customlist,quickrun#complete
\	QuickRun
\	call quickrun#command([
\		get(g:quickrun_config, &filetype."/_", {}),
\		<q-args>,
\	], <count>, <line1>, <line2>)

" \	call quickrun#command(extend(quickrun#config(<q-args>), get(g:quickrun_config, &filetype."/_", {}), "keep"), <count>, <line1>, <line2>)
" \	call quickrun#command(quickrun#config(<q-args>), <count>, <line1>, <line2>)


function! s:quickrun(args, count)
	let context = context_filetype#get(precious#base_filetype())
	let type = string(get(get(b:, "quickrun_config", {}), "type", context.filetype))
	execute context.range[0][0].",".context.range[1][0]
\		"QuickRun -type " type a:args
endfunction

command! -nargs=* -range=0 -complete=customlist,quickrun#complete
\	ContextQuickRun :call s:quickrun(<q-args>, <count>)


let g:unite_quickfix_is_multiline=0

" quickrun-hook-exec_command {{{
let s:hook = {
\	"name" : "exec_command",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\	}
\}

let s:points = [
\	"hook_loaded",
\	"normalized",
\	"module_loaded",
\	"ready",
\	"output",
\	"success",
\	"failure",
\	"finish",
\	"exit",
\]

for s:point in s:points
	let s:hook.config["on_" . s:point] = ""
	execute join([
\		"function! s:hook.on_" . s:point . "(session, context)",
\		"	if has_key(self.config, 'on_" . s:point . "') | execute self.config.on_" . s:point . " | endif",
\		"endfunction"
\	], "\n")
endfor


call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}



function! Test()
	for i in range(1, 10)
		let b:_{i} = deepcopy(g:quickrun_config)
	endfor
endfunction


let s:hook = {
\	"name" : "set_old_qflist",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\	}
\}

function! s:hook.on_exit(...)
	call setqflist(s:old_qflist, "a")
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook


let s:hook = {
\	"name" : "second_run",
\	"kind" : "hook",
\	"config" : {
\		"enable" : 0,
\		"type" : "",
\	}
\}

function! s:execute(cmd)
	execute a:cmd
endfunction

function! s:hook.on_exit(...)
	echom self.config.type
	let s:old_qflist = getqflist()
	let cmd = join([
\		"WatchdogsRun",
\		self.config.type,
\		"-outputter quickfix",
\		"-hook/set_old_qflist/enable 1",
\	])
	call timer_start(1, { -> s:execute(cmd) }, { "repeat" : 1 })
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook



" e.g. call MultiRun("watchdogs_checker/rubocop", "watchdogs_checker/ruby")
function! MultiRun(a, b)
	let s:old_qflist = []
	let cmd = join([
\		"WatchdogsRun",
\		a:b,
\		"-outputter quickfix",
\		"-hook/second_run/enable 1",
\		"-hook/second_run/type " . a:a,
\		"-hook/clear_quickfix/enable_hook_loaded 1",
\	])
	echo cmd
	execute cmd
endfunction

" let g:quickrun_config._["outputter/buffer/split"] = ":botright 6sp"
" let g:quickrun_config._["hook/unite_quickfix/unite_options"] = "-no-quit -direction=botright -winheight=6 -max-multi-lines=32 -wrap"


" vim:set foldmethod=marker:
