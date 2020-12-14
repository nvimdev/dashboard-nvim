" Plugin:      https://github.com/hardcoreplayers/dashboard-nvim
" Description: A fancy start screen for Vim.
" Maintainer:  Glepnir <http://github.com/glepnir>
"
function! dashboard#fzf#find_file() abort
  Files
endfunction

function! dashboard#fzf#find_history() abort
  History
endfunction

function! dashboard#fzf#change_colorscheme() abort
  Colors
endfunction

function! dashboard#fzf#find_word() abort
  if g:dashboard_fzf_engine == 'rg'
    Rg
  elseif g:dashboard_fzf_engine == 'ag'
    Ag
  endif
endfunction

function! dashboard#fzf#book_marks() abort
  Marks
endfunction

if g:dashboard_fzf_window == 1
    let $FZF_DEFAULT_OPTS='--layout=reverse'
    if !exists('g:dashboard_fzf_window_rate')
      let g:dashboard_fzf_window_rate = 0.9
    endif

    fu s:snr() abort
        return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
    endfu

    let s:snr = get(s:, 'snr', s:snr())
    let g:fzf_layout = {'window': 'call '..s:snr..'fzf_window(0.9, 0.6, "Comment")'}

    fu s:fzf_window(width, height, border_highlight) abort
        let width = float2nr(&columns * a:width)
        let height = float2nr(&lines * a:height)
        let row = float2nr((&lines - height) / 2)
        let col = float2nr((&columns - width) / 2)
        let top = '┌' . repeat('─', width - 2) . '┐'
        let mid = '│' . repeat(' ', width - 2) . '│'
        let bot = '└' . repeat('─', width - 2) . '┘'
        let border = [top] + repeat([mid], height - 2) + [bot]
        if has('nvim')
            let frame = s:create_float(a:border_highlight, {
                \ 'row': row,
                \ 'col': col,
                \ 'width': width,
                \ 'height': height,
                \ })
            call nvim_buf_set_lines(frame, 0, -1, v:true, border)
            call s:create_float('Normal', {
                \ 'row': row + 1,
                \ 'col': col + 2,
                \ 'width': width - 4,
                \ 'height': height - 2,
                \ })
            exe 'au BufWipeout <buffer> bw '..frame
        else
            let frame = s:create_popup_window(a:border_highlight, {
                \ 'line': row,
                \ 'col': col,
                \ 'width': width,
                \ 'height': height,
                \ 'is_frame': 1,
                \ })
            call setbufline(frame, 1, border)
            call s:create_popup_window('Normal', {
                \ 'line': row + 1,
                \ 'col': col + 2,
                \ 'width': width - 4,
                \ 'height': height - 2,
                \ })
        endif
    endfu

    fu s:create_float(hl, opts) abort
        let buf = nvim_create_buf(v:false, v:true)
        let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
        let win = nvim_open_win(buf, v:true, opts)
        call setwinvar(win, '&winhighlight', 'NormalFloat:'..a:hl)
        return buf
    endfu

    fu s:create_popup_window(hl, opts) abort
        if has_key(a:opts, 'is_frame')
            let id = popup_create('', #{
                \ line: a:opts.line,
                \ col: a:opts.col,
                \ minwidth: a:opts.width,
                \ minheight: a:opts.height,
                \ zindex: 50,
                \ })
            call setwinvar(id, '&wincolor', a:hl)
            exe 'au BufWipeout * ++once call popup_close('..id..')'
            return winbufnr(id)
        else
            let buf = term_start(&shell, #{hidden: 1})
            call popup_create(buf, #{
                \ line: a:opts.line,
                \ col: a:opts.col,
                \ minwidth: a:opts.width,
                \ minheight: a:opts.height,
                \ zindex: 51,
                \ })
            exe 'au BufWipeout * ++once bw! '..buf
        endif
    endfu
endif
