" デフォルトのルールを一旦クリアする
call lexima#clear_rules()

" 便利関数定義
function! s:as_list(a)
	return type(a:a) == type([]) ? a:a : [a:a]
endfunction

" 無視するルールを追加する
" 特定のコンテキストでみは無視する的な
function! s:add_ignore_rule(rule)
	let rule = copy(a:rule)
	let rule.input = rule.char
	let rule.input_after = ""
	call lexima#add_rule(rule)
endfunction


" ルールを追加する
function! s:add_rule(rule, ...)
	call lexima#add_rule(a:rule)
	if a:0 == 0
		return
	endif

	for ignore in s:as_list(a:1)
		call s:add_ignore_rule(extend(copy(a:rule), ignore))
	endfor
endfunction


" let s:String = vital#of("vital").import("Data.String")
let s:String = {}
function! s:String.escape_pattern(str)
	return escape(a:str, '^$~.*[]\')
endfunction

function! s:replace_bracket(str, bracket)
	let begin = s:String.escape_pattern(a:bracket[0])
	let end   = s:String.escape_pattern(a:bracket[1])
	return substitute(substitute(a:str, '(', begin, "g"), ')', end, "g")
endfunction


function! s:replace_bracket_rule(bracket, rule)
	let rule = copy(a:rule)
	if has_key(rule, "at")
		let begin = s:String.escape_pattern(a:bracket[0])
		let end   = s:String.escape_pattern(a:bracket[1])
		let rule.at = s:replace_bracket(rule.at, [begin, end])
	endif

	for key in ["char", "input", "input_after"]
		if has_key(rule, key)
			let rule[key] = s:replace_bracket(rule[key], a:bracket)
		endif
	endfor
	return rule
endfunction


function! s:add_bracket(bracket, rule, ...)
	let rule = s:replace_bracket_rule(a:bracket, a:rule)
	let ignore = map(copy(get(a:, 1, [])), "s:replace_bracket_rule(a:bracket, v:val)")

	call s:add_rule(rule, ignore)
endfunction




let s:ignore_syntaxs = ["String", "Comment"]
let s:ignore_syntaxs = ["String"]
let s:ignore_rules = [{ "syntax" : s:ignore_syntaxs }]


" let s:bracket_rules = [
" \	{'at': '\%#',   'char': '(',    'input_after': ')',
" \		"ignore" : [{ "at" : '\%#)' }, {"at" : '\%#\w'}]},
" \	{'at': '(\%#)', 'char': ')',    'input': '<Right>'},
" \	{'at': '(\%#)', 'char': '(',    'input_after': ')'},
" \	{'at': '(\%#)', 'char': '<BS>', 'input': '<BS><Del>'},
" \	{'at': '(\%#)', 'char': '<Enter>', 'input': '<Enter><Enter><Up><Tab>'},
" \	{'at': '(\%#)', 'char': '<Space>', 'input': '<Space><Space><Left>'},
" \]

" \		"ignore" : [{ "at" : '\%#)' }, {"at" : '\%#\w'}]},
let s:bracket_rules = [
\	{'at': '\%#',   'char': '(',    'input_after': ')',
\		"ignore" : [{"at" : '\%#[^[:space:],`}\]).]'}]},
\	{'at': '(\%#)', 'char': ')',    'input': '<Right>'},
\	{'at': '(\%#)', 'char': '(',    'input_after': ')'},
\	{'at': '(\%#)', 'char': '<BS>', 'input': '<BS><Del>'},
\	{'at': '(\%#)', 'char': '<Enter>', 'input': '<Enter><Enter><Up><Tab>'},
\	{'at': '(\%#)', 'char': '<Space>', 'input': '<Space><Space><Left>'},
\	{'at': '( \%# )', 'char': '<BS>', 'input': '<BS><Del>'},
\	{'at': '( \%# )', 'char': '<Space>', 'input': ''},
\]

let s:brackets = [['(', ')'], ['{', '}'], ['[', ']'], ['`', '`']]


for s:rule in s:bracket_rules
	let s:ignore = s:ignore_rules + get(s:rule, 'ignore', [])
	call map(deepcopy(s:brackets), "s:add_bracket(v:val, s:rule, s:ignore)")

	" <> rule
	let s:rule = copy(s:rule)
	let s:rule.at = '\k' . s:rule.at
	call map(copy(s:bracket_rules), "s:add_bracket(['<', '>'], s:rule, s:ignore)")
endfor
unlet s:rule


call s:add_rule({"at" : '\%#', "char" : '"', "input_after" : '"'},
\	[{"at" : '^\s*\%#', 'filetype' : "vim"}, {"at" : '[^"]\%#"'}, {"at" : '\\\%#'}, {"at" : '"\%#'}] + s:ignore)
call lexima#add_rule({"at" : '"\%#"', "char" : '<BS>', "input" : '<BS><Del>'})
call lexima#add_rule({"at" : '"\%#"', "char" : '"', "input" : '<Right>'})
" "syntax" を設定して他の syntax : "String" と優先順位を同じにする
call lexima#add_rule({"at" : '\%#"', "char" : '"', "input" : '<Right>', "syntax" : "String"})

call s:add_rule({"at" : '\%#', "char" : "'", "input_after" : "'"},
\	[{"at" : '^\s*\%#'}, {"at" : "[^']\\%#'"}, {"at" : '\\\%#'}] + s:ignore)
call lexima#add_rule({"at" : "'\\%#'", "char" : '<BS>', "input" : '<BS><Del>'})
call lexima#add_rule({"at" : "'\\%#'", "char" : "'", "input" : '<Right>'})
call lexima#add_rule({"at" : "'\\%#'", "char" : "'", "input" : '<Right>', "syntax" : "String"})



" . で omnifunc を呼び出す
" call s:add_rule(
" \	{"at" : '\S\%#', "char" : '.', "input" : '.<C-x><C-o>', "filetype" : "ruby"},
" \	[
" \		{"at" : '\%#"',  "priority" : 10},
" \		{"at" : "\\%#'", "priority" : 10},
" \		{"syntax" : ["String", "Comment"]}
" \])

" call s:add_rule(
" \	{"at" : '\S:\%#', "char" : ':', "input" : ':<C-x><C-o>', "filetype" : "ruby"},
" \	[
" \		{"at" : '\%#"',  "priority" : 10},
" \		{"at" : "\\%#'", "priority" : 10},
" \		{"syntax" : ["String", "Comment"]}
" \	])

call s:add_rule({"char" : "#", "input" : "#{}<Left>", "filetype" : "ruby", "syntax" : ["String", "Special"]})
call s:add_rule({"at" : '#{\%#}', "char" : "#", "input" : "<Right><BS><BS>", "filetype" : "ruby", "syntax" : ["String", "Special"]})

call s:add_rule({"at" : '{\s*\%#', "char" : "<Bar>", "input_after" : "|", "filetype" : "ruby"})



call s:add_rule({"char" : "#", "input" : "#{}<Left>", "filetype" : "ruby.rspec", "syntax" : ["String", "Special"]})


" augroup cpp-auto;
" 	autocmd!
" 	" 末尾が " ' ) の場合に ; を追加する
" 	autocmd InsertLeave *
" \	if &filetype == "cpp" && getline(".") =~ '["'')]$'
" \|		call setline(".", getline(".") . ";")
" \|	end


" ,の後にスペースを入れる
call s:add_rule({
\	"at" : '\%#\(\S\|$\)',
\	"char" : ",",
\	"input" : ",<Space>",
\}, [
\	{"syntax" : ["String", "Comment"]}
\])


" ", \%#" の時に <BS> で ", " ごと消す
call s:add_rule({
\	"at" : ', \%#',
\	"char" : '<BS>',
\	"input" : "<BS><BS>",
\})


" ", " の後にスペースを続けれないようにする
" 誤爆防止用
call s:add_rule({
\	"at" : ', \%#',
\	"char" : '<Space>',
\	"input" : "",
\})

" ", "の後に改行したら末尾のスペースを消す
call s:add_rule({
\	"at" : ', \%#',
\	"char" : '<Enter>',
\	"input" : '<BS><Enter>',
\})



" erb
call s:add_rule(
\	{"at" : '<\%#', "char" : '%', "input" : '%<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)

call s:add_rule(
\	{"at" : '>\%#', "char" : '%', "input" : '<%<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)

call s:add_rule(
\	{"at" : '^\s*\%#', "char" : '%', "input" : '<%<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)



call s:add_rule(
\	{"at" : '<\%#', "char" : '=', "input" : '%=<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)

call s:add_rule(
\	{"at" : '>\%#', "char" : '=', "input" : '<%=<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)

call s:add_rule(
\	{"at" : '^\s*\%#', "char" : '=', "input" : '<%=<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)


call s:add_rule(
\	{"at" : '^\s*\%#', "char" : '#', "input" : '<%#<Space><Space>%><Left><Left><Left>', "filetype" : "eruby"},
\)


call s:add_rule(
\	{"at" : '<% \%# %>', "char" : '<BS>', "input" : '<Right><Right><Right><BS><BS><BS><BS><BS><BS>', "filetype" : "ruby"},
\)

call s:add_rule(
\	{"at" : '<%= \%# %>', "char" : '<BS>', "input" : '<Right><Right><Right><BS><BS><BS><BS><BS><BS><BS>', "filetype" : "ruby"},
\)

" markdown で `- <Tab>` すると
" call s:add_rule(
" \	{"at" : '- \%#', "char" : '<Tab>', "input" : '<Left><Left><Tab><Right><Right>', "filetype" : "markdown"},
" \)
"
" call s:add_rule(
" \	{"at" : '* \%#', "char" : '<Tab>', "input" : '<Left><Left><Tab><Right><Right>', "filetype" : "markdown"},
" \)



