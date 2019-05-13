
" set statusline=%1*%m%*%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %f%=[tabpage%{tabpagenr()}][winnr:%{winnr()}][uniq_tabpage%{gift#uniq_tabpagenr()}][uniq_winnr:%{gift#uniq_winnr()}]%-2(%)\ %-11(%l,%c%)\ %4P
" 
" 
" finish

function! s:split(cmd, name)
	let winnr = gift#uniq_winnr(a:name)
	if winnr == -1
		silent execute a:cmd
		call s:set_winname(a:name)
	else
		silent execute winnr . "wincmd w"
	endif
endfunction

" ウィンドウ名を指定して split する
" 既に存在するウィンドウ名であればそこに移動する
command! -bar -count=0 -nargs=1
\	Split call s:split("split", <q-args>) | if <count> | silent execute <count> | endif

" 行番号を指定して preview ウィンドウを開く
" 123ss
nnoremap <silent> ss :<C-u>execute v:count."Split preview"<CR>

nnoremap <silent> <C-@> :execute line(".")."Split search"<CR>*zz



" finish

function! s:is_number(str)
	return (type(a:str) == type(0)) || (a:str =~ '^\d\+$')
endfunction


function! s:winnrlist(...)
	return a:0
\		? range(1, tabpagewinnr(a:1, "$"))
\		: range(1, tabpagewinnr(tabpagenr(), "$"))
endfunction


function! s:winlist(...)
	let tabnr = a:0 == 0 ? tabpagenr() : a:1
	return map(s:winnrlist(tabnr), '{
\		"winnr" : v:val,
\		"name"  : gettabwinvar(tabnr, v:val, "name")
\	}')
endfunction


function! s:winnr(...)
	return a:0 == 0    ? winnr()
\		 : a:1 ==# "$" ? winnr("$")
\		 : a:1 ==# "#" ? winnr("#")
\		 : !s:is_number(a:1) ? (filter(s:winnrlist(), "s:winname(v:val) ==# a:1")+[-1])[0]
\		 : a:1
endfunction

function! s:winname(...)
	return a:0 == 0    ? s:winname(winnr())
\		 : a:1 ==# "$" ? s:winname(winnr("$"))
\		 : a:1 ==# "#" ? s:winname(winnr("#"))
\		 : !s:is_number(a:1) ? (filter(s:winlist(), 'v:val.name ==# a:1') + [{'name' : ''}])[0].name
\		 : (filter(s:winlist(), 'v:val.winnr ==# a:1') + [{'name' : ''}])[0].name
endfunction


function! s:set_winname(name)
	let w:name = a:name
endfunction

function! s:get_winname()
	return w:name
endfunction


function! Winnr(...)
	return call("s:winnr", a:000)
endfunction

function! Winname(...)
	return call("s:winname", a:000)
endfunction


if !has_key(s:, "winname_counter")
	let s:winname_counter = 0
endif

function! s:winname_numbering()
	if empty(s:winname())
		call s:set_winname("winnr_".s:winname_counter)
		let s:winname_counter += 1
	endif
endfunction



augroup Window
	autocmd!
	autocmd VimEnter,WinEnter * call s:winname_numbering()
augroup END


function! s:test_winname()
	
endfunction



function! s:set_tabpagename(name)
	let t:name = a:name
endfunction


function! s:tabpagenrlist()
	return range(1, tabpagenr("$"))
endfunction


function! s:tabpagenr(...)
	return a:0 == 0    ? tabpagenr()
\		 : a:1 ==# "$" ? tabpagenr("$")
\		 : !s:is_number(a:1) ? (filter(s:tabpagenrlist(), "s:tabpagename(v:val) ==# a:1")+[-1])[0]
\		 : a:1
endfunction



function! s:tabpagename(...)
	return a:0 == 0    ? s:tabpagename(tabpagenr())
\		 : a:1 ==# "$" ? s:tabpagename(tabpagenr("$"))
\		 : s:is_number(a:1) ? gettabvar(a:1, "name")
\		 : a:1
endfunction


function! s:tabpagewinname(tabpage, ...)
	let tabpagenr = s:tabpagenr(a:tabpage)
	let winnr = a:0 ? s:winnr(a:1) : tabpagewinnr(tabpagenr)
" 	let winnr = a:0 ? s:winnr(a:1) : s:winnr()
	return gettabwinvar(tabpagenr, winnr, "name")
endfunction


function! s:tabpagewinnr(winname)
	let winname = a:winname
	let list = eval(join(map(s:tabpagenrlist(), "map(s:winnrlist(v:val), '['.v:val.', v:val]')"), "+"))
	for data in list
		if s:tabpagewinname(data[0], data[1]) ==# winname
			return { "tabpagenr" : data[0], "winnr" : data[1] }
		endif
	endfor
	return { "tabpagenr" : -1, "winnr" : -1 }
endfunction

if !has_key(s:, "tabpagename_counter")
	let s:tabpagename_counter = 0
endif

function! s:tabpagename_numbering()
	if empty(s:tabpagename())
		call s:set_tabpagename("tabpagenr_".s:tabpagename_counter)
		let s:tabpagename_counter += 1
	endif
endfunction


function! Tabpagename(...)
	return call("s:tabpagename", a:000)
endfunction

function! Tabpagenr(...)
	return call("s:tabpagenr", a:000)
endfunction

augroup Tabpage
	autocmd!
	autocmd VimEnter,TabEnter * call s:tabpagename_numbering()
augroup END


function! s:main()
" 	echo s:tabpagewinname(1, 2)
	let list = eval(join(map(s:tabpagenrlist(), "map(s:winnrlist(v:val), '['.v:val.', v:val]')"), "+"))
	for data in list
" 		echo s:tabpagename(data[0]) . " : " . s:tabpagewinname(data[0], data[1])
" 		echo n
	endfor
	echo s:tabpagewinname(3)
	echo s:tabpagewinnr("winnr_0")
	echo s:tabpagewinnr("winnr_10")
endfunction
" call s:main()



set statusline=%1*%m%*%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %f%=[%{Tabpagename()}][%{Winname()}]%-8(%)\ %-11(%l,%c%)\ %4P


function! s:test_tabpagename()
	let winname = s:winname(1)
	Assert s:winnr(winname) == 1
	Assert s:winnr() == winnr()
	Assert s:winnr("$") == winnr("$")
	Assert s:winnr("#") == winnr("#")

	let tabwinnr = s:tabpagewinnr(winname)
	Assert tabwinnr.winnr == 1
	Assert s:tabpagewinname(tabwinnr.winnr, tabwinnr.tabpagenr) == winname
	Assert s:tabpagewinname(tabwinnr.winnr) == winname

	let tabname = s:tabpagename(tabwinnr.tabpagenr)
	Assert s:tabpagenr(tabname) == tabwinnr.tabpagenr
	Assert s:tabpagenr() == tabpagenr()
	Assert s:tabpagenr("$") == tabpagenr("$")
	
	let tanname = "homuhomuhomuhomu"
	let tabwinnr = s:tabpagewinnr(tabname)
	Assert tabwinnr.tabpagenr == -1
	Assert tabwinnr.winnr == -1
endfunction
" call s:test()


function! s:test_is_number()
	Assert !s:is_number("")
	Assert  s:is_number(1)
	Assert  s:is_number("0")
	Assert !s:is_number("homu")
	Assert !s:is_number("0ma")
	Assert  s:is_number("00")
	Assert  s:is_number("1234")
endfunction
" call s:test_is_number()





" set guitablabel=%{g:tablabel()}



function! s:split(cmd, name)
	let winnr = s:winnr(a:name)
	if winnr == -1
		silent execute a:cmd
		call s:set_winname(a:name)
	else
		silent execute winnr . "wincmd w"
	endif
endfunction

" ウィンドウ名を指定して split する
" 既に存在するウィンドウ名であればそこに移動する
command! -bar -count=0 -nargs=1
\	Split call s:split("split", <q-args>) | if <count> | silent execute <count> | endif

" 行番号を指定して preview ウィンドウを開く
" 123ss
nnoremap <silent> ss :<C-u>execute v:count."Split preview"<CR>

nnoremap <silent> <C-@> :execute line(".")."Split search"<CR>*zz





