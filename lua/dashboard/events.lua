local api = vim.api
local au = {}
local db = require('dashboard')
local preview = require('dashboard.preview')

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

  api.nvim_create_autocmd({ 'BufWinEnter' }, {
    group = self.au_group,
    callback = function()
      if not_close[vim.bo.filetype] then
        if db.bufnr and api.nvim_buf_is_loaded(db.bufnr) then
          local winconfig = api.nvim_win_get_config(preview.winid)
          winconfig['col'][false] = vim.o.columns / 1.4
          api.nvim_win_set_config(preview.winid, winconfig)
        end
      end

      if not not_close[vim.bo.filetype] then
        require('dashboard.preview'):close_preview_window()
        -- neovim-qt requires that conditional
        if self.au_group then
          api.nvim_del_augroup_by_id(self.au_group)
        end
        self.au_group = nil
      end
    end,
  })

  if self.au_line == nil then
    self.au_line = api.nvim_create_augroup('dashboard_line_augroup', { clear = true })
  end

  api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = self.au_line,
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

      if self.au_line then
        api.nvim_del_augroup_by_id(self.au_line)
        self.au_line = nil
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
      db:instance(false, true)
    end,
  })
end

return au
