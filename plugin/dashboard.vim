
if exists('g:loaded_dashboard') || &cp
  finish
endif

let g:loaded_dashboard = 1

if !get(g:, 'dashboard_disable_at_vimenter') && (!has('nvim') || has('nvim-0.3.5'))
  " Only for Nvim v0.3.5+: https://github.com/neovim/neovim/issues/9885
  set shortmess+=I
endif

" Use clap and fzf as executive
let g:dashboard_executive = get(g:,'dashboard_default_executive','clap')

augroup dashboard
  autocmd!
  autocmd VimEnter * nested call s:loaded_dashboard()
augroup END

function! s:loaded_dashboard() abort
  if !argc() && line2byte('$') == -1
    if !get(g:, 'dashboard_disable_at_vimenter')
      call dashboard#instance(1)
    endif
  endif
  autocmd! dashboard VimEnter
endfunction


" vim: et sw=2 sts=2
