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

function! s:scrapbox_open(project_name, title, body)
	let title = g:scrapbox_title_format.call(s:URI.encode(a:title))
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
	let title = a:buffer->split("\n")[0]
	let body = a:buffer->split("\n")[1:]->join("\n")
	call s:scrapbox_open(a:project_name, title, body)
endfunction

command! -range=% ScrapboxOpenBuffer
	\ call s:scrapbox_open_buffer(g:scrapbox_project_name, getline(<line1>, <line2>)->join("\n"))

command! -range=% ScrapboxOpenBufferWithYesNo
	\ call popup_dialog('Open Scrapbox? y/n', #{ filter: 'popup_filter_yesno', callback: { _, yes -> (yes ? [execute("ScrapboxOpenBuffer")] : "") } })


function! s:scrapbox_edit(cmd)
	execute a:cmd
	setlocal filetype=scrapbox
	setlocal buftype=nofile
	if type(g:scrapbox_template) == type({})
		call append(0, g:scrapbox_template.call())
	elseif type(g:scrapbox_template) == type("")
		call append(0, g:scrapbox_template)
	endif
endfunction

command! -complete=command -nargs=1
\	ScrapboxEditOpen
\	call s:scrapbox_edit(<q-args>)
command! ScrapboxEditSplit ScrapboxEditOpen new
command! ScrapboxEditTab ScrapboxEditOpen tabnew


" 以下個人設定
let g:scrapbox_project_name = "osyo"
" let g:scrapbox_title_format = {
" \	"call" : { title -> printf("%s %s", strftime("%Y/%m/%d"), title) }
" \}

" テンプレ
" 2行目以降はどんどん追記されてしまうのであんまり意味がない…
" let g:scrapbox_template =<< trim END
" 	今日のできごと
"
" END
let g:scrapbox_template = {
\	"call" : { -> [printf("%s %s", strftime("%Y/%m/%d"), "今日のできごと"), ""] }
\}


" open 後に自動でバッファを閉じる
let g:scrapbox_close_opened = v:true

" 編集画面をシュッと開く
nnoremap <silent> <Space>ss :ScrapboxEditSplit<CR>


augroup my_scrapbox
	autocmd!
augroup END

command! -bang -nargs=*
\	 MyScrapboxAutocmd
\	 autocmd<bang> my_scrapbox <args>

" filetype=scrapbox の設定
MyScrapboxAutocmd FileType scrapbox call s:scrapbox_my_settings()
function! s:scrapbox_my_settings() abort
	augroup ftplugin-scrapbox
	augroup END

	" <C-s> でポストする
	nnoremap <silent><buffer> <C-s> :<C-u>ScrapboxOpenBufferWithYesNo<CR>
	inoremap <silent><buffer> <C-s> <Esc>:<C-u>ScrapboxOpenBufferWithYesNo<CR>
endfunction

finish

" WIP
let s:HTTP = vital#vital#new().import("Web.HTTP")
function! s:main()
	let response = s:HTTP.get(printf("https://scrapbox.io/api/pages/ima1zumi"))
	let pages = json_decode(response.content)
	let titles = pages["pages"]->map({ _, val -> { "title" : val["title"], "views" : val["views"] } })
	PP titles
endfunction
call s:main()




