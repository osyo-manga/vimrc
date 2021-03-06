" コード
"  - https://gist.github.com/osyo-manga/2ca4665d630d596a7fbf4b5fa99d0809
"
" 必須プラグイン
"  - https://github.com/vim-jp/vital.vim
"
"
" 概要
"   :ScrapboxOpenBuffer で現在のバッファを scrapbox で開く
"   1行目がタイトルでそれ以降が本文になる
"
"
" 設定
"   g:scrapbox_project_name にプロジェクト名を設定する
"
"   g:scrapbox_title_format
"     "call" : タイトルを生成するコールバック
"
"   g:scrapbox_template
"     :ScrapboxEditOpen 等で編集バッファを開いた時に自動挿入される文字列のリスト
"
"
" コマンド
"   :ScrapboxEditOpen
"     ウィンドウ分割して編集バッファを開く
"
"   :ScrapboxEditTab
"     新しいタブで編集バッファを開く
"

let g:scrapbox_project_name = "xxx"
let g:scrapbox_title_format = {
\	"call" : { title -> title }
\}
let g:scrapbox_template =<< trim END
	ここに書く
END
" v:true を設定すると open 後にバッファを閉じる
let g:scrapbox_close_opened = v:false

let s:File = vital#vital#new().import("System.File")
let s:URI = vital#vital#new().import("Web.URI")

function! s:scrapbox_open(project_name, title, body) abort
	let title_format = get(g:scrapbox_title_format, a:project_name, g:scrapbox_title_format)
	let title = title_format.call(s:URI.encode(a:title))
	let body = s:URI.encode(trim(a:body, "\n"))
	let url = printf('https://scrapbox.io/%s/%s?body=%s', a:project_name, title, body)
	call s:File.open(url)
	if g:scrapbox_close_opened
		if mode() == "i"
			call feedkeys("\<Esc>\<C-w>c", "n")
		else
			call feedkeys("\<C-w>c", "n")
		endif
	endif
endfunction


function! s:scrapbox_open_buffer(project_name, buffer)
	let title = split(a:buffer, "\n")[0]
	let body = join(split(a:buffer, "\n")[1:], "\n")
	call s:scrapbox_open(a:project_name, title, body)
endfunction

command! -range=% ScrapboxOpenBuffer
	\ call s:scrapbox_open_buffer(get(b:, "scrapbox_project_name", g:scrapbox_project_name), join(getline(<line1>, <line2>), "\n"))

command! -range=% ScrapboxOpenBufferWithYesNo
	\ call popup_dialog('Open Scrapbox? y/n', #{ filter: 'popup_filter_yesno', callback: { _, yes -> (yes ? [execute("ScrapboxOpenBuffer")] : "") } })


function! s:scrapbox_edit(...) abort
	let cmd = get(a:000, 0)
	let project_name = get(a:000, 1, g:scrapbox_project_name)
	let template = g:scrapbox_template->get(project_name, g:scrapbox_template)

	execute cmd
	setlocal filetype=scrapbox
	setlocal buftype=nowrite
	let b:scrapbox_project_name = project_name
	if type(template) == type({})
		call append(0, template.call())
	elseif type(template) == type("")
		call append(0, template)
	endif
endfunction

command! -complete=command -nargs=+
\	ScrapboxEditOpen
\	call s:scrapbox_edit(<f-args>)
command! ScrapboxEditSplit ScrapboxEditOpen new
command! ScrapboxEditTab ScrapboxEditOpen tabnew


source <sfile>:h/scrapbox.private.vim
