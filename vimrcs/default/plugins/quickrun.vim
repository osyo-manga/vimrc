scriptencoding utf-8


let s:V = vital#of("vital")
let g:Prelude = s:V.import("Prelude")
let s:Buffer = s:V.import("Coaster.Buffer")


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 雑多な設定
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" <C-c> で quickrun の実行を中断する
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"


" "{filetype}/_" の設定をベースとして実行時に config に追加する
function s:quickrun_execute(argline, use_range, line1, line2) abort
  try
    let config = quickrun#command#parse(a:argline)
    if a:use_range
      let config.region = {
      \   'first': [a:line1, 0, 0],
      \   'last':  [a:line2, 0, 0],
      \   'wise': 'V',
      \ }
    endif
    call quickrun#run(extend(config, get(g:quickrun_config, &filetype."/_", {}), "keep"))
  catch /^quickrun:/
    call s:V.Vim.Message.error(v:exception)
  endtry
endfunction

command! -nargs=* -range=0 -complete=customlist,quickrun#command#complete
\ QuickRun call s:quickrun_execute(<q-args>, <count>, <line1>, <line2>)


" コンテキスト内で quickrun する
function! s:context_quickrun(args, count)
	let context = context_filetype#get(precious#base_filetype())
	let type = string(get(get(b:, "quickrun_config", {}), "type", context.filetype))
	execute context.range[0][0].",".context.range[1][0]
\		"QuickRun -type " type a:args
endfunction

command! -nargs=* -range=0 -complete=customlist,quickrun#complete
\	ContextQuickRun :call s:context_quickrun(<q-args>, <count>)


augroup my-quickrun
	autocmd!
	autocmd BufEnter,FocusGained,WinEnter schema.rb let b:watchdogs_checker_type = "ruby/syntax_check"
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" hooks
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" is_started {{{
let g:is_quickrun_started = 0

let s:hook = {
\	"name" : "is_started",
\	"kind" : "hook",
\}

function! s:hook.init(...)
	let g:is_quickrun_started = 1
endfunction

function! s:hook.sweep(...)
	let g:is_quickrun_started = 0
endfunction

call quickrun#module#register(s:hook, 1)
unlet s:hook
" }}}



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" quickrun_config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" g:quickrun_config の初期化
if exists("quickrun_running") || !exists("g:quickrun_config")
	let g:quickrun_config = {}
endif
	let g:quickrun_config = {}


" デフォルト {{{
let s:config = {
\	"_" : {
\		"outputter/buffer/opener" : ":botright 8sp",
\		"outputter" : "multi:buffer:quickfix:bufixlist",
\		"outputter/buffer/running_mark" : "ﾊﾞﾝ（∩`･ω･）ﾊﾞﾝﾊﾞﾝﾊﾞﾝﾊﾞﾝﾞﾝ",
\		"outputter/quickfix/open_cmd" : "",
\		"outputter/bufixlist/open_cmd" : "",
\		"runner" : "job",
\		"hook/sweep/enable" : 0,
\		"hook/extend_config/enable" : 1,
\		"hook/extend_config/force" : 1,
\		"hook/close_buffer/enable_failure" : 0,
\		"hook/close_buffer/enable_empty_data" : 1,
\		"hook/close_buffer/enable_exit" : 0,
\		"hook/echo/enable" : 1,
\		"hook/echo/enable_output_exit" : 1,
\		"hook/echo/priority_exit" : 10000,
\		"hook/echo/output_success" : "（＾ω＾U 三 U＾ω＾）",
\		"hook/echo/output_failure" : "(∪´;ﾟ;ω;ﾟ)･;'.､･;'.･;';ﾌﾞﾌｫ",
\		"hook/clear_quickfix/enable_hook_loaded" : 1,
\		"hook/clear_bufixlist/enable_hook_loaded" : 1,
\		"hook/clear_location_list/enable_hook_loaded" : 1,
\		"hook/hier_update/enable_exit" : 1,
\		"hook/quickfix_status_enable/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/priority_exit" : -10,
\	},
\	"wandbox" : {
\		"runner/wandbox/enable_output_every_polling" : 1,
\		"runner" : "wandbox",
\	},
\	"wandbox_post" : {
\		"command" : "wandbox",
\		"exec": "%c run %o %s:p",
\		"cmdopt": "--save --lang=%{&filetype}",
\	}
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


"--------------------------------------------------------------------
" watchdogs
"--------------------------------------------------------------------

" {{{
let s:config = {
\	"watchdogs_checker/_" : {
\		"runner" : "job",
\		"hook/extend_config/enable" : 0,
\		"outputter" : "bufixlist",
\		"outputter/bufixlist/open_cmd" : "",
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable" : 0,
\		"hook/close_quickfix/enable_exit" : 1,
\		"hook/redraw_unite_quickfix/enable_exit" : 0,
\		"hook/close_unite_quickfix/enable_exit" : 1,
\		"hook/location_list_replace_tempname_to_bufnr/enable_exit" : 1,
\		"hook/location_list_replace_tempname_to_bufnr/priority_exit" : -10,
\		"hook/back_buffer/enable" : 0,
\		"hook/back_tabpage/enable" : 0,
\		"hook/back_window/enable" : 0,
\		"hook/gift_back_start_window/enable" : 0,
\		"hook/clear_quickfix/enable_hook_loaded" : 0,
\		"hook/echo/enable" : 0,
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


"--------------------------------------------------------------------
" ruby
"--------------------------------------------------------------------

let s:ruby_versions = [
\	"2.0.0-p648",
\	"2.5.9",
\	"2.6.6",
\	"2.7.1",
\	"2.7.2",
\	"2.7.3",
\	"3.0.0",
\	"3.0.1",
\	"3.1.0-dev",
\]

" {{{
let s:config = {
\	"ruby/all" : {
\		"command" : "docker",
\		"cmdopt" : "run --rm rubylang/all-ruby ./all-ruby ",
\		"exec" : '%c %o -e %{shellescape(getline(1, "$")->join(";"))}',
\	},
\	"ruby/jruby-1.7.27" : {
\		"command" : "jruby-1.7.27",
\		"exec" : "%c %o %s:p",
\	},
\	"ruby/mruby-dev" : {
\		"command" : "mruby",
\		"exec" : "RBENV_VERSION=mruby-dev %c %o %s:p",
\	},
\	"ruby/rake test without warning" : {
\		"command" : "rake",
\		"exec" : "bundle exec %c test %s:p",
\	},
\	"ruby/rake TEST without warning" : {
\		"command" : "rake",
\		"exec" : "bundle exec %c TEST=%s:p",
\	},
\	"ruby/ruby-test" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : "/Users/worker/build/ruby/ruby",
\	},
\	"ruby/ruby-test2" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" :  expand("~/build/ruby/build"),
\	},
\	"ruby/ruby-test3" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : expand("~/build/ruby/build"),
\	},
\	"ruby/make-run" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 run %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/make-runruby" : {
\		"exec" : "%c DEFS=-DVM_CHECK_MODE=2 runruby %s:p",
\		"command" : "make",
\		"hook/cd/directory" : "../build",
\	},
\	"ruby/bundle" : {
\		"exec" : "%c exec ruby %o %s:p",
\		"command" : "bundle",
\	},
\	"ruby/rails runner" : {
\		"exec" : "%c runner %s:p",
\		"command" : "rails",
\		"hook/cd/directory" : '%{vital#of("vital").import("Prelude").path2project_directory(expand("%:p"))}'
\	},
\	"ruby/foreman" : {
\		"exec"    : "%c %o",
\		"command" : "foreman",
\		"cmdopt" : "start",
\	},
\	"ruby/goreman" : {
\		"exec"    : "%c %o",
\		"command" : "goreman",
\		"cmdopt" : "start",
\	},
\	"watchdogs_checker/rubocop" : {
\		"command" : "bundle",
\		"exec"    : "%c exec rubocop %o %s:p",
\		"errorformat" : '%f:%l:%c:%m,%f:%l:%m,%-G%.%#',
\	},
\}
call extend(g:quickrun_config, s:config)


function! s:ruby_config(version)
	return {
\		"ruby/" . a:version : {
\			"command" : "ruby",
\			"exec" : "RBENV_VERSION=" . a:version . " %c %o %s:p",
\		},
\		"ruby/bundle exec ". a:version : {
\			"exec" : "RBENV_VERSION=" . a:version . " %c exec ruby %o %s:p",
\			"command" : "bundle",
\		},
\	}
endfunction
let s:config = deepcopy(s:ruby_versions)->map({ -> s:ruby_config(v:val) })->reduce({ sum, val -> extend(sum, val) })

call extend(g:quickrun_config, s:config)


let s:rails_version = [
\	"rails-5.2",
\	"rails-6.0",
\	"rails-6.1",
\	"main"
\]

function! s:ruby_appraisal_config(version)
	return {
\		"ruby/bundle exec with " . a:version : {
\			"exec" : "%c exec appraisal " . a:version . " ruby %o %s:p",
\			"cmdopt" : "-Ku ",
\			"command" : "bundle",
\			"hook/cd/directory" : "%{g:Prelude.path2project_directory('%')}",
\		},
\	}
endfunction
let s:config = deepcopy(s:rails_version)->map({ -> s:ruby_appraisal_config(v:val) })->reduce({ sum, val -> extend(sum, val) })
call extend(g:quickrun_config, s:config)


unlet s:config
" }}}


"--------------------------------------------------------------------
" ruby.rspec
"--------------------------------------------------------------------

" ruby.rspec {{{
let s:config = {
\	"ruby.rspec/_" : {
\		"cmdopt"  : "-c -fd --tty",
\		"errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\	},
\	"ruby.rspec/bundle" : {
\		"command" : "rake",
\		"exec"    : "bundle exec %c spec %s:p",
\	},
\	"ruby.rspec/bundle_single" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=\"%s:p\" SPEC_OPTS=\"%o\" bundle exec %c spec'",
\	},
\	"ruby.rspec/bundle_single_on_cursor" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=\"%s:p\\:%{line('.')}\" SPEC_OPTS=\"%o\" bundle exec %c spec'",
\	},
\	"ruby.rspec/bundle_rspec_single_on_cursor" : {
\		"command" : "rspec",
\		"exec"    : "bundle exec %c %s:p\\:%{line('.')} %o",
\	},
\	"ruby.rspec/bundle_single_on_cursor all backtrace" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} SPEC_OPTS=\"-b %o\" bundle exec %c spec'",
\	},
\	"ruby.rspec/bundle_single_on_cursor_with_foreground" : {
\		"command" : "rake",
\		"exec"    : "bash -c 'SPEC=%s:p\\:%{line('.')} SPEC_OPTS=\"--tag \\@foreground %o\" bundle exec %c spec'",
\	},
\	"ruby.rspec/ruby-test" : {
\		"exec" : "%c test-all TESTS=%s:p",
\		"command" : "make",
\		"hook/cd" : 1,
\		"hook/cd/directory" : "/Users/mayu/build/ruby/build",
\	},
\	"ruby.rspec/syntax_check" : {
\		"command" : "ruby",
\		"exec"    : "%c %s:p %o",
\		"cmdopt"  : "-c",
\		"outputter" : "quickfix",
\		"vimproc/sleep"    : 0,
\		"hook/unite_quickfix/enable" : 0,
\		"hook/close_unite_quickfix/enable" : 0,
\		"hook/close_buffer/enable_exit" : 1,
\		"hook/u_nya_/enable" : 0,
\	},
\}
call extend(g:quickrun_config, s:config)

function! s:ruby_rspec_config(version)
	return {
\		"ruby.rspec/single_on_cursor " . a:version : {
\			"command" : "rspec",
\			"exec"    : "RBENV_VERSION=" . a:version . " %c %s:p\\:%{line('.')} %o",
\		},
\		"ruby.rspec/bundle_single_on_cursor " . a:version : {
\			"command" : "rake",
\			"exec"    : "RBENV_VERSION=" . a:version . " bash -c 'SPEC=%s:p\\:%{line('.')} SPEC_OPTS=\"%o\" RUBYOPT=\"-W:deprecated\" bundle exec %c spec'",
\		},
\	}
endfunction
let s:config = deepcopy(s:ruby_versions)->map({ -> s:ruby_rspec_config(v:val) })->reduce({ sum, val -> extend(sum, val) })
call extend(g:quickrun_config, s:config)


let s:rails_version = [
\	"rails-5.2",
\	"rails-6.0",
\	"rails-6.1",
\	"main"
\]

function! s:ruby_rspec_appraisal_config(version)
	return {
\		"ruby.rspec/bundle_single_on_cursor with " . a:version : {
\			"command" : "rake",
\			"exec"    : "bash -c 'SPEC=\"%s:p\\:%{line('.')}\" SPEC_OPTS=\"%o\" RUBYOPT=\"-W:deprecated\" bundle exec appraisal " . a:version . " %c spec'",
\			"hook/cd/directory" : "%{g:Prelude.path2project_directory('%')}",
\		},
\	}
endfunction
let s:config = deepcopy(s:rails_version)->map({ -> s:ruby_rspec_appraisal_config(v:val) })->reduce({ sum, val -> extend(sum, val) })
call extend(g:quickrun_config, s:config)


unlet s:config
" }}}


"--------------------------------------------------------------------
" HTML
"--------------------------------------------------------------------

" {{{
let s:config = {
\	'html' : {
\		"type" : "run/browser/cat"
\	},
\	'html/haml' : {
\		"command" : "html2haml"
\	},
\	'html/haml_repace' : {
\		"outputter" : "error",
\		"outputter/success" : "replace_region",
\		"outputter/error"   : "message",
\		"outputter/message/log"   : 1,
\		"hook/unite_quickfix/enable" : 0,
\		"runner" : "system",
\		"type" : "html/haml"
\	},
\	'html/pug' : {
\		"command" : "html2pug",
\		"exec" : "%c --fragment < %s:p"
\	},
\	'html/pug_repace' : {
\		"outputter" : "error",
\		"outputter/success" : "replace_region",
\		"outputter/error"   : "message",
\		"outputter/message/log"   : 1,
\		"hook/unite_quickfix/enable" : 0,
\		"runner" : "system",
\		"type" : "html/pug"
\	},
\	'html/pasha_slicer' : {
\		"command" : "ruby",
\		"exec" : "%c /home/worker/Dropbox/work/worker/momonga/script/momonga/pasha_slicer.rb %s:p"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}



"--------------------------------------------------------------------
" haml
"--------------------------------------------------------------------

" {{{
let s:config = {
\	'haml' : {
\		"type" : "haml/buffer"
\	},
\	'haml/buffer' : {
\		"command" : "haml",
\		"outputter" : "buffer"
\	},
\	'haml/browser' : {
\		"command" : "haml",
\		"outputter" : "browser"
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}


"--------------------------------------------------------------------
" TypeScript
"--------------------------------------------------------------------

" {{{
let s:config = {
\	'typescript' : {
\		"type" : "typescript/tsc"
\	},
\	'typescript/tsc': {
\		'command': 'tsc',
\		'exec': ['%c --target es2020 --module commonjs %o %s', 'node %s:r.js'],
\		'tempfile': '%{tempname()}.ts',
\		'hook/sweep/files': ['%S:p:r.js'],
\	},
\	'typescript/compile' : {
\		'command': 'tsc',
\		'exec': ['%c --target es2020 --module commonjs %o %s', 'cat %s:r.js'],
\		'tempfile': '%{tempname()}.ts',
\		'hook/sweep/files': ['%S:p:r.js'],
\	},
\}

call extend(g:quickrun_config, s:config)
unlet s:config
" }}}
