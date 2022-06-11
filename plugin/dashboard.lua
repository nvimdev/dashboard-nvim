local api = vim.api

local db_autogroup = api.nvim_create_augroup('Dashboard',{})
api.nvim_create_autocmd('Vimenter',{
  group = db_autogroup,
  pattern = '*',
  nested = true,
  callback = function()
    if vim.fn.argc() >= 0 and vim.fn.line2byte('$') == -1 then
      require('dashboard').instance(true)
    end
  end
})

api.nvim_create_autocmd({'BufLeave'},{
  group = db_autogroup,
  pattern = '*',
  callback = function()
    local pos = api.nvim_win_get_cursor(0)
    api.nvim_win_set_var(0,'dashboard_prev_pos',pos)
  end
})

api.nvim_create_autocmd('WinLeave',{
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
    if require('dashboard').hide_statusline then
      vim.opt.laststatus = 0
    end
  end
})

api.nvim_create_autocmd('BufReadPost',{
  group = db_autogroup,
  pattern = '*',
  callback  = function()
    if vim.bo.filetype ~= 'dashboard' and vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus =2
    end
  end
})

api.nvim_create_user_command('Dashboard','lua require("dashboard").instance(false)<CR>',{})
