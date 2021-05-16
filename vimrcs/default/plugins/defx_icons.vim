" ハイライト
function! s:clear_syn_list(opt)
	let highlight_name = "my_devicons"
	let syntax_name = "my_devicons_syntax"
	let result = []
	for [name, opts] in defx_icons#get()["icons"][a:opt]->items()
		let text = substitute(name, '[^A-Za-z]', "", "g")
		call add(result, printf("silent! syntax clear %s_%s", highlight_name, text))
	endfor
	return result
endfunction
	
function! s:syn_list(opt)
	let highlight_name = "my_devicons"
	let syntax_name = "my_devicons_syntax"
	let result = []
	for [name, opts] in defx_icons#get()["icons"][a:opt]->items()
		let text = substitute(name, '[^A-Za-z]', "", "g")
		call add(result, printf("silent! syntax clear %s_%s", highlight_name, text))
" 		call add(result, printf("syntax match %s_%s /%s/ containedin=ALL", highlight_name, text, opts["icon"]))
		call add(result, printf("syntax match %s_%s /%s/ contained containedin=ALL", highlight_name, text, opts["icon"]))
" 		call add(result, printf("syntax match %s_%s /%s/ contained containedin=TOP", highlight_name, text, opts["icon"]))
" 		call add(result, printf("syntax match %s_%s /%s/ contained containedin=%s", highlight_name, text, opts["icon"], syntax_name))
		call add(result, printf("highlight default %s_%s guifg=#%s ctermfg=%s", highlight_name, text, opts["color"], get(opts, "term_color", "NONE")))
	endfor
	return result
endfunction


function! s:highlight()
	" [WIP] ディレクトリのハイライト
	let s:directory_icons = {}
	for name in ["parent_icon"]
		let s:directory_icons["dir_" . name] = {
		\ "icon" : defx_icons#get()["icons"][name]
		\}
	endfor

	let commands = []
	call add(commands, s:clear_syn_list('pattern_matches'))
	call add(commands, s:clear_syn_list('exact_matches'))
	call add(commands, s:clear_syn_list('exact_dir_matches'))
	call add(commands, s:clear_syn_list('extensions'))

	call add(commands, s:syn_list('extensions'))
	call add(commands, s:syn_list('exact_matches'))
	call add(commands, s:syn_list('exact_dir_matches'))
	call add(commands, s:syn_list('pattern_matches'))
	call flatten(commands)
	for cmd in commands
		execute cmd
	endfor
endfunction
command! IconHighlight call s:highlight()

augroup icon_highlight
	autocmd!
	autocmd Syntax unite call s:highlight()
	autocmd Syntax denite call s:highlight()
augroup END
