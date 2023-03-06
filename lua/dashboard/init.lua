local api, fn = vim.api, vim.fn
local utils = require('dashboard.utils')
local ctx = {}
local db = {}

db.__index = db
db.__newindex = function(t, k, v)
  rawset(t, k, v)
end

local function clean_ctx()
  for k, _ in pairs(ctx) do
    ctx[k] = nil
  end
end

local function cache_dir()
  local dir = utils.path_join(vim.fn.stdpath('cache'), 'dashboard')
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, 'p')
  end
  return dir
end

local function cache_path()
  local dir = cache_dir()
  return utils.path_join(dir, 'cache')
end

local function conf_cache_path()
  return utils.path_join(cache_dir(), 'conf')
end

local function default_options()
  return {
    theme = 'hyper',
    disable_move = false,
    shortcut_type = 'letter',
    change_to_vcs_root = false,
    buffer_name = 'Dashboard',
    config = {
      week_header = {
        enable = false,
        concat = nil,
        append = nil,
      },
    },
    hide = {
      statusline = true,
      tabline = true,
    },
    preview = {
      command = '',
      file_path = nil,
      file_height = 0,
      file_width = 0,
    },
  }
end

local function buf_local()
  local opts = {
    ['bufhidden'] = 'wipe',
    ['colorcolumn'] = '',
    ['foldcolumn'] = '0',
    ['matchpairs'] = '',
    ['buflisted'] = false,
    ['cursorcolumn'] = false,
    ['cursorline'] = false,
    ['list'] = false,
    ['number'] = false,
    ['relativenumber'] = false,
    ['spell'] = false,
    ['swapfile'] = false,
    ['filetype'] = 'dashboard',
    ['buftype'] = 'nofile',
    ['wrap'] = false,
    ['signcolumn'] = 'no',
    ['winbar'] = '',
  }
  for opt, val in pairs(opts) do
    vim.opt_local[opt] = val
  end
  if fn.has('nvim-0.9') == 1 then
    vim.opt_local.stc = ''
  end
end

function db:new_file()
  vim.cmd('enew')
  if self.user_laststatus_value then
    vim.opt_local.laststatus = self.user_laststatus_value
    self.user_laststatus_value = nil
  end

  if self.user_tabline_value then
    vim.opt_local.showtabline = self.user_showtabline_value
    self.user_showtabline_value = nil
  end
end

-- cache the user options value restore after leave the dahsboard buffer
-- or use DashboardNewFile command
function db:cache_ui_options(opts)
  if opts.hide.statusline then
    self.user_laststatus_value = vim.opt.laststatus:get()
    vim.opt.laststatus = 0
  end
  if opts.hide.tabline then
    self.user_tabline_value = vim.opt.showtabline:get()
    vim.opt.showtabline = 0
  end
end

function db:restore_options()
  if self.user_cursor_line then
    vim.opt.cursorline = self.user_cursor_line
    self.user_cursor_line = nil
  end

  if self.user_laststatus_value then
    vim.opt.laststatus = tonumber(self.user_laststatus_value)
    self.user_laststatus_value = nil
  end

  if self.user_tabline_value then
    vim.opt.showtabline = tonumber(self.user_tabline_value)
    self.user_tabline_value = nil
  end
end

function db:cache_opts()
  if not self.opts then
    return
  end
  local uv = vim.loop
  local path = conf_cache_path()
  if self.opts.config.shortcut then
    for _, item in pairs(self.opts.config.shortcut) do
      if type(item.action) == 'function' then
        ---@diagnostic disable-next-line: param-type-mismatch
        local dump = assert(string.dump(item.action))
        item.action = dump
      end
    end
  end

  if self.opts.config.project and type(self.opts.config.project.action) == 'function' then
    ---@diagnostic disable-next-line: param-type-mismatch
    local dump = assert(string.dump(self.opts.config.project.action))
    self.opts.config.project.action = dump
  end

  if self.opts.config.center then
    for _, item in pairs(self.opts.config.center) do
      if type(item.action) == 'function' then
        ---@diagnostic disable-next-line: param-type-mismatch
        local dump = assert(string.dump(item.action))
        item.action = dump
      end
    end
  end

  if self.opts.config.footer and type(self.opts.config.footer) == 'function' then
    ---@diagnostic disable-next-line: param-type-mismatch
    local dump = assert(string.dump(self.opts.config.footer))
    self.opts.config.footer = dump
  end

  local dump = vim.json.encode(self.opts)
  uv.fs_open(path, 'w+', tonumber('664', 8), function(err, fd)
    assert(not err, err)
    ---@diagnostic disable-next-line: redefined-local
    uv.fs_write(fd, dump, 0, function(err, _)
      assert(not err, err)
      uv.fs_close(fd)
    end)
  end)
end

function db:get_opts(callback)
  utils.async_read(
    conf_cache_path(),
    vim.schedule_wrap(function(data)
      if not data or #data == 0 then
        return
      end
      local obj = vim.json.decode(data)
      if obj then
        callback(obj)
      end
    end)
  )
end

local function get_unique_buffer_name(opts)
  local name2 = string.format(opts.buffer_name, 1)

  if -1 == vim.fn.bufnr(name2) then
    return name2
  end

  for i = 2, 9999, 1 do
    local name2 = string.format(opts.buffer_name, i)
    if name2 == opts.buffer_name then
      name2 = opts.buffer_name .. '-' .. i
    end

    if -1 == vim.fn.bufnr(name2) then
      return name2
    end
  end

  -- if we are here, then it is bad ... but chances of getting here are very low
  error('Unable to find unique name for the dashboard buffer')
end

function db:load_theme(opts)
  local config = vim.tbl_extend('force', opts.config, {
    path = cache_path(),
    bufnr = self.bufnr,
    winid = self.winid,
    confirm_key = opts.confirm_key or nil,
    shortcut_type = opts.shortcut_type,
    change_to_vcs_root = opts.change_to_vcs_root,
  })

  vim.api.nvim_buf_set_name(self.bufnr, get_unique_buffer_name(opts))

  if #opts.preview.command > 0 then
    config = vim.tbl_extend('force', config, self.opts.preview)
  end

  require('dashboard.theme.' .. opts.theme)(config)
  self:cache_ui_options(opts)

  api.nvim_create_autocmd('VimResized', {
    buffer = self.bufnr,
    callback = function()
      require('dashboard.theme.' .. opts.theme)(config)
      vim.bo[self.bufnr].modifiable = false
    end,
  })

  api.nvim_create_autocmd('BufEnter', {
    callback = function(opt)
      local bufs = api.nvim_list_bufs()
      bufs = vim.tbl_filter(function(k)
        return vim.bo[k].filetype == 'dashboard'
      end, bufs)
      if #bufs == 0 then
        self:cache_opts()
        self:restore_options()
        clean_ctx()
        pcall(api.nvim_del_autocmd, opt.id)
      end
    end,
    desc = '[Dashboard] clean dashboard data reduce memory',
  })
end

-- create dashboard instance
function db:instance()
  local mode = api.nvim_get_mode().mode
  if mode == 'i' or not vim.bo.modifiable then
    return
  end

  if not vim.o.hidden and vim.bo.modified then
    --save before open
    vim.cmd.write()
    return
  end

  if vim.fn.line2byte('$') ~= -1 then
    vim.cmd('noautocmd')
    self.bufnr = api.nvim_create_buf(true, true)
  else
    self.bufnr = api.nvim_get_current_buf()
  end

  self.winid = api.nvim_get_current_win()
  api.nvim_win_set_buf(self.winid, self.bufnr)

  self.user_cursor_line = vim.opt.cursorline:get()
  buf_local()
  if self.opts then
    self:load_theme(self.opts)
  else
    self:get_opts(function(obj)
      self:load_theme(obj)
    end)
  end
end

function db.setup(opts)
  opts = opts or {}
  ctx.opts = vim.tbl_deep_extend('force', default_options(), opts)
end

return setmetatable(ctx, db)
