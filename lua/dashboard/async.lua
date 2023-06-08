local uv = vim.loop

local function async(fn)
  local co = coroutine.create(fn)
  return function(...)
    local status, result = coroutine.resume(co, ...)
    if not status then
      error(result)
    end
    return result
  end
end

local function await(promise)
  if type(promise) ~= 'function' then
    return promise
  end
  local co = assert(coroutine.running())
  promise(function(...)
    coroutine.resume(co, ...)
  end)
  return (coroutine.yield())
end

local function fs_module(filename)
  local fs = {}
  local task = {}

  function fs:open()
    task[#task + 1] = function(callback)
      uv.fs_open(filename, 'r', 438, function(err, fd)
        assert(not err)
        self.fd = fd
        callback(fd)
      end)
    end
    return self
  end

  function fs:size()
    task[#task + 1] = function(callback)
      uv.fs_fstat(self.fd, function(err, stat)
        assert(not err)
        self.size = stat.size
        callback(stat.size)
      end)
    end
    return self
  end

  function fs:read()
    task[#task + 1] = function(callback)
      uv.fs_read(self.fd, self.size, function(err, data)
        assert(not err)
        assert(uv.fs_close(self.fd))
        callback(data)
      end)
    end
    return self
  end

  function fs:write(content)
    local data = vim.json.encode(content)
    task[#task + 1] = function()
      uv.fs_write(self.fd, data, function(err)
        assert(not err)
        assert(uv.fs_close(self.fd))
      end)
    end
    return self
  end

  function fs:run(callback)
    async(function()
      for i, t in ipairs(task) do
        local res = await(t)
        if i == #task then
          callback(res)
        end
      end
    end)()
  end

  return fs
end

local function async_read(filename, callback)
  local fs = fs_module(filename)
  fs:open():size():read():run(callback)
end

local function async_write(filename, content, callback)
  local fs = fs_module(filename)
  fs:open():size():write(content):run(callback)
end

return {
  async_read = async_read,
  async_write = async_write,
}
