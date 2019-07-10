local Util
do
  local _class_0
  local _base_0 = {
    tableContains = function(table, element)
      for _index_0 = 1, #table do
        local value = table[_index_0]
        if value == element then
          return true
        end
      end
      return false
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Util"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Util = _class_0
  return _class_0
end
