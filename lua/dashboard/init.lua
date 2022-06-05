local api = vim.api
local uv = vim.loop
local db = {}
local empty_lines = {''}

db.default_banner = {
    '',
    '',
    ' ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗  ',
    ' ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗ ',
    ' ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║ ',
    ' ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║ ',
    ' ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝ ',
    ' ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ',
    '',
    '                     [ Dashboard version 0.2.0 ]     ',
    '',
}
db.custom_header = nil
db.custom_footer = nil
db.custom_center = nil
db.preview_file_Path = ''
db.preview_file_height = ''
db.preview_file_width = ''
db.preview_pipeline_command = ''
db.tomato_work = false

local set_buf_local_options = function ()
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
  }
  for opt,val in pairs(opts) do
    vim.opt_local[opt] = val
  end
end

local draw_center = function(tbl)
  vim.validate{
    tbl = {tbl,'table'}
  }

  local centered_lines = {}
  local tmp = tbl
  table.sort(tmp,function(a,b) return #a > #b end)
  local longest_line = #tmp[1]
  local fill_size = math.floor((vim.fn.winwidth(0) / 2) - (longest_line / 2))

  for _,v in pairs(tbl) do
    local fill_line = vim.fn['repeat'](' ',fill_size) .. v
    table.insert(centered_lines,fill_line)
  end
  table.insert(centered_lines,'')

  return centered_lines
end

local header_length,center_length = 0,0
local dashboard_namespace = api.nvim_create_namespace('Dashboard')
local hl_group = {'DashboardHeader','DashboardCenter','DashboardFooter'}

local render_hl = function(bufnr,tbl,hl)
  for i=1,#tbl do
    api.nvim_buf_add_highlight(bufnr,dashboard_namespace,hl,2+i,1,-1)
  end
end

local set_line_with_highlight = function(bufnr,line_start,line_end,tbl,hl)
  api.nvim_buf_set_lines(bufnr,line_start+1,line_end,false,draw_center(tbl))
  render_hl(bufnr,tbl,hl)
end

-- render header
local render_header = uv.new_async(vim.schedule_wrap(function(bufnr)
  if db.custom_header == nil then
    if #db.preview_pipeline_command > 0 then
      local preview = require('dashboard.preview')
      preview.open_preview()
    else
      set_line_with_highlight(bufnr,1,#db.default_banner,db.default_banner,hl_group[1])
    end
    return
  end

  if type(db.custom_header)  == 'table' then
    set_line_with_highlight(bufnr,1,#db.custom_header,db.custom_header,hl_group[1])
    header_length = #db.custom_header
  elseif type(db.custom_header) == 'function' then
    local user_header = db.custom_header()
    set_line_with_highlight(bufnr,1,#user_header,user_header,hl_group[1])
    header_length = #user_header
  else
    vim.notify('Wrong Header type must be table or function','error')
  end
end))

local db_notify = function(msg)
  vim.notify(msg,'error',{title='Dashboard'})
end

local render_default_center = function(bufnr)
  if db.custom_center == nil then return end
  local center_descs = {}

  local set_center_lines = function()
    for _,v in pairs(center_descs) do
      if v.desc == nil then
        db_notify('Miss keyword desc in custom center')
        return
      end
      table.insert(center_descs,v.desc)
    end
    set_line_with_highlight(bufnr,header_length+1,#center_descs+1,center_descs,hl_group[2])
    center_length = #center_descs
  end

  if type(db.custom_center) == 'table' then
    center_descs = db.custom_center
    set_center_lines()
  elseif type(db.custom_center) == 'function' then
    center_descs = db.custom_center()
    if type(center_descs) ~= 'table' then
      db_notify('Your center function must return table type')
      return
    end
    set_center_lines()
  end
end

local render_tomato_work = function()end

-- render center
local render_center = uv.new_async(vim.schedule_wrap(function(bufnr)
  if  not db.tomato_work then
    render_default_center(bufnr)
  else
    render_tomato_work()
  end
end))

-- render footer
local render_footer = uv.new_async(vim.schedule_wrap(function(bufnr)
  local default_footer = {'Have fun with neovim'}

  -- load defualt footer
  if db.custom_footer == nil then
    if packer_plugins ~= nil then
      local count = #vim.tbl_keys(packer_plugins)
      default_footer[1] = 'neovim loaded '.. count .. ' plugins'
    end
    set_line_with_highlight(bufnr,center_length+1,-1,default_footer,hl_group[3])
    return
  end

  -- load user custom footer
  if type(db.custom_footer) == 'table' then
    set_line_with_highlight(bufnr,center_length+1,-1,db.custom_footer,hl_group[3])
  elseif type(db.custom_footer) == 'function' then
    default_footer = db.custom_footer()
    if type(default_footer) ~= 'table' then
      db_notify('Your function must return a table type!')
    end
    set_line_with_highlight(bufnr,center_length+1,-1,default_footer,hl_group[3])
  end
end))

-- create dashboard instance
function db.instance(on_vimenter)
  local bufnr
  if on_vimenter and (vim.o.insertmode or not vim.bo.modfied) then
    return
  end

  if not vim.o.hidden and vim.bo.modfied then
    vim.notify('Save your change first','info',{title = 'Dashboard'})
    return
  end

  if vim.fn.line2byte('$') ~= -1 then
    return
  end

  set_buf_local_options()

  bufnr = api.nvim_create_buf(false,true)
  api.nvim_buf_set_option(bufnr,'filetype','dashboard')

  render_header:send(bufnr)
--   render_center:send(bufnr)
  render_footer:send(bufnr)
  api.nvim_buf_set_option(bufnr,'modified',false)
  api.nvim_exec_autocmds('User DashboardReady',{
    modeline = false
  })
end

return db
