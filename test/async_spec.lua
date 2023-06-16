local afs = require('dashboard.asyncfs')
local equal = assert.equal
local path = './test/simple.txt'

describe('asyncfs moudle', function()
  setup(function()
    os.execute('touch ./test/simple.txt')
    local fd = io.open(path, 'w')
    if fd then
      fd:write('foo bar')
      fd:close()
    end
  end)

  teardown(function()
    vim.fn.delete(path)
  end)

  it('can read file async', function()
    local data
    afs.async_read(path, function(content)
      data = vim.split(content, '\n')
    end)
    vim.wait(1000)
    equal('foo bar', data[1])
  end)

  it('can write file async', function()
    afs.async_write(path, 'bar bar foo foo')
    vim.wait(1000)
    local fd = io.open(path, 'r')
    if not fd then
      print('open file failed in write callback')
      return
    end
    local data = fd:read('*a')
    equal('bar bar foo foo', data)
  end)
end)
