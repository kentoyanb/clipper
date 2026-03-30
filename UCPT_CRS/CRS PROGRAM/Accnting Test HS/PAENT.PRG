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
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11]," BasicEd Update Payment Record  ")
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
                        a999accp->(dbseek(cacctno))
                        setkey(K_F12,{||delpay(cacctno,npayamt,dpay,cterm,a999accp->acccolcod)})

                        
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


static function processOR()
local nindexsss := 1

            zyytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->idno+memvar->cpayno))
            zyytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->idno+memvar->cpayno))
            
            zyytpayp->(dbgotop())
            if ! zyytpayp -> (eof())
                do while ! zyytpayp->(eof())

                            //b999chrt->(dbseek(zyytpayp->paycode))

                            nlastelems := len(memvar->aitemss)
                            aadd(memvar->aitemss,_EMPTY2)
                            memvar->aitemss[nlastelems,_ORNO]          := zyytpayp->payrefno
                            memvar->aitemss[nlastelems,_CODE2]         := zyytpayp->paycolcod
                            memvar->aitemss[nlastelems,_AMOUNT2]       := zyytpayp->payamt
                            memvar->aitemss[nlastelems,_DATE2]         := displaydate(zyytpayp->paydte)
                            memvar->aitemss[nlastelems,_ENTTIME]       := zyytpayp->payenttme

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

static function delpay(cacctno,npayamt,dpay,cterm,colcod)

if a999ctrl->(dbseek(cterm+colcod)) .and. ! a999ctrl->status == _CLOSED
    if rights("[RESTRICT]") 
        if dpay == date()
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
        else
            fask(10,"  Cannot delete record, record is already past entry date.   ",{" Ok "},memvar->colorarray[05],.t.,nil)    
        endif
    else
        fask(10,"   You have no right to delete record.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
    endif
else
    fask(10,"   Transaction is already closed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
endif

return(nil)

*-------------------------------------------------------------------------------

function payentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cpayno,dpay,cacctno,npayamt,ctype,adjcod

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11],"  BasicEd Payment Record Entry   ")
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
                adjcod  := space(02)
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
                        adjcod  := ayytpayp->payadjcod
                        viewacct(cacctno,cprocsts)
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")

                        a999accp->(dbseek(cacctno))
                        setkey(K_F12,{||delpayent(cacctno,npayamt,dpay,cterm,a999accp->acccolcod)})

                else
                        commandline("Г         F4 - View Student            Г           ESC - Previous              Г")
                endif

                /*setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts),)})
                setcursor(1);set(_SET_CONFIRM,.t.)*/

                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)


                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)
                @ 16,19 say "Amount Paid    :";
                        color memvar->colorarray[02];
                        get npayamt pict "999,999.99";
                        valid ! npayamt = 0
                @ 17,19 say "Payment Type   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!"
                @ 18,19 say "If Payment is SUBSIDY->Enter code (SS):";
                        color memvar->colorarray[02];
                        get adjcod pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F12,nil)
                if lastkey() == K_ESC
                        loop
                endif

                a999accp->(dbseek(cacctno))
                if ! a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AG,GS,ST,HU,OO,IC,AM" 
                        fask(10,"Record Entry of College ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if alltrim(substr(cterm,3,1)) != "1" .and. a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
                        fask(10,"Payments of Elem/JuniorHigh ("+a999accp->acccolcod+") may CAUSE DATA ERROR ("+cterm+");"+;
                        "because Elem/JuniorHigh is per YEAR, transactions are in First Semester. ",{" Ok "},memvar->colorarray[05],.t.,nil)

                        if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                            loop
                        endif
                endif

                /*if a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(cterm,3,1)) != "1"
                      fask(10,"Payment Entry of Elem/JH ("+a999accp->acccolcod+") is ALLOWED during;"+;
                        "1ST SEMESTERS ONLY. Please Enter Adjustment in 1st Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif*/

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

                if adjcod == "SS"
                    ayytpayp->payadjcod  := adjcod //to determine nga SubSidy ni
                endif

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

static function delpayent(cacctno,npayamt,tdate,cterm,colcod)

if a999ctrl->(dbseek(cterm+colcod)) .and. ! a999ctrl->status == _CLOSED
    if rights("[RESTRICT]") 
        if tdate == date()
            if fask(20,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                    **payment file**
                    ayytpayp->payrefno := _DELETE_TAG
                    ayytpayp->(dbdelete())
                    ayytpayp->(dbcommit())
                    ayytpayp->(dbunlock())
                    __keyboard(chr(K_ESC))
            endif
        else
            fask(10,"  Cannot delete record, record is already past entry date.   ",{" Ok "},memvar->colorarray[05],.t.,nil)    
        endif
    else
        fask(10,"   You have no right to delete record.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
    endif
else
    fask(10,"   Transaction is already closed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
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
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11],"  BasicEd Adjustment Entry  ")
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
                cadjcode := space(len(a999chrt->code)) //space(02)
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

                        a999accp->(dbseek(ayytpayp->payidno))
                        setkey(K_F12,{||deladj(cacctno,nadjamt,ctype,dadj,cterm,a999accp->acccolcod)})
                    
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")
                else
                        commandline("Г          F4 - View Student           Г            ESC - Previous             Г")
                endif

                /*setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts),;
                               if(readvar()=="CADJCODE",viewchart(space(len(a999chrt->code)),cprocsts),))})
                setcursor(1);set(_SET_CONFIRM,.t.)*/

                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
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

                a999accp->(dbseek(cacctno))
                if ! a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AG,GS,ST,HU,OO,IC,AM" 
                        fask(10,"Record Entry of College ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if alltrim(substr(cterm,3,1)) != "1" .and. a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
                        fask(10,"Adjustment of Elem/JuniorHigh ("+a999accp->acccolcod+") may CAUSE ERROR ("+cterm+");"+;
                        "because Elem/JuniorHigh is per YEAR, transactions are in First Semester. ",{" Ok "},memvar->colorarray[05],.t.,nil)

                        if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                            loop
                        endif
                elseif cadjcode == 'OA' .or. cadjcode == 'EP'

                        fask(10,"  OA/EP is not allowed to be adjusted. ",{" Ok "},memvar->colorarray[05],.t.,nil)
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

static function deladj(cacctno,nadjamt,ctype,dadj,cterm,colcod)

if a999ctrl->(dbseek(cterm+colcod)) .and. ! a999ctrl->status == _CLOSED
    if rights("[RESTRICT]") 
        if dadj == date()
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
        else
            fask(10,"  Cannot delete record, record is already past entry date.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
            
        endif      
    else
        fask(10,"   You have no right to delete record.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
    endif
else
    fask(10,"   Transaction is already closed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
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
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11]," BasicEd Post Payment Records  ")
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
                @ 04,02 say "BasicEd Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"   BasicEd "+ccolcode+" not found.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ! ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AG,GS,ST,HU,OO,IC,AM" 
                        fask(10,"Record Entry of College ("+ccolcode+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(cterm,3,1)) != "1"
                      fask(10,"Posting Payments of Elem/JH ("+ccolcode+") is ALLOWED during;"+;
                        "1ST SEMESTERS ONLY. Please Enter Postings in 1st Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
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


function paymentsubsidy()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,aentryscr,cyytenrp,;
      cterm,cname,ccolcode,ayytassp,ayytpayp,cyytskdp,cvar:="",adspscr,;
      cpayno

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Subsidy Entry by BasicEd Code")
        commandline("Г        F4 - View Term/College File       Г         ESC - Previous            Г")
        @ 03,01 say replicate("Ф",78)
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
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  A"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+cterm+"assp"
        ayytpayp  := "a"+cterm+"payp"
        cyytenrp  := "c"+cterm+"enrp"
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,10},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999stra",,_DBF_SHARED,,1},;
                                   {,,"a999feep",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999lbfp",,_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        cpayno  := space(len(ayytpayp->payrefno))
        cstrndsbsid := space(len(a999accp->accpbcprv))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "BasicEd Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!" valid ! empty(ccolcode)

                @ 05,02 say "Ref No. :";
                        color memvar->colorarray[02];
                        get cpayno pict "@!";
                        valid ! empty(cpayno)

                @ 06,40 say "[1]|[2]|[3][4] " color memvar->colorarray[02]
                @ 06,02 say "Pub|PrE|PrwE|UCESC: ";
                color memvar->colorarray[02];
                get memvar->cstrndsbsid       pict "@!";
                valid memvar->cstrndsbsid $ "1234"

               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"  BasicEd code "+ccolcode+" not found.  ",{" OK "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ! ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AG,GS,ST,HU,OO,IC,AM"
                        fask(10,"Creating of College ("+ccolcode+") Subsidy is NOT ALLOWED ;"+;
                        "in Basic Ed Accounting Program",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(cterm,3,1)) != "1"
                        fask(10,"Subsidy Entry of Elem/JH ("+ccolcode+") is ALLOWED during;"+;
                        "1ST SEMESTERS ONLY. Please do the entry in 1st Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                adspscr := savescr(01,00,24,79)

                /*if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->aflag == _POSTED
                        fask(10,"  BasicEd code "+ccolcode+" assessment already posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                */
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  BasicEd code "+ccolcode+" transaction already closed.  ;"+;
                                "         No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif !a999ctrl->(dbseek(cterm+ccolcode))
                        fask(10,"  BasicEd code "+ccolcode+" transaction not forwarded.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif


                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                subsidyproc(cterm,ccolcode,cpayno)
                fask(18,"   Processing completed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function subsidyproc(cterm,ccolcode,cpayno)
local nunit,noth,nlab,nctr := 1,idnum,skdno,alastscr := savescr(01,00,24,79)
private nlast,nrec, lexist:=.f.
showretrieving()
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
count to memvar->nlast
&&restscr(adspscr)
restscr(alastscr)
statusbar()

cyytenrp->(dbgotop())

do while ! cyytenrp->(eof())
        showprogress()
        nunit := 0
        nunit := cyytenrp->enrunt
        ntuition := noth := nlab := 0
// FOR ID 1,2,3
        if a999accp->(dbseek("1"+cyytenrp->enridno))
               idnum := a999accp->accidno
               //fask(10,"  Processing student no. "+idnum+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
               idnum := a999accp->accidno
               //fask(10,"  Processing student no. "+idnum+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
        elseif a999accp->(dbseek("3"+cyytenrp->enridno))
               idnum := a999accp->accidno
               //fask(10,"  Processing student no. "+idnum+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
        endif

        a999accp->(dbseek(idnum))

        fask(10," "+a999accp->accidno+" "+a999accp->accfeeyr+" "+a999accp->accpbcprv+" ",{" Ok "},memvar->colorarray[06],.f.,nil)

        //search for the subsidy of that certain strand and fee year to get the amount
        a999stra->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+cterm+memvar->cstrndsbsid))

        
        **payp file here** 
        if (a999accp->accfeeyr == a999stra->strndyr ) .and. (a999accp->acccolcod == a999stra->strndbcod) .and. (a999accp->accpbcprv == memvar->cstrndsbsid)

            nctr++
            //ayytpayp->(recycle()) //insert


            if  ayytpayp->(dbseek(a999accp->accidno+"SS")) 
                    ayytpayp->(reclock()) //update if existing na or ge creatan na og payment subsidy
            else
                    ayytpayp->(recycle()) //insert if not existed ang payment subsidy
            endif
            
            fask(10," "+a999accp->accidno+" "+a999accp->accfeeyr+" "+a999accp->accpbcprv+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
            
            //ayytpayp->payrefno      := str(nctr)+""+cpayno
            ayytpayp->payrefno      := alltrim(str(nctr)) + cpayno
            ayytpayp->payidno       := idnum
            ayytpayp->paydte        := date()
            ayytpayp->paycolcod     := cyytenrp->enrcolcod
            ayytpayp->payyrlevl     := cyytenrp->enryrlevl
            ayytpayp->paysyt        := cterm
            ayytpayp->payamt        := a999stra->strndamoun
            ayytpayp->payentdte     := date()
            ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
            ayytpayp->payentusr     := substr(memvar->cusername,1,8)
            ayytpayp->payentws      := "STN-"+str(n_stanum())

            ayytpayp->paytag        := _PAYMENT
            ayytpayp->payadjcod     := "SS" //to determine nga SubSidy ni


            ayytpayp->(dbcommit())
            ayytpayp->(dbunlock())
        endif

        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())

return(nil)

*------------------------------------------------------------------------------*


