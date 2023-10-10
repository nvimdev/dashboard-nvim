local api = vim.api
local db = require('dashboard')

local view = {}

function view:open_window(opt)
  local row = math.floor(opt.height / 5)
  local col = math.floor((vim.o.columns - opt.width) / 2)

  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = opt.width,
    height = opt.height,
    style = 'minimal',
    noautocmd = true,
  }

  self.bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(self.bufnr, 'filetype', 'dashboardpreview')
  self.winid = api.nvim_open_win(self.bufnr, false, opts)
  if vim.fn.has('nvim-0.8') == 1 then
    local normal = api.nvim_get_hl_by_name('Normal', true)
    pcall(api.nvim_set_hl, 0, 'DashboardPreview', normal)
  else
    api.nvim_set_hl(0, 'DashboardPreview', { bg = 'none' })
  end
  api.nvim_win_set_option(self.winid, 'winhl', 'Normal:DashboardPreview')
  return { self.bufnr, self.winid }
end

function view:close_preview_window()
  if self.bufnr and api.nvim_buf_is_loaded(self.bufnr) then
    api.nvim_buf_delete(self.bufnr, { force = true })
    self.bufnr = nil
  end

  if self.winid and api.nvim_win_is_valid(self.winid) then
    api.nvim_win_close(self.winid, true)
    self.winid = nil
  end
end

function view:preview_events()
  local group =
    api.nvim_create_augroup('DashboardClosePreview' .. self.preview_bufnr, { clear = true })

  --refresh the preview window col position.
  local function refresh_preview_wincol()
    if not self.preview_winid or not api.nvim_win_is_valid(self.preview_winid) then
      return
    end

    local winconfig = api.nvim_win_get_config(self.preview_winid)
    local cur_width = api.nvim_win_get_width(self.main_winid)
    if cur_width ~= self.win_width then
      local wins = api.nvim_list_wins()
      if #wins == 2 then
        local scol = bit.rshift(vim.o.columns, 1) - bit.rshift(winconfig.width, 1)
        winconfig.col[false] = scol
        api.nvim_win_set_config(self.preview_winid, winconfig)
        self.win_width = cur_width
        return
      end

      if #wins == 3 then
        local new_win = vim.tbl_filter(function(k)
          return k ~= self.main_winid and k ~= self.preview_winid
        end, wins)[1]
        winconfig.col[false] = winconfig.col[false] + api.nvim_win_get_width(new_win)
        api.nvim_win_set_config(self.preview_winid, winconfig)
        self.win_width = cur_width
      end
    end
  end

  local function winresized()
    api.nvim_create_autocmd('WinResized', {
      group = group,
      callback = function()
        refresh_preview_wincol()
      end,
      desc = ' Dashboard preview window resized for nvim 0.9',
    })
  end

  api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      refresh_preview_wincol()
    end,
  })

  if vim.fn.has('nvim-0.9') == 1 then
    winresized()
  else
    ---@deprecated when 0.9 version release remove
    api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function()
        refresh_preview_wincol()
      end,
      desc = 'dashboard preview window resize for neovim 0.8+ version',
    })
  end
end

function view:open_preview(opt)
  self.preview_bufnr, self.preview_winid = unpack(view:open_window(opt))

  api.nvim_buf_call(self.preview_bufnr, function()
    vim.fn.termopen(opt.cmd, {
      on_exit = function() end,
    })
  end)
  self.main_winid = api.nvim_get_current_win()
  self.win_width = api.nvim_win_get_width(self.main_winid)

  api.nvim_create_autocmd('BufWipeout', {
    buffer = db.bufnr,
    callback = function()
      if self.winid and api.nvim_win_is_valid(self.preview_winid) then
        api.nvim_win_close(self.preview_winid, true)
        self.preview_winid = nil
        self.preview_bufnr = nil
        self.main_winid = nil
        self.win_width = nil
      end
    end,
    once = true,
    desc = 'make preview have same lifetime with dashboard buffer',
  })

  self:preview_events()
end

return view
