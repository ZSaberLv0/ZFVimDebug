
let s:presetPath = expand('<sfile>:p:h') . '/preset'

function! ZFDebugPresetEdit(...)
    let ft = get(a:, 1, &filetype)
    if empty(ft)
        echo 'filetype is required'
        return
    endif
    let path = printf('%s/%s.vim', s:presetPath, ft)
    execute 'edit ' . substitute(path, ' ', '\\ ', 'g')
    if line('$') <= 1
        let lines = [
                    \   'if exists("g:ZFDebug_preset[''<ft>'']")',
                    \   '    finish',
                    \   'endif',
                    \   '',
                    \   'function! ZFDebug_preset_<ft>(param)',
                    \   '    let preset = get(a:param, ''preset'', '''')',
                    \   '    let path = get(a:param, ''path'', '''')',
                    \   '    let args = get(a:param, ''args'', [])',
                    \   '    return {',
                    \   '                \   ''ZFDebug'' : {',
                    \   '                \     ''adapter'' : ''<YourAdapter>'',',
                    \   '                \     ''configuration'' : {',
                    \   '                \       ''request'' : ''launch'',',
                    \   '                \       ''program'' : path,',
                    \   '                \       ''args'' : args,',
                    \   '                \       ''cwd'' : getcwd(),',
                    \   '                \       ''stopOnEntry#json'' : ''false'',',
                    \   '                \     },',
                    \   '                \     ''breakpoints'' : {',
                    \   '                \       ''exception'' : {',
                    \   '                \         ''raised'' : '''',',
                    \   '                \         ''caught'' : '''',',
                    \   '                \         ''uncaught'' : '''',',
                    \   '                \         ''userUnhandled'' : '''',',
                    \   '                \         ''all'' : '''',',
                    \   '                \       },',
                    \   '                \     },',
                    \   '                \   },',
                    \   '                \ }',
                    \   'endfunction',
                    \   '',
                    \   'if !exists(''g:ZFDebug_preset'')',
                    \   '    let g:ZFDebug_preset = {}',
                    \   'endif',
                    \   'let g:ZFDebug_preset[''<ft>''] = function(''ZFDebug_preset_<ft>'')',
                    \   '',
                    \ ]
        for i in range(len(lines))
            let lines[i] = substitute(lines[i], '<ft>', ft, 'g')
        endfor
        call setline(1, lines)
        let @/='<YourAdapter>'
        silent! normal! n
    endif
endfunction
command! -nargs=? -complete=filetype ZFDebugPresetEdit :call ZFDebugPresetEdit(<f-args>)

