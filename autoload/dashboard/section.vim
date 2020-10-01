" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

let s:empty_lines = ['']
let s:Section = {}
let s:dashboard_shortcut={}
let s:dashboard_shortcut_icon={}

if exists('g:dashboard_custom_shortcut')
  call extend(s:dashboard_shortcut, g:dashboard_custom_shortcut)
else
  let s:dashboard_shortcut['last_session'] = 'SPC s l'
  let s:dashboard_shortcut['find_history'] = 'SPC f h'
  let s:dashboard_shortcut['find_file'] = 'SPC f f'
  let s:dashboard_shortcut['new_file'] = 'SPC c n'
  let s:dashboard_shortcut['change_colorscheme'] = 'SPC t c'
  let s:dashboard_shortcut['find_word'] = 'SPC f a'
  let s:dashboard_shortcut['book_marks'] = 'SPC f b'
endif

if exists('g:dashboard_custom_shortcut_icon')
  call extend(s:dashboard_shortcut_icon, g:dashboard_custom_shortcut_icon)
else
  let s:dashboard_shortcut_icon['last_session'] = ' '
  let s:dashboard_shortcut_icon['find_history'] = ' '
  let s:dashboard_shortcut_icon['find_file'] = ' '
  let s:dashboard_shortcut_icon['new_file'] = ' '
  let s:dashboard_shortcut_icon['change_colorscheme'] = ' '
  let s:dashboard_shortcut_icon['find_word'] = ' '
  let s:dashboard_shortcut_icon['book_marks'] = ' '
endif

if exists('g:dashboard_custom_section')
  call extend(s:Section, g:dashboard_custom_section)
else
  let s:Section = {
    \ 'last_session'         :[s:dashboard_shortcut_icon['last_session'].'Recently last session                 '.s:dashboard_shortcut['last_session']],
    \ 'find_history'         :[s:dashboard_shortcut_icon['find_history'].'Recently opened files                 '.s:dashboard_shortcut['find_history']],
    \ 'find_file'            :[s:dashboard_shortcut_icon['find_file'].'Find  File                            '.s:dashboard_shortcut['find_file']],
    \ 'new_file'             :[s:dashboard_shortcut_icon['new_file'].'New  File                             '.s:dashboard_shortcut['new_file']],
    \ 'change_colorscheme'   :[s:dashboard_shortcut_icon['change_colorscheme'].'Change Colorscheme                    '.s:dashboard_shortcut['change_colorscheme']],
    \ 'find_word'            :[s:dashboard_shortcut_icon['find_word'].'Find  word                            '.s:dashboard_shortcut['find_word']],
    \ 'book_marks'           :[s:dashboard_shortcut_icon['book_marks'].'Jump to book marks                    '.s:dashboard_shortcut['book_marks']],
    \ }
endif

function! dashboard#section#height()
  return len(s:Section)+(len(s:Section)-1)
endfunction

function! dashboard#section#instance()
  call s:set_section()
endfunction

function! s:set_section()
  let l:sorted = []
  for key in keys(s:Section)
    call add(l:sorted,key)
  endfor

  for key in sort(l:sorted)
    let dashboard_{key} = g:dashboard#utils#set_custom_section(g:dashboard#utils#draw_center(s:Section[key]))
    call append('$',dashboard_{key})
    call dashboard#register(line('$'), key, key)
    call append('$', s:empty_lines)
  endfor
endfunction
