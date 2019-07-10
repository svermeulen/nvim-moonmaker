local Vim = require("moonmaker.internal.Vim")
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
  return _class_0
end
