
local Path = {   join = function(left, right)

    local result = left
    local lastChar = left:sub(-1)

    if lastChar ~= '/' and lastChar ~= '\\' then
      result = result .. '/'     end

    result = result .. right
    return result   end,   normalize = function(path)


    local result = string.gsub(path, "\\", "/")

    if result:sub(-1) == '/' then
      result = result:sub(0, #result - 1)     end

    return result   end,   getDirectory = function(path)


    return path:match('^(.*)[\\/][^\\/]*$')   end }

local File = {   exists = function(path)

    return io.open(path, 'r') ~= nil   end,   getModificationTime = function(path)


    return vim.api.nvim_call_function('getftime', {       path     })   end,   delete = function(path)


    return vim.api.nvim_call_function('delete', {       path     })   end }

local Directory = {   getAllFilesWithExtensionRecursive = function(path, extension)     local _accum_0 = { }     local _len_0 = 1

    local _list_0 = vim.api.nvim_call_function('globpath', {       path,       "**/*." .. tostring(extension),       0,       1     })     for _index_0 = 1, #_list_0 do       local x = _list_0[_index_0]       _accum_0[_len_0] = Path.normalize(x)       _len_0 = _len_0 + 1     end     return _accum_0   end }

local tableContains tableContains = function(table, element)
  for _index_0 = 1, #table do     local value = table[_index_0]
    if value == element then
      return true     end   end

  return false end

local deleteOrphanedLuaFiles deleteOrphanedLuaFiles = function(validBaseNames, pluginRoot, verbose)
  local luaDir = Path.join(pluginRoot, 'lua')

  local _list_0 = Directory.getAllFilesWithExtensionRecursive(luaDir, 'lua')   for _index_0 = 1, #_list_0 do     local filePath = _list_0[_index_0]
    local baseName = filePath:sub(#luaDir + 2)
    baseName = baseName:sub(0, #baseName - 4)

    if not tableContains(validBaseNames, baseName) then
      File.delete(filePath)
      if verbose then
        vim.api.nvim_command("echo 'Deleted file " .. tostring(filePath) .. " since it had no matching moon file'")       end     end   end end

local shouldCompileMoonFile shouldCompileMoonFile = function(moonPath, luaPath)
  if not File.exists(luaPath) then
    return true   end

  local luaTime = File.getModificationTime(luaPath)
  local moonTime = File.getModificationTime(moonPath)

  return moonTime > luaTime end

local compileMoon compileMoon = function(moonPath, luaPath)
  local dirPath = Path.getDirectory(luaPath)
  vim.api.nvim_command("call mkdir('" .. tostring(dirPath) .. "', 'p')")
  local output = vim.api.nvim_call_function("system", {     "moonc -o \"" .. tostring(luaPath) .. "\" -n \"" .. tostring(moonPath) .. "\""   })

  if vim.api.nvim_eval('v:shell_error') ~= 0 then
    return vim.api.nvim_command("echoerr 'Errors occurred when executing moonc for file \"" .. tostring(moonPath) .. "\"'")   end end


local MoonScriptCompiler = {   compile = function(verbose)

    local rtp = vim.api.nvim_eval('&rtp')     local paths     do       local _accum_0 = { }       local _len_0 = 1
      for x in string.gmatch(rtp, "([^,]+)") do         _accum_0[_len_0] = Path.normalize(x)         _len_0 = _len_0 + 1       end       paths = _accum_0     end

    local numUpdated = 0

    for _index_0 = 1, #paths do       local pluginRoot = paths[_index_0]
      local moonBaseNames = { }
      local moonDir = Path.join(pluginRoot, 'moon')

      local _list_0 = Directory.getAllFilesWithExtensionRecursive(moonDir, 'moon')       for _index_1 = 1, #_list_0 do         local filePath = _list_0[_index_1]
        local baseName = filePath:sub(#moonDir + 2)
        baseName = baseName:sub(0, #baseName - 5)
        table.insert(moonBaseNames, baseName)       end

      if #moonBaseNames > 0 then
        deleteOrphanedLuaFiles(moonBaseNames, pluginRoot, verbose)

        local luaDir = Path.join(pluginRoot, 'lua')

        for _index_1 = 1, #moonBaseNames do           local baseName = moonBaseNames[_index_1]
          local luaPath = Path.join(luaDir, baseName) .. '.lua'
          local moonPath = Path.join(moonDir, baseName) .. '.moon'

          if shouldCompileMoonFile(moonPath, luaPath) then
            compileMoon(moonPath, luaPath)

            if verbose then
              vim.api.nvim_command("echo 'Compiled file " .. tostring(moonPath) .. "'")             end



            package.loaded[baseName] = nil
            numUpdated = numUpdated + 1           end         end       end     end

    if verbose and numUpdated == 0 then
      vim.api.nvim_command("echo 'All moon files are already up to date'")     end

    return numUpdated   end }

return MoonScriptCompiler

