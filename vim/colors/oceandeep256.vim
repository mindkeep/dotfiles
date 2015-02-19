" Vim color file

" This steals quite a bit of functionality from Henry So, Jr.
" <henryso@panix.com> 's desert256 theme and uses the colors of
" Chris Vertonghen <chris@vertonghen.org> 's oceanblack theme.
" I've then tweaked it to my preference.


set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="dave256"

if has("gui_running") || &t_Co == 88 || &t_Co == 256
    " functions {{{
    " returns an approximate grey index for the given grey level
    fun <SID>grey_number(x)
        if &t_Co == 88
            if a:x < 23
                return 0
            elseif a:x < 69
                return 1
            elseif a:x < 103
                return 2
            elseif a:x < 127
                return 3
            elseif a:x < 150
                return 4
            elseif a:x < 173
                return 5
            elseif a:x < 196
                return 6
            elseif a:x < 219
                return 7
            elseif a:x < 243
                return 8
            else
                return 9
            endif
        else
            if a:x < 14
                return 0
            else
                let l:n = (a:x - 8) / 10
                let l:m = (a:x - 8) % 10
                if l:m < 5
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun

    " returns the actual grey level represented by the grey index
    fun <SID>grey_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 46
            elseif a:n == 2
                return 92
            elseif a:n == 3
                return 115
            elseif a:n == 4
                return 139
            elseif a:n == 5
                return 162
            elseif a:n == 6
                return 185
            elseif a:n == 7
                return 208
            elseif a:n == 8
                return 231
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 8 + (a:n * 10)
            endif
        endif
    endfun

    " returns the palette index for the given grey index
    fun <SID>grey_color(n)
        if &t_Co == 88
            if a:n == 0
                return 16
            elseif a:n == 9
                return 79
            else
                return 79 + a:n
            endif
        else
            if a:n == 0
                return 16
            elseif a:n == 25
                return 231
            else
                return 231 + a:n
            endif
        endif
    endfun

    " returns an approximate color index for the given color level
    fun <SID>rgb_number(x)
        if &t_Co == 88
            if a:x < 69
                return 0
            elseif a:x < 172
                return 1
            elseif a:x < 230
                return 2
            else
                return 3
            endif
        else
            if a:x < 75
                return 0
            else
                let l:n = (a:x - 55) / 40
                let l:m = (a:x - 55) % 40
                if l:m < 20
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun

    " returns the actual color level for the given color index
    fun <SID>rgb_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 139
            elseif a:n == 2
                return 205
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 55 + (a:n * 40)
            endif
        endif
    endfun

    " returns the palette index for the given R/G/B color indices
    fun <SID>rgb_color(x, y, z)
        if &t_Co == 88
            return 16 + (a:x * 16) + (a:y * 4) + a:z
        else
            return 16 + (a:x * 36) + (a:y * 6) + a:z
        endif
    endfun

    " returns the palette index to approximate the given R/G/B color levels
    fun <SID>color(r, g, b)
        " get the closest grey
        let l:gx = <SID>grey_number(a:r)
        let l:gy = <SID>grey_number(a:g)
        let l:gz = <SID>grey_number(a:b)

        " get the closest color
        let l:x = <SID>rgb_number(a:r)
        let l:y = <SID>rgb_number(a:g)
        let l:z = <SID>rgb_number(a:b)

        if l:gx == l:gy && l:gy == l:gz
            " there are two possibilities
            let l:dgr = <SID>grey_level(l:gx) - a:r
            let l:dgg = <SID>grey_level(l:gy) - a:g
            let l:dgb = <SID>grey_level(l:gz) - a:b
            let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
            let l:dr = <SID>rgb_level(l:gx) - a:r
            let l:dg = <SID>rgb_level(l:gy) - a:g
            let l:db = <SID>rgb_level(l:gz) - a:b
            let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
            if l:dgrey < l:drgb
                " use the grey
                return <SID>grey_color(l:gx)
            else
                " use the color
                return <SID>rgb_color(l:x, l:y, l:z)
            endif
        else
            " only one possibility
            return <SID>rgb_color(l:x, l:y, l:z)
        endif
    endfun

    " returns the palette index to approximate the 'rrggbb' hex string
    fun <SID>rgb(rgb)

        if a:rgb == "000000"
            return "NONE"
        endif
        let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
        let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
        let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

        return <SID>color(l:r, l:g, l:b)
    endfun

    " sets the highlighting for the given group
    fun <SID>X(group, fg, bg, attr)
        if a:fg != ""
            exec "hi " . a:group . " guifg=#" . a:fg . " ctermfg=" . <SID>rgb(a:fg)
        endif
        if a:bg != ""
            exec "hi " . a:group . " guibg=#" . a:bg . " ctermbg=" . <SID>rgb(a:bg)
        endif
        if a:attr != ""
            exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
        endif
    endfun
    " }}}


    " GUI/cterm colors
    call <SID>X("Normal", "e0eee0", "000000", "")

    " highlight groups
    call <SID>X("Cursor", "96cdcd", "ffffff", "")
    "CursorIM
    "Directory
    call <SID>X("DiffAdd", "", "000055", "")
    call <SID>X("DiffChange", "", "550055", "")
    call <SID>X("DiffDelete", "", "0000aa", "")
    call <SID>X("DiffText", "", "770000", "")
    "ErrorMsg
    call <SID>X("VertSplit", "000000", "999999", "reverse")
    call <SID>X("Folded", "b0d0e0", "305060", "bold")
    call <SID>X("FoldColumn", "b0d0e0", "305060", "")
    call <SID>X("IncSearch", "", "", "reverse")
    "LineNr
    call <SID>X("ModeMsg", "90ee90", "006400", "")
    call <SID>X("MoreMsg", "2e8b57", "", "bold")
    call <SID>X("NonText", "87cefa", "000000", "")
    call <SID>X("Question", "4eee94", "", "")
    call <SID>X("Search", "607b8b", "", "")
    call <SID>X("SpecialKey", "324262", "103040", "")
    call <SID>X("StatusLine", "000000", "e0e0e0", "bold")
    call <SID>X("StatusLineNC", "1a1a1a", "999999", "")
    call <SID>X("Title", "e066ff", "", "bold")
    call <SID>X("Visual", "2e8b57", "ffffff", "reverse")
    "VisualNOS
    call <SID>X("WarningMsg", "ff3030", "", "bold")
    call <SID>X("WildMenu", "000000", "7fff00", "bold")
    "Menu
    "Scrollbar
    "Tooltip

    " syntax highlighting groups
    call <SID>X("Comment", "7c7268", "", "")
    call <SID>X("Constant", "ffa0a0", "", "")
    call <SID>X("Number", "00ffff", "", "")
    call <SID>X("String", "80a0ff", "", "")
    call <SID>X("Boolean", "00ffff", "", "bold")
    call <SID>X("Identifier", "8db6cd", "", "none")
    call <SID>X("Function", "b4eeb4", "", "none")

    call <SID>X("Statement", "90ee90", "", "")
    call <SID>X("Conditional", "90ee90", "", "")
    call <SID>X("Operator", "7fff00", "", "")
    call <SID>X("Keyword", "90ee90", "", "")
    call <SID>X("Exception", "90ee90", "", "")

    call <SID>X("PreProc", "87ceff", "", "")
    call <SID>X("Type", "bfefff", "", "bold")
    call <SID>X("Special", "999999", "", "")
    "Underlined
    call <SID>X("Ignore", "204050", "", "")
    "Error
    call <SID>X("Todo", "00ffff", "507080", "")

    " Spelling...
    hi SpellBad    cterm=underline      ctermfg=DarkRed      ctermbg=black
    hi SpellCap    cterm=underline      ctermfg=DarkBlue     ctermbg=black
    hi SpellRare   cterm=underline      ctermfg=DarkYellow   ctermbg=black
    hi SpellLocal  cterm=underline      ctermfg=DarkGreen    ctermbg=black

    " Diff
    "hi DiffAdd       ctermfg=4      ctermbg=black
    "hi DiffChange    ctermfg=5      ctermbg=black
    "hi DiffDelete    cterm=bold ctermfg=4 ctermbg=6
    "hi DiffText      cterm=bold ctermfg=1      ctermbg=black

    " delete functions {{{
    delf <SID>X
    delf <SID>rgb
    delf <SID>color
    delf <SID>rgb_color
    delf <SID>rgb_level
    delf <SID>rgb_number
    delf <SID>grey_color
    delf <SID>grey_level
    delf <SID>grey_number
    " }}}
else
    " color terminal definitions
    hi SpecialKey    ctermfg=darkgreen
    hi NonText       cterm=bold ctermfg=darkblue
    hi Directory     ctermfg=darkcyan
    hi ErrorMsg      cterm=bold ctermfg=7 ctermbg=1
    hi IncSearch     cterm=NONE ctermfg=yellow ctermbg=green
    hi Search        cterm=NONE ctermfg=grey ctermbg=blue
    hi MoreMsg       ctermfg=darkgreen
    hi ModeMsg       cterm=NONE ctermfg=brown
    hi LineNr        ctermfg=3
    hi Question      ctermfg=green
    hi StatusLine    cterm=bold,reverse
    hi StatusLineNC  cterm=reverse
    hi VertSplit     cterm=reverse
    hi Title         ctermfg=5
    hi Visual        cterm=reverse
    hi VisualNOS     cterm=bold,underline
    hi WarningMsg    ctermfg=1
    hi WildMenu      ctermfg=0 ctermbg=3
    hi Folded        ctermfg=darkgrey ctermbg=NONE
    hi FoldColumn    ctermfg=darkgrey ctermbg=NONE
    hi DiffAdd       ctermbg=4
    hi DiffChange    ctermbg=5
    hi DiffDelete    cterm=bold ctermfg=4 ctermbg=6
    hi DiffText      cterm=bold ctermbg=1
    hi Comment       ctermfg=darkcyan
    hi Constant      ctermfg=brown
    hi Special       ctermfg=5
    hi Identifier    ctermfg=6
    hi Statement     ctermfg=3
    hi PreProc       ctermfg=5
    hi Type          ctermfg=2
    hi Underlined    cterm=underline ctermfg=5
    hi Ignore        ctermfg=darkgrey
    hi Error         cterm=bold ctermfg=7 ctermbg=1
endif

" vim: set sw=4 et fdl=0 fdm=marker:
