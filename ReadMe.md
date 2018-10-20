
## Moonscript Plugin Support

This plugin adds support for writing moonscript plugins much more easily in Neovim.

Install via vim-plug by adding this to your init.vim.

```
Plug 'svermeulen/nvim-moonscript-plugin-support'
```

Then all you need to do is place `.moon` files in a 'moon' directory inside any plugin directory that is on the vim `&runtimepath`.  This follows the same convention that Neovim uses for other file types.  Neovim supports python and lua out of the box by expecting them to be placed in `'&rtp/lua'` and `&rtp/python3` directories, however, despite early plans to support MoonScript, this was never added (hence this plugin).

Compilation occurs at Neovim startup or whenever manually executed by one of the methods below.  Note that it will only compile the moon files that are out of date (ie. those moon files with a greater file modification time then the corresponding lua file).

You can then use the lua `require()` method to lazily load and call your lua code from vim script.

See [here](https://github.com/svermeulen/nvim-moonscript-plugin-example) for an simple example.

Note that when you are actually ready to distribute your plugin, you don't need to depend on this plugin, since you can just include the compiled lua files.

Note also that you need to install moonscript for this to work.  The `moonc` executable needs to be on the PATH.

After editting your moon files, you can update them manually by calling the command `:CompileMoonScript`.  You can also add a binding by doing something like `nmap <leader>cm <plug>(CompileMoonScript)` in your `init.vim`.  After manually calling one of these, if any `.moon` files in any plugin directory are out of date, they will be compiled.  The require cache for each updated lua file will also be cleared so that the next time you call require you will get the latest version.

