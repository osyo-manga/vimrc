let $NEOBUNDLE_ORIGIN=$VIMUSER."/runtime/neobundle"

let g:neobundle#default_options = {
\	"_" : {
\		"focus" : 0,
\		"verbose" : 1,
\		"lazy" : 0,
\	},
\	"original" : {
\		"base" : $NEOBUNDLE_ORIGIN,
\		"type" : "nosync"
\	}
\}

NeoBundle "altercation/vim-colors-solarized"


command! -nargs=1
\	MyBundle
\	call neobundle#bundle(<args>)


command! -nargs=1
\	NeoBundleNoSync
\	NeoBundle <args>
\	, { "type" : "nosync" }

NeoBundleFetch "Shougo/neobundle.vim", {
\	"base" : $BUNDLE_ROOT,
\}


NeoBundle "Shougo/vimproc.vim", {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }


" NeoBundle "Shougo/neobundle-vim-scripts"
NeoBundleLazy "Shougo/unite.vim", {
\	"focus" : 10,
\	'autoload' : {
\		'commands' : [
\			{
\				"name" : "Unite",
\				"complete" : "customlist,unite#complete_source"
\			},
\		]
\	},
\}


" NeoBundleLazy 'Shougo/vimfiler.vim', {
" \	'depends' : ["Shougo/unite.vim"],
" \	'autoload' : { 'commands' : [ "VimFilerTab", "VimFiler", "VimFilerExplorer" ] }
" \}
" NeoBundleLazy 'Shougo/vimfiler.vim'
" NeoBundle 'Shougo/defx.nvim'

NeoBundleLazy 'Shougo/vimshell.vim', {
\	"focus" : 5,
\	'autoload' : { 'commands' : [ 'VimShell', 'VimShellTab', "VimShellPop", "VimShellInteractive" ] }
\}

NeoBundleLazy "Shougo/vinarise.vim", {
\	'autoload' : { 'commands' : [ 'Vinarise' ] }
\}
NeoBundle "Shougo/deorise.nvim"

NeoBundle "Shougo/denite.nvim"
" NeoBundle "Shougo/deol.nvim"
NeoBundle "Shougo/defx.nvim"
NeoBundle "kristijanhusak/defx-icons"

let s:use_deoplete = 1
if s:use_deoplete
	NeoBundle "Shougo/deoplete.nvim"
	NeoBundle "roxma/nvim-yarp"
	NeoBundle "roxma/vim-hug-neovim-rpc"
" 	NeoBundle "fszymanski/deoplete-emoji"
elseif has("lua")
	NeoBundle "Shougo/neocomplete.vim"
endif


if executable("look")
	NeoBundle 'ujihisa/neco-look'
endif
NeoBundle "Shougo/neosnippet"
NeoBundle "Shougo/neosnippet-snippets"
" finish


" coding
" NeoBundle "autozimu/LanguageClient-neovim", "next"
" NeoBundle "autozimu/LanguageClient-neovim", "next", {
" \ 'build' : {
" \     'unix' : 'bash install.sh',
" \    },
" \ }
NeoBundle "prabirshrestha/async.vim"
NeoBundle "prabirshrestha/vim-lsp"
NeoBundle "mattn/vim-lsp-settings"
NeoBundle "lighttiger2505/deoplete-vim-lsp"
" NeoBundle "Shougo/deoplete-lsp"
" NeoBundle "dradtke/vim-dap"

NeoBundle 'bogado/file-line'

NeoBundle "tyru/empty-prompt.vim"



" operator
NeoBundle "kana/vim-operator-user"
NeoBundle "thinca/vim-operator-sequence"

" cy
NeoBundle "kana/vim-operator-replace"

NeoBundle "rhysd/vim-operator-surround", {
\	"rev" : "input_in_advance"
\}

" textobj
NeoBundle 'kana/vim-textobj-user'

" ae
" NeoBundle "kana/vim-textobj-entire"

" il
NeoBundle "kana/vim-textobj-line"

" if
NeoBundle "kana/vim-textobj-function"

" a,
NeoBundle "sgur/vim-textobj-parameter"

" axb, ixb
NeoBundle "anyakichi/vim-textobj-xbrackets"

" ii
NeoBundleLazy 'kana/vim-textobj-indent', {
\ 'depends': 'kana/vim-textobj-user',
\ 'autoload': {
\ 'mappings': [['xo', 'ai'], ['xo', 'aI'], ['xo', 'ii'], ['xo', 'iI'], "<Plug>(textobj-indent"]
\ }
\ }
omap ii <Plug>(textobj-indent-i)
vmap ii <Plug>(textobj-indent-i)

omap ia <Plug>(textobj-indent-a)
vmap ia <Plug>(textobj-indent-a)


NeoBundle "thinca/vim-textobj-comment"
NeoBundle "mattn/vim-textobj-url"
NeoBundle "deris/vim-textobj-enclosedsyntax"


" Twitter
NeoBundleLazy "basyura/TweetVim", {
\	'depends' : ["basyura/twibill.vim", "basyura/bitly.vim"],
\	'autoload' : { 'commands' : [ 'TweetVimSwitchAccount', "TweetVimSay", "TweetVimHomeTimeline" ] },
\}


" C++
" NeoBundle "vim-jp/cpp-vim"


" Ruby
" NeoBundle "rhysd/vim-textobj-ruby"
" NeoBundle "ruby-formatter/rufo-vim"
NeoBundle "pocke/rbs.vim"
NeoBundle "tpope/vim-rbenv"


" Slim
" NeoBundle "slim-template/vim-slim"


" Haskell
" NeoBundleLazy "eagletmt/unite-haddock", {
" \	"autoload" : { "filetypes" : ["haskell"] }
" \}
"
" NeoBundleLazy "ujihisa/neco-ghc", {
" \	"autoload" : { "filetypes" : ["haskell"] }
" \}

NeoBundle "vim-jp/vimdoc-ja"


" NeoBundle "jelera/vim-javascript-syntax"
NeoBundle "pangloss/vim-javascript"
" NeoBundle "isRuslan/vim-es6"



" Vim script
NeoBundle "thinca/vim-prettyprint"

NeoBundle "kana/vim-gf-user"
" NeoBundle "sgur/vim-gf-autoload"
NeoBundle "hujo/gf-user-vimfn"

" markdown
NeoBundle "kannokanno/previm"


" Riot
" NeoBundle "nicklasos/vim-jsx-riot"

" Pug
NeoBundle "digitaltoad/vim-pug"

" Vue
NeoBundle "posva/vim-vue"

" Kotlin
NeoBundle "udalov/kotlin-vim"


" RAML
" NeoBundle "IN3D/vim-raml"


" HTML5
NeoBundle "othree/html5.vim"


" JSON
NeoBundle "vim-scripts/JSON.vim"


" haml
NeoBundle "tpope/vim-haml"


" コーディング支援
" NeoBundleLazy "thinca/vim-quickrun", {
" \	"focus" : 10,
" \	'autoload' : {
" \		'commands' : [ "QuickRun", "UniteQuickRunConfig" ],
" \	},
" \}
NeoBundle "thinca/vim-quickrun"

NeoBundle "Shougo/unite-outline"
NeoBundle "tyru/caw.vim"
NeoBundle "dannyob/quickfixstatus"

NeoBundleLazy "cohama/vim-hier", {
\	'autoload' : { 'commands' : [ "HierClear", "HierStart", "HierStop", "HierUpdate" ] }
\}
" NeoBundle "jceb/vim-hier"


NeoBundle "h1mesuke/vim-alignta"
NeoBundle "t9md/vim-quickhl"
NeoBundle "tyru/current-func-info.vim"
NeoBundle "uplus/vim-clurin"


" るりま rurima
" NeoBundle "vim-scripts/rd.vim"



" let g:loaded_matchparen = 1
" NeoBundle 'itchyny/vim-parenmatch'


" unite-sources
NeoBundle "ujihisa/unite-colorscheme"


" テキスト支援
NeoBundle "cohama/lexima.vim"
" GhostText: 好きなブラウザでの入力を好きなエディタで行う:https://rcmdnk.com/blog/2021/03/15/computer-vim/
NeoBundle "raghur/vim-ghost"

" Git
" NeoBundle "kmnk/vim-unite-giti"
" NeoBundle "sgur/vim-gitgutter
NeoBundle 'hrsh7th/vim-versions'
NeoBundle "airblade/vim-gitgutter"
NeoBundle "kmnk/vim-unite-giti"
" NeoBundle "lambdalisue/gina.vim"
NeoBundle "tpope/vim-fugitive"
NeoBundle "hrsh7th/vim-gitto"
" NeoBundle "hrsh7th/vim-denite-gitto"


" colorscheme
" NeoBundle "shawncplus/skittles_berry"
" NeoBundle "vim-scripts/oh-l-l"
" NeoBundle "nanotech/jellybeans.vim"
" NeoBundle "w0ng/vim-hybrid"
" NeoBundle "jpo/vim-railscasts-theme"
" NeoBundle "tomasr/molokai"
NeoBundle "croaky/vim-colors-github"
NeoBundle "jpo/vim-railscasts-theme"
NeoBundle "chriskempson/vim-tomorrow-theme"
NeoBundle "jonathanfilip/vim-lucius"
NeoBundle "sjl/badwolf"
NeoBundle "whatyouhide/vim-gotham"
NeoBundle "junegunn/seoul256.vim"
NeoBundle "cocopon/iceberg.vim"



" その他雑多
NeoBundleLazy "thinca/vim-fontzoom", {
\	'autoload' : {
\		'commands' : [ "Fontzoom" ],
\		'mappings'  : [ "<Plug>(fontzoom-larger)", "<Plug>(fontzoom-smaller)" ]
\	}
\}

NeoBundleLazy "thinca/vim-ref", {
\	'autoload' : {
\		'commands' : [ "Ref" ],
\		'mappings'  : [ "<Plug>(ref-keyword)" ]
\	}
\}


NeoBundleLazy "vim-scripts/copypath.vim", {
\	'autoload' : { 'commands' : [ "CopyPath" ] }
\}

NeoBundleLazy "tyru/restart.vim", {
\	'autoload' : { 'commands' : [ "Restart" ] }
\}


NeoBundle "tyru/open-browser.vim"
NeoBundle "tyru/open-browser-github.vim"

NeoBundleLazy "tyru/capture.vim", {
\	'autoload' : {
\		'commands' : [
\			{
\				"name" : "Capture",
\				"complete" : "command",
\			}
\		]
\	}
\}

NeoBundleLazy "thinca/vim-scall", {
\	"focus" : 10,
\	'autoload' : {'functions' : ["Scall"] },
\}

NeoBundle "Lokaltog/vim-easymotion"
NeoBundle "t9md/vim-textmanip"
NeoBundle "haya14busa/incsearch.vim"
NeoBundle "haya14busa/incsearch-migemo.vim"
NeoBundle 'haya14busa/vim-asterisk'
NeoBundle 'thinca/vim-localrc'
NeoBundle "deris/vim-diffbuf"

" NeoBundle "syngan/vim-vimlint"
" NeoBundle "ynkdir/vim-vimlparser"

" NeoBundle "bling/vim-airline"
" NeoBundle "vim-airline/vim-airline-themes"

NeoBundle "tyru/vim-altercmd"
NeoBundle "t9md/vim-choosewin"
NeoBundle "thinca/vim-qfreplace"

NeoBundle "sgur/vim-editorconfig"

" QSL formatter
NeoBundle 'vim-scripts/Align'
" 余計なキーマッピングがされているので無効化
nmap none <Plug>RestoreWinPosn
NeoBundle 'vim-scripts/SQLUtilities'


NeoBundle "mbbill/undotree", {
\	'autoload' : {'commands' : ["UndotreeShow"] },
\}

NeoBundle "Yggdroot/indentLine"
NeoBundle "vim-scripts/sudo.vim"
NeoBundle "vim-scripts/AnsiEsc.vim"
NeoBundle "simeji/winresizer"


" アイコン表示いろいろ
" https://qiita.com/park-jh/items/4358d2d33a78ec0a2b5c
NeoBundle "ryanoasis/vim-devicons"


" ライブラリ
NeoBundle "mattn/webapi-vim"
NeoBundle "vim-jp/vital.vim"
" NeoBundle "haya14busa/revital.vim"
NeoBundle 'lambdalisue/vital-ArgumentParser'


" 自作プラグインとか
" NeoBundleLocal $VIMUSER/runtime/neobundle
function! s:neobundle_origin(name, ...)
	let base_option = {
\		"base" : $NEOBUNDLE_ORIGIN,
\		"type" : "nosync",
\	}
	let option = extend(base_option, get(a:, 1, {}))
	execute "NeoBundle" string(a:name) "," string(option)
endfunction
command! -nargs=*
\	NeoBundleOrigin
\	call s:neobundle_origin(<args>)


" command! -nargs=1
" \	NeoBundleOrigin
" \	NeoBundle <args>, {
" \		"base" : $NEOBUNDLE_ORIGIN,
" \		"type" : "nosync",
" \	}

NeoBundleOrigin "after"
NeoBundleOrigin "mswin"

" NeoBundleOrigin "vim-clang_declared"
" NeoBundle "vim-reti", "", "original"
" NeoBundleOrigin "vim-reti"
NeoBundleOrigin "vim-chained"

" NeoBundleOrigin "unite-env"
" NeoBundleOrigin "unite-file_mru2"
" NeoBundleLazy "unite-file_mru2", {
" \		"base" : $NEOBUNDLE_ORIGIN,
" \		"type" : "nosync"
" \}

" NeoBundleOrigin "unite-fold"
NeoBundleOrigin "unite-quickfix"
NeoBundleOrigin "unite-quickrun_config"
NeoBundleOrigin "denite-quickrun_config"
" NeoBundleOrigin "unite-boost-online-doc"
" NeoBundleOrigin "TweetVim-powerline-theme"

" NeoBundleOrigin "neocomplcache-snippets-complete-dart"
" NeoBundleOrigin "neocomplcache-snippets-complete-jsx"

NeoBundleOrigin "ref-lynx"

" NeoBundleOrigin "my-powerline"
" NeoBundleOrigin "vim-powerline-unite-theme"
" NeoBundleOrigin "vim-powerline"
" NeoBundleOrigin "unite-vimkaruta"

NeoBundleOrigin "shabadou.vim"
NeoBundleOrigin "vim-watchdogs"
" NeoBundleOrigin "vim-reanimate"
" NeoBundleOrigin "rsense"
NeoBundleOrigin "vim-budou"
NeoBundleOrigin "vim-owl"
NeoBundleOrigin "unite-qfixhowm"
NeoBundleOrigin "quickrun-hook-u-nya-"
NeoBundleOrigin "quickrun-hook-vcvarsall"
NeoBundleOrigin "quickrun-outputter-replace_region"
" NeoBundleOrigin "quickrun-hook-santi_pinch"
" NeoBundleOrigin "vim-hideout"


let g:textobj_multiblock_no_default_key_mappings = 0
NeoBundleOrigin "vim-textobj-multiblock"
NeoBundleOrigin "vim-textobj-multitextobj"


let g:textobj_context_no_default_key_mappings = 0
NeoBundleOrigin "vim-textobj-context"
NeoBundleOrigin "vim-bufixlist"
NeoBundleOrigin "vim-anzu"
" NeoBundleOrigin "vim-ghost"
" NeoBundleOrigin "vim-reunions"
NeoBundleOrigin "vim-milfeulle"
NeoBundleOrigin "vim-gyazo"
NeoBundleOrigin "vim-gift"
" NeoBundleOrigin "unite-airline_themes"
NeoBundleOrigin "unite-highlight"
NeoBundleOrigin "vim-frill"
NeoBundleOrigin "vim-garden"
" NeoBundleOrigin "vim-pronamachang"
" NeoBundleOrigin "vim-sound"
NeoBundleOrigin "unite-filters-collection"
" NeoBundleOrigin "vim-marching"
" NeoBundleOrigin "vim-operator-search"
" NeoBundleOrigin "vim-operator-jump-side"
NeoBundleOrigin "vim-operator-swap"
NeoBundleOrigin "vim-operator-alignta"
NeoBundleOrigin "vim-operator-block"
" NeoBundleOrigin "vim-operator-highlight"
NeoBundleOrigin "vim-operator-highlighter"
NeoBundleOrigin "vim-operator-stay-cursor"
" NeoBundleOrigin "vim-fancy"
NeoBundleOrigin "vim-over",{
\	"lazy" : 1,
\	'autoload' : {
\		"commands" : ["OverCommandLine"],
\	}
\}
" NeoBundleOrigin "vim-stargate"
NeoBundleOrigin "vim-snowdrop"
" NeoBundleOrigin "unite-itchyny-calendar"
" NeoBundleOrigin "neobundle-auto_lazy_source"
NeoBundleOrigin "vim-operator-surround-before"
NeoBundleOrigin "vim-textobj-blockwise"
NeoBundleOrigin "vim-operator-blockwise"
NeoBundleOrigin "vim-textobj-from_regexp"
NeoBundleOrigin "vim-operator-exec_command"
NeoBundleOrigin "vim-brightest"
" NeoBundleOrigin "vim-retime"
NeoBundleOrigin "unite-candidate_sorter"
NeoBundleOrigin "unite-github"
" NeoBundleOrigin "unite-vimmer"
NeoBundleOrigin "unite-vital-module"
NeoBundleOrigin "unite-web_feed"
" NeoBundleOrigin "vim-monster"
NeoBundleOrigin "vim-nyaaancat"
NeoBundleOrigin "vim-hopping"
NeoBundleOrigin "vim-vigemo"
NeoBundleOrigin "vim-trip"
NeoBundleOrigin "vim-operator-aggressive"
" NeoBundleOrigin "vim-edit_filetype"
" NeoBundleOrigin "vim-stripe"
NeoBundleOrigin "vim-agrep"
" NeoBundleOrigin "unite-option"
" NeoBundleOrigin "unite-oldfiles"
NeoBundleOrigin "vim-swindle"

" NeoBundle "vim-euphoric_player", "", "original", {
" \	"lazy" : 1,
" \	'autoload' : {
" \		"unite_sources" : ["euphoric_player_playlist", "euphoric_player_tracks"],
" \	}
" \}


NeoBundleOrigin "vim-sugarpot", {
\	"lazy" : 1,
\	'autoload' : {
\		'commands' : [
\			{
\				"name" : "SugarpotPreview",
\				"complete" : "file",
\			}
\		]
\	}
\}

" NeoBundleOrigin "vim-sudden_valentine"
" NeoBundleOrigin "osyo-manga/capture.vim"


let g:textobj_precious_no_default_key_mappings = 0
NeoBundleOrigin "vim-precious"
" NeoBundleOrigin "context_filetype.vim"
NeoBundle "Shougo/context_filetype.vim"
NeoBundleOrigin "vim-jplus"
" NeoBundleOrigin "vim-automatic"
NeoBundleOrigin "unite-choosewin-actions"
" NeoBundleOrigin "vim-bug20131231"
" NeoBundleOrigin "vim-airline-inu"
" NeoBundleOrigin "vim-airline-nuko"
" NeoBundleOrigin "vim-airline-usamin"
" NeoBundleOrigin "vim-usamin"

" Forked plugins.
" NeoBundleOrigin "unite.vim"
" NeoBundleOrigin "Omnisharp"
" NeoBundleOrigin "J6uil.vim"
" NeoBundleOrigin "neocomplete.vim"
" NeoBundleOrigin "vim-quickrun"
" NeoBundleOrigin "vimshell.vim"
" NeoBundleOrigin "vim-airline"
" NeoBundleOrigin "unite-vim_hacks"
NeoBundleOrigin "codic-vim"



NeoBundleOrigin "test"
NeoBundleOrigin "test2"
NeoBundleOrigin "unite-vimpatches"
" NeoBundleOrigin "unite-toggle-options"
NeoBundleOrigin "vim-auto_alignta"
" NeoBundleOrigin "vim-itunes-bgm"
" NeoBundleOrigin "vim-scaffold"
" NeoBundleOrigin "vim-scaffold-templates"
NeoBundleOrigin "vim-cpp-syntax-reserved_identifiers"
NeoBundleOrigin "vim-poster"
NeoBundleOrigin "vim-hoogle-web"
NeoBundleOrigin "vim-gimei"


NeoBundleOrigin "vital-over"
NeoBundleOrigin "vital-garden"
NeoBundleOrigin "vital-secret"
NeoBundleOrigin "vital-coaster"
NeoBundleOrigin "vital-unlocker"
NeoBundleOrigin "vital-reti"
NeoBundleOrigin "vital-reunions"
NeoBundleOrigin "vital-gift"
NeoBundleOrigin "vital-palette"
NeoBundleOrigin "vital-paradise"
NeoBundleOrigin "vital-branc"

NeoBundleOrigin "vital-migemo"

if executable("cmigemp")
endif



NeoBundleOrigin "wandbox-vim"


NeoBundle "fuenor/qfixhowm"


if !has('vim_starting')
	NeoBundleDocs
endif



