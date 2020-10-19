let s:save_cpo = &cpo
set cpo&vim
if has('patch-8.1.1116')
  scriptversion 3
endif

if get(g:, 'charsearch_loaded', 0)
  finish
endif

if get(g:, 'charsearch_plugmaps', 1)
  nnoremap <silent><expr> <Plug>(charsearch#f) charsearch#('%s', '/')
  xnoremap <silent><expr> <Plug>(charsearch#f) charsearch#('%s', '/')
  onoremap <silent><expr> <Plug>(charsearch#f) charsearch#('%s', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#f) charsearch#('%s\zs', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#F) charsearch#('%s', '?')
  xnoremap <silent><expr> <Plug>(charsearch#F) charsearch#('%s', '?')
  onoremap <silent><expr> <Plug>(charsearch#F) charsearch#('%s', 'b', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#F) charsearch#('%s\zs', 'b', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#t) charsearch#('\_.\ze%s', '/')
  xnoremap <silent><expr> <Plug>(charsearch#t) charsearch#('\_.\ze%s', '/')
  onoremap <silent><expr> <Plug>(charsearch#t) charsearch#('\_.\ze%s', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#t) charsearch#('\.\zs%s', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#T) charsearch#('%s\zs\_.', '?')
  xnoremap <silent><expr> <Plug>(charsearch#T) charsearch#('%s\zs\_.', '?')
  onoremap <silent><expr> <Plug>(charsearch#T) charsearch#('%s\zs\_.', 'b', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#T) charsearch#('\zs%s', 'b', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#s) charsearch#('%s%s', '/')
  xnoremap <silent><expr> <Plug>(charsearch#s) charsearch#('\_.\ze%s%s', '/')
  onoremap <silent><expr> <Plug>(charsearch#s) charsearch#('\_.\ze%s%s', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#s) charsearch#('%s%s', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#S) charsearch#('%s%s', '?')
  xnoremap <silent><expr> <Plug>(charsearch#S) charsearch#('%s%s\zs', '?')
  onoremap <silent><expr> <Plug>(charsearch#S) charsearch#('%s%s\zs', 'b', 'prefix:v')
  inoremap <silent><expr> <Plug>(charsearch#S) charsearch#('%s%s', 'b', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#n) charsearch#n('n')
  xnoremap <silent><expr> <Plug>(charsearch#n) charsearch#n('n', 'prefix:gv')
  onoremap <silent><expr> <Plug>(charsearch#n) charsearch#n('n')
  inoremap <silent><expr> <Plug>(charsearch#n) charsearch#n('n', "prefix:\<C-\>\<C-O>")

  nnoremap <silent><expr> <Plug>(charsearch#N) charsearch#n('N')
  xnoremap <silent><expr> <Plug>(charsearch#N) charsearch#n('N', 'prefix:gv')
  onoremap <silent><expr> <Plug>(charsearch#N) charsearch#n('N')
  inoremap <silent><expr> <Plug>(charsearch#N) charsearch#n('N', "prefix:\<C-\>\<C-O>")
endif

if get(g:, 'charsearch_autohldisable', 1)
  noremap  <expr> <Plug>(charsearch#nohl) (v:hlsearch && searchpos(@/, 'cnz', line('.'))[1] != getcurpos()[2] && execute('nohlsearch'))[-1]
  noremap! <expr> <Plug>(charsearch#nohl) (v:hlsearch && searchpos(@/, 'cnz', line('.'))[1] != getcurpos()[2] && execute('nohlsearch'))[-1]

  nnoremap <expr> <Plug>(charsearch#togglehl) execute(v:hlsearch ? 'nohlsearch' : 'set hlsearch')[-1]

  augroup plugin_search
    au!
    au InsertEnter,CursorMoved * call feedkeys("\<Plug>(charsearch#nohl)\<Ignore>")
  augroup END
endif

let g:charsearch_loaded = 1

let &cpo = s:save_cpo
