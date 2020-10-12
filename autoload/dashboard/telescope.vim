" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

function! dashboard#telescope#find_file() abort
  TelescopeFindFile
endfunction

function! dashboard#telescope#find_history() abort
  TelescopeOldFiles
endfunction

function! dashboard#telescope#change_colorscheme() abort
  TelescopeColorscheme
endfunction

function! dashboard#telescope#find_word() abort
  TelescopeGrepString
endfunction

function! dashboard#telescope#book_marks() abort
  TelescopeMarks
endfunction

