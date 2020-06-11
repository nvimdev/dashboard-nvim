" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

if exists('g:autoloaded_dashboard') || &compatible
  finish
endif
let g:autoloaded_dashboard = 1

let s:fixed_column = 0

function! dashboard#get_lastline() abort
  let b:dashboard.lastline = line('$')
  return b:dashboard.lastline
endfunction

function! dashboard#get_centerline() abort
  return b:dashboard.centerline
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
      \ '                     [ Dashboard version : '. g:dashboard_version .' ]     ',
      \ '',
      \ ]

let s:dashboard_shutcut={}

if exists('g:dashboard_custom_shutcut')
  let s:dashboard_shutcut=copy(g:dashboard_custom_shutcut)
else
  let s:dashboard_shutcut['last_session'] = 'SPC s l'
  let s:dashboard_shutcut['find_history'] = 'SPC f h'
  let s:dashboard_shutcut['find_file'] = 'SPC f f'
  let s:dashboard_shutcut['change_colorscheme'] = 'SPC t c'
  let s:dashboard_shutcut['find_word'] = 'SPC f a'
  let s:dashboard_shutcut['book_marks'] = 'SPC f b'
endif

let s:Section = {
  \ 'last_session'         :[' Recently lase session                 '.s:dashboard_shutcut['last_session']],
  \ 'find_history'         :['ﭯ Recently opened files                 '.s:dashboard_shutcut['find_history']],
  \ 'find_file'            :[' Find  File                            '.s:dashboard_shutcut['find_file']],
  \ 'change_colorscheme'   :[' Change Colorscehme                    '.s:dashboard_shutcut['change_colorscheme']],
  \ 'find_word'            :[' Find  word                            '.s:dashboard_shutcut['find_word']],
  \ 'book_marks'           :[' Jump to book marks                    '.s:dashboard_shutcut['book_marks']],
  \ }

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
        \ laststauts=0
  setlocal showtabline=0

  " config the header margin-top
  let empty_lines = ['']
  for i in repeat([0],(winheight(0) / 4) - 8)
    call append('$', empty_lines)
  endfor

  " Set Header
  let g:dashboard_header = exists('g:dashboard_custom_header')
        \ ? s:set_custom_section(s:set_drawer_center(g:dashboard_custom_header))
        \ : s:set_custom_section(s:set_drawer_center(s:header))
  if !empty(g:dashboard_header)
    let g:dashboard_header += ['']  " add blank line
  endif
  call append('$', g:dashboard_header)
  call append('$', empty_lines)
  call append('$', empty_lines)

  let b:dashboard = {
        \ 'entries':   {},
        \ }
  let b:dashboard.centerline = line('$')

  if g:session_enable
    " Dashboard center section: last session
    let dashboard_last_session = s:set_custom_section(s:set_drawer_center(s:Section['last_session']))
    call append('$',dashboard_last_session)
    call s:register(line('$'), 'load_session', 'load_session')
    call append('$', empty_lines)
  endif

  " Dashboard center section: find history file
  let dashboard_find_history = s:set_custom_section(s:set_drawer_center(s:Section['find_history']))
  call append('$',dashboard_find_history)
  call s:register(line('$'), 'find_history', 'find_history')
  call append('$', empty_lines)

  " Dashboard center section: find file
  let dashboard_find_file = s:set_custom_section(s:set_drawer_center(s:Section['find_file']))
  call append('$',dashboard_find_file)
  call s:register(line('$'), 'find_file', 'find_file')
  call append('$', empty_lines)

  " Dashboard center section: Change Colorscheme
  let dashboard_change_colorscheme = s:set_custom_section(s:set_drawer_center(s:Section['change_colorscheme']))
  call append('$',dashboard_change_colorscheme)
  call s:register(line('$'), 'change_colorscheme', 'change_colorscheme')
  call append('$', empty_lines)

  " Dashboard center section: find words
  let dashboard_find_word = s:set_custom_section(s:set_drawer_center(s:Section['find_word']))
  call append('$',dashboard_find_word)
  call s:register(line('$'), 'find_word', 'find_word')
  call append('$', empty_lines)

  " Dashboard center section: book marks
  let dashboard_book_marks = s:set_custom_section(s:set_drawer_center(s:Section['book_marks']))
  call append('$',dashboard_book_marks)
  call s:register(line('$'), 'book_marks', 'book_marks')
  call append('$', empty_lines)

  " Set footer
  for i in repeat([0],3)
    call append('$', empty_lines)
  endfor

  let b:dashboard.lastline = line('$')
  let footer = exists('g:startify_custom_footer')
    \ ? s:set_custom_section(s:set_drawer_center(g:dashboard_custom_footer))
    \ : s:set_custom_section(s:set_drawer_center(s:print_plugins_message()))
  if !empty(footer)
    let footer = [''] + footer
  endif
  call append('$', footer)


  setlocal nomodifiable nomodified
  call s:set_mappings()
  call cursor(b:dashboard.centerline+1,0)
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
  if has('nvim')
    let l:vim = 'neovim'
  else
    let l:vim = 'vim'
  endif
  if stridx(&runtimepath,'dein.vim')
    let l:total_plugins = len(dein#get())
  elseif stridx(&runtimepath, 'plug.vim')
    let l:total_plugins = len(g:plugs)
  endif
  let l:footer=[]
  let footer_string= l:vim .' loaded ' . l:total_plugins . ' plugins '
  call insert(l:footer,footer_string)
  return l:footer
endfunction

" Function: s:register {{{1
function! s:register(line, index, cmd )
  let b:dashboard.entries[a:line] = {
        \ 'index':  a:index,
        \ 'line':   a:line,
        \ 'cmd':    a:cmd,
        \ }
endfunction

" Function: s:set_mappings {{{1
function! s:set_mappings()
  nnoremap <buffer><nowait><silent> <cr>      :call <sid>call_line_function()<CR>
endfunction

function! s:call_line_function()
  let l:current_line = getpos('.')[1]
  if has_key(b:dashboard.entries, l:current_line)
    let l:method = b:dashboard.entries[l:current_line]['cmd']
    call dashboard#handler#{l:method}()
  endif
endfunction

" Function: s:set_cursor {{{1
function! s:set_cursor() abort
  let b:dashboard.oldline = exists('b:dashboard.newline') ? b:dashboard.newline : 2 + s:fixed_column
  let b:dashboard.newline = line('.')

  " going up (-1) or down (1)
  if b:dashboard.oldline == b:dashboard.newline
        \ && col('.') != s:fixed_column
        \ && !b:dashboard.leftmouse
    let movement = 2 * (col('.') > s:fixed_column) - 1
    let b:dashboard.newline += movement
  else
    let movement = 2 * (b:dashboard.newline > b:dashboard.oldline) - 1
    let b:dashboard.leftmouse = 0
  endif

  let b:dashboard.newline += movement

  " skip blank lines between lists
  if empty(getline(b:dashboard.newline))
    let b:dashboard.newline += movement
  endif

  " don't go beyond first or last entry
  let b:dashboard.newline = max([b:dashboard.centerline+1, min([b:dashboard.centerline+11, b:dashboard.newline])])

  call cursor(b:dashboard.newline, s:fixed_column)
endfunction
" vim: et sw=2 sts=2
