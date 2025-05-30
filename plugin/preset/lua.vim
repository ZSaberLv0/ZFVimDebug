if exists("g:ZFDebug_preset['lua']")
    finish
endif

function! ZFDebug_preset_lua(param)
    let preset = get(a:param, 'preset', '')
    let path = get(a:param, 'path', '')
    let args = get(a:param, 'args', [])
    return {
                \   'ZFDebug' : {
                \     'adapter' : 'lua-local',
                \     'configuration' : {
                \       'request' : 'launch',
                \       'program' : {
                \         'lua' : path,
                \         'file' : join(args, ' '),
                \       },
                \       'args' : args,
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
let g:ZFDebug_preset['lua'] = function('ZFDebug_preset_lua')

