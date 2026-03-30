* Program       :  ACCTENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) January 1999
* Updated       :  Jun Benlot April 20, 2001
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------

function fwdbalcol()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,ccolcode,ayytpayp,nbal,nadj,ctime:="",xtime,nctr,ncol1,;
      xyytpayp,xyytassp,xyytenrp,adspscr
private xterm,nlast,nrec
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Forward Account Balances by College  ")
        commandline("Г        F4 - View Term/College File       Г         ESC - Previous            Г")
        @ 03,01 say replicate("Ф",78)
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
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        checkterm(cterm)
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"Target A"+cterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+memvar->xterm+"payp.dbf"))
                fask(10,"Source A"+memvar->xterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+memvar->xterm+"assp.dbf"))
                fask(10,"Source A"+memvar->xterm+"ASSP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"Target C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+memvar->xterm+"enrp.dbf")
                fask(10,"Source  C"+memvar->xterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+cterm+"payp"                   //target payment file
        cyytenrp  := "c"+cterm+"enrp"                   //target enrollment file
        xyytpayp  := "a"+memvar->xterm+"payp"           //source payment file
        xyytassp  := "a"+memvar->xterm+"assp"           //source assessment file
        xyytenrp  := "c"+memvar->xterm+"enrp"           //source enrollment file
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999amlp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,1},;
                                   {,,xyytpayp,"xyytpayp",_DBF_SHARED,,2},;
                                   {,,xyytassp,"xyytassp",_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,xyytenrp,"xyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"para",,_DBF_SHARED,,},;
                                   {,,"csctrl",,_DBF_SHARED,,1},;
                                   {,,"a999accp",,_DBF_SHARED,,3}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        para->(dbgoto(1))
        nctr := para->seriesno
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"   College code "+ccolcode+" not found.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->fflag == _FORWARDED
                        if ! fask(10,"  Transaction for "+alltrim(term->name)+" was already  ;"+;
                                "  Forwarded, Proceed Re-Forwarding ?",{" Yes "," No  "},memvar->colorarray[05])==1
                                loop
                        endif
                endif
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif

                **begin processing**
                adspscr := savescr(01,00,24,79)
                showretrieving()
//              a999accp->(dbsetrelation("cyytenrp",{||a999accp->accidno},"a999accp->accidno"))   //added
                a999accp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
                a999accp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
/*
                memvar->nlast := 0
                a999accp->(dbgotop())
                do while ! a999accp->(eof())
                   if a999accp->acccolcod == ccolcode
                        memvar->nlast++
                   endif
                        a999accp->(dbskip())
                enddo
*/
                count to memvar->nlast
                restscr(adspscr)
                statusbar()
                a999accp->(dbgotop())
                do while ! a999accp->(eof())
                        showprogress()

                        nbal := 0
                        if xyytassp->(dbseek(a999accp->accidno))
                                nbal += xyytassp->asstotal
                        endif

                        xyytpayp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
                        xyytpayp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
                        xyytpayp->(dbgotop())
                        do while ! xyytpayp->(eof())
                               * fask(16,"  Processing document no. "+alltrim(xyytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                if xyytpayp->paytag == _POSTED
                                        nbal -= xyytpayp->payamt
                                elseif xyytpayp->paytag == _DISCOUNT
                                        nbal -= xyytpayp->payamt
                                elseif xyytpayp->paytag == _SHORT_TERM
                                        nbal += xyytpayp->payamt
                                elseif xyytpayp->paytag == _ADJUSTMENT
                                        nbal += xyytpayp->payamt
                                elseif xyytpayp->paytag == _FORWARDED
                                        nbal += xyytpayp->payamt
                                endif
                                xyytpayp->(dbskip())
                        enddo
                        xyytpayp->(clearscope())
/*
                        if xyytenrp->(dbseek(right(a999accp->accidno,8)))
                                if ! a999amlp->(dbseek(a999accp->accidno+memvar->xterm))
                                        a999amlp->(recycle())
                                        a999amlp->amlsyt        := memvar->xterm
                                        a999amlp->amlidno       := a999accp->accidno
                                        a999amlp->amlcolcod     := a999accp->acccolcod
                                        a999amlp->amlyrlevl     := a999accp->accyrlevl
                                        a999amlp->amlcode       := a999accp->acccode
                                        a999amlp->amlfeeyr      := a999accp->accfeeyr
                                        a999amlp->amlfeeunt     := a999accp->accfeeunt
                                        a999amlp->amlsytunt     := a999accp->accsytunt
                                        a999amlp->amlsytass     := a999accp->accsytass
                                        a999amlp->amlbalold     := a999accp->accbalold
                                        a999amlp->amladj        := a999accp->accadj
                                        a999amlp->amlsytadsc    := a999accp->accsytadsc
                                        a999amlp->amlduetot     := a999accp->accduetot
                                        a999amlp->amlamtpd      := a999accp->accamtpd
                                        a999amlp->amlbaltot     := a999accp->accbaltot
                                        a999amlp->(dbcommit())
                                        a999amlp->(dbunlock())
                                endif
                        endif
*/

                        if ! alltrim(str(nbal,9,2)) == "0.00"
                                a999accp->(reclock())
                                if cyytenrp->(dbseek(right(a999accp->accidno,8)))
                                        a999accp->acccolcod     := cyytenrp->enrcolcod
                                        a999accp->accyrlevl     := cyytenrp->enryrlevl
                                        a999accp->accsyt        := alltrim(cterm)
                                endif
                                a999accp->acccode       := space(04)
                                a999accp->accsytpdsc    := 0
                                a999accp->accsytadsc    := 0
                                a999accp->accfeeunt     := 0
                                a999accp->accsytunt     := 0
                                a999accp->accsyttui     := 0
                                a999accp->accst         := "1"
                                a999accp->accsytmisc    := 0
                                a999accp->accsytlab     := 0
                                a999accp->accsytoth     := 0
                                a999accp->accsytass     := 0
                                a999accp->accsyttot     := 0
                                a999accp->accamtpd      := 0
                                if nbal > 0
                                        a999accp->accbalold := nbal
                                        a999accp->accadj    := 0
                                elseif nbal < 0
                                        a999accp->accbalold := 0
                                        a999accp->accadj    := nbal
                                endif
                                a999accp->accduetot := nbal
                                a999accp->accbaltot := nbal
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())

                                ** payment file **
                                para->(dbgoto(1))
                                para->(reclock())
                                ayytpayp->(dbsetorder(4))
                                if ayytpayp->(dbseek(a999accp->accidno+_FORWARDED))
                                        ayytpayp->(reclock())
                                else
                                        ayytpayp->(recycle())
                                endif
                                ayytpayp->(dbsetorder(1))
                                ayytpayp->payrefno      := alltrim(str(++para->seriesno,8))
                                ayytpayp->payidno       := a999accp->accidno
                                ayytpayp->paytyp        := space(01)
                                ayytpayp->paydte        := date()
                                ayytpayp->paycolcod     := a999accp->acccolcod
                                ayytpayp->payyrlevl     := a999accp->accyrlevl
                                ayytpayp->paysyt        := cterm
                                ayytpayp->payamt        := nbal
                                ayytpayp->paytag        := _FORWARDED
                                ayytpayp->payadjcod     := if(nbal > 0,"OA","EP")
                                ayytpayp->payentdte     := date()
                                for ncol1 := 1 to 8
                                        xtime := substr(time(),ncol1,1)
                                        if (!xtime == ":")
                                                alltrim(ctime += xtime)
                                        endif
                                next
                                ayytpayp->payenttme     := ctime
                                ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                                ayytpayp->payentws      := " "
                                ayytpayp->(dbcommit())
                                ayytpayp->(dbunlock())

                                para->(dbcommit())
                                para->(dbunlock())
                        else
                                a999accp->(reclock())
                                if cyytenrp->(dbseek(right(a999accp->accidno,8)))
                                        a999accp->acccolcod     := cyytenrp->enrcolcod
                                        a999accp->accyrlevl     := cyytenrp->enryrlevl
                                        a999accp->accsyt        := alltrim(cterm)
                                endif
                                a999accp->acccode       := space(04)
                                a999accp->accsytpdsc    := 0
                                a999accp->accsytadsc    := 0
                                a999accp->accfeeunt     := 0
                                a999accp->accsytunt     := 0
                                a999accp->accsyttui     := 0
                                a999accp->accst         := "1"
                                a999accp->accsytmisc    := 0
                                a999accp->accsytlab     := 0
                                a999accp->accsytoth     := 0
                                a999accp->accsytass     := 0
                                a999accp->accsyttot     := 0
                                a999accp->accamtpd      := 0
                                a999accp->accadj        := 0
                                a999accp->accbalold     := 0
                                a999accp->accduetot     := 0
                                a999accp->accbaltot     := 0
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())

                        endif
                        a999accp->(dbskip())
                enddo
                a999accp->(clearscope())
//                a999accp->(dbclearrelation())
                ***************************************
                ** writing to cashier control file **
                if csctrl->(dbseek(memvar->xterm))
                        csctrl->(reclock())
                else
                        csctrl->(recycle())
                endif
                csctrl->term            := memvar->xterm
                csctrl->date            := date()
                csctrl->rectrail        := dtoc(date())+","+time()+","+memvar->cusername
                ****************************************
                ** write control file **
                if a999ctrl->(dbseek(memvar->xterm+ccolcode))
                        a999ctrl->(reclock())
                else
                        a999ctrl->(recycle())
                endif
                a999ctrl->term          := memvar->xterm
                a999ctrl->ccode         := ccolcode
                a999ctrl->date          := date()
                a999ctrl->fflag         := _FORWARDED
                a999ctrl->status        := _CLOSED
                a999ctrl->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
                a999ctrl->(dbcommit())
                a999ctrl->(dbunlock())

                if a999ctrl->(dbseek(cterm+ccolcode))
                        a999ctrl->(reclock())
                else
                        a999ctrl->(recycle())
                endif
                a999ctrl->term      := cterm
                a999ctrl->ccode     := ccolcode
                a999ctrl->date      := date()
                a999ctrl->fflag     := _FORWARDED
                a999ctrl->status    := space(01)
                a999ctrl->rectrail  := dtoc(date())+","+time()+","+memvar->cusername
                a999ctrl->(dbcommit())
                a999ctrl->(dbunlock())
                ********************************
                fask(18,"   Processing finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function checkterm(cterm)
local nyr := 0
if right(cterm,1) == "1"
        if left(cterm,2) == "00"
                nyr := 99
        else
                nyr := val(left(cterm,2)) - 1
        endif
        memvar->xterm := strzero(nyr,2)+"4"
elseif right(cterm,1) == "2"
        memvar->xterm := left(cterm,2)+"1"
else
        memvar->xterm := left(cterm,2)+"2"
endif
return(nil)

*-------------------------------------------------------------------------------

function newaccts()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,ccolcode,nbal,nadj,ctime:="",xtime,nctr,ainputscr
private nlast,nrec
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Create New Accounts  ")
        commandline("Г        F4 - View Term/College File       Г         ESC - Previous            Г")
        @ 03,01 say replicate("Ф",78)
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
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := "c"+cterm+"enrp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"para",,_DBF_SHARED,,},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                ainputscr := savescr(01,00,24,79)
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"   College code "+ccolcode+" not found.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif

                **Begin Processing**
                showretrieving()
                cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
                cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
                cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
                count to memvar->nlast
                restscr(ainputscr)
                statusbar()
                cyytenrp->(dbgotop())
                do while ! cyytenrp->(eof())
                        *fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        showprogress()
                        if ! a999accp->(dbseek("1"+cyytenrp->enridno))
                        //if a999accp->(dbseek("1"+cyytenrp->enridno)) // kung walay course code
                        //        a999accp->(reclock())                // ug year level - activate this one.
                                a999accp->(recycle())
                                a999accp->accidno       := "1"+cyytenrp->enridno
                                a999accp->acclname      := c999sm1p->sm1lstnam
                                a999accp->accfname      := c999sm1p->sm1fstnam
                                a999accp->accmname      := c999sm1p->sm1midnam
                                a999accp->acccolcod     := cyytenrp->enrcolcod
                                a999accp->accyrlevl     := cyytenrp->enryrlevl
                                a999accp->accsyt        := cterm
                                a999accp->accfeeyr      := substr(cyytenrp->enridno,1,2)
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                        endif
                        cyytenrp->(dbskip())
                enddo
                cyytenrp->(clearscope())
                cyytenrp->(dbclearrelation())
                fask(18,"   Processing finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-------------------------------------------------------------------------------

function resetacct()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,;
      cterm,cname,cacctno,ayytpayp,cyytenrp,cvar:=""
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Reset/Recompute Account Master Records  ")
        commandline("Г        F4 - View Term/Account File       Г         ESC - Previous            Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
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
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+cterm+"payp"
        cyytenrp  := "c"+cterm+"enrp"
        if(aprv2setup:=openwcheck({{,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Account No. :";
                        color memvar->colorarray[02];
                        get cacctno     pict "@!";
                        valid ! empty(cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if a999accp->(dbseek(cacctno)) .and. (! cyytenrp->(dbseek(right(cacctno,8))) .and.;
                                                      ! ayytpayp->(dbseek(cacctno))) .and.;
                                                      ! val(a999accp->acccolcod) > 0
                        fask(10,"  Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! a999accp->(dbseek(cacctno)) .and. ! cyytenrp->(dbseek(right(cacctno,8)))
                        fask(10,"   Student not enrolled this semester.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! a999accp->(dbseek(cacctno))
                        fask(10,"   Student not found in account file.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                commandline("Г       F10 - Reset/Recompute          Г           ESC - Previous              Г")
                dispinfo(cacctno)
                cvar := " "
                do while .t.
                        setkey(K_F10,{||resetrecord(cacctno)})
                        @ 24,78 get cvar pict "@!"
                       read
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F10,nil)
                        if lastkey() == K_ESC
                                exit
                        endif
                enddo
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function dispinfo(cacctno)
draw_box2(04,15,06,65,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 05,26 say "Students' Account Information" color memvar->colorarray[01]
draw_box1(07,15,22,65,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 08,17 say "                       "+a999accp->accidno color memvar->colorarray[01]
@ 08,17 say "Student ID No. . . . : " color memvar->colorarray[36]
@ 09,17 say "                       "+a999accp->acclname color memvar->colorarray[01]
@ 09,17 say "Last Name. . . . . . : " color memvar->colorarray[36]
@ 10,17 say "                       "+a999accp->accfname color memvar->colorarray[01]
@ 10,17 say "First Name . . . . . : " color memvar->colorarray[36]
@ 11,17 say "                       "+a999accp->accmname color memvar->colorarray[01]
@ 11,17 say "Middle Initial . . . : " color memvar->colorarray[36]
@ 12,17 say "                       "+a999accp->acccolcod+" "+a999accp->accyrlevl color memvar->colorarray[01]
@ 12,17 say "Course & Year. . . . : " color memvar->colorarray[36]
@ 14,17 say "                       "+transform(a999accp->accsyttot,"99,999,999.99") color memvar->colorarray[01]
@ 14,17 say "Assessments. . . . . : " color memvar->colorarray[36]
@ 15,17 say "                       "+transform(a999accp->accbalold,"99,999,999.99") color memvar->colorarray[01]
@ 15,17 say "Old Accounts . . . . : " color memvar->colorarray[36]
@ 16,17 say "                       "+transform(a999accp->accadj,"99,999,999.99") color memvar->colorarray[01]
@ 16,17 say "Adjustments. . . . . : " color memvar->colorarray[36]
@ 17,17 say "                       "+transform(a999accp->accsytadsc,"99,999,999.99") color memvar->colorarray[01]
@ 17,17 say "Discounts. . . . . . : " color memvar->colorarray[36]
@ 18,17 say "                       "+transform(a999accp->accduetot,"99,999,999.99") color memvar->colorarray[01]
@ 18,17 say "Total Due. . . . . . : " color memvar->colorarray[36]
@ 19,17 say "                       "+transform(a999accp->accamtpd,"99,999,999.99") color memvar->colorarray[01]
@ 19,17 say "Amount Paid. . . . . : " color memvar->colorarray[36]
@ 20,17 say "                       "+transform(a999accp->accbaltot,"99,999,999.99") color memvar->colorarray[01]
@ 20,17 say "Balance. . . . . . . : " color memvar->colorarray[36]
return(nil)

static function resetrecord(cacctno)
local noldacct := 0,nadjust := 0,ndisc := 0,ntotdue := 0,;
      namtpd := 0,nbal := 0
if fask(13,"  Are you sure to Reset/Recompute Account ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
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

        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accduetot     := a999accp->accsytass + noldacct + nadjust - ndisc
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := a999accp->accduetot - namtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())
*        fask(13,"   Reset/Recompute finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        __keyboard(chr(K_ESC))
endif
return(nil)

*------------------------------------------------------------------------------*

function fwdbalacct()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,cacctno,ayytpayp,nbal,nadj,ctime:="",xtime,nctr,ncol1,;
      xyytpayp,xyytassp,xyytenrp
private xterm
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Forward Account Balances by Account  ")
        commandline("Г        F4 - View Account File            Г         ESC - Previous            Г")
        @ 03,01 say replicate("Ф",78)
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
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        checkterm(cterm)
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+memvar->xterm+"payp.dbf"))
                fask(10,"  A"+memvar->xterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+memvar->xterm+"assp.dbf"))
                fask(10,"  A"+memvar->xterm+"ASSP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+memvar->xterm+"enrp.dbf")
                fask(10,"  C"+memvar->xterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+cterm+"payp"
        xyytpayp  := "a"+memvar->xterm+"payp"
        xyytassp  := "a"+memvar->xterm+"assp"
        cyytenrp  := "c"+cterm+"enrp"
        xyytenrp  := "c"+memvar->xterm+"enrp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999amlp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,4},;
                                   {,,xyytpayp,"xyytpayp",_DBF_SHARED,,2},;
                                   {,,xyytassp,"xyytassp",_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,xyytenrp,"xyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"para",,_DBF_SHARED,,},;
                                   {,,"a999accp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Account No.  :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid ! empty(cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(cacctno))
                        fask(10,"   Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
/*                if ! cyytenrp->(dbseek(right(cacctno,8)))
                        fask(10,"  Student not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif*/
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif
                **begin processing**
//                store 0 to nbal
                nbal := 0

                if xyytassp->(dbseek(cacctno))
                        nbal += xyytassp->asstotal
                endif

                xyytpayp->(sx_setscope(_TOP_SCOPE   ,cacctno))
                xyytpayp->(sx_setscope(_BOTTOM_SCOPE,cacctno))
                xyytpayp->(dbgotop())
                do while ! xyytpayp->(eof())
                        fask(16,"  Processing document no. "+alltrim(xyytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        do case
                                case xyytpayp->paytag == _POSTED
                                        nbal -= xyytpayp->payamt
                                case xyytpayp->paytag == _DISCOUNT
                                        nbal -= xyytpayp->payamt
                                case xyytpayp->paytag == _SHORT_TERM
                                        nbal += xyytpayp->payamt
                                case xyytpayp->paytag == _ADJUSTMENT
                                        nbal += xyytpayp->payamt
                                case xyytpayp->paytag == _FORWARDED
                                        nbal += xyytpayp->payamt
                        endcase
                        if nextkey() == K_ESC
                                exit
                        endif
                        xyytpayp->(dbskip())
                enddo
                xyytpayp->(clearscope())

                if ! a999amlp->(dbseek(cacctno+memvar->xterm))
                        a999amlp->(recycle())
                        a999amlp->amlsyt        := memvar->xterm
                        a999amlp->amlidno       := a999accp->accidno
                        a999amlp->amlcolcod     := a999accp->acccolcod
                        a999amlp->amlyrlevl     := a999accp->accyrlevl
                        a999amlp->amlcode       := a999accp->acccode
                        a999amlp->amlfeeyr      := a999accp->accfeeyr
                        a999amlp->amlfeeunt     := a999accp->accfeeunt
                        a999amlp->amlsytunt     := a999accp->accsytunt
                        a999amlp->amlsytass     := a999accp->accsytass
                        a999amlp->amlbalold     := a999accp->accbalold
                        a999amlp->amladj        := a999accp->accadj
                        a999amlp->amlsytadsc    := a999accp->accsytadsc
                        a999amlp->amlduetot     := a999accp->accduetot
                        a999amlp->amlamtpd      := a999accp->accamtpd
                        a999amlp->amlbaltot     := a999accp->accbaltot
                        a999amlp->(dbcommit())
                        a999amlp->(dbunlock())
                endif


                if ! alltrim(str(nbal,9,2)) == "0.00"
                        a999accp->(reclock())
                        if cyytenrp->(dbseek(right(a999accp->accidno,8)))
                                a999accp->acccolcod     := cyytenrp->enrcolcod
                                a999accp->accyrlevl     := cyytenrp->enryrlevl
                                a999accp->accsyt        := cterm
                        endif
                        a999accp->acccode       := space(04)
                        a999accp->accsytpdsc    := 0
                        a999accp->accsytadsc    := 0
                        a999accp->accfeeunt     := 0
                        a999accp->accsytunt     := 0
                        a999accp->accsyttui     := 0
                        a999accp->accst         := "1"
                        a999accp->accsytmisc    := 0
                        a999accp->accsytlab     := 0
                        a999accp->accsytoth     := 0
                        a999accp->accsytass     := 0
                        a999accp->accsyttot     := 0
                        a999accp->accamtpd      := 0
                        if nbal > 0
                                a999accp->accbalold := nbal
                                a999accp->accadj    := 0
                        elseif nbal < 0
                                a999accp->accbalold := 0
                                a999accp->accadj    := nbal
                        endif
                        a999accp->accduetot := nbal
                        a999accp->accbaltot := nbal
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())

                        ** payment file **
                        para->(dbgoto(1))
                        para->(reclock())
                        if ayytpayp->(dbseek(cacctno+_FORWARDED))
                                ayytpayp->(reclock())
                        else
                                ayytpayp->(recycle())
                        endif
                        ayytpayp->payrefno      := alltrim(str(++para->seriesno,8))
                        ayytpayp->payidno       := a999accp->accidno
                        ayytpayp->paytyp        := space(01)
                        ayytpayp->paydte        := date()
                        ayytpayp->paycolcod     := a999accp->acccolcod
                        ayytpayp->payyrlevl     := a999accp->accyrlevl
                        ayytpayp->paysyt        := cterm
                        ayytpayp->payamt        := nbal
                        ayytpayp->paytag        := _FORWARDED
                        ayytpayp->payadjcod     := if(nbal > 0,"OA","EP")
                        ayytpayp->payentdte     := date()
                        for ncol1 := 1 to 8
                                xtime := substr(time(),ncol1,1)
                                if (!xtime == ":")
                                        alltrim(ctime += xtime)
                                endif
                        next
                        ayytpayp->payenttme     := ctime
                        ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                        ayytpayp->payentws      := " "
                        ayytpayp->(dbcommit())
                        ayytpayp->(dbunlock())

                        para->(dbcommit())
                        para->(dbunlock())
                else
                        if cyytenrp->(dbseek(right(a999accp->accidno,8)))
                                a999accp->(reclock())
                                a999accp->acccolcod     := cyytenrp->enrcolcod
                                a999accp->accyrlevl     := cyytenrp->enryrlevl
                                a999accp->accsyt        := cterm
                                a999accp->acccode       := space(04)
                                a999accp->accsytpdsc    := 0
                                a999accp->accsytadsc    := 0
                                a999accp->accfeeunt     := 0
                                a999accp->accsytunt     := 0
                                a999accp->accsyttui     := 0
                                a999accp->accst         := "1"
                                a999accp->accsytmisc    := 0
                                a999accp->accsytlab     := 0
                                a999accp->accsytoth     := 0
                                a999accp->accsytass     := 0
                                a999accp->accsyttot     := 0
                                a999accp->accamtpd      := 0
                                a999accp->accbalold     := 0
                                a999accp->accadj        := 0
                                a999accp->accduetot     := 0
                                a999accp->accbaltot     := 0
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                        endif
                endif

                fask(18,"   Processing finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-----------------------------------------------------------------------------*


