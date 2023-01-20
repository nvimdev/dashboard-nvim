local uv = vim.loop
local utils = {}

function utils.path_join(...)
  local is_win = uv.os_uname().version == 'WindowsNT'
  local path_sep = is_win and '\\' or '/'
  return table.concat({ ... }, path_sep)
end

function utils.element_align(tbl)
  local lens = {}
  vim.tbl_map(function(k)
    table.insert(lens, vim.api.nvim_strwidth(k))
  end, tbl)
  table.sort(lens)
  local max = lens[#lens]
  local res = {}
  for _, item in pairs(tbl) do
    local len = vim.api.nvim_strwidth(item)
    local times = math.floor((max - len) / vim.api.nvim_strwidth(' '))
    item = item .. (' '):rep(times)
    table.insert(res, item)
  end
  return res
end

-- draw the graphics into the screen center
function utils.center_align(tbl)
  vim.validate({
    tbl = { tbl, 'table' },
  })
  local function fill_sizes(lines)
    local fills = {}
    for _, line in pairs(lines) do
      table.insert(fills, math.floor((vim.o.columns - vim.api.nvim_strwidth(line)) / 2))
    end
    return fills
  end

  local centered_lines = {}
  local fills = fill_sizes(tbl)

  for i = 1, #tbl do
    local fill_line = (' '):rep(fills[i]) .. tbl[i]
    table.insert(centered_lines, fill_line)
  end

  return centered_lines
end

function utils.generate_header(header, elements)
  local default = {
    '',
    ' ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗  ',
    ' ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗ ',
    ' ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║ ',
    ' ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║ ',
    ' ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝ ',
    ' ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ',
    '',
  }
  header = header or default
  vim.list_extend(elements.lines, utils.center_align(header))
  local header_highlight = function(bufnr, _)
    for i, _ in ipairs(header) do
      vim.api.nvim_buf_add_highlight(bufnr, 0, 'DashboardHeader', i - 1, 0, -1)
    end
  end
  table.insert(elements.fns, header_highlight)
end

function utils.get_icon(ft)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    return nil
  end
  return devicons.get_icon_by_filetype(ft, { default = true })
end

--- return the most recently files list
function utils.get_mru_list()
  local mru = {}
  for _, file in pairs(vim.v.oldfiles or {}) do
    if file and uv.fs_stat(file) then
      table.insert(mru, file)
    end
  end
  return mru
end

function utils.get_packages_count()
  local count = 0
  ---@diagnostic disable-next-line: undefined-global
  if packer_plugins then
    ---@diagnostic disable-next-line: undefined-global
    count = #vim.tbl_keys(packer_plugins)
  end
  local status, lazy = pcall(require, 'lazy')
  if status then
    count = lazy.stats().count
  end
  return count
end

--- generate an empty table by length
function utils.generate_empty_table(length)
  local empty_tbl = {}
  if length == 0 then
    return empty_tbl
  end

  for _ = 1, length + 3 do
    table.insert(empty_tbl, '')
  end
  return empty_tbl
end

function utils.generate_truncateline(cells)
  local char = '┉'
  return char:rep(math.floor(cells / vim.api.nvim_strwidth(char)))
end

return utils
