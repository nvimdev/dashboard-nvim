local api,fn,uv,co = vim.api,vim.fn,vim.loop,coroutine
local db = {}

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
    '                     [ Dashboard version 0.2.1 ]     ',
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
    ['filetype'] = 'dashboard'
  }
  for opt,val in pairs(opts) do
    vim.opt_local[opt] = val
  end
end

-- draw the graphics into the screen center
local draw_center = function(tbl)
  vim.validate{
    tbl = {tbl,'table'}
  }

  local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
      copy[key] = value
    end
    return copy
  end

  local centered_lines = {}
  local tmp = shallowCopy(tbl)
  table.sort(tmp,function(a,b) return fn.strwidth(a) > fn.strwidth(b) end)
  local longest_line = fn.strwidth(tmp[1])
  local fill_size = math.floor((vim.fn.winwidth(0) / 2) - (longest_line / 2))

  for _,v in pairs(tbl) do
    local fill_line = vim.fn['repeat'](' ',fill_size) .. v
    table.insert(centered_lines,fill_line)
  end

  return centered_lines
end

local dashboard_namespace = api.nvim_create_namespace('Dashboard')
local hl_group = {'DashboardHeader','DashboardCenter','DashboardFooter'}

local render_hl = function(bufnr,tbl,line_start,hl)
  for i=1,#tbl do
    api.nvim_buf_add_highlight(bufnr,dashboard_namespace,hl,line_start+i,1,-1)
  end
end

-- insert text and config highlight
local set_line_with_highlight = function(bufnr,line_start,line_end,tbl,hl)
  api.nvim_buf_set_lines(bufnr,line_start,line_end,false,draw_center(tbl))
  render_hl(bufnr,tbl,line_start-1,hl)
end

local db_notify = function(msg)
  vim.notify(msg,'error',{title='Dashboard'})
end

-- get header and center graphics length use coroutine
local get_length_with_graphics = co.create(function()
  local meta = {
    ['header'] = db.custom_header,
    ['center'] = db.custom_center,
    ['footer'] = db.custom_footer
  }

  local get_data = function(item)
    local length,user_data = 0,nil

    if item == 'header' and db.custom_header == nil then
      length = #db.default_banner
      return length,db.default_banner
    end

    if item == 'footer' and db.custom_footer == nil then
      local default_footer = {'Have fun with neovim'}
      if packer_plugins ~= nil then
        local count = #vim.tbl_keys(packer_plugins)
        default_footer[1] = 'neovim loaded '.. count .. ' plugins'
      end
      return 0,default_footer
    end

    if type(meta[item]) == 'table' then
      length = #meta[item]
      return length,meta[item]
    end

    if type(meta[item]) == 'function' then
      user_data = meta[item]()
      return #user_data,user_data
    end

    db_notify('Wrong Data Type must be table or function in custom header or center')
  end

  local count = 0
  for _,v in pairs {"header","footer"} do
    local length,graphics = get_data(v)
    count = length + count
    if v == 'footer' then
      co.yield(count,graphics)
    else
      co.yield(length,graphics)
    end
  end
end)

-- render header
local render_header = co.create(function(bufnr)
  if #db.preview_pipeline_command > 0 then
    local preview = require('dashboard.preview')
    preview.open_preview()
    return
  end
  local _,header_length,header_graphics = co.resume(get_length_with_graphics)
  set_line_with_highlight(bufnr,1,header_length,header_graphics,hl_group[1])
end)

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
local render_footer = co.create(function(bufnr)
  local _,margin,graphics = co.resume(get_length_with_graphics)
  -- load user custom footer
  set_line_with_highlight(bufnr,margin,-1,graphics,hl_group[3])
  api.nvim_buf_set_option(bufnr,'modifiable',false)
end)

-- create dashboard instance
function db.instance(on_vimenter)
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

  local bufnr
  local window = api.nvim_get_current_win()
  if on_vimenter then
    bufnr = vim.api.nvim_get_current_buf()
  else
    if vim.bo.ft ~= "dashboard" then
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(window, bufnr)
    else
        bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_delete(bufnr, {})
        return
    end
  end
  set_buf_local_options()

  co.resume(render_header,bufnr)
  co.resume(render_footer,bufnr)
  api.nvim_exec_autocmds('User DashboardReady',{
    modeline = false
  })
end

return db
