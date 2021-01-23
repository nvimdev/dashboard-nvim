local uv = vim.loop
local api = vim.api

local async_preview = uv.new_async(vim.schedule_wrap(function()
  local width = vim.g.dashboard_preview_file_width
  local height = vim.g.dashboard_preview_file_height
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

  local bufnr = api.nvim_create_buf(false,true)
  local winid = api.nvim_open_win(bufnr,true,opts)
  api.nvim_win_set_option(winid,"winhl","Normal:DashboardTerminal")
  api.nvim_command('hi DashboardTerminal guibg=NONE gui=NONE')
  local pipline = ''
  if string.len(vim.g.preview_pipeline_command) > 0 then
    pipline = ' |' .. vim.g.preview_pipeline_command
  end
  local cmd = 'terminal '..vim.g.dashboard_command..' '..vim.g.preview_file_path ..pipline
  api.nvim_command(cmd)
  api.nvim_buf_set_option(0,'buflisted',false)
  api.nvim_command('wincmd j')
  api.nvim_win_set_var(0,'dashboard_preview_winid',winid)
end))

async_preview:send()
