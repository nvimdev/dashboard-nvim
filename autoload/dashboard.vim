
if exists('g:autoloaded_dashboard') || &compatible
  finish
endif
let g:autoloaded_dashboard = 1

function! dashboard#get_lastline() abort
  let b:dashboard.lastline = line('$')
  return b:dashboard.lastline + 1
endfunction

let s:header = [
      \ '',
      \ '',
      \ ' ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗  ',
      \ ' ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗ ',
      \ ' ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║ ',
      \ ' ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║ ',
      \ ' ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝ ',
      \ ' ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ',
      \ '',
      \ '',
      \ ]

let s:section = [
      \ '',
      \ 'Reload  last  session                          SPC s l',
      \ '',
      \ 'Recently opened files                          SPC f h',
      \ '',
      \ 'Jump   to   bookmark                           SPC f b',
      \ '',
      \ '',]

" Function: #insane_in_the_membrane {{{1
function! dashboard#insane_in_the_membrane(on_vimenter) abort
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
        \ laststauts=0
  setlocal showtabline=0

  call append('$'," ")

  " Set Header
  let g:dashboard_header = exists('g:dashboard_custom_header')
        \ ? s:set_custom_section(s:set_drawer_center(g:dashboard_custom_header))
        \ : s:set_custom_section(s:set_drawer_center(s:header))
  if !empty(g:dashboard_header)
    let g:dashboard_header += ['']  " add blank line
  endif
  call append('$', g:dashboard_header)

  let b:dashboard = {
        \ 'entries':   {},
        \ 'indices':   [],
        \ 'leftmouse': 0,
        \ 'tick':      0,
        \ }

  let dashboard_center = s:set_custom_section(s:set_drawer_center(s:section))
  call append('$',dashboard_center)

  silent! %foldopen!
  normal! zb
  set filetype=dashboard

  let b:dashboard.lastline = line('$')

  " Set footer
  let footer = s:set_custom_section(s:set_drawer_center(s:print_plugins_message()))
  if !empty(footer)
    let footer = [''] + footer
  endif
  call append('$', footer)

  setlocal nomodifiable nomodified

  " Config the dashboard autocmd
  if exists('#User#Dashboard')
    doautocmd <nomodeline> User Dashboard
  endif
  if exists('#User#DashboardReady')
    doautocmd <nomodeline> User DashboardReady
  endif

endfunction

" Function: s:set_custom_section {{{1
function! s:set_drawer_center(lines) abort
  let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
  let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
  return centered_lines
endfunction

" Function: s:set_custom_section {{{1
function! s:set_custom_section(section) abort
  if type(a:section) == type([])
    return copy(a:section)
  elseif type(a:section) == type('')
    return empty(a:section) ? [] : eval(a:section)
  endif
  return []
endfunction

function! s:print_plugins_message() abort
  let l:total_plugins = len(dein#get())
  let l:footer=[]
  let footer_string='load  ' . l:total_plugins . ' plugins  in times'
  call insert(l:footer,footer_string)
  return l:footer
endfunction

" vim: et sw=2 sts=2
