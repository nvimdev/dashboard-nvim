<h1 align="center">
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />
  Fancy And Fastest Start Screen Plugin of Neovim
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />“
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

<p align="center">
  <img src="https://user-images.githubusercontent.com/41671631/110912263-b1e20700-834e-11eb-8058-c29e34ec439a.png"
  height = "40%"
  widht = "40%"
  />
</p>

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
                  -- shortcut type is nil or string also like icon
                  -- action type can be string or function or nil.
                  -- if you don't need any one of icon shortcut action ,you can ignore it.
db.custom_footer  -- type can be nil,table or function(must be return table in function)
db.preview_file_Path    -- string type 
db.preview_file_height  -- string type
db.preview_file_width   -- string type
db.preview_command      -- string type
db.hide_statusline      -- boolean default is true.it will hide statusline in dashboard buffer and auto open in other buffer
db.hide_tabline         -- boolean default is true.it will hide tabline in dashboard buffer and auto open in other buffer

-- Highlight Group
DashboardHeader DashboardCenter DashboardCenterIcon DashboardShortCut DashboardFooter
```
- Ascii Header text

  I collection some header texts in [Wiki](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text) and you can preview
these texts [Preview](https://github.com/glepnir/dashboard-nvim/wiki/Header-Preview      )

## FQA

- How to config like screenshot

   you need install `lolcat` and Thanks [@sunjon](https://github.com/sunjon) create this neovim logo. you can
  find it in [here](https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text)

```lua
  local home = os.getenv('HOME')
  local db = require('dashboard')
  db.preview_command = 'cat | lolcat -F 0.3'
  db.preview_file_path = home .. '/.config/nvim/static/neovim.cat'
  db.preview_file_height = 12
  db.preview_file_width = 80
  db.custom_center = {
      {icon = '  ',
      desc = 'Recently laset session                  ',
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
      aciton = 'DashboardFindWord',
      shortcut = 'SPC f w'},
      {icon = '  ',
      desc = 'Open Personal dotfiles                  ',
      action = 'Telescope dotfiles path=' .. home ..'/.dotfiles',
      shortcut = 'SPC f d'},
    }
```
- How to work with indentLine plugin?

   If you install some indentline plugin. you need config the option that can pass dashboard filetype `dashboard` to exclude filetyp


## LICENSE

- MIT
