## <div align="center"> [Dashboard-nvim](https://github.com/hardcoreplayers/dashboard-nvim)</div>

<div align="center">
<img src="https://user-images.githubusercontent.com/41671631/84384273-4f71a400-ac20-11ea-8806-8052ed64f28b.png" width="704" height="507">
</div>

<p align="center">
  <b><a href="https://github.com/hardcoreplayers/dashboard-nvim/wiki">Demo Screenshots</a></b>
  |
  <b><a href="/docs">docs</a></b>
</p>

## Install

- vim-plug

  ```vim
  Plug 'hardcoreplayers/dashboard-nvim'
  ```

- dein

  ```vim
  call dein#add('hardcoreplayers/dashboard-nvim')
  ```

## Options

- Config your excute tool by `g:dashboard_executive`,This option mean what fuzzy
  search plugins that you used. [vim-clap](https://github.com/liuchengxu/vim-clap)
  and [fzf.vim](https://github.com/junegunn/fzf.vim)

  ```viml
  let g:dashboard_executive ='clap' --default
  ```

- The `g:dashboard_custom_shutcut` means that what keymaps used for these commands,Just a tip like `whichkey`.
  On the dashboard, you only need to trigger it by pressing Enter on line.
  if you already define these commands keymaps just set it into `g:dashboard_custom_shutcut`,

  ```
  dashboard-nvim: SessionSave
  fzf.vim : History Files Colors Rg Marks

  vim-clap : Clap history Clap files ++finder=rg --ignore --hidden --files
  Clap colors Clap grep2 Clap marks
  ```

  ```viml
  eg :
    let g:dashboard_custon_shutcut['last_session'] = 'SPC s l'
    let g:dashboard_custon_shutcut['find_history'] = 'SPC f h'
    let g:dashboard_custon_shutcut['find_file'] = 'SPC f f'
    let g:dashboard_custon_shutcut['change_colorscheme'] = 'SPC t c'
    let g:dashboard_custon_shutcut['find_word'] = 'SPC f a'
    let g:dashboard_custon_shutcut['book_marks'] = 'SPC f b'
  ```

- `g:dashboard_custom_header` custom the dashboard header (same as startify)

- `g:dashboard_custom_footer` custom the dashboard footer (same as startify)

- Dashboard provide session support with `SessionLoad` and `SessionSave`
  commands you can define keymap like this .
  ```viml
  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  ```
  you can disable dashboard session by `g:dashboard_enable_session`. `0` means disable session.
  set the `dashboard_session_directory` to change the session folder
  default is `~/.cache/vim/session`
- Highlight group
  ```VimL
  DashboardHeader
  DashboardCenter
  DashboardShutCut
  DashboardFooter
  ```
- Autocmd `Dashboard` `DashboardReady` same as vim-startify

## MinialVimrc

- dashboard-nvim with vim-clap

  ```viml
  Plug 'hardcoreplayers/dashboard-nvim'
  Plug 'liuchengxu/vim-clap'

  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  nnoremap <silent> <Leader>fh :<C-u>Clap history<CR>
  nnoremap <silent> <Leader>ff :<C-u>Clap files ++finder=rg --ignore --hidden --files<cr>
  nnoremap <silent> <Leader>tc :<C-u>Clap colors<CR>
  nnoremap <silent> <Leader>fa :<C-u>Clap grep2<CR>
  nnoremap <silent> <Leader>fb :<C-u>Clap marks<CR>

  let g:dashboard_custon_shutcut['last_session'] = 'SPC s l'
  let g:dashboard_custon_shutcut['find_history'] = 'SPC f h'
  let g:dashboard_custon_shutcut['find_file'] = 'SPC f f'
  let g:dashboard_custon_shutcut['change_colorscheme'] = 'SPC t c'
  let g:dashboard_custon_shutcut['find_word'] = 'SPC f a'
  let g:dashboard_custon_shutcut['book_marks'] = 'SPC f b'
  ```

- dashboard-nvim with fzf.vim

  ```viml
  Plug 'hardcoreplayers/dashboard-nvim'
  Plug 'junegunn/fzf.vim'

  nmap <Leader>ss :<C-u>SessionSave<CR>
  nmap <Leader>sl :<C-u>SessionLoad<CR>
  nnoremap <silent> <Leader>fh :History<CR>
  nnoremap <silent> <Leader>ff :Files<CR>
  nnoremap <silent> <Leader>tc :Colors<CR>
  nnoremap <silent> <Leader>fa :Rg<CR>
  nnoremap <silent> <Leader>fb :Marks<CR>

  let g:dashboard_custon_shutcut['last_session'] = 'SPC s l'
  let g:dashboard_custon_shutcut['find_history'] = 'SPC f h'
  let g:dashboard_custon_shutcut['find_file'] = 'SPC f f'
  let g:dashboard_custon_shutcut['change_colorscheme'] = 'SPC t c'
  let g:dashboard_custon_shutcut['find_word'] = 'SPC f a'
  let g:dashboard_custon_shutcut['book_marks'] = 'SPC f b'
  ```

```
## Donate

| Wechat                                                                                                                | AliPay                                                                                                        |
| ------------- --------------------------------------------------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------|
| ![wechat](https://user-images.githubusercontent.com/41671631/79724460-287eac00-831a-11ea-8149-f5a68f19411a.png)       | ![ali](https://user-images.githubusercontent.com/41671631/84403276-1a714b80-ac38-11ea-8607-8492df84e516.png)  |


## Acknowledgement

- Inspired by [doom emacs](https://github.com/hlissner/doom-emacs)

- [vim-startify](https://github.com/mhinz/vim-startify)

## LICENSE

- MIT
```
