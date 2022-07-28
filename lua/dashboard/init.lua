local api, fn = vim.api, vim.fn
local db = {}
local insert = table.insert

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
  ' [ Dashboard version 0.2.1 ] ',
  '',
}
db.custom_header = nil
db.custom_footer = nil
db.custom_center = {
  { icon = '', desc = 'Please Config your own center section ', action = '' },
}
db.preview_file_Path = nil
db.preview_file_height = 0
db.preview_file_width = 0
db.preview_command = ''
db.hide_statusline = true
db.hide_tabline = true
db.session_directory = ''
db.header_pad = 1
db.center_pad = 1
db.footer_pad = 1

local generate_empty_table = function(length)
  local empty_tbl = {}
  if length == 0 then
    return empty_tbl
  end

  for _ = 1, length + 3 do
    insert(empty_tbl, '')
  end
  return empty_tbl
end

local set_buf_local_options = function()
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
    ['filetype'] = 'dashboard',
    ['buftype'] = 'nofile',
    ['wrap'] = false,
    ['signcolumn'] = 'no',
  }
  for opt, val in pairs(opts) do
    vim.opt_local[opt] = val
  end
end

-- draw the graphics into the screen center
local draw_center = function(tbl)
  vim.validate({
    tbl = { tbl, 'table' },
  })
  local function fill_sizes(lines)
    local winwidth = fn.winwidth(0)
    local fills = {}

    for _, line in pairs(lines) do
      insert(fills, math.floor((winwidth - fn.strwidth(line)) / 2))
    end

    return fills
  end

  local centered_lines = {}
  local fills = fill_sizes(tbl)

  for i = 1, #tbl do
    local fill_line = string.rep(' ', fills[i]) .. tbl[i]
    insert(centered_lines, fill_line)
  end

  return centered_lines
end

local dashboard_namespace = api.nvim_create_namespace('Dashboard')
local hl_group = { 'DashboardHeader', 'DashboardCenter', 'DashboardFooter' }

local render_hl = function(bufnr, tbl, line_start, hl)
  for i = 1, #tbl do
    api.nvim_buf_add_highlight(bufnr, dashboard_namespace, hl, line_start + i, 1, -1)
  end
end

-- insert text and config highlight
local set_line_with_highlight = function(bufnr, line_start, line_end, tbl, hl)
  api.nvim_buf_set_lines(bufnr, line_start, line_end, false, tbl)
  render_hl(bufnr, tbl, line_start - 1, hl)
end

local db_notify = function(msg)
  vim.notify(msg, 'error', { title = 'Dashboard' })
end

local line_actions, icons, shortcuts = {}, {}, {}

local cache_data = {
  header = {},
  center = {},
  footer = {},
  margin = {},
}

local margin = {}
-- get header and center graphics length use coroutine
local get_length_with_graphics = function(pos)
  local meta = {
    ['header'] = db.custom_header,
    ['center'] = db.custom_center,
    ['footer'] = db.custom_footer,
  }

  local get_data = function(item)
    if item == 'header' and db.custom_header == nil and db.preview_command == '' then
      return db.default_banner
    end

    if #db.preview_command > 0 and item == 'header' then
      if type(db.preview_file_Path) == 'function' then
        db.preview_file_Path()
      end
      return generate_empty_table(db.preview_file_height)
    end

    if item == 'footer' and db.custom_footer == nil then
      local default_footer = { '', '🎉 Have fun with neovim' }
      if packer_plugins ~= nil then
        local count = #vim.tbl_keys(packer_plugins)
        default_footer[2] = '🎉 neovim loaded ' .. count .. ' plugins'
      end
      return default_footer
    end

    if item == 'center' then
      local user_conf = {}
      if next(meta[item]) == nil then
        insert(meta[item], { desc = 'Please config your own section' })
      end
      for _, v in pairs(meta[item]) do
        if v.desc == nil or #v.desc == 0 then
          db_notify('Miss desc keyword in custom center')
          return
        end

        if v.icon == nil then
          v.icon = ''
        end
        if v.shortcut == nil then
          v.shortcut = ''
        end
        insert(user_conf, v.icon .. v.desc .. v.shortcut)
        insert(user_conf, '')
        insert(shortcuts, v.shortcut)
        insert(shortcuts, '')
        insert(icons, v.icon)
        insert(icons, '')
        if v.action then
          insert(line_actions, v.action)
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

  local graphics = vim.deepcopy(get_data(pos))
  if pos == 'header' then
    for _ = 1, db.header_pad do
      insert(graphics, 1, '')
    end

    for _ = 1, db.center_pad do
      insert(graphics, #graphics, '')
    end
  end

  if pos == 'footer' then
    for _ = 1, db.footer_pad do
      insert(graphics, 1, '')
    end
  end
  insert(margin, #graphics)
  return graphics
end

-- render header
local render_header = function(bufnr)
  if #db.preview_command > 0 then
    local preview = require('dashboard.preview')
    preview.open_preview()
  end
  local graphics = get_length_with_graphics('header')
  graphics = draw_center(graphics)
  -- cache the header graphics
  cache_data.header = graphics
  set_line_with_highlight(bufnr, 1, #graphics, graphics, hl_group[1])
end

-- register every center line function in a table
local register_line_with_action = function(graphics)
  local line_with_action = {}
  local count = 0
  for i = 1, #graphics - 1 do
    if #graphics[i] > 0 then
      count = count + 1
      line_with_action[margin[1] + i + 1] = line_actions[count]
    end
  end
  line_actions = line_with_action
end

-- cr map event
function db.call_line_action()
  local current_line = api.nvim_win_get_cursor(0)[1]
  if not line_actions[current_line] then
    return
  end
  if type(line_actions[current_line]) == 'string' then
    vim.cmd(line_actions[current_line])
    return
  end

  if type(line_actions[current_line]) == 'function' then
    line_actions[current_line]()
    return
  end
  db_notify('Wrong type of action must be string or function type')
end

local set_cursor_initial_pos = function(margin, graphics, window)
  local col = 0
  if graphics[1]:find('%w') == nil then
    col = #graphics[1]
  else
    col = graphics[1]:find('%S') + #cache_data.icons[1]
  end
  api.nvim_win_set_var(window, 'db_fix_col', col)
  api.nvim_win_set_var(window, 'db_margin', margin)
  api.nvim_win_set_cursor(window, { margin[1] + 2, col - 1 })
  api.nvim_win_set_var(window, 'db_oldline', margin[1] + 2)
end

local render_default_center = function(bufnr, window)
  local center_graphics = get_length_with_graphics('center')
  local graphics = draw_center(center_graphics)
  --cache the center graphics
  cache_data.center = graphics
  cache_data.icons = icons
  set_line_with_highlight(bufnr, margin[1] + 1, margin[1] + 1 + margin[2], graphics, hl_group[2])

  set_cursor_initial_pos(margin, graphics, window)

  for i, shortcut in pairs(shortcuts) do
    local start_pos = graphics[i]:find(shortcut)
    if start_pos ~= nil then
      api.nvim_buf_add_highlight(bufnr, 0, 'DashboardShortCut', margin[1] + i, start_pos - 1, -1)
    end

    if #icons[i] >= 2 then
      local icon_pos = graphics[i]:find(icons[i])
      api.nvim_buf_add_highlight(
        bufnr,
        0,
        'DashboardCenterIcon',
        margin[1] + i,
        icon_pos,
        icon_pos + #icons[i] - 1
      )
    end
  end

  register_line_with_action(center_graphics)
end

local function set_cursor(bufnr, window)
  local cur_line = api.nvim_win_get_cursor(window)[1]
  local _, col = pcall(api.nvim_win_get_var, window, 'db_fix_col')
  local _, margin = pcall(api.nvim_win_get_var, window, 'db_margin')
  local initial_line = margin[1] + 2
  vim.w.db_oldline = vim.w.db_oldline == nil and initial_line or vim.w.db_oldline
  local max_line = margin[1] + margin[2]
  local new_line = 0

  -- if cursor in initial pos no need move
  if cur_line == initial_line then
    return
  end
  if next(api.nvim_buf_get_lines(bufnr, cur_line, cur_line, false)) == nil then
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

  api.nvim_win_set_cursor(window, { new_line, col - 1 })
end

-- render center
local render_center = function(bufnr, window)
  render_default_center(bufnr, window)
end

-- render footer
local render_footer = function(bufnr)
  local graphics = get_length_with_graphics('footer')
  local tmp = {}
  for _, v in pairs(graphics) do
    insert(tmp, v)
  end
  tmp = draw_center(tmp)
  cache_data.footer = tmp
  cache_data.margin = margin
  -- load user custom footer
  set_line_with_highlight(bufnr, margin[1] + margin[2], -1, tmp, hl_group[3])
  api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

db.confirm_key = '<CR>'

local custom_keymap = function(bufnr)
    local custom_key = db.custom_key
    for key, rhs in pairs(custom_key) do
        api.nvim_buf_set_keymap(bufnr, 'n', key, rhs, { noremap = true, silent = true, nowait = true })
    end
end

local set_keymap = function(bufnr)
  -- disable h l move
  local keys = {
    ['h'] = '',
    ['l'] = '',
    ['w'] = '',
    ['b'] = '',
    ['<BS>'] = '',
  }

  for key, rhs in pairs(keys) do
    api.nvim_buf_set_keymap(bufnr, 'n', key, rhs, { noremap = true, silent = true, nowait = true })
  end

end

local dashboard_loaded = false

local load_from_cache = function(bufnr, window)
  if #db.preview_command > 0 then
    local preview = require('dashboard.preview')
    preview.open_preview()
  end

  set_line_with_highlight(bufnr, 1, #cache_data.header, cache_data.header, hl_group[1])
  set_line_with_highlight(
    bufnr,
    cache_data.margin[1] + 1,
    cache_data.margin[1] + 1 + cache_data.margin[2],
    cache_data.center,
    hl_group[2]
  )
  set_line_with_highlight(
    bufnr,
    cache_data.margin[1] + cache_data.margin[2],
    -1,
    cache_data.footer,
    hl_group[3]
  )

  set_cursor_initial_pos(cache_data.margin, cache_data.center, window)
end

function db.new_file()
  vim.cmd('enew')
  if vim.opt_local.laststatus:get() == 0 then
    vim.opt_local.laststatus = db.user_laststatus_value
  end

  if vim.opt_local.showtabline:get() == 0 then
    vim.opt_local.showtabline = db.user_showtabline_value
  end
end

-- create dashboard instance
function db.instance(on_vimenter, ...)
  local mode = api.nvim_get_mode().mode
  if on_vimenter and (mode == 'i' or not vim.bo.modifiable) then
    return
  end

  if not vim.o.hidden and vim.bo.modfied then
    vim.notify('Save your change first', 'info', { title = 'Dashboard' })
    return
  end

  local bufnr

  if vim.fn.line2byte('$') ~= -1 then
    vim.cmd('noautocmd')
    bufnr = api.nvim_create_buf(false, true)
  else
    bufnr = api.nvim_get_current_buf()
  end

  local window = api.nvim_get_current_win()
  api.nvim_win_set_buf(window, bufnr)

  -- cache the user config and restore it see #144
  db.user_laststatus_value = vim.opt.laststatus:get()
  db.user_showtabline_value = vim.opt.showtabline:get()

  set_buf_local_options()

  local args = { ... }
  local force = args[1] or false

  if dashboard_loaded and not force then
    load_from_cache(bufnr, window)
  else
    render_header(bufnr)
    render_center(bufnr, window)
    render_footer(bufnr)
    dashboard_loaded = true
  end

  set_keymap(bufnr)
  custom_keymap(bufnr)

  if db.cursor_moved_id == nil then
    db.cursor_moved_id = api.nvim_create_augroup('Dashboard CursorMoved Autocmd', {})
  end

  api.nvim_create_autocmd('CursorMoved', {
    group = db.cursor_moved_id,
    buffer = bufnr,
    callback = function()
      if vim.bo.filetype ~= 'dashboard' then
        return
      end
      local ok, pos = pcall(api.nvim_win_get_var, window, 'dashboard_prev_pos')
      set_cursor(bufnr, window)
      if ok and pos[2] > 0 then
        api.nvim_win_set_cursor(window, pos)
        api.nvim_win_set_var(window, 'dashboard_prev_pos', { 0, 0 })
      end
    end,
  })

  api.nvim_exec_autocmds('User', {
    pattern = 'DashboardReady',
    modeline = false,
  })

  -- clear
  icons, shortcuts, margin = {}, {}, {}
end

return db
