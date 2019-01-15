nmap <silent>rcf :call RunCurrentFile()<CR>
command! -bang -nargs=0 JestList call JestList()
command! -bang -nargs=1 -complete=file_in_path JestTest call JestTest(<args>)
