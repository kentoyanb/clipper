* Program       :  PAENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) November 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------

function payupdate()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cpayno,dpay,cacctno,xacctno,npayamt,xpayamt,ctype

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11],"  Update Payment Record  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        @ 06,18 say replicate("Ф",46)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,19 say "School Term :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 05,37 say "- "+substr(term->name,1,25)
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        ayytpayp     := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,1}}))==nil
                return(nil)
        endif
        cpayno  := space(len(ayytpayp->payrefno))
        dpay    := date()
        do while .t.
                restscr(aentryscr)
                cacctno := space(len(ayytpayp->payidno))
                npayamt := 0
                ctype   := space(01)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 07,19 say "Payment Number :";
                        color memvar->colorarray[02];
                        get cpayno pict "@!";
                        valid ! empty(cpayno)
                @ 08,19 say "Payment Date   :";
                        color memvar->colorarray[02];
                        get dpay valid ! empty(dpay)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if ! ayytpayp->(dbseek(cpayno+dtos(dpay)))
                        fask(10,"   Payment not yet entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ayytpayp->(dbseek(cpayno+dtos(dpay))) .and. ayytpayp->paytag == _PAYMENT
                        fask(10,"   Payment not yet posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ayytpayp->(dbseek(cpayno+dtos(dpay))) .and. ! ayytpayp->paytag == _POSTED
                        fask(10,"   Data is not a payment record.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                else
                        ayytpayp->(reclock())
                        cacctno := ayytpayp->payidno
                        xacctno := ayytpayp->payidno
                        npayamt := ayytpayp->payamt
                        xpayamt := ayytpayp->payamt
                        ctype   := ayytpayp->paytyp
                        viewacct(cacctno,cprocsts)
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")
                        if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                                if rights("[RESTRICT]")
                                        setkey(K_F12,{||delpay(cacctno,npayamt,cpayno,dpay)})
                                endif
                        endif
                endif
                setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)
                @ 17,19 say "Amount Paid    :";
                        color memvar->colorarray[02];
                        get npayamt pict "999,999.99";
                        valid ! npayamt = 0
                @ 19,19 say "Payment Type   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F12,nil)
                if lastkey() == K_ESC
                        loop
                endif
                if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(20,"   Are you sure to save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ** payment file **
                ayytpayp->payrefno      := cpayno
                ayytpayp->payidno       := cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := dpay
                ayytpayp->paycolcod     := a999accp->acccolcod
                ayytpayp->payyrlevl     := a999accp->accyrlevl
                ayytpayp->paysyt        := cterm
                ayytpayp->paymach       := space(04)
                ayytpayp->paytelr       := space(02)
                ayytpayp->paybalbefr    := 0
                ayytpayp->payamt        := npayamt
                ayytpayp->paybalaftr    := 0
                ayytpayp->paytag        := _POSTED
                ayytpayp->payupddte     := date()
                ayytpayp->payupdusr     := substr(memvar->cusername,1,8)
                ayytpayp->payupdws      := "STN-"+strzero(n_stanum(),2)
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                **updated account master file (accp)**
                if ! cacctno = xacctno
                        ** new file **
                        a999accp->(dbseek(cacctno))
                        a999accp->(reclock())
                        a999accp->accamtpd  += npayamt
                        a999accp->accbaltot -= npayamt
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                        ** old file **
                        a999accp->(dbseek(xacctno))
                        a999accp->(reclock())
                        a999accp->accamtpd  -= xpayamt
                        a999accp->accduetot += xpayamt
                        a999accp->accbaltot += xpayamt
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                else
                        a999accp->(dbseek(cacctno))
                        a999accp->(reclock())
                        a999accp->accamtpd  -= xpayamt
                        a999accp->accduetot += xpayamt
                        a999accp->accbaltot += xpayamt
                        a999accp->accamtpd  += npayamt
                        a999accp->accbaltot -= npayamt
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

function viewacct(cacctno,cprocsts)
if ! a999accp->(dbseek(cacctno))
        vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 11,19 say "                 "+a999accp->acclname
@ 11,19 say "Last Name      : " color memvar->colorarray[02]
@ 12,19 say "                 "+a999accp->accfname
@ 12,19 say "First Name     : " color memvar->colorarray[02]
@ 13,19 say "                 "+a999accp->accmname
@ 13,19 say "Middle Initial : " color memvar->colorarray[02]
if c999colp->(dbseek(a999accp->acccolcod))
        @ 14,19 say "                 "+alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
elseif a999stcp->(dbseek(a999accp->acccolcod))
        @ 14,19 say "                 "+alltrim(a999stcp->stcdesabr)+" "+a999accp->accyrlevl
endif
@ 14,19 say "Course & Year  : " color memvar->colorarray[02]
@ 15,19 say "                 "+a999accp->accsyt
@ 15,19 say "Last Enrolment : " color memvar->colorarray[02]
return(.t.)

static function delpay(cacctno,npayamt,cpayno,dpay)
if fask(20,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        **payment file**
        *ayytpayp->(reclock())
        ayytpayp->payrefno := _DELETE_TAG
        ayytpayp->(dbdelete())
        ayytpayp->(dbcommit())
        ayytpayp->(dbunlock())

        **account master file**
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accamtpd  -= npayamt
        a999accp->accbaltot += npayamt
        a999accp->(dbcommit())
        a999accp->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*-------------------------------------------------------------------------------

function payentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cpayno,dpay,cacctno,npayamt,ctype

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11],"  Payment Record Entry  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        @ 06,18 say replicate("Ф",46)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,19 say "School Term :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 05,37 say "- "+substr(term->name,1,25)
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        ayytpayp     := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,1}}))==nil
                return(nil)
        endif
        cpayno  := space(len(ayytpayp->payrefno))
        dpay    := date()
        do while .t.
                restscr(aentryscr)
                cacctno := space(len(ayytpayp->payidno))
                npayamt := 0
                ctype   := space(01)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 07,19 say "Payment Number :";
                        color memvar->colorarray[02];
                        get cpayno pict "@!";
                        valid ! empty(cpayno)
                @ 08,19 say "Payment Date   :";
                        color memvar->colorarray[02];
                        get dpay valid ! empty(dpay)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if ayytpayp->(dbseek(cpayno+dtos(dpay))) .and. ayytpayp->paytag = _POSTED
                        fask(10,"   Payment already posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if lexist := ayytpayp->(dbseek(cpayno+dtos(dpay)))
                        ayytpayp->(reclock())
                        cacctno := ayytpayp->payidno
                        npayamt := ayytpayp->payamt
                        ctype   := ayytpayp->paytyp
                        viewacct(cacctno,cprocsts)
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")
                        if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                                if rights("[RESTRICT]")
                                        setkey(K_F12,{||delpayent(cacctno,npayamt)})
                                endif
                        endif
                else
                        commandline("Г         F4 - View Student            Г           ESC - Previous              Г")
                endif
                setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)
                @ 17,19 say "Amount Paid    :";
                        color memvar->colorarray[02];
                        get npayamt pict "999,999.99";
                        valid ! npayamt = 0
                @ 19,19 say "Payment Type   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F12,nil)
                if lastkey() == K_ESC
                        loop
                endif
                if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(20,"   Are you sure to save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ** payment file **
                if ! lexist
                        ayytpayp->(recycle())
                endif
                ayytpayp->payrefno      := cpayno
                ayytpayp->payidno       := cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := dpay
                ayytpayp->paycolcod     := a999accp->acccolcod
                ayytpayp->payyrlevl     := a999accp->accyrlevl
                ayytpayp->paysyt        := cterm
                ayytpayp->paymach       := space(04)
                ayytpayp->paytelr       := space(02)
                ayytpayp->paybalbefr    := 0
                ayytpayp->payamt        := npayamt
                ayytpayp->paybalaftr    := 0
                ayytpayp->paytag        := _PAYMENT
                if ! lexist
                        ayytpayp->payentdte     := date()
                        ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                        ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                        ayytpayp->payentws      := "STN-"+strzero(n_stanum(),2)
                else
                        ayytpayp->payupddte     := date()
                        ayytpayp->payupdusr     := substr(memvar->cusername,1,8)
                        ayytpayp->payupdws      := "STN-"+strzero(n_stanum(),2)
                endif
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function delpayent(cacctno,npayamt)
if fask(20,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        **payment file**
        ayytpayp->payrefno := _DELETE_TAG
        ayytpayp->(dbdelete())
        ayytpayp->(dbcommit())
        ayytpayp->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*-------------------------------------------------------------------------------

function adjentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cadjno,dadj,cacctno,xacctno,nadjamt,xadjamt,ctype,xtype,cadjcode

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                           {,,"para",,_DBF_SHARED,,}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11],"  Adjustment Entry  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        @ 06,18 say replicate("Ф",46)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,19 say "School Term :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 05,37 say "- "+substr(term->name,1,25)
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        ayytpayp     := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999chrt",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,1}}))==nil
                return(nil)
        endif
        *para->(dbgoto(1))
        *cadjno := alltrim(str(para->seriesno))+space(08-len(alltrim(str(para->seriesno))))
        do while .t.
                restscr(aentryscr)
                cadjno   := space(len(ayytpayp->payrefno))
                cacctno  := space(len(ayytpayp->payidno))
                dadj     := date()
                nadjamt  := 0
                ctype    := space(02)
                cadjcode := space(02)
                if rights("[BEWARE]")    &&for supervisor only
                        setcursor(1);set(_SET_CONFIRM,.t.)
                        @ 07,19 say "Adjustment No.  :";
                                color memvar->colorarray[02];
                                get cadjno pict "@!"
*                               valid ! empty(cadjno)
                       read
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                        if lastkey() == K_ESC
                                exit
                        endif
                        if ayytpayp->(dbseek(cadjno)) .and. ! ayytpayp->paytag = _ADJUSTMENT
                                fask(10,"   Record is not an adjustment.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                endif
                if lexist := ayytpayp->(dbseek(cadjno))
                        ayytpayp->(reclock())
                        dadj     := ayytpayp->paydte
                        cacctno  := ayytpayp->payidno
                        xacctno  := ayytpayp->payidno
                        nadjamt  := if(ayytpayp->payamt>0,ayytpayp->payamt,ayytpayp->payamt*-1)
                        xadjamt  := if(ayytpayp->payamt>0,ayytpayp->payamt,ayytpayp->payamt*-1)
                        cadjcode := ayytpayp->payadjcod
                        ctype    := if(ayytpayp->payamt>0,"DR","CR")
                        xtype    := if(ayytpayp->payamt>0,"DR","CR")
                        viewacct(cacctno,cprocsts)
                        vchart(cadjcode,cprocsts)
                        if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                                if rights("[RESTRICT]")
                                        setkey(K_F12,{||deladj(cacctno,nadjamt,ctype)})
                                endif
                        endif
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")
                else
                        commandline("Г          F4 - View Student           Г            ESC - Previous             Г")
                endif
                setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts),;
                               if(readvar()=="CADJCODE",viewchart(space(len(a999chrt->code)),cprocsts),))})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 08,19 say "Adjustment Date :";
                        color memvar->colorarray[02];
                        get dadj valid ! empty(dadj)
                if ! rights("[BEWARE]")
                       read
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                        if lastkey() == K_ESC
                                exit
                        endif
                        setcursor(1);set(_SET_CONFIRM,.t.)
                endif
                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)
                @ 17,19 say "Adjustment Code   :";
                        color memvar->colorarray[02];
                        get cadjcode pict "@!";
                        valid vchart(cadjcode,cprocsts)
                @ 18,19 say "                       [CR-credit, DR-debit]" color memvar->colorarray[02]
                @ 18,19 say "Adjustment Type   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!";
                        valid ctype $ "DR,CR"
                @ 19,19 say "Adjustment Amount :";
                        color memvar->colorarray[02];
                        get nadjamt pict "999,999.99";
                        valid ! nadjamt == 0
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F12,nil)
                if lastkey() == K_ESC
                        loop
                endif
                if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(20,"   Are you sure to save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ** payment file **
                if ! lexist
                        ayytpayp->(recycle())
                        para->(dbgoto(1))
                        ayytpayp->payrefno := alltrim(str(para->seriesno))+space(08-len(alltrim(str(para->seriesno))))
                        para->(reclock())
                        para->seriesno := para->seriesno + 1
                        para->(dbcommit())
                        para->(dbunlock())
                endif
                *ayytpayp->payrefno      := cadjno
                ayytpayp->payidno       := cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := dadj
                ayytpayp->paycolcod     := a999accp->acccolcod
                ayytpayp->payyrlevl     := a999accp->accyrlevl
                ayytpayp->paysyt        := cterm
                ayytpayp->paymach       := space(04)
                ayytpayp->paytelr       := space(02)
                ayytpayp->paybalbefr    := 0
                ayytpayp->payamt        := if(ctype="CR",nadjamt*-1,nadjamt)
                ayytpayp->paybalaftr    := 0
                ayytpayp->paytag        := _ADJUSTMENT
                ayytpayp->payadjcod     := cadjcode
                if ! lexist
                        ayytpayp->payentdte     := date()
                        ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                        ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                        ayytpayp->payentws      := "STN-"+strzero(n_stanum(),2)
                else
                        ayytpayp->payupddte     := date()
                        ayytpayp->payupdusr     := substr(memvar->cusername,1,8)
                        ayytpayp->payupdws      := "STN-"+strzero(n_stanum(),2)
                endif
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                **updated account master file (accp)**
                if lexist
                        if ! cacctno = xacctno
                                ** new file **
                                a999accp->(dbseek(cacctno))
                                a999accp->(reclock())
                                if ctype = "CR"
                                        a999accp->accadj    -= nadjamt
                                        a999accp->accduetot -= nadjamt
                                        a999accp->accbaltot -= nadjamt
                                elseif ctype = "DR"
                                        a999accp->accadj    += nadjamt
                                        a999accp->accduetot += nadjamt
                                        a999accp->accbaltot += nadjamt
                                endif
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                                ** old file **
                                a999accp->(dbseek(xacctno))
                                a999accp->(reclock())
                                if xtype = "CR"
                                        a999accp->accadj    += xadjamt
                                        a999accp->accduetot += xadjamt
                                        a999accp->accbaltot += xadjamt
                                elseif xtype = "DR"
                                        a999accp->accadj    -= xadjamt
                                        a999accp->accduetot -= xadjamt
                                        a999accp->accbaltot -= xadjamt
                                endif
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                        else
                                a999accp->(dbseek(cacctno))
                                a999accp->(reclock())
                                if xtype = "CR"
                                        a999accp->accadj    += xadjamt
                                        a999accp->accduetot += xadjamt
                                        a999accp->accbaltot += xadjamt
                                elseif xtype = "DR"
                                        a999accp->accadj    -= xadjamt
                                        a999accp->accduetot -= xadjamt
                                        a999accp->accbaltot -= xadjamt
                                endif

                                if ctype = "CR"
                                        a999accp->accadj    -= nadjamt
                                        a999accp->accduetot -= nadjamt
                                        a999accp->accbaltot -= nadjamt
                                elseif ctype = "DR"
                                        a999accp->accadj    += nadjamt
                                        a999accp->accduetot += nadjamt
                                        a999accp->accbaltot += nadjamt
                                endif
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                        endif
                else
                        a999accp->(dbseek(cacctno))
                        a999accp->(reclock())
                        if ctype = "CR"
                                a999accp->accadj    -= nadjamt
                                a999accp->accduetot -= nadjamt
                                a999accp->accbaltot -= nadjamt
                        elseif ctype = "DR"
                                a999accp->accadj    += nadjamt
                                a999accp->accduetot += nadjamt
                                a999accp->accbaltot += nadjamt
                        endif
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
/*
                if val(cadjno) == para->seriesno
                        para->(reclock())
                        para->seriesno := para->seriesno + 1
                        para->(dbcommit())
                        para->(dbunlock())
                endif
                cadjno := alltrim(str(para->seriesno))+space(08-len(alltrim(str(para->seriesno))))
*/
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function deladj(cacctno,nadjamt,ctype)
if fask(20,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        **payment file**
        ayytpayp->payrefno := _DELETE_TAG
        ayytpayp->(dbdelete())
        ayytpayp->(dbcommit())
        ayytpayp->(dbunlock())
        **account master file**
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        if ctype = "CR"
                a999accp->accadj    += nadjamt
                a999accp->accduetot += nadjamt
                a999accp->accbaltot += nadjamt
        elseif ctype = "DR"
                a999accp->accadj    -= nadjamt
                a999accp->accduetot -= nadjamt
                a999accp->accbaltot -= nadjamt
        endif
        a999accp->(dbcommit())
        a999accp->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

static function vchart(ccode,cprocsts)
if ! a999chrt->(dbseek(ccode))
        viewchart({||__keyboard(chr(K_CTRL_LEFT)+a999chrt->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 17,42 say "- "+substr(a999chrt->desc,1,20)
return(.t.)

*-------------------------------------------------------------------------------

function postpay()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,aentryscr,ayytpayp,;
      cterm,ccolcode

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Post Payment Records  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "           No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        ayytpayp     := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,3}}))==nil
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
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"   College code "+ccolcode+" not found.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(10,"   Post payment records ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif
                processpostpay(ccolcode)
                fask(18,"  Finished payment posting.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function processpostpay(ccolcode)
local alastscr := savescr(01,00,24,79)
private nlast,nrec
showretrieving()
ayytpayp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
count to memvar->nlast
restscr(alastscr)
statusbar()
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        showprogress()
        if ayytpayp->paytag == _PAYMENT
                **account master file**
                a999accp->(dbseek(ayytpayp->payidno))
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
ayytpayp->(clearscope())
return(nil)

*-------------------------------------------------------------------------------
