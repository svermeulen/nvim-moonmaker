
class Vim
  eval: (vimL) ->
    return vim.api.nvim_eval(vimL)

  echo: (message) ->
    vim.api.nvim_out_write(message .. '\n')

  echoError: (message) ->
    vim.api.nvim_err_writeln(message)

  callFunction: (functionName, args) ->
    vim.api.nvim_call_function(functionName, args)
