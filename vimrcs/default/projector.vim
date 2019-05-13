

" function! s:open_project_explorer()
" 	let project_dir =
" endfunction

" nnoremap <silent><expr> <Space>vfe <SID>open_project_explorer()

function! s:get_project_directory()
	return has_key(g:, "project_directory") && isdirectory(g:project_directory) ? g:project_directory : ""
endfunction

nnoremap <Space>vfe :execute "VimFilerExplorer -winwidth=20 ".<SID>get_project_directory()<CR>
nnoremap <Space>gr  :execute "Unite grep:".substitute(get(g:, "project_directory", ""), '\:', '\\:', 'g')<CR>

function! s:change_cd(dir)
	if get(g:, "is_quickrun_started", 0)
		return
	endif
	try
		execute ":lcd " a:dir
	catch
		echom "Error"
	endtry

" 	if has_key(g:, "project_directory") && isdirectory(g:project_directory)
" 		execute ":lcd" g:project_directory
" " 	elseif file_readable(expand("%:p"))
" 	elseif isdirectory(a:dir)
" " 		echom a:dir
" 		execute ":lcd " a:dir
" 	endif
endfunction


" 常に開いているファイルと同じディレクトリをカレントディレクトリにする
" http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html#mozTocId567011
augroup vimrc_group__cd
	autocmd!
" 	autocmd BufEnter *
" \|			execute ":lcd " . (isdirectory(expand("%:p:h")) ? expand("%:p:h") : "")
" \|			execute isdirectory(expand("%:p:h")) ? ":lcd " . expand("%:p:h") : ""

" 	autocmd BufEnter *
" \	if !(exists("*QuickrunStarted") && QuickrunStarted())
" \|		call s:change_cd(expand("%:p:h"))
" \|	endif

	autocmd FileReadPost,BufEnter,BufWinEnter,WinEnter,TabEnter * call s:change_cd(expand("%:p:h"))

	" :QuickRun 中はカレントディレクトリを変更しない
" 	autocmd FileReadPost,BufEnter *
" \	if !get(g:, "is_quickrun_started", 0)
" \|		execute isdirectory(expand("%:p:h")) ? ":lcd " . expand("%:p:h") : ""
" \|	endif

augroup END


