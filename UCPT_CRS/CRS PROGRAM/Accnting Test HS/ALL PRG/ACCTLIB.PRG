* Program       :  ACCTLIB.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function vcolcode(bkeyboard,cprocsts,ccolor)
static ocolcode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999colp->(sx_tagno())
default nlastorder to 2

ocolcode  := c999colp->(createbrowse(07,10,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|fcolcode(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+colcod+'  '","' '+colnamcol+' '","' '+coldesabr+' '"},;
                {" Code ", "        D e s c i p t i o n                 ", " Abrev. "},;
                {"ÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ"}))
                * xx12xx    x123456789012345678901234567890123456789012x    x123456x
setcolor(ccolor)
boxshadow(04,08,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing College File  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,70,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
c999colp->(sx_settagorder(nlastorder))
c999colp->(dbgotop())
c999colp->(browsefile(ocolcode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999colp->(sx_tagno())
c999colp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fcolcode(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 24 say space(40)
                @ 05, 24 say axparam[01]
                @ 21, 10 say "Description: "+space(47)
                @ 21, 10 say "Description: "+c999colp->coldesful
                return 1
        case lastkey() == K_ENTER .and. ! empty(c999colp->colcod)
                __keyboard(chr(K_CTRL_LEFT) + c999colp->colcod+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Description     ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2

*-------------------------------------------------------------------------------
function viewterm(bkeyboard,cprocsts,ccolor)
static oterm, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := term->(sx_tagno())
default nlastorder to 1

oterm  := term->(createbrowse(07,17,21,60,;
                {|xnmode,xacfields,xobrowser,xaxparam|fterm(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+code+'  '","' '+name+' '","' '+status+' '"},;
                {"  Term ", "      D e s c i p t i o n       ", "Sts"},;
                {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ"}))
                * xx123xx    x123456789012345678901234567890x    x1x
setcolor(ccolor)
boxshadow(04,15,22,62,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Term File  ")
outexpr(05,17,"Search Key =>")
dispbox(06,16,21,61,_SINGLE_LINE)
connectline(08,16,61)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
term->(sx_settagorder(nlastorder))
term->(dbgotop())
term->(browsefile(oterm,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := term->(sx_tagno())
term->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fterm(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 31 say space(15)
                @ 05, 31 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(term->code)
                __keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Term            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Name            ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------
function vacctname(bkeyboard,cprocsts,ccolor)
static oacctname, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := a999accp->(sx_tagno())
default nlastorder to 2

oacctname  := a999accp->(createbrowse(07,05,21,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|facctname(xnmode,xacfields,xobrowser,xaxparam)},;
                {"accidno","acclname+', '+accfname+' '+accmname","' '+acccolcod+' '","' '+accsyt","'  '+accyrlevl+' '"},;
                {"Account# ", "         S t u d e n t   N a m e           ", "CCod", "SYTerm", "Year"},;
                {"ÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄ"}))
                * 123456789    123456789012345, 123456789012345678901234 1    x12x    x12345    xx1x
setcolor(ccolor)
boxshadow(04,03,22,76,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Account Master File  ")
outexpr(05,05,"Search Key =>")
dispbox(06,04,21,75,_SINGLE_LINE)
connectline(08,04,75)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
a999accp->(sx_settagorder(nlastorder))
a999accp->(dbgotop())
a999accp->(browsefile(oacctname,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := a999accp->(sx_tagno())
a999accp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function facctname(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 19 say space(40)
                @ 05, 19 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(a999accp->accidno)
                __keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ID ~Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() == K_INS
                axparam[01] := alltrim(axparam[01])
                axparam[01] := padr(axparam[01],15)
                dynamicsearch(axparam[01], obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------
function vschpriv(bkeyboard,cprocsts,ccolor)
static opriv,nlastorder
local alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(0),;
      clastcolor:=setcolor(),nlasttag:=a999prcp->(sx_tagno())
default nlastorder to 1

opriv  := a999prcp->(createbrowse(07,17,21,60,;
                {|xnmode,xacfields,xobrowser,xaxparam|fschpriv(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+prccode+'  '","' '+prcdescr+' '"},;
                {"  Code  ", "      D e s c i p t i o n       "},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * xx1234xx    x123456789012345678901234567890x
setcolor(ccolor)
boxshadow(04,15,22,62,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Scholarship/Privelege File  ")
outexpr(05,17,"Search Key =>")
dispbox(06,16,21,61,_SINGLE_LINE)
connectline(08,16,61)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
a999prcp->(sx_settagorder(nlastorder))
a999prcp->(dbgotop())
a999prcp->(browsefile(opriv,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := a999prcp->(sx_tagno())
a999prcp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fschpriv(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 31 say space(15)
                @ 05, 31 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(a999prcp->prccode)
                __keyboard(chr(K_CTRL_LEFT)+a999prcp->prccode+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Description     ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------
function viewchart(bkeyboard,cprocsts,ccolor)
static ochart, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := a999chrt->(sx_tagno())
default nlastorder to 2

ochart  := a999chrt->(createbrowse(07,17,21,60,;
                {|xnmode,xacfields,xobrowser,xaxparam|fchart(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+code+'  '","' '+desc+' '"},;
                {" Code ", "      D e s c i p t i o n       "},;
                {"ÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * xx12xx    x123456789012345678901234567890x
setcolor(ccolor)
boxshadow(04,15,22,62,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Chart File  ")
outexpr(05,17,"Search Key =>")
dispbox(06,16,21,61,_SINGLE_LINE)
connectline(08,16,61)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
a999chrt->(sx_settagorder(nlastorder))
a999chrt->(dbgotop())
a999chrt->(browsefile(ochart,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := a999chrt->(sx_tagno())
a999chrt->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fchart(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 31 say space(15)
                @ 05, 31 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(a999chrt->code)
                __keyboard(chr(K_CTRL_LEFT)+a999chrt->code+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Name            ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*------------------------------------------------------------------------------*
function vsplcode(bkeyboard,cprocsts,ccolor)
static osplcode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := a999stcp->(sx_tagno())
default nlastorder to 1

osplcode  := a999stcp->(createbrowse(07,10,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|fsplcode(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+stccod+' '","' '+stccls+' '","' '+stcdesabr+' '","' '+stcdesful+' '"},;
                {"Code", "Clas", " Course ", "     D e s c i p t i o n        "},;
                {"ÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³","³","³"},;
                {"ÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * x12x    x12x    x123456x    x123456789012345678901234567890x
setcolor(ccolor)
boxshadow(04,08,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Special Course File  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,70,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
a999stcp->(sx_settagorder(nlastorder))
a999stcp->(dbgotop())
a999stcp->(browsefile(osplcode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := a999stcp->(sx_tagno())
a999stcp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fsplcode(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 24 say space(40)
                @ 05, 24 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(a999stcp->stccod)
                __keyboard(chr(K_CTRL_LEFT) + a999stcp->stccod+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Description     ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2

*------------------------------------------------------------------------------*

function vstudent(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno())
default nlastorder to 2

ostudent  := c999sm1p->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstudent(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","' '+sm1colcod+' '","' '+transform(sm1yrlevl,'@Z 9')+' '","sm1schtrm"},;
                {" ID No. ", "        S t u d e n t   N a m e            ", "Sex", "CCod", "Yr ", "Term"},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄ"}))
                * 12345678    123456789012345, 123456789012345678901234 1    x1x    x11x    x1x    1234
setcolor(ccolor)
boxshadow(04,03,22,76,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,05,"Search Key =>")
dispbox(06,04,20,75,_SINGLE_LINE)
connectline(08,04,75)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
c999sm1p->(sx_settagorder(nlastorder))
c999sm1p->(dbgotop())
c999sm1p->(browsefile(ostudent,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999sm1p->(sx_tagno())
c999sm1p->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fstudent(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 19 say space(40)
                @ 05, 19 say axparam[01]
                @ 21, 05 say "Home Address: "+space(30)
                @ 21, 05 say "Home Address: "+c999sm1p->sm1homadr
                return 1
        case lastkey() == K_ENTER .and. ! empty(c999sm1p->sm1idno)
                __keyboard(chr(K_CTRL_LEFT) + c999sm1p->sm1idno+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ID ~Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------
function vschedule(bkeyboard,cprocsts,ccolor)
static oskd, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := cyytskdp->(sx_tagno())
default nlastorder to 1

oskd   := cyytskdp->(createbrowse(07,03,20,75,;
                {|xnmode,xacfields,xobrowser,xaxparam|fskd(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+skdcod+' '","' '+skdsubcod+' '+skdsubtyp+' '","' '+skdbegtim+'-'+skdendtim+' '","' '+skdday+' '","' '+skdrom+' '","' '+skdcolcod+' '","' '+transform(skdactsiz,'@Z 9999')+' '","' '+transform(skdmaxsiz,'@Z 9999')+' '"},;
                {"EDPCode", "      Subject     ", "    Time     ", " Days ", " Room ", "CCod", "AcSize", "MxSize"},;
                {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ"},;
                {"³","³","³","³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ"}))
*                 x12345x    x123456789012 123x    x12345-12345x    x1234x    x1234x    x12x    x1234x    x1234x

setcolor(ccolor)
boxshadow(04,01,22,77,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Schedule File  ")
outexpr(05,03,"Search Key =>")
dispbox(06,02,20,76,_SINGLE_LINE)
connectline(08,02,76)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
cyytskdp->(sx_settagorder(nlastorder))
cyytskdp->(dbgotop())
cyytskdp->(browsefile(oskd,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := cyytskdp->(sx_tagno())
cyytskdp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fskd(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 17 say space(40)
                @ 05, 17 say axparam[01]
                @ 21, 03 say "Section => "+cyytskdp->skdsec
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytskdp->skdcod)
                __keyboard(chr(K_CTRL_LEFT) + cyytskdp->skdcod+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Subject         ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------

function vupgrade(bkeyboard,cprocsts,ccolor)
static pcolcode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := a999stcp->(sx_tagno())
default nlastorder to 2

pcolcode  := a999stcp->(createbrowse(07,10,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|fcolcode(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+stccod+'  '","' '+stcdesful+' '","' '+stcdesabr+' '"},;
                {" Code ", "        D e s c i p t i o n                 ", " Abrev. "},;
                {"ÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ"}))
                * xx12xx    x123456789012345678901234567890123456789012x    x123456x
setcolor(ccolor)
boxshadow(04,08,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Upgrading File  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,70,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
a999stcp->(sx_settagorder(nlastorder))
a999stcp->(dbgotop())
a999stcp->(browsefile(pcolcode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := a999stcp->(sx_tagno())
a999stcp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fpcolcode(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 24 say space(40)
                @ 05, 24 say axparam[01]
                @ 21, 10 say "Description: "+space(47)
                @ 21, 10 say "Description: "+a999stcp->stcdesful
                return 1
        case lastkey() == K_ENTER .and. ! empty(a999stcp->stccod)
                __keyboard(chr(K_CTRL_LEFT) + a999stcp->stccod+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Description     ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2
*-------------------------------------------------------------------------------

