" コード
"  - https://gist.github.com/osyo-manga/2ca4665d630d596a7fbf4b5fa99d0809
"
" 必須プラグイン
"  - https://github.com/vim-jp/vital.vim
"
" 概要
"   :ScrapboxOpenBuffer で現在のバッファを scrapbox で開く
"   1行目がタイトルでそれ以降が本文になる
"
" 設定
"   `g:scrapbox_project_name` にプロジェクト名を設定する
"   `g:scrapbox_title_format`
"     "call" : タイトルを生成するコールバック

let g:scrapbox_project_name = "osyo"
let g:scrapbox_title_format = {
\	"call" : { title -> printf("%s %s", strftime("%Y/%m/%d"), title) }
\}

let s:File = vital#vital#new().import("System.File")
let s:URI = vital#vital#new().import("Web.URI")

function! s:scrapbox_open(project_name, title, body)
	let title = g:scrapbox_title_format.call(s:URI.encode(a:title))
	let body = s:URI.encode(a:body)
	let url = printf('https://scrapbox.io/%s/%s?body=%s', a:project_name, title, body)
	echo url
	call s:File.open(url)
endfunction


function! s:scrapbox_open_buffer(project_name, buffer)
	let title = a:buffer->split("\n")[0]
	let body = a:buffer->split("\n")[1:]->join("\n")
	call s:scrapbox_open(a:project_name, title, body)
endfunction

command! -range=% ScrapboxOpenBuffer
	\ call s:scrapbox_open_buffer(g:scrapbox_project_name, getline(<line1>, <line2>)->join("\n"))



finish

" 以下 WIP
augroup my_scrapbox
	autocmd!
augroup END

command! -bang -nargs=*
\	 MyScrapboxAutocmd
\	 autocmd<bang> my_scrapbox <args>

MyScrapboxAutocmd FileType scrapbox call s:scrapbox_my_settings()
function! s:scrapbox_my_settings() abort
	augroup ftplugin-scrapbox
		autocmd! * <buffer>
" 		autocmd BufWriteCmd <buffer> setlocal nomodified
		autocmd BufWriteCmd <buffer> call popup_dialog('Open Scrapbox? y/n', #{ filter: 'popup_filter_yesno', callback: { _, yes -> (yes ? s:scrapbox_open_buffer(g:scrapbox_project_name, getline(1, "$")->join("\n")) : "") } })
	augroup END
endfunction


