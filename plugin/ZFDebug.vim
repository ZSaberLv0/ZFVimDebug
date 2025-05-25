
function! ZF_Plugin_vimspector_openBreakpoints()
    VimspectorBreakpoints
    if &syntax == 'vimspector-breakpoints'
        nnoremap <silent><buffer> q :q<cr>
    endif
endfunction

if get(g:, 'zf_vimspector_keymap', 1)
    let g:vimspector_mappings = {
                \   'variables' : {
                \     'expand_collapse' : ['o', '<cr>'],
                \     'delete' : ['<del>'],
                \     'set_value' : ['cc'],
                \     'read_memory' : ['r'],
                \   },
                \   'stack_trace' : {
                \     'expand_or_jump' : ['o', '<cr>'],
                \     'focus_thread' : ['<leader><cr>'],
                \   },
                \   'breakpoints': {
                \     'toggle' : ['t'],
                \     'toggle_all' : ['T'],
                \     'delete' : ['dd', '<del>'],
                \     'edit' : ['cc', 'C'],
                \     'add_line' : ['i', 'a'],
                \     'add_func' : ['I', 'A'],
                \     'jump_to' : ['o', '<cr>'],
                \   },
                \ }

    nmap DB <Plug>VimspectorToggleBreakpoint
    nmap <silent> DV :call ZF_Plugin_vimspector_openBreakpoints()<cr>
    nmap DC :call vimspector#ClearBreakpoints()<cr>
    nmap DF <Plug>VimspectorBalloonEval
    nmap <f4> :call ZFDebugStop()<cr>
    nmap <f5> :call ZFDebugRestart()<cr>
    nmap DN :call vimspector#DownFrame()<cr>
    nmap <f6> :call vimspector#DownFrame()<cr>
    nmap DM :call vimspector#UpFrame()<cr>
    nmap <f7> :call vimspector#UpFrame()<cr>
    nmap DS <Plug>VimspectorContinue
    nmap <f8> <Plug>VimspectorContinue
    nmap Ds <Plug>VimspectorPause
    nmap DU <Plug>VimspectorStepOut
    nmap <f9> <Plug>VimspectorStepOut
    nmap DO <Plug>VimspectorStepOver
    nmap <f10> <Plug>VimspectorStepOver
    nmap DI <Plug>VimspectorStepInto
    nmap <f11> <Plug>VimspectorStepInto

    augroup zf_vimspector_keymap_VimspectorPrompt
        autocmd!
        autocmd FileType VimspectorPrompt
                    \ nmap <buffer> dd :call vimspector#DeleteWatch()<cr>
    augroup END
endif

" ============================================================
" {
"   // return a json object passed to vimspector#LaunchWithConfigurations()
"   'cpp' : function({
"         'preset' : 'cpp',
"         'path' : 'xxx',
"         'args' : ['xxx'],
"       }),
"   ...
" }
if !exists('g:ZFDebug_preset')
    let g:ZFDebug_preset = {}
endif

" ============================================================
function! ZFDebugRestart()
    call ZFDebugStop()

    let Fn_l_action = get(b:, 'ZFDebug_action', '')
    if !empty(Fn_l_action)
        call Fn_l_action()
    endif
    let l_preset = get(b:, 'ZFDebug_preset', '')
    let l_path = get(b:, 'ZFDebug_path', '')
    let l_args = get(b:, 'ZFDebug_args', '')
    if !empty(l_path)
        if empty(l_preset)
            let l_preset = ZFDebug_presetChoose()
            if empty(l_preset)
                return 0
            endif
            let b:ZFDebug_preset = l_preset
        endif
        call timer_start(500, function('s:ZFDebugRestartDelay', [{
                    \   'preset' : l_preset,
                    \   'path' : l_path,
                    \   'args' : l_args,
                    \   'saveState' : 0,
                    \ }]))
        return 1
    endif

    let preset = s:stateGet('ZFDebug_preset')
    let path = s:stateGet('ZFDebug_path')
    let args = !empty(s:stateGet('ZFDebug_args')) ? json_decode(s:stateGet('ZFDebug_args')) : []
    if !empty(preset) && !empty(path)
        call timer_start(500, function('s:ZFDebugRestartDelay', [{
                    \   'preset' : preset,
                    \   'path' : path,
                    \   'args' : args,
                    \   'saveState' : 1,
                    \ }]))
        return 1
    endif

    if ZFDebugSessionChoose() != 0
        return 1
    endif

    redraw
    echo 'no debug session, to start new one:'
    echo '    ZFDebug path [args]'
    echo '    ZFDebug! preset path [args]'
    return 0
endfunction
function! s:ZFDebugRestartDelay(params, ...)
    call ZFDebug(a:params)
endfunction

function! ZFDebugStop()
    silent! call vimspector#Stop()
    silent! call vimspector#Reset()
endfunction

command! -nargs=0 ZFDebugSessionChoose :call ZFDebugSessionChoose()
function! ZFDebugSessionChoose()
    let sessions = get(g:, 'ZFDebug_session', {})
    if len(sessions) == 0
        echo 'no session configured, use g:ZFDebug_session to config'
        return 0
    elseif len(sessions) == 1
        return ZFDebug(values(sessions)[0])
    endif
    let hints = []
    let names = keys(sessions)
    for i in range(len(names))
        let name = names[i]
        let param = sessions[name]
        call add(hints, printf('%s (%s)'
                    \ , name
                    \ , get(param, 'preset', '')
                    \ ))
    endfor
    let choice = ZFChoice('choose debug session:', hints)
    if choice < 0 || choice >= len(sessions)
        echo 'canceled'
        return -1
    endif
    return ZFDebug(sessions[names[choice]])
endfunction

command! -nargs=0 ZFDebugSessionClear :call ZFDebugSessionClear()
function! ZFDebugSessionClear()
    call s:stateSet('ZFDebug_preset', '')
    call s:stateSet('ZFDebug_path', '')
    call s:stateSet('ZFDebug_args', '')
    echo 'cleared, use :ZFDebug to start new one'
endfunction

command! -nargs=* -bang -complete=file ZFDebug :call ZFDebug(s:parseArgs(<q-bang>, <q-args>))
function! s:parseArgs(bang, args)
    let args = split(substitute(a:args, '\\ ', '_zf_space_', 'g'), ' ')
    if len(args) <= 0
        return {}
    endif
    if a:bang == '!'
        let preset = args[0]
        call remove(args, 0)
        if len(args) <= 0
            return {}
        endif
    else
        let preset = ''
    endif

    let path = substitute(args[0], '_zf_space_', ' ', 'g')
    call remove(args, 0)
    let i = 0
    while i < len(args)
        let args[i] = substitute(args[i], '_zf_space_', ' ', 'g')
        let i += 1
    endwhile
    return {
                \   'preset' : preset,
                \   'path' : path,
                \   'args' : args,
                \   'saveState' : 1,
                \ }
endfunction

" params: {
"   'preset' : '',
"   'path' : 'program path',
"   'args' : [...],
"   'saveState' : '1/0, whether to save last debug config',
" }
"
" you may also set buffer local vars to override config for local file:
"     let b:ZFDebug_preset = xxx
"     let b:ZFDebug_path = xxx
"     let b:ZFDebug_args = xxx
function! ZFDebug(params)
    if empty(a:params)
        return ZFDebugSessionChoose()
    endif

    let preset = get(a:params, 'preset', '')
    let path = get(a:params, 'path', '')
    let args = get(a:params, 'args', [])
    let saveState = get(a:params, 'saveState', 1)

    if empty(path)
        echo 'invalid program path'
        return 0
    endif
    let program = {
                \   'path' : fnamemodify(path, ':p'),
                \   'args' : args,
                \ }

    if empty(preset)
        let preset = ZFDebug_presetChoose()
        if empty(preset)
            return 0
        endif
    endif

    if saveState
        call s:stateSet('ZFDebug_preset', preset)
        call s:stateSet('ZFDebug_path', path)
        call s:stateSet('ZFDebug_args', json_encode(args))
    endif

    let Fn = g:ZFDebug_preset[preset]
    call vimspector#LaunchWithConfigurations(Fn({
                \   'preset' : preset,
                \   'path' : path,
                \   'args' : args,
                \ }))
    return 1
endfunction
function! ZFDebug_presetChoose()
    let candidates = keys(g:ZFDebug_preset)
    if empty(candidates)
        echo 'no configured debug preset'
        return ''
    endif
    let choice = ZFChoice('choose debug preset:', candidates)
    if choice < 0 || choice >= len(candidates)
        echo 'canceled'
        return ''
    endif
    return candidates[choice]
endfunction
function! ZFDebug_adapterChoose()
    let candidates = split(vimspector#CompleteInstall('', '', 0), "\n")
    let choice = ZFChoice('choose debug adapter:', candidates)
    if choice < 0 || choice >= len(candidates)
        echo 'canceled'
        return ''
    endif
    return candidates[choice]
endfunction

function! s:stateSet(key, value)
    execute printf('let s:%s = a:value', a:key)
endfunction
function! s:stateGet(key)
    return get(s:, a:key, '')
endfunction

