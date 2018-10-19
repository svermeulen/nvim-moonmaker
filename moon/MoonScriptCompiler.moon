
local Path

Output = (message) ->
  vim.api.nvim_command("echom '#{message}'")

Path =
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

  getExtension: (path) ->
    return path\match('%.([^%.]*)$')

  removeExtension: (fileName) ->
    extension = Path.getExtension(fileName)

    if extension == nil
      return fileName

    return fileName\sub(0, #fileName - #extension - 1)

File =
  exists: (path) ->
    return io.open(path, 'r') != nil

  getModificationTime: (path) ->
    return vim.api.nvim_call_function('getftime', {path})

  getFileName: (path) ->
    return path\match('[\\/]([^\\/]*)$')

Directory =
  getAllFilesWithExtensionRecursive: (path, extension) ->
    return [Path.normalize(x) for x in *vim.api.nvim_call_function('globpath', {path, "**/*.#{extension}", 0, 1})]

  getDirectoriesAndFiles: (path) ->
    return [Path.normalize(x) for x in *vim.api.nvim_call_function('globpath', {path, "*", 0, 1})]

  getFilesWithExtension: (path, extension) ->
    return [Path.normalize(x) for x in *vim.api.nvim_call_function('globpath', {path, "*.#{extension}", 0, 1})]

tableContains = (table, element) ->
  for value in *table
    if value == element then
      return true

  return false

deleteOrphanedLuaFiles = (validBaseNames, pluginRoot) ->
  luaDir = Path.join(pluginRoot, 'lua')

  for filePath in *Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')
    baseName = filePath\sub(#luaDir + 2)
    baseName = baseName\sub(0, #baseName - 4)

    if not tableContains(validBaseNames, baseName)
      --os.remove(fullPath)
      Output("Deleted file #{filePath} since it had no matching moon file")

shouldCompileMoonFile = (moonPath, luaPath) ->
  if not File.exists(luaPath)
    return true

  luaTime = File.getModificationTime(luaPath)
  moonTime = File.getModificationTime(moonPath)

  return moonTime > luaTime

compileMoon = (moonPath, luaPath) ->
  os.execute("moonc -o \"#{luaPath}\" -n \"#{moonPath}\"")
  Output("Compiled file #{moonPath}")

MoonScriptCompiler =
  compile: ->
    rtp = vim.api.nvim_eval('&rtp')
    paths = [Path.normalize(x) for x in string.gmatch(rtp, "([^,]+)")]

    numUpdated = 0

    for pluginRoot in *paths
      moonBaseNames = {}
      moonDir = Path.join(pluginRoot, 'moon')

      for filePath in *Directory.getAllFilesWithExtensionRecursive(moonDir, 'moon')
        baseName = filePath\sub(#moonDir + 2)
        baseName = baseName\sub(0, #baseName - 5)
        table.insert(moonBaseNames, baseName)

      if #moonBaseNames > 0
        deleteOrphanedLuaFiles(moonBaseNames, pluginRoot)

        luaDir = Path.join(pluginRoot, 'lua')

        for baseName in *moonBaseNames
          luaPath = Path.join(luaDir, baseName) .. '.lua'
          moonPath = Path.join(moonDir, baseName) .. '.moon'

          if shouldCompileMoonFile(moonPath, luaPath)
            compileMoon(moonPath, luaPath)

            -- Also delete it from the package cache so the next time require(baseName)
            -- is called, it will load the new file
            package.loaded[baseName] = nil
            numUpdated += 1

    if numUpdated == 0
      Output("Compile finished with zero updates")
      --Output("Compiled #{numUpdated} moon files")

return MoonScriptCompiler
