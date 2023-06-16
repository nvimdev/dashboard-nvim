local api, fn = vim.api, vim.fn
local nvim_create_autocmd = api.nvim_create_autocmd
local opt_local = vim.opt_local
local util = require('dashboard.util')
local entry = require('dashboard.entry')
local asmod = require('dashboard.async')

local function buf_local()
  opt_local.bufhidden = 'wipe'
  opt_local.colorcolumn = ''
  opt_local.foldcolumn = '0'
  opt_local.matchpairs = ''
  opt_local.buflisted = false
  opt_local.cursorcolumn = false
  opt_local.cursorline = false
  opt_local.list = false
  opt_local.number = false
  opt_local.relativenumber = false
  opt_local.spell = false
  opt_local.swapfile = false
  opt_local.readonly = false
  opt_local.filetype = 'dashboard'
  opt_local.wrap = false
  opt_local.signcolumn = 'no'
  opt_local.winbar = ''
  opt_local.stc = ''
end

local function hide_options(hide)
  local tbl = {}

  if hide.statusline then
    tbl.laststatus = util.get_global_option_value('laststatus')
    vim.opt.laststatus = 0
  end

  if hide.tabline then
    tbl.showtabline = util.get_global_option_value('showtabline')
    vim.opt.showtabline = 0
  end

  if hide.cursorline then
    tbl.cursorline = util.get_global_option_value('cursorline')
  end

  return function()
    for option, val in pairs(tbl) do
      vim.opt[option] = val
    end
  end
end

-- create dashboard instance
local function instance(opt)
  local mode = api.nvim_get_mode().mode
  if mode == 'i' or not vim.bo.modifiable then
    return
  end

  if not vim.o.hidden and vim.bo.modified then
    --save before open
    vim.cmd.write()
    return
  end

  local bufnr
  if vim.fn.line2byte('$') ~= -1 then
    bufnr = api.nvim_create_buf(false, true)
  else
    bufnr = api.nvim_get_current_buf()
  end

  local winid = api.nvim_get_current_win()
  api.nvim_win_set_buf(winid, bufnr)

  buf_local()

  local theme = require('dashboard.theme.' .. opt.theme)
  if not theme or not theme.init then
    vim.notify(
      ('[Dashboard] Load theme error missed theme %s or %s.init function'):format(
        opt.theme,
        opt.theme
      ),
      vim.log.levels.ERROR
    )
    return
  end
  local restore = hide_options(opt.hide)
  local e = entry:new({ winid = winid, bufnr = bufnr })
  asmod.async(function()
    e = asmod.await(theme.init(e, opt.theme_config))
  end)()

  api.nvim_create_autocmd('VimResized', {
    buffer = bufnr,
    callback = function()
      require('dashboard.theme.' .. opt.theme).init(entry, opt.theme_config)
      vim.bo[bufnr].modifiable = false
    end,
  })

  nvim_create_autocmd('BufLeave', {
    buffer = bufnr,
    callback = function()
      restore()
    end,
  })
end

local function setup(opt)
  local default = {
    theme = 'doom',
    change_to_vcs_root = true,
    hide = {
      statusline = true,
      tabline = true,
      cursorline = true,
    },
    theme_config = {},
  }
  opt = vim.tbl_extend('force', default, opt or {})
  if #opt.theme == 0 then
    vim.notify('[Dashboard] Please config a theme ', vim.log.levels.WARN)
    return
  end

  nvim_create_autocmd('UIEnter', {
    group = vim.api.nvim_create_augroup('Dashboard', { clear = true }),
    callback = function()
      if fn.argc() == 0 and fn.line2byte('$') == -1 then
        instance(opt)
      end
    end,
  })
end

return {
  setup = setup,
}
