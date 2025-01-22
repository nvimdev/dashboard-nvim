<h1 align="center">
  Fancy and Blazing Fast start screen plugin of neovim
</h1>

| <center>Hyper</center> | <center>Doom</center> |
| ---   | ---   |
| <center><img src="https://user-images.githubusercontent.com/41671631/215015845-b13343c4-427e-45d6-9f92-267ab909eff1.png" width=80% height=80%/></center>|<center> <img src="https://user-images.githubusercontent.com/41671631/214518543-d7d6afbf-f405-4a6f-a505-568c5a101e92.png" width=80% height=80%/> </center>|

# Feature

- Low memory usage. dashboard does not store the all user configs in memory like header etc these string will take some memory. now it will be clean after you open a file. you can still use dashboard command to open a new one , then dashboard will read the config from cache.
- Blazing fast


# Install

- Lazy.nvim

```lua
{
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
}
```

- Packer

```lua
use {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  requires = {'nvim-tree/nvim-web-devicons'}
}
```

# Configuration

## Options

```lua
theme = 'hyper'    -- theme is doom and hyper default is hyper
disable_move       -- default is false disable move keymap for hyper
shortcut_type      -- shortcut type 'letter' or 'number'
shuffle_letter     -- default is false, shortcut 'letter' will be randomize, set to false to have ordered letter
letter_list        -- default is a-z, excluding j and k
change_to_vcs_root -- default is false,for open file in hyper mru. it will change to the root of vcs
config = {},       -- config used for theme
hide = {
  statusline       -- hide statusline default is true
  tabline          -- hide the tabline
  winbar           -- hide winbar
},
preview = {
  command          -- preview command
  file_path        -- preview file path
  file_height      -- preview file height
  file_width       -- preview file width
},
```

## Theme config

the `config` field is used for theme. general field

```lua
config = {
  header -- type is table def
  week_header = {
    enable  --boolean use a week header
    concat  --concat string after time string line
    append  --table append after time string line
  },
  disable_move  -- boolean default is false disable move key
}
```

### Hyper

when use `hyper` theme the available options in `config` is

```lua
config = {
  shortcut = {
    -- action can be a function type
    { desc = string, group = 'highlight group', key = 'shortcut key', action = 'action when you press key' },
  },
  packages = { enable = true }, -- show how many plugins neovim loaded
  -- limit how many projects list, action when you press key or enter it will run this action.
  -- action can be a function type, e.g.
  -- action = func(path) vim.cmd('Telescope find_files cwd=' .. path) end
  project = { enable = true, limit = 8, icon = 'your icon', label = '', action = 'Telescope find_files cwd=' },
  mru = { enable = true, limit = 10, icon = 'your icon', label = '', cwd_only = false },
  footer = {}, -- footer
}
```

### Doom

when use `doom` theme the available options in `config` is

```lua
config = {
  center = {
    {
      icon = '',
      icon_hl = 'group',
      desc = 'description',
      desc_hl = 'group',
      key = 'shortcut key in dashboard buffer not keymap !!',
      key_hl = 'group',
      key_format = ' [%s]', -- `%s` will be substituted with value of `key`
      action = '',
    },
  },
  footer = {},
  vertical_center = false, -- Center the Dashboard on the vertical (from top to bottom)
}
```

notice if you don't link config every highlight group. you can ignore this key.
dashboard will use default highlight group like `DashboardKey/Icon/Desc` instead

### Commands

- `Dashboard` open dashboard
- `DbProjectDelete count` delete project in cache works for hyper theme. count is number
- `DashboardUpdateFooter` updates the content of the Footer

### Highlight

all highlight groups

```
-- General
DashboardHeader DashboardFooter
-- Hyper theme
DashboardProjectTitle DashboardProjectTitleIcon DashboardProjectIcon
DashboardMruTitle DashboardMruIcon DashboardFiles DashboardShortCutIcon
-- Doom theme
DashboardDesc DashboardKey DashboardIcon DashboardShortCut
```

### Example config

example config of screenshot

<details>
<summary> Hyper </summary>

```lua
  db.setup({
    theme = 'hyper',
    config = {
      week_header = {
       enable = true,
      },
      shortcut = {
        { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
        {
          icon = ' ',
          icon_hl = '@variable',
          desc = 'Files',
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
        icon_hl = 'Title',
        desc = 'Find File           ',
        desc_hl = 'String',
        key = 'b',
        keymap = 'SPC f f',
        key_hl = 'Number',
        key_format = ' %s', -- remove default surrounding `[]`
        action = 'lua print(2)'
      },
      {
        icon = ' ',
        desc = 'Find Dotfiles',
        key = 'f',
        keymap = 'SPC f d',
        key_format = ' %s', -- remove default surrounding `[]`
        action = 'lua print(3)'
      },
    },
    footer = {}  --your footer
  }
})
```
</details

### Changed

- Removed Session as a start screen plugin speed is first.if you want use session you can take a
  look at [glepnir/dbsession.nvim](https://github.com/glepnir/dbsession.nvim)
- Removed Ueberzug script, as the Ueberzug author has deleted the repository.

### TODO

- I will write a plugin to implement some popular terminal evaluators image protocol then I think
  can make it work with dashboard

# Backers

[@RakerZh](https://github.com/RakerZh)

# Donate

If you'd like to support my work financially, buy me a drink through Github Sponsor or [![](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/bobbyhub)


# LICENSE

MIT
