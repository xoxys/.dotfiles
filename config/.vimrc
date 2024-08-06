set nocompatible
syntax on
set encoding=utf-8
set nonumber
set background=dark
set tabstop=2 shiftwidth=2 expandtab
set softtabstop=2
set hlsearch
set ignorecase
set mouse-=a

augroup eventtypemappings
autocmd!
autocmd BufWrite * execute "normal! mz" |  keeppatterns %s/\v\s+$//e | normal `z

augroup END
