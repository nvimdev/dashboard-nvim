local fn, api = vim.fn, vim.api
local utils = require('dashboard.utils')
local session = {}

local function output_msg(type)
  local msg_dict = {
    save = 'Session %s is now persistent',
    load = 'Loaded %s session',
    load_failed = 'The session %s does not exist',
    deleted = 'Session %s deleted',
    delete_failed = 'The session %s does not exist',
  }
  return msg_dict[type]
end

local function project_name()
  local cwd = fn.resolve(fn.getcwd())
  local path_sep = utils.is_windows and '\\' or '/'
  cwd = fn.substitute(cwd, '^' .. vim.env.HOME .. path_sep, '', '')
  if utils.is_windows then
    cwd = fn.fnamemodify(cwd, [[:p:gs?\?_?]])
    cwd = (string.gsub(cwd, 'C:', ''))
  else
    cwd = fn.fnamemodify(cwd, [[:p:gs?/?_?]])
  end
  cwd = fn.substitute(cwd, [[^\.]], '', '')
  return cwd
end

local function get_session_dir()
  local dir = require('dashboard').opts.session.dir
  if #dir == 0 then
    dir = utils.path_join(fn.stdpath('cache'), 'session')
  end
  return dir
end

local function session_save(name)
  local dir = get_session_dir()
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, 'p')
  end

  local file_name = name == nil and project_name() or name
  local file_path = utils.path_join(dir, file_name .. '.vim')
  api.nvim_command('mksession! ' .. fn.fnameescape(file_path))
  vim.v.this_session = file_path

  vim.notify(string.format(output_msg('save'), file_name), vim.log.levels.INFO)
end

local function convert_home_base()
  local dir = get_session_dir()
  if dir:find('^~/') then
    dir = vim.fs.normalize(dir)
  end
  return dir
end

local function session_load(name)
  local dir = convert_home_base()
  local file_path = (name and #name > 0) and name or utils.path_join(dir, project_name() .. '.vim')

  if vim.v.this_session ~= '' and fn.exists('g:SessionLoad') == 0 then
    api.nvim_command('mksession! ' .. fn.fnameescape(vim.v.this_session))
  end

  if fn.filereadable(file_path) == 1 then
    vim.cmd([[ noautocmd silent! %bwipeout!]])
    api.nvim_command('silent! source ' .. file_path)

    if vim.opt.laststatus:get() == 0 then
      vim.opt.laststatus = 2
    end

    vim.notify(string.format(output_msg('load'), file_path), vim.log.levels.INFO)
    return
  end

  vim.notify(string.format(output_msg('load_failed'), file_path), vim.log.levels.ERROR)
end

local function path_in_session(fname)
  local dir = convert_home_base()
  return utils.path_join(dir, fname .. '.vim')
end

local function session_exists(name)
  local file_name = name == nil and project_name() or name
  local file_path = path_in_session(file_name)

  return fn.filereadable(file_path) == 1
end

local function session_delete(name)
  local file_name = not name and project_name() or name
  local file_path = path_in_session(file_name)

  if fn.filereadable(file_path) == 1 then
    fn.delete(file_path)
    vim.notify(string.format(output_msg('deleted'), file_name), vim.log.levels.INFO)
    return
  end

  vim.notify(string.format(output_msg('delete_failed'), file_name), vim.log.levels.ERROR)
end

local function session_list()
  local dir = convert_home_base()
  return vim.split(fn.globpath(dir, '*.vim'), '\n')
end

function session.command(opt)
  if opt.auto_save_on_exit then
    local function should_auto_save()
      return opt.session_auto_save_on_exit and session_exists()
    end

    api.nvim_create_autocmd('VimLeavePre', {
      group = api.nvim_create_augroup('session_auto_save', { clear = true }),
      callback = function()
        if should_auto_save() then
          api.nvim_exec_autocmds('User', { pattern = 'DBSessionSavePre', modeline = false })
          session_save()
          api.nvim_exec_autocmds('User', { pattern = 'DBSessionSaveAfter', modeline = false })
        end
      end,
    })
  end

  api.nvim_create_user_command('SessionSave', function()
    session_save()
  end, {
    nargs = '?',
    complete = session_list,
  })

  api.nvim_create_user_command('SessionLoad', function(args)
    session_load(args.args)
  end, {
    nargs = '?',
    complete = session_list,
  })

  api.nvim_create_user_command('SessionDelete', function()
    session_delete()
  end, {
    nargs = '?',
    complete = session_list,
  })
end

return session
