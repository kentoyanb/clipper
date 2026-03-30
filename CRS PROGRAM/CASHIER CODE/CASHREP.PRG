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


#define _CODE           1
#define _DESCRIPTION    2
#define _AMOUNT         3
#define _EMPTY          {space(04),;
                        space(20),;
                        0}

#define _ORNO            1
#define _CODE2           2
#define _DESCRIPTION2    3
#define _AMOUNT2         4
#define _DATE2           5
#define _USER            6
#define _EMPTY2          {space(08),;
                          space(04),;
                          space(20),;
                          0,;
                          space(10),;
                          space(08)}

#define _P_ACCTNO       1
#define _P_LNAME        2
#define _P_FNAME        3
#define _P_COURSE       4
#define _P_ORNO         5 
#define _P_DATE         6 
#define _P_AMOUNT       7  
#define _P_CASHIER      8 
#define _P_EMPTY        {space(09),; //ACCTNO
                         space(15),; //LNAME
                         space(20),; //FNAME
                         space(08),;//COURSE
                         space(08),;//ORNO
                         space(10),;//DATE
                         0,;//AMOUNT
                         space(10)} //CASHIER                

#define _REFNO          1
#define _DATE           2
#define _DEBIT          3
#define _CREDIT         4
#define _BALANCE        5
#define _USERID         6
#define _REMARKS        7
#define _REFNO1         8
#define _PAYFOR         9
#define _EMPTY_3         {space(08),;
                         space(10),;
                         0,0,0,;
                         space(08),;
                         space(07),;
                         space(08),;
                         space(20)}

#define _CODE_2         1
#define _SUBJECT        2
#define _TYPE           3
#define _UNIT           4
#define _EMPTY_1        {space(05),space(12),space(03),0}


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
//stext := padr(stext,15-len(alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999"))))
stext := padr(stext,15-len(alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999,999.99"))))
//stext += alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999"))
stext += alltrim(transform(memvar->qpeso+memvar->qdollar,"9,999,999.99"))
@ prow()+1,02 say stext 

@ prow()+02,02 say alltrim(substr(memvar->cusername,1,8))

//@ prow()+01,00 say chr(27)+"a"+chr(8)
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



function re_printOR(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar,date,;
      cborno,cnorno,bfound,i, nlastelem, cacctno, array_size,user, name,checknum, invoice
//private nlast

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif

//memvar->aitems := {_EMPTY}
//memvar->nindex := 1
array_size := 0

cterm := space(len(term->code))
do while .t.
        memvar->aitems := {_EMPTY}
        memvar->nindex := 1

        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OFFICIAL RECEIPT RE-PRINTING ")
        commandline("³    F4 - View Term     ³     ESC - Previous    ³")
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

        cborno:= space(8)
        cnorno:= space(8)
        @ 02,21 say "- "+term->name
        setcursor(1);set(_SET_CONFIRM,.t.)

        @ 04,02 say "Offcial Receipt # :" color memvar->colorarray[02];
                get cborno pict "@!" valid ! empty(cborno)
       
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif

        bprntscr := savescr(01,00,24,79)
        byytpayp := alltrim("b"+cterm+"payp")
        zyytpayp := alltrim("b"+cterm+"payp")

        //{,, byytpayp,"byytpayp",_DBF_SHARED,,9},;

        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,9},;
                                     {,, zyytpayp,"zyytpayp",_DBF_SHARED,,1},;
                                     {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                     {,, "b999chrt",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif


        bdollar := .f.

        count to memvar->nlast
        restscr(bprntscr)
        statusbar()
        //byytpayp->(dbgotop())
        i := 0

        memvar->name     := ""
        memvar->checknum := ""
        memvar->invoice  := ""   

        byytpayp->(sx_setscope(_TOP_SCOPE   ,cborno))
        byytpayp->(sx_setscope(_BOTTOM_SCOPE,cborno))

        if val(cterm) >= 201
            memvar->name := byytpayp->payname
            memvar->checknum := byytpayp->paychcknum        
        endif

        if val(cterm) > 241
                memvar->invoice :=  byytpayp->payinvoice  
        endif

        memvar->ccode := byytpayp->payorno 
        memvar->cacctno := byytpayp->payidno

        memvar->date := byytpayp->paydte
        memvar->user := byytpayp->payentusr

        /*
        byytpayp->(dbgotop())
        if ! byytpayp->(eof())
            bfound := 0
            do while ! byytpayp->(eof())

                    showprogress()

                    b999chrt->(dbseek(byytpayp->paycode))

                    bfound := 1
                    aadd(memvar->aitems,_EMPTY)
                    nlastelem := len(memvar->aitems)
                                            
                    memvar->aitems[nindex,_CODE]         := b999chrt->code
                    memvar->aitems[nindex,_DESCRIPTION]  := alltrim(b999chrt->desc)
                    memvar->aitems[nindex,_AMOUNT]       := byytpayp->paypesoamt
                    ++nindex

                    byytpayp->(dbskip())
            enddo
        endif
        byytpayp->(clearscope())
        */

        
        
        b999chrt->(dbgotop())
        do while ! b999chrt->(eof())
                //byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+cborno+b999chrt->code)) //+b999chrt->code
                //byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+cborno+b999chrt->code)) //+b999chrt->code

                byytpayp->(sx_setscope(_TOP_SCOPE   ,cborno+b999chrt->code))
                byytpayp->(sx_setscope(_BOTTOM_SCOPE,cborno+b999chrt->code))

                if val(cterm) >= 201
                    memvar->name := byytpayp->payname
                    memvar->checknum := byytpayp->paychcknum
                    
                endif

                if val(cterm) > 241
                    memvar->invoice :=  byytpayp->payinvoice  
                endif

                byytpayp->(dbgotop())
                if ! byytpayp->(eof())
                        bfound := 0
                        do while ! byytpayp->(eof())
                                showprogress()

                                memvar->ccode := byytpayp->payorno 
                                memvar->cacctno := byytpayp->payidno

                                

                                memvar->date := byytpayp->paydte
                                memvar->user := byytpayp->payentusr

                                        bfound := 1
                                        aadd(memvar->aitems,_EMPTY)
                                        nlastelem := len(memvar->aitems)
                                        
                                        memvar->aitems[nindex,_CODE]         := b999chrt->code
                                        memvar->aitems[nindex,_DESCRIPTION]  := alltrim(b999chrt->desc)
                                        memvar->aitems[nindex,_AMOUNT]       := byytpayp->paypesoamt
                                ++nindex
                                byytpayp->(dbskip())
                        enddo
                        
                endif
                byytpayp->(clearscope())
                b999chrt->(dbskip())
        enddo
                
       
        if nindex > 1
               printOR(cunit)
                fask(16,"  Re-Printing Official Receipt successful...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        else
                fask(16,"  There is nothing to print...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif

        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)


return(nil)


//printing sa OR
static function printOR(cunit)
local nmax,nmax1, nctr,nctr1,ntotamt ,ntotamt1, stext, txtlenght, code, amount, studinfo, particulars,i, currency
local MARGIN := 2
set device to printer

a999accp->(dbseek(memvar->cacctno))

//@ 01,65 say "XXXXXXXXXXXXXXXXXXXX"

//@ 02,64 say "SERVICE INVOICE"
//OR NO:
@ 03,65 say memvar->ccode
//DATE:
@ 04,65 say displaydate(memvar->date)
//TIME:
@ 05,65 say AmPm(time())
//Cashier or User
@ 06,65 say "CS-"+right(cunit,1)+" "+alltrim(substr(memvar->user,1,10))

//STUDENTS INFORMATION(ID, FULL NAME)
/*
//if alltrim(memvar->cacctno) == ""
       // studinfo := memvar->cname
//else
        studinfo := right(memvar->cacctno,8)+" ";
                +alltrim(memvar->name)
                //+alltrim(a999accp->accfname)+" ";
                //+alltrim(a999accp->accmname)+"."
        studinfo := strtran(studinfo,"¥","Å")
//endif
*/

if empty(memvar->name)
    studinfo := right(memvar->cacctno,9)+" ";
                +alltrim(a999accp->(acclname))+", ";
                +alltrim(a999accp->(accfname))+" ";
                +alltrim(a999accp->(accmname))+"."
        studinfo := strtran(studinfo,"¥","Å")
else

        studinfo := right(memvar->cacctno,9)+" ";
                        +alltrim(memvar->name)
                        
        studinfo := strtran(studinfo,"¥","Å")
endif

@ 06,01+MARGIN say studinfo

nmax := len(memvar->aitems)
nctr := 1
ntotamt := 0

nmax1 := len(memvar->aitems)
nctr1 := 1
ntotamt1 := 0

//GET THE TOTAL AMOUNTS IN ARRAY OF ITEMS
if nmax1>1
        for i := 1 to nmax1-1
                ntotamt += memvar->aitems[i,_AMOUNT]
        next
endif

if !bdollar
        currency := "PESOS "
    else
        currency := "DOLLARS "
endif

txtlenght := trim(amttochar(ntotamt, currency))

@ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)//THE DISPLAYED AMOUNT IN WORDS
if Len(txtlenght) > 50
    @ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)//THE DISPLAYED AMOUNT IN WORDS
    
    if !bdollar
        @ 09,65+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    else
        @ 09,65+MARGIN say ""+("$ "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    endif


    @ 09,65+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    @ 10,01+MARGIN say " "+PADR(Substr(txtlenght,51,Len(txtlenght)),Len(txtlenght)-50)

else
    @ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)
    //@ 09,65+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99")))

    if !bdollar
        @ 09,65+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    else
        @ 09,65+MARGIN say ""+("$ "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    endif
   
endif


@12,01+MARGIN say ""//EMPTY SPACE TO DETERMINE WHERE THE PROW() WILL START


//LOOP THROUGH TO THE ITEMS AND GET THE CODE AND AMOUNT
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        //b999chrt->(dbseek(memvar->aitems[nctr,_CODE]))

        
            stext := memvar->aitems[nctr,_CODE] + " " + alltrim(memvar->aitems[nctr,_DESCRIPTION])
            stext := padr(stext,37-len(transform(memvar->aitems[nctr,_AMOUNT],"99,999,999.99")))
            stext +=transform(memvar->aitems[nctr,_AMOUNT],"99,999,999.99")
           
            //DISPLAY IN PARTICULAR TAB
            @prow()+01,02 say " "+stext
            //ntotamt += memvar->aitems[nctr,_AMOUNT]
            ++nctr
enddo

if ! empty(memvar->checknum)
    @prow()+01,02 say "Check No. : "+memvar->checknum
endif

if ! empty(memvar->invoice)
    @prow()+01,02 say "Invoice No. : "+memvar->invoice
endif

//the total amount to be paid display
if !bdollar
        //stext += ("P "+alltrim(transform(ntotamt,"99,999,999.99")))
        @18,64+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99")))
else
        //stext += ("$ "+alltrim(transform(ntotamt,"99,999,999.99")))
        @18,64+MARGIN say ""+("$ "+alltrim(transform(ntotamt,"99,999,999.99")))
endif


@ 20,01 say space(01)
setprc(00,-1)
set device to screen
return(nil)
//end of print OR


function dept_sel(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode,qpeso,qdollar,npeso,ndollar,;
      cborno,cnorno,bfound,i
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
        if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,8},;
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

if memvar->nlast > 0
        set device to printer
        header(cunit,"DEPARTMENTAL REPORT")
        b999chrt->(dbgotop())
        do while ! b999chrt->(eof())
//                byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+"P"+b999chrt->code))
//                byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+"P"+b999chrt->code))
               //byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+cborno+b999chrt->code+b999chrt->code)) why 2 ka b999chrt??
               // byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+cnorno+b999chrt->code+b999chrt->code)) why 2 ka b999chrt??

                byytpayp->(sx_setscope(_TOP_SCOPE   ,cuser+cborno+b999chrt->code))
                byytpayp->(sx_setscope(_BOTTOM_SCOPE,cuser+cnorno+b999chrt->code))
                restscr(bprntscr)
                memvar->npeso  := memvar->ndollar  := 0
                memvar->qpeso  := memvar->qdollar  := 0
                byytpayp->(dbgotop())
                if ! byytpayp->(eof())
                        bfound := 0
                        do while ! byytpayp->(eof())
                                if byytpayp->paycode == b999chrt->code
                                        bfound := 1
                                        if right(byytpayp->payorno,1) != "$"
                                                memvar->npeso += byytpayp->paypesoamt
                                                ++memvar->qpeso
                                        else
                                                memvar->ndollar += byytpayp->paydollamt
                                                ++memvar->qdollar
                                        endif
                                endif
                                byytpayp->(dbskip())
                        enddo
                        if bfound == 1
                                memvar->cdesc := b999chrt->desc
                                printdeptrpt()
                        endif
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
@ prow(),02 say space(01)
return(nil)


function AmPm(cTime)
ctime := left(cTime,5)
if val(cTime) < 12
        cTime += " AM"
elseif  val(cTime) == 12
        cTime += " PM"
else
        cTime := str(val(cTime) - 12,2) + substr(cTime,3) + " PM"
endif
return(cTime)




function or_view(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,byytpayp,idno,pclass,viewor,bindex,bitems,;
      oappren,nrec,nlastelems,cborno,nindexss,indicator,name, checknum, invoice
private cterm,nmos,aitemss := {}, nindexs

bindex  := memvarblock("NINDEXS")
bitems  := memvarblock("AITEMSS")


viewor   := createabrowse(bitems,bindex,08,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|pOR(xnmode,xoabrowser,xaxparam,cunit)},;
                        {{{||memvar->aitemss[memvar->nindexs,_ORNO]},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_CODE2]},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_DESCRIPTION2]},nil},;
                         {{||transform(memvar->aitemss[memvar->nindexs,_AMOUNT2],"999,999.99")+" "},nil},;
                         {{||" "+memvar->aitemss[memvar->nindexs,_DATE2]+" "},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_USER]},nil}},;
                        {"O.R NO.", "   CODE   ", "   DESCRIPTION   ", "  AMOUNT  ",  "  DATE ",    " USER "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"})


if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OR Viewing  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")

aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))


do while .t.
       
        //clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OFFICIAL RECEIPT VIEWING by OR Number")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!" valid ! empty(memvar->cterm)
        read

            setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
            if lastkey() == K_ESC
                    exit
            endif
            if ! term->(dbseek(memvar->cterm))
                    fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
            endif
            if term->status == _CLOSED
                    fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                            "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
            endif
            @ 02,22 say term->name

            bprntscr := savescr(01,00,24,79)

            //ANg NUMBERS SA OPENWCHECK KY MO DETERMINE UNSA NGA INDEX SA SCOPE ANG GE GMIT NGA INDEX EXPRESSION
            byytpayp := "b"+memvar->cterm+"payp"
            zyytpayp := "b"+memvar->cterm+"payp"
            if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,1},;
                                         {,, zyytpayp,"zyytpayp",_DBF_SHARED,,10},;
                                         {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                         {,, "b999chrt",,_DBF_SHARED,,1}})) == nil
                    return(nil)
            endif

            memvar->idno := space(len(a999accp->accidno))
            memvar->pclass := space(01)
            memvar->dpay  := date()
            memvar->cpayno := space(len(byytpayp->payorno))

        //setcursor(1);set(_SET_CONFIRM,.t.)
        do while .t.

                restscr(bprntscr)
                commandline("?         F4 - View Account           ?          ESC - Previous              ?")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)


                @ 04,02 say "OR Number : ";
                        color memvar->colorarray[02];
                        get memvar->cpayno pict "@!" valid ! empty(memvar->cpayno)

               
                read
                    //setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                    setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)

                    if lastkey() == K_ESC
                            //loop
                            exit
                    endif
                    //byytpayp->(dbseek(cpayno+dtos(dpay)))
                    if ! byytpayp->(dbseek(cpayno))
                        fask(10,"   Payment not yet entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    endif

                    memvar->idno := byytpayp->payidno
                    a999accp->(dbseek(memvar->idno))

                    /*if ! 
                        fask(10,"  Students account not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    endif*/

                    memvar->name := ""
                    memvar->checknum := ""
                    memvar->invoice := ""
                    if val(memvar->cterm) < 201
                        @ 06,02 say "Personal Information: " + alltrim(a999accp->acclname) +" "+ alltrim(a999accp->accfname)+ " " +alltrim(a999accp->accmname)
                    else
                        @ 06,02 say "Personal Information: " + alltrim(byytpayp->payname)
                        memvar->name := byytpayp->payname
                        memvar->checknum := byytpayp->paychcknum
                    endif

                    if(val(memvar->cterm) >= 242)
                        memvar->invoice := byytpayp->payinvoice
                    endif


                    //bprntscr := savescr(01,00,24,79)
                    memvar->aitemss := {_EMPTY2}
                    memvar->nindexs := 1

                    indicator = 1
                    processOR(indicator)

                    dispbox(07,01,21,78,_SINGLE_LINE)
                    connectline(09,01,78)
                    //commandline("?         F6 - Print           ?          ESC - Previous              ?")
                    stabilize(viewor,.t.)
                    browsearray(viewor,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)

enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


function byidnum_or_view(cunit,cuser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,byytpayp,idno,pclass,viewor,bindex,bitems,;
      oappren,nrec,nlastelems,cborno,nindexss,checknum,name,invoice
private cterm,nmos,aitemss := {}, nindexs

bindex  := memvarblock("NINDEXS")
bitems  := memvarblock("AITEMSS")


viewor   := createabrowse(bitems,bindex,08,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|pOR(xnmode,xoabrowser,xaxparam,cunit)},;
                        {{{||memvar->aitemss[memvar->nindexs,_ORNO]},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_CODE2]},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_DESCRIPTION2]},nil},;
                         {{||transform(memvar->aitemss[memvar->nindexs,_AMOUNT2],"999,999.99")+" "},nil},;
                         {{||" "+memvar->aitemss[memvar->nindexs,_DATE2]+" "},nil},;
                         {{||memvar->aitemss[memvar->nindexs,_USER]},nil}},;
                        {"O.R NO.", "   CODE   ", "   DESCRIPTION   ", "  AMOUNT  ",  "  DATE ",    " USER "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ"})


if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OR Viewing  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")

aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))


do while .t.
       
        //clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OFFICIAL RECEIPT VIEWING by ID Number")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!" valid ! empty(memvar->cterm)
        read

            setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
            if lastkey() == K_ESC
                    exit
            endif
            if ! term->(dbseek(memvar->cterm))
                    fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
            endif
            if term->status == _CLOSED
                    fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                            "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
            endif
            @ 02,22 say term->name

            bprntscr := savescr(01,00,24,79)

            //ANg NUMBERS SA OPENWCHECK KY MO DETERMINE UNSA NGA INDEX SA SCOPE ANG GE GMIT NGA INDEX EXPRESSION
            byytpayp := "b"+memvar->cterm+"payp"
            zyytpayp := "b"+memvar->cterm+"payp"
            if(aprv2setup := openwcheck({{,, byytpayp,"byytpayp",_DBF_SHARED,,4},;
                                         {,, zyytpayp,"zyytpayp",_DBF_SHARED,,4},;
                                         {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                         {,, "b999chrt",,_DBF_SHARED,,1}})) == nil
                    return(nil)
            endif

            memvar->idno := space(len(a999accp->accidno))
            memvar->pclass := space(01)
            memvar->dpay  := date()
            memvar->cpayno := space(len(byytpayp->payorno))

        //setcursor(1);set(_SET_CONFIRM,.t.)
        do while .t.

                restscr(bprntscr)
                commandline("?         F4 - View Account           ?          ESC - Previous              ?")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)

                @ 03,02 say "Account Number:  ";
                        color memvar->colorarray[02];
                        get memvar->idno pict "@!" valid ! empty(memvar->idno)

                @ 04,25 say "[M-iscellaneous]|[T-uition]|[U-prading] " color memvar->colorarray[02]
                @ 04,02 say "M/T/U : ";
                        color memvar->colorarray[02];
                        get memvar->pclass pict "@!" valid ! empty(memvar->pclass)


                read
                    //setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                    setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)

                    if lastkey() == K_ESC
                            //loop
                            exit
                    endif
                    //byytpayp->(dbseek(cpayno+dtos(dpay)))
                    if ! byytpayp->(dbseek(memvar->idno+memvar->pclass))
                        fask(10,"   Payment not yet entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    endif

                    memvar->name := ""
                    memvar->checknum := ""
                    memvar->invoice := ""
                    
                    if val(memvar->cterm) < 201
                        a999accp->(dbseek(byytpayp->payidno))
                        @ 06,02 say "Personal Information: " + alltrim(a999accp->acclname) +" "+ alltrim(a999accp->accfname)+ " " +alltrim(a999accp->accmname)
                    else
                        @ 06,02 say "Personal Information: " + alltrim(byytpayp->payname)
                        memvar->name := byytpayp->payname
                        memvar->checknum := byytpayp->paychcknum
                    endif 

                    if val(memvar->cterm) >= 242
                        memvar->invoice := byytpayp->payinvoice
                    endif

                    
                   
                    //bprntscr := savescr(01,00,24,79)
                    memvar->aitemss := {_EMPTY2}
                    memvar->nindexs := 1

                    indicator = 2
                    processOR(indicator)

                    dispbox(07,01,21,78,_SINGLE_LINE)
                    connectline(09,01,78)
                    //commandline("?         F6 - Print           ?          ESC - Previous              ?")
                    stabilize(viewor,.t.)
                    browsearray(viewor,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)

enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


static function processOR(indicator)
local nindexsss := 1
            
            if indicator == 2 // indicates idno + tag(M,T,U)
                zyytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->idno+memvar->pclass))
                zyytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->idno+memvar->pclass))
            elseif indicator == 1 //indicates that idno+ornumber
                zyytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->idno+memvar->cpayno))
                zyytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->idno+memvar->cpayno))
            endif
            
            zyytpayp->(dbgotop())
            if ! zyytpayp -> (eof())
                do while ! zyytpayp->(eof())

                            b999chrt->(dbseek(zyytpayp->paycode))

                            nlastelems := len(memvar->aitemss)
                            aadd(memvar->aitemss,_EMPTY2)
                            memvar->aitemss[nlastelems,_ORNO]          := zyytpayp->payorno
                            memvar->aitemss[nlastelems,_CODE2]         := b999chrt->code
                            memvar->aitemss[nlastelems,_DESCRIPTION2]  := alltrim(b999chrt->desc)
                            memvar->aitemss[nlastelems,_AMOUNT2]       := zyytpayp->paypesoamt
                            memvar->aitemss[nlastelems,_DATE2]         := displaydate(zyytpayp->paydte)
                            memvar->aitemss[nlastelems,_USER]          := zyytpayp->payentusr

                            zyytpayp->(dbskip())
                enddo
            endif
            zyytpayp->(clearscope())

            if len(memvar->aitemss) > 1
                for nctr := 1 to len(memvar->aitemss)
                        if empty(memvar->aitemss[nctr,_ORNO])
                                adel(memvar->aitemss,nctr)
                                asize(memvar->aitemss,len(memvar->aitemss)-1)
                        endif
                next
            endif

return(nil)    



static function pOR(nmode,oabrowser,axparam, cunit)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case lastkey() == K_F6
                if fask(13,"  Re-Print O.R ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                        __keyboard(replicate(chr(K_DOWN),1))
                        if whereprint({||printOR2(cunit)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                        return(0)
                endif
                clearbuffer()
endcase
return 2

//printing sa OR version 2 kung tawgon gekan sa table from OR VIEWER
static function printOR2(cunit)
local nmax,nmax1, nctr,nctr1,ntotamt ,ntotamt1, stext, txtlenght, amount, studinfo, particulars,i, currency,  orno, code, date, user, desc
     
local MARGIN := 2
set device to printer

//get items array of information from the table
for nctr := 1 to len(memvar->aitemss)       
        orno := memvar->aitemss[nctr,_ORNO]
        code := memvar->aitemss[nctr,_CODE2]
        desc := memvar->aitemss[nctr,_DESCRIPTION2]
        user := memvar->aitemss[nctr,_USER]
        date := memvar->aitemss[nctr,_DATE2]
        amount :=  memvar->aitemss[nctr,_AMOUNT2]
next

nmax1 := len(memvar->aitemss)
ntotamt := 0
//if nmax1>1
    for nctr := 1 to len(memvar->aitemss)
            ntotamt += memvar->aitemss[nctr,_AMOUNT2]
        next
//endif

a999accp->(dbseek(memvar->idno))

//@ 01,65 say "XXXXXXXXXXXXXXXXXXXX"

//@ 02,64 say "SERVICE INVOICE"
//OR NO:
@ 03,65 say orno
//DATE:
@ 04,65 say date
//TIME:
@ 05,65 say AmPm(time())
//Cashier or User
@ 06,65 say "CS-"+right(cunit,1)+" "+alltrim(substr(user,1,10))
//STUDENTS INFORMATION(ID, FULL NAME)
if empty(memvar->name)
    studinfo := right(memvar->idno,9)+" ";
                +alltrim(a999accp->(acclname))+", ";
                +alltrim(a999accp->(accfname))+" ";
                +alltrim(a999accp->(accmname))+"."
        studinfo := strtran(studinfo,"¥","Å")
else

        studinfo := right(memvar->idno,9)+" ";
                        +alltrim(memvar->name)
                        
        studinfo := strtran(studinfo,"¥","Å")
endif

@ 06,01+MARGIN say studinfo

currency := "PESOS "
    
/*//get items array of information from the table
for nctr := 1 to len(memvar->aitemss)       
        orno := memvar->aitemss[nctr,_ORNO]
        code := memvar->aitemss[nctr,_CODE2]
        desc := memvar->aitemss[nctr,_DESCRIPTION2]
        user := memvar->aitemss[nctr,_USER]
        date := memvar->aitemss[nctr,_DATE2]
        amount :=  memvar->aitemss[nctr,_AMOUNT2]
next*/

txtlenght := trim(amttochar(ntotamt, currency))

//@ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)//THE DISPLAYED AMOUNT IN WORDS
if Len(txtlenght) > 50
    @ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)//THE DISPLAYED AMOUNT IN WORDS

    @ 09,64+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
    @ 10,01+MARGIN say " "+PADR(Substr(txtlenght,51,Len(txtlenght)),Len(txtlenght)-50)

else
    @ 09,01+MARGIN say PADR(Substr(txtlenght,1,50),50)
    
    @ 09,64+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99"))) //THE TOTAL AMOUNT DISPLAYED RIGHT BESIDE AMOUNT OF BOX
   
endif


@12,01+MARGIN say ""//EMPTY SPACE TO DETERMINE WHERE THE PROW() WILL START
nctr1 := 1
nmax := len(memvar->aitemss)

 //LOOP THROUGH TO THE ITEMS AND GET THE CODE AND AMOUNT
do while nctr1 <= nmax //.and. ! len(memvar->aitemss) == nctr1
        b999chrt->(dbseek(memvar->aitemss[nctr1,_CODE2]))
        stext := memvar->aitemss[nctr1,_CODE2] + " " + alltrim(b999chrt->desc)
        stext := padr(stext,37-len(transform(memvar->aitemss[nctr1,_AMOUNT2],"99,999,999.99")))
        stext += transform(memvar->aitemss[nctr1,_AMOUNT2],"99,999,999.99")
       
        //DISPLAY IN PARTICULAR TAB
        @prow()+01,02 say " "+stext
        ++nctr1
enddo

/*stext := code + " " + alltrim(desc)
stext := padr(stext,37-len(transform(amount,"99,999,999.99")))
           
//DISPLAY IN PARTICULAR TAB
@prow()+01,02 say " "+stext*/

if ! empty(memvar->checknum)
    @prow()+01,02 say "Check No. : "+memvar->checknum
endif

if ! empty(memvar->invoice)
    @prow()+01,02 say "Invoice No. : "+memvar->invoice
endif

//the total amount paid display
@18,64+MARGIN say ""+("P "+alltrim(transform(ntotamt,"99,999,999.99")))

@ 20,01 say space(01)
setprc(00,-1)
set device to screen
return(nil)
//end of print OR

//*************************************************************************************************************************
function feesincome()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytassp,ayytpayp,cfile,ccdx,cyytenrp,idno,byytpayp,code,enddate,zyytpayp,xyytpayp,myytpayp,nyytpayp,oyytpayp
private cterm,cdesc,;
        cdummy := "fees"+strzero(memvar->naccess,2),fees

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
memvar->code  := space(2)
enddate := displaydate(date())
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Summary of School Income  ")
        commandline("³        F4 - View Term File           ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)

        
        @ 05,02 say "Code :";
                color memvar->colorarray[02];
                get memvar->code pict "@!";
                valid ! empty(memvar->code)
        @ 06,02 say " [EJ]-> Elem and Junior High " color memvar->colorarray[02]
        @ 07,02 say " [SH]-> Senior High " color memvar->colorarray[02]
        @ 08,02 say " [CO]-> College " color memvar->colorarray[02]
        @ 09,02 say " [AL]-> For EJH, SH, COLLEGE " color memvar->colorarray[02]
        /*       

        @ 06,02 say "End Date :";
                color memvar->colorarray[02];
                get enddate
        */
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name

        if ! file("b"+memvar->cterm+"payp.dbf")
                fask(10,"  b"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

       
        /*if memvar->code == "AL" or. ! file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf") .or. ! file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf")
                fask(10,"  Una ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif*/

        if memvar->code == "EJ" .and. alltrim(substr(memvar->cterm,3,1)) != "1"
                    fask(10,"Please View the Income of Elem and Junior High in First Semester. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop        
        endif

        if memvar->code == "AL" .and. alltrim(substr(memvar->cterm,3,1)) != "1"
                    fask(10,"Viewing of Elementary and Junior High ;"+;
                    " is not allowed in Second Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop        
        endif
        
        aentryscr := savescr(01,00,24,79)
        
        
        byytpayp  := "b"+memvar->cterm+"payp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        oyytpayp  := "b"+memvar->cterm+"payp"

        //if alltrim(substr(memvar->cterm,3,1)) == "2"

        if file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf") .and. ! file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf")

            zyytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp")
            myytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp")

        elseif file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf") .and. file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf")
            zyytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp")
            xyytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp")

            myytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp")
            nyytpayp  := alltrim("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp")

        //else
            //zyytpayp  := "b"+memvar->cterm+"payp"
            //xyytpayp  := "b"+memvar->cterm+"payp"
        endif

        if(aopen2files := openwcheck({{,,byytpayp,"byytpayp",_DBF_SHARED,,4},;
                                      {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,zyytpayp,"zyytpayp",_DBF_SHARED,,4},;
                                      {,,xyytpayp,"xyytpayp",_DBF_SHARED,,4},;
                                      {,,myytpayp,"myytpayp",_DBF_SHARED,,4},;
                                      {,,nyytpayp,"nyytpayp",_DBF_SHARED,,4},;
                                      {,,oyytpayp,"oyytpayp",_DBF_SHARED,,4},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
       
        if whereprint({||pfeesincome()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pfeesincome()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile,ntotstud := 0, ntottui := 0, ntotreg := 0, ntotmisc := 0,;
      ntotlab := 0, ntotdisc := 0, ndiscount := 0, ntotpayment := 0 , ntotpromodiscount := 0 , yrlvl,idno := "",promo := 0,misc := 0,tuition := 0, misc1 := 0, misc2:= 0, misc4 := 0, misctot := 0 , tui1 := 0, tui2 := 0 , tui4 := 0 , tuitot := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"COLCODE"     ,"C",02,0},;
                                 {"COLDESC"     ,"C",06,0},;
                                 {"STUDENT"     ,"N",07,0},;
                                 {"PAYMENT"     ,"N",12,2},;
                                 {"MISCFEE"     ,"N",12,2}},{||cdxcode()})
        dbcloseall()
        return(nil)
endif
memvar->fees := memvar->cdummy
if(afile := openwcheck({{,,(memvar->fees+".TXT"),"fees",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
fees->(__dbzap()); fees->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SUMMARY OF SCHOOL INCOME",nmaxcol))+"SUMMARY OF SCHOOL INCOME"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""+chr(15)})
aadd(abtext,{||"               Course     #Student      Miscellaneous       Tuition"})
aadd(abtext,{||"              --------    ---------     -------------      ----------- "})

**filtering data**
        cyytenrp->(dbgotop())
        do while ! cyytenrp->(eof())
        tui1 := 0
        tui2 := 0 
        tui4 := 0
        tuitot := 0
        misc1 := 0
        misc2 := 0
        misc4 := 0
        misctot := 0

                        if memvar->code == "EJ"
                            if cyytenrp->enrcolcod $ "N1,K1,K2,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" 
                                //fask(10,"  Processing student no. "+cyytenrp->enridno+"  " + memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)

                                  
                                if a999accp->(dbseek("1"+cyytenrp->enridno))
                                      idno = "1"+cyytenrp->enridno
                                elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                                      idno = "2"+cyytenrp->enridno
                                elseif a999accp->(dbseek("3"+cyytenrp->enridno))
                                       idno = "3"+cyytenrp->enridno
                                endif

                                    //a999accp->(dbseek(idno))

                                    //kung naa nay second semester payp.dbf unya wla pay summer nga payp.dbf
                                    if file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf") .and. ! file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf")

                                    fask(10,"  1 "+cyytenrp->enridno+"  " + memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)

                                    byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T"))
                                        byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                        byytpayp->(dbgotop())
                                        if ! byytpayp -> (eof())
                                            do while ! byytpayp->(eof())
                                                tui1 +=  byytpayp->paypesoamt
                                                byytpayp->(dbskip())
                                            enddo
                                        endif
                                        byytpayp->(clearscope())

                                        oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        oyytpayp->(dbgotop())
                                        if ! oyytpayp -> (eof())
                                            do while ! oyytpayp->(eof())
                                                misc1 +=  oyytpayp->paypesoamt
                                                oyytpayp->(dbskip())
                                            enddo
                                        endif
                                        oyytpayp->(clearscope())


                                        zyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T"))
                                        zyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                        zyytpayp->(dbgotop())
                                        if ! zyytpayp -> (eof())
                                            do while ! zyytpayp->(eof())
                                                tui2 += zyytpayp->paypesoamt
                                                zyytpayp->(dbskip())
                                            enddo

                                        endif
                                        zyytpayp->(clearscope())

                                        myytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        myytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        myytpayp->(dbgotop())
                                        if ! myytpayp -> (eof())
                                            do while ! myytpayp->(eof())
                                                misc2 += myytpayp->paypesoamt
                                                myytpayp->(dbskip())
                                            enddo

                                        endif
                                        myytpayp->(clearscope())

                                        misctot = misc1+ misc2
                                        tuitot = tui1 + tui2

                                    //kung available na ang second and summer payp.dbf
                                    elseif file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf") .and. file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf")
                                        fask(10,"  2 "+idno+"  " + memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)

                                        //current term searching
                                        byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T"))
                                        byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                        byytpayp->(dbgotop())
                                        if ! byytpayp -> (eof())
                                            do while ! byytpayp->(eof())
                                                tui1 +=  byytpayp->paypesoamt
                                                byytpayp->(dbskip())
                                            enddo
                                        endif
                                        byytpayp->(clearscope())

                                        oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        oyytpayp->(dbgotop())
                                        if ! oyytpayp -> (eof())
                                            do while ! oyytpayp->(eof())
                                                misc1 +=  oyytpayp->paypesoamt
                                                oyytpayp->(dbskip())
                                            enddo
                                        endif
                                        oyytpayp->(clearscope())
                                        ///////////////////////////////////////////////

                                        // second sem searching ///////////////////////
                                        zyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T"))
                                        zyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                        zyytpayp->(dbgotop())
                                        if ! zyytpayp -> (eof())
                                            do while ! zyytpayp->(eof())
                                                tui2 += zyytpayp->paypesoamt
                                                zyytpayp->(dbskip())
                                            enddo

                                        endif
                                        zyytpayp->(clearscope())

                                        myytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        myytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        myytpayp->(dbgotop())
                                        if ! myytpayp -> (eof())
                                            do while ! myytpayp->(eof())
                                                misc2 += myytpayp->paypesoamt
                                                myytpayp->(dbskip())
                                            enddo

                                        endif
                                        myytpayp->(clearscope())
                                        ////////////////////////////////////////////////

                                        // summer sem searching ///////////////////////
                                        xyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T"))
                                        xyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                        xyytpayp->(dbgotop())
                                        if ! xyytpayp -> (eof())
                                            do while ! xyytpayp->(eof())
                                                tui4 += xyytpayp->paypesoamt
                                                xyytpayp->(dbskip())
                                            enddo

                                        endif
                                        xyytpayp->(clearscope())

                                        nyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        nyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        nyytpayp->(dbgotop())
                                        if ! nyytpayp -> (eof())
                                            do while ! nyytpayp->(eof())
                                                misc4 += nyytpayp->paypesoamt
                                                nyytpayp->(dbskip())
                                            enddo

                                        endif
                                        nyytpayp->(clearscope())
                                        ///////////////////////////////////////////////

                                        //ADD TOTAL MISC AND TUITION FROM FIRST, SECOND AND SUMMER 
                                        misctot = misc1+ misc2 + misc4
                                        tuitot = tui1 + tui2 + tui4


                                    elseif ! file("b"+alltrim(substr(memvar->cterm,1,2))+"2"+"payp.dbf") .and. ! file("b"+alltrim(substr(memvar->cterm,1,2))+"4"+"payp.dbf")

                                        fask(10,"  3 "+cyytenrp->enridno+"  " + memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)

                                        //current term searching
                                        byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //search for tuituion
                                        byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T")) //search for miscelleanous
                                        byytpayp->(dbgotop())
                                        if ! byytpayp -> (eof())
                                            do while ! byytpayp->(eof())
                                                tui1 +=  byytpayp->paypesoamt
                                                byytpayp->(dbskip())
                                            enddo
                                        endif
                                        byytpayp->(clearscope())

                                        oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M"))
                                        oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                        oyytpayp->(dbgotop())
                                        if ! oyytpayp -> (eof())
                                            do while ! oyytpayp->(eof())
                                                misc1 +=  oyytpayp->paypesoamt
                                                oyytpayp->(dbskip())
                                            enddo
                                        endif
                                        oyytpayp->(clearscope())
                                        ///////////////////////////////////////////////

                                        //misctot = misc1
                                        //tuitot = tui1
                                    endif
                                                
                                                if ! fees->(dbseek(cyytenrp->enrcolcod))
                                                     c999colp->(dbseek(cyytenrp->enrcolcod))
                                                      fees->(dbappend())
                                                      fees->colcode   := cyytenrp->enrcolcod
                                                      fees->coldesc   := c999colp->coldesabr
                                                      fees->student   := fees->student + 1                                 
                                                      fees->miscfee   := misc1                           
                                                      fees->payment   := tui1
                                                      fees->(dbcommit())
                                                      fees->(dbunlock())

                                                elseif fees->(dbseek(cyytenrp->enrcolcod))
                                                      fees->(reclock())
                                                      fees->student   := fees->student + 1
                                                      fees->miscfee   := fees->miscfee + misc1
                                                      fees->payment   := fees->payment + tui1 
                                                      fees->(dbcommit())
                                                      fees->(dbunlock())
                                                endif

                                if nextkey() == K_ESC
                                        exit
                                endif
                            endif
                            //cyytenrp->(dbskip())

                        elseif memvar->code == "SH"
                                if  cyytenrp->enrcolcod $ "TM,GS,PB,ST,HU" 

                                            if a999accp->(dbseek("1"+cyytenrp->enridno))
                                                  idno = "1"+cyytenrp->enridno
                                            elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                                                  idno = "2"+cyytenrp->enridno
                                            elseif a999accp->(dbseek("3"+cyytenrp->enridno))
                                                   idno = "3"+cyytenrp->enridno
                                            endif

                                              fask(10,"  Processing student no. "+cyytenrp->enridno+"  "+memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //searches for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //searches for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                misctot = misc1
                                                tuitot = tui1
                                                                
                                                                if ! fees->(dbseek(cyytenrp->enrcolcod))
                                                                     c999colp->(dbseek(cyytenrp->enrcolcod))
                                                                      fees->(dbappend())
                                                                      fees->colcode   := cyytenrp->enrcolcod
                                                                      fees->coldesc   := c999colp->coldesabr
                                                                      fees->student   := fees->student + 1                                 
                                                                      fees->miscfee   := misc1                        
                                                                      fees->payment   := tui1
                                                                      fees->(dbcommit())
                                                                      fees->(dbunlock())

                                                                elseif fees->(dbseek(cyytenrp->enrcolcod))
                                                                      fees->(reclock())
                                                                      fees->student   := fees->student + 1
                                                                      fees->miscfee   := fees->miscfee + misc1
                                                                      fees->payment   := fees->payment + tui1 
                                                                      fees->(dbcommit())
                                                                      fees->(dbunlock())
                                                                endif
                                                //endif      
                                endif
                                if nextkey() == K_ESC
                                    exit
                                endif
                                //cyytenrp->(dbskip())

                        elseif memvar->code == "CO"
                            if ! cyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" .and. cyytenrp->enrenrst == "C"
                                    if a999accp->(dbseek("1"+cyytenrp->enridno))
                                        idno = "1"+cyytenrp->enridno
                                    elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                                        idno = "2"+cyytenrp->enridno
                                    elseif a999accp->(dbseek("3"+cyytenrp->enridno))
                                        idno = "3"+cyytenrp->enridno
                                    endif

                                if cyytenrp->enrcolcod $ "HN,MV,SN,MI,TL" //CHECK ALL COLCODE FOR MARINE TRANSPORTATION
                                            

                                              fask(10,"  Processing student no. "+cyytenrp->enridno+"  "+memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //searches for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //searches for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                misctot = misc1
                                                tuitot = tui1
                                                                
                                                if ! fees->(dbseek("MV"))
                                                    c999colp->(dbseek("MV"))
                                                    fees->(dbappend())
                                                    fees->colcode   := cyytenrp->enrcolcod
                                                    fees->coldesc   := c999colp->coldesabr
                                                    fees->student   := fees->student + 1                                 
                                                    fees->miscfee   := misc1                        
                                                    fees->payment   := tui1
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())

                                                elseif fees->(dbseek("MV"))
                                                    fees->(reclock())
                                                    fees->student   := fees->student + 1
                                                    fees->miscfee   := fees->miscfee + misc1
                                                    fees->payment   := fees->payment + tui1 
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())
                                                endif
                                elseif cyytenrp->enrcolcod $ "HM,ML,MM,MR,SM" //CHECK ALL COLCODE FOR MARINE ENG
                                            

                                              fask(10,"  Processing student no. "+cyytenrp->enridno+"  "+memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //searches for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //searches for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                misctot = misc1
                                                tuitot = tui1
                                                                
                                                if ! fees->(dbseek("MM"))
                                                    c999colp->(dbseek("MM"))
                                                    fees->(dbappend())
                                                    fees->colcode   := cyytenrp->enrcolcod
                                                    fees->coldesc   := c999colp->coldesabr
                                                    fees->student   := fees->student + 1                                 
                                                    fees->miscfee   := misc1                        
                                                    fees->payment   := tui1
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())

                                                elseif fees->(dbseek("MM"))
                                                    fees->(reclock())
                                                    fees->student   := fees->student + 1
                                                    fees->miscfee   := fees->miscfee + misc1
                                                    fees->payment   := fees->payment + tui1 
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())
                                                endif
                                elseif cyytenrp->enrcolcod $ "MN,NS" // CHECK ALL COLCODE FOR NAME

                                              fask(10,"  Processing student no. "+cyytenrp->enridno+"  "+memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //searches for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //searches for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                misctot = misc1
                                                tuitot = tui1
                                                                
                                                if ! fees->(dbseek("MN"))
                                                    c999colp->(dbseek("MN"))
                                                    fees->(dbappend())
                                                    fees->colcode   := cyytenrp->enrcolcod
                                                    fees->coldesc   := c999colp->coldesabr
                                                    fees->student   := fees->student + 1                                 
                                                    fees->miscfee   := misc1                        
                                                    fees->payment   := tui1
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())

                                                elseif fees->(dbseek("MN"))
                                                    fees->(reclock())
                                                    fees->student   := fees->student + 1
                                                    fees->miscfee   := fees->miscfee + misc1
                                                    fees->payment   := fees->payment + tui1 
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())
                                                endif 
                                else
                                            fask(10,"  Processing student no. "+cyytenrp->enridno+"  "+memvar->code+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //searches for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //searches for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                                
                                                if ! fees->(dbseek(cyytenrp->enrcolcod))
                                                    c999colp->(dbseek(cyytenrp->enrcolcod))
                                                    fees->(dbappend())
                                                    fees->colcode   := cyytenrp->enrcolcod
                                                    fees->coldesc   := c999colp->coldesabr
                                                    fees->student   := fees->student + 1                                 
                                                    fees->miscfee   := misc1                        
                                                    fees->payment   := tui1
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())

                                                elseif fees->(dbseek("MN"))
                                                    fees->(reclock())
                                                    fees->student   := fees->student + 1
                                                    fees->miscfee   := fees->miscfee + misc1
                                                    fees->payment   := fees->payment + tui1 
                                                    fees->(dbcommit())
                                                    fees->(dbunlock())
                                                endif
                                endif
                            endif 

                            if nextkey() == K_ESC
                                exit
                            endif   
                        elseif memvar->code == "AL" .and. alltrim(substr(memvar->cterm,3,1)) == "1"

                                if  cyytenrp->enrcolcod $ "TM,GS,PB,ST,HU,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,HN,MV,SN,MI,TL,HM,ML,MM,MR,SM,MN,NS,CS" 
                                            if a999accp->(dbseek("1"+cyytenrp->enridno))
                                                  idno = "1"+cyytenrp->enridno
                                            elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                                                  idno = "2"+cyytenrp->enridno
                                            elseif a999accp->(dbseek("3"+cyytenrp->enridno))
                                                   idno = "3"+cyytenrp->enridno
                                            endif

                                              fask(10,"  3 "+cyytenrp->enridno+"  "+ memvar->code +" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                //if a999accp->(dbseek(idno))

                                                //current term searching
                                                byytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"T")) //search for tuition
                                                byytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"T"))
                                                byytpayp->(dbgotop())
                                                if ! byytpayp -> (eof())
                                                    do while ! byytpayp->(eof())
                                                        tui1 +=  byytpayp->paypesoamt
                                                        byytpayp->(dbskip())
                                                    enddo
                                                endif
                                                byytpayp->(clearscope())

                                                oyytpayp->(sx_setscope(_TOP_SCOPE   ,idno+"M")) //search for miscelleanous
                                                oyytpayp->(sx_setscope(_BOTTOM_SCOPE,idno+"M"))
                                                oyytpayp->(dbgotop())
                                                if ! oyytpayp -> (eof())
                                                    do while ! oyytpayp->(eof())
                                                        misc1 +=  oyytpayp->paypesoamt
                                                        oyytpayp->(dbskip())
                                                    enddo
                                                endif
                                                oyytpayp->(clearscope())
                                                ///////////////////////////////////////////////

                                                                if ! fees->(dbseek(cyytenrp->enrcolcod))
                                                                     c999colp->(dbseek(cyytenrp->enrcolcod))
                                                                      fees->(dbappend())
                                                                      fees->colcode   := cyytenrp->enrcolcod
                                                                      fees->coldesc   := c999colp->coldesabr
                                                                      fees->student   := fees->student + 1                                 
                                                                      fees->miscfee   := misc1                           
                                                                      fees->payment   := tui1
                                                                      fees->(dbcommit())
                                                                      fees->(dbunlock())

                                                                elseif fees->(dbseek(cyytenrp->enrcolcod))
                                                                      fees->(reclock())
                                                                      fees->student   := fees->student + 1
                                                                      fees->miscfee   := fees->miscfee + misc1
                                                                      fees->payment   := fees->payment + tui1 
                                                                      fees->(dbcommit())
                                                                      fees->(dbunlock())
                                                                endif
                                                    
                                endif
                                if nextkey() == K_ESC
                                    exit
                                endif
                        endif
 
           cyytenrp->(dbskip())      
        enddo

**printing data**
pageprint(abtext)
fees->(dbgotop())
do while ! fees->(eof())
        fask(10,"  Printing college "+fees->colcode+"-"+alltrim(fees->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say "              "+fees->colcode+"-"+fees->coldesc+"  "+;
                           transform(fees->student,"9999,999")+"     "+; 
                           transform(fees->miscfee,"999,999,999.99")+"    "+;
                           transform(fees->payment,"999,999,999.99")


        ntotstud += fees->student  
        ntotmisc += fees->miscfee   
        ntotpayment += fees->payment 
        if nextkey() == K_ESC
                exit
        endif
        fees->(dbskip())
enddo
@ prow()+01,00 say "               --------   ---------     -------------      ----------- "
@ prow()+01,00 say "ETOTALS                 "+transform(ntotstud,"9999,999")+"    "+; 
                                 transform(ntotmisc,"999,999,999.99")+"     "+;
                                 transform(ntotpayment ,"999,999,999.99")

@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function cdxcode()
field colcode
private cdummyfile := alias()
index on colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function isElemJH(misc,tuition)
    local idnum := ""
        zyytenrp->(dbgotop())
        do while ! zyytenrp->(eof())
                
                //$ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(memvar->cterm,3,1)) != "1" 
                //alltrim("a"+alltrim(substr(memvar->cterm,1,2))+"1"+"payp")

                if zyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" 
                        
                          
                        if a999accp->(dbseek("1"+zyytenrp->enridno))
                              idnum = "1"+zyytenrp->enridno
                        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                              idnum = "2"+zyytenrp->enridno
                        elseif a999accp->(dbseek("3"+cyytenrp->enridno))
                               idnum = "3"+zyytenrp->enridno
                        endif

                        fask(10,"  Processing student no. "+idnum+"  "+zyytenrp->enrcolcod+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                            if a999accp->(dbseek(idnum))
                                if byytpayp->(dbseek(a999accp->accidno+"M"))
                                    misc = byytpayp->paypesoamt
                                elseif byytpayp->(dbseek(a999accp->accidno+"T"))
                                    tuition = byytpayp->paypesoamt
                                endif
                                            
                                            if ! fees->(dbseek(zyytenrp->enrcolcod))
                                                 c999colp->(dbseek(zyytenrp->enrcolcod))
                                                  fees->(dbappend())
                                                  fees->colcode   := zyytenrp->enrcolcod
                                                  fees->coldesc   := c999colp->coldesabr
                                                  fees->student   := fees->student + 1                                 
                                                  fees->miscfee   := misc                           
                                                  fees->payment   := tuition
                                                  fees->(dbcommit())
                                                  fees->(dbunlock())

                                            elseif fees->(dbseek(zyytenrp->enrcolcod))
                                                  fees->(reclock())
                                                  fees->student   := fees->student + 1
                                                  fees->miscfee   := fees->miscfee + misc
                                                  fees->payment   := fees->payment + tuition 
                                                  fees->(dbcommit())
                                                  fees->(dbunlock())
                                            endif
                            endif
                endif
                if nextkey() == K_ESC
                        exit
                endif
                zyytenrp->(dbskip())
        enddo

return(nil)


function chartcodeincome()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,oscholar,bindex,bitems,;
      byytpayp,cfile,ccdx,cnotedby:=cdesgn:=space(35)
private aitems := {},nindex,cterm,cdesc,cprivcode,ntotalamt,nctr,cprivdesc,;
        cdummy := "bycode"+strzero(memvar->naccess,2),bycode,summary,cstud,code

bindex   := memvarblock("NINDEX")
bitems   := memvarblock("AITEMS")
oscholar := createabrowse(bitems,bindex,06,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fstcode(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitems[memvar->nindex,_P_ACCTNO]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_LNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_FNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_COURSE]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_ORNO]},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_P_DATE]+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_P_AMOUNT],"9,999,999.99")},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_CASHIER]},nil}},;
                        {"Account #", "   Last Name   ", "       First Name       ", " Course/Grade "," ORNO " , "  Date  ", " Amount ", " Cashier "},;
                        {"ÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",  "ÂÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",  "ÂÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄ"})
                      

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                              {,, "b999chrt",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
memvar->code  := space(len(b999chrt->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Report by Chart Code ")

        /*
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        */

        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)

        commandline("³              F4-View Code            ³             ESC-Previous              ³")
        setcursor(1);set(_SET_CONFIRM,.t.)
        setkey(K_F4,{||viewchart({||__keyboard(chr(K_CTRL_LEFT)+;
        b999chrt->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)

        @ 04,02 say "Chart Code :";
                color memvar->colorarray[02];
                get memvar->code pict "@!";
                valid ! empty(memvar->code)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! b999chrt->(dbseek(memvar->code))
                fask(10,"  Chart Code not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name

        if ! file("b"+memvar->cterm+"payp.dbf")
                fask(10,"  b"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif


        aentryscr := savescr(01,00,24,79)
        byytpayp  := "b"+memvar->cterm+"payp"
        
       
        if(aopen2files := openwcheck({{,,byytpayp,"byytpayp",_DBF_SHARED,,11},;
                                      {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        memvar->aitems := {_P_EMPTY}
        memvar->nindex := 1
        //bycode->(__dbzap()); bycode->(dbreindex())
                
               
        processbycode()
        dispbox(05,01,21,78,_SINGLE_LINE)
        connectline(07,01,78)
        commandline("³ F6 - Print Report ³  ESC - Previous ³")
        @ 22,02 say "                        "+ltrim(transform(memvar->nctr,"9999"))
        @ 22,02 say "Total No. of Students : " color memvar->colorarray[02]
        @ 22,51 say "               "+transform(memvar->ntotalamt,"9,999,999.99")
        @ 22,51 say "Total Amount : " color memvar->colorarray[02]
        stabilize(oscholar,.t.)
        browsearray(oscholar,{""},{|b|b:gotop()})

        

        closewcheck(aopen2files)

        cfile := (memvar->cdummy+"B"+".TXT"); ccdx := (memvar->cdummy+"B"+".CDX")
        ferase(cfile);ferase(ccdx)

        /*cfile := (memvar->cdummy+"S"+".TXT"); ccdx := (memvar->cdummy+"S"+".CDX")
        ferase(cfile);ferase(ccdx)*/
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function processbycode()
local nlastelem,nctr1,cpercent
memvar->ntotalamt := memvar->nctr := 0

byytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->code))
byytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->code))

byytpayp->(dbgotop())
do while ! byytpayp->(eof())
    
    fask(10,"  Processing student "+byytpayp->payidno+"-"+alltrim(byytpayp->payname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)

        a999accp->(dbseek(byytpayp->payidno))
        c999colp->(dbseek(a999accp->acccolcod))

        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := byytpayp->payidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        //memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname
        memvar->aitems[nlastelem,_P_COURSE ]    := c999colp->coldesabr
        memvar->aitems[nlastelem,_P_ORNO ]      := byytpayp->payorno
        memvar->aitems[nlastelem,_P_DATE ]      := displaydate(byytpayp->paydte)
        memvar->aitems[nlastelem,_P_AMOUNT ]    := byytpayp->paypesoamt
        memvar->aitems[nlastelem,_P_CASHIER ]   := byytpayp->payentusr

        memvar->ntotalamt += byytpayp->paypesoamt
        ++memvar->nctr
      
        if nextkey() == K_ESC
                exit
        endif
        byytpayp->(dbskip())
enddo
byytpayp->(clearscope())

if len(memvar->aitems) > 1
        for nctr1 := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr1,_P_ACCTNO])
                        adel(memvar->aitems,nctr1)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
asort(memvar->aitems,,,{|a,b|a[_P_LNAME]+a[_P_FNAME]<b[_P_LNAME]+b[_P_FNAME]})
return(nil)


static function fstcode(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_F6
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pbycode()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function pbycode()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0, nline := 0,;
      npagetotal := 0, ngrandtotal := 0, namt := 0, nstud := 0, privcourse := space(8)
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-14)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(b999chrt->code)+"-"+alltrim(b999chrt->desc)+" REPORT",nmaxcol))+alltrim(b999chrt->code)+"-"+alltrim(b999chrt->desc)+" REPORT"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})

aadd(abtext,{||"      Account#    Last Name          First Name         Course/Grade   ORNO     Date      Amount     Cashier  "})
aadd(abtext,{||"     --------- --------------- ----------------------    ----------     ----   --------   ---------   --------  "})


pageprint(abtext)

if len(memvar->aitems) > 1
    
    for nctr := 1 to len(memvar->aitems)
        //if empty(memvar->aitems[nctr,_P_ACCTNO])

            fask(10," Printing name "+alltrim(memvar->aitems[nctr,_P_LNAME])+", "+alltrim(memvar->aitems[nctr,_P_FNAME])+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
              
                        if prow() > 55
                                __eject()
                                pageprint(abtext)
                        endif
                        @ prow()+01,00 say transform(++nline,"999")+". "+;
                                           memvar->aitems[nctr,_P_ACCTNO]+" "+;
                                           memvar->aitems[nctr,_P_LNAME]+" "+;
                                           memvar->aitems[nctr,_P_FNAME]+" "+;
                                           padR(memvar->aitems[nctr,_P_COURSE],8)+"   "+;
                                           memvar->aitems[nctr,_P_ORNO]+"   "+;
                                           memvar->aitems[nctr,_P_DATE]+" "+;
                                           transform(memvar->aitems[nctr,_P_AMOUNT],"@Z 999,999.99")+" "+;
                                           memvar->aitems[nctr,_P_CASHIER]

                        npagetotal  += memvar->aitems[nctr,_P_AMOUNT]
                        ngrandtotal += memvar->aitems[nctr,_P_AMOUNT]

                        ++nstud
                        namt += memvar->aitems[nctr,_P_AMOUNT]
        //endif
    next

    @ prow()+01,00 say ""
    nstud := namt := 0
endif


@ prow()+00,71 say "----------"
@ prow()+01,52 say "  T O T A L  --> "+transform(ngrandtotal,"@Z 9,999,999.99")
__eject()
//summary(npage)
return(nil)


function acctinfo()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,aentryscr,lexist,cprocsts,oacct,bindex,bitems,;
      ayytpayp,ayytassp,ayytprsp,cyytenrp,cyytskdp
private aitems:={},nindex,cterm,cdesc,cacctno,ntotamt,;
        cname,ccourse,cyear,cpriv,cfeeyr,cenroll,nunits,nfeeunit,;
        ntassess,noaccts,nadjust,nadisc,crdisc,ntdue,ntamtpd,ntbal,;
        aitemss := {}, nindexs := 1,ntotunit := 0

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")


oacct   := createabrowse(bitems,bindex,12,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|facct(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitems[memvar->nindex,_REFNO]},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_DATE]+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_DEBIT],"99,999,999.99")+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_CREDIT],"99,999,999.99")+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_BALANCE],"999,999.99")+" "},nil},;
                         {{||memvar->aitems[memvar->nindex,_USERID]},nil},;
                         {{||memvar->aitems[memvar->nindex,_REMARKS]},nil}},;
        {"Ref. No.", "   Date   ","   Debit  ", "  Credit  ", "  Balance ", "User id ", "Remarks"},;
        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ"},;
        {"³","³","³","³","³","³","³","³","³"},;
        {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ"})
                      *   12345678    11/11/1111    123,123.12    1123,123.12    123,123.12    12345678    Pending

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Statement of Accounts  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  . . . :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,27 say "- "+term->name
        if ! file("/arunlib/a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/arunlib/a"+memvar->cterm+"assp.dbf")
                fask(10,"  A"+memvar->cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/arunlib/a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"skdp.dbf")
                fask(10,"  C"+memvar->cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+memvar->cterm+"payp"
        ayytassp  := "a"+memvar->cterm+"assp"
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        cyytskdp  := "c"+memvar->cterm+"skdp"
        byytpayp  := "b"+memvar->cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,byytpayp,"byytpayp",_DBF_SHARED,,3,"/brunlib"},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"blocklst",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999stcp",,_DBF_SHARED,,1,"/arunlib"},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2,"/arunlib"},;
                                   {,,ayytprsp,"ayytprsp",_DBF_SHARED,,1,"/arunlib"},;
                                   {,,"b999chrt",,_DBF_SHARED,,1,"/brunlib"},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1,"/arunlib"}}))==nil
                return(nil)
        endif
        memvar->cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                commandline("?         F4 - View Account           ?          ESC - Previous              ?")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Account Number. . :";
                        color memvar->colorarray[02];
                        get memvar->cacctno     pict "@!";
                        valid ! empty(memvar->cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(memvar->cacctno))
                        fask(10,"  Students account not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif


                if c999colp->(dbseek(a999accp->acccolcod))
                        memvar->ccourse := c999colp->coldesabr
                elseif a999stcp->(dbseek(a999accp->acccolcod))
                        memvar->ccourse := a999stcp->stcdesabr
                endif
                if blocklst->(dbseek(right(memvar->cacctno,8))) .and. ;
                        left(memvar->cacctno,1)=="1" .and. ;
                        (blocklst->blkreason != "BOUNCING CHECK")
                        fask(10," Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                endif
                
                testresetrecord(cacctno)//recompute
                
                memvar->cname           := alltrim(a999accp->acclname)+",  "+alltrim(a999accp->accfname)+"  "+a999accp->accmname+"."
                *memvar->ccourse         := c999colp->coldesabr
                memvar->cyear           := a999accp->accyrlevl //Course and YEAR
                memvar->cenroll         := a999accp->accsyt // Last Enrolment
                memvar->nunits          := a999accp->accsytunt //No. of Units
                memvar->cfeeyr          := a999accp->accfeeyr // Fee YEAR
                memvar->nfeeunit        := a999accp->accfeeunt //Fee Per unit
                memvar->ntassess        := a999accp->accsytass // Total Assesment
                memvar->noaccts         := a999accp->accbalold // Old ACCOUNTS
                memvar->nadjust         := a999accp->accadj // Adjustments
                memvar->ntdue           := a999accp->accduetot // Total Due
                memvar->ntamtpd         := a999accp->accamtpd // Total Amount Paid
                memvar->ntbal           := a999accp->accbaltot // Total BALANCE
                memvar->cpriv           := a999accp->acccode // Privilege
                memvar->nadisc          := a999accp->accsytadsc //DISCOUNT
                memvar->crdisc          := " "
                memvar->nadisc          := 0
               
                
                
                        if ! left(a999accp->acccode,1) == "X"
                                memvar->nadisc  := a999accp->accsytadsc
                                if a999accp->accsytpdsc == 0
                                        memvar->crdisc := "FF"
                                else
                                        memvar->crdisc := transform(a999accp->accsytpdsc*100,"999")+"%"
                                endif

                        endif


                memvar->aitems := {_EMPTY_3}
                memvar->nindex := 1
                processtrans()
                dspdata()

                dispbox(11,01,21,78,_SINGLE_LINE)
                connectline(12,01,78)
                
                commandline("?F6 - Subject ?F8 - Clearance ?  F9 - Post  ? F10 - Print ?ESC - Previous ?")
                stabilize(oacct,.t.)
                browsearray(oacct,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

//THIS WILL RESET THE COMPUTATION
static function testresetrecord(cacctno)
local noldacct := 0,nadjust := 0,ndisc := 0,ntotdue := 0,;
      namtpd := 0,nbal := 0
      

        ayytpayp->(sx_setscope(_TOP_SCOPE   ,cacctno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,cacctno))
        ayytpayp->(dbgotop())
        
        do while ! ayytpayp->(eof())
                fask(13,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[11],.f.,nil)
                do case
                        case ayytpayp->paytag == _POSTED
                                namtpd += ayytpayp->payamt

                        case ayytpayp->paytag == _FORWARDED

                                if ayytpayp->payamt < 0
                                        nadjust += ayytpayp->payamt
                                elseif ayytpayp->payamt > 0
                                        noldacct += ayytpayp->payamt
                                endif

                        case ayytpayp->paytag == _DISCOUNT
                                ndisc += ayytpayp->payamt

                        case ayytpayp->paytag == _ADJUSTMENT
                                nadjust += ayytpayp->payamt

                        case ayytpayp->paytag == _SHORT_TERM
                                nadjust += ayytpayp->payamt
                endcase
                ayytpayp->(dbskip())
        enddo
        ayytpayp->(clearscope())
        ayytassp->(dbseek(cacctno))
        
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accsytass     := ayytassp->asstotal
        a999accp->accduetot     := a999accp->accsytass + noldacct + nadjust - ndisc
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := a999accp->accduetot - namtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())

return(nil)
//END OF RESET RECORDS FUNCTION



static function facct(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0 .and. rights("[BEWARE]")
                @ 22,02 say "               "+memvar->aitems[memvar->nindex,_PAYFOR]
                @ 22,02 say "Payment For -> " color memvar->colorarray[02]
                @ 23,02 say "             "+memvar->aitems[memvar->nindex,_REFNO1]
                @ 23,02 say "Reference -> " color memvar->colorarray[02]
                return 1
        case lastkey() == K_F8
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pclear()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pacct()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
        case lastkey() == K_F9
                if fask(13,"  Post payments ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                        postpayment()
                        return(0)
                endif
        case lastkey() == K_F6
                dispsubject()
endcase
return 2

*-----------------------------------------------------------------------------*

//this will display the table of payments in statement of accounts

static function processtrans()
local nlastelem,nctr
memvar->ntotamt := 0

if ayytassp->(dbseek(memvar->cacctno))
        aadd(memvar->aitems,_EMPTY_3)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_REFNO]        := "ASSMNT  "
        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytassp->assenrdte)
        memvar->aitems[nlastelem,_DEBIT]        := ayytassp->asstotal
        memvar->aitems[nlastelem,_BALANCE]      := ayytassp->asstotal
        memvar->aitems[nlastelem,_USERID]       := substr(ayytassp->asscusrid,1,8)
        memvar->aitems[nlastelem,_REMARKS]      := if(ayytassp->asstag == "C","Changed",;
                                                   if(ayytassp->asstag == "U","Posted ","       "))
        memvar->ntotamt                         := ayytassp->asstotal



endif

ayytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(13,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)

          byytpayp->(dbseek(ayytpayp->paycolcod))
          b999chrt->(dbseek(byytpayp->paycode))

        do case
                    
                case ayytpayp->paytag = _PAYMENT
                      
                        aadd(memvar->aitems,_EMPTY_3)
                        nlastelem := len(memvar->aitems)
                        *memvar->ntotamt -= ayytpayp->payamt
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payrefno 
                        //a999stcp->(dbseek(ayytpayp->paycolcod))
                        
    
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "       "
                        memvar->aitems[nlastelem,_PAYFOR]       := b999chrt->desc
                        
                case ayytpayp->paytag = _POSTED
                        byytpayp->(dbseek(ayytpayp->paycolcod))
                        b999chrt->(dbseek(byytpayp->paycode))

                        aadd(memvar->aitems,_EMPTY_3)
                        nlastelem := len(memvar->aitems)
                        memvar->ntotamt -= ayytpayp->payamt
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payrefno
                        
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "Posted "
                        memvar->aitems[nlastelem,_PAYFOR]       := b999chrt->desc
                        

                case ayytpayp->paytag $ _ADJUSTMENT+_FORWARDED
                        aadd(memvar->aitems,_EMPTY_3)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payadjcod+space(06)
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        if ayytpayp->payamt < 0
                                memvar->ntotamt                         -= (ayytpayp->payamt * -1)
                                memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                                memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        else
                                memvar->ntotamt                         += ayytpayp->payamt
                                memvar->aitems[nlastelem,_DEBIT]        := ayytpayp->payamt
                                memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        endif
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "Posted "
                        memvar->aitems[nlastelem,_REFNO1]       := ayytpayp->payrefno


                case ayytpayp->paytag == _DISCOUNT
                        aadd(memvar->aitems,_EMPTY_3)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->paymach
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->ntotamt                         -= ayytpayp->payamt
                        memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "Posted "
                        memvar->aitems[nlastelem,_REFNO1]       := ayytpayp->payrefno

                case ayytpayp->paytag == _SHORT_TERM
                        a999stcp->(dbseek(ayytpayp->paycolcod))
                        aadd(memvar->aitems,_EMPTY_3)
                        nlastelem := len(memvar->aitems)

                        /*
                            memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payadjcod+"-"+alltrim(ayytpayp->paymach)+(space(08-len(ayytpayp->payadjcod+"-"+alltrim(ayytpayp->paymach))))
                            memvar->aitems[nlastelem,_REFNO]        := if(empty(ayytpayp->paycourse),ayytpayp->payadjcod+"-"+alltrim(ayytpayp->paymach)+(space(08-len(ayytpayp->payadjcod+"-"+alltrim(ayytpayp->paymach)))),;
                                                                          ayytpayp->paycourse+"  ")
                        */

                        memvar->aitems[nlastelem,_REFNO]        := a999stcp->stcdesabr+space(02)
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->ntotamt                         += ayytpayp->payamt
                        memvar->aitems[nlastelem,_DEBIT]        := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "Posted "
                        memvar->aitems[nlastelem,_REFNO1]       := ayytpayp->payrefno
        endcase
        ayytpayp->(dbskip())
enddo
ayytpayp->(clearscope())
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_REFNO])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)

*-----------------------------------------------------------------------------*
//clearance for statement of accounts (f8)
static function pclear()
local nctr := 0, arepscr := savescr(01,00,24,79)
@ 01,20 say "E          UNIVERSITY OF CEBU        "
@ 02,20 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 03,20 say "     Alumnos, Mambaling, Cebu City    "
@ 06,20 say "  CLEARANCE FOR BSMT / BSMARE DEGREE  "
@ 10,05 say cmonth(date())+str(day(date()))+","+str(year(date()))
@ 13,05 say "ETo Whom It May Concern :"
@ 16,10 say "This is to certify that Mr./Ms. E"+alltrim(a999accp->acclname)+","+alltrim(a999accp->accfname)+" "+alltrim(a999accp->accmname)+"."
@ 17,05 say "took the apprenticeship for his / her BSMT / BSMARE degree.E"
@ 20,10 say "This is to certify that he/she has fully paid his accounts"
@ 21,05 say "as of this date."
@ 24,10 say "This certification is issued for "+"EVERIFICATION PURPOSES only."
@ 29,50 say "Carl Joseph G. Tecson, CPA"
@ 30,50 say "Head - SAS Dept."
@ 34,05 say "UC-METC/SAC.DOC./013/REV.0"

*__eject()
@ 41,01 say space(01)
setprc(06,19)

*__eject()
restscr(arepscr)
return(nil)

*-----------------------------------------------------------------------------*
//printing statement of accnt (f10)
static function pacct()
local nctr := 0, arepscr := savescr(01,00,24,79)
@ 01,20 say "E          UNIVERSITY OF CEBU        "
@ 02,20 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 03,20 say "     Alumnos, Mambaling, Cebu City    "
@ 04,20 say "        Telephone No.: 261-9963       "

@ 06,20 say "         STATEMENT OF ACCOUNTS        "

@ 08,00 say "School Term : "+memvar->cdesc

@ 10,00 say "Account Number  : "+memvar->cacctno
@ 11,00 say "  Student Name  : "+memvar->cname
@ 12,00 say "  Course & Year : "+alltrim(memvar->ccourse)+" "+memvar->cyear
@ 12,28 say "Privilege   : "+memvar->cpriv
@ 12,50 say "Fee Year    : "+memvar->cfeeyr
@ 13,00 say "  Last Enrolment: "+memvar->cenroll
@ 13,28 say "No. of Units: "+transform(memvar->nunits,"99.9")
@ 13,50 say "Fee Per Unit: "+transform(memvar->nfeeunit,"9999.99")


@ 15,02 say "Total Assessment: " +transform(memvar->ntassess,"99,999,999.99")
@ 15,36 say "Total Due        : "+transform(memvar->ntdue,"99,999,999.99")
@ 16,02 say "Old Accounts    : " +transform(memvar->noaccts,"99,999,999.99")
@ 16,36 say "Total Amount Paid: "+transform(memvar->ntamtpd,"99,999,999.99")
@ 17,02 say "Adjustments     : " +transform(memvar->nadjust,"99,999,999.99")
@ 17,36 say "Total Balance    : "+transform(memvar->ntbal,"999,999.99")
@ 18,02 say "Discounts       :  " +transform(memvar->nadisc,"999,999.99")





@ 20,00 say "  Ref#       Date         Debit         Credit       Balance     UserId   Remarks"
@ 21,00 say "--------  ----------    ----------    ----------    ----------  --------  -------"

//@ 15,00 say "  Ref#       Payment For        Date         Debit         Credit       Balance     UserId   Remarks"
//@ 16,00 say "--------  -----------------  ----------    ----------    ----------    ----------  --------  -------"

for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing Ref. No. "+alltrim(memvar->aitems[nctr,_REFNO])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say memvar->aitems[nctr,_REFNO]+" "+;
                           memvar->aitems[nctr,_DATE]+" "+;
                           transform(memvar->aitems[nctr,_DEBIT],"@Z 99,999,999.99")+" "+;
                           transform(memvar->aitems[nctr,_CREDIT],"@Z 99,999,999.99")+" "+;
                           transform(memvar->aitems[nctr,_BALANCE]," 99,999,999.99")+"  "+;
                           memvar->aitems[nctr,_USERID]+"  "+;
                           memvar->aitems[nctr,_REMARKS]
next
@ 40,05 say "UC-METC/SFM-SAC-015/REV.00"
__eject()
restscr(arepscr)
return(nil)

*-----------------------------------------------------------------------------*
static function dspdata()
@ 04,04 say "                   "+memvar->cname
@ 04,04 say "Student Name . . : " color memvar->colorarray[02]
@ 05,04 say "                   "+alltrim(memvar->ccourse)+" "+memvar->cyear
@ 05,04 say "Course & Year  . : " color memvar->colorarray[02]
@ 06,04 say "                   "+memvar->cenroll
@ 06,04 say "Last Enrolment . : " color memvar->colorarray[02]
@ 05,32 say "                 "+memvar->cpriv
@ 05,32 say "Privilege  . . : " color memvar->colorarray[02]
@ 06,32 say "                 "+transform(memvar->nunits,"99.9")
@ 06,32 say "No. of Units . : " color memvar->colorarray[02]
@ 05,54 say "                 "+memvar->cfeeyr
@ 05,54 say "Fee Year . . . : " color memvar->colorarray[02]
@ 06,54 say "                 "+transform(memvar->nfeeunit,"9999.99")
@ 06,54 say "Fee Per Unit . : " color memvar->colorarray[02]
 
@ 07,02 say "                         "+transform(memvar->ntassess,"99,999,999.99")
@ 07,02 say "Total Assessment . . . : " color memvar->colorarray[02]
@ 08,02 say "                         "+transform(memvar->noaccts,"99,999,999.99")
@ 08,02 say "Old Accounts . . . . . : " color memvar->colorarray[02]

@ 09,02 say "                         "+transform(memvar->nadjust,"99,999,999.99")
@ 09,02 say "Adjustments  . . . . . : " color memvar->colorarray[02]
@ 10,02 say "                         "+transform(memvar->nadisc,"99,999,999.99") //+" "+memvar->crdisc
@ 10,02 say "Discounts  . . . . . . : " color memvar->colorarray[02]
@ 07,43 say "                        "+transform(memvar->ntdue,"999,999.99")
@ 07,43 say "Total Due . . . . . . : " color memvar->colorarray[02]

@ 08,43 say "                        "+transform(memvar->ntamtpd,"999,999.99")
@ 08,43 say "Total Amount Paid . . : " color memvar->colorarray[02]

@ 09,43 say "                        "+transform(memvar->ntbal,"999,999.99")
@ 09,43 say "Total Balance . . . . : " color memvar->colorarray[02]


@ 23,02 say "Reference ->" color memvar->colorarray[02]
return(nil)

*-----------------------------------------------------------------------------*
//post payment(f9)
static function postpayment()
ayytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(13,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ayytpayp->paytag = _PAYMENT
                **account master file**
                a999accp->(reclock())
                a999accp->accamtpd  += ayytpayp->payamt
                a999accp->accbaltot -= ayytpayp->payamt
                a999accp->(dbcommit())
                a999accp->(dbunlock())
                **payment file**
                ayytpayp->(reclock())
                ayytpayp->paytag := _POSTED
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())
        endif
        ayytpayp->(dbskip())
enddo
*fask(13,"  Posting successful.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
return(0)

*-----------------------------------------------------------------------------*
static function dispsubject()
local getlist := {},bindex := memvarblock("NINDEXS"),;
      bitems    := memvarblock("AITEMSS"),osubj,;
      alastscr  := savescr(01,00,24,79),;
      lconfirm  := set(_SET_CONFIRM),;
      nlastcursor := setcursor(0),;
      clastcolor  := setcolor(memvar->colorarray[10])
osubj := createabrowse(bitems,bindex,07,23,20,57,;
                {|xnmode,xoabrowser,xaxparam|fdispsubj(xnmode,xoabrowser,xaxparam)},;
                {{{||" "+memvar->aitemss[memvar->nindexs,_CODE_2]+" "},nil},;
                 {{||" "+memvar->aitemss[memvar->nindexs,_SUBJECT]+" "},nil},;
                 {{||" "+memvar->aitemss[memvar->nindexs,_TYPE]+" "},nil},;
                 {{||" "+transform(memvar->aitemss[memvar->nindexs,_UNIT],'@Z 99.9')+" "},nil}},;
                {" Code  ", "   Subject    ", "Type ", " Unit "},;
                {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄ"},;
                {"³","³","³","³"},;
                {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄ"})
*                 x12345x    x123456789012x    x123x    x12.1x
memvar->aitemss := {_EMPTY_1}
memvar->nindexs := 1
procsubj()
boxshadow(05,21,22,59,"ÛßÛÛÛÜÛÛ ",,"  Subject Info  ")
dispbox(06,22,20,58,_SINGLE_LINE);connectline(08,22,58)
@ 21,38 say "Total Units => "+transform(memvar->ntotunit,"@Z 99.9")
commandline("³                               ESC - Previous                                 ³")
stabilize(osubj,.t.)
browsearray(osubj,{""},{|b|b:gotop()})
setcolor(memvar->colorarray[11])
restscr(alastscr)
return(nil)

*-----------------------------------------------------------------------------*
static function fdispsubj(nmode,oabrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2

*-----------------------------------------------------------------------------*
static function procsubj()
local nlastelem,nctr,skdno
if cyytenrp->(dbseek(right(memvar->cacctno,8)))
        memvar->ntotunit := cyytenrp->enrunt
        for nctr := 1 to 16
                skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                if ! cyytenrp->&skdno == "00000"
                        cyytskdp->(dbseek(cyytenrp->&skdno))
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                aadd(memvar->aitemss,_EMPTY_1)
                                nlastelem := len(memvar->aitemss)
                                memvar->aitemss[nlastelem,_CODE_2]    := cyytenrp->&skdno
                                memvar->aitemss[nlastelem,_SUBJECT] := cyytskdp->skdsubcod
                                memvar->aitemss[nlastelem,_TYPE]    := cyytskdp->skdsubtyp
                                memvar->aitemss[nlastelem,_UNIT]    := cyytskdp->skdunt
                        endif
                else
                        exit
                endif
        next
endif
if len(memvar->aitemss) > 1
        for nctr := 1 to len(memvar->aitemss)
                if empty(memvar->aitemss[nctr,_CODE_2])
                        adel(memvar->aitemss,nctr)
                        asize(memvar->aitemss,len(memvar->aitemss)-1)
                endif
        next
endif
return(nil)