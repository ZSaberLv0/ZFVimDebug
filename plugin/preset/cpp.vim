if exists("g:ZFDebug_preset['cpp']")
    finish
endif

function! ZFDebug_preset_cpp(param)
    let preset = get(a:param, 'preset', '')
    let path = get(a:param, 'path', '')
    let args = get(a:param, 'args', [])
    return {
                \   'ZFDebug' : {
                \     'adapter' : 'CodeLLDB',
                \     'configuration' : {
                \       'request' : 'launch',
                \       'program' : path,
                \       'args' : args,
                \       'stopOnEntry#json' : 'false',
                \       'expressions' : 'native',
                \     },
                \     'breakpoints' : {
                \       'exception' : {
                \         'raised' : '',
                \         'caught' : '',
                \         'uncaught' : '',
                \         'userUnhandled' : '',
                \         'all' : '',
                \         'cpp_catch' : '',
                \         'cpp_throw' : '',
                \       },
                \     },
                \   },
                \ }
endfunction

if !exists('g:ZFDebug_preset')
    let g:ZFDebug_preset = {}
endif
let g:ZFDebug_preset['cpp'] = function('ZFDebug_preset_cpp')

