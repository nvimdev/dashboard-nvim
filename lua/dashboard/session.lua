local fn, api, loop = vim.fn, vim.api, vim.loop
local db = require('dashboard')
local is_windows = #vim.fn.windowsversion() > 0
local path_sep = is_windows and '\\' or '/'
local session = {}
local home = loop.os_homedir()
local session_cp_name

local project_name = function()
  local cwd = fn.resolve(fn.getcwd())
  cwd = fn.substitute(cwd, '^' .. home .. path_sep, '', '')
  if is_windows then
    cwd = fn.fnamemodify(cwd, [[:p:gs?\?_?]])
    cwd = (string.gsub(cwd, 'C:', ''))
  else
    cwd = fn.fnamemodify(cwd, [[:p:gs?/?_?]])
  end
  cwd = fn.substitute(cwd, [[^\.]], '', '')
  return cwd
end

if is_windows then
  -- overwrite db.session_directory for Windows in this file
  db.session_directory = string.gsub(db.session_directory, '/', '\\')
end

function session.session_save(name)
  if fn.isdirectory(db.session_directory) == 0 then
    fn.mkdir(db.session_directory, 'p')
  end

  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. path_sep .. file_name .. '.vim'
  api.nvim_command('mksession! ' .. fn.fnameescape(file_path))
  vim.v.this_session = file_path

  if db.session_verbose then
    vim.notify('Session ' .. file_name .. ' is now persistent')
  else
    vim.notify('This session is now persistent')
  end
  session_cp_name = project_name()
end

function session.session_load(name)
  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. path_sep .. file_name .. '.vim'

  if vim.v.this_session ~= '' and fn.exists('g:SessionLoad') == 0 then
    api.nvim_command('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end

  if fn.filereadable(file_path) == 1 then
    vim.cmd([[ noautocmd silent! %bwipeout!]])
    api.nvim_command('silent! source ' .. file_path)

    if vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus = 2
    end

    if db.session_verbose then
      vim.notify('Loaded ' .. file_path .. ' session')
    else
      vim.notify('Session loaded')
    end
    session_cp_name = project_name()
    return
  end

  if db.session_verbose then
    vim.notify('The session ' .. file_path .. ' does not exist')
  else
    vim.notify('No saved session for this directory')
  end
end

function session.session_exists(name)
  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. path_sep .. file_name .. '.vim'

  return fn.filereadable(file_path) == 1
end

function session.session_delete(name)
  local file_name = not name and project_name() or name
  local file_path = db.session_directory .. path_sep .. file_name .. '.vim'

  if fn.filereadable(file_path) == 1 then
    fn.delete(file_path)
    if db.session_verbose then
      vim.notify('Session ' .. file_name .. ' deleted')
    else
      vim.notify('Session deleted')
    end
    return
  end

  if db.session_verbose then
    vim.notify('The session ' .. file_path .. ' does not exist')
  else
    vim.notify('No saved session for this directory')
  end
end

function session.should_auto_save()
  return db.session_auto_save_on_exit and session.session_exists()
      and session_cp_name == project_name()
end

function session.session_list()
  return vim.split(fn.globpath(db.session_directory, '*.vim'), '\n')
end

return session
