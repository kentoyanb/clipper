* Program       : CURRP.PRG
* Author        : Randy F. Santizo and Jun Benlot (c) September 1998
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

#define _ICODE          1
#define _SUBJ           2
#define _TYPE           3
#define _GCODE          4
#define _UNITS          5
#define _LECHRS         6
#define _LABHRS         7
#define _MCODE          8
#define _CRCODE         9
#define _CREDIT         10
#define _DESC1          11
#define _DESC2          12
#define _FLAG           13
#define _EMPTY          {space(06),space(12),space(01),space(02),0,0,0,space(01),;
                         0,space(03),space(36),space(36),space(01)}
function currp()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ocurrp,bindex,bitems,aentryscr
private aitems:={},nindex,crevcode,csemcode,ccolcode,lpassedit := .f.

if(aprvsetup := openwcheck({{,,"c999curp",,_DBF_SHARED,,3},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Curriculum/Course Entry  ")
commandline("³         F4 - View College            ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
crevcode  := space(01)
csemcode  := space(02)
ccolcode  := space(02)
bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ocurrp  := createabrowse(bitems,bindex,06,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fcurrp(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_ICODE]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SUBJ ]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_TYPE ]+" "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_GCODE]+"  "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_UNITS ],"@Z 999.9")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_LECHRS],"@Z 99.99")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_LABHRS],"@Z 99.99")+" "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_MCODE]+"  "},nil},;
                         {{||"  "+transform(memvar->aitems[memvar->nindex,_CRCODE],"@Z 99")+"  "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_CREDIT]},nil}},;
                        {"INT-Code", "    Subject   ", "Typ", "Grpcod", " Units ", "Lec.Hrs", "Lab.Hrs", "MjCod", "CrCode", " CR "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ"})
                       *  x123456x    x123456789012x    x1x    xx12xx    x123.1x    x12.12x    x12.12x    xx1xx    xx12xx    x123
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Revision Code  :";
                color memvar->colorarray[02];
                get memvar->crevcode    pict "@!";
                valid ! empty(memvar->crevcode)
        @ 03,22 say "[11,12,14,21,22,24,31,32,34,41,42,44]";
                color memvar->colorarray[02]
        @ 03,02 say "Semestral Code :";
                color memvar->colorarray[02];
                get memvar->csemcode    pict "@!";
                valid memvar->csemcode $ "111214212224313234414244  "
        @ 04,02 say "College Code   :";
                color memvar->colorarray[02];
                get memvar->ccolcode    pict "@!";
                valid ! empty(memvar->ccolcode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999colp->(dbseek(memvar->ccolcode))
                fask(10,"   College code "+memvar->ccolcode+" not exist.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->aitems := {_EMPTY}
        memvar->nindex := 1
        processtrans()
        @ 22,02 say "Description ->" color memvar->colorarray[02]
        @ 23,02 say "            ->" color memvar->colorarray[02]
        dispbox(05,01,21,78,_SINGLE_LINE)
        connectline(07,01,78)
        stabilize(ocurrp,.t.)
        commandline("³   Ù - Add/Edit   ³     F10 - Save    ³   Del - Delete   ³   ESC - Previous  ³")
        browsearray(ocurrp,{""},{|b|b:gotop()})
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)


static function fcurrp(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                if memvar->lpassedit
                        if(nexit := fask(13,"  Document has been modified.  Save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])) == 1
                                savedata(axparam[02])
                        elseif nexit == 0
                                clearbuffer()
                                return 2
                        endif
                endif
                return 0
        case nmode == 0
                @ 22,17 say memvar->aitems[memvar->nindex,_DESC1]
                @ 23,17 say memvar->aitems[memvar->nindex,_DESC2]
                return 1
        case lastkey() == K_ENTER
                editcurrp(oabrowser)
        case lastkey() == K_DEL .and. ! empty(memvar->aitems[memvar->nindex,_ICODE])
                if fask(13,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        adel(memvar->aitems,memvar->nindex)
                        asize(memvar->aitems,len(memvar->aitems) - 1)
                        oabrowser:refreshall()
                        stabilize(oabrowser)
                        __keyboard(chr(K_F10))
                else
                        clearbuffer()
                endif
        case lastkey() == K_F10
                if len(memvar->aitems) <= 1
                        fask(13,"  Can't save.  No items entered.  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(record())
                endif
                clearbuffer()
endcase
return 2


static function editcurrp(oabrowser)
local getlist := {}, nrec, acmdline := savescr(24,00,24,79),acmddetail,;
      nlastcursor := setcursor(), lconfirm := set(_SET_CONFIRM),;
      nlastrec := len(memvar->aitems),nrow := row(), cprocsts
private cmcode,csubject,ctype,ccredit,cicode,cgcode,nunits,ncrcode,;
        nlechrs,nlabhrs,cdesc1,cdesc2
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
commandline("³                               ESC - Previous                                 ³")
acmddetail              := savescr(24,00,24,79)
memvar->cmcode          := memvar->aitems[memvar->nindex,_MCODE]
memvar->csubject        := memvar->aitems[memvar->nindex,_SUBJ ]
memvar->ctype           := memvar->aitems[memvar->nindex,_TYPE ]
memvar->ccredit         := memvar->aitems[memvar->nindex,_CREDIT]
memvar->cicode          := memvar->aitems[memvar->nindex,_ICODE]
memvar->cgcode          := memvar->aitems[memvar->nindex,_GCODE]
memvar->nunits          := memvar->aitems[memvar->nindex,_UNITS]
memvar->ncrcode         := memvar->aitems[memvar->nindex,_CRCODE]
memvar->nlechrs         := memvar->aitems[memvar->nindex,_LECHRS]
memvar->nlabhrs         := memvar->aitems[memvar->nindex,_LABHRS]
memvar->cdesc1          := memvar->aitems[memvar->nindex,_DESC1 ]
memvar->cdesc2          := memvar->aitems[memvar->nindex,_DESC2 ]
do while .t.
        restscr(acmddetail)
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,03 get memvar->cicode    pict "@!";
                valid ! empty(memvar->cicode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
        if c999crsp->(dbseek(memvar->cicode)) .and. ! memvar->aitems[memvar->nindex,_FLAG] == "E"
                fask(13,"   Internal code "+alltrim(memvar->cicode)+" already exist.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_ICODE] == memvar->cicode})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"   Internal code "+alltrim(memvar->cicode)+" was already entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,12 get memvar->csubject  pict "@!"
        @ nrow,27 get memvar->ctype     pict "@!"
        @ nrow,32 get memvar->cgcode    pict "@!"
        @ nrow,38 get memvar->nunits    pict "999.9"
/*
        if memvar->ctype == "R"
                memvar->nlechrs := memvar->nunits
                @ nrow,46 say memvar->nlechrs   pict "99.99"
        elseif memvar->ctype == "L"
                memvar->nlabhrs := 3*memvar->nunits
                @ nrow,54 get memvar->nlabhrs   pict "99.99"
        endif
*/
        @ nrow,46 get memvar->nlechrs   pict "99.99"
        @ nrow,54 get memvar->nlabhrs   pict "99.99"
        @ nrow,63 get memvar->cmcode    pict "@!"
        @ nrow,69 get memvar->ncrcode   pict "99"
        @ nrow,75 get memvar->ccredit   pict "@!"
        @   22,17 get memvar->cdesc1    pict "@!"
        @   23,17 get memvar->cdesc2    pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ENTER
                memvar->aitems[memvar->nindex,_ICODE ]  := memvar->cicode
                memvar->aitems[memvar->nindex,_SUBJ  ]  := memvar->csubject
                memvar->aitems[memvar->nindex,_TYPE  ]  := memvar->ctype
                memvar->aitems[memvar->nindex,_GCODE ]  := memvar->cgcode
                memvar->aitems[memvar->nindex,_UNITS ]  := memvar->nunits
                memvar->aitems[memvar->nindex,_LECHRS]  := memvar->nlechrs
                memvar->aitems[memvar->nindex,_LABHRS]  := memvar->nlabhrs
                memvar->aitems[memvar->nindex,_MCODE ]  := memvar->cmcode
                memvar->aitems[memvar->nindex,_CRCODE]  := memvar->ncrcode
                memvar->aitems[memvar->nindex,_CREDIT]  := memvar->ccredit
                memvar->aitems[memvar->nindex,_DESC1 ]  := memvar->cdesc1
                memvar->aitems[memvar->nindex,_DESC2 ]  := memvar->cdesc2
                if nlastrec == memvar->nindex
                        aadd(memvar->aitems,_EMPTY)
                        oabrowser:gobottom()
                endif
                memvar->lpassedit := .t.
                exit
        endif
enddo
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
restscr(acmdline)
return(nil)


static function processtrans()
local nlastelem
c999curp->(dbsetrelation("c999crsp",{||c999curp->curintcod},"c999curp->curintcod"))
c999curp->(sx_setscope(_TOP_SCOPE   ,memvar->crevcode+memvar->csemcode+memvar->ccolcode))
c999curp->(sx_setscope(_BOTTOM_SCOPE,memvar->crevcode+memvar->csemcode+memvar->ccolcode))
c999curp->(dbgotop())
do while ! c999curp->(eof())
        fask(13,"  Processing subject "+alltrim(c999curp->cursubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_ICODE]   := c999curp->curintcod
        memvar->aitems[nlastelem,_SUBJ ]   := c999curp->cursubcod
        memvar->aitems[nlastelem,_TYPE ]   := c999curp->cursubtyp
        memvar->aitems[nlastelem,_GCODE]   := c999crsp->crsgrpcod
        memvar->aitems[nlastelem,_UNITS]   := c999crsp->crscreunt
        memvar->aitems[nlastelem,_LECHRS]  := c999crsp->crslechrs
        memvar->aitems[nlastelem,_LABHRS]  := c999crsp->crslabhrs
        memvar->aitems[nlastelem,_MCODE]   := c999curp->curmajcod
        memvar->aitems[nlastelem,_CRCODE]  := c999crsp->crscrecod
        memvar->aitems[nlastelem,_CREDIT]  := c999curp->curcredit
        memvar->aitems[nlastelem,_DESC1 ]  := c999crsp->crsdsc1
        memvar->aitems[nlastelem,_DESC2 ]  := c999crsp->crsdsc2
        memvar->aitems[nlastelem,_FLAG  ]  := "E"
        aadd(memvar->aitems,_EMPTY)
        c999curp->(dbskip())
enddo
c999curp->(clearscope())
c999curp->(dbclearrelation())
return(nil)


static function record()
local alastscr := savescr(01,00,24,79),nctr,nmax
*----------------------*
*  Clearing record     *
*----------------------*
c999curp->(sx_setscope(_TOP_SCOPE   ,memvar->crevcode+memvar->csemcode+memvar->ccolcode))
c999curp->(sx_setscope(_BOTTOM_SCOPE,memvar->crevcode+memvar->csemcode+memvar->ccolcode))
c999curp->(dbgotop())
do while ! c999curp->(eof())
        fask(13,"   Clearing subject "+alltrim(c999curp->cursubcod)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if c999crsp->(dbseek(c999curp->curintcod))
                c999crsp->(reclock())
                c999crsp->crsintcod := _DELETE_TAG
                c999crsp->(dbdelete())
                c999crsp->(dbcommit())
                c999crsp->(dbunlock())
        endif
        c999curp->(reclock())
        c999curp->currevcod := _DELETE_TAG
        c999curp->(dbdelete())
        c999curp->(dbcommit())
        c999curp->(dbunlock())
        c999curp->(dbgotop())
enddo
c999curp->(clearscope())

*-----------------------*
*  Record new data      *
*------------------------
nmax    := len(memvar->aitems)
nctr    := 1
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"   Saving subject "+alltrim(memvar->aitems[nctr,_SUBJ])+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999curp->(recycle())
        c999curp->currevcod     := memvar->crevcode
        c999curp->curcolcod     := memvar->ccolcode
        c999curp->curmajcod     := memvar->aitems[nctr,_MCODE]
        c999curp->cursubcod     := memvar->aitems[nctr,_SUBJ]
        c999curp->cursubtyp     := memvar->aitems[nctr,_TYPE]
        c999curp->curintcod     := memvar->aitems[nctr,_ICODE]
*        c999curp->curyytseq     := memvar->aitems[nctr,_YYTSEQ]
        c999curp->cursemseq     := memvar->csemcode
        c999curp->rectrail      := dtoc(date())+";"+time()+";"+memvar->cusername
        c999curp->(dbcommit())
        c999curp->(dbunlock())

        ** write crsp file **
        c999crsp->(recycle())
        c999crsp->crsintcod     := memvar->aitems[nctr,_ICODE]
        c999crsp->crssubcod     := memvar->aitems[nctr,_SUBJ]
        c999crsp->crssubtyp     := memvar->aitems[nctr,_TYPE]
        c999crsp->crsdsc1       := memvar->aitems[nctr,_DESC1]
        c999crsp->crsdsc2       := memvar->aitems[nctr,_DESC2]
        c999crsp->crsgrpcod     := memvar->aitems[nctr,_GCODE]
        c999crsp->crscreunt     := memvar->aitems[nctr,_UNITS]
        c999crsp->crscrecod     := memvar->aitems[nctr,_CRCODE]
        c999crsp->crslechrs     := memvar->aitems[nctr,_LECHRS]
        c999crsp->crslabhrs     := memvar->aitems[nctr,_LABHRS]
        c999crsp->rectrail      := dtoc(date())+";"+time()+";"+memvar->cusername
        c999crsp->(dbcommit())
        c999crsp->(dbunlock())
        ++nctr
enddo
restscr(alastscr)
return(0)


