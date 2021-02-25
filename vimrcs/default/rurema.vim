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
\		"type" : 'rd/bitclust_htmlfile',
\	},
\	"rd/_" : {
\		"command" : "bitclust",
\		"outputter" : "browser",
\	},
\	"rd/bitclust_htmlfile" : {
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:t:r')} --ruby=latest",
\	},
\	"rd/bitclust_htmlfile 3.0.0" : {
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:t:r')} --ruby=3.0.0",
\	},
\	"rd/bitclust_htmlfile 2.7.0" : {
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:t:r')} --ruby=2.7.0",
\	},
\	"rd/bitclust_htmlfile 2.6.0" : {
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:t:r')} --ruby=2.6.0",
\	},
\	"rd/bitclust_htmlfile 2.5.0" : {
\		"exec"    : "%c htmlfile %s:p --target=%{expand('%:t:r')} --ruby=2.5.0",
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
