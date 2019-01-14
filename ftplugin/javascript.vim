nmap <silent>rcf :call RunCurrentFile()<CR>
command! -bang -nargs=0 JestList call JestList()
command! -bang -nargs=1 JestTest call JestTest(<args>)
