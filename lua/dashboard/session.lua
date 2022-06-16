local fn, api = vim.fn, vim.api
local db = require('dashboard')
local session = {}
local session_loaded = false

function DirectoryConverter(directory)
  -- replace '/' of db.session_directory to '\' for Windows
  if vim.loop.os_uname().sysname == 'Windows_NT' then
    return ((string.gsub(directory, '/', '\\')))
  else
    return directory
  end
end

function FilenameConverter(filename)
  -- replace '\' and 'C:\' to '_' and '' for Windows
  if vim.loop.os_uname().sysname == 'Windows_NT' then
    filename = ((string.gsub(filename, 'C:\\', '')))
    return ((string.gsub(filename, '\\', '_')))
  elseif vim.loop.os_uname().sysname == "Linux" then
    return ((string.gsub(filename, '/', '_')))
  else
    return filename
  end
end

local project_name = function()
  return FilenameConverter(vim.fn.getcwd())
end

local session_directory = DirectoryConverter(db.session_directory)

function session.session_save(name)
  print(session_directory)
  if fn.isdirectory(session_directory) == 0 then
    vim.cmd(':!mkdir ' .. session_directory)
  end

  local file_name = name == nil and project_name() or name
  local file_path = DirectoryConverter(session_directory .. '/' .. file_name .. '.vim')

  api.nvim_command('mksession!' .. fn.fnameescape(file_path))
  vim.v.this_session = file_path
  vim.notify('Session ' .. file_name .. ' is now persistent')
end

function session.session_load(name)
  local file_name = name == nil and project_name() or name
  local file_path = DirectoryConverter(session_directory .. '/' .. file_name .. '.vim')

  if vim.v.this_session ~= nil and not session_loaded then
    api.nvim_command('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end

  if fn.filereadable(file_path) then
    vim.cmd [[ noautocmd silent! %bwipeout!]]
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
  return fn.split(session_directory .. '/*.vim', '\n')
end

return session
