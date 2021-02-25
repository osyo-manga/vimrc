augroup my_rurema
	autocmd!
augroup END

command! -bang -nargs=*
\	 MyRuremaAutocmd
\	 autocmd<bang> my_rurema <args>

MyRuremaAutocmd BufReadPost *.rd set filetype=rd
MyRuremaAutocmd BufReadPost */doctree/refm/api/src/* set filetype=rd


let s:config = {
\	"rd" : {
\		"type" : 'rd/bitclust_htmlfile'
\	},
\	"rd/bitclust_htmlfile" : {
\		"command" : "bitclust",
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:r')} --ruby=last",
\		"outputter" : "browser",
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
