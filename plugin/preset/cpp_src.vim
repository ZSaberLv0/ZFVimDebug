if exists("g:ZFDebug_preset['cpp_src']")
    finish
endif

function! ZFDebug_preset_cpp_src(param)
    let preset = get(a:param, 'preset', '')
    let path = get(a:param, 'path', '')
    let args = get(a:param, 'args', [])
    if 0
    elseif executable('g++')
        let cc = 'g++'
    elseif executable('clang')
        let cc = 'clang'
    else
        echo 'no compiler available'
        return {}
    endif

    let tmpPath = tempname()
    if (has('win32') || has('win64')) && !has('unix')
        call system('del /s/q "' . substitute(tmpPath, '/', '\', 'g') . '"')
        call system('rmdir /f/s/q "' . substitute(tmpPath, '/', '\', 'g') . '"')
    else
        call system('rm -rf "' . tmpPath . '"')
    endif
    call mkdir(tmpPath, 'p')
    let compile = system(printf('%s -g -x c++ "%s" -o "%s/a.out"', cc, path, tmpPath))
    if v:shell_error != '0' && !empty(compile)
        echo compile
        return {}
    endif

    let wrap = deepcopy(a:param)
    let wrap['path'] = tmpPath . '/a.out'
    return ZFDebug_preset_cpp(wrap)
endfunction

if !exists('g:ZFDebug_preset')
    let g:ZFDebug_preset = {}
endif
let g:ZFDebug_preset['cpp_src'] = function('ZFDebug_preset_cpp_src')

