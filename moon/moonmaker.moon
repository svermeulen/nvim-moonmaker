
class Vim
  eval: (vimL) ->
    return vim.api.nvim_eval(vimL)

  echo: (message) ->
    vim.api.nvim_out_write(message .. '\n')

  echoError: (message) ->
    vim.api.nvim_err_writeln(message)

  callFunction: (functionName, args) ->
    vim.api.nvim_call_function(functionName, args)

Assert = (condition, message) ->
  if not condition
    if message
      error("Assert hit! " .. message)
    else
      error("Assert hit!")

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

class File
  exists: (path) ->
    return Vim.callFunction('filereadable', { path }) != 0

  getModificationTime: (path) ->
    return Vim.callFunction('getftime', { path })

  delete: (path) ->
    Vim.callFunction('delete', { path })

class Directory
  exists: (path) ->
    return Vim.callFunction('isdirectory', { path }) != 0

  getAllFilesWithExtensionRecursive: (path, extension) ->
    return [Path.normalize(x) for x in *Vim.callFunction('globpath', {path, "**/*.#{extension}", 0, 1})]

tableContains = (table, element) ->
  for value in *table
    if value == element then
      return true

  return false

deleteOrphanedLuaFiles = (validBaseNames, luaDir, verbose) ->
  for filePath in *Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')
    luaRelativePath = filePath\sub(#luaDir + 2)
    baseName = luaRelativePath\sub(0, #luaRelativePath - 4)

    if tableContains(validBaseNames, baseName)
      continue

    alwaysDelete = false
    if Vim.callFunction('exists', {'g:MoonMakerDeleteOrphanedLuaFiles'}) == 1
      alwaysDelete = vim.api.nvim_get_var('MoonMakerDeleteOrphanedLuaFiles')

    if not alwaysDelete
      choice = Vim.callFunction(
        "confirm", { "Lua file at '#{luaRelativePath}' does not have a corresponding Moon file. Delete it?\nNote that this popup can be suppressed with the g:MoonMakerDeleteOrphanedLuaFiles setting", "&Delete\n&Skip\n&Abort", 2, "Question" })
      if choice == 2
        if verbose
          Vim.echo("Skipping orphaned lua file '#{luaRelativePath}'")
        continue
      if choice != 1
        if verbose
          Vim.echo("Aborting lua file cleanup")
        return

    File.delete(filePath)
    if verbose
      Vim.echo("Deleted file '#{filePath}' since it had no matching moon file")

timeStampIsGreater = (file1Path, file2Path) ->
    time1 = File.getModificationTime(file1Path)
    time2 = File.getModificationTime(file2Path)

    return time1 > time2

class MoonMaker
  executeMoon: (moonText) ->
    luaText = Vim.callFunction("system", { "moonc --", moonText })
    loadstring(luaText)!

  -- Returns true if it was compiled
  compileMoonIfOutOfDate: (moonPath, luaPath) ->

    if not File.exists(luaPath) or timeStampIsGreater(moonPath, luaPath)
      Path.makeMissingDirectoriesInPath(luaPath)
      output = Vim.callFunction("system", { "moonc -o \"#{luaPath}\" \"#{moonPath}\"" })

      if Vim.eval('v:shell_error') != 0
        Vim.echoError("Errors occurred while compiling file '#{moonPath}'")
        Vim.echoError(output)
        return false

      return true

    return false

  compileDir: (moonDir, luaDir, verbose) ->
    numUpdated = 0
    moonBaseNames = {}

    for filePath in *Directory.getAllFilesWithExtensionRecursive(moonDir, 'moon')
      baseName = filePath\sub(#moonDir + 2)
      baseName = baseName\sub(0, #baseName - 5)
      table.insert(moonBaseNames, baseName)

    if #moonBaseNames > 0
      deleteOrphanedLuaFiles(moonBaseNames, luaDir, verbose)

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

  compileAllMoonFilesInDirectoryRecursive: (rootDir) ->
    numUpdated = 0
    for moonPath in *Directory.getAllFilesWithExtensionRecursive(rootDir, 'moon')
      luaPath = moonPath\sub(0, #moonPath - 4) .. "lua"
      if MoonMaker.compileMoonIfOutOfDate(moonPath, luaPath)
        numUpdated += 1
    return numUpdated

  compileAll: (verbose) ->
    rtp = Vim.eval('&rtp')
    paths = [Path.normalize(x) for x in string.gmatch(rtp, "([^,]+)")]

    numUpdated = 0

    for pluginRoot in *paths
      moonDir = Path.join(pluginRoot, 'moon')
      luaDir = Path.join(pluginRoot, 'lua')

      numUpdated += MoonMaker.compileDir(moonDir, luaDir, verbose)

      for dirName in *{'ftplugin', 'indent', 'plugin'}
        numUpdated += MoonMaker.compileAllMoonFilesInDirectoryRecursive(Path.join(pluginRoot, dirName))

    if verbose and numUpdated == 0
      Vim.echo("All moon files are already up to date")

    return numUpdated

