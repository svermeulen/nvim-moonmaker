
## Moonscript Plugin Support

This plugin adds support for writing moonscript plugins much more easily in Neovim.

All you need to do is place .moon files in a 'moon' directory on the runtimepath, and they will be automatically compiled into the 'lua' directory.  Compilation occurs at startup or whever `MoonScriptCompiler#Compile()` is called.  Note that it will only compile the moon files that are out of date (aka those moon files with a greater file modification time then the corresponding lua file).

You can then use the lua 'require()' method to lazily load and call your code from vim script.

