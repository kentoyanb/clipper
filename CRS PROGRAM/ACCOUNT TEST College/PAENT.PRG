* Program       :  PAENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) November 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

#define _ORNO            1 //REFNO
#define _CODE2           2 // PAYCOLCOD
#define _ADJCOD          3 //PAYADJCOD
#define _AMOUNT2         4 //PAYMT
#define _DATE2           5 // PAYDTE
#define _ENTTIME         6 //PAYENTTIME
#define _TAG             7 //paytag
#define _BATCHNO         8 //paybatchno       
#define _EMPTY2          {space(08),;
                          space(02),;
                          space(02),;
                          0,;
                          space(10),;
                          space(10),;
                          space(01),;
                          0}

*-------------------------------------------------------------------------------

function payupdate()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cpayno,dpay,cacctno,xacctno,npayamt,xpayamt,ctype,colcod

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Update Payment Record  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 06,18 say replicate("Ä",46)
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
                colcod  := space(len(ayytpayp->paycolcod))
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
                        commandline("³     F4 - View Student    ³       F12 - Delete        ³     ESC - Previous    ³")
                        a999accp->(dbseek(cacctno))
                        setkey(K_F12,{||delpay(cacctno,npayamt,dpay,cterm,a999accp->acccolcod)})

                       
                endif
                setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)

                @ 14,19 say "Course Code/Training(Short Term) Code :";
                        color memvar->colorarray[02];
                        get colcod pict "@!";
                        valid ! empty(colcod)

                @ 17,19 say "Amount Paid    :";
                        color memvar->colorarray[02];
                        get npayamt pict "999,999.99";
                        valid ! npayamt = 0
                /*@ 18,19 say "Amount Paid 2   :";
                        color memvar->colorarray[02];
                        get xpayamt pict "999,999.99";
                        valid ! xpayamt = 0
                        */
                        
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

                /*
                if ! c999colp->(dbseek(a999accp->acccolcod)) .and. ! a999stcp->(dbseek(a999accp->acccolcod))
                        @ 14,19 say "                 "+alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
                //elseif a999stcp->(dbseek(a999accp->acccolcod))
                //       @ 14,19 say "                 "+alltrim(a999stcp->stcdesabr)+" "+a999accp->accyrlevl

                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop        
                endif                
                */

                if ! fask(20,"   Are you sure to save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ** payment file **
                ayytpayp->payrefno      := cpayno
                ayytpayp->payidno       := cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := dpay
                ayytpayp->paycolcod     := colcod
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

/*
if c999colp->(dbseek(a999accp->acccolcod))
        @ 14,19 say "                 "+alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
elseif a999stcp->(dbseek(a999accp->acccolcod))
        @ 14,19 say "                 "+alltrim(a999stcp->stcdesabr)+" "+a999accp->accyrlevl
endif
@ 14,19 say "Course & Year  : " color memvar->colorarray[02]
*/
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
      cterm,cpayno,dpay,cacctno,npayamt,ctype,paycode,colcod

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Payment Record Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 06,18 say replicate("Ä",46)
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
                                   {,,"b999chrt",,_DBF_SHARED,,1,"/brunlib"},;
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
                colcod  := space(len(ayytpayp->paycolcod))
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
                /*if ayytpayp->(dbseek(cpayno+dtos(dpay))) .and. ayytpayp->paytag = _POSTED
                        fask(10,"   Payment already posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif*/
                if lexist := ayytpayp->(dbseek(cpayno+dtos(dpay)))
                        ayytpayp->(reclock())
                        cacctno := ayytpayp->payidno
                        npayamt := ayytpayp->payamt
                        ctype   := ayytpayp->paytyp
                        viewacct(cacctno,cprocsts)
                        commandline("³     F4 - View Student    ³       F12 - Delete        ³     ESC - Previous    ³")
                        
                        a999accp->(dbseek(cacctno))
                        setkey(K_F12,{||delpayent(cacctno,npayamt,dpay,cterm,a999accp->acccolcod)})

                        
                else
                        commandline("³         F4 - View Student            ³           ESC - Previous              ³")
                endif
                /*setkey(K_F4,{||if(readvar()=="CACCTNO",viewacct(space(len(a999accp->accidno)),cprocsts),)})
                setcursor(1);set(_SET_CONFIRM,.t.)*/

                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                
                @ 10,19 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid viewacct(cacctno,cprocsts)

                @ 14,19 say "Course Code/Training(Short Term) Code :";
                        color memvar->colorarray[02];
                        get colcod pict "@!";
                        valid ! empty(colcod)  

                @ 17,19 say "Amount Paid    :";
                        color memvar->colorarray[02];
                        get npayamt pict "999,999.99";
                        valid ! npayamt = 0

                @ 19,19 say "Payment Code   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!"         

                @ 19,19 say "Payment Type   :";
                        color memvar->colorarray[02];
                        get ctype pict "@!"

               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F12,nil)
                if lastkey() == K_ESC
                        loop
                endif

                a999accp->(dbseek(cacctno))
                
                if a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" 
                        fask(10,"Record Entry of BasicEd ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in College Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
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
                ayytpayp->paycolcod     := colcod
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
      cterm,cadjno,dadj,cacctno,xacctno,nadjamt,xadjamt,ctype,xtype,cadjcode,colcod

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                           {,,"para",,_DBF_SHARED,,}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Adjustment Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 06,18 say replicate("Ä",46)
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
                colcod   := space(len(ayytpayp->paycolcod))
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
                        a999accp->(dbseek(ayytpayp->payidno))
                        setkey(K_F12,{||deladj(cacctno,nadjamt,ctype,dadj,cterm,a999accp->acccolcod)})
                        

                        commandline("³     F4 - View Student    ³       F12 - Delete        ³     ESC - Previous    ³")
                else
                        commandline("³          F4 - View Student           ³            ESC - Previous             ³")
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

                @ 14,19 say "Course Code/Training(Short Term) Code :";
                        color memvar->colorarray[02];
                        get colcod pict "@!";
                        valid ! empty(colcod)

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
                if a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" 
                        fask(10,"Record Entry of BasicEd ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in College Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop

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
                ayytpayp->paycolcod     := colcod
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
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Post Payment Records  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 03,01 say replicate("Ä",78)
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

                if ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" 
                        fask(10,"Post Payments of BasicEd ("+ccolcode+") is not ALLOWED ;"+;
                        "in College Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
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


function or_view()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,ayytpayp,idno,pclass,viewor,bindex,bitems,;
      oappren,nrec,nlastelems,cborno,nindexss,xyytpayp
private cterm,nmos,aitemss := {}, nindexs

bindex  := memvarblock("NINDEXS")
bitems  := memvarblock("AITEMSS")


viewor   := createabrowse(bitems,bindex,08,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|pOR(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitemss[memvar->nindexs,_ORNO]},nil},;
                        {{||memvar->aitemss[memvar->nindexs,_CODE2]},nil},;
                        {{||transform(memvar->aitemss[memvar->nindexs,_AMOUNT2],"999,999.99")+" "},nil},;
                        {{||" "+memvar->aitemss[memvar->nindexs,_DATE2]+" "},nil},;
                        {{||" "+memvar->aitemss[memvar->nindexs,_ENTTIME]+" "},nil}},;
                        {"O.R NO.", "   CODE   ", "  AMOUNT  ",  "  DATE ",  "  ENTTIME "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"})


if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OR Viewing  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")

aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))


do while .t.
       
        //clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Update Payment Records V2 ")
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
            ayytpayp := "a"+memvar->cterm+"payp"
            zyytpayp := "a"+memvar->cterm+"payp"
            xyytpayp := "a"+memvar->cterm+"payp"
            if(aprv2setup := openwcheck({{,, ayytpayp,"ayytpayp",_DBF_SHARED,,1},;
                                         {,, zyytpayp,"zyytpayp",_DBF_SHARED,,7},;
                                         {,, xyytpayp,"xyytpayp",_DBF_SHARED,,12},;
                                         {,,"a999ctrl",,_DBF_SHARED,,1},;
                                         {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"}})) == nil
                    return(nil)
            endif

            memvar->idno := space(len(a999accp->accidno))
            memvar->pclass := space(01)
            memvar->dpay  := date()
            memvar->cpayno := space(len(ayytpayp->payrefno))

        //setcursor(1);set(_SET_CONFIRM,.t.)
        do while .t.

                restscr(bprntscr)
                //commandline("?         F4 - View Account           ?          ESC - Previous              ?")
               // setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})

                

                setcursor(1);set(_SET_CONFIRM,.t.)

                @ 04,02 say "OR /Reference #: ";
                        color memvar->colorarray[02];
                        get memvar->cpayno pict "@!" valid ! empty(memvar->cpayno)

                read
                    //setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                    setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)

                    if lastkey() == K_ESC
                           
                            exit
                    endif
                    ayytpayp->(dbseek(cpayno))

                    if ! ayytpayp->(dbseek(cpayno))
                        fask(10,"   Payment not yet entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    elseif  ayytpayp->paytag == 'F'
                        fask(10,"   Reference is not a Payment  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    elseif ayytpayp->paytag == 'U'
                        fask(10,"   Not Allowed to Modify Student Payments  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    endif

                    //viewacct(cacctno,cprocsts)

                    commandline("³     F10 - Save    ³       F12 - Delete        ³     ESC - Previous    ³")
                    

                    memvar->idno := ayytpayp->payidno
                    a999accp->(dbseek(memvar->idno))
                    
                    @ 06,02 say "Personal Information: "+alltrim(memvar->idno)+" - " + alltrim(a999accp->acclname) +", "+ alltrim(a999accp->accfname)+ " " +alltrim(a999accp->accmname);
                    color memvar->colorarray[02]
                     
                    //bprntscr := savescr(01,00,24,79)
                    memvar->aitemss := {_EMPTY2}
                    memvar->nindexs := 1

                    processOR()

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



static function processOR()
local nindexsss := 1

            zyytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->idno+memvar->cpayno))
            zyytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->idno+memvar->cpayno))
            
            zyytpayp->(dbgotop())
            if ! zyytpayp -> (eof())
                    do while ! zyytpayp->(eof())

                                nlastelems := len(memvar->aitemss)
                                aadd(memvar->aitemss,_EMPTY2)
                                memvar->aitemss[nlastelems,_ORNO]          := zyytpayp->payrefno
                                memvar->aitemss[nlastelems,_CODE2]         := zyytpayp->paycolcod
                                memvar->aitemss[nlastelems,_ADJCOD]        := zyytpayp->payadjcod
                                memvar->aitemss[nlastelems,_AMOUNT2]       := zyytpayp->payamt
                                memvar->aitemss[nlastelems,_DATE2]         := displaydate(zyytpayp->paydte)
                                memvar->aitemss[nlastelems,_ENTTIME]       := zyytpayp->payenttme
                                memvar->aitemss[nlastelems,_TAG]           := zyytpayp->paytag
                                memvar->aitemss[nlastelems,_BATCHNO]       := zyytpayp->paybatchno

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



function byidor_view()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,ayytpayp,idno,pclass,viewor,bindex,bitems,;
      oappren,nrec,nlastelems,cborno,nindexss,xyytpayp
private cterm,nmos,aitemss := {}, nindexs

bindex  := memvarblock("NINDEXS")
bitems  := memvarblock("AITEMSS")


viewor   := createabrowse(bitems,bindex,08,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|pOR(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitemss[memvar->nindexs,_ORNO]},nil},;
                        {{||memvar->aitemss[memvar->nindexs,_CODE2]},nil},;
                        {{||transform(memvar->aitemss[memvar->nindexs,_AMOUNT2],"999,999.99")+" "},nil},;
                        {{||" "+memvar->aitemss[memvar->nindexs,_DATE2]+" "},nil},;
                        {{||" "+memvar->aitemss[memvar->nindexs,_ENTTIME]+" "},nil}},;
                        {"O.R NO.", "   CODE   ", "  AMOUNT  ",  "  DATE ",  "  ENTTIME "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"})


if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  OR Viewing  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")

aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))


do while .t.
       
        //clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Update Payment Records V2 (By Id) ")
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
            /*if term->status == _CLOSED
                    fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                            "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
            endif*/
            @ 02,22 say term->name

            bprntscr := savescr(01,00,24,79)

            //ANg NUMBERS SA OPENWCHECK KY MO DETERMINE UNSA NGA INDEX SA SCOPE ANG GE GMIT NGA INDEX EXPRESSION
            ayytpayp := "a"+memvar->cterm+"payp"
            zyytpayp := "a"+memvar->cterm+"payp"
            xyytpayp := "a"+memvar->cterm+"payp"
            if(aprv2setup := openwcheck({{,, ayytpayp,"ayytpayp",_DBF_SHARED,,1},;
                                         {,, zyytpayp,"zyytpayp",_DBF_SHARED,,7},;
                                         {,, xyytpayp,"xyytpayp",_DBF_SHARED,,12},;
                                         {,,"a999ctrl",,_DBF_SHARED,,1},;
                                         {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"}})) == nil
                    return(nil)
            endif

            memvar->idno := space(len(a999accp->accidno))
            memvar->pclass := space(01)
            memvar->dpay  := date()
            memvar->cpayno := space(len(ayytpayp->payrefno))

        //setcursor(1);set(_SET_CONFIRM,.t.)
        do while .t.

                restscr(bprntscr)
                //commandline("?         F4 - View Account           ?          ESC - Previous              ?")
               // setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})

                

                setcursor(1);set(_SET_CONFIRM,.t.)

                @ 04,02 say "OR /Reference #: ";
                        color memvar->colorarray[02];
                        get memvar->cpayno pict "@!" valid ! empty(memvar->cpayno)

                read
                    //setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                    setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)

                    if lastkey() == K_ESC
                           
                            exit
                    endif
                    ayytpayp->(dbseek(cpayno))

                    

                    if ! ayytpayp->(dbseek(cpayno))
                        fask(10,"   Payment not yet entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    elseif  ayytpayp->paytag == 'F'
                        fask(10,"   Reference is not a payment  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                    elseif  ! ayytpayp->paytag == 'A'
                                fask(10,"   Record is not an adjustment.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop                        
                    endif

                    //viewacct(cacctno,cprocsts)

                    commandline("³     F10 - Save    ³       F12 - Delete        ³     ESC - Previous    ³")
                    

                    memvar->idno := ayytpayp->payidno
                    a999accp->(dbseek(memvar->idno))
                    
                    @ 06,02 say "Personal Information: "+alltrim(memvar->idno)+" - " + alltrim(a999accp->acclname) +", "+ alltrim(a999accp->accfname)+ " " +alltrim(a999accp->accmname);
                    color memvar->colorarray[02]
                     
                    //bprntscr := savescr(01,00,24,79)
                    memvar->aitemss := {_EMPTY2}
                    memvar->nindexs := 1

                    byIdprocessOR()

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



static function byIdprocessOR()
local nindexsss := 1

            zyytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->idno+memvar->cpayno))
            zyytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->idno+memvar->cpayno))
            
            zyytpayp->(dbgotop())
            if ! zyytpayp -> (eof())
                    do while ! zyytpayp->(eof())

                                nlastelems := len(memvar->aitemss)
                                aadd(memvar->aitemss,_EMPTY2)
                                memvar->aitemss[nlastelems,_ORNO]          := zyytpayp->payrefno
                                memvar->aitemss[nlastelems,_CODE2]         := zyytpayp->paycolcod
                                memvar->aitemss[nlastelems,_ADJCOD]        := zyytpayp->payadjcod
                                memvar->aitemss[nlastelems,_AMOUNT2]       := zyytpayp->payamt
                                memvar->aitemss[nlastelems,_DATE2]         := displaydate(zyytpayp->paydte)
                                memvar->aitemss[nlastelems,_ENTTIME]       := zyytpayp->payenttme
                                memvar->aitemss[nlastelems,_TAG]           := zyytpayp->paytag
                                memvar->aitemss[nlastelems,_BATCHNO]       := zyytpayp->paybatchno

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

static function pOR(nmode,oabrowser,axparam)
local nexit, indicator, temp_date := date()
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_ENTER
                editor(oabrowser)

        /*case lastkey() == K_F6

                viewPaymentInfo(memvar->idno, memvar->aitemss[memvar->nindexs,_ORNO],memvar->aitemss[memvar->nindexs,_CODE2], memvar->aitemss[memvar->nindexs,_ADJCOD],memvar->aitemss[memvar->nindexs,_AMOUNT2], memvar->aitemss[memvar->nindexs,_DATE2],memvar->aitemss[memvar->nindexs,_ENTTIME], memvar->aitemss[memvar->nindexs,_TAG], memvar->aitemss[memvar->nindexs,_BATCHNO])
        */

        case lastkey() == K_F12

            if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                if rights("[RESTRICT]")
                    if CTOD(memvar->aitemss[nindexs,_DATE2]) == temp_date
                        if fask(13,"  Do you want to delete entries ?, with CODE->"+alltrim(memvar->aitemss[memvar->nindexs,_CODE2])+" and ;"+;
                        " AMOUNT OF "+alltrim(str(memvar->aitemss[memvar->nindexs,_AMOUNT2]))+"  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                            
                            if xyytpayp->(dbseek(memvar->idno+memvar->aitemss[memvar->nindexs,_ORNO]+memvar->aitemss[memvar->nindexs,_ENTTIME]))
                                fask(13,"  Items deleted.  ",{" Ok "},memvar->colorarray[05])
                                xyytpayp->(reclock())
                                xyytpayp->payrefno := _DELETE_TAG
                                xyytpayp->payentusr := substr(memvar->cusername,1,8)
                                xyytpayp->(dbdelete())
                                xyytpayp->(dbcommit())
                                xyytpayp->(dbunlock())
                                
                            __keyboard(chr(K_ESC))   
                            endif  
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
            
            
            clearbuffer()
        case lastkey() == K_F10
            if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                if rights("[RESTRICT]")

                        if fask(13,"  Do you want to save entries ?, with CODE->"+alltrim(memvar->aitemss[memvar->nindexs,_CODE2])+" and ;"+;
                            " AMOUNT OF "+alltrim(str(memvar->aitemss[memvar->nindexs,_AMOUNT2]))+"  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                                    
                                    if xyytpayp->(dbseek(memvar->idno+memvar->aitemss[memvar->nindexs,_ORNO]+memvar->aitemss[memvar->nindexs,_ENTTIME]))

                                        fask(13,"  Items saved.  ",{" Ok "},memvar->colorarray[05])

                                        xyytpayp->(reclock())
                                        xyytpayp->paycolcod     := memvar->aitemss[memvar->nindexs,_CODE2]
                                        xyytpayp->payamt        := memvar->aitemss[memvar->nindexs,_AMOUNT2]
                                        xyytpayp->payupddte     := date()
                                        xyytpayp->payentusr     := substr(memvar->cusername,1,8)

                                    endif
                                    xyytpayp->(dbcommit())
                                    xyytpayp->(dbunlock())
                        endif
                else
                    else
                    fask(10,"   You have no right to modify record.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                endif
            else
                fask(10,"   Transaction is already closed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
            endif
            clearbuffer()

endcase
return 2


static function editor(oabrowser)
local getlist:={},nrec,acmdline:=savescr(24,00,24,79),acmddetail,;
      nlastcursor:=setcursor(),lconfirm:=set(_SET_CONFIRM),;
      nlastrec:=len(memvar->aitemss),nrow:=row(),;
      ccode,amount,adjcod
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
commandline("³                               ESC - Previous                                 ³")
acmddetail      := savescr(24,00,24,79)
ccode           := memvar->aitemss[memvar->nindexs,_CODE2]
amount          := memvar->aitemss[memvar->nindexs,_AMOUNT2]
//adjcod          := memvar->aitemss[memvar->nindexs,_ADJCOD]

do while .t.
        restscr(acmddetail)
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,21 get ccode      
        @ nrow,32 get amount     pict "999,999.99"
        @ nrow,43 get adjcod     
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
        if lastkey() == K_ENTER
                memvar->aitemss[memvar->nindexs,_CODE2]   := ccode
                memvar->aitemss[memvar->nindexs,_AMOUNT2] := amount
                //memvar->aitemss[memvar->nindexs,_ADJCOD] := adjcod
                __keyboard(chr(K_DOWN))
                exit
        endif
enddo
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
restscr(acmdline)
return(nil)

static function recordor(indicator)
local alastscr:=savescr(01,00,24,79),nctr,nmax
nmax := len(memvar->aitemss)
//nctr := 0
//for nctr := 1 to len(memvar->aitemss)  
        
        fask(13,"  Can't save.  No items entered.  "+alltrim(str(indicator))+" "+memvar->idno+" "+memvar->aitemss[indicator,_ORNO]+" "+ayytpayp->paycolcod+" "+memvar->aitemss[indicator,_ENTTIME],{" Ok "},memvar->colorarray[05]) 

        if xyytpayp->(dbseek(memvar->idno+memvar->aitemss[indicator,_ORNO]+ayytpayp->paycolcod+memvar->aitemss[indicator,_ENTTIME]))
            
                xyytpayp->(reclock())
                xyytpayp->paycolcod     := memvar->aitemss[indicator,_CODE2]
                xyytpayp->payamt        := memvar->aitemss[indicator,_AMOUNT2]
                xyytpayp->payupddte     := date()

                
        endif
        xyytpayp->(dbcommit())
        xyytpayp->(dbunlock())
              
//next
restscr(alastscr)
return(0)

static function deleteor()
local alastscr:=savescr(01,00,24,79),nctr,nmax
nmax := len(memvar->aitemss)
nctr := 0
for nctr := 1 to nmax
        
         if xyytpayp->(dbseek(memvar->idno+memvar->aitemss[nindexs,_ORNO]+ayytpayp->paycolcod+memvar->aitemss[nindexs,_ENTTIME]))

                xyytpayp->payrefno := _DELETE_TAG
                xyytpayp->(dbdelete())
                xyytpayp->(dbcommit())
                xyytpayp->(dbunlock())

                    **account master file**
                a999accp->(dbseek(memvar->idno))
                a999accp->(reclock())
                a999accp->accamtpd  -= memvar->aitemss[nindexs,_AMOUNT2]
                a999accp->accbaltot += memvar->aitemss[nindexs,_AMOUNT2]
                a999accp->(dbcommit())
                a999accp->(dbunlock())
                __keyboard(chr(K_ESC))
        endif
       
       
next
restscr(alastscr)
return(0)
*-------------------------------------------------------------------------------

static function viewPaymentInfo(idno, refno, colcod, adjcod,amt, dte, enttime, tag, batchno)
local alastscr:=savescr(01,00,24,79),nlastcursor := setcursor(),lconfirm := set(_SET_CONFIRM)

//01,00,23,79
boxshadow(05,02,20,70,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Payment Information  ")
//boxshadow(08,05,20,70,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Payment Information  ")
commandline("³                               ESC - Previous                                 ³")
//fask(13,"  TEST.  "+alltrim(idno)+" "+ alltrim(orno)+" "+alltrim(enttime)+" ",{" Ok "},memvar->colorarray[05])

do while .t.
        
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 10,19 say "Account No.       ->";
                color memvar->colorarray[02];
                get idno      pict "@!";
                valid ! empty(idno)
        @ 11,19 say "Ref. No.          ->";
                color memvar->colorarray[02];
                get refno      pict "@!"
        @ 12,19 say "Pay Code          ->";
                color memvar->colorarray[02];
                get colcod      pict "@!"
        @ 13,19 say "Adjustment Code   ->";
                color memvar->colorarray[02];
                get adjcod        pict "@!";
                
        @ 14,19 say "Amount            ->";
                color memvar->colorarray[02];
                get amt   pict "999,999.99"
        @ 15,19 say "Pay Tag            ->";
                color memvar->colorarray[02];
                get tag   pict "@!"
        @ 16,19 say "Batch No.(For Training) ->";
                color memvar->colorarray[02];
                get batchno   pict "@!"
                
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif


        if ! fask(20,"   Save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                exit
        endif

        fask(13,"  Save Successfully.  ",{" Ok "},memvar->colorarray[05])
        //exit
enddo


restscr(alastscr)
return(nil)
