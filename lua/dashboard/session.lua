local fn,api = vim.fn,vim.api
local db = require('dashboard')
local session = {}
local session_loaded = false

local project_name = function()
  local cwd = os.getenv('PWD')
  return cwd
end

function session.session_save(name)
  if fn.isdirectory(db.session_directory) == 0 then
    os.execute('mkdir -p' .. db.session_directory)
  end

  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory ..'/'..file_name ..'.vim'
  api.nvim_command('mksession!'..fn.fnameescape(file_path))
  vim.v.this_session = file_path
  vim.notify('Session '..file_name .. ' is now persistent')
end

function session.session_load(name)
  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. '/' .. file_name ..'.vim'

  if vim.v.this_session ~= nil and not session_loaded then
    api.nvim_command('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end

  if fn.filereadable(file_path) then
    vim.cmd [[ noautocmd silent! %bwipeout!]]
    api.nvim_command('silent! source ' .. file_path)

    if vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus = 2
    end

    vim.notify('Loaded '..file_path .. ' session')
    return
  end

  vim.notify('The session '..file_path .. ' does not exist')
end

function session.session_list()
  return fn.split(db.session_directory..'/*.vim','\n')
end

return session
