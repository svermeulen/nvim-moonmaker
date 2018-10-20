
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

  getDirectory: (path) ->
    return path\match('^(.*)[\\/][^\\/]*$')

File =
  exists: (path) ->
    return io.open(path, 'r') != nil

  getModificationTime: (path) ->
    return vim.api.nvim_call_function('getftime', {path})

Directory =
  getAllFilesWithExtensionRecursive: (path, extension) ->
    return [Path.normalize(x) for x in *vim.api.nvim_call_function('globpath', {path, "**/*.#{extension}", 0, 1})]

tableContains = (table, element) ->
  for value in *table
    if value == element then
      return true

  return false

deleteOrphanedLuaFiles = (validBaseNames, pluginRoot, verbose) ->
  luaDir = Path.join(pluginRoot, 'lua')

  for filePath in *Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')
    baseName = filePath\sub(#luaDir + 2)
    baseName = baseName\sub(0, #baseName - 4)

    if not tableContains(validBaseNames, baseName)
      os.remove(fullPath)
      if verbose
        vim.api.nvim_command("echo 'Deleted file #{filePath} since it had no matching moon file'")

shouldCompileMoonFile = (moonPath, luaPath) ->
  if not File.exists(luaPath)
    return true

  luaTime = File.getModificationTime(luaPath)
  moonTime = File.getModificationTime(moonPath)

  return moonTime > luaTime

compileMoon = (moonPath, luaPath) ->
  dirPath = Path.getDirectory(luaPath)
  vim.api.nvim_command("call mkdir('#{dirPath}', 'p')")
  output = vim.api.nvim_call_function("system", { "moonc -o \"#{luaPath}\" -n \"#{moonPath}\"" })

  if vim.api.nvim_eval('v:shell_error') != 0
    vim.api.nvim_command("echoerr 'Errors occurred when executing moonc for file \"#{moonPath}\"'")
    -- Can we safely print the output here?

MoonScriptCompiler =
  compile: (verbose) ->
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
        deleteOrphanedLuaFiles(moonBaseNames, pluginRoot, verbose)

        luaDir = Path.join(pluginRoot, 'lua')

        for baseName in *moonBaseNames
          luaPath = Path.join(luaDir, baseName) .. '.lua'
          moonPath = Path.join(moonDir, baseName) .. '.moon'

          if shouldCompileMoonFile(moonPath, luaPath)
            compileMoon(moonPath, luaPath)

            if verbose
              vim.api.nvim_command("echo 'Compiled file #{moonPath}'")

            -- Also delete it from the package cache so the next time require(baseName)
            -- is called, it will load the new file
            package.loaded[baseName] = nil
            numUpdated += 1

    if verbose and numUpdated == 0
      vim.api.nvim_command("echo 'All moon files are already up to date'")

    return numUpdated

return MoonScriptCompiler
