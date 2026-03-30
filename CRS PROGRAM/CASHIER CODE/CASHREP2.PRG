* Program       :  CASHREP.PRG  //OnLine Cashiering System
* Author        :  jHUN bENLOT and FcTOPZ (c) Dec 2001
* Last Update   :  tope 01-10-2002
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function mediaprnt(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Media Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("b"+cterm+"payp.dbf"))
                fask(10,"  B"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->npeso := memvar->ndollar := 0
        memvar->qpeso := memvar->qdollar := 0
        cdesc := term->name
        @ 02,21 say "- "+term->name
        bprntscr := savescr(01,00,24,79)
        byytpayp  := alltrim("b"+cterm+"payp")
        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,7}})) == nil
                return(nil)
        endif
        cuser := left(cuser,8)
        byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+"P"))
        byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+"P"))
        count to memvar->nlast
        restscr(bprntscr)
        statusbar()
        byytpayp->(dbgotop())
        do while ! byytpayp->(eof())
                showprogress()
                if right(byytpayp->payorno,1) != "$"
                        memvar->npeso += byytpayp->paypesoamt
                        ++memvar->qpeso
                else
                        memvar->ndollar += byytpayp->paydollamt
                        ++memvar->qdollar
                endif
                byytpayp->(dbskip())
        enddo
        if memvar->nlast > 0
                printmedia(cunit)
                fask(16,"  Print Media successful...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        else
                fask(16,"  There is nothing to print...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif
        byytpayp->(clearscope())
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

function printmedia(cunit)
set device to printer
header(cunit,"MEDIA  REPORT")
footer()
set device to screen
return(nil)


function deptprnt(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar
private nlast

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Departmental Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("b"+cterm+"payp.dbf"))
                fask(10,"  B"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->npeso  := memvar->ndollar  := 0
        memvar->qpeso  := memvar->qdollar  := 0
        memvar->ntotpeso := memvar->ntotdollar := 0
        memvar->qtotpeso := memvar->qtotdollar := 0
        @ 02,21 say "- "+term->name
        bprntscr := savescr(01,00,24,79)
        byytpayp  := alltrim("b"+cterm+"payp")
        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,7},;
                                     {,, "b999chrt",,_DBF_SHARED,,3}})) == nil
                return(nil)
        endif
        cuser := left(cuser,8)

        byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+"P"))
        byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+"P"))
        count to memvar->nlast
        byytpayp->(dbgotop())
        do while ! byytpayp->(eof())
                if right(byytpayp->payorno,1) != "$"
                        memvar->ntotpeso += byytpayp->paypesoamt
                        ++memvar->qtotpeso
                else
                        memvar->ntotdollar += byytpayp->paydollamt
                        ++memvar->qtotdollar
                endif
                byytpayp->(dbskip())
        enddo
        byytpayp->(clearscope())

if memvar->nlast > 0
/*======================================*/
        set device to printer
        header(cunit,"DEPARTMENTAL REPORT")
        b999chrt->(dbgotop())
        do while ! b999chrt->(eof())
                byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+"P"+b999chrt->code))
                byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+"P"+b999chrt->code))
                restscr(bprntscr)
                memvar->npeso  := memvar->ndollar  := 0
                memvar->qpeso  := memvar->qdollar  := 0
                byytpayp->(dbgotop())
                if ! byytpayp->(eof())
                do while ! byytpayp->(eof())
                        if right(byytpayp->payorno,1) != "$"
                                memvar->npeso += byytpayp->paypesoamt
                                ++memvar->qpeso
                        else
                                memvar->ndollar += byytpayp->paydollamt
                                ++memvar->qdollar
                        endif
                        byytpayp->(dbskip())
                enddo
                memvar->cdesc := b999chrt->desc
                printdeptrpt()
                byytpayp->(dbgotop())
                do while ! byytpayp->(eof())
                        byytpayp->(reclock())
                        byytpayp->paytag := "D"
                        byytpayp->(dbcommit())
                        byytpayp->(dbunlock())
                        byytpayp->(dbgotop())
                enddo
                endif
                byytpayp->(clearscope())
                b999chrt->(dbskip())
        enddo
        memvar->qpeso := memvar->qtotpeso
        memvar->qdollar := memvar->qtotdollar
        memvar->npeso := memvar->ntotpeso
        memvar->ndollar := memvar->ntotdollar
        footer()
        set device to screen

/*==========================================*/
        fask(16,"  Departmental Printing successful...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
else
        fask(16,"  There is nothing to print...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
endif

        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)


function printdeptrpt()

@ prow()+1,02 say "-"+alltrim(memvar->cdesc)+"-0"
if qpeso != 0
        @ prow()+1,02 say transform(memvar->qpeso,"9,999")+space(1)+;
          transform((memvar->qpeso / memvar->qtotpeso)*100,"999.99%")+space(2)+;
          transform(memvar->npeso,"P 99,999,999.99")+space(2)+;
          transform((memvar->npeso / memvar->ntotpeso)*100,"999.99%")
endif
if qdollar != 0
        @ prow()+1,02 say transform(memvar->qdollar,"9,999")+space(1)+;
          transform((memvar->qdollar / memvar->qtotdollar)*100,"999.99%")+space(2)+;
          transform(memvar->ndollar,"$ 99,999,999.99")+space(2)+;
          transform((memvar->ndollar / memvar->ntotdollar)*100,"999.99%")
endif
@ prow()+1,02 say space(01)
return(nil)

function header(cunit,ctitle)
ncol := titlepos(alltrim(ctitle),40)

@ 00,02 say "      UNIVERSITY OF CEBU - METC"
@ 01,02 say "           WINDOW-"+right(cunit,1)+""
@ 02,02 say "-------------------------------------"
@ 03,ncol say "E"+ctitle+"F"
@ 04,10 say displaydate(date())+" "+AmPm(time())
//@ 04,10 say "05/20/2003   8:29 AM"

return(nil)

function footer()
local nlen,nlenpso,nlendol,bdol


nlenpso := len(alltrim(transform(memvar->npeso,"99,999,999.99")))
nlendol := len(alltrim(transform(memvar->ndollar,"99,999,999.99")))
bdol := .f.

@ prow()+1,02 say "            QTY          AMT. TOTAL"
@ prow()+1,02 say "-------------------------------------"
stext := padl(transform(memvar->qpeso,"9,999"),15)
stext := padr(stext,35-len("P "+if(nlendol>nlenpso,space(nlendol-nlenpso),"")+;
                alltrim(transform(memvar->npeso,"99,999,999.99"))))
stext += ("P "+if(nlendol>nlenpso,space(nlendol-nlenpso),"")+alltrim(transform(memvar->npeso,"99,999,999.99")))
@ prow()+1,02 say stext
stext := padl(transform(memvar->qdollar,"9,999"),15)
stext := padr(stext,35-len("$ "+if(nlenpso>nlendol,space(nlenpso-nlendol),"")+;
                alltrim(transform(memvar->ndollar,"99,999,999.99"))))
stext += ("$ "+if(nlenpso>nlendol,space(nlenpso-nlendol),"")+alltrim(transform(memvar->ndollar,"9,999,999.99")))
@ prow()+1,02 say stext
@ prow()+1,02 say "-------------------------------------"
stext := "QTY TTL"
stext := padr(stext,15-len(alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999"))))
stext += alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999"))
@ prow()+1,02 say stext

@ prow()+02,02 say alltrim(substr(memvar->cusername,1,8))

@ prow()+01,00 say chr(27)+"a"+chr(8)
setprc(00,00)
return(nil)

*-----------------------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------------------*

function media_sel(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar,cborno,cnorno

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Media Report [Selective] ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("b"+cterm+"payp.dbf"))
                fask(10,"  B"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->npeso := memvar->ndollar := 0
        memvar->qpeso := memvar->qdollar := 0
        cdesc := term->name
        cborno:= space(8)
        cnorno:= space(8)
        @ 02,21 say "- "+term->name
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 04,02 say "Starting OR# :" color memvar->colorarray[02];
                get cborno pict "@!"
        @ 05,02 say "Ending OR#   :" color memvar->colorarray[02];
                get cnorno pict "@!"
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        bprntscr := savescr(01,00,24,79)
        byytpayp  := alltrim("b"+cterm+"payp")
        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,8}})) == nil
                return(nil)
        endif
        cuser := left(cuser,8)
        byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+cborno))
        byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+cnorno))
        count to memvar->nlast
        restscr(bprntscr)
        statusbar()
        byytpayp->(dbgotop())
        do while ! byytpayp->(eof())
                showprogress()
                if right(byytpayp->payorno,1) != "$"
                        memvar->npeso += byytpayp->paypesoamt
                        ++memvar->qpeso
                else
                        memvar->ndollar += byytpayp->paydollamt
                        ++memvar->qdollar
                endif
                byytpayp->(dbskip())
        enddo
        if memvar->nlast > 0
                pmedia(cunit)
                fask(16,"  Print Media successful...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        else
                fask(16,"  There is nothing to print...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif
        byytpayp->(clearscope())
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

function pmedia(cunit)
set device to printer
header(cunit,"MEDIA  REPORT")
footer()
set device to screen
return(nil)



function dept_sel(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv12setup, aprv3setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar,date,;
      cborno,cnorno,bfound,i, nlastelem, cacctno
private nlast

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Departmental Report [Selective] ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("b"+cterm+"payp.dbf"))
                fask(10,"  B"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->npeso  := memvar->ndollar  := 0
        memvar->qpeso  := memvar->qdollar  := 0
        memvar->ntotpeso := memvar->ntotdollar := 0
        memvar->qtotpeso := memvar->qtotdollar := 0
        
        cborno:= space(8)
        //cnorno:= space(8)
        @ 02,21 say "- "+term->name
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 04,02 say "Starting OR# :" color memvar->colorarray[02];
                get cborno pict "@!"
       
        read

        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif

        bprntscr := savescr(01,00,24,79)
        byytpayp  := alltrim("b"+cterm+"payp")

        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,8},;
                                     {,, a999accp,"a999accp",_DBF_SHARED,,1,"/arunlib"},;
                                     {,, "b999chrt",,_DBF_SHARED,,3}})) == nil
                return(nil)
        endif
        
        cuser := left(cuser,8)

        byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+cborno))
        byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+cnorno))
        count to memvar->nlast
        byytpayp->(dbgotop())
        i := 0
        do while ! byytpayp->(eof())
//                fask(10,"  Counter ==> "+transform(i++,"999")+"  ",{" Ok "},memvar->colorarray[05],.f.,nil)
                if right(byytpayp->payorno,1) != "$"
                        memvar->ntotpeso += byytpayp->paypesoamt
                        ++memvar->qtotpeso
                else
                        memvar->ntotdollar += byytpayp->paydollamt
                        ++memvar->qtotdollar
                endif
                byytpayp->(dbskip())
        enddo
        byytpayp->(clearscope())



        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)


function print_dept()

@ prow()+1,02 say "-"+alltrim(memvar->cdesc)+"-0"
if qpeso != 0
        @ prow()+1,02 say transform(memvar->qpeso,"9,999")+space(1)+;
          transform((memvar->qpeso / memvar->qtotpeso)*100,"999.99%")+space(2)+;
          transform(memvar->npeso,"P 99,999,999.99")+space(2)+;
          transform((memvar->npeso / memvar->ntotpeso)*100,"999.99%")
endif
if qdollar != 0
        @ prow()+1,02 say transform(memvar->qdollar,"9,999")+space(1)+;
          transform((memvar->qdollar / memvar->qtotdollar)*100,"999.99%")+space(2)+;
          transform(memvar->ndollar,"$ 99,999,999.99")+space(2)+;
          transform((memvar->ndollar / memvar->ntotdollar)*100,"999.99%")
endif
@ prow()+1,02 say space(01)
return(nil)


