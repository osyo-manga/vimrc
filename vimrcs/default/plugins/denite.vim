
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" denite のバッファの設定
augroup my_denite
	autocmd!
	autocmd FileType denite call s:denite_my_settings()
	autocmd FileType denite-filter call s:denite_filter_my_settings()
" 	autocmd FileType denite-filter inoremap <buffer> <C-c> :echom "hogehoge"
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" denite.nvim のバッファの設定
function! s:denite_my_settings()
	nnoremap <silent><buffer><expr> <CR>
	\ denite#do_map('do_action')
	nnoremap <silent><buffer><expr> d
	\ denite#do_map('do_action', 'delete')
	nnoremap <silent><buffer><expr> p
	\ denite#do_map('do_action', 'preview')
	nnoremap <silent><buffer><expr> q
	\ denite#do_map('quit')
	nnoremap <silent><buffer><expr> i
	\ denite#do_map('open_filter_buffer')
	nnoremap <silent><buffer><expr> <Space>
	\ denite#do_map('toggle_select').'j'
	nnoremap <silent><buffer><expr> <C-Space>
	\ denite#do_map('toggle_select').'j'
	nnoremap <silent><buffer><expr><nowait> t
	\ denite#do_map('do_action', 'tabswitch')
	nnoremap <silent><buffer><expr> a
	\ denite#do_map('choose_action')
	nnoremap <silent><buffer><expr> *
	\ denite#do_map('toggle_select_all')
	nnoremap <silent><buffer><expr><nowait> s
	\ denite#do_map('do_action', 'vsplit')
	nnoremap <silent><buffer><expr> <C-g>
	\ denite#do_map('echo')
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" denite.nvim のフィルタバッファの設定
function! s:denite_filter_my_settings() abort
	augroup ftplugin-my-denite
		autocmd! * <buffer>
		" denite-filter 用のキーマッピング
		" NOTE: このタイミングじゃないとキーマッピングが反映されない
		" フィルタリング中に Enter を押すと選択されている候補のデフォルトアクションを実行する
		autocmd InsertEnter <buffer> imap <silent><buffer> <CR> <ESC><CR><CR>
		" インサートを抜けた時に自動的にフィルタウィンドウを閉じる
		autocmd InsertEnter <buffer> inoremap <silent><buffer> <Esc> <Esc><C-w><C-q>:<C-u>call denite#move_to_parent()<CR>
	augroup END

	" フィルタバッファでは自動補完を無効にしておく
	call deoplete#custom#buffer_option('auto_complete', v:false)

	" ステータスラインに file/rec(10/100) のような候補数を表示させる
	setlocal statusline=%!denite#get_status('sources')

	" カーソルキーで候補の選択を移動させる
	inoremap <silent><buffer> <Down> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')+1,0)<CR>
		\:call denite#move_to_filter()<CR>A
	inoremap <silent><buffer> <Up> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')-1,0)<CR>
		\:call denite#move_to_filter()<CR>A
	" 同様のことを <C-j><C-k> で
	inoremap <silent><buffer> <C-j> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')+1,0)<CR>
		\:call denite#move_to_filter()<CR>A
	inoremap <silent><buffer> <C-k> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')-1,0)<CR>
		\:call denite#move_to_filter()<CR>A
	" 同様のことを <C-j><C-k> で
	inoremap <silent><buffer> <C-n> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')+1,0)<CR>
		\:call denite#move_to_filter()<CR>A
	inoremap <silent><buffer> <C-p> <Esc>
		\:call denite#move_to_parent()<CR>
		\:call cursor(line('.')-1,0)<CR>
		\:call denite#move_to_filter()<CR>A

	return

	" インサートを抜けた時に自動的に候補のバッファに移動する
	imap <silent><buffer> <Esc> <Esc>:call denite#move_to_parent()<CR>
	imap <silent><buffer> <C-[> <C-[>:call denite#move_to_parent()<CR>

	" フィルタバッファで <CR> すると候補を実行する
	inoremap <silent><buffer> <CR> <Esc>
		\:call denite#move_to_parent()<CR>
		\<CR>
	" 別キーで実装
	inoremap <silent><buffer> <C-CR> <Esc>
		\:call denite#move_to_parent()<CR>
		\<CR>
	inoremap <silent><buffer> <C-m> <Esc>
		\:call denite#move_to_parent()<CR>
		\<CR>

endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" :Denite のデフォルトの設定
let s:denite_default_options = {}


" 絞り込んだワードをハイライトする
call extend(s:denite_default_options, {
\	'highlight_matched_char': 'None',
\	'highlight_matched_range': 'Search',
\	'match_highlight': v:true,
\})

" denite を上に持っていく
call extend(s:denite_default_options, {
\	'direction': "top",
\	'filter_split_direction': "top",
\})

" フィルタのプロンプトを設定
call extend(s:denite_default_options, {
\	'prompt': '> ',
\})

" 大文字小文字を区別してフィルタする
call extend(s:denite_default_options, {
\	'smartcase': v:true,
\})

" ステータスラインに入力を表示しないようにする
" call extend(s:denite_default_options, {
"\	'statusline': v:true,
"\})


" デフォルトで絞り込みウィンドウを開く
" call extend(s:denite_default_options, {
" \	'start_filter': v:true,
" \})


" :DeniteProjectDir する時に README.md や README.rdoc 基準も追加する
call extend(s:denite_default_options, {
\	'root_markers': "README.rdoc,README.md,README",
\})

call denite#custom#option('default', s:denite_default_options)



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" kind の設定

" ファイルを開く際のデフォルトアクションを tabswitch にする
call denite#custom#kind('file', 'default_action', 'tabswitch')



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" file の設定
call denite#custom#source('file', 'matchers', ['matcher/regexp'])
call denite#custom#source('file', 'sorters', ['sorter/word'])
if &rtp =~ "devicons"
	call denite#custom#source('file', 'converters', ['devicons_denite_converter', 'converter/abbr_word'])
else
	call denite#custom#source('file', 'converters', ['converter/abbr_word'])
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" file/rec の設定
call denite#custom#source("file/rec", "max_candidates", 100)
call denite#custom#source('file/rec', 'matchers', ['matcher/regexp'])
call denite#custom#source('file/rec', 'sorters', ['sorter/word'])
if &rtp =~ "devicons"
	call denite#custom#source('file/rec', 'converters', ['devicons_denite_converter', 'converter/abbr_word'])
else
	call denite#custom#source('file/rec', 'converters', ['converter/abbr_word'])
endif


" プロジェクト直下のファイル一覧を表示する + 新規ファイル作成
nnoremap <Space>uff :DeniteProjectDir file/rec<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" quickrun_config の設定

" denite-quickrun_config の並び順を単語順にする
call denite#custom#source('quickrun_config', 'sorters', ['sorter/word'])


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" frill の設定
call denite#custom#source("frill", "max_candidates", 50)
call denite#custom#source('frill', 'matchers', ['matcher/substring'])

if &rtp =~ "devicons"
	call denite#custom#source('frill', 'converters', ['devicons_denite_converter'])
endif
nnoremap <Space>ufm   :Denite frill<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" grep の設定
" ripgrep で grep
if executable("rg")
	call denite#custom#var('file/rec', 'command',
	\ ['rg', '--files', '--glob', '!.git', '--color', 'never'])
	call denite#custom#var('grep', {
	\ 'command': ['rg'],
	\ 'default_opts': ['-i', '--vimgrep', '--no-heading'],
	\ 'recursive_opts': [],
	\ 'pattern_opt': ['--regexp'],
	\ 'separator': ['--'],
	\ 'final_opts': [],
	\ })
endif


call denite#custom#source("grep", "max_candidates", 300)
" ファイル名を含めて絞り込めるようにする converter/abbr_word を追加する
" devicons_denite_converter を使うと絞り込みがおかしくなるので一旦無効にする
" call denite#custom#source('grep', 'converters', ['converter/devicons_denite_converter', 'converter/abbr_word'])
call denite#custom#source('grep', 'converters', ['converter/abbr_word'])
call denite#custom#source('grep', 'matchers', ['matcher/regexp'])
call denite#custom#source('grep', 'sorters', ['sorter/word'])
call denite#custom#option('grep', s:denite_default_options->extend({ "post_action": "jump" }))
nnoremap <Space>gr :DeniteProjectDir grep -buffer-name=grep<CR>
nnoremap <Space>ugr :DeniteProjectDir grep -buffer-name=grep<CR>




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" gitto の設定

command! GitBranch DeniteGitto gitto/branch
call denite#custom#source('gitto/branch', 'sorters', ['sorter/word'])
call denite#custom#source('gitto/branch', 'default_action', 'checkout')

command! GitCommit DeniteGitto gitto/status
call denite#custom#source('gitto/status', 'default_action', 'commit')

nnoremap <Space>gb :GitBranch<CR>
nnoremap <Space>gc :GitCommit<CR>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" unite の設定
" nnoremap <Space>ufm   :Unite frill<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 他の設定の読み込み
source <sfile>:h/denite.private.vim
source <sfile>:h/denite.sandbox.vim



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" qfreplace
function! MyDeniteReplace(context)
	let qflist = []
	for target in a:context['targets']
		if !has_key(target, 'action__path') | continue | endif
		if !has_key(target, 'action__line') | continue | endif
		if !has_key(target, 'action__text') | continue | endif

		call add(qflist, {
					\ 'filename': target['action__path'],
					\ 'lnum': target['action__line'],
					\ 'text': target['action__text']
					\ })
	endfor
	call setqflist(qflist)
	call qfreplace#start('')
endfunction
call denite#custom#action('file', 'qfreplace', function('MyDeniteReplace'))




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 雑多なスクリプト
function! s:grep_root()
	" こっちはカレントディレクトリを基準にする
"	 return getcwd()
	" こっちは .git のディレクトリなんかを基準にする
	return denite#project#path2project_directory(expand("%"), "")

	" README.md なんかも基準とする場合
"	 return denite#project#path2project_directory(expand("%"), "README.rdoc,README.md")
endfunction

" denite grep で第二引数にパスを受け取れるようにする
function! s:grep(...)
	let [args, options] = denite#helper#_parse_options_args(join(a:000))
	let names = map(args, "v:val['name']")
	let pattern = get(names, 0, "")
	let path    = get(names, 1, "")

	if empty(pattern)
		let pattern = input("Pattern: ")
	endif
	let current = s:grep_root()
	call denite#start([{'name': 'grep', 'args': [current . "/" . path, "", pattern] }], extend({ "buffer_name": "grep", "post_action": 'jump' }, options))
endfunction

" dir + :Denite のコマンドオプション補完
function! DeniteGrepComplete(arglead, cmdline, cursorpos) abort
	let dirs = filter(split(glob(a:arglead . "*/"), "\n"), "isdirectory(v:val)")
	return dirs + denite#helper#complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

" e.g.
" :DeniteGrep
" :DeniteGrep pattern
" :DeniteGrep pattern dir
" :DeniteGrep pattern dir -smartcase
" :DeniteGrep pattern -smartcase
" :DeniteGrep pattern -smartcase dir
" :DeniteGrep pattern -no-smartcase dir
command! -nargs=* -complete=customlist,DeniteGrepComplete
\	DeniteGrep call s:grep(<q-args>)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" その他

" .git からの相対パスを取得する
function! s:project_relative_path() abort
	let project_dir = denite#project#path2project_directory(expand("%"), "")
	let full_path = expand("%:p")
	return substitute(full_path, project_dir, "", "")
endfunction
command! CopyProjectRelativePath call setreg(v:register, s:project_relative_path())


" ctrlp っぽい挙動をする
call denite#custom#alias('source', 'ctrlp', 'file/rec')
call denite#custom#source('file/rec', 'sorters', ['sorter/word'])
call denite#custom#source("file/rec", "max_candidates", 100)
command! -nargs=* -complete=customlist,denite#helper#complete
\    DeniteCtrlp Denite file/rec -start-filter -default-action=tabswitch <args>


call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command',
      \ ['git', 'ls-files', '-co', '--exclude-standard'])




finish

function! s:hoge(...) abort
	let [args, options] = denite#helper#_parse_options_args(join(a:000))
	let names = map(args, "v:val['name']")
	let pattern = get(names, 0, "")
	let path    = get(names, 1, "")
	echo pattern
	echo path
	echo options
endfunction

" echo s:hoge("pat", "dir", "-smartcase", "-buffer_name=hoge")
" echo s:hoge("pat", "-smartcase", "dir", "-buffer_name=hoge")

function! DeniteGrepComplete(arglead, cmdline, cursorpos) abort
	let dirs = filter(split(glob(a:arglead . "*/"), "\n"), "isdirectory(v:val)")
	return dirs + denite#helper#complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

command! -nargs=* -complete=customlist,DeniteGrepComplete
\	Hoge call s:hoge(<q-args>)




