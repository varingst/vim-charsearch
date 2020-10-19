let s:save_cpo = &cpo
set cpo&vim
if has('patch-8.1.1116')
  scriptversion 3
endif

let s:sugar = extend({
      \ '\': '\\',
      \ "\<C-U>": '\u',
      \ "\<C-L>": '\U',
      \}, get(g:, 'charsearch_sugar', {}))

let s:prefix = extend({
      \ "\<BS>": '\^',
      \ "\<C-W>": '\<',
      \ "\<Tab>": {-> '\^'..matchstr(getline('.'), '^[ \t]*') },
      \}, get(g:, 'charsearch_sugar_prefix', {}))

let s:suffix = extend({
      \ "\<CR>": '\$',
      \ "\<C-E>": '\>',
      \}, get(g:, 'charsearch_sugar_suffix', {}))

let s:cancel = extend([
      \ "\<ESC>",
      \ "\<C-C>",
      \], get(g:, 'charsearch_cancel', []))

let s:pattern_prefix = get(g:, 'charsearch_pattern_prefix', '\V\C')
let s:normal_n = get(g:, 'charsearch_normal_n', 0)

fun! charsearch#(pattern, ...)
  " if a:000 includes:
  " '/' => forward highlighted search
  " '?' => backward highlighted search
  " 'b' => backward search()
  " 'prefix:foo' => 'foo' is prefixed on the returned <expr> mapping
  " 'suffix:foo' => 'foo' is suffixed on the returned <expr> mapping
  "
  " default is a forward search()
  " 'prefix:v' makes a :call search() inclusive
  try
    let @/ = s:getcharf(a:pattern)
  catch /cancel/
    return ''
  endtry

  let [
        \   hlsearch,
        \   prefix,
        \   suffix,
        \   bflag
        \ ] = s:findargs(a:000,
        \   "v:val =~ '[/?]'",
        \   "v:val =~ '^prefix:'",
        \   "v:val =~ '^suffix:'",
        \   "v:val == 'b'")

  let [prefix, suffix] = s:stripfix([prefix, suffix])
  if !empty(hlsearch)
    return prefix..hlsearch.."\<CR>"..suffix
  endif

  let flags = 'W'..bflag

  fun! s:search() closure
    let c = v:count1
    while c
      call search(@/, flags)
      let c -= 1
    endwhile
  endfun

  return printf("%s:\<C-U>silent! call %ssearch()\<CR>%s", prefix, s:sid, suffix)
endfun

fun! charsearch#n(n, ...)
  " TODO: search(..., 'b') does not set v:searchforward 0
  let [prefix, suffix] = s:findargs(a:000, "v:val =~ '^prefix:'", "v:val =~ '^suffix:'")->s:stripfix()
  let relative_n = a:n ==# 'n'
        \ ? v:searchforward ? 'n' : 'N'
        \ : v:searchforward ? 'N' : 'n'

  return printf(":\<C-U>keepjumps normal! %s%d%s%s\<CR>",
        \ prefix,
        \ v:count1,
        \ s:normal_n ? a:n : relative_n,
        \ suffix)
endfun

fun! s:getcharf(fmt)
  let n = s:matchcount(a:fmt, '%s')
  let pre = ''
  let suff = ''
  let chars = []

  while n
    let c = s:getchar()

    if index(s:cancel, c) != -1
      throw 'cancel'
    endif

    let c = pre..s:desugar(s:sugar, c, c)..suff

    let pre = s:desugar(s:prefix, c, '')
    let suff = s:desugar(s:suffix, c, '')

    if empty(pre) && empty(suff)
      call add(chars, c)
      let n -= 1
    endif
  endwhile

  return call('printf', [s:pattern_prefix..a:fmt] + chars)
endfun

fun! s:desugar(dict, c, def)
  let C = get(a:dict, a:c, a:def)
  return type(C) is v:t_func ? C() : C
endfun

fun! s:matchcount(expr, pat)
  let n = 0
  let pos = match(a:expr, a:pat)

  while pos != -1
    let n += 1
    let pos = match(a:expr, a:pat, pos + 1)
  endwhile

  return n
endfun

fun! s:getchar()
  let c = getchar()

  while c == "\<CursorHold>"
    let c = getchar()
  endwhile

  return type(c) is v:t_number
        \ ? nr2char(c)
        \ : c
endfun

fun! s:findargs(args, ...)
  return map(copy(a:000), 'copy(a:args)->filter(v:val)')
        \ ->map("empty(v:val) ? '' : v:val[0]")
endfun

fun! s:stripfix(fixes)
  return a:fixes->map({ _, s -> matchstr(s, '^\(prefix\|suffix\):\zs.*')})
endfun

" vimscript <3
fun! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfun
let s:sid = s:SID()
delfun! s:SID

let &cpo = s:save_cpo
