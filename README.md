<h1 align="center">
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />
  Fancy Fastest Async Start Screen Plugin of Neovim
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />
</h1>

<p align="center">
  <a href="https://github.com/glepnir/nvim/stargazers">
    <img
      alt="Stargazers"
      src="https://img.shields.io/github/stars/glepnir/dashboard-nvim?style=for-the-badge&logo=starship&color=c678dd&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/glepnir/nvim/issues">
    <img
      alt="Issues"
      src="https://img.shields.io/github/issues/glepnir/dashboard-nvim?style=for-the-badge&logo=gitbook&color=f0c062&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/glepnir/dashboard-nvim/contributors">
    <img
      alt="Contributors"
      src="https://img.shields.io/github/contributors/glepnir/dashboard-nvim?style=for-the-badge&logo=opensourceinitiative&color=abcf84&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
</p>

| macos | linux |
| ---   | ---   |
|<img src="https://user-images.githubusercontent.com/41671631/173181227-dd8f46c3-0aae-444a-b2e8-fe8ed592e28f.png" width=80% height=50%/> | <img src="https://user-images.githubusercontent.com/41671631/180594217-49567435-f7b6-4282-bf52-2d70eeb6b476.png" width=90% height=50%>|

> I hate someone stealing my ideas and code.

## Install

- Packer

```lua
packer.use {'glepnir/dashboard-nvim'}
```

## Option

```lua
local db = require('dashboard')
db.custom_header  -- type can be nil,table or function(must be return table in function)
                  -- if not config will use default banner
db.custom_center  -- table type and in this table you can set icon,desc,shortcut,action keywords. desc must be exist and type is string
                  -- icon type is nil or string
                  -- icon_hl table type { fg ,bg} see `:h vim.api.nvim_set_hl` opts
                  -- shortcut type is nil or string also like icon
                  -- action type can be string or function or nil.
                  -- if you don't need any one of icon shortcut action ,you can ignore it.
db.custom_footer  -- type can be nil,table or function(must be return table in function)
db.preview_file_Path          -- string or function type that mean in function you can dynamic generate height width
db.preview_file_height        -- number type
db.preview_file_width         -- number type
db.preview_command            -- string type (can be ueberzug which only work in linux)
db.confirm_key                -- string type key that do confirm in center select
db.hide_statusline            -- boolean default is true.it will hide statusline in dashboard buffer and auto open in other buffer
db.hide_tabline               -- boolean default is true.it will hide tabline in dashboard buffer and auto open in other buffer
db.hide_winbar                -- boolean default is true.it will hide the winbar in dashboard buffer and auto open in other buffer
db.session_directory          -- string type the directory to store the session file
db.session_auto_save_on_exit  -- boolean default is false.it will auto-save the current session on neovim exit if a session exists and more than one buffer is loaded
db.session_verbose            -- boolean default true.it will display the session file path on SessionSave and SessionLoad
db.header_pad                 -- number type default is 1
db.center_pad                 -- number type default is 1
db.footer_pad                 -- number type default is 1

-- example of db.custom_center for new lua coder,the value of nil mean if you
-- don't need this filed you can not write it
db.custom_center = {
  {icon_hl={fg="color_code"},icon ="some icon",desc="some desc"} --correct
  { icon = 'some icon' desc = 'some description here' } --correct if you don't action filed
  { desc = 'some description here' }                    --correct if you don't action and icon filed
  { desc = 'some description here' action = 'Telescope find files'} --correct if you don't icon filed
}

-- Custom events
DBSessionSavePre   -- a custom user autocommand to add functionality before auto-saving the current session on exit
DBSessionSaveAfter -- a custom user autocommand to add functionality after auto-saving the current session on exit

-- Example: Close NvimTree buffer before auto-saving the current session
autocmd('User', {
    pattern = 'DBSessionSavePre',
    callback = function()
      pcall(vim.cmd, 'NvimTreeClose')
    end,
})


-- Highlight Group
DashboardHeader DashboardCenter DashboardShortCut DashboardFooter

-- Command

DashboardNewFile  -- if you like use `enew` to create file,Please use this command,it's wrap enew and restore the statsuline and tabline
SessionSave,SessionLoad,SessionDelete
```

### Ascii Header Examples

I've collected some header texts in the [wiki](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text). You can view previews of them [here](https://github.com/glepnir/dashboard-nvim/wiki/Header-Preview).

And you can use the [nv-dashboard-header-maker](https://github.com/xflea/nv-dashboard-header-maker)
thanks the [xflea](https://github.com/xflea)  create it.

## FAQ

1. How to achieve the dashboard like in the screenshot?

You need install `lolcat` and pass it this Ascii logo (Thanks [@sunjon](https://github.com/sunjon), which you can find [here](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text)).

```lua
  local home = os.getenv('HOME')
  local db = require('dashboard')
  -- macos
  db.preview_command = 'cat | lolcat -F 0.3'
  -- linux
  db.preview_command = 'ueberzug'
  --
  db.preview_file_path = home .. '/.config/nvim/static/neovim.cat'
  db.preview_file_height = 11
  db.preview_file_width = 70
  db.custom_center = {
      {icon = '  ',
      desc = 'Recently latest session                  ',
      shortcut = 'SPC s l',
      action ='SessionLoad'},
      {icon = '  ',
      desc = 'Recently opened files                   ',
      action =  'DashboardFindHistory',
      shortcut = 'SPC f h'},
      {icon = '  ',
      desc = 'Find  File                              ',
      action = 'Telescope find_files find_command=rg,--hidden,--files',
      shortcut = 'SPC f f'},
      {icon = '  ',
      desc ='File Browser                            ',
      action =  'Telescope file_browser',
      shortcut = 'SPC f b'},
      {icon = '  ',
      desc = 'Find  word                              ',
      action = 'Telescope live_grep',
      shortcut = 'SPC f w'},
      {icon = '  ',
      desc = 'Open Personal dotfiles                  ',
      action = 'Telescope dotfiles path=' .. home ..'/.dotfiles',
      shortcut = 'SPC f d'},
    }
```

2. How to work with indentLine or whitespace plugin alike?

If you installed some indentline plugin. you need to set it to ignore the filetype `dashboard`. For example:

```viml
" For 'Yggdroot/indentLine' and 'lukas-reineke/indent-blankline.nvim' "
let g:indentLine_fileTypeExclude = ['dashboard']
" For 'ntpeters/vim-better-whitespace' "
let g:better_whitespace_filetypes_blacklist = ['dashboard']
```

Or in a `plugins.lua` config context:

```lua
use {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    require("indent_blankline").setup { filetype_exclude = { "dashboard" }
    }
  end
}
```

## Donate

[![](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/bobbyhub)

If you'd like to support my work financially, buy me a drink through [paypal](https://paypal.me/bobbyhub)

## LICENSE

MIT
