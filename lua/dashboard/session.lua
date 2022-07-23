local fn, api, loop = vim.fn, vim.api, vim.loop
local db = require('dashboard')
local session = {}
local home = loop.os_homedir()

local isWindows = function()
  if loop.os_uname().sysname == 'Windows_NT' then
    return true
  else
    return false
  end
end

local project_name = function()
  local cwd = fn.resolve(fn.getcwd())
  cwd = fn.substitute(cwd, '^' .. home .. '/', '', '')
  if isWindows() then
    cwd = fn.fnamemodify(cwd, [[:p:gs?\?_?]])
    cwd = (string.gsub(cwd, 'C:', ''))
  else
    cwd = fn.fnamemodify(cwd, [[:p:gs?/?_?]])
  end
  cwd = fn.substitute(cwd, [[^\.]], '', '')
  return cwd
end

if isWindows() then
  -- overwrite db.session_directory for Windows in this file
  db.session_directory = string.gsub(db.session_directory, '/', '\\')
end

function session.session_save(name)
  if fn.isdirectory(db.session_directory) == 0 then
    fn.mkdir(db.session_directory, 'p')
  end

  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. '/' .. file_name .. '.vim'
  api.nvim_command('mksession! ' .. fn.fnameescape(file_path))
  vim.v.this_session = file_path
  vim.notify('Session ' .. file_name .. ' is now persistent')
end

function session.session_load(name)
  local file_name = name == nil and project_name() or name
  local file_path = db.session_directory .. '/' .. file_name .. '.vim'

  if vim.v.this_session ~= '' and fn.exists('g:SessionLoad') == 0 then
    api.nvim_command('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end

  if fn.filereadable(file_path) then
    vim.cmd([[ noautocmd silent! %bwipeout!]])
    api.nvim_command('silent! source ' .. file_path)

    if vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus = 2
    end

    vim.notify('Loaded ' .. file_path .. ' session')
    return
  end

  vim.notify('The session ' .. file_path .. ' does not exist')
end

function session.session_list()
  return vim.split(fn.globpath(db.session_directory, '*.vim'), '\n')
end

return session
