" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

function! sessions#session#session_save(name)
  if ! isdirectory(g:session_directory)
    call mkdir(g:session_directory, 'p')
  endif
  let file_name = empty(a:name) ? s:project_name() : a:name
  let file_path = g:session_directory.'/'.file_name.'.vim'
  execute 'mksession! '.fnameescape(file_path)
  let v:this_session = file_path

  echohl MoreMsg
  echo 'Session `'.file_name.'` is now persistent'
  echohl None
endfunction

function! sessions#session#session_load(name)
  let file_name = empty(a:name) ? s:project_name() : a:name
  let file_path = g:session_directory.'/'.file_name.'.vim'

  if ! empty(v:this_session) && ! exists('g:SessionLoad')
    \ |   execute 'mksession! '.fnameescape(v:this_session)
    \ | endif

  if filereadable(file_path)
    noautocmd silent! %bwipeout!
    execute 'silent! source '.file_path
    if &laststatus == 0
      set laststatus=2
    endif
    echomsg 'Loaded "'.file_path.'" session'
  else
    echohl ErrorMsg
    echomsg 'The session "'.file_path.'" doesn''t exist'
    echohl None
  endif
endfunction

function! sessions#session#session_list(A, C, P)
  return map(
    \ split(glob(g:session_directory.'/*.vim'), '\n'),
    \ "fnamemodify(v:val, ':t:r')"
    \ )
endfunction

function! s:project_name()
  let l:cwd = resolve(getcwd())
  let l:cwd = substitute(l:cwd, '^'.$HOME.'/', '', '')
  let l:cwd = fnamemodify(l:cwd, ':p:gs?/?_?')
  let l:cwd = substitute(l:cwd, '^\.', '', '')
  return l:cwd
endfunction


" vim: et sw=2 sts=2
