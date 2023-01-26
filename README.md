<h1 align="center">
  Fancy and Blazing Fast start screen plugin of neovim
</h1>

| <center>Hyper</center> | <center>Doom</center> |
| ---   | ---   |
| <center><img src="https://user-images.githubusercontent.com/41671631/213870957-ee345d45-7e5e-41ba-bdf3-c371e65544b9.png" width=80% height=80%/></center>|<center> <img src="https://user-images.githubusercontent.com/41671631/214518543-d7d6afbf-f405-4a6f-a505-568c5a101e92.png" width=80% height=80%/> </center>|

# Feature

- Low memory usage. dashboard does not store the all user configs in memory like header etc these string will take some memory. now it will be clean after you open a file. you can still use dashboard command to open a new one , then dashboard will read the config from cache.
- Blazing fast


# Install

- Lazy.nvim

```lua
{
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    -- config
  },
  dependices = { {'nvim-tree/nvim-web-devicons'}}
}
```

- Packer

```lua
use {
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end
  require = { {'nvim-tree/nvim-web-devicons'}}
}
```

# Configuration

## Options

```lua
theme = 'hyper' --  theme is doom and hyper default is hyper
config = {},    --  config used for theme
hide = {
  statusline    -- hide statusline default is true
  tabline       -- hide the tabline
  winbar        -- hide winbar
},
preview = {
  command       -- preview command
  file_path     -- preview file path
  file_height   -- preview file height
  file_width    -- preview file width
},
```

## Theme config

the `config` field is used for theme.

### Hyper

when use `hyper` theme the available options in `config` is

```lua
config = {
  header = {}, -- ascii text in there
  shortcut = {
    { desc = string, group = 'highlight group', key = 'shortcut key', action = 'action when you press key' },
  },
  packages = { enable = true }, -- show how many plugins neovim loaded
  project = { limit = 8, action = 'Telescope find_files cwd=' }, -- limit how many projects list, action when you press key or enter it will run this action.
  mru = { limit = 10 }, -- how many files in list
  footer = {}, -- footer
}
```

### Doom

when use `doom` theme the available options in `config` is

```lua
config = {
  header = {},
  center = {
    {
      icon = '',
      icon_hl = 'group',
      desc = 'description',
      desc_hl = 'group',
      key = 'shortcut key in dashboard buffer not keymap !!',
      key_hl = 'group',
      action = '',
    },
  },
  footer = {},
}
```

notice if you don't link config every highlight group. you can ignore this key.
dashboard will use default highlight group like `DashboardKey/Icon/Desc` instead

### Highlight

all highlight groups

```
DashboardHeader DashboardFooter DashboardProjectIcon
DashboardFiles DashboardRecentTitle DashboardRecentProject
DashboardDesc DashboardKey DashboardIcon DashboardShotCut
```

### Example config

example config of screenshot

<details>
<summary>Hyper<summary/>

```lua
  db.setup({
    theme = 'hyper',
    config = {
      shortcut = {
        { desc = ' Update', group = '@property', action = 'Lazy update', key = 'u' },
        {
          desc = ' Files',
          group = 'Label',
          action = 'Telescope find_files',
          key = 'f',
        },
        {
          desc = ' Apps',
          group = 'DiagnosticHint',
          action = 'Telescope app',
          key = 'a',
        },
        {
          desc = ' dotfiles',
          group = 'Number',
          action = 'Telescope dotfiles',
          key = 'd',
        },
      },
    },
  })
```
</details>

<details>
<summary> Doom </summary>

```lua
db.setup({
  theme = 'doom',
  config = {
    header = {}, --your header
    center = {
      {
        icon = ' ',
        icon_hi = 'Title',
        desc = 'Find File',
        desc_hi = 'String',
        key = 'b',
        key_hi = 'Number',
        action = 'lua print(2)'
      },
      {
        icon = ' ',
        icon_hi = 'Title',
        desc = 'Find Dotfiles',
        desc_hi = 'String',
        key = 'f',
        key_hi = 'Number',
        action = 'lua print(3)'
      },
    }
    footer = {}  --your footer
  }
})
```
</details

### Changed

- Removed Session as a start screen plugin speed is first.
- Removed Ueberzug script. since the ueberzug author delete the repo.

### TODO

- I will write a plugin to implement some popular terminal evaluators image protocol then I think
  can make it work with dashboard

# Backers

[@RakerZh](https://github.com/RakerZh)

# Donate

[![](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/bobbyhub)

If you'd like to support my work financially, buy me a drink through [paypal](https://paypal.me/bobbyhub)

# LICENSE

MIT
