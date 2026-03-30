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

function vpaycode(bkeyboard,cprocsts,ccolor)
static opaycode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := chart->(sx_tagno())
default nlastorder to 1

opaycode  := chart->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|fpaycode(xnmode,xacfields,xobrowser,xaxparam)},;
                {"chddctn"},;
                {" Pay Code "},;
                {"ÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄÄ"}))
setcolor(ccolor)
boxshadow(04,03,22,76,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,05,"Search Key =>")
dispbox(06,04,20,75,_SINGLE_LINE)
connectline(08,04,75)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
chart->(sx_settagorder(nlastorder))
chart->(dbgotop())
chart->(browsefile(opaycode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))

nlastorder := chart->(sx_tagno())
chart->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fpaycode(nmode,acfields,obrowser,axparam)
tempstr := space(len(axparam[01]))
do case
        case nmode = 0
                @ 05, 19 say space(40)
                @ 05, 19 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(chart->chddctn)
                __keyboard(chr(K_CTRL_LEFT) + chart->chddctn+chr(K_ENTER))
                return 6
        case lastkey() == K_ESC
                return 0
                return 1
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)

endcase
return 2


*-------------------------------------------------------------------------------

function vstudent(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno())
default nlastorder to 2

ostudent  := c999sm1p->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstudent(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","' '+sm1colcod+' '","' '+transform(sm1yrlevl,'@Z 9')+' '","strzero(sm1schtrm,4)"},;
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

function vlmstud(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno())
default nlastorder to 2

ostudent  := uclmsm1p->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|flmstud(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","' '+sm1colcod+' '","' '+transform(sm1yrlevl,'@Z 9')+' '","strzero(sm1schtrm,4)"},;
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
uclmsm1p->(sx_settagorder(2))
uclmsm1p->(dbgotop())
uclmsm1p->(browsefile(ostudent,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999sm1p->(sx_tagno())
uclmsm1p->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function vmnstud(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno())
default nlastorder to 2

ostudent  := ucmnsm1p->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|fmnstud(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","' '+sm1colcod+' '","' '+transform(sm1yrlevl,'@Z 9')+' '","strzero(sm1schtrm,4)"},;
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
ucmnsm1p->(sx_settagorder(2))
ucmnsm1p->(dbgotop())
ucmnsm1p->(browsefile(ostudent,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999sm1p->(sx_tagno())
ucmnsm1p->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fstudent(nmode,acfields,obrowser,axparam)
tempstr := space(len(axparam[01]))
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
        case lastkey() == K_INS
                axparam[01] := alltrim(axparam[01])
                axparam[01] := padr(axparam[01],15)
                dynamicsearch(axparam[01], obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2


function flmstud(nmode,acfields,obrowser,axparam)
tempstr := space(len(axparam[01]))
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 19 say space(40)
                @ 05, 19 say axparam[01]
                @ 21, 05 say "Home Address: "+space(30)
                @ 21, 05 say "Home Address: "+uclmsm1p->sm1homadr
                return 1
        case lastkey() == K_ENTER .and. ! empty(uclmsm1p->sm1idno)
                __keyboard(chr(K_CTRL_LEFT) + uclmsm1p->sm1idno+chr(K_ENTER))
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

function fmnstud(nmode,acfields,obrowser,axparam)
tempstr := space(len(axparam[01]))
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 19 say space(40)
                @ 05, 19 say axparam[01]
                @ 21, 05 say "Home Address: "+space(30)
                @ 21, 05 say "Home Address: "+ucmnsm1p->sm1homadr
                return 1
        case lastkey() == K_ENTER .and. ! empty(ucmnsm1p->sm1idno)
                __keyboard(chr(K_CTRL_LEFT) + ucmnsm1p->sm1idno+chr(K_ENTER))
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
                * 1234567   890123456789012345678901234567890123456789012   34567890
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

* --------------------------------------

function vzipcode(bkeyboard,cprocsts,ccolor)
static ocolcode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := zip_prov->(sx_tagno())
default nlastorder to 2
ocolcode  := zip_prov->(createbrowse(07,10,20,59,;
                {|xnmode,xacfields,xobrowser,xaxparam|fzipcode(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+zip_area->area_name+' '","'   '+zip_area->zip_code+'   '"},;
                {" A R E A                               ", " ZIP CODE"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÁÄÄÄÄÄÄÄÄ"}))
                 *xx12345678901234567890123456789012345xx     xx1234xx
                 *1234567890123456789012345678901234567890    12345678

setcolor(ccolor)
boxshadow(04,08,22,61,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Zip Code  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,60,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,60,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
zip_area->(dbsetrelation("zip_prov",{||zip_area->prov_id},"zip_area->prov_id"))
zip_area->(sx_settagorder(nlastorder))
zip_area->(dbgotop())
zip_area->(browsefile(ocolcode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := zip_area->(sx_tagno())
zip_area->(sx_settagorder(nlasttag))

restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fzipcode(nmode,acfields,obrowser,axparam)
tempstr := space(50)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 24 say space(35)
                @ 05, 24 say axparam[01]
                @ 21, 10 say "Province:  "+space(35)
                @ 21, 10 say "Province:  "+zip_prov->prov_name
                return 1
        case lastkey() == K_ENTER .and. ! empty(zip_area->zip_code)
//                tempstr := zip_area->zip_code + " " +alltrim(zip_area->area_name)+ if(at("CITY",zip_area->area_name)=0,", " + zip_prov->prov_name,"")
                tempstr := zip_area->zip_code + " " + alltrim(zip_area->area_name) + ", " + alltrim(zip_prov->prov_name)
                __keyboard(chr(K_CTRL_LEFT) + padr(tempstr,50) + chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(2) + " Order by ~Area            ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, }, ;
                              { 14, 24, "   " + checkorder(3) + " Order by ~Zip Code        ",,,, { || changeorder( obrowser, sx_tagno(), 3 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2


* --------------------------------------



function v_section(scolcode,bkeyboard,cprocsts,ccolor)
static ocolcode, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := cyytsecp->(sx_tagno())
default nlastorder to 2

ocolcode  := cyytsecp->(createbrowse(07,10,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|f_section(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+seccolcod+'  '","' '+seccod+' '"},;
                {" Code "," Section "},;
                {"ÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ"}))
                * xx12xx    x123456789012345678901234567890123456789012x    x123456x
setcolor(ccolor)
boxshadow(04,08,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Section by College  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,70,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
cyytsecp->(sx_settagorder(1))
cyytsecp->(sx_setscope(_TOP_SCOPE   ,scolcode))
cyytsecp->(sx_setscope(_BOTTOM_SCOPE,scolcode))
cyytsecp->(dbgotop())
cyytsecp->(browsefile(ocolcode,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := cyytsecp->(sx_tagno())
cyytsecp->(sx_settagorder(nlasttag))
cyytsecp->(clearscope())
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function f_section(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 24 say space(40)
                @ 05, 24 say axparam[01]
                @ 21, 10 say "Description: "+space(47)
*               @ 21, 10 say "Description: "+c999colp->coldesful
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytsecp->seccod)
                __keyboard(chr(K_CTRL_LEFT) + cyytsecp->seccod+chr(K_ENTER))
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
                @ 21, 19 say "Split => "+cyytskdp->skdsplcod+"-"+skdsplskd
                @ 21, 37 say "Blocked => "+cyytskdp->skdblkcode
                @ 21, 51 say "Units => "+transform(cyytskdp->skdunt,"999.9")
                @ 21, 67 say "Rev. => "+cyytskdp->skdrevcod
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytskdp->skdcod)
                __keyboard(chr(K_CTRL_LEFT) + cyytskdp->skdcod+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F4
                if c999curp->(dbseek(cyytskdp->skdintcod)) .and. rights("[REST]")
                if c999crsp->(dbseek(cyytskdp->skdintcod))
                   fask(13,"  "+alltrim(cyytskdp->skdcod)+"  "+alltrim(cyytskdp->skdsubcod)+";  College Code: "+c999curp->curcolcod+"  Revision: "+c999curp->currevcod+";  "+c999crsp->crsdsc1+"  "+if(!empty(c999crsp->crsdsc2),"; "+c999crsp->crsdsc2,"")+"  ",{" Ok "},memvar->colorarray[01])
                endif
                endif
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

function viewcontrol(bkeyboard,cprocsts,ccolor,cscope)
static ocontrol, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := cyytappp->(sx_tagno())
default nlastorder to 2

ocontrol  := cyytappp->(createbrowse(07,10,20,69,;
                {|xnmode,xacfields,xobrowser,xaxparam|fcontrol(xnmode,xacfields,xobrowser,xaxparam)},;
                {"appno","appvesname"},;
                {" Control# ", "      Vessel Name             "},;
                {"ÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * 1234567890    123456789012345678901234567890
setcolor(ccolor)
boxshadow(04,08,22,71,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Control File  ")
outexpr(05,10,"Search Key =>")
dispbox(06,09,20,70,_SINGLE_LINE)
outexpr(08,09,"Ã"); outexpr(08,70,"´")
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
cyytappp->(sx_settagorder(nlastorder))
cyytappp->(sx_setscope(_TOP_SCOPE   ,cscope))
cyytappp->(sx_setscope(_BOTTOM_SCOPE,cscope))
cyytappp->(dbgotop())
cyytappp->(browsefile(ocontrol,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := cyytappp->(sx_tagno())
cyytappp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function fcontrol(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytappp->appno)
                __keyboard(chr(K_CTRL_LEFT) + cyytappp->appno+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                axparam[01] := ""
/*
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Description     ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
*/
endcase
return 2
* - * - Additional function viewing room file - * - *
*-------------------------------------------------------------------------------
function viewroom(bkeyboard,cprocsts,ccolor)
static oroom, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999room->(sx_tagno()),cskd:=space(5)
default nlastorder to 1

oroom  := c999room->(createbrowse(07,17,21,60,;
                {|xnmode,xacfields,xobrowser,xaxparam|froom(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+roomno+' '","' '+status+' '","' '+type+' '"},;
                {" Room no"," Status"," Room Type       "},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * xx1234xx    xx1xx    x123456789012345x
setcolor(ccolor)
boxshadow(04,15,22,62,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Room File  ")
outexpr(05,17,"Search Key =>")
dispbox(06,16,21,61,_SINGLE_LINE)
connectline(08,16,61)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
c999room->(sx_settagorder(nlastorder))
//c999room->(sx_setscope(_TOP_SCOPE ,cskd))
//c999room->(sx_setscope(_BOTTOM_SCOPE ,cskd))
c999room->(dbgotop())
c999room->(browsefile(oroom,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999room->(sx_tagno())
c999room->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
//c999room->(clearscope())
return(nil)

function froom(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 31 say space(15)
                @ 05, 31 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(c999room->roomno)
                __keyboard(chr(K_CTRL_LEFT)+c999room->roomno+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[03] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Room no.        ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Status          ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2
*-------------------------------------------------------------------------------
function viewsub(bkeyboard,cprocsts,ccolor)
static osub, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999curp->(sx_tagno())
private nstr
default nlastorder to 1
memvar->nstr:=space(15)
osub  := c999curp->(createbrowse(07,20,18,57,;
                {|xnmode,xacfields,xobrowser,xaxparam|fsub(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+cursubcod+' '","'  '+cursubtyp+'  '","' '+curintcod+' '"},;
                {" Subject code "," Type ", "Int.code"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                {"³","³","³"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ"}))
                * x12x34x567890123456789012x    xx1xx    x123456x
setcolor(ccolor)
memvar->nstr:=space(15)
boxshadow(03,18,22,59,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Subject File  ")
outexpr(05,21,"Search Key =>")
dispbox(04,19,21,58,_SINGLE_LINE)
connectline(08,19,58)
//if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
commandline("³       Ù - to Select       ³      F10 - ReFresh      ³    ESC - Previous     ³")
clearbuffer()
c999curp->(sx_settagorder(nlastorder))
c999curp->(sx_setscope(_TOP_SCOPE ,memvar->crevision+memvar->ccolcode))
c999curp->(sx_setscope(_BOTTOM_SCOPE ,memvar->crevision+memvar->ccolcode))
c999curp->(dbgotop())
c999curp->(browsefile(osub,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999curp->(sx_tagno())
c999curp->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
c999curp->(clearscope())
return(nil)

function fsub(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 34 say space(15)
                @ 05, 34 say substr(axparam[01],4,20)
                c999crsp->(dbseek(c999curp->curintcod))
                @ 19, 21 say c999crsp->crsdsc1
                @ 20, 21 say c999crsp->crsdsc2
                return 1
        case lastkey() == K_ENTER .and. ! empty(c999curp->cursubcod)
                __keyboard(chr(K_CTRL_LEFT)+c999curp->cursubcod+chr(K_ENTER))
                return 6
        case lastkey() == K_F10
                memvar->nstr:=space(15)
                axparam[01] := memvar->crevision+memvar->ccolcode
        case lastkey() >= 32 .and. lastkey() <= 255
                memvar->nstr+=chr(lastkey())
                axparam[01] := memvar->crevision+memvar->ccolcode+alltrim(memvar->nstr)
                dynamicsearch(axparam[01], obrowser)
        otherwise
                memvar->nstr:=space(15)
                axparam[01] := memvar->crevision+memvar->ccolcode
endcase
return 2

*-------------------------------------------------------------------------------

function vrank(bkeyboard,cprocsts,ccolor)
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999sm1p->(sx_tagno()),;
      nterm:=val(memvar->cterm)
default nlastorder to 4

ostudent  := c999sm1p->(createbrowse(07,05,20,74,;
                {|xnmode,xacfields,xobrowser,xaxparam|frank(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","' '+sm1colcod+' '","' '+transform(sm1yrlevl,'@Z 9')+' '","strzero(sm1schtrm,4)"},;
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
c999sm1p->(sx_setscope(_TOP_SCOPE ,nterm))
c999sm1p->(sx_setscope(_BOTTOM_SCOPE ,nterm))
c999sm1p->(dbgotop())
c999sm1p->(browsefile(ostudent,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999sm1p->(sx_tagno())
c999sm1p->(sx_settagorder(nlasttag))
c999sm1p->(clearscope())
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function frank(nmode,acfields,obrowser,axparam)
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
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, }, ;
                              { 15, 24, "   " + checkorder(4) + " Order by ~Term            ",,,, { || changeorder( obrowser, sx_tagno(), 4 ) },, } }, ;
                            { || boxshadow( 12, 23, 16, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2
*-------------------------------------------------------------------------------

function viewrank(bkeyboard,cprocsts,ccolor)
static orank, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(), nlasttag := c999rank->(sx_tagno())
default nlastorder to 1

orank  := c999rank->(createbrowse(07,17,21,60,;
                {|xnmode,xacfields,xobrowser,xaxparam|f1rank(xnmode,xacfields,xobrowser,xaxparam)},;
                {"'  '+r_code+'  '","' '+r_desc+' '"},;
                {"  Rank ", "      D e s c i p t i o n       "},;
                {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³"},;
                {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"}))
                * xx123xx    x123456789012345678901234567890x

setcolor(ccolor)
boxshadow(04,15,22,62,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Rank File  ")
outexpr(05,17,"Search Key =>")
dispbox(06,16,21,61,_SINGLE_LINE)
connectline(08,16,61)
if(cprocsts == "I", commandline("³ Ù - to Select ³  Ins - Add  ³ F10 - ReFresh ³ F12 - Order ³  ESC - Previous ³"), ;
                    commandline("³  Ù - to Select  ³   F10 - ReFresh   ³    F12 - Order    ³  ESC - Previous   ³"))
clearbuffer()
c999rank->(sx_settagorder(nlastorder))
c999rank->(dbgotop())
c999rank->(browsefile(orank,{"",bkeyboard,cprocsts},{|b|b:gotop()}))
nlastorder := c999rank->(sx_tagno())
c999rank->(sx_settagorder(nlasttag))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
return(nil)

function f1rank(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 31 say space(15)
                @ 05, 31 say axparam[01]
                return 1
        case lastkey() == K_ENTER .and. ! empty(c999rank->r_code)
                __keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))
                return 6
        case lastkey() == K_INS .and. axparam[02] == "I"
                *client("E")
                *editrefresh(obrowser)
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Rank            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Name            ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2
