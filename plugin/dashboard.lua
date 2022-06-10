local api = vim.api

local db_autogroup = api.nvim_create_augroup('Dashboard',{})
api.nvim_create_autocmd('Vimenter',{
  group = db_autogroup,
  pattern = '*',
  nested = true,
  callback = function()
    require('dashboard').instance()
  end
})

api.nvim_create_autocmd({'WinLeave','BufReadPre'},{
  group = db_autogroup,
  pattern = '*',
  callback = function()
    if require('dashboard').hide_statusline then
      vim.opt.laststatus=2
    end
  end
})

api.nvim_create_user_command('Dashboard','lua require("dashboard").instance(false)<CR>',{})
