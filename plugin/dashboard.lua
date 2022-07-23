local api = vim.api
local db = require('dashboard')

local db_autogroup = api.nvim_create_augroup('Dashboard', {})
api.nvim_create_autocmd('Vimenter', {
  group = db_autogroup,
  pattern = '*',
  nested = true,
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
      db.instance(true)
    end
  end,
})

api.nvim_create_autocmd({ 'BufLeave' }, {
  group = db_autogroup,
  pattern = '*',
  callback = function()
    local pos = api.nvim_win_get_cursor(0)
    api.nvim_win_set_var(0, 'dashboard_prev_pos', pos)
  end,
})

api.nvim_create_autocmd({ 'WinLeave', 'BufEnter' }, {
  group = db_autogroup,
  pattern = '*',
  callback = function()
    require('dashboard.preview').close_preview_window()
  end,
})

api.nvim_create_autocmd('FileType', {
  group = db_autogroup,
  pattern = 'dashboard',
  callback = function()
    if db.hide_statusline then
      vim.opt.laststatus = 0
    end

    if db.hide_tabline then
      vim.opt.showtabline = 0
    end
  end,
})

api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group = db_autogroup,
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'dashboard' then
      return
    end
    if vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus = db.user_laststatus_value
    end

    if vim.opt.showtabline:get() == 0 then
      vim.opt.showtabline = db.user_showtabline_value
    end
  end,
})

api.nvim_create_user_command('Dashboard', function()
  require('dashboard').instance(false)
end, {})

api.nvim_create_user_command('DashboardNewFile', function()
  require('dashboard').new_file()
end, {})

api.nvim_create_user_command('SessionSave', function()
  require('dashboard.session').session_save()
end, {
  nargs = '?',
  complete = require('dashboard.session').session_list,
})

api.nvim_create_user_command('SessionLoad', function()
  require('dashboard.session').session_load()
end, {
  nargs = '?',
  complete = require('dashboard.session').session_list,
})
