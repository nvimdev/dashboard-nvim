" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

function! dashboard#clap#find_file() abort
  Clap files ++finder=rg --ignore --hidden --files
endfunction

function! dashboard#clap#find_history() abort
  Clap history
endfunction

function! dashboard#clap#change_colorscheme() abort
  Clap colors
endfunction

function! dashboard#clap#find_word() abort
  Clap grep2
endfunction

function! dashboard#clap#book_marks() abort
  Clap marks
endfunction

