" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

function! dashboard#telescope#find_file() abort
  Telescope find_files prompt_prefix=🔍
endfunction

function! dashboard#telescope#find_history() abort
  Telescope oldfiles prompt_prefix=🔍
endfunction

function! dashboard#telescope#change_colorscheme() abort
  Telescope colorscheme prompt_prefix=🔍
endfunction

function! dashboard#telescope#find_word() abort
  Telescope grep_string prompt_prefix=🔍
endfunction

function! dashboard#telescope#book_marks() abort
  Telescope marks prompt_prefix=🔍
endfunction

