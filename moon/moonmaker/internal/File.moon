
Vim = require("moonmaker.internal.Vim")

class File
  exists: (path) ->
    return Vim.callFunction('filereadable', { path }) != 0

  getModificationTime: (path) ->
    return Vim.callFunction('getftime', { path })

  delete: (path) ->
    Vim.callFunction('delete', { path })
