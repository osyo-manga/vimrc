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
NeoBundle 'Shougo/vimfiler.vim'

NeoBundleLazy 'Shougo/vimshell.vim', {
\	"focus" : 5,
\	'autoload' : { 'commands' : [ 'VimShell', 'VimShellTab', "VimShellPop", "VimShellInteractive" ] }
\}

NeoBundleLazy "Shougo/vinarise.vim", {
\	'autoload' : { 'commands' : [ 'Vinarise' ] }
\}
NeoBundle "Shougo/deorise.nvim"

if has("python3")
	" NeoBundle "Shougo/deol.nvim"
	NeoBundle "Shougo/denite.nvim"
	NeoBundle "Shougo/defx.nvim"
	NeoBundle "kristijanhusak/defx-icons"
end

let s:use_deoplete = 1
if s:use_deoplete && has("python3")
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
NeoBundle "prabirshrestha/async.vim"
NeoBundle "prabirshrestha/vim-lsp"
NeoBundle "mattn/vim-lsp-settings"
NeoBundle "lighttiger2505/deoplete-vim-lsp"

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
" NeoBundle "voldikss/vim-floaterm"


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


" HTML5
NeoBundle "othree/html5.vim"


" JSON
NeoBundle "vim-scripts/JSON.vim"


" haml
NeoBundle "tpope/vim-haml"

" TypeScript
" NeoBundle "HerringtonDarkholme/yats.vim"
NeoBundle "leafgarland/typescript-vim"
" NeoBundle "sheerun/vim-polyglot"


" コーディング支援
NeoBundle "thinca/vim-quickrun"
" 自動でライブラリをリンクする奴
" https://mattn.kaoriya.net/software/vim/20120525181657.htm
" NeoBundle "mattn/vim-quickrunex"

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
NeoBundle "andymass/vim-matchup"


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
NeoBundle "hrsh7th/vim-denite-gitto"


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
" NeoBundle "haya14busa/incsearch.vim"
" NeoBundle "haya14busa/incsearch-migemo.vim"
NeoBundle 'haya14busa/vim-asterisk'
NeoBundle 'thinca/vim-localrc'
NeoBundle "deris/vim-diffbuf"

NeoBundle "bling/vim-airline"
NeoBundle "vim-airline/vim-airline-themes"

NeoBundle "tyru/vim-altercmd"
NeoBundle "t9md/vim-choosewin"
NeoBundle "thinca/vim-qfreplace"

NeoBundle "sgur/vim-editorconfig"

" QSL formatter
NeoBundle 'vim-scripts/Align'
NeoBundle 'vim-scripts/SQLUtilities'


NeoBundle "mbbill/undotree", {
\	'autoload' : {'commands' : ["UndotreeShow"] },
\}

NeoBundle "Yggdroot/indentLine"
NeoBundle "vim-scripts/sudo.vim"
" NeoBundle "vim-scripts/AnsiEsc.vim"
NeoBundle "powerman/vim-plugin-AnsiEsc"
NeoBundle "simeji/winresizer"


" アイコン表示いろいろ
" https://qiita.com/park-jh/items/4358d2d33a78ec0a2b5c
NeoBundle "ryanoasis/vim-devicons"


" ライブラリ
NeoBundle "mattn/webapi-vim"
NeoBundle "vim-jp/vital.vim"
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

NeoBundle "fuenor/qfixhowm"
NeoBundle "Shougo/context_filetype.vim"


NeoBundleOrigin "after"
NeoBundleOrigin "mswin"

NeoBundleOrigin "vim-chained"
NeoBundleOrigin "ref-lynx"
NeoBundleOrigin "shabadou.vim"
NeoBundleOrigin "vim-watchdogs"
NeoBundleOrigin "vim-brightest"
NeoBundleOrigin "vim-budou"
NeoBundleOrigin "vim-owl"
NeoBundleOrigin "vim-hopping"
NeoBundleOrigin "vim-vigemo"
NeoBundleOrigin "vim-trip"
NeoBundleOrigin "vim-swindle"
let g:textobj_precious_no_default_key_mappings = 0
NeoBundleOrigin "vim-precious"
NeoBundleOrigin "vim-jplus"
" NeoBundleOrigin "vim-auto_alignta"
" NeoBundleOrigin "vim-poster"
" NeoBundleOrigin "vim-hoogle-web"
NeoBundleOrigin "vim-gimei"
NeoBundleOrigin "wandbox-vim"
NeoBundleOrigin "vim-bufixlist"
NeoBundleOrigin "vim-anzu"
NeoBundleOrigin "vim-milfeulle"
NeoBundleOrigin "vim-gift"
NeoBundleOrigin "vim-frill"
NeoBundleOrigin "vim-garden"
NeoBundleOrigin "unite-filters-collection"
NeoBundleOrigin "vim-snowdrop"
NeoBundleOrigin "vim-over",{
\	"lazy" : 1,
\	'autoload' : {
\		"commands" : ["OverCommandLine"],
\	}
\}
NeoBundleOrigin "codic-vim"
" NeoBundleOrigin "vim-gyazo"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" operator
NeoBundleOrigin "vim-operator-swap"
NeoBundleOrigin "vim-operator-alignta"
NeoBundleOrigin "vim-operator-block"
NeoBundleOrigin "vim-operator-highlighter"
NeoBundleOrigin "vim-operator-stay-cursor"
NeoBundleOrigin "vim-operator-surround-before"
NeoBundleOrigin "vim-operator-blockwise"
NeoBundleOrigin "vim-operator-exec_command"
NeoBundleOrigin "vim-operator-aggressive"
" NeoBundleOrigin "vim-operator-search"
" NeoBundleOrigin "vim-operator-jump-side"
" NeoBundleOrigin "vim-operator-highlight"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" textobj
let g:textobj_multiblock_no_default_key_mappings = 0
NeoBundleOrigin "vim-textobj-multiblock"
NeoBundleOrigin "vim-textobj-multitextobj"

let g:textobj_context_no_default_key_mappings = 0
NeoBundleOrigin "vim-textobj-context"
NeoBundleOrigin "vim-textobj-blockwise"
NeoBundleOrigin "vim-textobj-from_regexp"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" denite.vim
NeoBundleOrigin "denite-quickrun_config"
" NeoBundleOrigin "denite-qfixhowm"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" unite.vim
NeoBundleOrigin "unite-qfixhowm"
NeoBundleOrigin "unite-candidate_sorter"
NeoBundleOrigin "unite-highlight"
NeoBundleOrigin "unite-quickfix"
NeoBundleOrigin "unite-quickrun_config"
" NeoBundleOrigin "unite-vimpatches"
" NeoBundleOrigin "unite-github"
" NeoBundleOrigin "unite-vital-module"
" NeoBundleOrigin "unite-web_feed"
" NeoBundleOrigin "unite-choosewin-actions"
" NeoBundleOrigin "unite-env"
" NeoBundleOrigin "unite-file_mru2"
" NeoBundleLazy "unite-file_mru2", {
" \		"base" : $NEOBUNDLE_ORIGIN,
" \		"type" : "nosync"
" \}
" NeoBundleOrigin "unite-vimkaruta"
" NeoBundleOrigin "unite-fold"
" NeoBundleOrigin "unite-boost-online-doc"
" NeoBundleOrigin "unite-vim_hacks"
" NeoBundleOrigin "unite-itchyny-calendar"
" NeoBundleOrigin "unite-airline_themes"
" NeoBundleOrigin "unite-vimmer"
" NeoBundleOrigin "unite-option"
" NeoBundleOrigin "unite-oldfiles"
" NeoBundleOrigin "unite-toggle-options"
" NeoBundleOrigin "vim-powerline-unite-theme"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" quickrun.vim
NeoBundleOrigin "quickrun-outputter-replace_region"
" NeoBundleOrigin "quickrun-hook-vcvarsall"
" NeoBundleOrigin "quickrun-hook-u-nya-"
" NeoBundleOrigin "quickrun-hook-santi_pinch"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vital.vim

NeoBundleOrigin "vital-over"
NeoBundleOrigin "vital-garden"
NeoBundleOrigin "vital-secret"
NeoBundleOrigin "vital-coaster"
NeoBundleOrigin "vital-unlocker"
NeoBundleOrigin "vital-reti"
NeoBundleOrigin "vital-gift"
NeoBundleOrigin "vital-palette"
NeoBundleOrigin "vital-paradise"
NeoBundleOrigin "vital-branc"
NeoBundleOrigin "vital-migemo"
" NeoBundleOrigin "vital-reunions"






" NeoBundleOrigin "vim-nyaaancat"
" NeoBundleOrigin "vim-agrep"
" NeoBundleOrigin "vim-reanimate"
" NeoBundleOrigin "rsense"
" NeoBundleOrigin "vim-stargate"
" NeoBundleOrigin "neobundle-auto_lazy_source"
" NeoBundleOrigin "vim-hideout"
" NeoBundleOrigin "vim-pronamachang"
" NeoBundleOrigin "vim-sound"
" NeoBundleOrigin "vim-ghost"
" NeoBundleOrigin "vim-reunions"
" NeoBundleOrigin "vim-marching"
" NeoBundleOrigin "vim-fancy"
" NeoBundleOrigin "vim-retime"
" NeoBundleOrigin "vim-monster"
" NeoBundleOrigin "vim-edit_filetype"
" NeoBundleOrigin "vim-stripe"

" NeoBundle "vim-euphoric_player", "", "original", {
" \	"lazy" : 1,
" \	'autoload' : {
" \		"unite_sources" : ["euphoric_player_playlist", "euphoric_player_tracks"],
" \	}
" \}


" NeoBundleOrigin "vim-sugarpot", {
" \	"lazy" : 1,
" \	'autoload' : {
" \		'commands' : [
" \			{
" \				"name" : "SugarpotPreview",
" \				"complete" : "file",
" \			}
" \		]
" \	}
" \}

" NeoBundleOrigin "vim-sudden_valentine"
" NeoBundleOrigin "osyo-manga/capture.vim"


" NeoBundleOrigin "context_filetype.vim"
" NeoBundleOrigin "vim-automatic"
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
" NeoBundleOrigin "test"
" NeoBundleOrigin "test2"
" NeoBundleOrigin "vim-itunes-bgm"
" NeoBundleOrigin "vim-scaffold"
" NeoBundleOrigin "vim-scaffold-templates"
" NeoBundleOrigin "vim-cpp-syntax-reserved_identifiers"
" NeoBundle "vim-reti", "", "original"
" NeoBundleOrigin "vim-clang_declared"
" NeoBundleOrigin "vim-reti"
" NeoBundleOrigin "my-powerline"
" NeoBundleOrigin "vim-powerline"
" NeoBundleOrigin "TweetVim-powerline-theme"
" NeoBundleOrigin "neocomplcache-snippets-complete-dart"
" NeoBundleOrigin "neocomplcache-snippets-complete-jsx"


if !has('vim_starting')
	NeoBundleDocs
endif



