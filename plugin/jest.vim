" Author: t_t <jamestthompson3@gmail.com>
" Description: Vim editor bindings for the Jest testing library
"

let g:jest_use_global = 0
" let g:jest_javascript_executable = 0
" Runs jobs in the terminal using QFList dimensions
function! s:run_term(jobString)
  execute ':copen'
  call termopen(a:jobString)
endfunction

" Filters out unnecessary strings related to running tests
function! s:no_yarn(idx, value)
  let l:filtered_words = ['yarn', 'lib', 'Done', '$']
  if len(filter(l:filtered_words, {idx, val -> stridx(a:value, val) >= 0})) > 0
    return 0
  else
    return 1
  endif
endfunction

function! s:get_jest_executable(buffer) abort
  let l:executable = jest#utils#FindNodeExecutable(a:buffer, 'javascript', [
        \ 'node_modules/.bin/jest',
        \])
  return l:executable
endfunction

" Prepares a list of items to be pushed to the QFList
function! s:prep_qf(id, value)
  let l:qf_item = {}
  let l:trimmed = s:str_trim(a:value)
  let l:qf_item.filename = l:trimmed
  return l:qf_item
endfunction

" Trims JSON strings
function! s:str_trim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

function! JestTest(file_name)
    let l:pos = stridx(a:file_name, ' ')
    let l:file_path = a:file_name[l:pos+1:-1]
    call s:run_term(printf('%s %s', s:get_jest_executable(bufnr('%')), substitute(l:file_path, '\\', '/', 'g')))
endfunction

function! RunJest() abort
  let l:executable = s:get_jest_executable(bufnr('%'))
  call s:run_term(l:executable)
endfunction

function! JestWatch() abort
  let l:executable = s:get_jest_executable(bufnr('%'))
  call s:run_term(printf('%s, --watch',l:executable))
endfunction


" Lists all tests found in the project, takes an argument of what to do with
" said list, defaults to populating the QFList
function! JestList() abort
  let l:callbacks = {
    \ 'on_stdout': 'OnEvent',
    \ 'on_exit': 'OnExit'
    \ }
  let s:jest_list = ['']

  function! OnExit(job_id, data, event)
    let l:trimmed_values = filter(s:jest_list, function('s:no_yarn'))
      if exists('g:Jest_list_callback')
        call g:Jest_list_callback(l:trimmed_values)
      else
        call setqflist(map(l:trimmed_values, function('s:prep_qf')))
        exec ':copen'
      endif
  endfunction

  function! OnEvent(job_id, data, event)
    let s:jest_list[-1] .= a:data[0]
    call extend(s:jest_list, a:data[1:])
  endfunction

  call jobstart(printf('%s --listTests', s:get_jest_executable(bufnr('%'))), l:callbacks)
endfunction

function! RunCurrentFile() abort
  let l:fileName = expand('%:t')
  call s:run_term(printf('%s jest %s', s:get_jest_executable(bufnr('%')) l:fileName))
endfunction

nmap <silent>rcf :call RunCurrentFile()<CR>
