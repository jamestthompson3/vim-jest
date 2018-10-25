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
    call s:run_term(printf('yarn jest %s', substitute(l:file_path, '\\', '/', 'g')))
endfunction

" Lists all tests found in the project, takes an argument of what to do with
" said list, defaults to populating the QFList
function! JestList() abort
  let l:callbacks = {
    \ 'on_stdout': 'OnEvent',
    \ 'on_exit': 'OnExit'
    \ }
  let s:jest_list = ['']

  "TODO Make callback plugable
  function! OnExit(job_id, data, event)
    let l:trimmed_values = filter(s:jest_list, function('s:no_yarn'))
    echom get(g:, 'jest_list_callback')
    " if get(g:, 'jest_list_callback')
      " echom "callback found"
      call g:jest_list_callback(l:trimmed_values)
      " setqflist(map(l:trimmed_values, function('s:prep_qf'))))
          " else
      " echom No callback found"
      " call
      " exec ':copen'
    " endif
  endfunction

  function! OnEvent(job_id, data, event)
    let s:jest_list[-1] .= a:data[0]
    call extend(s:jest_list, a:data[1:])
  endfunction

  call jobstart('yarn jest --listTests', l:callbacks)
endfunction

function! RunCurrentFile() abort
  let l:fileName = expand('%:t')
  call runTerm(printf('yarn jest %s', l:fileName))
endfunction

nmap <silent>rcf :call RunCurrentFile()<CR>
