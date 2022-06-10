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
db.custom_center = {
  {icon = '',desc= ' ', action=''}
}
db.preview_file_Path = ''
db.preview_file_height = ''
db.preview_file_width = ''
db.preview_pipeline_command = ''
db.tomato_work = false
db.hide_statusline = true

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
  api.nvim_buf_set_lines(bufnr,line_start,line_end,false,tbl)
  render_hl(bufnr,tbl,line_start-1,hl)
end

local db_notify = function(msg)
  vim.notify(msg,'error',{title='Dashboard'})
end

local line_actions,icons,shortcuts = {},{},{}

-- get header and center graphics length use coroutine
local get_length_with_graphics = co.create(function()
  local meta = {
    ['header'] = db.custom_header,
    ['center'] = db.custom_center,
    ['footer'] = db.custom_footer
  }

  local get_data = function(item)
    if item == 'header' and db.custom_header == nil then
      return db.default_banner
    end

    if item == 'footer' and db.custom_footer == nil then
      local default_footer = {'','🎉 Have fun with neovim'}
      if packer_plugins ~= nil then
        local count = #vim.tbl_keys(packer_plugins)
        default_footer[2] = '🎉 neovim loaded '.. count .. ' plugins'
      end
      return default_footer
    end

    if item == 'center' then
      local user_conf = {}
      for i,v in pairs(meta[item]) do
        if v.desc == nil then db_notify('Miss desc keyword in custom center') return end
        if v.icon == nil then v.icon = '' end
        if v.shortcut == nil then v.shortcut = '' end
        table.insert(user_conf,v.icon .. v.desc..v.shortcut)
        table.insert(user_conf,'')
        table.insert(shortcuts,v.shortcut)
        table.insert(shortcuts,'')
        table.insert(icons,{v.icon,#v.desc})
        table.insert(icons,{''})
        if v.action then
          table.insert(line_actions,v.action)
        end
      end
      return user_conf
    end

    if type(meta[item]) == 'table' then
      return meta[item]
    end

    if type(meta[item]) == 'function' then
      return meta[item]()
    end

    db_notify('Wrong Data Type must be table or function in custom header or center')
  end

  local margin = {}
  for _,v in pairs {"header","center","footer"} do
    local graphics = get_data(v)
    table.insert(margin,#graphics)
    co.yield(margin,graphics)
  end
end)

-- render header
local render_header = co.create(function(bufnr)
  if #db.preview_pipeline_command > 0 then
    local preview = require('dashboard.preview')
    preview.open_preview()
    return
  end
  local _,_,header_graphics = co.resume(get_length_with_graphics)
  set_line_with_highlight(bufnr,1,#header_graphics,draw_center(header_graphics),hl_group[1])
end)

-- register every center line function in a table
local register_line_with_action = function (margin)
  local line_with_action = {}
  local count = 0
  for i = margin[1]+2,margin[1]+margin[2] do
    count = count + 1
    line_with_action[i] = line_actions[count]
  end
  line_actions = line_with_action
end

-- cr map event
function db.call_line_action()
  local current_line = api.nvim_win_get_cursor(0)[1]
  if not line_actions[current_line] then return end
  if type(line_actions[current_line]) == 'string' then
    vim.cmd(line_actions[current_line])
    return
  end

  if type(line_actions[current_line])  == 'function' then
    line_actions[current_line]()
    return
  end
  db_notify('Wrong type of action must be string or function type')
end

local render_default_center = function(bufnr,window)
  local _,margin,graphics = co.resume(get_length_with_graphics)
  graphics = draw_center(graphics)
  set_line_with_highlight(bufnr,margin[1]+1,margin[1]+1+margin[2],graphics,hl_group[2])
  local col = graphics[1]:find('%S') + #db.custom_center[1]['icon']
  api.nvim_win_set_var(window,'db_fix_col',col)
  api.nvim_win_set_var(window,'db_margin',margin)
  api.nvim_win_set_cursor(window,{margin[1]+2,col -1})

  for i,shortcut in pairs(shortcuts) do
    if #shortcut > 0 then
      fn.matchaddpos('DashboardShortCut',{{ margin[1]+1+i,#graphics[i]-#shortcut,#shortcut+1}})
    end

    if #icons[i] == 2 then
      local tmp = icons[i]
      fn.matchaddpos('DashboardCenterIcon',{{ margin[1]+1+i,#graphics[i]-#shortcut-tmp[2]-#tmp[1],#tmp[1]}})
    end
  end

  register_line_with_action(margin)
end

local function set_cursor(bufnr,window)
  local cur_line = api.nvim_win_get_cursor(window)[1]
  local col = api.nvim_win_get_var(window,'db_fix_col')
  local margin = api.nvim_win_get_var(window,'db_margin')
  local initial_line = margin[1] + 2
  local max_line = margin[1] + margin[2]
  local new_line = 0
  local ok,_ = pcall(api.nvim_win_get_var,window,'db_oldline')
  if not ok then
    api.nvim_win_set_var(window,'db_oldline',initial_line)
  end

  -- if cursor in initial pos no need move
  if cur_line == initial_line then return end
  if next(api.nvim_buf_get_lines(bufnr,cur_line,cur_line,false)) == nil then
    if cur_line > vim.w.db_oldline then
      new_line = cur_line + 1
      vim.w.db_oldline = new_line
    else
      new_line = cur_line - 1
      vim.w.db_oldline = new_line
    end
  end

  if new_line > max_line then
    new_line = margin[1] + 2
    vim.w.db_oldline = new_line
  end

  if cur_line < initial_line then
    new_line = max_line
    vim.w.db_oldline = new_line
  end

  api.nvim_win_set_cursor(window,{new_line,col - 1})
end

local render_tomato_work = function()end

-- render center
local render_center = co.create(function(bufnr,window)
  if  not db.tomato_work then
    render_default_center(bufnr,window)
  else
    render_tomato_work()
  end
end)

-- render footer
local render_footer = co.create(function(bufnr)
  local _,margin,graphics = co.resume(get_length_with_graphics)
  -- load user custom footer
  set_line_with_highlight(bufnr,margin[1]+margin[2],-1,draw_center(graphics),hl_group[3])
  api.nvim_buf_set_option(bufnr,'modifiable',false)
end)

-- create dashboard instance
function db.instance(on_vimenter)
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

  for _,v in pairs {render_header,render_center,render_footer} do
    co.resume(v,bufnr,window)
  end

  if db.hide_statusline then
    vim.opt.laststatus=0
  end

  api.nvim_buf_set_keymap(bufnr,'n','<CR>',
  '<cmd>lua require("dashboard").call_line_action()<CR>',
  {noremap = true,silent = true,nowait = true})

  api.nvim_create_autocmd('CursorMoved',{
    buffer = bufnr,
    callback = function() set_cursor(bufnr,window) end
  })

  api.nvim_exec_autocmds('User DashboardReady',{
    modeline = false
  })
end

return db
