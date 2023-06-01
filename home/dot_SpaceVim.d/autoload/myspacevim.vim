function! myspacevim#before() abort
  " Dark powered mode of SpaceVim, generated by SpaceVim automatically.
  let g:spacevim_enable_debug = 1
  let g:spacevim_realtime_leader_guide = 1
  let g:spacevim_automatic_update = 0

  call SpaceVim#layers#load('incsearch')
  call SpaceVim#layers#load('lang#c')
  call SpaceVim#layers#load('lang#elixir')
  call SpaceVim#layers#load('lang#go')
  call SpaceVim#layers#load('lang#haskell')
  call SpaceVim#layers#load('lang#java')
  call SpaceVim#layers#load('lang#javascript')
  call SpaceVim#layers#load('lang#lua')
  call SpaceVim#layers#load('lang#perl')
  call SpaceVim#layers#load('lang#php')
  call SpaceVim#layers#load('lang#python')
  call SpaceVim#layers#load('lang#rust')
  call SpaceVim#layers#load('lang#swig')
  call SpaceVim#layers#load('lang#vim')
  call SpaceVim#layers#load('lang#xml')
  call SpaceVim#layers#load('shell')
  call SpaceVim#layers#load('tools#screensaver')
  let g:spacevim_enable_vimfiler_welcome = 1
  let g:spacevim_enable_debug = 1
  let g:spacevim_enable_tabline_filetype_icon = 1
  let g:spacevim_enable_statusline_display_mode = 0
  let g:spacevim_statusline_unicode_symbols = 0
  let g:spacevim_enable_os_fileformat_icon = 1
  let g:spacevim_buffer_index_type = 1
  let g:neomake_vim_enabled_makers = []
  if executable('vimlint')
      call add(g:neomake_vim_enabled_makers, 'vimlint')
  endif
  if executable('vint')
      call add(g:neomake_vim_enabled_makers, 'vint')
  endif
  let g:clang2_placeholder_next = ''
  let g:clang2_placeholder_prev = ''

  let g:spacevim_enable_neomake = 1
  let g:neomake_open_list = 0
  let g:spacevim_filemanager = 'nerdtree'
  " Set nerdtree to display hidden files by default
  let g:NERDTreeShowHidden = 1

  let g:spacevim_layers_shell_default_position = "bottom"

  let g:chromatica#libclang_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib'

  " Prevent syntax highlighting on wide lines.  Fixes issues with kubectl last-applied-configuration
  set synmaxcol=240
  " Time for spacevim bar to show up (ms)
  set timeoutlen=250
  " Ignore case when searching (required for smartcase)
  :set ignorecase
  " ... except for when a capital letter is present
  :set smartcase
endfunction
