<div align="center">
<img src="https://user-images.githubusercontent.com/41671631/84760810-26c02480-affb-11ea-903a-d8796189e58a.png">
</div>
<p align="center">
  <b><a href="https://github.com/glepnir/dashboard-nvim/wiki">Demo Screenshots</a></b>
  •
  <b><a href="/doc/dashboard.txt">doc</a></b>
</p>
<div align="center">
<img src="https://user-images.githubusercontent.com/41671631/110912263-b1e20700-834e-11eb-8058-c29e34ec439a.png">
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

- Use `g:dashboard_default_executive` to select which fuzzy search plugins that you would like to apply: 
  
  - [vim-clap](https://github.com/liuchengxu/vim-clap)
  
  - [fzf.vim](https://github.com/junegunn/fzf.vim)

  - [telescope.nvim](https://github.com/nvim-lua/telescope.nvim)
  
    **You must install one of them.**
  
  ```vim
  " Default value is clap
  let g:dashboard_default_executive ='clap'
  ```
  
- Dashboard utilises some `vim-clap`, `fzf.vim`, and 'telescope.nvim' commands and displays the result in popup windows.
  The built-in dashboard commands executed are based on the plugin you set in previous session.

  - DashboardFindFile is the same as: 
    - vim-clap: `Clap files ++finder=rg --ignore --hidden --files`
    - fzf.vim: `Files`
    - telescope.nvim: `Telescope find_files`
  - DashboardFindHistory: 
    - vim-clap: `Clap history`
    - fzf.vim: `History`
    - telescope.nvim: `Telescope oldfiles`
  - DashboardChangeColorscheme: 
    - vim-clap: `Clap colors`
    - fzf.vim: `Colors`
    - telescope.nvim: `Telescope colorscheme`
  - DashboardFindWord:
    - vim-clap: `Clap grep2`
    - fzf.vim: `Rg` or `Ag`
    - telescope.nvim: `Telescope live_grep`
  - DashboardJumpMark:
    - vim-clap: `Clap marks`
    - fzf.vim: `Marks`
    - telescope.nvim: `Telescope marks`

  If you have already defined the vim-clap/fzf/telescope commands, just set your keymaps into `g:dashboard_custom_shortcut`.
  
  If you want to use the built-in commands, you can create the dashboard command keymappings (refer to **Minimal Vimrc** session Line 8-13) then set them into `g:dashboard_custom_shortcut`.

  ```vim
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

- `g:dashboard_custom_shortcut_icon` customs the shortcut icons:

  Note: There is one extra space after the icon character to improve visibility.

  ```vim
  let g:dashboard_custom_shortcut_icon['last_session'] = ' '
  let g:dashboard_custom_shortcut_icon['find_history'] = 'ﭯ '
  let g:dashboard_custom_shortcut_icon['find_file'] = ' '
  let g:dashboard_custom_shortcut_icon['new_file'] = ' '
  let g:dashboard_custom_shortcut_icon['change_colorscheme'] = ' '
  let g:dashboard_custom_shortcut_icon['find_word'] = ' '
  let g:dashboard_custom_shortcut_icon['book_marks'] = ' '
  ```

- What does the shortcut do? 

    Just a tip like `whichkey`, on the dashboard, shortcuts are items that you can use the cursor to navigate around and press `Enter` to confirm.

- `g:dashboard_custom_header` customs the dashboard header (same as startify). Check [wiki](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text) to find more Ascii Text Header collections.
  
- `g:dashboard_custom_footer` customs the dashboard footer (same as startify).

- Dashboard provides session support. With `SessionLoad` and `SessionSave` commands, you can define keymaps like below:
  
  ```vim
  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  ```
  Set `dashboard_session_directory` to change the session folder which by default is `~/.cache/vim/session`.
  
- Highlight groups
  ```vim
  DashboardHeader
  DashboardCenter
  DashboardShortcut
  DashboardFooter
  ```

- Autocmd `Dashboard` `DashboardReady` are the same as vim-startify.

- `g:dashboard_custom_section` customs your own sections. 
  
  It's a dictionary whose entries will be your DIY shortcuts.

  Each entry will be an object that must contain attribute `description` and attribute `command`:
  
  * `description` is a string shown in Dashboard buffer.
  * `command` is a string or funcref type. You can pass every command from all fuzzy find plugins you used.

  ```vim
  let g:dashboard_custom_section={
    \ 'buffer_list': {
        \ 'description': [' Recently lase session                 SPC b b'],
        \ 'command': 'Some Command' or function('your funciton name') }
    \ }
  ```
  
- some options for fzf :

    * `g:dashboard_fzf_float` : default is 1.
    * `g:dashboard_fzf_engine`: default is `rg`, while the other value is `ag`.

- `dashboard_preview_command`: use a command that can print output to a neovim built-in terminal. e.g. `cat`
  
- `dashboard_preview_pipeline`: pipeline command.

- `dashboard_preview_file`: the string path of your preview file.

- `dashboard_preview_file_height`: the height of the preview file.

- `dashboard_preview_file_width`: the width of the preview file.

## Minimal Vimrc

You can replace the vim-clap or fzf.vim commands by dashboard commands.

  ```vim
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

- Config as Demo

  Thanks [@sunjon](https://github.com/sunjon) create this neovim logo. you can
  find it in
  [here](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text)

  ```vim
  vim.g.dashboard_preview_command = 'cat'
  vim.g.dashboard_preview_pipeline = 'lolcat'
  vim.g.dashboard_preview_file = path to logo file like
  ~/.config/nvim/neovim.cat
  vim.g.dashboard_preview_file_height = 12
  vim.g.dashboard_preview_file_width = 80
  ```

- What is the difference between this plugin and vim-startify?

  Dashbaord is inspired by doom-emacs. vim-startify provides a list of many files, MRU old files, etc. But do we really need that list? We merely just wanna open one single file, while the huge files list is constantly occupying a lot of space.
  
  Dashboard uses fuzzy search plugins, pop-up menus that hide all the lists and display only if needed. In addition, more functionalities are brought in.
  
- How to work with indentLine plugin?

  Disable the plugin while in dashboard:

  ```vim
  let g:indentLine_fileTypeExclude = ['dashboard']
  ```

- How to disable the tabline in dashboard buffer?

  ```vim
  autocmd FileType dashboard set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2
  ```


## LICENSE

- MIT
