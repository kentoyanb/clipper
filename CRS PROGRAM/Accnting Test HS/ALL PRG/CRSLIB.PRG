* Program       :  CRSLIB.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function vstudent(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno())
default nlastorder to 2

ostudent  := c999sm1p->(createbrowse(07,06,20,73,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstudent(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","'  '+sm1colcod+'  '","' '+transform(sm1yrlevl,'@Z 9')+'  '"},;
                {" ID No. ", "        S t u d e n t   N a m e            ", "Sex", "C-Code", "Year"},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ"}))
                * 12345678    123456789012345, 123456789012345678901234 1    x1x    xx11xx    x1xx
setcolor(ccolor)
boxshadow(04,04,22,75,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,06,"Search Key =>")
dispbox(06,05,20,74,_SINGLE_LINE)
outexpr(08,05,"Ã"); outexpr(08,74,"´")
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
                @ 05, 20 say space(40)
                @ 05, 20 say axparam[01]
                @ 21, 06 say "Home Address: "+space(30)
                @ 21, 06 say "Home Address: "+c999sm1p->sm1homadr
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
        case lastkey() == K_INS
                axparam[01] := alltrim(axparam[01])
                axparam[01] := padr(axparam[01],15)
                dynamicsearch(axparam[01], obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

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
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
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
function viewterm(bkeyboard,cprocsts,ccolor)
static oterm, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := term->(sx_tagno())
default nlastorder to 1

oterm  := term->(createbrowse(07,20,21,59,;
                {|xnmode,xacfields,xobrowser,xaxparam|fterm(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+code+'  '","' '+name+' '"},;
                {"  Term ", "      D e s c i p t i o n       "},;
                {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * xx123xx    x123456789012345678901234567890x
setcolor(ccolor)
boxshadow(04,18,22,61,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Term File  ")
outexpr(05,20,"Search Key =>")
dispbox(06,19,21,60,_SINGLE_LINE)
connectline(08,19,60)
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
                @ 05, 34 say space(15)
                @ 05, 34 say axparam[01]
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
function vinstructor(bkeyboard,cprocsts,ccolor)
static oinst, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := t999lst->(sx_tagno())
default nlastorder to 2

oinst  := t999lst->(createbrowse(07,11,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|finst(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+tidno+' '","' '+tlname+' '","' '+tfname+' '","'  '+tmname+'  '"},;
                {" ID No. ", "    Last Name    ", "      First Name          ", "  M  "},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ"},;
                {"³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ"}))
                * x123456x    x123456789012345x    x123456789012345678901234x    xx1xx
setcolor(ccolor)
boxshadow(04,09,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Instructor File  ")
outexpr(05,11,"Search Key =>")
dispbox(06,10,20,70,_SINGLE_LINE)
outexpr(08,10,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
t999lst->(sx_settagorder(nlastorder))
t999lst->(dbgotop())
t999lst->(browsefile(oinst,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := t999lst->(sx_tagno())
t999lst->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function finst(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 25 say space(40)
                @ 05, 25 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(t999lst->tidno)
                __keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~ID Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Name            ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2

*-------------------------------------------------------------------------------

