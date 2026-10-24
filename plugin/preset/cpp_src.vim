if exists("g:ZFDebug_preset['cpp_src']")
    finish
endif

function! ZFDebug_preset_cpp_src_onExit(cfg)
    call ZFDebug_rm(a:cfg['cpp_src_tmpPath'])
endfunction

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
    call ZFDebug_rm(tmpPath)
    call mkdir(tmpPath, 'p')
    let compile = system(printf('%s -g -x c++ "%s" -o "%s/a.out"', cc, path, tmpPath))
    if v:shell_error != '0' && !empty(compile)
        echo compile
        return {}
    endif

    let wrap = deepcopy(a:param)
    let wrap['path'] = tmpPath . '/a.out'
    let cfg = ZFDebug_preset_cpp(wrap)
    if !empty(get(cfg, 'onExit', ''))
        return cfg
    endif
    let cfg['onExit'] = 'ZFDebug_preset_cpp_src_onExit'
    let cfg['cpp_src_tmpPath'] = tmpPath
    return cfg
endfunction

if !exists('g:ZFDebug_preset')
    let g:ZFDebug_preset = {}
endif
let g:ZFDebug_preset['cpp_src'] = function('ZFDebug_preset_cpp_src')

function! s:rm(f)
endfunction

