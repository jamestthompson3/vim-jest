# vim-jest
Neovim plugin for the jest testing library

## Available Functions
#### JestList

Lists all tests available by using `jest --listTests`. The default action for this is to populate the quickfix list.
However, you can cutomize this by using the `g:Jest_list_callback` variable.

#### RunJest

Runs all tests available by using `jest`. Opens a new terminal drawer to do so.

#### JestWatch

Starts jest in watch mode

#### JestTest

Tests only the file passed to it as an argument.

#### RunCurrentFile

Tests the current file loaded in the buffer. If the file is not a test file, it attempts to find all related tests to it and run those.

## Helpful Configurations
Load a list of all tests into FZF and run the selected test:
```viml
function! FuzzyJest(trimmed_values) abort
  call fzf#run({
        \ 'source': a:trimmed_values,
        \ 'sink':   function('JestTest'),
        \ 'options': '-m',
        \ 'down': '40%'
        \ })
    call feedkeys('i')
endfunction

function! ListTests() abort
  let g:Jest_list_callback = funcref('FuzzyJest')
  call JestList()
  unlet g:Jest_list_callback
endfunction
```
