* Program       :  PRIVENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) October 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function privmst()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ccode,cname

if(aprvsetup:=openwcheck({{,,"a999prcp",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
boxshadow(07,19,16,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11]," BasicEd Scholarship/Privelege Entry ")
commandline("³     F4 - View Scholarship/Privelege     ³          ESC - Previous            ³")
aentryscr:=savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        ccode := space(len(a999prcp->prccode))
        cname := space(len(a999prcp->prcdescr))
        setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 09,21 say "Code :";
                color memvar->colorarray[02];
                get ccode       pict "@!";
                valid ! empty(ccode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if lexist := a999prcp->(dbseek(ccode))
                a999prcp->(reclock())
                cname := a999prcp->prcdescr
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 11,21 say "Name :";
                color memvar->colorarray[02];
                get cname       pict "@!";
                valid ! empty(cname)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(13,"  Are you sure to save entries ?  ",{" Ok "},memvar->colorarray[05])==1
                loop
        endif
        if ! lexist
                a999prcp->(recycle())
        endif
        a999prcp->prccode       := ccode
        a999prcp->prcdescr      := cname
        a999prcp->(dbcommit())
        a999prcp->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

*------------------------------------------------------------------------------*

#define _CODE           1
#define _DATE           2
#define _FF             3
#define _RATE           4
#define _AMT            5
#define _EMPTY          {space(04),space(10),space(01),0,0}

function privent()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,bindex,bitems,opriv,aentryscr,cprocsts,;
      ayytprsp,cyytenrp,ayytpayp,cyytskdp,ayytassp
private aitems:={},nindex:=1,cacctno,cterm,ccolcode,cyrlevel,nassamt

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
opriv   := createabrowse(bitems,bindex,10,01,21,78,;
                        {|xnmode,xoabrowser,xaxparam|fpriv(xnmode,xoabrowser,xaxparam)},;
                        {{{||"  "+memvar->aitems[memvar->nindex,_CODE ]+"  "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_DATE ]+"  "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_FF   ]+"  "},nil},;
                         {{||"  "+transform(memvar->aitems[memvar->nindex,_RATE],"@Z 999")+"  "},nil},;
                         {{||"  "+transform(memvar->aitems[memvar->nindex,_AMT ],"@Z 999,999.99")+"  "},nil}},;
                        {"Prv-Code", "     Date     ", " F-F ", " %Rate ", "    Amount    "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"})
*                         xx1234xx    xx11/11/1111xx    xx1xx    xx123xx    xx123,123.12xx

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"\crunlib"}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11]," BasicEd Work with Scholarship/Privelege Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!" valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        if ! file("/crunlib/"+"c"+memvar->cterm+"enrp.dbf")
                fask(10,"   C"+memvar->term+"ENRP.DBF not available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/"+"c"+memvar->cterm+"skdp.dbf")
                fask(10,"   C"+memvar->cterm+"SKDP.DBF not available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"   A"+memvar->cterm+"PRSP.DBF not available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"   A"+memvar->cterm+"PAYP.DBF not available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := "c"+memvar->cterm+"enrp"
        cyytskdp        := "c"+memvar->cterm+"skdp"
        ayytprsp        := "a"+memvar->cterm+"prsp"
        ayytpayp        := "a"+memvar->cterm+"payp"
        ayytassp        := "a"+memvar->cterm+"assp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999prcp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                   {,,ayytprsp,"ayytprsp",_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"para",,_DBF_SHARED,,},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"\crunlib"},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"\crunlib"},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"\crunlib"}}))==nil
                return(nil)
        endif
        memvar->cacctno := space(len(a999accp->accidno))
        do while .t.
                memvar->ccolcode := space(len(c999colp->colcod))
                memvar->cyrlevel := space(01)
                memvar->nassamt  := 0
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Account Number. . . . :";
                        color memvar->colorarray[02];
                        get memvar->cacctno pict "@!" valid ! empty(memvar->cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if a999accp->(dbseek(memvar->cacctno)) .and. ! cyytenrp->(dbseek(right(memvar->cacctno,8)))
                        fask(10,"  Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! a999accp->(dbseek(memvar->cacctno)) .and. ! cyytenrp->(dbseek(right(memvar->cacctno,8)))
                        fask(10,"   Student not enrolled this semester.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! a999accp->(dbseek(memvar->cacctno))
                        fask(10,"   Student file not found in master file.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(memvar->cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                                "              No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                a999accp->(dbseek(memvar->cacctno))
                if ! a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AG,GS,ST,HU,OO,IC,AM" 
                        fask(10,"Scholarship/Privelege Entry of College ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(cterm,3,1)) != "1"
                        fask(10,"Scholarship/Privelege Entry of Elem/JH ("+a999accp->acccolcod+") is ALLOWED during;"+;
                        "1ST SEMESTERS ONLY. Please do the entry in 1st Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                ayytassp->(dbseek(memvar->cacctno))
                memvar->aitems := {_EMPTY}
                memvar->nindex := 1
                memvar->ccolcode := a999accp->acccolcod
                memvar->cyrlevel := a999accp->accyrlevl
                prodata()
                c999colp->(dbseek(a999accp->acccolcod))
                @ 09,01 say replicate("Ä",78)

               //@ 05,02 say "                        "+a999accp->acclname
               // @ 05,02 say "Last Name . . . . . . :" color memvar->colorarray[02]
                @ 05,02 say "                        "+alltrim(a999accp->acclname)+ ", "+ alltrim(a999accp->accfname) +" "+a999accp->accmname
                @ 05,02 say "Full Name . . . . . . :" color memvar->colorarray[02]
                //@ 06,02 say "                        "+a999accp->accfname
                //@ 06,02 say "First Name. . . . . . :" color memvar->colorarray[02]
                //@ 07,02 say "                        "+a999accp->accmname
                //@ 07,02 say "Middle Initial. . . . :" color memvar->colorarray[02]
                @ 06,02 say "                        "+alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
                @ 06,02 say "Strand/Grade & Year . . . . :" color memvar->colorarray[02]
                @ 07,02 say "                        "+transform(ayytassp->asstui,"999,999.99")
                @ 07,02 say "Tuition . . . . . . . :" color memvar->colorarray[02]
                @ 08,02 say "                        "+transform(ayytassp->asstotal,"999,999.99")
                @ 08,02 say "Total Assessment  . . :" color memvar->colorarray[02]
                stabilize(opriv,.t.)
                commandline("³ Ù - Add/Edit ³  F3 - Cancel  ³ F10 - Record ³ Del - Delete ³ ESC - Previous ³")
                browsearray(opriv,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fpriv(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
/*
                if memvar->lpassedit
                        if(nexit := fask(13,"  Document has been modified.  Save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])) == 1
                                savedata(axparam[02])
                        elseif nexit == 0
                                clearbuffer()
                                return 2
                        endif
                endif
*/
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_ENTER
                editpriv(oabrowser)
        case lastkey() == K_DEL .and. ! empty(memvar->aitems[memvar->nindex,_CODE])
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
        case lastkey() == K_F3
                if len(memvar->aitems) <= 1
                        fask(13,"  Can't cancel.  No items recorded.  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to cancel record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(cancelrecord())
                endif
                clearbuffer()
endcase
return 2

static function editpriv(oabrowser)
local getlist:={},nrec,acmdline:=savescr(24,00,24,79),acmddetail,;
      nlastcursor:=setcursor(),lconfirm:=set(_SET_CONFIRM),;
      nlastrec:=len(memvar->aitems),nrow:=row(),cprocsts
private ccode := memvar->aitems[memvar->nindex,_CODE],;
        cdate := ctod(memvar->aitems[memvar->nindex,_DATE]),;
        cff   := memvar->aitems[memvar->nindex,_FF],;
        nrate := memvar->aitems[memvar->nindex,_RATE],;
        namt  := memvar->aitems[memvar->nindex,_AMT]
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
commandline("³           F4 - View Privelege        ³          ESC - Previous               ³")
acmddetail := savescr(24,00,24,79)
if empty(memvar->cdate)
        memvar->cdate := date()
endif
do while .t.
        restscr(acmddetail)
        setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,16 get memvar->ccode pict "@!" valid ! empty(memvar->ccode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
        if ! a999prcp->(dbseek(memvar->ccode))
                fask(10,"  Privilege code not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_CODE] == memvar->ccode})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"  Privelege code was already entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,25 get memvar->cdate valid ! empty(memvar->cdate)
        @ nrow,40 get memvar->cff pict "@!" valid checkff(nrow)
        @ nrow,54 get memvar->namt pict "999,999.99"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ENTER
                memvar->aitems[memvar->nindex,_CODE] := memvar->ccode
                memvar->aitems[memvar->nindex,_DATE] := dtoc(memvar->cdate)
                memvar->aitems[memvar->nindex,_FF  ] := memvar->cff
                memvar->aitems[memvar->nindex,_RATE] := memvar->nrate
                memvar->aitems[memvar->nindex,_AMT ] := memvar->namt
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

static function prodata()
local nlastelem
ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        fask(13,"  Retrieving code "+ayytprsp->prscode+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_CODE] := substr(ayytprsp->prscode,1,4)
        memvar->aitems[nlastelem,_DATE] := dtoc(ayytprsp->prsdte)
        memvar->aitems[nlastelem,_FF  ] := ayytprsp->prstag
        memvar->aitems[nlastelem,_RATE] := ayytprsp->prstuipdsc * 100
        memvar->aitems[nlastelem,_AMT ] := ayytprsp->prstuiadsc
        aadd(memvar->aitems,_EMPTY)
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())
return(nil)

static function checkff(nrow)
local nctr,skdno,nunit:=0
if ! memvar->cff $ "YN"
        return(.f.)
endif
if memvar->cff == "N"
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,46 get memvar->nrate pict "999" valid memvar->nrate > 0
       read
else
        memvar->nrate := 0
endif
cyytenrp->(dbseek(right(memvar->cacctno,8)))
for nctr := 1 to 16
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                cyytskdp->(dbseek(cyytenrp->&skdno))
                if ! alltrim(str(cyytskdp->skdunt,5,1)) == "1.5" .and.;
                   ! substr(cyytskdp->skdsubcod,1,2) == "PE"     .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC")
                        nunit := nunit + cyytskdp->skdunt
                endif
        else
                exit
        endif
next
a999accp->(dbseek(memvar->cacctno))
ayytassp->(dbseek(memvar->cacctno))
memvar->ccolcode := a999accp->acccolcod
memvar->cyrlevel := a999accp->accyrlevl
memvar->nassamt  := nunit * a999accp->accfeeunt
if memvar->cff == "N"
        //memvar->namt := (nunit * a999accp->accfeeunt) * (memvar->nrate / 100)
        memvar->namt := ayytassp->asstui * (memvar->nrate / 100)
else
        //memvar->namt := a999accp->accsytass
        memvar->namt := ayytassp->asstotal
endif
return(.t.)


static function record()
local nmax,nctr,xamt:=0,xcode:=space(04),lprocess:=.f.,xrate:=0
***************
** prsp file **
***************
ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        fask(13,"  Clearing record "+ayytprsp->prscode+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
        ayytprsp->(reclock())
        //ayytprsp->prsidno := _DELETE_TAG
        ayytprsp->prssyt := _DELETE_TAG
        ayytprsp->(dbdelete())
        ayytprsp->(dbcommit())
        ayytprsp->(dbunlock())
        ayytprsp->(dbskip())

enddo
ayytprsp->(clearscope())

nmax := len(memvar->aitems)
nctr := 1
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"  Saving record "+memvar->aitems[nctr,_CODE]+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        ayytprsp->(recycle())
        ayytprsp->prsidno       := memvar->cacctno
        ayytprsp->prscode       := memvar->aitems[nctr,_CODE]
        ayytprsp->prssyt        := memvar->cterm
        ayytprsp->prscolcod     := memvar->ccolcode
        ayytprsp->prsyrlvl      := memvar->cyrlevel
        ayytprsp->prsdte        := ctod(memvar->aitems[nctr,_DATE])
        ayytprsp->prstuipdsc    := memvar->aitems[nctr,_RATE] / 100
        ayytprsp->prstuiadsc    := memvar->aitems[nctr,_AMT]
        ayytprsp->prsassmnt     := memvar->nassamt
        ayytprsp->prsdisctd     := memvar->nassamt - memvar->aitems[nctr,_AMT]
        ayytprsp->prstag        := memvar->aitems[nctr,_FF]
        ayytprsp->prsentusr     := substr(memvar->cusername,1,8)
        ayytprsp->prsentdte     := date()
        ayytprsp->prsenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),6,2)
        ayytprsp->(dbcommit())
        ayytprsp->(dbunlock())
        ++nctr
enddo
***************
** payp file **
***************
ayytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(13,"  Clearing record "+ayytpayp->paymach+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
        if ayytpayp->paytag == _DISCOUNT
                ayytpayp->(reclock())
                //ayytpayp->payidno := _DELETE_TAG
                ayytpayp->payrefno := _DELETE_TAG
                ayytpayp->(dbdelete())
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())
        endif
        ayytpayp->(dbskip())
enddo
ayytpayp->(clearscope())

nmax := len(memvar->aitems)
nctr := 1
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"  Saving record "+memvar->aitems[nctr,_CODE]+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! substr(memvar->aitems[nctr,_CODE],1,1) == "X"
                ayytpayp->(recycle())
                para->(dbgotop())
                ayytpayp->payrefno      := alltrim(str(para->seriesno))
                ayytpayp->payidno       := memvar->cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := ctod(memvar->aitems[nctr,_DATE])
                ayytpayp->paycolcod     := memvar->ccolcode
                ayytpayp->payyrlevl     := memvar->cyrlevel
                ayytpayp->paysyt        := memvar->cterm
                ayytpayp->paymach       := memvar->aitems[nctr,_CODE]
                ayytpayp->payamt        := memvar->aitems[nctr,_AMT]
                ayytpayp->payentdte     := date()
                ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),6,2)
                ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                ayytpayp->paytag        := _DISCOUNT
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                para->(reclock())
                para->seriesno := para->seriesno + 1
                para->(dbcommit())
                para->(dbunlock())
                lprocess := .t.
                xrate := memvar->aitems[nctr,_RATE] / 100
                xamt  += memvar->aitems[nctr,_AMT]
                xcode := memvar->aitems[nctr,_CODE]
        endif
        ++nctr
enddo
if lprocess
        a999accp->(dbseek(memvar->cacctno))
        a999accp->(reclock())
        a999accp->acccode    := xcode
        a999accp->accsytpdsc := xrate
        a999accp->accsytadsc := xamt
        a999accp->accsyttot  := a999accp->accsytass - xamt
        a999accp->accduetot  := a999accp->accsytass + a999accp->accbalold + a999accp->accadj - xamt
        a999accp->accbaltot  := a999accp->accduetot - a999accp->accamtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())
endif
return(0)




static function cancelrecord()
** prsp file **
ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        fask(13,"  Clearing record "+ayytprsp->prscode+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
        ayytprsp->(reclock())
        //ayytprsp->prsidno := _DELETE_TAG
        ayytprsp->prssyt := _DELETE_TAG
        ayytprsp->(dbdelete())
        ayytprsp->(dbcommit())
        ayytprsp->(dbunlock())
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())
** payp file **
ayytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(13,"  Clearing record "+ayytpayp->paymach+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
        if ayytpayp->paytag == _DISCOUNT
                ayytpayp->(reclock())
                //ayytpayp->payidno := _DELETE_TAG
                ayytpayp->payrefno := _DELETE_TAG
                ayytpayp->(dbdelete())
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())
        endif
        ayytpayp->(dbskip())
enddo
ayytpayp->(clearscope())
** accp master file **
a999accp->(dbseek(memvar->cacctno))
a999accp->(reclock())
a999accp->acccode    := space(04)
a999accp->accsytpdsc := 0
a999accp->accsytadsc := 0
a999accp->accsyttot  := a999accp->accsytass
a999accp->accduetot  := a999accp->accsytass + a999accp->accbalold + a999accp->accadj
a999accp->accbaltot  := a999accp->accduetot - a999accp->accamtpd
a999accp->(dbcommit())
a999accp->(dbunlock())
return(0)

*------------------------------------------------------------------------------*

