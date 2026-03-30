* Program       :  LOAD.PRG
* Author        :
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function payslip()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,opayrec,bindex,bitems,aentryscr,;
      cyytskdp, aprv1setup, nctr := 0, cskdcode, nlastelem
private aitems := {},nindex := 1, ntotunits := 0, lpassedit := .f.,;
        cterm := space(03), cidno := space(06), payday := ctod("  /  /  "),;
        rpunit := 0, sanum := space(12),  g_earn := 0,;
        tot_deduc := 0, net_earn := 0, rate := 0, nload := 0,;
        ascr := savescr(01,00,24,79)

#define _IDNO           1
#define _PAYDAY         2
#define _CHNAME         3
#define _EARNINGS       4
#define _DEDUCTIONS     5
#define _EMPTY_ELEMENT  {space(06),;
                         space(01),;
                         space(15),;
                         0,0}

if ! (memvar->clevel $ "PA")
      fask(13,"    You have no rights to access this code.    ",{" Ok "},memvar->colorarray[05],.t.,nil)
      restscr(alastscr)
      return
endif

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
opayrec := createabrowse(bitems,bindex,10,16,22,62,;
                        {|xnmode,xoabrowser,xaxparam|fpayslip(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_CHNAME]+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_EARNINGS],  "@Z #,###,###.##")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_DEDUCTIONS],"@Z #,###,###.##")+" "},nil}},;
                        {"   Description   ", "   Earnings   ",  "  Deductions  "},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", "ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"})
*                         x123456789012345x     x123456789.12x     x123456789.12x


if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        cterm := space(len(term->code))
        rpunit := 0
        sanum := space(12)
        g_earn := 0
        tot_deduc := 0
        net_earn := 0
        rate := 0
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"    ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    : ";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,24 say "- "+term->name
        if ! file(alltrim("t999lst.dbf"))
                fask(10,"  T999LST.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp     := alltrim("c"+cterm+"skdp")
        if(aprvsetup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                    {,,"t999lst" ,,_DBF_SHARED,,1},;
                                    {,,"chart"   ,,_DBF_SHARED,,1},;
                                    {,,"accnt_no",,_DBF_SHARED,,1},;
                                    {,,"c021pslp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        ascr := savescr(01,00,24,79)
        do while .t.
        restscr(ascr)
                memvar->aitems := {_EMPTY_ELEMENT}
                memvar->nindex := 1
                memvar->ntotunits := 0
                commandline("³            F4 - Instructor            ³            ESC - Previous            ³")
                setkey(K_F4,{||if(readvar()=="MEMVAR->CIDNO",vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Pay Day        : ";
                        color memvar->colorarray[02];
                        get memvar->payday;
                        valid ! empty(memvar->payday)
                @ 04,02 say "Instructor ID# : ";
                        color memvar->colorarray[02];
                        get memvar->cidno      pict "@!";
                        valid ! empty(memvar->cidno)
                read
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(memvar->cidno))
                        fask(13,"  ID No.: "+memvar->cidno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        exit
                endif
                @ 05,02 say "Name of Instr  : " color memvar->colorarray[02]
                @ 05,20 say alltrim(t999lst->tlname)+", "+;
                            alltrim(t999lst->tfname)+" "+;
                            alltrim(t999lst->tmname);
                            color memvar->colorarray[01]
                if accnt_no->(dbseek(memvar->cidno))
                        memvar->sanum := accnt_no->account_no
                else
                        sanum := space(12)
                endif
                if accnt_no->(dbseek(memvar->cidno+memvar->cterm))
                        memvar->nload := accnt_no->load
                else
                        memvar->nload :=0
                endif
                if accnt_no->(dbseek(memvar->cidno+memvar->cterm))
                        memvar->rpunit := accnt_no->rate
                else
                        memvar->rpunit := 0
                endif
                @ 06,02 say "Savings Acct No: ";
                        color memvar->colorarray[02];
                        get memvar->sanum    pict "###-######-#"
                @ 07,02 say "No. of Load(s) : ";
                        color memvar->colorarray[02];
                        get memvar->nload      pict "###.###"
                @ 08,02 say "Rate Per Unit  : ";
                        color memvar->colorarray[02];
                        get memvar->rpunit      pict "P #,###.##"
                read
                if lastkey() == K_ESC
                        exit
                endif
                g_earn := 0
                tot_deduc := 0
                net_earn := 0
                if ! c021pslp->(dbseek(memvar->cidno+dtos(memvar->payday)))
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_CHNAME]     := "BASIC (ACAD)"
                        memvar->aitems[nlastelem,_EARNINGS]   := (memvar->nload * memvar->rpunit)/2
                        memvar->aitems[nlastelem,_DEDUCTIONS] := 0
                        g_earn     += memvar->aitems[nlastelem,_EARNINGS]
                        net_earn   += memvar->aitems[nlastelem,_EARNINGS]
                        aadd(memvar->aitems,_EMPTY_ELEMENT)
                endif
                c021pslp->(dbgotop())
                do while ! c021pslp->(eof())
                   if (c021pslp->idno == memvar->cidno) .and. (c021pslp->payday == memvar->payday)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_CHNAME]     := c021pslp->chname
                        memvar->aitems[nlastelem,_EARNINGS]   := c021pslp->earnings
                        memvar->aitems[nlastelem,_DEDUCTIONS] := c021pslp->deductions
                        if c021pslp->earnings != 0
                           g_earn     += c021pslp->earnings
                           net_earn   += c021pslp->earnings
                        elseif c021pslp->deductions != 0
                           tot_deduc  += c021pslp->deductions
                           net_earn   -= c021pslp->deductions
                        endif
                        aadd(memvar->aitems,_EMPTY_ELEMENT)
                   endif
                   c021pslp->(dbskip())
                enddo

                @ 04,48 say "Gross Earning  : ";
                        color memvar->colorarray[02]
                @ 05,48 say "Total Deduction: ";
                        color memvar->colorarray[02]
                @ 06,48 say "Net Earnings   : ";
                        color memvar->colorarray[02]

                @ 04,65 say g_earn    color memvar->colorarray[01] pict "P ###,###.##"
                @ 05,65 say tot_deduc color memvar->colorarray[01] pict "P ###,###.##"
                @ 06,65 say net_earn  color memvar->colorarray[01] pict "P ###,###.##"

                dispbox(09,15,22,63,_SINGLE_LINE)
                connectline(11,15,63)
                commandline("³    F4 - View Pay Code    ³     F10 - Save      ³      ESC - Previous         ³")

                opayrec:gotop()
                stabilize(opayrec,.t.)
                browsearray(opayrec,{""},{|b|b:gotop()})
                dbunlockall();dbcommitall()

                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
        enddo
enddo
        closewcheck(aprvsetup)
        closewcheck(aprv1setup)
restscr(alastscr)
return

static function fpayslip(nmode,obrowser,axparam)
local nexit, earnings := space(12)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_ENTER
                editpaycode(obrowser)
        case lastkey() == K_DEL .and. ! (len(memvar->aitems) == 1)  /*.and. ! empty(memvar->aitems[memvar->nindex,_SKDNO])*/
                if memvar->aitems[memvar->nindex,_EARNINGS] != 0
                   g_earn     -= memvar->aitems[memvar->nindex,_EARNINGS]
                   net_earn   -= memvar->aitems[memvar->nindex,_EARNINGS]
                elseif memvar->aitems[memvar->nindex,_DEDUCTIONS] != 0
                   tot_deduc  -= memvar->aitems[memvar->nindex,_DEDUCTIONS]
                   net_earn   += memvar->aitems[memvar->nindex,_DEDUCTIONS]
                endif
                @ 04,62 say g_earn    color memvar->colorarray[01] pict "P ###,###.##"
                @ 05,62 say tot_deduc color memvar->colorarray[01] pict "P ###,###.##"
                @ 06,62 say net_earn  color memvar->colorarray[01] pict "P ###,###.##"
                adel(memvar->aitems,memvar->nindex)
                asize(memvar->aitems,len(memvar->aitems) - 1)
                obrowser:refreshall()
                stabilize(obrowser)
                __keyboard(chr(K_F10))
        case lastkey() == K_F6
                memvar->chname := "BASIC (ACAD)"
                memvar->earn := (memvar->nload * memvar->rpunit)/2
                earnings := transform(memvar->earn,"999999.99")
/*                fask(13,"  "+transform(memvar->earn,"P ###,###.##")+"   ",{" Ok "},memvar->colorarray[05],.t.,nil) */
                __keyboard(chr(K_ENTER)+memvar->chname+chr(K_ENTER)+earnings+chr(K_ENTER)+chr(K_ENTER))
        case lastkey() == K_F8
                        printpayslip()

        case lastkey() == K_F10
                if len(memvar->aitems) <= 1
                        fask(13,"  Can't save.  No items entered.  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(recordprec())
                endif
                clearbuffer()
endcase
return 2

static function editpaycode(oabrowser)
local getlist := {}, nrec, acmdline := savescr(24,00,24,79),acmddetail,;
      nlastcursor := setcursor(), lconfirm := set(_SET_CONFIRM),;
      nlastrec := len(memvar->aitems),nrow := row(), cprocsts,;
      nmax := 0, nctr := 0, llab := .f., lscode := .f.
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
/*commandline("³    F4 - View Pay Code    ³     F10 - Save      ³      ESC - Previous         ³")
*/
acmddetail               := savescr(24,00,24,79)

** initialize **

memvar->chname           := memvar->aitems[memvar->nindex,_CHNAME]
memvar->earn             := memvar->aitems[memvar->nindex,_EARNINGS]
memvar->deduc            := memvar->aitems[memvar->nindex,_DEDUCTIONS]
fask(13,memvar->chname,{" Ok "},memvar->colorarray[05],.t.,nil)
do while .t.
        restscr(acmddetail)
        setcursor(1);set(_SET_CONFIRM,.t.)
        setkey(K_F4,{||vpaycode(memvar->chname,cprocsts,memvar->colorarray[10])})
        @ nrow,17 get memvar->chname    pict "@!";
                  valid ! empty(memvar->chname)
        @ nrow,37 get memvar->earn      pict "@Z ###,###.##"
        @ nrow,52 get memvar->deduc     pict "@Z ###,###.##"
        read
        if lastkey() == K_ENTER
                nlastelem := len(memvar->aitems)
                        memvar->aitems[nindex,_IDNO] := memvar->cidno
                        memvar->aitems[nindex,_PAYDAY] := memvar->payday
                        memvar->aitems[nindex,_CHNAME] := memvar->chname
                        memvar->aitems[nindex,_EARNINGS] := memvar->earn
                        memvar->aitems[nindex,_DEDUCTIONS] := memvar->deduc
                if nlastelem == nindex
                        if memvar->earn != 0
                            g_earn     += memvar->earn
                            net_earn   += memvar->earn
                         elseif memvar->deduc != 0
                            tot_deduc  += memvar->deduc
                            net_earn   -= memvar->deduc
                         endif
                        @ 04,62 say g_earn    color memvar->colorarray[01] pict "P ###,###.##"
                        @ 05,62 say tot_deduc color memvar->colorarray[01] pict "P ###,###.##"
                        @ 06,62 say net_earn  color memvar->colorarray[01] pict "P ###,###.##"
                        aadd(memvar->aitems,_EMPTY_ELEMENT)
                endif
                oabrowser:gobottom()
                clearbuffer()
                exit
        endif
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
enddo
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
restscr(acmdline)
return(nil)

static function recordprec()
local nlastelem
c021pslp->(sx_setscope(_TOP_SCOPE   ,memvar->cidno+dtos(memvar->payday)))
c021pslp->(sx_setscope(_BOTTOM_SCOPE,memvar->cidno+dtos(memvar->payday)))
c021pslp->(dbgotop())
do while ! c021pslp->(eof())
   if c021pslp->payday == memvar->payday
        fask(13,"   Clearing Instructor "+c021pslp->idno+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c021pslp->(reclock())
        c021pslp->idno := _DELETE_TAG
        c021pslp->(dbdelete())
        c021pslp->(dbcommit())
        c021pslp->(dbunlock())
        c021pslp->(dbgotop())
   endif
enddo
c021pslp->(clearscope())

nmax := len(memvar->aitems)
i := 0
do while i<2
nctr := 1
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"   Saving code "+memvar->aitems[nctr,_CHNAME]+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (i==0 .and. memvar->aitems[nctr,_EARNINGS] != 0) .or. ;
           (i==1 .and. memvar->aitems[nctr,_DEDUCTIONS] != 0)
                c021pslp->(recycle())
                c021pslp->idno       := memvar->cidno
                c021pslp->payday     := memvar->payday
                c021pslp->chname     := memvar->aitems[nctr,_CHNAME]
                c021pslp->earnings   := memvar->aitems[nctr,_EARNINGS]
                c021pslp->deductions := memvar->aitems[nctr,_DEDUCTIONS]
                c021pslp->(dbcommit())
                c021pslp->(dbunlock())
        endif
        ++nctr
enddo
++i
enddo
if accnt_no->(dbseek(memvar->cidno+memvar->cterm))
        accnt_no->(reclock())
else
        accnt_no->(recycle())
        accnt_no->idno := memvar->cidno
        accnt_no->term := memvar->cterm
endif

accnt_no->account_no := memvar->sanum
accnt_no->load       := memvar->nload
accnt_no->rate       := memvar->rpunit
accnt_no->(dbcommit())
accnt_no->(dbunlock())

*************

return(0)


*-------------------------------------------------------------------------------
function printpayslip()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup
private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,cterm,;
        payday := ctod("  /  /  "), cidno := space(06)

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Study Load Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->ctdesc := term->name
        cyytskdp     := alltrim("c"+cterm+"skdp")
        if(aprvsetup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                    {,,"t999lst" ,,_DBF_SHARED,,2},;
                                    {,,"chart"   ,,_DBF_SHARED,,1},;
                                    {,,"accnt_no",,_DBF_SHARED,,1},;
                                    {,,"c021pslp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        setcursor(1);set(_SET_CONFIRM,.t.)
        setkey(K_F4,{||if(readvar()=="CIDNO",vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
        @ 03,02 say "Pay Day        : ";
                color memvar->colorarray[02];
                get payday  ;
                valid ! empty(payday)
        @ 04,02 say "Instructor ID# : ";
                color memvar->colorarray[02];
                get cidno      pict "@!";
                valid ! empty(cidno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif

        if whereprint({||ppayslip(cterm,payday,cidno)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function ppayslip(cterm,payday,cidno)
local getlist := {}, entryscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytflag, aprv1setup, i:=j:=0

private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,pstring := space(39),;
        cdummy := "pslplst"+strzero(memvar->naccess,2), pslpfil,;
        deductables := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"       ,"C",06,0},;
                                 {"PAYDAY"     ,"C",01,0},;
                                 {"CHNAME"     ,"C",15,0},;
                                 {"EARNINGS"   ,"N",09,2},;
                                 {"DEDUCTIONS" ,"N",09,2}},{||cdxpslip()})
        dbcloseall()
        return(nil)
endif
memvar->pslpfil := memvar->cdummy
if(afile := openwcheck({{,,(memvar->pslpfil+".TXT"),"pslpfil",_DBF_EXCLUSIVE,,2}})) == nil
        dbcloseall()
        return(nil)
endif
        aentryscr    := savescr(01,00,24,79)
                t999lst->(sx_setscope(_TOP_SCOPE   ,cidno))
                t999lst->(sx_setscope(_BOTTOM_SCOPE,cidno))
        fask(10,"  ID NO: "+cidno+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        t999lst->(dbgotop())
        fask(10,"  ID NO: "+t999lst->tidno+" NAME: "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        if t999lst->(eof())
                fask(10,"  End of file...  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        endif
        do while ! t999lst->(eof())
                fask(10,"  ID NO: "+t999lst->tidno+" NAME: "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)
                if accnt_no->(dbseek(t999lst->tidno))
                        outexpr(00,00,"UNIVERSITY OF CEBU - PAYSLIP        DATE: 07/31/2001  S/A "+accnt_no->account_no)
                        outexpr(prow()+01,00,"ID NO: "+t999lst->tidno+" NAME: "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+;
                        chr(13)+replicate("_",70))
                        g_earn := 0
                        tot_deduc := 0
                        net_earn := 0
                        pslpfil->(__dbzap());pslpfil->(dbreindex())
                        c021pslp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno+dtos(payday)))
                        c021pslp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno+dtos(payday)))
                        c021pslp->(dbgotop())
                        pslpfil->idno := t999lst->tidno
                        pslpfil->payday := payday
                        do while ! c021pslp->(eof())
                                pslpfil->(dbappend())
                                pslpfil->chname     := c021pslp->chname
                                pslpfil->earnings   := c021pslp->earnings
                                pslpfil->deductions := c021pslp->deductions
                                if c021pslp->earnings != 0
                                   g_earn     += c021pslp->earnings
                                   net_earn   += c021pslp->earnings
                                elseif c021pslp->deductions != 0
                                   tot_deduc  += c021pslp->deductions
                                   net_earn   -= c021pslp->deductions
                                endif
                                c021pslp->(dbskip())
                        enddo
                        c021pslp->(clearscope())
                        pslpfil->(dbgotop())
                        i := j := 0
                        deductables := .f.
                        do while j <16
                                pstring := ""
                                if ! pslpfil->(eof())
                                        if (i == 0) .and. (j == 0)
                                                pstring := "EARNINGS:     "+pslpfil->chname
                                        elseif (i == 0) .and. (j != 0)
                                                pstring := "DEDUCTIONS:   "+pslpfil->chname
                                        else
                                                pstring := space(14) + pslpfil->chname
                                        endif
                                        if pslpfil->earnings > 0
                                                pstring := pstring + space(39-len(transform(pslpfil->earnings,"###,###.##"))-;
                                                                           len(pstring))+transform(pslpfil->earnings,"###,###.##")
                                        else
                                                pstring := pstring + space(39-len(transform(pslpfil->deductions,"###,###.##"))-;
                                                                           len(pstring))+transform(pslpfil->deductions,"###,###.##")
                                        endif
                                else
                                        pstring := space(39)
                                endif
                                do case
                                        case j == 1
                                                pstring += space(03) + "GROSS EARNINGS:"
                                                pstring += space(70-len(pstring)-len(transform(g_earn,"###,###.##")))
                                                pstring += transform(g_earn,"###,###.##")
                                        case j == 2
                                                pstring += space(03) + "TOTAL DEDUCTIONS:"
                                                pstring += space(70-len(pstring)-len(transform(tot_deduc,"###,###.##")))
                                                pstring += transform(tot_deduc,"###,###.##")
                                        case j == 3
                                                pstring += space(03) + "NET EARNINGS:"
                                                pstring += space(70-len(pstring)-len(transform(net_earn,"###,###.##")))
                                                pstring += transform(net_earn,"###,###.##")
                                        case j == 6
                                                pstring += space(03) + "RECEIVED:"
                                        case j == 11
                                                pstring += space(03) + replicate("_",28)
                                        case j == 12
                                                pstring += space(12) + "SIGNATURE"
                                endcase
                                if ! pslpfil->(eof())
                                        pslpfil->(dbskip())
                                endif
                                ++i
                                if (pslpfil->earnings==0) .and. ! deductables
                                        deductables := .t.
                                        i := 0
                                        pstring += chr(13)+replicate("_",39)
                                endif
                                if pslpfil->(eof()) .and. ! deductables
                                        deductables := .t.
                                        i := 0
                                        pstring += ""+replicate("_",39)
                                endif
                                outexpr(prow()+1,00,pstring)
                                ++j
                        enddo
/*                        @ 22,00 say space(01)   to eject */
                        outexpr(22,00,"")
                        setprc(00,00)
                endif
                t999lst->(dbskip())
        enddo
        t999lst->(clearscope())
return

static function cdxpslip()
field idno
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------
function paysummary()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup, cidno
private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,cterm,payday := space(01)

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Study Load Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term : ";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->ctdesc := term->name
        @ 03,23 say "[1-15th, 2-30th ]" color memvar->colorarray[01]
        @ 03,24 say "1" color memvar->colorarray[02]
        @ 03,32 say "2" color memvar->colorarray[02]
        cidno := space(06)
        @ 03,02 say "Pay Day        : ";
                color memvar->colorarray[02];
                get payday      pict "@!";
                valid ! empty(payday)
        @ 04,02 say "Inst ID No.    : ";
                color memvar->colorarray[02];
                get cidno      pict "@!";
                valid ! empty(cidno)
        read
        if lastkey() == K_ESC
                exit
        endif

        if whereprint({||ppayslip(cidno,cterm,payday)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function ppaysummary(cidno,cterm,payday)
local getlist := {}, entryscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup, i:=j:=0

private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,pstring := space(39),;
        cdummy := "psumlst"+strzero(memvar->naccess,2), psumfil,;
        deductables := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"PAYDAY"     ,"D",08,0},;
                                 {"PAY01"      ,"N",09,2},;
                                 {"PAY02"      ,"N",09,2},;
                                 {"PAY03"      ,"N",09,2},;
                                 {"PAY04"      ,"N",09,2},;
                                 {"PAY05"      ,"N",09,2},;
                                 {"PAY06"      ,"N",09,2},;
                                 {"PAY07"      ,"N",09,2},;
                                 {"PAY08"      ,"N",09,2},;
                                 {"PAY09"      ,"N",09,2},;
                                 {"PAY10"      ,"N",09,2},;
                                 {"PAY01"      ,"N",09,2},;
                                 {"PAY12"      ,"N",09,2},;
                                 {"PAY13"      ,"N",09,2},;
                                 {"PAY14"      ,"N",09,2},;
                                 {"PAY15"      ,"N",09,2},;
                                 {"PAY16"      ,"N",09,2},;
                                 {"PAY17"      ,"N",09,2},;
                                 {"PAY18"      ,"N",09,2},;
                                 {"PAY19"      ,"N",09,2},;
                                 {"PAY20"      ,"N",09,2},;
                                 {"PAY21"      ,"N",09,2},;
                                 {"PAY22"      ,"N",09,2},;
                                 {"PAY23"      ,"N",09,2},;
                                 {"PAY24"      ,"N",09,2},;
                                 {"PAY25"      ,"N",09,2}},{||cdxpsum()})
        dbcloseall()
        return(nil)
endif
memvar->psumfil := memvar->cdummy
if(afile := openwcheck({{,,(memvar->psumfil+".TXT"),"psumfil",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
        aentryscr       := savescr(01,00,24,79)
        cyytskdp     := alltrim("c"+cterm+"skdp")
        if(aprvsetup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                    {,,"t999lst" ,,_DBF_SHARED,,2},;
                                    {,,"chart"   ,,_DBF_SHARED,,1},;
                                    {,,"accnt_no",,_DBF_SHARED,,1},;
                                    {,,"c021pslp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        c021pslp->(dbgotop())
        do while ! c021pslp->(eof())

        enddo
        closewcheck(aprvsetup)
return

static function cdxpsum()
field idno
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

