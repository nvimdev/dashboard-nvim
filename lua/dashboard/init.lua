local api, fn = vim.api, vim.fn
local utils = require('dashboard.utils')
local ctx = {}
local db = {}

db.__index = db
db.__newindex = function(t, k, v)
  rawset(t, k, v)
end

local function cache_path()
  return utils.path_join(vim.fn.stdpath('cache'), 'dashboard_cache')
end

local function default_options()
  return {
    theme = 'classic',
    config = {},
    hide = {
      statusline = true,
      abline = true,
      winbar = true,
    },
    preview = {
      command = '',
      file_path = nil,
      file_height = 0,
      file_width = 0,
      image_width_pixel = 0,
      image_height_pixel = 0,
    },
    session = {
      enable = true,
      dir = '',
      auto_save_on_exit = false,
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

  if self.user_winbar_value then
    vim.opt_local.winbar = self.user_winbar_value
    self.user_winbar_value = nil
  end
end

-- cache the user options value restore after leave the dahsboard buffer
-- or use DashboardNewFile command
function db:cache_ui_options()
  if self.opts.hide.statusline then
    self.user_laststatus_value = vim.opt.laststatus:get()
    vim.opt.laststatus = 0
  end
  if self.opts.hide.tabline then
    self.user_tabline_value = vim.opt.tabline:get()
    vim.opt.showtabline = 0
  end
  if self.opts.hide.winbar then
    ---@diagnostic disable-next-line: undefined-field
    self.user_winbar_value = vim.opt.winbar:get()
    vim.opt.winbar = ''
  end

  api.nvim_create_autocmd('BufEnter', {
    callback = function(opt)
      local ignored = { 'prompt', 'nofile', 'terminal' }
      if vim.tbl_contains(ignored, vim.bo[opt.buf].buftype) then
        return
      end

      if self.user_winbar_value then
        vim.opt.winbar = self.user_winbar_value
      end

      if self.user_laststatus_value then
        vim.opt.laststatus = self.user_laststatus_value
      end

      if self.user_tabline_value then
        vim.opt.showtabline = self.user_tabline_value
      end
      pcall(api.nvim_del_autocmd, opt.id)
    end,
    desc = 'Dashboard resotre the options value',
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

  buf_local()
  self:cache_ui_options()

  local config = vim.tbl_extend(
    'force',
    self.opts.config,
    { path = cache_path(), bufnr = self.bufnr, winid = self.winid }
  )

  if #self.opts.preview.command > 0 then
    config = vim.tbl_extend('force', config, self.opts.preview)
  end

  require('dashboard.theme.' .. self.opts.theme)(config)
  api.nvim_create_autocmd('VimResized', {
    buffer = self.bufnr,
    callback = function()
      require('dashboard.theme.' .. self.opts.theme)(config)
      vim.bo[self.bufnr].modifiable = false
    end,
  })
end

function db.setup(opts)
  opts = opts or {}
  ctx.opts = vim.tbl_extend('force', default_options(), opts)
  if ctx.opts.session.enable then
    require('dashboard.session').command(ctx.opts.session)
  end
end

return setmetatable(ctx, db)
