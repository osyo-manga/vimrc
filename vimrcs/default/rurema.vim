augroup my_rurema
	autocmd!
augroup END

command! -bang -nargs=*
\	 MyRuremaAutocmd
\	 autocmd<bang> my_rurema <args>

MyRuremaAutocmd BufReadPost *.rd set filetype=rd
MyRuremaAutocmd BufReadPost */doctree/refm/api/src/* set filetype=rd

function! Grurema_target()
	return (expand('%:t:r') =~ '^\u') ? ('--target=' . expand('%:t:r')) : ''
endfunction

let s:config = {
\	"rd" : {
\		"type" : 'rd/bitclust_htmlfile',
\	},
\	"rd/_" : {
\		"command" : "bitclust",
\		"outputter" : "browser",
\		"exec"    : "%c htmlfile %s:p %{ Grurema_target() } %o",
\	},
\	"rd/bitclust_htmlfile" : {
\		"cmdopt"    : "--ruby=latest",
\	},
\	"rd/bitclust_htmlfile 3.0.0" : {
\		"cmdopt"    : "--ruby=3.0.0",
\	},
\	"rd/bitclust_htmlfile 2.7.0" : {
\		"cmdopt"    : "--ruby=2.7.0",
\	},
\	"rd/bitclust_htmlfile 2.6.0" : {
\		"cmdopt"    : "--ruby=2.6.0",
\	},
\	"rd/bitclust_htmlfile 2.5.0" : {
\		"cmdopt"    : "--ruby=2.5.0",
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config

function! s:kusa(start, end)
	let view = winsaveview()
	call append(a:start - 1, "#@samplecode 例")
	for lnum in range(a:start + 1, a:end + 1)
		call setline(lnum, matchstr(getline(lnum), '\s\{2}\zs.*'))
	endfor
	call append(a:end + 1, "#@end")
	call winrestview(view)
endfunction

command! -range=% Kusa call s:kusa(<line1>, <line2>)

