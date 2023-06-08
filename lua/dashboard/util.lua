local uv, api, fn = vim.loop, vim.api, vim.fn
local util = {}

local function strscreenwidth(str)
  return vim.fn.strdisplaywidth(str)
end

---get os path separator
---@return string
function util.path_sep()
  local slash = false
  local path_sep = '/'
  if fn.exists('+shellslash') == 1 then
    ---@diagnostic disable-next-line: param-type-mismatch
    slash = vim.opt.shellslash:get()
  end
  local iswin = uv.os_uname().version:match('Windows')
  if iswin and not slash then
    path_sep = '\\'
  end
  return path_sep
end

---join path
---@return string
function util.path_join(...)
  return table.concat({ ... }, util.path_sep())
end

---get dashboard cache path
---@return string
function util.cache_path()
  local dir = util.path_join(fn.stdpath('cache'), 'dashboard')
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, 'p')
  end
  return dir
end

function util.get_global_option_value(name)
  return api.nvim_get_option_value(name, { scope = 'global' })
end

local function get_max_len(lines)
  local cells = {}
  vim.tbl_map(function(item)
    cells[#cells + 1] = strscreenwidth(item)
  end, lines)

  table.sort(cells)
  return cells[#cells]
end

---tail align lines insert spaces at the every item of lines tail
---@param lines table
---@return table
function util.tail_align(lines)
  local max = get_max_len(lines)
  local res = {}

  for _, item in ipairs(lines) do
    item = item .. (' '):rep(max - strscreenwidth(item))
    res[#res + 1] = item
  end

  return res
end

---head align lines insert spaces at the every item of lines head
---according nvim screen width
---@param lines table
---@return table
function util.center_align(lines)
  local screen_center = math.floor(bit.rshift(vim.o.columns, 1))
  local new = {}
  for _, line in ipairs(lines) do
    local line_center = math.floor(bit.rshift(strscreenwidth(line), 1))
    local size = screen_center - line_center
    line = (' '):rep(size) .. line
    new[#new + 1] = line
  end

  return new
end

---@param ft string
---@return table|nil
function util.get_icon(ft)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    return nil
  end
  return devicons.get_icon_by_filetype(ft, { default = true })
end

---get the most recently files list
---@return table
function util.get_mru_list()
  local mru = {}
  for _, item in ipairs(vim.v.oldfiles or {}) do
    mru[#mru + 1] = item
  end
  return mru
end

---generate an empty table by given capacity
---@param capacity number
---@return table
function util.generate_empty_table(capacity)
  local res = {}
  if capacity == 0 then
    return res
  end

  for _ = 1, capacity do
    res[#res + 1] = ''
  end
  return res
end

---@param bufnr number
---@return string|nil
function util.get_vcs_root(bufnr)
  bufnr = bufnr or 0
  local path = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ':p:h')
  local patterns = { '.git', '.hg', '.bzr', '.svn' }
  for _, pattern in ipairs(patterns) do
    local root = vim.fs.find(pattern, { path = path, upward = true, stop = vim.env.HOME })
    if root then
      local res = root[#root]
      local sep = util.path_sep()
      res = vim.split(res, sep)
      res[#res] = nil
      return table.concat(res, sep)
    end
  end
end

function util.get_packer_count()
  local ok = pcall(require, 'packer')
  if ok then
    ---@diagnostic disable-next-line: undefined-global
    return #vim.tbl_keys(packer_plugins)
  end
end

function util.get_lazy_count()
  local status, lazy = pcall(require, 'lazy')
  if status then
    return lazy.stats().count
  end
end

function util.read_project_cache(path)
  local fd = assert(uv.fs_open(path, 'r', tonumber('644', 8)))
  local stat = uv.fs_fstat(fd)
  local chunk = uv.fs_read(fd, stat.size, 0)
  local dump = assert(loadstring(chunk))
  return dump()
end

---disable some vim move keys on buffer
---@param bufnr number
function util.disable_move_keys(bufnr, keys)
  keys = keys or { 'w', 'f', 'b', 'h', 'j', 'k', 'l', '<Up>', '<Down>', '<Left>', '<Right>' }
  for _, key in ipairs(keys) do
    api.nvim_buf_set_keymap(bufnr, 'n', key, '<Nope>', {})
  end
end

return util
