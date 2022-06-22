" 静的なエラー箇所の検知を無効化
let g:lsp_diagnostics_enabled = 0
" 参照箇所のハイライトを無効
let g:lsp_document_highlight_enabled = 0


let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')

let g:lsp_settings_filetype_ruby = ['solargraph']
" let g:lsp_settings_filetype_ruby = ['solargraph', 'steep']
" let g:lsp_settings_filetype_ruby = ['steep']

let g:lsp_settings = {
\	"solargraph": {
\		'allowlist': ['ruby', "ruby.rspec"]
\	}
\}


function! s:on_lsp_buffer_enabled() abort
"     setlocal omnifunc=lsp#complete
"     setlocal signcolumn=yes
"     if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
	" 定義位置にジャンプする
	nmap <buffer> gd <plug>(lsp-definition)

	" リファレンスをポップアップウィンドウで表示
	nmap <buffer> <A-k> <plug>(lsp-hover)

" 	nmap <A-s> <plug>(lsp-signature-help)

"     nmap <buffer> gs <plug>(lsp-document-symbol-search)
"     nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
"     nmap <buffer> gr <plug>(lsp-references)
"     nmap <buffer> gi <plug>(lsp-implementation)
"     nmap <buffer> gt <plug>(lsp-type-definition)
"     nmap <buffer> <leader>rn <plug>(lsp-rename)
"     nmap <buffer> [g <plug>(lsp-previous-diagnostic)
"     nmap <buffer> ]g <plug>(lsp-next-diagnostic)

"     inoremap <buffer> <expr><c-f> lsp#scroll(+4)
"     inoremap <buffer> <expr><c-d> lsp#scroll(-4)
endfunction


let s:port = "38587"

function! s:lsp_setup() abort
" 	let g:lsp_settings_filetype_ruby = ['typeprof']
" 	call lsp#register_server({
" 	\	'name': 'typeprof',
" 	\	"tcp": { server_info-> "localhost:" . s:port },
" 	\	'allowlist': ['ruby']
" 	\})
endfunction

augroup lsp_install
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

 	autocmd User lsp_setup call s:lsp_setup()
augroup END


