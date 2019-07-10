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
  return _class_0
end
