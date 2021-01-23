<div align="center">
<img src="https://user-images.githubusercontent.com/41671631/84760810-26c02480-affb-11ea-903a-d8796189e58a.png">
</div>
<p align="center">
  <b><a href="https://github.com/glepnir/dashboard-nvim/wiki">Demo Screenshots</a></b>
  •
  <b><a href="/docs">docs</a></b>
</p>
<div align="center">
<img src="https://user-images.githubusercontent.com/41671631/100820859-2113a980-348a-11eb-8a11-c1fa3a76ab2f.png">
</div>

## Install

- vim-plug

  ```vim
  Plug 'glepnir/dashboard-nvim'
  ```

- dein

  ```vim
  call dein#add('glepnir/dashboard-nvim')
  ```

## Options

- Config your excute tool by `g:dashboard_default_executive`,This option mean what fuzzy
  search plugins that you used. [vim-clap](https://github.com/liuchengxu/vim-clap)
  and [fzf.vim](https://github.com/junegunn/fzf.vim)
  [Telescope](https://github.com/nvim-lua/telescope.nvim)

  ```viml
  " Default value is clap
  let g:dashboard_default_executive ='clap'
  ```

- Dashboard wrap some `vim-clap` and `fzf.vim` commands with window config, And
  the dashboard commands execute tool depends on what plugin you used

  - DashboardFindFile same as
    - vim-clap: `Clap history Clap files ++finder=rg --ignore --hidden --files`
    - fzf.vim : `Files`
  - DashboardFindHistory same as
    - vim-clap: `Clap history`
    - fzf.vim : `History`
  - DashboardChangeColorscheme same as
    - vim-clap: `Clap colors`
    - fzf.vim : `Colors`
  - DashboardFindWord same as
    - vim-clap: `Clap grep2`
    - fzf.vim : `Rg`
  - DashboardJumpMark same as
    - vim-clap: `Clap marks`
    - fzf.vim : `Marks`

  If you already define the vim-clap and fzf commands, just set your keymaps
  into the `g:dashboard_custom_shortcut`.
  If you want use the Dashboard wrap commands. you can define the dashboard
  commands keymap then set it into `g:dashboard_custom_shortcut`

  ```viml
  eg : "SPC mean the leaderkey
      let g:dashboard_custom_shortcut={
        \ 'last_session'       : 'SPC s l',
        \ 'find_history'       : 'SPC f h',
        \ 'find_file'          : 'SPC f f',
        \ 'new_file'           : 'SPC c n',
        \ 'change_colorscheme' : 'SPC t c',
        \ 'find_word'          : 'SPC f a',
        \ 'book_marks'         : 'SPC f b',
        \ }
  ```

- `g:dashboard_custom_shortcut_icon` custom the shortcut icon.like this

```
 let g:dashboard_custom_shortcut_icon['last_session'] = ' '
 let g:dashboard_custom_shortcut_icon['find_history'] = 'ﭯ '
 let g:dashboard_custom_shortcut_icon['find_file'] = ' '
 let g:dashboard_custom_shortcut_icon['new_file'] = ' '
 let g:dashboard_custom_shortcut_icon['change_colorscheme'] = ' '
 let g:dashboard_custom_shortcut_icon['find_word'] = ' '
 let g:dashboard_custom_shortcut_icon['book_marks'] = ' '

```

- what does the shortcut do? just a tip like `whichkey`,on dashboard you just
  move the cursor and press `enter`

- `g:dashboard_custom_header` custom the dashboard header (same as startify)
  check [wiki](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text)
  to find more Ascii Text Header collection.

- `g:dashboard_custom_footer` custom the dashboard footer (same as startify)

- Dashboard provide session support with `SessionLoad` and `SessionSave`
  commands you can define keymap like this .
  ```viml
  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  ```
  set the `dashboard_session_directory` to change the session folder
  default is `~/.cache/vim/session`
- Highlight group
  ```VimL
  DashboardHeader
  DashboardCenter
  DashboardShortcut
  DashboardFooter
  ```
- Autocmd `Dashboard` `DashboardReady` same as vim-startify

- `g:dashboard_custom_section` custom section, it's a dict type,key is your section component name,
  It will be used to sort. every component is a dict and must have `description` and `command`,
  `description` is a list that show in Dashboard buffer,`command` is string or funcref type.

  ```viml
  let g:dashboard_custom_section={
    \ 'buffer_list': {
        \ 'description': [' Recently lase session                 SPC b b'],
        \ 'command': 'Some Command' or function('your funciton name') }
    \ }
  ```
- some options for fzf `g:dashboard_fzf_float` default is 1, `g:dashboard_fzf_engine` default is `rg` other value is `ag`

- `dashboard_preview_command`  a command that can normal output in neovim built-in terminal.like
  `cat` etc

- `dashboard_preview_pipeline` pipeline command

- `dashboard_preview_file` your preview file path string.

- `dashboard_preview_file_height` preview file height.

- `dashboard_preview_file_width` preview file width.

## Minial vimrc

you can replace the vim-clap or fzf.vim commands by dashboard commands

  ```viml
  Plug 'glepnir/dashboard-nvim'
  Plug 'liuchengxu/vim-clap' or Plug 'junegunn/fzf.vim' or Plug 'nvim-lua/telescope.nvim'

  let g:mapleader="\<Space>"
  let g:dashboard_default_executive ='clap' or 'fzf' or 'telescope'
  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  nnoremap <silent> <Leader>fh :DashboardFindHistory<CR>
  nnoremap <silent> <Leader>ff :DashboardFindFile<CR>
  nnoremap <silent> <Leader>tc :DashboardChangeColorscheme<CR>
  nnoremap <silent> <Leader>fa :DashboardFindWord<CR>
  nnoremap <silent> <Leader>fb :DashboardJumpMark<CR>
  nnoremap <silent> <Leader>cn :DashboardNewFile<CR>

  ```

## FAQ

- What is it different from vim-startify ?
  dashbaord is inspired by doom-emacs, startify provides a list of many files,
  Mru oldfile, etc., but do we really need this list, we will only open one file,
  and the file list takes up a lot of space, the dashboard uses fuzzy search plugin
  pop-up menu, it saves a lot of space, and provides more functions.

- How to work with indentline plugin ?

  ```vim
  let g:indentLine_fileTypeExclude = ['dashboard']
  ```

- How to disable tabline in dashboard buffer?

  ```vim
  autocmd FileType dashboard set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2
  ```


## LICENSE

- MIT
