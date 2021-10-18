function! s:capture_cmd(cmd)
	echom a:cmd
	new
	execute "read!" a:cmd
endfunction

function! s:default_branch()
	return systemlist("git symbolic-ref refs/remotes/origin/HEAD | awk -F'[/]' '{print $NF}'")[0]
endfunction

" 現在開いているファイルの master ブランチ時点でのファイルを Vim で開く
function! s:git_show(branch, path, filetype)
	if a:branch == ""
		let branch = s:default_branch()
	else
		let branch = a:branch
	endif
	
	let cmd = printf("git show %s:%s", branch, a:path)
	call s:capture_cmd(cmd)
	let &filetype = a:filetype
	" 一番上の行に移動して空業を削除
	normal! ggdd
endfunction

command! -nargs=* GitShowCurrent
\	call s:git_show(<q-args>, "./" . expand("%:."), &filetype)


" github の pr を開く openpr
" gitconfig に設定してある openpr が前提
function! s:openpre_open() abort
  let line = line('.')
  let fname = expand('%')
  let cmd = printf('git blame -L %d,%d %s | cut -d " " -f 1', line, line, fname)
  let sha1 = system(cmd)
  let cmd = printf('gh openpr %s', sha1)
  echo system(cmd)
endfunction
" nnoremap <F5> :call <SID>openpre_open()<CR>


command! -nargs=* Commit
\	echo system(printf("git commit %s -m %s", expand("%:p"), shellescape(<q-args>)))
command! -nargs=* GitReset echo system("git reset --soft HEAD^")



