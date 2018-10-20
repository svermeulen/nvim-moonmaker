
## Moonscript Plugin Support

This plugin adds support for writing moonscript plugins much more easily in Neovim.

Install via vim-plug by adding this to your init.vim

```
Plug 'svermeulen/nvim-moonscript-plugin-example'
```

Then all you need to do is place .moon files in a 'moon' directory inside any plugin directory that is on the vim `&runtimepath`.  Compilation occurs at startup or whenever `MoonScriptCompiler#Compile()` is called.  Note that it will only compile the moon files that are out of date (ie. those moon files with a greater file modification time then the corresponding lua file).

You can then use the lua 'require()' method to lazily load and call your lua code from vim script.

See [here](https://github.com/svermeulen/nvim-moonscript-plugin-example) for an simple example

Note that when you are actually ready to distribute your plugin, you don't need to depend on this plugin, since you can just include the compiled lua files.

