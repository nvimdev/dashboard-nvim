function! dashboard#preview#preview_file()
  let s:width = g:preview_file_width
  let s:height = g:preview_file_height
  let s:row = float2nr(s:height / 5)
  let s:col = float2nr((&columns - s:width) / 2)
  let s:opts = {
    \ 'relative': 'editor',
    \ 'row': s:row,
    \ 'col': s:col,
    \ 'width': s:width,
    \ 'height': s:height,
    \ 'style': 'minimal'
    \ }
  let s:buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_option(s:buf,'filetype','dashpreview')
  let s:winid = nvim_open_win(s:buf, v:true, s:opts)
  call nvim_win_set_option(s:winid, "winhl", "Normal:DashboardTerminal")
  hi DashboardTerminal guibg=NONE gui=NONE
  execute 'terminal ' . g:dashboard_command .' ' . g:preview_file_path
  return s:winid
endfunction
