local util = require('dashboard.util')
local eq = assert.equal
local same = assert.same

describe('util functions', function()
  it('util.path_sep get path of system', function()
    local iswin = vim.loop.os_uname().version:match('Windows')
    local path = util.path_sep()
    eq('/', path)
    if iswin then
      eq('\\', path)
      vim.opt.shellslash = true
      eq('/', path)
    end
  end)

  it('util.element_align', function()
    local lines = { 'balabala  ', 'foo  ', 'bar   ' }
    lines = util.element_align(lines)
    same({
      'balabala  ',
      'foo       ',
      'bar       ',
    }, lines)
  end)

  it('util.path_join', function()
    local nvim = '/Users/runner/.cache/nvim'
    local dir = 'dashboard'
    local path = util.path_join(nvim, dir)
    eq('/Users/runner/.cache/nvim/dashboard', path)
  end)
end)
