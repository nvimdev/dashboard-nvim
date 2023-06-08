local api, fn = vim.api, vim.fn
local util = require('dashboard.util')
local db = {}
local instance = {}

local function default_options()
  return {
    theme = 'hyper',
    change_to_vcs_root = true,
    hide = {
      statusline = true,
      tabline = true,
      cursorline = true,
    },
    theme_config = {},
    -- preview = {
    --   command = '',
    --   file_path = nil,
    --   file_height = 0,
    --   file_width = 0,
    -- },
  }
end

function db:new()
  local o = setmetatable({}, self)
  self.__index = self
  return o
end

local function buf_local()
  vim.opt_local.bufhidden = 'wipe'
  vim.opt_local.colorcolumn = ''
  vim.opt_local.foldcolumn = '0'
  vim.opt_local.matchpairs = ''
  vim.opt_local.buflisted = false
  vim.opt_local.cursorcolumn = false
  vim.opt_local.cursorline = false
  vim.opt_local.list = false
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.spell = false
  vim.opt_local.swapfile = false
  vim.opt_local.readonly = false
  vim.opt_local.filetype = 'dashboard'
  vim.opt_local.wrap = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.winbar = ''
  vim.opt_local.stc = ''
end

function db:hide_options(opts)
  if opts.hide.statusline then
    self.user_laststatus = util.get_global_option_value('laststatus')
    vim.opt.laststatus = 0
  end

  if opts.hide.tabline then
    self.user_tabline = util.get_global_option_value('showtabline')
    vim.opt.showtabline = 0
  end

  if opts.hide.cursorline then
    self.user_cursorline = util.get_global_option_value('cursorline')
  end
end

function db:restore_options()
  if self.user_cursorline then
    vim.opt.cursorline = self.user_cursorline
  end

  if self.user_laststatus then
    vim.opt.laststatus = tonumber(self.user_laststatus)
  end

  if self.user_tabline then
    vim.opt.showtabline = tonumber(self.user_tabline)
  end
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

  -- api.nvim_buf_set_name(self.bufnr, utils.gen_bufname(opts.buffer_name))

  if #opts.preview.command > 0 then
    config = vim.tbl_extend('force', config, opts.preview)
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
    self.bufnr = api.nvim_create_buf(false, true)
  else
    self.bufnr = api.nvim_get_current_buf()
  end

  self.winid = api.nvim_get_current_win()
  api.nvim_win_set_buf(self.winid, self.bufnr)

  buf_local()
end

local function render() end

local function setup(opts)
  local async = require('dashboard.async')
  print('start')
  async.async_read('/Users/mathew/workspace/test/a.ts', function(res)
    print(res)
  end)
  print('end')
end

return {
  setup = setup,
  render = render,
}
