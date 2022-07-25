local uv = vim.loop
local api = vim.api
local db = require('dashboard')
local space = ' '

local width = db.preview_file_width
local height = db.preview_file_height
local row, col

local get_script_path = function()
  local path = packer_plugins['dashboard-nvim'].path

  if path == nil then
    error('Does not find the dashboard dir')
    return
  end
  return path .. '/scripts/ueberzug.sh '
end

local open_window = function(bn)
  row = math.floor(height / 5)
  col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
  }

  local bufnr = bn or nil

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  end
  local winid = api.nvim_open_win(bufnr, false, opts)
  api.nvim_win_set_option(winid, 'winhl', 'Normal:DashboardTerminal')
  api.nvim_set_hl(0, 'DashboardTerminal', { bg = 'none' })
  return { bufnr, winid }
end

local close_preview_window = function()
  local ok, wininfo = pcall(api.nvim_win_get_var, 0, 'dashboard_preview_wininfo')
  if ok then
    if api.nvim_buf_is_loaded(wininfo[1]) then
      api.nvim_buf_delete(wininfo[1], { force = true })
    end

    if api.nvim_win_is_valid(wininfo[2]) then
      api.nvim_win_close(wininfo[2], true)
    end
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

  if db.preview_command ~= 'ueberzug' then
    return db.preview_command .. ' ' .. file_path
  end

  local script_path = get_script_path()

  local ueberzug = 'bash ' .. script_path
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
  local wininfo = open_window()
  local cmd = preview_command()

  api.nvim_buf_call(wininfo[1], function()
    vim.fn.termopen(cmd, {
      on_exit = function()
        close_preview_window()
      end,
    })
  end)
  api.nvim_win_set_var(0, 'dashboard_preview_wininfo', wininfo)
end))

local open_preview = function()
  async_preview:send()
end

return {
  get_script_path = get_script_path,
  open_window = open_window,
  open_preview = open_preview,
  close_preview_window = close_preview_window,
}
