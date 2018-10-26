" Modified version of ALE's node utils
" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with Node executables.

let s:windows_node_executable_path = 'node.exe'

" Given a buffer and a filename, find the nearest file by searching upwards
" through the paths relative to the given buffer.
function! jest#utils#FindNearestFile(buffer, filename) abort
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')
    let l:buffer_filename = fnameescape(l:buffer_filename)

    let l:relative_path = findfile(a:filename, l:buffer_filename . '.;')

    if !empty(l:relative_path)
        return fnamemodify(l:relative_path, ':p')
    endif

    return ''
endfunction

" Given a buffer number, a base variable name, and a list of paths to search
" for in ancestor directories, detect the executable path for a Node program.
"
" The use_global and executable options for the relevant program will be used.
function! jest#utils#FindNodeExecutable(buffer, base_var_name, path_list) abort
    if g:jest_use_global
        return g:jest_global_executable
    endif

    for l:path in a:path_list
        let l:executable = jest#utils#FindNearestFile(a:buffer, l:path)

        if !empty(l:executable)
            return l:executable
        endif
    endfor

    return 'jest_executable'
endfunction

" As above, but curry the arguments so only the buffer number is required.
function! jest#utils#FindExecutableFunc(base_var_name, path_list) abort
    return {buf -> jest#utils#FindNodeExecutable(buf, a:base_var_name, a:path_list)}
endfunction

" Create a executable string which executes a Node.js script command with a
" Node.js executable if needed.
"
" The executable string should not be escaped before passing it to this
" function, the executable string will be escaped when returned by this
" function.
"
" The executable is only prefixed for Windows machines
function! jest#utils#Executable(buffer, executable) abort
    if has('win32') && a:executable =~? '\.js$'
        let l:node = s:windows_node_executable_path

        return s:Escape(l:node) . ' ' . s:Escape(a:executable)
    endif

    return s:Escape(a:executable)
endfunction

" Escape a string suitably for each platform.
" shellescape does not work on Windows.
function! s:Escape(str) abort
    if fnamemodify(&shell, ':t') is? 'cmd.exe'
        " If the string contains spaces, it will be surrounded by quotes.
        " Otherwise, special characters will be escaped with carets (^).
        return substitute(
        \   a:str =~# ' '
        \       ?  '"' .  substitute(a:str, '"', '""', 'g') . '"'
        \       : substitute(a:str, '\v([&|<>^])', '^\1', 'g'),
        \   '%',
        \   '%%',
        \   'g',
        \)
    endif

    return shellescape (a:str)
endfunction
