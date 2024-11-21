if exists("g:ZFDebug_preset['python']")
    finish
endif

function! ZFDebug_preset_python(param)
    let preset = get(a:param, 'preset', '')
    let path = get(a:param, 'path', '')
    let args = get(a:param, 'args', [])
    return {
                \   'ZFDebug' : {
                \     'adapter' : 'debugpy',
                \     'configuration' : {
                \       'request' : 'launch',
                \       'python' : path,
                \       'program' : join(args, ' '),
                \       'cwd' : getcwd(),
                \       'stopOnEntry#json' : 'false',
                \     },
                \     'breakpoints' : {
                \       'exception' : {
                \         'raised' : '',
                \         'caught' : '',
                \         'uncaught' : '',
                \         'userUnhandled' : '',
                \         'all' : '',
                \       },
                \     },
                \   },
                \ }
endfunction

if !exists('g:ZFDebug_preset')
    let g:ZFDebug_preset = {}
endif
let g:ZFDebug_preset['python'] = function('ZFDebug_preset_python')

