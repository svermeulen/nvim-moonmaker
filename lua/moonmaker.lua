local Vim
do
  local _class_0
  local _base_0 = {
    eval = function(vimL)
      return vim.api.nvim_eval(vimL)
    end,
    echo = function(message)
      return vim.api.nvim_out_write(message .. '\n')
    end,
    echoError = function(message)
      return vim.api.nvim_err_writeln(message)
    end,
    callFunction = function(functionName, args)
      return vim.api.nvim_call_function(functionName, args)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Vim"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vim = _class_0
end
local Assert
Assert = function(condition, message)
  if not condition then
    if message then
      return error("Assert hit! " .. message)
    else
      return error("Assert hit!")
    end
  end
end
local Path
do
  local _class_0
  local _base_0 = {
    join = function(left, right)
      local result = left
      local lastChar = left:sub(-1)
      if lastChar ~= '/' and lastChar ~= '\\' then
        result = result .. '/'
      end
      result = result .. right
      return result
    end,
    normalize = function(path)
      local result = string.gsub(path, "\\", "/")
      if result:sub(-1) == '/' then
        result = result:sub(0, #result - 1)
      end
      return result
    end,
    makeMissingDirectoriesInPath = function(path)
      local dirPath = Path.getDirectory(path)
      return Vim.callFunction('mkdir', {
        dirPath,
        'p'
      })
    end,
    getDirectory = function(path)
      return path:match('^(.*)[\\/][^\\/]*$')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Path"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Path = _class_0
end
local File
do
  local _class_0
  local _base_0 = {
    exists = function(path)
      return Vim.callFunction('filereadable', {
        path
      }) ~= 0
    end,
    getModificationTime = function(path)
      return Vim.callFunction('getftime', {
        path
      })
    end,
    delete = function(path)
      return Vim.callFunction('delete', {
        path
      })
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "File"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  File = _class_0
end
local Directory
do
  local _class_0
  local _base_0 = {
    getAllFilesWithExtensionRecursive = function(path, extension)
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = Vim.callFunction('globpath', {
        path,
        "**/*." .. tostring(extension),
        0,
        1
      })
      for _index_0 = 1, #_list_0 do
        local x = _list_0[_index_0]
        _accum_0[_len_0] = Path.normalize(x)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Directory"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Directory = _class_0
end
local tableContains
tableContains = function(table, element)
  for _index_0 = 1, #table do
    local value = table[_index_0]
    if value == element then
      return true
    end
  end
  return false
end
local deleteOrphanedLuaFiles
deleteOrphanedLuaFiles = function(validBaseNames, luaDir, verbose)
  local _list_0 = Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')
  for _index_0 = 1, #_list_0 do
    local filePath = _list_0[_index_0]
    local baseName = filePath:sub(#luaDir + 2)
    baseName = baseName:sub(0, #baseName - 4)
    if not tableContains(validBaseNames, baseName) then
      File.delete(filePath)
      if verbose then
        Vim.echo("Deleted file '" .. tostring(filePath) .. "' since it had no matching moon file")
      end
    end
  end
end
local timeStampIsGreater
timeStampIsGreater = function(file1Path, file2Path)
  local time1 = File.getModificationTime(file1Path)
  local time2 = File.getModificationTime(file2Path)
  return time1 > time2
end
local MoonMaker
do
  local _class_0
  local _base_0 = {
    executeMoon = function(moonText)
      local luaText = Vim.callFunction("system", {
        "moonc --",
        moonText
      })
      return loadstring(luaText)()
    end,
    compileMoonIfOutOfDate = function(moonPath, luaPath)
      if not File.exists(luaPath) or timeStampIsGreater(moonPath, luaPath) then
        Path.makeMissingDirectoriesInPath(luaPath)
        local output = Vim.callFunction("system", {
          "moonc -o \"" .. tostring(luaPath) .. "\" \"" .. tostring(moonPath) .. "\""
        })
        if Vim.eval('v:shell_error') ~= 0 then
          Vim.echoError("Errors occurred while compiling file '" .. tostring(moonPath) .. "'")
          Vim.echoError(output)
          return false
        end
        return true
      end
      return false
    end,
    compileDir = function(moonDir, luaDir)
      local numUpdated = 0
      local moonBaseNames = { }
      local _list_0 = Directory.getAllFilesWithExtensionRecursive(moonDir, 'moon')
      for _index_0 = 1, #_list_0 do
        local filePath = _list_0[_index_0]
        local baseName = filePath:sub(#moonDir + 2)
        baseName = baseName:sub(0, #baseName - 5)
        table.insert(moonBaseNames, baseName)
      end
      if #moonBaseNames > 0 then
        deleteOrphanedLuaFiles(moonBaseNames, luaDir, verbose)
        for _index_0 = 1, #moonBaseNames do
          local baseName = moonBaseNames[_index_0]
          local luaPath = Path.join(luaDir, baseName) .. '.lua'
          local moonPath = Path.join(moonDir, baseName) .. '.moon'
          if MoonMaker.compileMoonIfOutOfDate(moonPath, luaPath) then
            if verbose then
              Vim.echo("Compiled file '" .. tostring(moonPath) .. "'")
            end
            local packageName = baseName:gsub("\\", "."):gsub("/", ".")
            package.loaded[packageName] = nil
            numUpdated = numUpdated + 1
          end
        end
      end
      return numUpdated
    end,
    compileAll = function(verbose)
      local rtp = Vim.eval('&rtp')
      local paths
      do
        local _accum_0 = { }
        local _len_0 = 1
        for x in string.gmatch(rtp, "([^,]+)") do
          _accum_0[_len_0] = Path.normalize(x)
          _len_0 = _len_0 + 1
        end
        paths = _accum_0
      end
      local numUpdated = 0
      for _index_0 = 1, #paths do
        local pluginRoot = paths[_index_0]
        local moonDir = Path.join(pluginRoot, 'moon')
        local luaDir = Path.join(pluginRoot, 'lua')
        numUpdated = numUpdated + MoonMaker.compileDir(moonDir, luaDir)
      end
      if verbose and numUpdated == 0 then
        Vim.echo("All moon files are already up to date")
      end
      return numUpdated
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "MoonMaker"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  MoonMaker = _class_0
  return _class_0
end
