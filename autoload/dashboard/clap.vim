
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
