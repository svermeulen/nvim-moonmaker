
Directory = require("moonmaker.internal.Directory")
Vim = require("moonmaker.internal.Vim")
Path = require("moonmaker.internal.Path")
File = require("moonmaker.internal.File")
Util = require("moonmaker.internal.Util")

class MoonMaker
  _deleteOrphanedLuaFiles: (validBaseNames, luaDir, verbose) ->
    for filePath in *Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')
      baseName = filePath\sub(#luaDir + 2)
      baseName = baseName\sub(0, #baseName - 4)

      if not Util.tableContains(validBaseNames, baseName)
        File.delete(filePath)
        if verbose
          Vim.echo("Deleted file '#{filePath}' since it had no matching moon file")

  _timeStampIsGreater: (file1Path, file2Path) ->
      time1 = File.getModificationTime(file1Path)
      time2 = File.getModificationTime(file2Path)

      return time1 > time2

  executeMoon: (moonText) ->
    luaText = Vim.callFunction("system", { "moonc --", moonText })
    loadstring(luaText)!

  -- Returns true if it was compiled
  compileMoonIfOutOfDate: (moonPath, luaPath) ->

    if not File.exists(luaPath) or MoonMaker._timeStampIsGreater(moonPath, luaPath)
      Path.makeMissingDirectoriesInPath(luaPath)
      output = Vim.callFunction("system", { "moonc -o \"#{luaPath}\" \"#{moonPath}\"" })

      if Vim.eval('v:shell_error') != 0
        Vim.echoError("Errors occurred while compiling file '#{moonPath}'")
        Vim.echoError(output)
        return false

      return true

    return false

  compileDir: (moonDir, luaDir) ->
    numUpdated = 0
    moonBaseNames = {}

    for filePath in *Directory.getAllFilesWithExtensionRecursive(moonDir, 'moon')
      baseName = filePath\sub(#moonDir + 2)
      baseName = baseName\sub(0, #baseName - 5)
      table.insert(moonBaseNames, baseName)

    if #moonBaseNames > 0
      MoonMaker._deleteOrphanedLuaFiles(moonBaseNames, luaDir, verbose)

      for baseName in *moonBaseNames
        luaPath = Path.join(luaDir, baseName) .. '.lua'
        moonPath = Path.join(moonDir, baseName) .. '.moon'

        if MoonMaker.compileMoonIfOutOfDate(moonPath, luaPath)
          if verbose
            Vim.echo("Compiled file '#{moonPath}'")

          -- Also delete it from the package cache so the next time require(baseName)
          -- is called, it will load the new file
          packageName = baseName\gsub("\\", ".")\gsub("/", ".")
          package.loaded[packageName] = nil
          numUpdated += 1
    return numUpdated

  compileAll: (verbose) ->
    rtp = Vim.eval('&rtp')
    paths = [Path.normalize(x) for x in string.gmatch(rtp, "([^,]+)")]

    numUpdated = 0

    for pluginRoot in *paths
      moonDir = Path.join(pluginRoot, 'moon')
      luaDir = Path.join(pluginRoot, 'lua')

      numUpdated += MoonMaker.compileDir(moonDir, luaDir)

    if verbose and numUpdated == 0
      Vim.echo("All moon files are already up to date")

    return numUpdated

