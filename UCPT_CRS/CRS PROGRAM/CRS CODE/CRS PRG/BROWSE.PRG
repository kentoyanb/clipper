* Author        : UC-METC EDP Angels
* Installation  : UC-METC for UC-LM

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function main()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,nctr,aprv1setup,aentryscr,cyytskdp,cyytsecp,;
      ctimex
private cterm,cedpcode,csubject,ctype,nbegtimex,nendtimex,campm,cdayx,croom,;
        nunit,nmaxsize,crevision,ccolcode,cmajcode,csection,cplitcode,cgroupcode,;
        cbegtime,cendtime,cintcode,cday,ntimex1,ntimex2,csplittype,xroom,nactsize,;
        cblockcode
/*if file("c999room.dbf")
   copy file c999room.dbf navroom.dbf
else
   @13, say "C999room.dbf not found in directory..."
   inkey(1.5)
endif*/
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1},;
                             {,,"para",,_DBF_SHARED,, }})) == nil
        return(nil)
endif
do while .t.
        memvar->cterm := space(len(term->code))
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[54],"  Schedule Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        draw_box2(04,03,06,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        draw_box1(04,21,06,27,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        draw_box2(04,28,06,76,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        @ 05,05 say "School Term  :" color memvar->colorarray[55]
        @ 05,23 get memvar->cterm pict "@!" valid ! empty(memvar->cterm) color memvar->colorarray[54]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 05,30 say "- "+term->name color memvar->colorarray[55]
        if ! file(alltrim("c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+memvar->cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"secp.dbf"))
                fask(10,"  C"+memvar->cterm+"SECP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytskdp        := alltrim("c"+memvar->cterm+"skdp")
        cyytsecp        := alltrim("c"+memvar->cterm+"secp")
        if(aprvsetup    := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                       {,,"c999room",,_DBF_SHARED,,1},;
                                       {,,"c999curp",,_DBF_SHARED,,1},;
                                       {,,"c999crsp",,_DBF_SHARED,,1},;
                                       {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                       {,, cyytsecp ,"cyytsecp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif


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

return(nil)
