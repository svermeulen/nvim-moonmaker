local Vim = require("moonmaker.internal.Vim")
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
  return _class_0
end
