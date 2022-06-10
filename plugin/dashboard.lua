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

api.nvim_create_autocmd({'WinLeave'},{
  group = db_autogroup,
  pattern = '*',
  callback = function()
    require('dashboard.preview').close_preview_window()
  end
})

api.nvim_create_autocmd('FileType',{
  group = db_autogroup,
  pattern = 'dashboard',
  callback = function()
    if vim.bo.filetype == 'dashboard' and require('dashboard').hide_statusline then
      vim.opt.laststatus = 0
    end
  end
})

api.nvim_create_autocmd({'BufLeave','BufWinEnter'},{
  group = db_autogroup,
  pattern ='*',
  callback = function()
    if vim.opt.laststatus == 0 then print('here')vim.opt.laststatus = 2 end
  end
})

api.nvim_create_user_command('Dashboard','lua require("dashboard").instance(false)<CR>',{})
