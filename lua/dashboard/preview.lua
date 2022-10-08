local uv = vim.loop
local api = vim.api
local db = require('dashboard')
local space = ' '

local width = db.preview_file_width
local height = db.preview_file_height
local row, col

local get_script_path = function()
  local str = debug.getinfo(2, 'S').source:sub(2)
  local path = str:match('(.*/).*/.*/')

  if path == nil then
    error('Does not find the dashboard dir')
    return
  end
  return path .. 'scripts/'
end

local view = {}

function view:open_window()
  row = math.floor(height / 5)
  local win_width = vim.fn.winwidth(0)
  col = math.floor((win_width - width) / 2)

  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
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

local preview_command = function()
  local file_path = ''
  if type(db.preview_file_path) == 'string' then
    file_path = db.preview_file_path
  elseif type(db.preview_file_path) == 'function' then
    file_path = db.preview_file_path()
  else
    vim.notify('wrong type of preview_file_path')
    return
  end

  local script_path = get_script_path()

  if db.preview_command ~= 'ueberzug' and db.preview_command ~= 'wezterm' then
    return db.preview_command .. ' ' .. file_path
  end

  if db.preview_command == 'wezterm' then
    local image_view = script_path .. 'imageview '
    return image_view
      .. space
      .. file_path
      .. space
      .. db.image_width_pixel
      .. space
      .. db.image_height_pixel
  end

  local ueberzug = 'bash ' .. script_path .. 'ueberzug.sh '
  -- filepath x y
  return ueberzug
    .. file_path
    .. space
    .. col + 5
    .. space
    .. row + 3
    .. space
    .. width
    .. space
    .. height
end

local async_preview = uv.new_async(vim.schedule_wrap(function()
  local wininfo = view:open_window()
  local cmd = preview_command()

  api.nvim_buf_call(wininfo[1], function()
    vim.fn.termopen(cmd, {
      on_exit = function() end,
    })
  end)
  api.nvim_win_set_var(0, 'dashboard_preview_wininfo', wininfo)
end))

function view:open_preview()
  async_preview:send()
end

return view
