
function! MoonScriptCompiler#Compile(verbose)
    if a:verbose
        lua require("MoonScriptCompiler").compile(true)
    else
        lua require("MoonScriptCompiler").compile(false)
    endif
endfunction

nnoremap <plug>(CompileMoonScript) :<c-u>call MoonScriptCompiler#Compile(1)<cr>

command! -bang -nargs=0 CompileMoonScript call MoonScriptCompiler#Compile(1)

call MoonScriptCompiler#Compile(0)

