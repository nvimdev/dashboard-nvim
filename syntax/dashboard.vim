
if exists("b:current_syntax")
  finish
endif

syntax sync fromstart

execute 'syntax region DashboardHeader start=/\%1l/ end=/\%'. (len(g:dashboard_header) + 3) .'l/'

execute 'syntax region DashboardCenter start=/\%'. dashboard#get_centerline() .'l/ end=/\%' . (dashboard#get_centerline()+10).'l/'

execute 'syntax region DashboardFooter start=/\%'. dashboard#get_lastline() .'l/ end=/\_.*/'


highlight default link DashboardHeader  Type
highlight default link DashboardCenter  Function
highlight default link DashboardFooter  Boolean

let b:current_syntax = 'dashboard'

" vim: et sw=2 sts=2
