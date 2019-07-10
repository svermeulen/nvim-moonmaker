
Path = require("moonmaker.internal.Path")
Vim = require("moonmaker.internal.Vim")

class Directory
  getAllFilesWithExtensionRecursive: (path, extension) ->
    return [Path.normalize(x) for x in *Vim.callFunction('globpath', {path, "**/*.#{extension}", 0, 1})]

