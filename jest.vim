let s:callbacks = {
    \ 'on_stdout': 'OnEvent',
    \ 'on_exit': 'OnExit'
    \ }

function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

function! s:noYarn(idx, value)
    let l:filtered_words = ['yarn', 'lib', 'Done', '$']
    if len(filter(l:filtered_words, {idx, val -> stridx(a:value, val) >= 0})) > 0
      return 0
    else
      return 1
    endif
  endfunction


function! s:run_tests(item)
    let l:pos = stridx(a:item, ' ')
    let l:file_path = a:item[l:pos+1:-1]
    execute ':!yarn jest' substitute(l:file_path, '\\', '/', 'g')
endfunction

function! JestList() abort

  let s:jest_list = ['']

  function! s:prepQF(id, value)
    let l:qfItem = {}
    let l:trimmed = StrTrim(a:value)
    let l:qfItem.filename = l:trimmed
    return l:qfItem
  endfunction

 function! OnExit(job_id, data, event)
   let l:trimmed_values = map(filter(s:jest_list, function('s:noYarn')), function('s:prepQF'))

   call setqflist(l:trimmed_values)
   exec ':copen'

    " call fzf#run({
    "     \ 'source': filter(l:trimmed_values, function('NoYarn')),
    "     \ 'sink':   function('s:run_tests'),
    "     \ 'options': '-m',
    "     \ 'down': '40%'
    "     \ })
    " call feedkeys('i')
 endfunction

 function! OnEvent(job_id, data, event)
    let s:jest_list[-1] .= a:data[0]
    call extend(s:jest_list, a:data[1:])
 endfunction
 call jobstart('yarn jest --listTests', s:callbacks)
endfunction
