" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

if exists('g:autoloaded_dashboard') || &compatible
  finish
endif
let g:autoloaded_dashboard = 1

let s:fixed_column = 0
let s:empty_lines = ['']
let s:dashboard={}

function! dashboard#get_lastline() abort
  let s:dashboard.lastline = line('$')
  return s:dashboard.lastline
endfunction

function! dashboard#get_centerline() abort
  return s:dashboard.centerline
endfunction

" Function: #insane_in_the_membrane {{{1
function! dashboard#instance(on_vimenter) abort
  " Handle vim -y, vim -M.
  if a:on_vimenter && (&insertmode || !&modifiable)
    return
  endif

  if !&hidden && &modified
    call s:warn('Save your changes first.')
    return
  endif

  if line2byte('$') != -1
    noautocmd enew
  endif

  silent! setlocal
        \ bufhidden=wipe
        \ colorcolumn=
        \ foldcolumn=0
        \ matchpairs=
        \ nobuflisted
        \ nocursorcolumn
        \ nocursorline
        \ nolist
        \ nonumber
        \ norelativenumber
        \ nospell
        \ noswapfile
        \ signcolumn=no
        \ synmaxcol&

  " config the header margin-top
  call append('$', s:empty_lines)

  " Set Header
  let g:dashboard_header = exists('g:dashboard_custom_header')
        \ ? g:dashboard#utils#set_custom_section(g:dashboard#utils#draw_center(g:dashboard_custom_header))
        \ : g:dashboard#utils#set_custom_section(g:dashboard#utils#draw_center(dashboard#header#get_header()))
  if !empty(g:dashboard_header)
    let g:dashboard_header += ['']  " add blank line
  endif
  call append('$', g:dashboard_header)
  call append('$', s:empty_lines)

  let s:dashboard = {
        \ 'entries':   {},
        \ }
  let s:dashboard.centerline = line('$')

  call dashboard#section#instance()

  " Set footer
  call append('$', s:empty_lines)
  let s:dashboard.lastline = line('$')
  let footer = exists('g:dashboard_custom_footer')
    \ ? g:dashboard#utils#set_custom_section(g:dashboard#utils#draw_center(g:dashboard_custom_footer))
    \ : g:dashboard#utils#set_custom_section(g:dashboard#utils#draw_center(s:print_plugins_message()))
  if !empty(footer)
    let footer = [''] + footer
  endif
  call append('$', footer)


  setlocal nomodifiable nomodified
  call s:set_mappings()
  call cursor(s:dashboard.centerline+1,0)
  normal! ^ w
  let s:fixed_column = getpos('.')[2]
  autocmd dashboard CursorMoved <buffer> call s:set_cursor()

  silent! %foldopen!
  normal! zb
  set filetype=dashboard

  " Config the dashboard autocmd
  if exists('#User#Dashboard')
    doautocmd <nomodeline> User Dashboard
  endif
  if exists('#User#DashboardReady')
    doautocmd <nomodeline> User DashboardReady
  endif

endfunction

function! s:print_plugins_message() abort
  if has('nvim')
    let l:vim = 'neovim'
  else
    let l:vim = 'vim'
  endif
  if exists('*dein#get')
    let l:total_plugins = len(dein#get())
  elseif exists('*plug#begin')
    let l:total_plugins = len(keys(g:plugs))
  else
    return [' Have fun with ' . l:vim]
  endif
  let l:footer=[]
  let footer_string= l:vim .' loaded ' . l:total_plugins . ' plugins '
  call insert(l:footer,footer_string)
  return l:footer
endfunction

" Function: s:set_mappings {{{1
function! s:set_mappings()
  nnoremap <buffer><nowait><silent> <cr>      :call <sid>call_line_function()<CR>
endfunction

function! s:call_line_function()
  let l:current_line = getpos('.')[1]
  if has_key(s:dashboard.entries, l:current_line)
    let l:method = s:dashboard.entries[l:current_line]['cmd']
    if exists('g:dashboard_custom_section')
      let l:upper_method = toupper(l:method)
      call {l:upper_method}()
    else
      call dashboard#handler#{l:method}()
    endif
  endif
endfunction

" Function: s:set_cursor {{{1
function! s:set_cursor() abort
  let s:dashboard.oldline = exists('s:dashboard.newline') ? s:dashboard.newline : 2 + s:fixed_column
  let s:dashboard.newline = line('.')
  let l:height = dashboard#section#height()

  " going up (-1) or down (1)
  if s:dashboard.oldline == s:dashboard.newline
        \ && col('.') != s:fixed_column
        \ && !s:dashboard.leftmouse
    let movement = 2 * (col('.') > s:fixed_column) - 1
    let s:dashboard.newline += movement
  else
    let movement = 2 * (s:dashboard.newline > s:dashboard.oldline) - 1
    let s:dashboard.leftmouse = 0
  endif

  let s:dashboard.newline += movement

  " skip blank lines between lists
  if empty(getline(s:dashboard.newline))
    let s:dashboard.newline += movement
  endif

  " don't go beyond first or last entry
  let s:dashboard.newline = max([s:dashboard.centerline+1, min([s:dashboard.centerline+l:height, s:dashboard.newline])])

  call cursor(s:dashboard.newline, s:fixed_column)
endfunction

" Function: s:cd_to_vcs_root {{{1
function! dashboard#cd_to_vcs_root(path) abort
  let dir = fnamemodify(a:path, ':p:h')
  for vcs in [ '.git', '.hg', '.bzr', '.svn' ]
    let root = finddir(vcs, dir .';')
    if !empty(root)
      execute 'lcd' fnameescape(fnamemodify(root, ':h'))
      return 1
    endif
  endfor
  return 0
endfunction

function! dashboard#change_to_dir(path)
  if get(g:, 'dashboard_change_to_dir', 0)
    let dir = fnamemodify(a:path, ':h')
    if isdirectory(dir)
      echom "test"
      execute 'lcd' dir
    else
        " Do nothing. E.g. a:path == `scp://foo/bar`
    endif
  endif
endfunction

" Function: s:register {{{1
function! dashboard#register(line, index, cmd )
  let s:dashboard.entries[a:line] = {
        \ 'index':  a:index,
        \ 'line':   a:line,
        \ 'cmd':    a:cmd,
        \ }
endfunction


" vim: et sw=2 sts=2
