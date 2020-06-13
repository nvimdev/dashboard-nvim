" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

function! dashboard#handler#load_session()
  SessionLoad
endfunction

function! dashboard#handler#find_file() abort
  if g:dashboard_executive == 'clap'
    call dashboard#clap#find_file()
  elseif g:dashboard_executive == 'leaderf'
    call dashboard#leaderf#find_file()
  else
    call dashboard#fzf#find_file()
  endif
endfunction

function! dashboard#handler#find_history() abort
  if g:dashboard_executive == 'clap'
    call dashboard#clap#find_history()
  elseif g:dashboard_executive == 'leaderf' 
    call dashboard#leaderf#find_history()
  else
    call dashboard#fzf#find_history()
  endif
endfunction

function! dashboard#handler#change_colorscheme() abort
  if g:dashboard_executive == 'clap'
    call dashboard#clap#change_colorscheme()
  elseif g:dashboard_executive =='leaderf'
    call dashboard#leaderf#change_colorscheme()
  else
    call dashboard#fzf#change_colorscheme()
  endif
endfunction

function! dashboard#handler#find_word() abort
  if g:dashboard_executive == 'clap'
    call dashboard#clap#find_word()
  elseif g:dashboard_executive =='leaderf'
    call dashboard#leaderf#find_word()
  else
    call dashboard#fzf#find_word()
  endif
endfunction

function! dashboard#handler#book_marks() abort
  if g:dashboard_executive == 'clap'
    call dashboard#clap#book_marks()
  elseif g:dashboard_executive =='leaderf'
    call dashboard#leaderf#book_marks()
  else
    call dashboard#fzf#book_marks()
  endif
endfunction
