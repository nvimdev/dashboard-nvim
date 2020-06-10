
function! dashboard#clap#find_file() abort
  exec 'Clap files ++finder=rg --ignore --hidden --files' . '\<CR>'
endfunction
