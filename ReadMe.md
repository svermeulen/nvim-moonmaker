
## MoonMaker

<img align="right" width="268" height="214" src="https://i.imgur.com/gCDNsfH.png">

This plugin adds support for writing moonscript plugins in Neovim

Install via vim-plug by adding this to your init.vim.

```
Plug 'svermeulen/nvim-moonmaker'
```

Then all you need to do is place `.moon` files in a 'moon' directory inside any plugin directory that is on the vim `&runtimepath` and they will automatically compiled and available to be loaded.

This follows the same convention that Vim uses for other file types.  For example, if you place `Foo.py` inside a directory named 'python3' (underneath the root directory of your plugin) then it can be loaded by executing `:python3 import Foo`.  

And similar rules apply to lua (that is, they are expected to be placed underneath a 'lua' directory).   However, despite early plans to do so, direct MoonScript was never added to Neovim (hence this plugin).

So all this plugin really does is keep the lua directory in sync with the corresponding moon directory for every plugin on the runtimepath.

Compilation occurs at Neovim startup or whenever manually executed by one of the methods below.  Note that it will only compile the moon files that are out of date (ie. those moon files with a greater file modification time then the corresponding lua file).

You can then use the lua `require()` method to lazily load and call your lua code from vim script or from other moonscript/lua files.

See [here](https://github.com/svermeulen/nvim-moonmaker-example) for an simple example.

After editting your moon files, you can update them manually by any of the following methods:
- Calling the command `:MoonCompile`
- Binding something to `<plug>(MoonCompile)` (eg: `nmap <leader>cm <plug>(MoonCompile)`)
- Calling `moonmaker#compile()` from VimL

After manually calling one of these, if any `.moon` files in any plugin directory are out of date, they will be compiled.  The require cache for each updated lua file will also be cleared so that the next time you call require you will get the latest version.

More things to be aware of:
- If you want to execute some moonscript code you can use the included `:Moon` command.  For example:  `:Moon print('hello')` or `:Moon require('Foo').doThing!`
- When you are actually ready to distribute your plugin, you don't need to depend on this plugin, since you can just include the compiled lua files
- You need to install moonscript for this to work.  The `moonc` executable needs to be on the PATH.
- If your plugin contains multiple moon files and you want to avoid polluting the root require path, you can put your moon files into subdirectories underneath the moon folder.  Then you can use `require("dir1.dir2.filename")` to use them from other moonscript files
- Make sure to place this plugin earlier in the list of plugins with whatever plugin manager you're using, so that the lua files will be compiled as soon as possible.  This would be important if you're calling lua code during startup from one of your own plugins.
- Currently only Neovim is supported however Vim support could be added too
