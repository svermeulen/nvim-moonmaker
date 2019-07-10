local Path = require("moonmaker.internal.Path")
local Vim = require("moonmaker.internal.Vim")
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
  return _class_0
end
