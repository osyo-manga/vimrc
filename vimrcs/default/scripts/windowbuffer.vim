
function! WindowBufferList(...)
	let winnr = a:0 >= 1 ? a:1 : winnr()
	let tabnr = a:0 >= 2 ? a:2 : tabpagenr()
	let bufferlist = copy(gettabwinvar(tabnr, winnr, "bufferlist"))
	return empty(bufferlist) ? [bufnr("%")] : filter(bufferlist, "buflisted(v:val) && bufexists(v:val)")
endfunction

function! AddWindowBuffer(nr)
	if empty(bufname(a:nr))
		return
	endif
	let w:bufferlist = WindowBufferList() + (index(WindowBufferList(), a:nr) == -1 ? [a:nr] : [])
endfunction

function! RemoveWindowBuffer(nr)
	if empty(w:bufferlist)
		return
	endif

	call remove(w:bufferlist, index(w:bufferlist, a:nr))
	if empty(w:bufferlist)
		close
	endif
endfunction


function! s:bufname(bufnr, active)
	let label = bufname(a:bufnr)
	if label == ""
		let label = "無名-" . getbufvar(a:bufnr, "&filetype")
	elseif !filereadable(label)
		let label = bufname(a:bufnr)
	else
		let label = fnamemodify(label,':p:h:t').'/'. fnamemodify(label,':t')
	endif
	let label = (a:active == a:bufnr ? "【" . label . "】" : label)
	if getbufvar(a:bufnr, "&modified")
		let label = '+ '.label
	endif
	return label
endfunction

function! WindowBufferTabLabel()
	let buffers = WindowBufferList()
	if len(buffers) == 1
		return s:bufname(buffers[0], -1)
	else
		return join(map(copy(buffers), "s:bufname(v:val, bufnr('%'))"), " | ")
	endif
endfunction

function! s:next_buffer()
	let buffers = WindowBufferList()
	return empty(buffers) ? 0 : buffers[(index(buffers, bufnr("%"))+1) % len(buffers)]
endfunction

function! s:prev_buffer()
	let buffers = WindowBufferList()
	return  empty(buffers) ? 0 : buffers[(index(buffers, bufnr("%"))-1) % len(buffers)]
endfunction

function! s:move_next_buffer()
	let bufnr = s:next_buffer()
	if bufnr
		execute ":buffer" bufnr
	endif
endfunction

function! s:move_prev_buffer()
	let bufnr = s:prev_buffer()
	if bufnr
		execute ":buffer" bufnr
	endif
endfunction



" set guitablabel=%{WindowBufferTabLabel()}


command! -nargs=0 NextWindowBuffer call <SID>move_next_buffer()
command! -nargs=0 PrevWindowBuffer call <SID>move_prev_buffer()

command! -nargs=0 RemoveWindowBuffer :execute "NextWindowBuffer"|call RemoveWindowBuffer(s:prev_buffer())

" nnoremap <silent> <S-l> :NextWindowBuffer<CR>
" nnoremap <silent> <S-h> :PrevWindowBuffer<CR>

" nnoremap <silent> <A-l> :NextWindowBuffer<CR>
" nnoremap <silent> <A-h> :PrevWindowBuffer<CR>

" nnoremap <silent> Q :RemoveWindowBuffer<CR>

" nnoremap <silent> <C-q> :RemoveWindowBuffer<CR>
" nnoremap <silent> qq :RemoveWindowBuffer<CR>
" nnoremap <silent> q: q:
" nnoremap <silent> q/ q/
" nnoremap <silent> q <Nop>
" nnoremap <silent> <Space>bd :RemoveWindowBuffer<CR>


augroup window_buffer
	autocmd!
	autocmd BufWinEnter * :call AddWindowBuffer(bufnr("%"))
" 	autocmd BufWinEnter,WinEnter * :call AddWindowBuffer(bufnr("%"))
" 	autocmd WinEnter * :echom "homuhomu ".bufnr("%")
augroup END


function! s:tablist()
	return range(1, tabpagenr("$"))
endfunction

function! s:winlist(...)
	return a:0
\		? range(1, tabpagewinnr(a:1, "$"))
\		: range(1, tabpagewinnr(tabpagenr(), "$"))
endfunction


function! s:flatten(list, ...)
	let level = a:0 ? a:1 : -1
	return type(a:list) != type([]) ? [a:list]
\		 : empty(a:list)            ?  a:list
\		 : level == 0               ?  a:list
\		 : eval(join(map(a:list, "s:flatten(v:val, level-1)"), "+"))
endfunction

function! s:unique(list)
	let result = []
	for var in a:list
		if index(result, var) == -1
			call add(result, var)
		endif
	endfor
	return result
endfunction

function! s:buflist()
	return filter(range(1, bufnr("$")), "buflisted(v:val)")
endfunction

function! s:bufloaded_list()
	return filter(range(1, bufnr("$")), "buflisted(v:val)")
endfunction

function! s:bufexists_list()
	return filter(range(1, bufnr("$")), "bufexists(v:val)")
endfunction

function! s:delete_buffer(nr)
	execute "bw ".a:nr
endfunction

function! s:max(a, b)
	return a:a > a:b ? a:a : a:b
endfunction

function! s:min(a, b)
	return a:a < a:b ? a:a : a:b
endfunction

function! s:zip(a, b)
	return map(range(s:min(len(a:a), len(a:b))), "[a:a[v:val], a:b[v:val]]")
endfunction

function! s:tabwinnrlist()
	return map(s:flatten(map(s:tablist(), 's:zip(repeat(v:val, tabpagewinnr(v:val, "$")), s:winlist(v:val))'), 1), '{ "tabnr" : v:val[0], "winnr" : v:val[1] }')
endfunction

function! s:delete_no_active_buffers()
	let active_buflist = s:unique(s:flatten(map(s:tabwinnrlist(), "WindowBufferList(v:val.winnr, v:val.tabnr)")))
	let buflist = s:bufexists_list()
	for nr in buflist
		if index(active_buflist, nr) == -1
			call s:delete_buffer(nr)
		endif
	endfor
endfunction

command! -bar DeleteNoActiveBuffers :call s:delete_no_active_buffers()




function! s:main()
" 	echo s:unique(["a", "b", "c", "a"])
" 	echo s:unique(s:flatten([1, [2, 2, [3, 3], 4], [2, 3], 5, [5, 6]]))
" 	echo map(s:winlist(), '{
" \		"name" : getwinvar(v:val, "name"),
" \		"winnr" : v:val
" \	}')
endfunction
call s:main()


