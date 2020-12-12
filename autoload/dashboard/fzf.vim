" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>
"
function! dashboard#fzf#find_file() abort
  Files
endfunction

function! dashboard#fzf#find_history() abort
  History
endfunction

function! dashboard#fzf#change_colorscheme() abort
  Colors
endfunction

function! dashboard#fzf#find_word() abort
  if g:dashboard_fzf_engine == 'rg'
    Rg
  elseif g:dashboard_fzf_engine == 'ag'
    Ag
  endif
endfunction

function! dashboard#fzf#book_marks() abort
  Marks
endfunction

fu s:snr() abort
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu

let s:snr = get(s:, 'snr', s:snr())
