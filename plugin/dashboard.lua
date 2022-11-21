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
      if db_session.should_auto_save() then
        api.nvim_exec_autocmds('User', { pattern = 'DBSessionSavePre', modeline = false })
        db_session.session_save()
        api.nvim_exec_autocmds('User', { pattern = 'DBSessionSaveAfter', modeline = false })
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

api.nvim_create_user_command('SessionLoad', function(args)
  require('dashboard.session').session_load(args.args)
end, {
  nargs = '?',
  complete = require('dashboard.session').session_list,
})

api.nvim_create_user_command('SessionDelete', function()
  require('dashboard.session').session_delete()
end, {
  nargs = '?',
  complete = require('dashboard.session').session_list,
})
