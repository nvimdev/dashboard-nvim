local api = vim.api
local au = {}
local db = require('dashboard')

local not_close = {
  ['packer'] = true,
  ['NvimTree'] = true,
  ['NeoTree'] = true,
  ['dashboard'] = true,
  ['dashboardpreview'] = true,
}

function au:dashboard_events()
  if not self.au_group then
    self.au_group = api.nvim_create_augroup('dashboard-nvim', { clear = true })
  end

  api.nvim_create_autocmd({ 'BufEnter' }, {
    group = self.au_group,
    pattern = '*',
    callback = function()
      if not not_close[vim.bo.filetype] then
        require('dashboard.preview'):close_preview_window()
        api.nvim_del_augroup_by_id(self.au_group)
        self.au_group = nil
      end
    end,
  })

  api.nvim_create_autocmd('FileType', {
    group = self.au_group,
    pattern = 'dashboard',
    callback = function()
      if db.hide_statusline then
        vim.opt.laststatus = 0
      end

      if db.hide_tabline then
        vim.opt.showtabline = 0
      end
    end,
  })

  api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = self.au_group,
    callback = function()
      if vim.bo.filetype == 'dashboard' then
        return
      end
      if vim.opt.laststatus:get() == 0 then
        vim.opt.laststatus = db.user_laststatus_value
      end

      if vim.opt.showtabline:get() == 0 then
        vim.opt.showtabline = db.user_showtabline_value
      end
    end,
  })

  api.nvim_create_autocmd('VimResized', {
    group = self.au_group,
    callback = function()
      if vim.bo.filetype ~= 'dashboard' then
        return
      end
      require('dashboard.preview'):close_preview_window()
      vim.opt_local.modifiable = true
      if db.cursor_moved_id ~= nil then
        api.nvim_del_augroup_by_id(db.cursor_moved_id)
        db.cursor_moved_id = nil
      end
      db.instance(false, true)
    end,
  })
end

return au
