local api = vim.api
local db = require('dashboard')
local db_session = require('dashboard.session')

local dashboard_start = api.nvim_create_augroup('dashboard_start', { clear = true })

api.nvim_create_autocmd('Vimenter', {
  group = dashboard_start,
  nested = true,
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 and not db.disable_at_vimenter then
      db:instance(true)
    end
  end,
})

api.nvim_create_autocmd('FileType', {
  group = dashboard_start,
  pattern = 'dashboard',
  callback = function()
    if db.hide_statusline then
      vim.opt.laststatus = 0
    end

    if db.hide_tabline then
      vim.opt.showtabline = 0
    end

    if vim.fn.has('nvim-0.8') == 1 then
      if db.hide_winbar then
        vim.opt.winbar = ''
      end
    end
  end,
})

if db.session_auto_save_on_exit then
  local session_auto_save = api.nvim_create_augroup('session_auto_save', { clear = true })

  api.nvim_create_autocmd('VimLeavePre', {
    group = session_auto_save,
    callback = function()
      if db_session.session_exists() and vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 })) > 1 then
        if type(db.session_auto_save_pre) == 'function' then
          db.session_auto_save_pre()
        end
        db_session.session_save()
        if type(db.db.session_auto_save_after) == 'function' then
          db.session_auto_save_after()
        end
      end
    end,
  })
end

api.nvim_create_user_command('Dashboard', function()
  require('dashboard'):instance(false)
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
