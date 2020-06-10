
function! dashboard#clap#find_file() abort
  execute 'Clap files ++finder=rg --ignore --hidden --files<CR>'
endfunction
