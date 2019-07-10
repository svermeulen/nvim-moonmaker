
Vim = require("moonmaker.internal.Vim")

class Path
  join: (left, right) ->
    result = left
    lastChar = left\sub(-1)

    if lastChar != '/' and lastChar != '\\'
      result ..= '/'

    result ..= right
    return result

  normalize: (path) ->
    result = string.gsub(path, "\\", "/")

    if result\sub(-1) == '/'
      result = result\sub(0, #result - 1)

    return result

  makeMissingDirectoriesInPath: (path) ->
    dirPath = Path.getDirectory(path)
    Vim.callFunction('mkdir', { dirPath, 'p' })

  getDirectory: (path) ->
    return path\match('^(.*)[\\/][^\\/]*$')
