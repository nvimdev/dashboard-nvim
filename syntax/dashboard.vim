" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>

if exists("b:current_syntax")
  finish
endif

syntax sync fromstart

execute 'syntax region DashboardHeader start=/\%1l/ end=/\%'. (dashboard#get_centerline()-1) .'l/'


execute 'syntax region DashboardFooter start=/\%'. dashboard#get_lastline() .'l/ end=/\_.*/'


syntax region DashboardCenter start=/\S/ end=/\s\{1,3}/

syntax region DashboardShortCut start=/\s\s\w\+\s[a-z]\+/ end=/$/

highlight default link DashboardHeader  Type
highlight default link DashboardCenter  String
highlight default link DashboardShortCut Keyword
highlight default link DashboardFooter  Boolean

let b:current_syntax = 'dashboard'

" vim: et sw=2 sts=2
