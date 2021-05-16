tnoremap <C-r> <C-w>"
tnoremap <C-v> <C-w>"*


finish



" vital-palette-keymapping
function! s:escape_special_key(key)
	" Workaround : <C-?> https://github.com/osyo-manga/vital-palette/issues/5
	if a:key ==# "<^?>"
		return "\<C-?>"
	endif
	execute 'let result = "' . substitute(escape(a:key, '\"'), '\(<.\{-}>\)', '\\\1', 'g') . '"'
	return result
endfunction


" キーマッピングの設定
" set termkey=<A-w>
if exists(":tmap")
	tnoremap <Esc> <A-w><S-n>
endif


function! s:terminal(bufnr)
	let bufnr = a:bufnr
	return {
\		"bufnr" : bufnr,
\		"bufname" : bufname(bufnr),
\		"size"  : term_getsize(bufnr),
\		"job"   : term_getjob(bufnr),
\	}
endfunction


function! s:bufnew()
	if &buftype == "terminal" && &filetype == ""
		set filetype=terminal
	endif
endfunction


function! s:filetype()
	" set filetype=terminal のタイミングでは動作しなかったので
	" timer_start() で遅延して設定する
	call timer_start(0, { -> feedkeys(s:escape_special_key(&termkey) . "\<S-n>") })

	setlocal noswapfile
	setlocal bufhidden=hide

	nnoremap <buffer> q <C-w><C-q>

	let g:latest_terminal = s:terminal(bufnr("%"))
endfunction


augroup my-terminal
	autocmd!
	autocmd BufNew * call timer_start(0, { -> s:bufnew() })
	autocmd FileType terminal call s:filetype()
augroup END


function! s:open(args) abort
	if empty(term_list())
		execute "terminal" a:args
	else
		let bufnr = term_list()[0]
		execute term_getsize(bufnr)[0] . "new"
		execute "buffer + " bufnr
	endif
endfunction


" すでに :terminal が存在していればその :terminal を使用する
command! -nargs=*
\	Terminal call s:open(<q-args>)


finish
" https://twitter.com/mattn_jp/status/921217883023147008
map(filter(range(1, bufnr("%")), { -> getbufvar(v:val, "&buftype") == "terminal" }), { -> job_stop(term_getjob(v:val)) })
