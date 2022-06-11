local uv = vim.loop
local api = vim.api
local db = require('dashboard')

local open_window = function (bn)
  local width = db.preview_file_width
  local height = db.preview_file_height
  local row = math.floor(height / 5)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height =height,
    style = 'minimal'
  }

  local bufnr = bn or nil

  if not bufnr then
    bufnr = api.nvim_create_buf(false,true)
  end
  local winid = api.nvim_open_win(bufnr,true,opts)
  api.nvim_win_set_option(winid,"winhl","Normal:DashboardTerminal")
  api.nvim_command('hi DashboardTerminal guibg=NONE gui=NONE')
  return {bufnr,winid}
end

local async_preview = uv.new_async(vim.schedule_wrap(function()
  local wininfo = open_window()
  local cmd = 'terminal '..db.preview_command..' '..db.preview_file_path
  api.nvim_command(cmd)
  api.nvim_command('wincmd j')
  api.nvim_buf_set_option(wininfo[1],'buflisted',false)
  api.nvim_win_set_var(0,'dashboard_preview_winid',wininfo[2])
  api.nvim_command('let b:term_title ="dashboard_preview" ')
end))

local open_preview =function()
  async_preview:send()
end

local close_preview_window = function()
  local ok,winid = pcall(api.nvim_win_get_var,0,'dashboard_preview_winid')
  if ok and api.nvim_win_is_valid(winid) then
    api.nvim_win_close(winid,true)
  end
end

return {
  open_window = open_window,
  open_preview = open_preview,
  close_preview_window = close_preview_window
}
