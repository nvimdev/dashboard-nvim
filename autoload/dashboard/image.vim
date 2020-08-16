function! dashboard#image#preview()
 l:image = g:dashboard_image
 l:shellpath = ''
 for item in split(&runtimepath,',')
  if stridx(item,'dashboard-nvim') >= 0
    let l:shellpath = item.'/autoload/dashboard/preview_image.sh'
      break
    endif
  endfor
  let s:width = g:dashboard_img_width
  let s:height = g:dashboard_img_height
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
  let s:winid = nvim_open_win(s:buf, v:true, s:opts)
  hi! DashboardImage guibg=NONE guifg=NONE
  call nvim_win_set_option(s:winid, "winblend", 0)
  call nvim_win_set_option(s:winid, "winhl", "Normal:DashboardImage")
  execute 'terminal bash '.l:shellpath.' '. l:image
endfunction

