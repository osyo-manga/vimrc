" defx の起動設定
" https://github.com/ima1zumi/dotfiles/blob/d624b7364dd280a068eaa8944da49f482c5bda8f/.config/nvim/init.vim#L402
" see: https://qiita.com/arks22/items/9688ec7f4cb43444e9d9#%E8%B5%B7%E5%8B%95%E6%99%82%E3%81%AE%E3%83%AC%E3%82%A4%E3%82%A2%E3%82%A6%E3%83%88%E3%82%84%E8%A8%AD%E5%AE%9A
call defx#custom#option('_', {
      \ 'split': 'tab',
      \ 'show_ignored_files': 1,
      \ 'toggle': 1,
      \ 'auto_cd': 1,
      \ 'columns': 'indent:git:icons:filename:mark:type:size:time',
      \ })


" カーソル下のファイルをフルパスでポップアップする奴
function! s:popup_filepath()
	let filepath = get(defx#get_candidate(), "action__path", "file/to/path")
	echo popup_atcursor(filepath, #{ topleft: "botleft", col: virtcol(".") + 10 })
endfunction
command! PopupFilePath call s:popup_filepath()

augroup my-defx
	autocmd!
	autocmd FileType defx call s:defx_my_settings()
augroup END
function! s:defx_my_settings() abort
	augroup ftplugin-my-denite
		autocmd! * <buffer>
" 		autocmd CursorMoved <buffer> PopupFilePath
" 		autocmd CursorMoved <buffer> call defx#call_action("preview", [])
	augroup END
endfunction
