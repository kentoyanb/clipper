* Program       :  ACCTREP.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) October 1998
* Last update   :  Abundio C. Navarro and Jun Benlot (c) January 2000
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
#define _REFNO          1
#define _DATE           2
#define _DEBIT          3
#define _CREDIT         4
#define _BALANCE        5
#define _USERID         6
#define _REMARKS        7
#define _REFNO1         8
#define _EMPTY          {space(08),;
                         space(10),;
                         0,0,0,;
                         space(08),;
                         space(07),;
                         space(08)}

#define _CODE           1
#define _SUBJECT        2
#define _TYPE           3
#define _UNIT           4
#define _EMPTY_1        {space(05),space(12),space(03),0}
*-------------------------------------------------------------------------------
function acctinfo()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,aentryscr,lexist,cprocsts,oacct,bindex,bitems,;
      ayytpayp,ayytassp,ayytprsp,cyytenrp,cyytskdp
private aitems:={},nindex,cterm,cdesc,cacctno,ntotamt,;
        cname,ccourse,cyear,cpbpr,cpriv,cfeeyr,cenroll,nunits,nfeeunit,;
        ntassess,noaccts,nadjust,nadisc,crdisc,ntdue,ntamtpd,ntbal,;
        aitemss := {}, nindexs := 1,ntotunit := 0

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
oacct   := createabrowse(bitems,bindex,13,03,22,76,;
                        {|xnmode,xoabrowser,xaxparam|facct(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitems[memvar->nindex,_REFNO]},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_DATE]+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_DEBIT],"@Z 99,999,999.99")+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_CREDIT],"@Z 99,999,999.99")+" "},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_BALANCE],"999,999.99")+" "},nil},;
                         {{||memvar->aitems[memvar->nindex,_USERID]},nil},;
                         {{||memvar->aitems[memvar->nindex,_REMARKS]},nil}},;
                        {"Ref. No.", "   Date   ", "   Debit  ", "  Credit  ", "  Balance ", "User id ", "Remarks"},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³","³"},;
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
        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"assp.dbf")
                fask(10,"  A"+memvar->cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"prsp.dbf")
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
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"blocklst",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                   {,,ayytprsp,"ayytprsp",_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1}}))==nil
                return(nil)
        endif
        memvar->cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View Account           ³           ESC - Previous              ³")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Account Number . . :";
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
                memvar->cname           := alltrim(a999accp->acclname)+",  "+alltrim(a999accp->accfname)+"  "+a999accp->accmname+"."
                *memvar->ccourse         := c999colp->coldesabr
                memvar->cyear           := a999accp->accyrlevl

                if alltrim(a999accp->accpbcprv) == "1"
                   memvar->cpbpr = "Public"
                elseif alltrim(a999accp->accpbcprv) == "2"
                   memvar->cpbpr = "Private w/ ESC"
                elseif alltrim(a999accp->accpbcprv) == "3"
                   memvar->cpbpr = "Private w/o ESC"
                else
                   memvar->cpbpr = ""
                end
               * memvar->cpbpr           := a999accp->accpbcprv
                memvar->cenroll         := a999accp->accsyt
                memvar->nunits          := a999accp->accsytunt
                memvar->cfeeyr          := a999accp->accfeeyr
                memvar->nfeeunit        := a999accp->accfeeunt
                memvar->ntassess        := a999accp->accsytass
                memvar->noaccts         := a999accp->accbalold
                memvar->nadjust         := a999accp->accadj
                memvar->ntdue           := a999accp->accduetot
                memvar->ntamtpd         := a999accp->accamtpd
                memvar->ntbal           := a999accp->accbaltot
                memvar->cpriv           := a999accp->acccode
                *memvar->nadisc          := a999accp->accsytadsc
                memvar->nadisc          := 0
                memvar->crdisc          := " "
                if ! empty(a999accp->acccode)
                        if ! left(a999accp->acccode,1) == "X"
                                memvar->nadisc  := a999accp->accsytadsc
                                if a999accp->accsytpdsc == 0
                                        memvar->crdisc := "FF"
                                else
                                        memvar->crdisc := transform(a999accp->accsytpdsc*100,"999")+"%"
                                endif
                        endif
                endif
/*
                if ayytprsp->(dbseek(memvar->cacctno))
                        if ! substr(ayytprsp->prscode,1,1) == "X"
                                memvar->crdisc := if(ayytprsp->prstag == _FULL_FREE,"FF",transform(ayytprsp->prstuipdsc*100,"999")+"%")
                                memvar->nadisc := ayytprsp->prstuiadsc
                        else
                                memvar->crdisc := space(04)
                                memvar->nadisc := 0
                        endif
                        *memvar->cpriv   := ayytprsp->prscode
                else
                        memvar->crdisc  := space(04)
                        memvar->cpriv   := space(06)
                        memvar->nadisc  := 0
                endif
*/
                memvar->aitems := {_EMPTY}
                memvar->nindex := 1
                processtrans()
                dspdata()
                dispbox(12,02,22,77,_SINGLE_LINE)
                connectline(14,02,77)
*                commandline("³   F6 - Subject   ³    F9 - Post    ³    F10 - Print    ³    ESC - Previous   ³")
                commandline("³ F6 - Subject ³ F8 - Clearance ³   F9 - Post  ³  F10 - Print ³ ESC - Previous ³")
                stabilize(oacct,.t.)
                browsearray(oacct,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function facct(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0 .and. rights("[BEWARE]")
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
static function processtrans()
local nlastelem,nctr
memvar->ntotamt := 0
if ayytassp->(dbseek(memvar->cacctno))
        aadd(memvar->aitems,_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_REFNO]        := "ASSMNT  "
        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytassp->assenrdte)
        memvar->aitems[nlastelem,_DEBIT]        := ayytassp->asstotal
        memvar->aitems[nlastelem,_BALANCE]      := ayytassp->asstotal
        memvar->aitems[nlastelem,_USERID]       := substr(ayytassp->asscusrid,1,8)
        memvar->aitems[nlastelem,_REMARKS]      := if(ayytassp->asstag == "C","Changed",;
                                                   if(ayytassp->asstag == "U","Posted ","       "))
        memvar->ntotamt                         := ayytassp->asstotal
/*
else
        aadd(memvar->aitems,_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_REFNO]        := "ASSMNT  "
        memvar->aitems[nlastelem,_DATE]         := "**********"
        memvar->aitems[nlastelem,_USERID]       := "********"
        memvar->aitems[nlastelem,_REMARKS]      := "Pending"
*/
endif

ayytpayp->(sx_setscope(_TOP_SCOPE   ,memvar->cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,memvar->cacctno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(13,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ayytpayp->paytag = _PAYMENT
                        aadd(memvar->aitems,_EMPTY)
                        nlastelem := len(memvar->aitems)
                        *memvar->ntotamt -= ayytpayp->payamt
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payrefno
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "       "
                case ayytpayp->paytag = _POSTED
                        aadd(memvar->aitems,_EMPTY)
                        nlastelem := len(memvar->aitems)
                        memvar->ntotamt -= ayytpayp->payamt
                        memvar->aitems[nlastelem,_REFNO]        := ayytpayp->payrefno
                        memvar->aitems[nlastelem,_DATE]         := displaydate(ayytpayp->paydte)
                        memvar->aitems[nlastelem,_CREDIT]       := ayytpayp->payamt
                        memvar->aitems[nlastelem,_BALANCE]      := memvar->ntotamt
                        memvar->aitems[nlastelem,_USERID]       := ayytpayp->payentusr
                        memvar->aitems[nlastelem,_REMARKS]      := "Posted "
                case ayytpayp->paytag $ _ADJUSTMENT+_FORWARDED
                        aadd(memvar->aitems,_EMPTY)
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
                        aadd(memvar->aitems,_EMPTY)
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
                        aadd(memvar->aitems,_EMPTY)
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
@ 29,50 say "ENena T. Duran"
@ 30,50 say "Head - SAS Dept."
@ 34,05 say "UC-METC/SAC.DOC./013/REV.0"

*__eject()
@ 41,01 say space(01)
setprc(06,19)

*__eject()
restscr(arepscr)
return(nil)

*-----------------------------------------------------------------------------*
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
@ 18,02 say "Discounts       : " +transform(memvar->nadisc,"999,999.99")+" "+memvar->crdisc
@ 18,36 say "Category         : "+memvar->cpbpr

@ 21,00 say "  Ref#      Date       Debit      Credit   Balance    UserId  Remarks"
@ 22,00 say "-------- ---------- ---------- ---------- ---------- -------- -------"

for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing Ref. No. "+alltrim(memvar->aitems[nctr,_REFNO])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say memvar->aitems[nctr,_REFNO]+" "+;
                           memvar->aitems[nctr,_DATE]+" "+;
                           transform(memvar->aitems[nctr,_DEBIT],"@Z 99,999,999.99")+" "+;
                           transform(memvar->aitems[nctr,_CREDIT],"@Z 99,999,999.99")+" "+;
                           transform(memvar->aitems[nctr,_BALANCE]," 99,999,999.99")+" "+;
                           memvar->aitems[nctr,_USERID]+" "+;
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
@ 08,02 say "                         "+transform(memvar->ntassess,"99,999,999.99")
@ 08,02 say "Total Assessment . . . : " color memvar->colorarray[02]
@ 09,02 say "                         "+transform(memvar->noaccts,"99,999,999.99")
@ 09,02 say "Old Accounts . . . . . : " color memvar->colorarray[02]
@ 10,02 say "                         "+transform(memvar->nadjust,"99,999,999.99")
@ 10,02 say "Adjustments  . . . . . : " color memvar->colorarray[02]
@ 11,02 say "                         "+transform(memvar->nadisc,"99,999,999.99")+" "+memvar->crdisc
@ 11,02 say "Discounts  . . . . . . : " color memvar->colorarray[02]
@ 08,43 say "                        "+transform(memvar->ntdue,"999,999.99")
@ 08,43 say "Total Due . . . . . . : " color memvar->colorarray[02]
@ 09,43 say "                        "+transform(memvar->ntamtpd,"999,999.99")
@ 09,43 say "Total Amount Paid . . : " color memvar->colorarray[02]
@ 10,43 say "Total Balance . . . . : "+transform(memvar->ntbal,"999,999.99") color memvar->colorarray[04]
@ 11,43 say "                   "+memvar->cpbpr
@ 11,43 say "Category . . . . : " color memvar->colorarray[02]
@ 23,02 say "Reference ->" color memvar->colorarray[02]
return(nil)

*-----------------------------------------------------------------------------*
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
                {{{||" "+memvar->aitemss[memvar->nindexs,_CODE]+" "},nil},;
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
                                memvar->aitemss[nlastelem,_CODE]    := cyytenrp->&skdno
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
                if empty(memvar->aitemss[nctr,_CODE])
                        adel(memvar->aitemss,nctr)
                        asize(memvar->aitemss,len(memvar->aitemss)-1)
                endif
        next
endif
return(nil)

*------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------*
#define _E_SKDNO          1
#define _E_SUBJECT        2
#define _E_TIME           3
#define _E_DAYS           4
#define _E_ROOM           5
#define _E_UNITS          6
#define _E_REMARKS        7
#define _E_EMPTY        {space(08),;
                         space(16),;
                         space(14),;
                         space(04),;
                         space(04),;
                         space(05),;
                         space(11)}
function dispenrol()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup
private aitems := {},nindex := 1,ntotunits := 0,;
        cidno,clname,cfname,cmname,ccourse,nyrlevel,cterm,cdesc,ctdesc

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ostudy  := createabrowse(bitems,bindex,08,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fstudy(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_E_SKDNO]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_E_SUBJECT]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_E_TIME]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_E_DAYS]+" "},nil},;
                         {{||memvar->aitems[memvar->nindex,_E_ROOM]},nil},;
                         {{||memvar->aitems[memvar->nindex,_E_UNITS]+" "},nil},;
                         {{||memvar->aitems[memvar->nindex,_E_REMARKS]},nil}},;
                        {"  Skd No. ", "      Subject     ", "     Time       ", " Days ", "Room", "Units", "  Remarks  "},;
                        {"ÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ"})
*                         x12-12345x    x123456789012x345x    x12345-12345x12x    x1234x    1234    12.1x    12345678901

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Enrollment Record  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
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
        @ 02,20 say "- "+term->name
        memvar->ctdesc := term->name
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := "c"+memvar->cterm+"enrp"
        cyytskdp        := "c"+memvar->cterm+"skdp"
        cyytflag        := "c"+memvar->cterm+"flag"
        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                    {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                                    {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                    {,,"c999prsp",,_DBF_SHARED,,1,"/crunlib"},;
                                    {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                    {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        memvar->cidno := space(len(c999sm1p->sm1idno))
        do while .t.
                memvar->clname          := space(len(c999sm1p->sm1lstnam))
                memvar->cfname          := space(len(c999sm1p->sm1fstnam))
                memvar->cmname          := space(len(c999sm1p->sm1midnam))
                memvar->ccourse         := space(len(c999sm1p->sm1colcod))
                memvar->nyrlevel        := 0
                memvar->aitems          := {_E_EMPTY}
                memvar->nindex          := 1
                memvar->ntotunits       := 0
                restscr(aentryscr)
                commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno       pict "@!";
                        valid ! empty(memvar->cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(memvar->cidno)) .and.;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytenrp->(dbseek(memvar->cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                elseif !c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytenrp->(dbseek(memvar->cidno))
                                fask(10,"   Student not yet enrolled.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midnam
                memvar->ccourse         := cyytenrp->enrcolcod
                memvar->nyrlevel        := val(cyytenrp->enryrlevl)
                *memvar->ccourse         := c999sm1p->sm1colcod
                *memvar->nyrlevel        := c999sm1p->sm1yrlevl
                c999colp->(dbseek(memvar->ccourse))
                memvar->cdesc           := c999colp->coldesabr
                procenrolment()
                @ 04,02 say "              "+memvar->clname
                @ 04,02 say "Last Name   : " color memvar->colorarray[02]
                @ 05,02 say "              "+memvar->cfname
                @ 05,02 say "First Name  : " color memvar->colorarray[02]
                @ 06,02 say "              "+memvar->cmname
                @ 06,02 say "Middle Init.: " color memvar->colorarray[02]
                @ 04,47 say "               "+memvar->ccourse+" - "+memvar->cdesc
                @ 04,47 say "Course/Major : " color memvar->colorarray[02]
                @ 05,47 say "               "+transform(memvar->nyrlevel,"9")+;
                        if(memvar->nyrlevel == 1," - First Year",;
                        if(memvar->nyrlevel == 2," - Second Year",;
                        if(memvar->nyrlevel == 3," - Third Year",;
                        if(memvar->nyrlevel == 4," - Fourth Year"," - Fifth Year"))))
                @ 05,47 say "Year Level   : " color memvar->colorarray[02]
                @ 06,47 say "               "+displaydate(cyytenrp->enrdte)
                @ 06,47 say "Date Enrolled: " color memvar->colorarray[02]
                @ 22,02 say "      "+displaydate(date())
                @ 22,02 say "Date: " color memvar->colorarray[02]
                @ 22,55 say "                "+transform(memvar->ntotunits,"999.9")
                @ 22,55 say "Total Units =>  " color memvar->colorarray[02]
                dispbox(07,01,21,78,_SINGLE_LINE)
                connectline(09,01,78)
                commandline("³                               ESC - Previous                                 ³")
                stabilize(ostudy,.t.)
                browsearray(ostudy,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fstudy(nmode,oabrowser,axparam)
local nexit
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


static function procenrolment()
local nlastelem,nctr,cskdcode,nctr1,lfound:=.f.
for nctr := 1 to 16
        lfound := .f.
        cskdcode := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&cskdcode == "00000"
                if cyytskdp->(dbseek(cyytenrp->&cskdcode))
                        aadd(memvar->aitems,_E_EMPTY)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_E_SKDNO]        := cyytskdp->skdcolcod+"-"+cyytenrp->&cskdcode
                        memvar->aitems[nlastelem,_E_SUBJECT]      := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        memvar->aitems[nlastelem,_E_TIME]         := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn
                        memvar->aitems[nlastelem,_E_DAYS]         := cyytskdp->skdday
                        memvar->aitems[nlastelem,_E_ROOM]         := cyytskdp->skdrom
                        memvar->aitems[nlastelem,_E_UNITS]        := if(cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC","  - ",str(cyytskdp->skdunt,4,1))
                        if cyytskdp->skdrescod == "4"
                                memvar->aitems[nlastelem,_E_REMARKS] := "Dissolved "
                        endif
                        if ! cyytskdp->skdsplcod == "C"
                                memvar->ntotunits += cyytskdp->skdunt
                        elseif cyytskdp->skdsplcod == "C" .and. !cyytskdp->skdsubtyp == "LEC"
                                memvar->ntotunits += cyytskdp->skdunt
                        endif
                endif
        else
                exit
        endif
next
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_E_SKDNO])
                        adel(memvar->aitems,memvar->nindex)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)

*-------------------------------------------------------------------------------

#define _A_TERM         1
#define _A_COURSE       2
#define _A_FEE_YEAR     3
#define _A_ASSESSMENT   4
#define _A_OLD_ACCOUNT  5
#define _A_ADJUSTMENT   6
#define _A_DISCOUNT     7
#define _A_TOTAL_DUE    8
#define _A_AMOUNT_PAID  9
#define _A_BALANCE      10
#define _A_EMPTY        {space(5),space(8),space(2),0,0,0,0,0,0,0}

function acctsummary()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,cprocsts,oacct,bindex,bitems,aentryscr,;
      cacctno
private aitems := {}, nindex := 1

bindex := memvarblock("NINDEX")
bitems := memvarblock("AITEMS")
oacct  := createabrowse(bitems,bindex,08,04,20,75,;
                        {|xnmode,xoabrowser,xaxparam|facctsumm(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_A_TERM]+" "},nil},;
                         {{||memvar->aitems[memvar->nindex,_A_COURSE]},nil},;
                         {{||memvar->aitems[memvar->nindex,_A_FEE_YEAR]},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_A_ASSESSMENT],'999,999.99')},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_A_OLD_ACCOUNT],'999,999.99')},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_A_ADJUSTMENT],'999,999.99')},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_A_DISCOUNT],'999,999.99')},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_A_TOTAL_DUE],'999,999.99')},nil}},;
                        {"Term ", " Course ", "FY", "Assessment", " Old Acct ", "Adjustment", " Discount ", "Total Due "},;
                        {"ÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ"})
*                         x123x    12345678    12    123,123.12    123,123.12    123,123.12    123,123.12    123,123.12

if(aopenfiles := openwcheck({{,,"a999amlp",,_DBF_SHARED,,1},;
                             {,,"a999accp",,_DBF_SHARED,,1},;
                             {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Account Summary  ")
commandline("³         F4 - View Account File       ³           ESC - Previous              ³")
aentryscr := savescr(01,00,24,79)
cacctno   := space(len(a999amlp->amlidno))
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Account Number :";
                color memvar->colorarray[02];
                get cacctno pict "@!";
                valid ! empty(cacctno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! a999accp->(dbseek(cacctno))
                fask(10,"  Students account not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        procsummary()
        @ 03,02 say "                 "+a999accp->acclname
        @ 03,02 say "Last Name      : " color memvar->colorarray[02]
        @ 04,02 say "                 "+a999accp->accfname
        @ 04,02 say "First Name     : " color memvar->colorarray[02]
        @ 05,02 say "                 "+a999accp->accmname
        @ 05,02 say "Middle Initial : " color memvar->colorarray[02]
        dispbox(07,03,20,76,_SINGLE_LINE)
        connectline(09,03,76)
        commandline("³                               ESC - Previous                                 ³")
        stabilize(oacct,.t.)
        browsearray(oacct,{""},{|b|b:gotop()})
enddo
restscr(alastscr)
closewcheck(aopenfiles)
return(nil)


static function facctsumm(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 21,04 say "              "+transform(memvar->aitems[memvar->nindex,_A_AMOUNT_PAID],"999,999.99")
                @ 21,04 say "Amount Paid : " color memvar->colorarray[02]
                @ 22,04 say "              "+transform(memvar->aitems[memvar->nindex,_A_BALANCE],"999,999.99")
                @ 22,04 say "Balance     : " color memvar->colorarray[02]
                return 1
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function procsummary()
local nlastelem, nctr
a999amlp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
a999amlp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
a999amlp->(dbgotop())
do while ! a999amlp->(eof())
        fask(13,"  Processing school term "+a999amlp->amlsyt+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(a999amlp->amlcolcod))
        aadd(memvar->aitems,_A_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_A_TERM]               := a999amlp->amlsyt
        memvar->aitems[nlastelem,_A_COURSE]             := c999colp->coldesabr+" "+a999amlp->amlyrlevl
        memvar->aitems[nlastelem,_A_FEE_YEAR]           := a999amlp->amlfeeyr
        memvar->aitems[nlastelem,_A_ASSESSMENT]         := a999amlp->amlsytass
        memvar->aitems[nlastelem,_A_OLD_ACCOUNT]        := a999amlp->amlbalold
        memvar->aitems[nlastelem,_A_ADJUSTMENT]         := a999amlp->amladj
        memvar->aitems[nlastelem,_A_DISCOUNT]           := a999amlp->amlsytadsc
        memvar->aitems[nlastelem,_A_TOTAL_DUE]          := a999amlp->amlduetot
        memvar->aitems[nlastelem,_A_AMOUNT_PAID]        := a999amlp->amlamtpd
        memvar->aitems[nlastelem,_A_BALANCE]            := a999amlp->amlbaltot
        a999amlp->(dbskip())
enddo
a999amlp->(clearscope())
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_A_TERM])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)

*------------------------------------------------------------------------------*

function studbalance()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,cprocsts,ccolcode:="AL",aentryscr

if(aopenfiles := openwcheck({{,,"a999accp",,_DBF_SHARED,,4},;
                             {,,"a999stcp",,_DBF_SHARED,,1},;
                             {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Student Balances  ")
commandline("³          F4 - View College           ³          ESC - Previous               ³")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
  //      @ 02,22 say "[AC-All Courses / SC-Special Courses]"
        @ 02,02 say "College Code :";
                get ccolcode pict "@!";
                valid ! empty(ccolcode)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! ccolcode $ "ACSC" .and. ! c999colp->(dbseek(ccolcode))
                fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if whereprint({||pstudbal(ccolcode)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
enddo
restscr(alastscr)
closewcheck(aopenfiles)
return(nil)

function pstudbal(ccolcode)
local abtext := {}, ncol, nmaxcol := 80, npage := 0, ccourse := space(06)

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("STUDENTS' BALANCES REPORT",nmaxcol))+"STUDENTS' BALANCES REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"  ID No.     Last Name          First Name         M  Course  SYT    Balance   "})
aadd(abtext,{||"--------- --------------- ------------------------ - -------- --- -------------"})

/*
  ID No.     Last Name          First Name         M  Course  SYT    Balance
--------- --------------- ------------------------ - -------- --- -------------
123456789 123456789012345 123456789012345678901234 1 123456 1 123 12,123,123.12

*/

pageprint(abtext)

if ccolcode == "AL"
        a999accp->(sx_settagorder(2))
else
        a999accp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        a999accp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif
/*
if ccolcode $ "ACSC"
        a999accp->(sx_settagorder(2))
else
        a999accp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        a999accp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif

                if a999accp->acccolcod $ "MTMIMSPAMAMRMDMEMPRO"
                if val(a999accp->acccolcod) > 51 .and. val(a999accp->acccolcod) < 100
*/
a999accp->(dbgotop())
do while ! a999accp->(eof())
        fask(10,"  Processing student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+alltrim(a999accp->accmname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! alltrim(str(a999accp->accbaltot,11,2)) == "0.00"
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                if c999colp->(dbseek(a999accp->acccolcod))
                        ccourse := c999colp->coldesabr
                elseif a999stcp->(dbseek(a999accp->acccolcod))
                        ccourse := a999stcp->stcdesabr
                endif
                @ prow()+01,00 say a999accp->accidno+" "+;
                                   a999accp->acclname+" "+;
                                   a999accp->accfname+" "+;
                                   a999accp->accmname+" "+;
                                   ccourse+" "+a999accp->accyrlevl+" "+;
                                   substr(a999accp->accsyt,1,3)+" "+;
                                   transform(a999accp->accbaltot,"@Z 99,999,999.99")
                ccourse := space(06)
        endif
        if nextkey() == K_ESC
                exit
        endif
        a999accp->(dbskip())
enddo
a999accp->(clearscope())
a999accp->(sx_settagorder(4))
return(nil)

*------------------------------------------------------------------------------*

function studacct()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,aentryscr,cprocsts,aopen1files,cnotedby:=cdesgn:=space(35)
private cterm,cdesc,cidno,cto

if(aopenfiles := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                             {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                             {,,"a999feep",,_DBF_SHARED,,1},;
                             {,,"a999accp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Students Bill  ")
        commandline("³      F4 - View Term/Account File     ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
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
        cdesc := term->name
        @ 02,19 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        memvar->cidno := space(len(a999accp->accidno))
        memvar->cto   := space(35)
//        cnotedby := "MR. BARTOLOME T. POZON            "
//        cdesgn   := "Campus Administrative Director    "
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno pict "@!";
                        valid ! empty(memvar->cidno)
                @ 05,02 say "        To  :";
                        color memvar->colorarray[02];
                        get memvar->cto pict "@!"

//               @ 06,02 say "  Noted by  :";
//                        color memvar->colorarray[02];
//                        get cnotedby pict "@!"
//                @ 07,02 say "Designation :";
//                        color memvar->colorarray[02];
//                        get cdesgn pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(cidno))
                        fask(10,"  Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pstudbill(cnotedby,cdesgn)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
enddo
restscr(alastscr)
closewcheck(aopenfiles)
return(nil)


static function pstudbill(cnotedby,cdesgn)
c999colp->(dbseek(a999accp->acccolcod))
/*
@ 01,20 say "E          UNIVERSITY OF CEBU        "
@ 02,20 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 03,20 say "     Alumnos, Mambaling, Cebu City    "
@ 04,20 say "        Telephone No.: 261-9963       "
*/
@ 08,05 say "Date: "+cmonth(date())+str(day(date()))+","+str(year(date()))
@ 11,05 say "To  : "+cto

@ 14,05 say "ESir / Madam :"

@ 16,05 say "This is to certify that "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". is enrolled"
@ 17,05 say "in this institution for this "+if(right(cterm,1)=="4",substr(cdesc,1,6),substr(cdesc,1,12))+" of school year "+if(right(cterm,1)=="4",substr(cdesc,8,4),substr(cdesc,14,9))
@ 18,05 say "as "+if(a999accp->accyrlevl == "1","first year ",;
                  if(a999accp->accyrlevl == "2","second year ",;
                  if(a999accp->accyrlevl == "3","third year ",;
                  if(a999accp->accyrlevl == "4","fourth year ","fifth year "))))+"of "+alltrim(c999colp->coldesful)+"."
//                          feeyr+colcod+term

//if ! a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+transform(a999accp->accyrlevl,"9")))

if ! a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+right(cterm,1)))
        fask(10,"  Error.... Pls check for Fee Yr., College Code and Year Level",{" Ok "},memvar->colorarray[05],.t.,nil)
endif
@ 21,05 say "EBelow is his/her STATEMENT OF ACCOUNTS to wit:"

@ 23,10 say "Tuition . . . . . . . . . . . . . . . . .  P "+transform(a999accp->accsyttui,"999,999.99")
@ 24,10 say "Laboratory. . . . . . . . . . . . . . . .    "+transform(a999accp->accsytlab,"999,999.99")
@ 25,10 say "Registration. . . . . . . . . . . . . . .    "+transform(a999accp->accsytoth,"999,999.99")
//@ 26,10 say "Miscellaneous . . . . . . . . . . . . . .    "+transform(a999accp->accsytmisc,"999,999.99")
@ 26,10 say "Miscellaneous"
  @ 27,14 say "Library . . . . . . . . . . ."+transform(a999feep->feelibr,"9,999.99")
  @ 28,14 say "Medical and Dental. . . . . ."+transform(a999feep->feemed+a999feep->feeden,"9,999.99")
  @ 29,14 say "Athletics . . . . . . . . . ."+transform(a999feep->feeath+a999feep->feeprisaa,"9,999.99")
  @ 30,14 say "Guidance  . . . . . . . . . ."+transform(a999feep->feeguid+a999feep->feetest,"9,999.99")
//  @ 31,14 say "Audio-Visual. . . . . . . . ."+transform(a999feep->feeaudvis,"9,999.99")
  @ 31,14 say "Exam Supplies & Printing. . ."+transform(a999feep->feeother1,"9,999.99")
//  @ 33,14 say "Student Development . . . . ."+transform(a999feep->feestuddev,"9,999.99")
//  @ 34,14 say "Cultural. . . . . . . . . . ."+transform(a999feep->feeculturl,"9,999.99")
  @ 32,14 say "Publication . . . . . . . . ."+transform(a999feep->feeother3,"9,999.99")
  @ 33,14 say "Student Welfare . . . . . . ."+transform(a999feep->feestudwel,"9,999.99")
//  @ 35,14 say "Research & Devt.. . . . . . ."+transform(a999feep->feeresdevt,"9,999.99")
//  @ 36,14 say "Human Resource Development. ."+transform(a999feep->feeother2,"9,999.99")
//  @ 38,14 say "Modernization/upgrading . . ."+transform(a999feep->feeupgrade,"9,999.99")+"      "+transform(a999feep->a999accp->accsytmisc,"9,999.99")
@ 39,10 say "Other Fees / Adjustment . . . . . . . . .    "+transform(a999accp->accadj,"999,999.99")
@ 40,10 say "Total Fee . . . . . . . . . . . . . . . .    "+transform(a999accp->accduetot,"999,999.99")

@ 42,10 say "ETOTAL SCHOOL OBLIGATION . . . . . . . . .=P= "+transform(a999accp->accduetot,"999,999.99")+chr(18)
@ 43,10 say "E                                         =============="

@ 45,05 say "Please facilitate your payment thru:"

@ 47,05 say "University of Cebu"
@ 48,05 say "Banco De Oro"
@ 49,05 say "Elizabeth Mall Branch"
@ 50,05 say "Cebu City"
@ 51,05 say "Peso   SA # 1850000024"
@ 52,05 say "Dollar SA # 1850000032"

@ 53,05 say "Note: Please fax your deposit slip at 262-0555 for verification and"
@ 54,05 say "      posting of payment."

@ 57,05 say "Prepared by:"

@ 60,05 say "ENena T. Duran"
@ 61,05 say "Head - Student's Acctg. Dept."

//@ 60,05 say "Noted by: "+cnotedby
//@ 61,05 say "          "+cdesgn

@ 65,05 say "UC-METC/SAC.DOC./003/REV.04"
__eject()
return(nil)

*------------------------------------------------------------------------------*

function studterm()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopen1files,aopen2files,cprocsts,aentryscr,cyytenrp,ayytpayp,ayytassp,cfile,ccdx,;
      nrotc
private cterm,cdesc,ccolcode,;
        cdummy := "sterm"+strzero(memvar->naccess,2),sterm

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
nrotc := "N"
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Student Balances by Term  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
        @ 05,02 say "w/ ROTC Subjects only [Y/N]:";
                color memvar->colorarray[02];
                get nrotc pict "Y";
                valid ! empty(nrotc)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/"+"c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+memvar->cterm+"enrp"
        ayytpayp := "a"+memvar->cterm+"payp"
        ayytassp := "a"+memvar->cterm+"assp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,2},;
                                      {,, ayytassp ,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        memvar->ccolcode := "MT"
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View College File       ³           ESC - Previous              ³")
                setkey(K_F4,{||vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get memvar->ccolcode pict "@!";
                        valid ! empty(memvar->ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif

                if ! c999colp->(dbseek(memvar->ccolcode))
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if whereprint({||pstudterm()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function pstudterm()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, ccourse := space(06),;
      nbal := 0, ntotal := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",09,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",08,0},;
                                 {"BALANCE"     ,"N",12,2}},{||cdxterm()})
        dbcloseall()
        return(nil)
endif
memvar->sterm := memvar->cdummy
if(afile := openwcheck({{,,(memvar->sterm+".TXT"),"sterm",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
sterm->(__dbzap());sterm->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("STUDENTS' BALANCES REPORT",nmaxcol))+"STUDENTS' BALANCES REPORT"})
aadd(abtext,{||space(titlepos("FOR THE "+alltrim(memvar->cdesc),nmaxcol))+"FOR THE "+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"  ID No.      Last Name           First Name          M   Course      Balance    "})
aadd(abtext,{||"---------  ---------------  ------------------------  -  --------  --------------"})

/*
  ID No.      Last Name           First Name          M   Course      Balance
---------  ---------------  ------------------------  -  --------  --------------
123456789  123456789012345  123456789012345678901234  1  123456 1  123,123,123.12
                                                                   --------------
                                                          TOTAL -> 123,123,123.12
*/

*processing**
cyytenrp->(sx_setscope(_TOP_SCOPE   ,memvar->ccolcode))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,memvar->ccolcode))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nbal := 0
        if ayytassp->(dbseek("1"+cyytenrp->enridno))
                nbal := ayytassp->asstotal
        endif
        fask(10,"  Processing id number "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        ayytpayp->(sx_setscope(_TOP_SCOPE   ,"1"+cyytenrp->enridno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,"1"+cyytenrp->enridno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
                fask(16,"  Processing trx no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                do case
                        case ayytpayp->paytag == _POSTED
                                nbal -= ayytpayp->payamt
                        case ayytpayp->paytag == _DISCOUNT
                                nbal -= ayytpayp->payamt
                        case ayytpayp->paytag == _SHORT_TERM
                                nbal += ayytpayp->payamt
                        case ayytpayp->paytag == _ADJUSTMENT
                                nbal += ayytpayp->payamt
                        case ayytpayp->paytag == _FORWARDED
                                nbal += ayytpayp->payamt
                endcase
                if nextkey() == K_ESC
                        exit
                endif
                ayytpayp->(dbskip())
        enddo
        ayytpayp->(clearscope())

        if nbal > 49.99
                a999accp->(dbseek("1"+cyytenrp->enridno))
                c999colp->(dbseek(cyytenrp->enrcolcod))
                sterm->(dbappend())
                sterm->idno     := "1"+cyytenrp->enridno
                sterm->lname    := a999accp->acclname
                sterm->fname    := a999accp->accfname
                sterm->mname    := a999accp->accmname
                sterm->course   := c999colp->coldesabr+" "+cyytenrp->enryrlevl
                sterm->balance  := nbal
        endif

        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())


**printing**
pageprint(abtext)
sterm->(dbgotop())
do while ! sterm->(eof())
        fask(10,"  Printing name "+alltrim(sterm->lname)+", "+alltrim(sterm->fname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
        @ prow()+01,00 say sterm->idno+"  "+;
                           sterm->lname+"  "+;
                           sterm->fname+"  "+;
                           sterm->mname+"  "+;
                           sterm->course+"  "+;
                           transform(sterm->balance,"999,999,999.99")

        ntotal += sterm->balance

        if nextkey() == K_ESC
                exit
        endif
        sterm->(dbskip())
enddo
@ prow()+01,67 say "--------------"
@ prow()+01,58 say "TOTAL -> "+transform(ntotal,"999,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)

*------------------------------------------------------------------------------*

function upterm()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopen1files,aopen2files,cprocsts,aentryscr,ayytpayp,cfile,ccdx

private cterm,cdesc,ccolcode,;
        cdummy := "uterm"+strzero(memvar->naccess,2),sterm

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif

memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Upgrading Balances by Term  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
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

        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        ayytpayp := "a"+memvar->cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,3},;
                                      {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"a999stcp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        memvar->ccolcode := "  "

        do while .t.
                restscr(aentryscr)
                commandline("³       F4 - View Upgrading File       ³           ESC - Previous              ³")
                setkey(K_F4,{||vupgrade(space(len(a999stcp->stccod)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)

                @ 04,02 say "Upgrading Code :";
                        color memvar->colorarray[02];
                        get memvar->ccolcode pict "@!";
                        valid ! empty(memvar->ccolcode)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif

                if ! a999stcp->(dbseek(memvar->ccolcode))
                        fask(10,"  Upgrading code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if whereprint({||pupterm()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function pupterm()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, ccourse := space(06),;
      nbal := 0, ntotal := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",09,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",08,0},;
                                 {"BALANCE"     ,"N",12,2}},{||cdxterm()})
        dbcloseall()
        return(nil)
endif
memvar->sterm := memvar->cdummy
if(afile := openwcheck({{,,(memvar->sterm+".TXT"),"sterm",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
sterm->(__dbzap());sterm->(dbreindex())
a999stcp->(dbseek(memvar->ccolcode))
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("STUDENTS' BALANCES REPORT",nmaxcol))+"STUDENTS' BALANCES REPORT"})
aadd(abtext,{||space(titlepos("FOR THE "+alltrim(memvar->cdesc),nmaxcol))+"FOR THE "+alltrim(memvar->cdesc)})
aadd(abtext,{||space(titlepos(alltrim(a999stcp->stcdesful,nmaxcol)))+alltrim(a999stcp->stcdesful)})
aadd(abtext,{||""})
aadd(abtext,{||"  ID No.      Last Name           First Name          M   Course      Balance    "})
aadd(abtext,{||"---------  ---------------  ------------------------  -  --------  --------------"})

/*
  ID No.      Last Name           First Name          M   Course      Balance
---------  ---------------  ------------------------  -  --------  --------------
123456789  123456789012345  123456789012345678901234  1  123456 1  123,123,123.12
                                                                   --------------
                                                          TOTAL -> 123,123,123.12
*/

*processing**
a999accp->(sx_setscope(_TOP_SCOPE   ,memvar->ccolcode))
a999accp->(sx_setscope(_BOTTOM_SCOPE,memvar->ccolcode))
a999accp->(dbgotop())
do while ! a999accp->(eof())
        nbal := 0
        fask(10,"  Processing id number "+a999accp->accidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        ayytpayp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
                fask(16,"  Processing trx no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                do case
                        case ayytpayp->paytag == _POSTED
                                nbal -= ayytpayp->payamt
                        case ayytpayp->paytag == _DISCOUNT
                                nbal -= ayytpayp->payamt
                        case ayytpayp->paytag == _SHORT_TERM
                                nbal += ayytpayp->payamt
                        case ayytpayp->paytag == _ADJUSTMENT
                                nbal += ayytpayp->payamt
                        case ayytpayp->paytag == _FORWARDED
                                nbal += ayytpayp->payamt
                endcase
                if nextkey() == K_ESC
                        exit
                endif
                ayytpayp->(dbskip())
        enddo
        ayytpayp->(clearscope())

        if nbal > 49.99
                a999stcp->(dbseek(a999accp->acccolcod))
                sterm->(dbappend())
                sterm->idno     := a999accp->accidno
                sterm->lname    := a999accp->acclname
                sterm->fname    := a999accp->accfname
                sterm->mname    := a999accp->accmname
                sterm->course   := a999stcp->stcdesabr
                sterm->balance  := nbal
        endif

        if nextkey() == K_ESC
                exit
        endif
        a999accp->(dbskip())
enddo
a999accp->(clearscope())


**printing**
pageprint(abtext)
sterm->(dbgotop())
do while ! sterm->(eof())
        fask(10,"  Printing name "+alltrim(sterm->lname)+", "+alltrim(sterm->fname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
        @ prow()+01,00 say sterm->idno+"  "+;
                           sterm->lname+"  "+;
                           sterm->fname+"  "+;
                           sterm->mname+"  "+;
                           sterm->course+"  "+;
                           transform(sterm->balance,"999,999,999.99")

        ntotal += sterm->balance

        if nextkey() == K_ESC
                exit
        endif
        sterm->(dbskip())
enddo
@ prow()+01,67 say "--------------"
@ prow()+01,58 say "TOTAL -> "+transform(ntotal,"999,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


*------------------------------------------------------------------------------*

static function cdxterm()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
function specialincome()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,aentryscr,ayytpayp,cprocsts
private cterm,cdesc,ntotamt,cname,ntassess,noaccts,namtdue,nscod,necod,nvcod

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                               {,,"a999stcp",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))
nscod:=0
while .t.
   a999stcp->(dbgobottom())
   necod:=val(a999stcp->stccod)
   restscr(aentryscr)
   boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Summary of Special Courses Fees Income ")
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
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+memvar->cterm+"payp"
        if(aprv2setup:=openwcheck({{,,ayytpayp,"ayytpayp",_DBF_SHARED,,5}}))==nil
                return(nil)
        endif
        @ 03,29 say "- ([00] - For all special course " color memvar->colorarray[02]
        @ 03,62 say "- ([52 -   ]))" color memvar->colorarray[02]
        @ 03,71 say memvar->necod color memvar->colorarray[02]
        @ 03,02 say "Special College code...:";
                color memvar->colorarray[02];
                get memvar->nscod    pict "99";
                valid (memvar->nscod > 51 .and. memvar->nscod < memvar->necod+1);
                .or. memvar->nscod == _TOP_SCOPE
        read
        if lastkey() == K_ESC
                exit
        endif
        if whereprint({||navprint()}) == 1
           __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
           viewtextfile()
        endif
  closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)
*------------------------------------------------------------------------------*
static function navprint()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, ccourse := space(06),;
      lflag:=.f.
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SUMMARY OF SPECIAL COURSES FEES INCOME",nmaxcol))+"SUMMARY OF SPECIAL COURSES FEES INCOME"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(12)+"  Course       # Student        Assesment        Total    "})
aadd(abtext,{||space(12)+"------------ ---------------  -------------  --------------"})
pageprint(abtext)
memvar->ntotamt := 0.00
if memvar->nscod == _TOP_SCOPE
   memvar->vscod := 51
   memvar->necod++
else
   memvar->vscod := memvar->nscod - 1
   memvar->necod := memvar->nscod + 1
endif
a999stcp->(dbgotop())
while !(a999stcp->(eof()))
 if val(a999stcp->stccod) > memvar->vscod .and. val(a999stcp->stccod) < memvar->necod
    fask(10,"  Processing college code "+alltrim(a999stcp->stccod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
    memvar->cname := a999stcp->stcdesabr
    memvar->noaccts:=0
    memvar->ntassess:=0.00
    ayytpayp->(sx_setscope(_TOP_SCOPE   ,a999stcp->stccod))
    ayytpayp->(sx_setscope(_BOTTOM_SCOPE,a999stcp->stccod))
    ayytpayp->(dbgotop())
    while !(ayytpayp->(eof()))
     if alltrim(ayytpayp->paymach) == "1" && .and. ayytpayp->payamt > 0.00
       memvar->noaccts++
       if memvar->noaccts > 1
          if !memvar->ntassess = ayytpayp->payamt
               memvar->noaccts--
               print_it(npage,abtext)
               memvar->noaccts:=0
               memvar->ntassess:=ayytpayp->payamt
               ayytpayp->(dbskip(-1))
          endif
       else
         memvar->ntassess:=ayytpayp->payamt
       endif
       fask(16,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
     endif
     ayytpayp->(dbskip())
    enddo
    clearscope()
    print_it(npage,abtext)
 endif
 a999stcp->(dbskip())
enddo
if memvar->ntotamt > 0.00
  pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                 abtext, prow() + 1, _MAX_LINE, {||__eject()})
     @ prow()+01,00 say space(12)+"------------ ---------------  -------------  --------------"
     @ prow()+01,00 say space(46)+"Total ==> "+;
                        transform(memvar->ntotamt,"999,999,999.99")
     @ prow()+01,00 say " "
     eject
endif
return(nil)
*------------------------------------------------------------------------------*
static function print_it(npage,abtext)
    memvar->namtdue := 0.00
    if memvar->noaccts > 0
       memvar->namtdue := memvar->noaccts * memvar->ntassess
       memvar->ntotamt += memvar->namtdue
     pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                 abtext, prow() + 1, _MAX_LINE, {||__eject()})
     @ prow()+01,00 say space(12)+a999stcp->stccod+;
                        " - " +memvar->cname+;
                        space(4)+transform(memvar->noaccts,"99,999")+;
                        space(10)+transform(memvar->ntassess,"9,999,999.99")+;
                        space(2)+transform(memvar->namtdue,"999,999,999.99")
    endif
   return(nil)

*------------------------------------------------------------------------------*

function instpaysheet()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytskdp,cyytenrr,aprv2setup,;
      cfile,cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinstcode,cinstname,cskdcont,ccedpcode,ccsubject,ncunits,;
      clname,cfname,cperiod
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
//cedpcode := space(05)
cedpcode := "ALL  "
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Inst. Lst. of Req. Payment Sheet Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("\crunlib\c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("\crunlib\c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp := "c"+cterm+"skdp"
        cyytenrr := "c"+cterm+"enrr"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"a999accp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(t999lst->tlname))
        cfname := space(len(t999lst->tfname))
        cperiod := space(1)
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar()=="CEDPCODE",vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 03,02 say "Exam. Period   :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 04,02 say "Schedule Code  :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
                @ 05,02 say "Instructors Starting Name Printed :" color memvar->colorarray[02]
                @ 06,05 say "Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,05 say "First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(cedpcode) == "ALL"
                        if ! cyytskdp->(dbseek(cedpcode))
                                fask(10,"   Schedule code "+cedpcode+" does not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        if cyytskdp->skdsplcod == "C" /* .and. cyytskdp->skdsubtyp == "LEC" */
                                fask(10,"  Schedule code "+cedpcode+" is continuation code.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                        nunits    := cyytskdp->skdunt
                        c999crsp->(dbseek(cyytskdp->skdintcod))
                        cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                        if t999lst->(dbseek(cyytskdp->skdinscod))
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                        else
                                cinscode := space(06)
                                cinsname := space(30)
                        endif
                        if cyytskdp->skdsplcod == "S"
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                ccedpcode := cyytskdp->skdcod
                                ncunits   := cyytskdp->skdunt
                                ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        else
                                cskdcont  := " "
                                ccedpcode := " "
                                ncunits   := 0
                                ccsubject := " "
                        endif
                        if whereprint({||pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,10)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||pallinstpaysheet(cdesc,clname,cfname,cperiod)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,npost)
local nctr := 0, cskdno, npage := 0, nline := 0, namt := nexamf := 0
instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytenrr->(dbgotop())

//      fask(10,"  cperiod ==> "+cperiod+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

do while ! cyytenrr->(eof())
        fask(npost,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        a999accp->(dbseek("1"+cyytenrr->enridno))

//---------------------------------------------------------------

        nexamf := a999accp->accduetot / 4

        if cperiod == "P"
                namt   := nexamf - a999accp->accamtpd
        elseif cperiod == "M"
                namt   := (a999accp->accbaltot - (nexamf * 3)) + nexamf
        elseif cperiod == "S"
                namt   := (a999accp->accbaltot - (nexamf * 2)) + nexamf
        elseif cperiod == "F"
                namt   := a999accp->accbaltot
        endif

//---------------------------------------------------------------

        if namt < 0
                namt := 0
        endif

//SEQ. ID NO.   LASTNAME        FIRSTNAME                 MI     AMOUNT REMARKS")

        if namt > 1
                outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                     cyytenrr->enridno+space(01)+;
                                     c999sm1p->sm1lstnam+space(01)+;
                                     c999sm1p->sm1fstnam+space(01)+;
                                     c999sm1p->sm1midnam+space(01)+;
                                     if(alltrim(cyytenrr->enrrem) != "WITHDRAWN",;
                                        transform(int(namt),"99,999.99"),"     0.00"))
                if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                        outexpr(prow()+00,70,"WITHDRAWN")
                elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                        outexpr(prow()+00,70,"GRADUATING")
                endif
                ++nline
                if nextkey() == K_ESC
                        exit
                endif
                outexpr(prow(),70,replicate("_",14))
        endif
        cyytenrr->(dbskip())
        if nline == 40 .and. ! cyytenrr->(eof())
                outexpr(prow()+00,00,chr(18))
                __eject()
                instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
                nline := 0
        endif
enddo
cyytenrr->(clearscope())
outexpr(56,55,"_____________________________")
outexpr(57,55," SIGNATURE OVER PRINTED NAME")
outexpr(58,55,"    (INSTRUCTOR/PROCTOR)")
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

static function instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,npage,ccedpcode,ccsubject,ncunits,cperiod)
setprc(00,00)

outexpr(00,42-len("UNIVERSITY OF CEBU - MAMBALING")/2,"UNIVERSITY OF CEBU - MAMBALING")
outexpr(01,42-len("ALUMNOS, MAMBALING, CEBU CITY")/2,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,42-len("LIST OF STUDENTS W/ REQUIRED PAYMENT FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))/2,;
                  "LIST OF STUDENTS W/ REQUIRED PAYMENT FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))
outexpr(03,42-len(alltrim(cdesc))/2,alltrim(cdesc))

outexpr(05,00,"SUBJECT    :"+cedpcode+"  "+csubject+"  "+cschedule+"  "+transform(nunits,"@Z 99.9"))
outexpr(05,76,"Page  "+alltrim(transform(npage,"99")))
outexpr(06,00,"INSTRUCTOR :"+cinscode+"  "+cinsname)
outexpr(07,00,replicate("-",84))
outexpr(08,00,"SEQ. ID NO.   LASTNAME        FIRSTNAME                 MI   AMOUNT   REMARKS")
outexpr(09,00,replicate("-",84))
return(nil)

static function pallinstpaysheet(cdesc,clname,cfname,cperiod)
local cinscode:=" ",cinsname:=" ",cedpcode:=" ",csubject:=" ",cschedule:=" ",;
      nunits:=0,cdesctitle:=" ",cskdcont:=" ",npage:=0,ccedpcode,;
      ccsubject:=" ",ncunits:=0,nrec

t999lst->(sx_settagorder(2))
cyytskdp->(sx_settagorder(6))

t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" .and. (alltrim(t999lst->tlname)+alltrim(t999lst->tfname)) >= (alltrim(clname)+alltrim(cfname))
                fask(06,"  Processing name "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        npage := 0
                        fask(12,"  Processing code "+alltrim(cyytskdp->skdcod)+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! cyytskdp->skdsplcod == "C"
                                cedpcode  := cyytskdp->skdcod
                                csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                nunits    := cyytskdp->skdunt
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                                if cyytskdp->skdsplcod == "S"
                                        nrec := cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                        ccedpcode := cyytskdp->skdcod
                                        ncunits   := cyytskdp->skdunt
                                        ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                        cyytskdp->(dbgoto(nrec))
                                        cyytskdp->(sx_settagorder(6))
                                else
                                        cskdcont  := " "
                                        ccedpcode := " "
                                        ncunits   := 0
                                        ccsubject := " "
                                endif
                                **Printing**
                                pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,18)
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                enddo
        endif
        cyytskdp->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
cyytskdp->(sx_settagorder(1))
return(nil)

*------------------------------------------------------------------------------*

function acctpaylst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, cyytenrp, aprv2setup, ayytassp,;
      cterm,cdesc,ccolcode,cyear,cpaper,clname,cfname,cperiod:=space(1)
private cdummy := "gcours"+strzero(memvar->naccess,2),mstfile

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cperiod  := " "
ccolcode := "UC"
cyear    := "8"
cpaper   := "B"
clname   := space(15)
cfname   := space(24)
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing by Course  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("a999accp.dbf"))
                fask(10,"  A999ACCP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+cterm+"assp.dbf"))
                fask(10,"  A"+cterm+"ASSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("/crunlib/c999sm1p.dbf"))
                fask(10,"  C999SM1P.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("/crunlib/c999colp.dbf"))
                fask(10,"  C999COLP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("/crunlib/c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("/crunlib/c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytenrp := "c"+cterm+"enrp"
        cyytenrr := "c"+cterm+"enrr"
        ayytassp := "a"+cterm+"assp"
        if(aprv2setup := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                     {,, ayytassp ,"ayytassp",_DBF_SHARED,,4},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(a999accp->acclname))
        cfname := space(len(a999accp->accfname))
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 03,02 say "Exam. Period   :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 04,02 say "Students Starting Name For Printing :" color memvar->colorarray[02]
                @ 05,05 say "Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 06,05 say "First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||prnacctpaylst(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function prnacctpaylst(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname)
local afile, nline := nctr := npage :=0
private ntotunits,ntotequi,lok,ntotgrade,csubject,csubdesc,cgrade,cunit,ncredits,lprint,ncount,ncnt

fask(13,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"PERIOD"      ,"C",07,0}},{||cdxacctlst()})
        dbcloseall()
        return(nil)
endif
memvar->mstfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->mstfile+".TXT"),"mstfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
mstfile->(__dbzap()); mstfile->(dbreindex())
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))
ncnt:=0

hacctpaylstheader(cdesc,++npage,cperiod)

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        mstfile->(dbappend())
        mstfile->idno   := c999sm1p->sm1idno
        mstfile->lname  := c999sm1p->sm1lstnam
        mstfile->fname  := c999sm1p->sm1fstnam
        mstfile->mname  := c999sm1p->sm1midnam
        mstfile->course := c999colp->coldesabr
        mstfile->year   := cyytenrp->enryrlevl
        if nextkey() == K_ESC
                exit
        endif
        ncnt += 1
        cyytenrp->(dbskip())
enddo

//fask(10,"  "+ str(ncnt,5,0)  +"  ",{" Ok "},memvar->colorarray[06],.t.,nil)

cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*------------------
*  Printing data  *
*------------------
mstfile->(dbsetrelation("cyytenrr",{||mstfile->idno},"mstfile->idno"))
mstfile->(dbgotop())
do while ! mstfile->(eof())
        fask(10,"  Processing student "+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+" "+mstfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(mstfile->lname)+alltrim(mstfile->fname))
                fask(10,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                c999colp->(dbseek(cyytenrr->enrcolcod))
                c999sm1p->(dbseek(cyytenrr->enridno))
                a999accp->(dbseek("1"+cyytenrr->enridno))
//---------------------------------------------------------------
                nexamf := a999accp->accduetot / 4
                if cperiod == "P"
                        namt   := nexamf - a999accp->accamtpd
                elseif cperiod == "M"
                        namt   := (a999accp->accbaltot - (nexamf * 3)) + nexamf
                elseif cperiod == "S"
                        namt   := (a999accp->accbaltot - (nexamf * 2)) + nexamf
                elseif cperiod == "F"
                        namt   := a999accp->accbaltot
                endif
//---------------------------------------------------------------
                if namt < 0
                        namt := 0
                endif
                if (namt <= 0) .and. ! ayytassp->(dbseek("1"+mstfile->idno+cperiod))
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9,999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             c999sm1p->sm1lstnam+space(01)+;
                                             c999sm1p->sm1fstnam+space(01)+;
                                             c999sm1p->sm1midnam+space(01))
                        if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                                outexpr(prow()+00,62,"WITHDRAWN")
                        elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                                outexpr(prow()+00,62,"GRADUATING")
                        endif
                        ++nline
                        if ayytassp->(dbseek("1"+mstfile->idno))
                                ayytassp->(reclock())
                                ayytassp->assexamtag := cperiod
                                ayytassp->(dbcommit())
                                ayytassp->(dbunlock())
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        outexpr(prow(),62,replicate("_",10))
                  endif
                  cyytenrr->(dbskip())
                  if nline == 50 .and. ! cyytenrr->(eof())
                        outexpr(prow()+00,00,chr(18))
                        __eject()
                        hacctpaylstheader(cdesc,++npage,cperiod)
                        nline := 0
                  endif
        endif
        mstfile->(dbskip())
enddo
cyytenrr->(clearscope())
closewcheck(afile)
__eject()
return(nil)

static function cdxacctlst()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function hacctpaylstheader(cdesc,npage,cperiod)
setprc(00,00)
outexpr(00,36-len("UNIVERSITY OF CEBU -  MAMBALING")/2,"UNIVERSITY OF CEBU -  MAMBALING")
outexpr(00,64,"Page  "+alltrim(transform(npage,"99")))
outexpr(01,36-len("ALUMNOS, MAMBALING, CEBU CITY")/2,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,36-len("LIST OF STUDENTS PAYED FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))/2,;
                  "LIST OF STUDENTS PAYED FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))
outexpr(03,36-len(alltrim(cdesc))/2,alltrim(cdesc))

outexpr(05,00,replicate("-",72))
//outexpr(07,00,"SEQ. ID NO.   LASTNAME        FIRSTNAME                 MI   AMOUNT   REMARKS")
outexpr(06,00,"  SEQ. ID NO.   LASTNAME        FIRSTNAME                 MI  REMARKS")
outexpr(07,00,replicate("-",72))
return(nil)

*------------------------------------------------------------------------------*

function paylst4deans()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,;
      cfile,ccdx,cprocsts,clname,cfname
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student,ntotal

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Examination Permit by College - Deans Copy ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,22 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytenrr := "c"+cterm+"enrr"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytenrr,"cyytenrr",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        cperiod  := "P"
        cyrlevel := "8"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View Collge File        ³           ESC - Previous              ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [NT-nautical, MG-marine, UC - ALL COURSE]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
                @ 04,02 say "                   [1 2 3 4 5  8-ALL]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "123458"
                @ 05,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 06,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 07,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 08,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode)) .and. !(ccolcode $ "UC,NT,MG")
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                @ 03,21 say "                                                            " color memvar->colorarray[02]
                @ 03,21 say c999colp->coldesful color memvar->colorarray[02]
                if ccolcode == "UC"
                        @ 03,21 say "ALL COURSES" color memvar->colorarray[02]
                elseif ccolcode == "NT"
                        @ 03,21 say "MARINE TRANSPORTATION" color memvar->colorarray[02]
                elseif ccolcode == "MG"
                        @ 03,21 say "MARINE ENGINEERING" color memvar->colorarray[02]
                endif

                if whereprint({||ppaylst4deans(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)

static function ppaylst4deans(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)
local nctr,skdno,nlastelem,nover,nmax,afile,;
      npage := nctr := nline := 0, namt := 0.00
private ccol:=space(42)
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"1",{{"IDNO"        ,"C",08,0},;
                                     {"LNAME"       ,"C",15,0},;
                                     {"FNAME"       ,"C",24,0},;
                                     {"MNAME"       ,"C",01,0},;
                                     {"COURSE"      ,"C",08,0},;
                                     {"YEAR"        ,"C",01,0}},{||cdxname()}) .or. ;
   ! createdummy(memvar->cdummy+"2",{{"YRLEVEL"     ,"C",01,0},;
                                     {"NCOUNTER"    ,"N",06,0},;
                                     {"SUBTOTAL"    ,"N",10,2}},{||cdxtotal()})
        dbcloseall()
        return(nil)
endif
memvar->student := memvar->cdummy+"1"
memvar->ntotal  := memvar->cdummy+"2"
if(afile := openwcheck({{,,(memvar->student+".TXT"),"student",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->ntotal+".TXT"),"ntotal",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif

student->(__dbzap());student->(dbreindex())
ntotal->(__dbzap());ntotal->(dbreindex())

if ! (ccolcode $ "UC,NT,MG")
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif
c999colp->(dbseek(ccolcode))
ccol := c999colp->colnamcol
hpaylst4deans(cdesc,++npage,cperiod,ccolcode,ccol)

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
           if (cyrlevel == "8") .or. ((cyrlevel != "8") .and. (cyytenrp->enryrlevl == cyrlevel))
                if ((ccolcode=="NT") .and. cyytenrp->enrcolcod $ "MT,MV,PA,MI") .or. ;
                   ((ccolcode=="MG") .and. cyytenrp->enrcolcod $ "MA,MM,MP,MR") .or. ;
                    (ccolcode=="UC") .or. (cyytenrp->enrcolcod == ccolcode)
                        a999accp->(dbseek("1"+cyytenrp->enridno))
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        student->(dbappend())
                        student->idno    := cyytenrp->enridno
                        student->lname   := a999accp->acclname
                        student->fname   := a999accp->accfname
                        student->mname   := a999accp->accmname
                        student->course  := c999colp->coldesabr+" "+cyytenrp->enryrlevl
                        student->year    := cyytenrp->enryrlevl
                endif
           endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())

**printing**
cyytenrp->(sx_settagorder(1))
student->(dbsetrelation("cyytenrr",{||student->idno},"student->idno"))
student->(dbsetrelation("c999sm1p",{||student->idno},"student->idno"))
student->(dbgotop())
do while ! student->(eof())
        fask(10,"  Processing student "+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(student->lname)+alltrim(student->fname))
                fask(10,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                c999sm1p->(dbseek(cyytenrr->enridno))
                a999accp->(dbseek("1"+cyytenrr->enridno))
//---------------------------------------------------------------
                nexamf := a999accp->accduetot / 4
                if cperiod == "P"
                        namt   := nexamf - a999accp->accamtpd
                elseif cperiod == "M"
                        namt   := (a999accp->accbaltot - (nexamf * 3)) + nexamf
                elseif cperiod == "S"
                        namt   := (a999accp->accbaltot - (nexamf * 2)) + nexamf
                elseif cperiod == "F"
                        namt   := a999accp->accbaltot
                endif
//---------------------------------------------------------------
                if namt < 0
                        namt := 0
                endif
                if namt >= 100
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9,999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             c999sm1p->sm1lstnam+space(01)+;
                                             c999sm1p->sm1fstnam+space(01)+;
                                             c999sm1p->sm1midnam+space(01)+;
                                             right(alltrim(student->course),1)+space(01)+;
                                             if(alltrim(cyytenrr->enrrem) != "WITHDRAWN",;
                                                transform(namt,"99,999.99"),"     0.00"))
                        if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                                outexpr(prow()+00,72,"WITHDRAWN")
                        elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                                outexpr(prow()+00,72,"GRADUATING")
                        endif
                        ++nline
//                        if alltrim(cyytenrr->enrrem) != "WITHDRAWN"
                                if !(ntotal->(dbseek(student->year)))
                                        ntotal->(dbappend())
                                        ntotal->yrlevel  := student->year
                                        ntotal->ncounter := 0
                                        ntotal->subtotal := 0
                                endif
                                        ntotal->ncounter += 1
                                        ntotal->subtotal += if(alltrim(cyytenrr->enrrem)!="WITHDRAWN",namt,0)
//                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        outexpr(prow(),72,replicate("_",12))
                  endif
                  cyytenrr->(dbskip())
                  if nline == 50 .and. ! cyytenrr->(eof())
                        outexpr(prow()+00,00,chr(18))
                        __eject()
                        hpaylst4deans(cdesc,++npage,cperiod,ccol)
                        nline := 0
                  endif

        endif
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
enddo

if nline+10 >= 50
        outexpr(prow()+00,00,chr(18))
        __eject()
        nline := 0
endif

summpaylst4deans()

cyytenrp->(sx_settagorder(2))
closewcheck(afile)
return(nil)

static function cdxname()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function cdxtotal()
field yrlevel
private cdummyfile := alias()
index on yrlevel        tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function hpaylst4deans(cdesc,npage,cperiod,ccolcode,ccol)
setprc(00,00)
outexpr(00,42-len("UNIVERSITY OF CEBU -  MAMBALING")/2,"UNIVERSITY OF CEBU -  MAMBALING")
outexpr(00,76,"Page  "+alltrim(transform(npage,"99")))
outexpr(01,42-len("ALUMNOS, MAMBALING, CEBU CITY")/2,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,42-len("LIST OF STUDENTS WITH REQUIRED PAYMENT FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))/2,;
                  "LIST OF STUDENTS WITH REQUIRED PAYMENT FOR "+if(cperiod=="P","PRELIM",if(cperiod=="M","MIDTERM",if(cperiod=="S","SEMI-FINAL","FINAL"))))
outexpr(03,42-len(alltrim(cdesc))/2,alltrim(cdesc))
if ccolcode == "UC"
        outexpr(05,00,"ALL COURSES")
elseif ccolcode == "NT"
        outexpr(05,00,"COURSE: MARINE TRANSPORTATION")
elseif ccolcode == "MG"
        outexpr(05,00,"COURSE: MARINE ENGINEERING")
else
        outexpr(05,00,"COURSE: "+alltrim(c999colp->coldesful)+"  ")
endif
outexpr(06,00,replicate("-",84))
outexpr(07,00,"  SEQ. ID NO.   LASTNAME        FIRSTNAME                MI Yr   AMOUNT REMARKS")
outexpr(08,00,replicate("-",84))
return(nil)

function summpaylst4deans()
private i,grandtot:=nstuds:=0
outexpr(prow(),03,"SUMMARY:")
outexpr(prow()+2,00,"          LEVEL     STUDENTS      AMOUNT")
outexpr(prow()+1,00,"       ----------------------------------")

ntotal->(dbgotop())
while ! ntotal->(eof())
        outexpr(prow()+1,07,if(ntotal->yrlevel=="1","1ST",if(ntotal->yrlevel=="2","2ND",if(ntotal->yrlevel=="3","3RD",ntotal->yrlevel+"TH")))+" YEAR:  "+transform(ntotal->ncounter,"@Z   9,999")+ "   " + transform(ntotal->subtotal,"@Z 99,999,999.99"))
        nstuds+=ntotal->ncounter
        grandtot+=ntotal->subtotal
        ntotal->(dbskip())
enddo
        outexpr(prow()+1,21,replicate("-",20))
        outexpr(prow()+1,06,"GRAND TOTAL :"+transform(nstuds,"@Z 99,999")+ "  " + transform(grandtot,"@Z 999,999,999.99"))
        outexpr(prow()+1,21,replicate("=",20))

return(nil)
*------------------------------------------------------------------------------*

function lstrequired()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,;
      cfile,ccdx,cprocsts,clname,cfname, csection, sectf, sectcod
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student,ntotal

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Examination Permit by Section  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,22 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytenrr := "c"+cterm+"enrr"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"section",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytenrr,"cyytenrr",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := "PB"
        cperiod  := "1"
        cyrlevel := "8"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        csection := space(len(section->secdesc))
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View Collge File        ³           ESC - Previous              ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [PB-prebac, TM-tvl, ST-stem, GS-gas, HU-humss]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
/*                @ 04,02 say "                   [1 2 3 4 5  8-ALL]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "123458"
*/
                @ 04,02 say "                   [1-st, 2-nd, 3-rd, 4-th]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "1234"
                @ 05,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 06,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
                @ 08,02 say "    Section    :";
                        color memvar->colorarray[02];
                        get csection pict "@!";
                        valid ! empty(csection)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode)) .and. !(ccolcode $ "UC,NT,MG")
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                sectf = "0"
                sectcod = ""
                section->(dbgotop())
                do while ! section->(eof())
                        if alltrim(section->secdesc) == alltrim(csection)
                           sectcod = section->seccode
                           sectf = "1"
                        endif
                        section->(dbskip())
                enddo
                section->(clearscope())
                if  sectf == "0"
                        fask(10,"  SECTION not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                
                if whereprint({||paylst(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod,csection)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)

static function paylst(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod,csection)
local nctr,skdno,nlastelem,nover,nmax,afile,;
      npage := nctr := nline := 0, namt := 0.00, nshare := 0
private ccol:=space(42)
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"1",{{"IDNO"        ,"C",08,0},;
                                     {"LNAME"       ,"C",15,0},;
                                     {"FNAME"       ,"C",24,0},;
                                     {"MNAME"       ,"C",01,0},;
                                     {"COURSE"      ,"C",08,0},;
                                     {"YEAR"        ,"C",01,0}},{||cdxname()}) .or. ;
   ! createdummy(memvar->cdummy+"2",{{"YRLEVEL"     ,"C",01,0},;
                                     {"NCOUNTER"    ,"N",06,0},;
                                     {"SUBTOTAL"    ,"N",10,2}},{||cdxtotal()})
        dbcloseall()
        return(nil)
endif
memvar->student := memvar->cdummy+"1"
memvar->ntotal  := memvar->cdummy+"2"
if(afile := openwcheck({{,,(memvar->student+".TXT"),"student",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->ntotal+".TXT"),"ntotal",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif

student->(__dbzap());student->(dbreindex())
ntotal->(__dbzap());ntotal->(dbreindex())

if ! (ccolcode $ "UC,NT,MG")
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif
c999colp->(dbseek(ccolcode))
ccol := c999colp->colnamcol
hpaylst(cdesc,++npage,cperiod,ccolcode,ccol, csection)

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
           if (cyrlevel == "8") .or. ((cyrlevel != "8") .and. (cyytenrp->enryrlevl == cyrlevel))
                if ((ccolcode=="NT") .and. cyytenrp->enrcolcod $ "MT,MV,PA,MI") .or. ;
                   ((ccolcode=="MG") .and. cyytenrp->enrcolcod $ "MA,MM,MP,MR") .or. ;
                    (ccolcode=="UC") .or. (cyytenrp->enrcolcod == ccolcode)
                       if  a999accp->(dbseek("1"+cyytenrp->enridno))
                       elseif a999accp->(dbseek("2"+cyytenrp->enridno))
                       endif
                      c999colp->(dbseek(cyytenrp->enrcolcod))
                      if cyytenrp->enrsection == sectcod
                        student->(dbappend())
                        student->idno    := cyytenrp->enridno
                        student->lname   := a999accp->acclname
                        student->fname   := a999accp->accfname
                        student->mname   := a999accp->accmname
                        student->course  := c999colp->coldesabr
                        student->year    := cyytenrp->enryrlevl
                      endif
                endif
           endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())

**printing**
cyytenrp->(sx_settagorder(1))
student->(dbsetrelation("cyytenrr",{||student->idno},"student->idno"))
student->(dbsetrelation("c999sm1p",{||student->idno},"student->idno"))
student->(dbgotop())
do while ! student->(eof())
        fask(10,"  Processing student "+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(student->lname)+alltrim(student->fname))
                fask(10,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                c999sm1p->(dbseek(cyytenrr->enridno))
                a999accp->(dbseek("1"+cyytenrr->enridno))
//---------------------------------------------------------------
if a999accp->accpbcprv == "1"
   if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
          nshare = 0
   elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
          nshare = 4000
   endif

elseif a999accp->accpbcprv == "2"
   if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
          nshare = 2000
   elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
          nshare = 6000
   endif

elseif a999accp->accpbcprv == "3"
   if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
          nshare = 10000
   elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
          nshare = 14000
   endif
endif
         nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4


                if cperiod == "1"
                        namt   := nexamf
                elseif cperiod == "2"
                        namt   := (nexamf * 2) - a999accp->accamtpd
                elseif cperiod == "3"
                        namt   := (nexamf * 3) - a999accp->accamtpd
                elseif cperiod == "4"
                        namt   := a999accp->accbaltot
                endif
//---------------------------------------------------------------
                if namt < 0
                        namt := 0
                endif

                        outexpr(prow()+01,00,transform(++nctr,"@Z 9,999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             substr(c999sm1p->sm1lstnam,1,20)+space(01)+;
                                             substr(c999sm1p->sm1fstnam,1,24)+space(01)+;
                                             c999sm1p->sm1midnam+space(01)+;
                                             transform(int(namt),"99,999.99"))
                        ++nline
                        if nextkey() == K_ESC
                                exit
                        endif
                        outexpr(prow(),65,replicate("_",8))
                        outexpr(prow(),76,replicate("_",6))


                  cyytenrr->(dbskip())

                  if nline == 50 .and. ! cyytenrr->(eof())
                        outexpr(prow()+00,00,chr(18))
                        __eject()
                        hpaylst(cdesc,++npage,cperiod,ccol,csection)
                        nline := 0
                  endif

        endif
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
enddo
/*
if nline+10 >= 50
        outexpr(prow()+00,00,chr(18))
        __eject()
        nline := 0
endif
*/
 lstpayfooter()

cyytenrp->(sx_settagorder(2))
closewcheck(afile)
return(nil)
/*
static function cdxname()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function cdxtotal()
field yrlevel
private cdummyfile := alias()
index on yrlevel        tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)
*/
static function hpaylst(cdesc,npage,cperiod,ccolcode,ccol,csection)
setprc(00,00)
outexpr(00,42-len("UNIVERSITY OF CEBU -  MAMBALING")/2,"UNIVERSITY OF CEBU -  MAMBALING")
outexpr(00,76,"Page  "+alltrim(transform(npage,"99")))
outexpr(01,42-len("ALUMNOS, MAMBALING, CEBU CITY")/2,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,42-len("LIST OF STUDENTS WITH REQUIRED PAYMENT FOR "+if(cperiod=="1","JULY",if(cperiod=="2","AUGUST",if(cperiod=="3","SEPTEMBER","OCTOBER"))))/2,;
                  "LIST OF STUDENTS WITH REQUIRED PAYMENT FOR "+if(cperiod=="1","JULY",if(cperiod=="2","AUGUST",if(cperiod=="3","SEPTEMBER","OCTOBER"))))
outexpr(03,42-len(alltrim(cdesc))/2,alltrim(cdesc))

if ccolcode == "PB"
        outexpr(05,03,"STRAND: PREBAC     "+"SECTION: "+csection )
elseif ccolcode == "TM"
        outexpr(05,03,"STRAND: TECHVOC MARITIME     "+"SECTION: "+csection)
elseif ccolcode == "ST"
        outexpr(05,03,"STRAND: STEM    "+"SECTION: "+csection)
elseif ccolcode == "HU"
        outexpr(05,03,"STRAND: HUMSS    "+"SECTION: "+csection)
elseif ccolcode == "GS"
        outexpr(05,03,"STRAND: GAS     "+"SECTION: "+csection)
else
        outexpr(05,00,"  ")
endif

outexpr(06,00,replicate("-",84))
outexpr(07,00,"  SEQ. ID NO.   LASTNAME             FIRSTNAME                MI   AMOUNT    T/INT")
outexpr(08,00,replicate("-",84))
return(nil)

function lstpayfooter()

outexpr(60,03, "ADVISER:____________________")
outexpr(63,03, "NOTE: PLEASE LET THE STUDENTS PAY BEFORE TAKING THE EXAMINATION.")

return(nil)

*------------------------------------------------------------------------------*
function a2instpaysheet()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytskdp,cyytenrr,aprv2setup,;
      cfile,cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinstcode,cinstname,cskdcont,ccedpcode,ccsubject,ncunits,;
      clname,cfname,cperiod
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
//cedpcode := space(05)
cedpcode := "ALL  "
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Inst. Lst. of Req. Payment Sheet Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("\crunlib\c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("\crunlib\c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp := "c"+cterm+"skdp"
        cyytenrr := "c"+cterm+"enrr"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"a999accp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(t999lst->tlname))
        cfname := space(len(t999lst->tfname))
        cperiod := space(1)
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar()=="CEDPCODE",vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 03,02 say "Exam. Period   :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 04,02 say "Schedule Code  :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
                @ 05,02 say "Instructors Starting Name Printed :" color memvar->colorarray[02]
                @ 06,05 say "Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,05 say "First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(cedpcode) == "ALL"
                        if ! cyytskdp->(dbseek(cedpcode))
                                fask(10,"   Schedule code "+cedpcode+" does not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        if cyytskdp->skdsplcod == "C" /* .and. cyytskdp->skdsubtyp == "LEC" */
                                fask(10,"  Schedule code "+cedpcode+" is continuation code.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                        nunits    := cyytskdp->skdunt
                        c999crsp->(dbseek(cyytskdp->skdintcod))
                        cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                        if t999lst->(dbseek(cyytskdp->skdinscod))
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                        else
                                cinscode := space(06)
                                cinsname := space(30)
                        endif
                        if cyytskdp->skdsplcod == "S"
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                ccedpcode := cyytskdp->skdcod
                                ncunits   := cyytskdp->skdunt
                                ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        else
                                cskdcont  := " "
                                ccedpcode := " "
                                ncunits   := 0
                                ccsubject := " "
                        endif
                        if whereprint({||a2pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,10)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||a2pallinstpaysheet(cdesc,clname,cfname,cperiod)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function a2pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,npost)
local nctr := 0, cskdno, npage := 0, nline := 0, namt := nexamf := 0
instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytenrr->(dbgotop())

//      fask(10,"  cperiod ==> "+cperiod+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

do while ! cyytenrr->(eof())
        fask(npost,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        a999accp->(dbseek("1"+cyytenrr->enridno))

//---------------------------------------------------------------

        nexamf := a999accp->accduetot / 4

        if cperiod == "P"
                namt   := nexamf - a999accp->accamtpd
        elseif cperiod == "M"
                namt   := (a999accp->accbaltot - (nexamf * 3)) + nexamf
        elseif cperiod == "S"
                namt   := (a999accp->accbaltot - (nexamf * 2)) + nexamf
        elseif cperiod == "F"
                namt   := a999accp->accbaltot
        endif

//---------------------------------------------------------------

        if namt < 0
                namt := 0
        endif

        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(02)+;
                             cyytenrr->enridno+space(02)+;
                             c999sm1p->sm1lstnam+space(03)+;
                             c999sm1p->sm1fstnam+space(01)+;
                             c999sm1p->sm1midnam+space(04)+;
                             if(alltrim(cyytenrr->enrrem) != "WITHDRAWN",;
                                transform(int(namt),"999,999.99"),"      0.00"))
        if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                outexpr(prow()+00,124," WITHDRAWN")
        elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                outexpr(prow()+00,124,"GRADUATING")
        endif
        if nextkey() == K_ESC
                exit
        endif
        outexpr(prow(),00,replicate("_",135))
        cyytenrr->(dbskip())
        if ++nline == 34 .and. ! cyytenrr->(eof())
                outexpr(prow()+00,00,chr(18))
                __eject()
                a2instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
                nline := 0
        endif
enddo
cyytenrr->(clearscope())
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

static function a2instpshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,npage,ccedpcode,ccsubject,ncunits,cperiod)
setprc(00,00)
outexpr(00,55,"UNIVERSITY OF CEBU - METC")
outexpr(01,53,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,56,alltrim(cdesc))
outexpr(04,00,"SUBJECT    :"+cedpcode+"  "+csubject+"  "+cschedule+"  "+transform(nunits,"@Z 99.9"))
outexpr(04,129,"Page  "+alltrim(str(npage)))
outexpr(06,00,"INSTRUCTOR :"+cinscode+"  "+cinsname+"    SIG. OF INSTRUCTOR : "+replicate("_",25))
outexpr(07,00,replicate("-",135))
outexpr(08,00,"SEQ.  ID NO.    LASTNAME          FIRSTNAME                MI  REQ'D PAYMENT      (INSTRUCTOR TO FILL-UP)    (ACCOUNTING TO FILL-UP)")
do case
        case cperiod == "P"
                outexpr(09,63,"PRELIM EXAM         ")
        case cperiod == "M"
                outexpr(09,63,"MIDTERM EXAM        ")
        case cperiod == "S"
                outexpr(09,63,"SEMI-FINAL EXAM     ")
        case cperiod == "F"
                outexpr(09,63,"FINAL EXAM          ")
endcase
outexpr(09,83,"AMT PAID       BALANCE     AMT OF PROMI     REMARKS")
outexpr(10,00,replicate("-",135))
return(nil)


static function a2pallinstpaysheetgradesheet(cdesc,clname,cfname,cperiod)
local cinscode:=" ",cinsname:=" ",cedpcode:=" ",csubject:=" ",cschedule:=" ",;
      nunits:=0,cdesctitle:=" ",cskdcont:=" ",npage:=0,ccedpcode,;
      ccsubject:=" ",ncunits:=0,nrec

t999lst->(sx_settagorder(2))
cyytskdp->(sx_settagorder(6))

t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" .and. (alltrim(t999lst->tlname)+alltrim(t999lst->tfname)) >= (alltrim(clname)+alltrim(cfname))
                fask(06,"  Processing name "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        npage := 0
                        fask(12,"  Processing code "+alltrim(cyytskdp->skdcod)+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! cyytskdp->skdsplcod == "C"
                                cedpcode  := cyytskdp->skdcod
                                csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                nunits    := cyytskdp->skdunt
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                                if cyytskdp->skdsplcod == "S"
                                        nrec := cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                        ccedpcode := cyytskdp->skdcod
                                        ncunits   := cyytskdp->skdunt
                                        ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                        cyytskdp->(dbgoto(nrec))
                                        cyytskdp->(sx_settagorder(6))
                                else
                                        cskdcont  := " "
                                        ccedpcode := " "
                                        ncunits   := 0
                                        ccsubject := " "
                                endif
                                **Printing**
                                a2pinstpaysheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,18)
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                enddo
        endif
        cyytskdp->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
cyytskdp->(sx_settagorder(1))
return(nil)


*--------------------------------End of Acctrep--------------------------------*

function acct_recbl_by_col(nselect)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytskdp,cyytenrr,aprv2setup,;
      cfile,cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinstcode,cinstname,cskdcont,ccedpcode,ccsubject,ncunits,;
      clname,cfname,cperiod,ccolcode,cyytenrp,ayytpayp,a999payd,ccutoff,ccutoffdte
private cdummy := "acrcbl"+strzero(memvar->naccess,2),acrcbl   // account receivable
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Account Receivable by College  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytenrp  := alltrim("c"+cterm+"enrp")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        ayytpayp  := alltrim("a"+cterm+"payp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,2},;
                                     {,,"a999payd",,_DBF_SHARED,,1},;
                                     {,,"a999feep",,_DBF_SHARED,,1},;
                                     {,,"a999lbfp",,_DBF_SHARED,,1},;
                                     {,,"a999accp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(t999lst->tlname))
        cfname := space(len(t999lst->tfname))
        cperiod := space(1)
        ccolcode := "UC"
        ccutoff := displaydate(date())
        ccutoffdte := dtoc(date())
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                      - [NT-nautical MG-marine UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
                @ 05,02 say "Cutoff Date    :";
                        color memvar->colorarray[02];
                        get ccutoff    //pict "@!"
//                        valid ! empty(ccutoff)
                 read
//                        ccutoff := dtos(date())
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode)) .and. ! ccolcode $ "UC,NT,MG"
                        fask(10,"  College code not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
//                fask(10,"  "+ccutoff+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
//                fask(10,"  "+dtos(ctod(ccutoff))+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                ccutoffdte := dtos(ctod(ccutoff))
                if whereprint({||pacct_recbl_by_col(nselect,cterm,ccolcode,ccutoffdte)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pacct_recbl_by_col(nselect,cterm,ccolcode,ccutoff)
local abtext := {}, i:=1, init_pay, refno, ntotal := nbal := npage := 0, nEP,namtpd,;
      mtnstuds := mtntotal := mtnexcess := mtnstuds := mttuition := mtothers := mtdiscount := mtadj := mtepay := mtnbal := 0, ;
      mtint_pay := mtprelim := mtmidterm := mtprefinal := mtfinal := mtregfees := mtlabfees := mtcred_adj := 0, nline, ;
      namtprelim := namtmidterm := namtprefinal := namtfinal := nregfees := nlabfees := 0,;
      pd1, pd2, pd3, pd4, nadj, lrefunded := lwdrawn := .f., lrfamt := 0,;
      outbal := 0, cdate1,cdate2,cdate3,cdate4

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",09,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"nSTUDS"      ,"N",05,0},;
                                 {"CCODE"       ,"C",02,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"TUITION"     ,"N",12,2},;
                                 {"REGFEES"     ,"N",12,2},;
                                 {"LABFEES"     ,"N",12,2},;
                                 {"OTHERS"      ,"N",12,2},;
                                 {"DISCOUNT"    ,"N",12,2},;
                                 {"ADJ"         ,"N",12,2},;
                                 {"CREDIT_ADJ"  ,"N",12,2},;
                                 {"E_PAYMENTS"  ,"N",12,2},;
                                 {"INIT_PAY"    ,"N",12,2},;
                                 {"PRELIM"      ,"N",12,2},;
                                 {"MIDTERM"     ,"N",12,2},;
                                 {"PREFINAL"    ,"N",12,2},;
                                 {"FINAL"       ,"N",12,2},;
                                 {"TOTAL"       ,"N",14,2},;
                                 {"EXCESS"      ,"N",14,2},;
                                 {"RF_AMT"      ,"N",12,2},;
                                 {"REFUNDED"    ,"L",1,0},;
                                 {"WDRAWN"      ,"L",1,0},;
                                 {"BALANCE"     ,"N",14,2}},{||cdxacctrecbl()})
        dbcloseall()
        return(nil)
endif
memvar->acrcbl := memvar->cdummy
if(afile := openwcheck({{,,(memvar->acrcbl+".TXT"),"acrcbl",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
acrcbl->(__dbzap());acrcbl->(dbreindex())
c999colp->(dbseek(ccolcode))
aadd(abtext,{||" "+chr(15)})
//aadd(abtext,{||"UNIVERSITY OF CEBU - MAMBALING"+replicate(" ",193)+"Page "+transform(++npage,"999")})
if ! ccolcode == "UC"
        aadd(abtext,{||"UNIVERSITY OF CEBU - MAMBALING"+replicate(" ",169)+"Page "+transform(++npage,"999")})
else
        aadd(abtext,{||"UNIVERSITY OF CEBU - MAMBALING"+replicate(" ",146)+"Page "+transform(++npage,"999")})
endif

aadd(abtext,{||"Alumnos Mambaling, Cebu City"})
aadd(abtext,{||" "})
if nselect==1
        aadd(abtext,{||"PROJECTED RECEIVABLES BREAKDOWN "+if(ccolcode=="UC"," ","BY COLLEGE")})
else
        aadd(abtext,{||"RECEIVABLES BREAKDOWN "+if(ccolcode=="UC"," ","BY COLLEGE")})
endif
if ! ccolcode == "UC"
        aadd(abtext,{||"COLLEGE OF "+if(ccolcode=="NT","MARINE TRANSPORTATION",if(ccolcode=="MG","MARINE ENGINEERING",c999colp->coldesful))})
else
        aadd(abtext,{||"All Colleges"})
endif
aadd(abtext,{||term->name})

pd4 := displaydate(date())
if nselect==2
        aadd(abtext,{||"As of "+dtoc(stod(ccutoff))})  //dili pwede displaydate,stod,
endif

if ! ccolcode == "UC"
        aadd(abtext,{||"      "})
        aadd(abtext,{||"                                                             Outstanding         Debit         Total     Discounts        Credit        Prelim       Midterm    Semi-final         Final         Total           End"})
        aadd(abtext,{||"SEQ.  ID NO.   Name of Student                                             Adjustments         Debit                 Adjustments                                                                Credit       Balance"})
//                      9,999 12345678 123456789012345 123456789012345678901234 1  99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99
        aadd(abtext,{||replicate("-",211)})
else
        aadd(abtext,{||"      "})
        aadd(abtext,{||"                 Outstanding          Debit          Total      Discounts         Credit         Prelim        Midterm     Semi-final          Final          Total            End"})
        aadd(abtext,{||"Department                      Adjustments          Debit                   Adjustments                                                                     Credit        Balance"})
//                      123456789012  999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99 999,999,999.99
        aadd(abtext,{||replicate("-",185)})
endif
if ccolcode=="NT"
        ccolcode := "MV,MT,MI,PA"
elseif ccolcode == "MG"
        ccolcode := "MM,MA,MR,MP"
endif

//fask(10,"  "+transform(_MAX_LINE,"999")+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)

a999payd->(sx_setscope(_TOP_SCOPE   ,cterm))
a999payd->(sx_setscope(_BOTTOM_SCOPE,cterm))

a999payd->(dbseek(cterm+"1"))
pd1 := dtos(a999payd->pdcutofdat)
cdate1 := displaydate(a999payd->pdcutofdat)
a999payd->(dbseek(cterm+"2"))
pd2 := dtos(a999payd->pdcutofdat)
cdate2 := displaydate(a999payd->pdcutofdat)
a999payd->(dbseek(cterm+"3"))
pd3 := dtos(a999payd->pdcutofdat)
cdate3 := displaydate(a999payd->pdcutofdat)
a999payd->(dbseek(cterm+"4"))
pd4 := dtos(a999payd->pdcutofdat)
cdate4 := displaydate(a999payd->pdcutofdat)

/*
if empty(strtran(ccutoff,"/"))
        ccutofdate := cdate4
endif
*/

a999payd->(dbseek(cterm+"1"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        ayytpayp->(sx_setscope(_TOP_SCOPE   ,"1"+cyytenrp->enridno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,"1"+cyytenrp->enridno))
        if (cyytenrp->enrcolcod $ ccolcode)
                if a999accp->(dbseek("1"+cyytenrp->enridno))
                        nEP := nadj := namtpd := init_pay := 0
                        refno := ''
                        lrefunded := lwdrawn := .f.
                        lrfamt := 0
                        namtprelim := namtmidterm := namtprefinal := namtfinal := 0
                        ayytpayp->(dbgotop())
                        if ayytpayp->(dbseek("1"+cyytenrp->enridno))
                                do while (ayytpayp->payidno == ("1"+cyytenrp->enridno))
//                                   if (dtos(ayytpayp->payentdte) <= dtos(ccutoff)) .or. !empty(ayytpayp->payadjcod) .or. !empty(ayytpayp->paymach)
//                                fask(10,"  "+dtos(ayytpayp->payentdte)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
//                                fask(10,"  "+dtos(ccutoff)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                   if (dtos(ayytpayp->payentdte) <= ccutoff) .or. !empty(ayytpayp->payadjcod) .or. !empty(ayytpayp->paymach)
                                        if (ayytpayp->payadjcod $ "AJ,BK,LB,RE,GE,DP,TR,WD")
                                                nadj     += ayytpayp->payamt
                                        elseif (ayytpayp->payadjcod $ "EP,RF")
                                                nEP   += ayytpayp->payamt
                                        elseif (ayytpayp->payadjcod == "RF")
                                                lrefunded := .t.
                                                lrfamt   += ayytpayp->payamt
                                        elseif empty(ayytpayp->payadjcod) .and. empty(ayytpayp->paymach)
                                                namtpd += ayytpayp->payamt
                                                if (dtos(ayytpayp->payentdte) <= pd1)
                                                        namtprelim += ayytpayp->payamt
                                                elseif (dtos(ayytpayp->payentdte) > pd1) .and. (dtos(ayytpayp->payentdte) <= pd2)
                                                        namtmidterm += ayytpayp->payamt
                                                elseif (dtos(ayytpayp->payentdte) > pd2) .and. (dtos(ayytpayp->payentdte) <= pd3)
                                                        namtprefinal += ayytpayp->payamt
                                                else
                                                        namtfinal += ayytpayp->payamt
                                                endif
                                        endif
                                   endif
                                        ayytpayp->(dbskip())
                                enddo
                        endif
                        if lastkey() == K_ESC
                                exit
                        endif

                        fask(10,"  "+a999accp->acclname+", "+a999accp->accfname+" "+a999accp->accmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999colp->(dbseek(a999accp->acccolcod))

                        acrcbl->(dbappend())
                        acrcbl->idno     := a999accp->accidno
                        acrcbl->lname    := a999accp->acclname
                        acrcbl->fname    := a999accp->accfname
                        acrcbl->mname    := a999accp->accmname
                        acrcbl->ccode    := c999colp->colcod
                        acrcbl->course   := c999colp->coldesabr

                        procassess(cterm)

                        acrcbl->tuition := mttuition
                        acrcbl->regfees := mtregfees
                        acrcbl->others :=  mtothers+nadj        //(old balance)
                        acrcbl->labfees := mtlabfees

                        mttuition := mtregfees := mtothers := mtlabfees := 0

                        acrcbl->adj      := nadj
//                        ntotal           := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees + acrcbl->others + acrcbl->adj

                        namtpd := 0
                        ayytpayp->(dbgotop())
                        do while ! ayytpayp->(eof()) .and. namtpd < (ntotal-a999accp->accsytadsc)
                                if ayytpayp->paycolcod > "50" .and. ayytpayp->paycolcod < "B9"
                                        exit
                                endif
                                if empty(ayytpayp->payadjcod) .and. empty(ayytpayp->paymach)
                                        namtpd += ayytpayp->payamt
                                endif
                                if lastkey() == K_ESC
                                        exit
                                endif
                                ayytpayp->(dbskip())
                        enddo

                        acrcbl->rf_amt   := lrfamt
                        acrcbl->credit_adj := abs(nEP)
                        acrcbl->e_payments := namtpd + abs(nEP)
                        acrcbl->discount := a999accp->accsytadsc
                        acrcbl->total    := ntotal - acrcbl->e_payments - a999accp->accsytadsc
                        acrcbl->excess   := 0
                        if acrcbl->total < 0
                           acrcbl->excess := abs(acrcbl->total)-acrcbl->rf_amt
                           acrcbl->total  := 0
                        endif
                        acrcbl->balance  := a999accp->accbaltot
                        acrcbl->refunded := lrefunded
                        acrcbl->wdrawn   := lwdrawn

                        outbal := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees
                        ntotal := outbal + acrcbl->others - acrcbl->discount - acrcbl->credit_adj

                        acrcbl->prelim   := if(nselect==1,int(ntotal/4),namtprelim)
                        acrcbl->midterm  := if(nselect==1,int(ntotal/4),namtmidterm)
                        acrcbl->prefinal := if(nselect==1,int(ntotal/4),namtprefinal)
                        acrcbl->final    := if(nselect==1,ntotal-(int(ntotal/4)*3),namtfinal)

                        acrcbl->(dbcommit())
                        acrcbl->(dbunlock())
                endif
        elseif ccolcode == "UC"
                if a999accp->(dbseek("1"+cyytenrp->enridno))
                        nEP := nadj := namtpd := lrfamt := 0
                        mtprelim := mtmidterm := mtprefinal := mtfinal := 0
                        lrefunded := lwdrawn := .f.
                        ayytpayp->(dbgotop())
                        if ayytpayp->(dbseek("1"+cyytenrp->enridno))
                                do while (ayytpayp->payidno == ("1"+cyytenrp->enridno))
                                   if (dtos(ayytpayp->payentdte) <= ccutoff) .or. !empty(ayytpayp->payadjcod) .or. !empty(ayytpayp->paymach)
                                        if (ayytpayp->payadjcod $ "AJ,BK,LB,RE,GE,DP,TR,WD")
                                                nadj     += ayytpayp->payamt
                                        elseif (ayytpayp->payadjcod $ "EP,RF")
                                                nEP   += ayytpayp->payamt
                                        elseif (ayytpayp->payadjcod == "RF")
                                                lrefunded := .t.
                                                acrcbl->refunded := .t.
                                                lrfamt   += ayytpayp->payamt
                                        elseif empty(ayytpayp->payadjcod) .and. empty(ayytpayp->paymach)
                                                namtpd += ayytpayp->payamt
                                                if (dtos(ayytpayp->payentdte) <= pd1)
                                                        namtprelim += ayytpayp->payamt
                                                        mtprelim += ayytpayp->payamt
                                                elseif (dtos(ayytpayp->payentdte) > pd1) .and. (dtos(ayytpayp->payentdte) <= pd2)
                                                        namtmidterm += ayytpayp->payamt
                                                        mtmidterm += ayytpayp->payamt
                                                elseif (dtos(ayytpayp->payentdte) > pd2) .and. (dtos(ayytpayp->payentdte) <= pd3)
                                                        namtprefinal += ayytpayp->payamt
                                                        mtprefinal += ayytpayp->payamt
                                                else
                                                        namtfinal += ayytpayp->payamt
                                                        mtfinal += ayytpayp->payamt
                                                endif
                                        endif
                                   endif
                                        ayytpayp->(dbskip())
                                enddo
                        endif
                        if lastkey() == K_ESC
                                exit
                        endif
                        fask(10,"  "+a999accp->acclname+", "+a999accp->accfname+"  "+a999accp->accmname+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999colp->(dbseek(cyytenrp->enrcolcod))
//                        if acrcbl->(dbseek(c999colp->coldesabr+"-"+c999colp->colcod))
                        if acrcbl->(dbseek(c999colp->coldesabr))
                                acrcbl->(reclock())
                                ++acrcbl->nstuds
                        else
                                acrcbl->(dbappend())
                                acrcbl->lname    := c999colp->coldesabr
//                                acrcbl->lname    := c999colp->coldesabr+"-"+c999colp->colcod
                                acrcbl->fname    := cyytenrp->enrcolcod
                                acrcbl->course   := c999colp->coldesabr
                                acrcbl->ccode    := c999colp->colcod
                                acrcbl->nstuds   := 1
                                acrcbl->refunded := .f.
                        endif

                        procassess(cterm)
                        acrcbl->tuition += mttuition
                        acrcbl->regfees += mtregfees
                        acrcbl->others  += mtothers+nadj
                        acrcbl->labfees += mtlabfees

                        acrcbl->adj += nadj
                        ntotal := mttuition + mtregfees + mtlabfees + mtothers + nadj
                        namtpd := 0
                        ayytpayp->(dbgotop())
                        do while ! ayytpayp->(eof()) .and. namtpd < (ntotal-a999accp->accsytadsc)
                                if ayytpayp->paycolcod > "50" .and. ayytpayp->paycolcod < "B9"
                                        exit
                                endif
                                if empty(ayytpayp->payadjcod) .and. empty(ayytpayp->paymach)
                                        namtpd += ayytpayp->payamt
                                endif
                                if lastkey() == K_ESC
                                        exit
                                endif
                                ayytpayp->(dbskip())
                        enddo
                acrcbl->rf_amt     += lrfamt
                acrcbl->credit_adj += abs(nEP)
                acrcbl->e_payments += (namtpd + abs(nEP))
                acrcbl->discount   += a999accp->accsytadsc
                if (ntotal - (namtpd + abs(nEP)) - a999accp->accsytadsc) > 0
                        acrcbl->total += ntotal - (namtpd + abs(nEP)) - a999accp->accsytadsc
                else
                        acrcbl->excess += abs(ntotal - (namtpd + abs(nEP)) - a999accp->accsytadsc) - lrfamt
                endif

                ntotal := mttuition + mtregfees + mtlabfees + mtothers - ;
                          (a999accp->accsytadsc + abs(nEP))

                acrcbl->prelim   += if(nselect==1,int(ntotal/4),namtprelim)
                acrcbl->midterm  += if(nselect==1,int(ntotal/4),mtmidterm)
                acrcbl->prefinal += if(nselect==1,int(ntotal/4),mtprefinal)
                acrcbl->final    += if(nselect==1,ntotal-(int(ntotal/4)*3),mtfinal)
                acrcbl->balance  += a999accp->accbaltot
                acrcbl->(dbcommit())
                acrcbl->(dbunlock())
                endif
        endif
        cyytenrp->(dbskip())
enddo
ayytpayp->(clearscope())
a999payd->(clearscope())

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE-21, {||__eject()})
acrcbl->(dbgotop())

mttuition := mtothers := mtdiscount := mtadj := mtint_pay := mtntotal := ;
nbal := mtnbal := mtprelim := mtmidterm := mtprefinal := mtfinal := 0

if ! ccolcode == "UC"
do while ! acrcbl->(eof())
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), abtext, prow() + 1, _MAX_LINE-21, {||__eject()})
/*
        ntotal := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees + acrcbl->others + acrcbl->adj
        nbal   := ntotal - acrcbl->e_payments - acrcbl->discount
*/
        outbal := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees
        ntotal := outbal + acrcbl->others
        nbal   := ntotal - acrcbl->e_payments - acrcbl->discount

//9,999 12345678 123456789012345 123456789012345678901234 1  99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99

        outexpr(prow()+01,00,transform(i++,"9,999")+" "+right(acrcbl->idno,8)+" "+acrcbl->lname+" "+acrcbl->fname+" "+acrcbl->mname+"  "+;
                transform(outbal,      "99,999,999.99")+" "+;
                transform(acrcbl->others,          "99,999,999.99")+" "+;
                transform(ntotal,               "99,999,999.99")+" "+;
                transform(acrcbl->discount,     "99,999,999.99")+" "+;
                transform(acrcbl->credit_adj,   "99,999,999.99")+" "+;
                transform(acrcbl->prelim,       "99,999,999.99")+" "+;
                transform(acrcbl->midterm,      "99,999,999.99")+" "+;
                transform(acrcbl->prefinal,     "99,999,999.99")+" "+;
                transform(acrcbl->final,        "99,999,999.99")+" "+;
                transform(acrcbl->discount+acrcbl->credit_adj+acrcbl->prelim+acrcbl->acrcbl->midterm+acrcbl->prefinal+acrcbl->final,"99,999,999.99")+" "+;
                transform(ntotal-(acrcbl->discount+;
                            acrcbl->credit_adj+;
                            acrcbl->prelim+;
                            acrcbl->midterm+;
                            acrcbl->prefinal+;
                            acrcbl->final),"99,999,999.99"))
//                transform(if(nselect==1,nbal,acrcbl->balance),"99,999,999.99"))
/*
                transform(acrcbl->init_pay,     "99,999,999.99")+" "+;
                transform( if(nbal>=0, acrcbl->prelim  + acrcbl->midterm+;
                                       acrcbl->prefinal+ acrcbl->final,;
                                       nbal),   "99,999,999.99")+"   "+replicate("_",10))
*/
                        mttuition  += outbal            //(Outstanding Balance)
                        mtothers   += acrcbl->others    //(Debit Adjustments)
                        mtadj      += ntotal            //(Total Debit)
                        mtdiscount += acrcbl->discount
                        mtcred_adj += acrcbl->credit_adj
                        mtprelim   += acrcbl->prelim
                        mtmidterm  += acrcbl->midterm
                        mtprefinal += acrcbl->prefinal
                        mtfinal    += acrcbl->final
        acrcbl->(dbskip())
enddo
outexpr(prow()+01,00,replicate("Ä",211))
        acrcbl->(dbseek("TOTAL"))
        ntotal := mttuition + mtregfees + mtlabfees + mtothers + mtadj
//        nbal   := ntotal + mtadj - (mtdiscount + mtint_pay)
//outexpr(prow()+01,59,
        outexpr(prow()+01,0,"TOTAL"+space(54)+;
                             transform(mttuition,            "99,999,999.99")+" "+;
                             transform(mtothers,             "99,999,999.99")+" "+;
                             transform(mtadj,                "99,999,999.99")+" "+;
                             transform(mtdiscount,           "99,999,999.99")+" "+;
                             transform(mtcred_adj,           "99,999,999.99")+" "+;
                             transform(mtprelim,             "99,999,999.99")+" "+;
                             transform(mtmidterm,            "99,999,999.99")+" "+;
                             transform(mtprefinal,           "99,999,999.99")+" "+;
                             transform(mtfinal,              "99,999,999.99")+" "+;
                             transform(mtdiscount+mtcred_adj+mtprelim+mtmidterm+mtprefinal+mtfinal,              "99,999,999.99")+" "+;
                             transform(mtadj-(mtdiscount+mtcred_adj+mtprelim+mtmidterm+mtprefinal+mtfinal),             "99,999,999.99"))
if nselect==2
        outexpr(prow()+02,0,"CUT-OFF    PRELIM:"+cdate1+"   MIDTERM:"+cdate2+"   SEMI-FINAL:"+cdate3+"   FINAL:"+cdate4)
endif
else
do while ! acrcbl->(eof())
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), abtext, prow() + 1, _MAX_LINE-21, {||__eject()})
/*
        ntotal := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees + acrcbl->others + acrcbl->adj
        nbal   := ntotal - acrcbl->e_payments - acrcbl->discount
*/
        outbal := acrcbl->tuition + acrcbl->regfees + acrcbl->labfees
        ntotal := outbal + acrcbl->others
        nbal   := ntotal - acrcbl->e_payments - acrcbl->discount

//9,999 12345678 123456789012345 123456789012345678901234 1  99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99 99,999,999.99

//        outexpr(prow()+01,00,alltrim(acrcbl->lname)+"-"+alltrim(acrcbl->fname) + space(11-len(alltrim(acrcbl->lname))-len(alltrim(acrcbl->fname)))+ "  "+;
        outexpr(prow()+01,00,alltrim(acrcbl->lname) + space(12-len(alltrim(acrcbl->lname)))+ "  "+;
                transform(outbal,              "999,999,999.99")+" "+;
                transform(acrcbl->others,      "999,999,999.99")+" "+;
                transform(ntotal,              "999,999,999.99")+" "+;
                transform(acrcbl->discount,    "999,999,999.99")+" "+;
                transform(acrcbl->credit_adj,  "999,999,999.99")+" "+;
                transform(acrcbl->prelim,      "999,999,999.99")+" "+;
                transform(acrcbl->midterm,     "999,999,999.99")+" "+;
                transform(acrcbl->prefinal,    "999,999,999.99")+" "+;
                transform(acrcbl->final,       "999,999,999.99")+" "+;
                transform(acrcbl->discount+acrcbl->credit_adj+acrcbl->prelim+acrcbl->acrcbl->midterm+acrcbl->prefinal+acrcbl->final,"999,999,999.99")+" "+;
                transform(ntotal-(acrcbl->discount+;
                            acrcbl->credit_adj+;
                            acrcbl->prelim+;
                            acrcbl->acrcbl->midterm+;
                            acrcbl->prefinal+;
                            acrcbl->final),"999,999,999.99"))
//                if(acrcbl->refunded,"RF-"+transform(acrcbl->rf_amt,"99,999.99"),"____________"))
//                transform(if(nselect==1,nbal,acrcbl->balance),"99,999,999.99"))

                        mttuition  += outbal
                        mtothers   += acrcbl->others
                        mtadj      += ntotal
                        mtdiscount += acrcbl->discount
                        mtcred_adj += acrcbl->credit_adj
                        mtprelim   += acrcbl->prelim
                        mtmidterm  += acrcbl->midterm
                        mtprefinal += acrcbl->prefinal
                        mtfinal    += acrcbl->final

        acrcbl->(dbskip())
enddo
outexpr(prow()+01,00,replicate("Ä",185))
        acrcbl->(dbseek("TOTAL"))
        ntotal := mttuition + mtregfees + mtlabfees + mtothers + mtadj
//        nbal   := ntotal + mtadj - (mtdiscount + mtint_pay)

//outexpr(prow()+01,14,
        outexpr(prow()+01,0,"TOTAL"+space(9)+;
                             transform(mttuition,            "999,999,999.99")+" "+;
                             transform(mtothers,             "999,999,999.99")+" "+;
                             transform(mtadj,                "999,999,999.99")+" "+;
                             transform(mtdiscount,           "999,999,999.99")+" "+;
                             transform(mtcred_adj,           "999,999,999.99")+" "+;
                             transform(mtprelim,             "999,999,999.99")+" "+;
                             transform(mtmidterm,            "999,999,999.99")+" "+;
                             transform(mtprefinal,           "999,999,999.99")+" "+;
                             transform(mtfinal,              "999,999,999.99")+" "+;
                             transform(mtdiscount+mtcred_adj+mtprelim+mtmidterm+mtprefinal+mtfinal,              "999,999,999.99")+" "+;
                             transform(mtadj-(mtdiscount+mtcred_adj+mtprelim+mtmidterm+mtprefinal+mtfinal),             "999,999,999.99"))
if nselect==2
        outexpr(prow()+02,0,"CUT-OFF    PRELIM:"+cdate1+"   MIDTERM:"+cdate2+"   SEMI-FINAL:"+cdate3+"   FINAL:"+cdate4)
endif
endif
@ prow()+00,00 say chr(18)
__eject()
//fask(10,"  End of Account Receivable Routine ...  ",{" Ok "},memvar->colorarray[06],.t.,nil)
closewcheck(afile)
return(nil)

static function cdxacctrecbl()
field course,lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname      tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on course                 tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

static function acctrcvblheader(cdesc)
nline := 4
setprc(00,00)
outexpr(00,55,"UNIVERSITY OF CEBU - METC")
outexpr(01,53,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,56,alltrim(cdesc))
return(nil)

static function procassess(cterm)
local skdno,nctr:=0
a999feep->(dbseek(a999accp->accfeeyr+cyytenrp->enrcolcod+right(cterm,1)))
memvar->nfeeunit  := a999feep->feeperunit
/*
if cyytenrp->enridno == "03947587"
fask(10,"  Fee/Unit    : "+transform(a999feep->feeperunit,"99,999.99")+";  "+;
        "  Misc        : "+transform(a999feep->feetotmisc,"99,999.99")+";  "+;
        "  Registration: "+transform(a999feep->feereg,"99,999.99")+";  "+;
        "  Total       : "+transform(a999feep->feeperunit+a999feep->feetotmisc+a999feep->feereg,"99,999.99")+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
endif
*/
xunit := cyytenrp->enrunt

mttuition := mtregfees := mtothers := mtlabfees := 0

mtregfees += a999feep->feetotmisc + a999feep->feereg
mtothers += a999accp->accbalold

for nctr := 1 to 17
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                cyytskdp->(dbseek(cyytenrp->&skdno))
              if left(cyytskdp->skdsubcod,2) $ "NS,NT,CW,LE,MT,NR" .and. cyytskdp->skdcolcod == "**"
                        xunit -= cyytskdp->skdunt
                        a999lbfp->(dbseek(a999accp->accfeeyr+cyytskdp->skdintcod+"**"))
                        if right(cterm,1) == "1"
                                mtlabfees += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                mtlabfees += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                mtlabfees += a999lbfp->lbfamt3
                        endif
                else
                        a999lbfp->(dbseek(a999accp->accfeeyr+cyytskdp->skdintcod+cyytskdp->skdcolcod))
                        if right(cterm,1) == "1"
                                mtlabfees += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                mtlabfees += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                mtlabfees += a999lbfp->lbfamt3
                        endif
                endif
        else
                exit
        endif
next
mttuition += xunit * memvar->nfeeunit

//mttuition := mtregfees := mtothers := mtlabfees := 0
/*
if cyytenrp->enridno == "03947587"
fask(10,"  Tuition: "+transform(mttuition,"99,999.99")+";  "+;
        "  RegFees: "+transform(mtregfees,"99,999.99")+";  "+;
        "  Labfees: "+transform(mtlabfees,"99,999.99")+";  "+;
        "  Total  : "+transform(mttuition+mtregfees+mtlabfees,"99,999.99")+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
endif
*/
return(nil)

// ---------------------------------------------------------------------


function studbalbyterm()
local getlist := {}, alastscr, nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,cprocsts,ccolcode:="UC",aentryscr

private cdummy := "sterm"+strzero(memvar->naccess,2),sterm

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
alastscr := savescr(01,00,24,79)
do while .t.
        restscr(alastscr)
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Student Balances by Term  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
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
        if ! file("/crunlib/"+"c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
//        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+memvar->cterm+"enrp"
        ayytpayp := "a"+memvar->cterm+"payp"
        ayytassp := "a"+memvar->cterm+"assp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,4},;
                                      {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,2},;
                                      {,, ayytassp ,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        memvar->ccourse := space(len(c999colp->colnamcol))
//        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Student Balances  ")
        commandline("³          F4 - View College           ³          ESC - Previous               ³")
        aentryscr := savescr(01,00,24,79)
//        fask(10," Press any key to continue . . .  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
          //      @ 02,22 say "[AC-All Courses / SC-Special Courses]"
                @ 04,02 say "College Code :";
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! ccolcode $ "UC,MV,MM,MI,MR,PA,MP" .and. ! c999colp->(dbseek(ccolcode))
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                c999colp->(dbseek(ccolcode))
                memvar->ccourse := c999colp->colnamcol
                if whereprint({||pstudbalbyterm(ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)

enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

function pstudbalbyterm(ccolcode)
local abtext := {}, ncol, nmaxcol := 80, npage := 0, ccourse := space(06),;
        nOA:=nAssess:=nTuition:=0

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
//aadd(abtext,{||space(titlepos("STUDENTS' BALANCES REPORT",nmaxcol))+"STUDENTS' BALANCES REPORT"})
aadd(abtext,{||space(titlepos(alltrim(memvar->ccourse),nmaxcol))+alltrim(memvar->ccourse)})
aadd(abtext,{||space(titlepos(alltrim(term->name),nmaxcol))+alltrim(term->name)})
aadd(abtext,{||""})
aadd(abtext,{||"  ID No.     Last Name          First Name         M  Old Acct.    Assessment    Tuition  "})
aadd(abtext,{||"--------- --------------- ------------------------ -  ---------    ----------    ---------"})

/*
  ID No.     Last Name          First Name         M Old Acct. Assessment Tuition
--------- --------------- ------------------------ - --------- ---------- ---------
123456789 123456789012345 123456789012345678901234 1 12,123.12 123,123.12 12,123.12

*/

pageprint(abtext)

if ccolcode == "UC"
        a999accp->(sx_settagorder(2))
else
        a999accp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        a999accp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif
/*
if ccolcode $ "ACSC"
        a999accp->(sx_settagorder(2))
else
        a999accp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        a999accp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif

                if a999accp->acccolcod $ "MTMIMSPAMAMRMDMEMPRO"
                if val(a999accp->acccolcod) > 51 .and. val(a999accp->acccolcod) < 100
*/
a999accp->(dbgotop())
do while ! a999accp->(eof())
        if cyytenrp->(dbseek(right(a999accp->accidno,8)))
                fask(10,"  Processing student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+alltrim(a999accp->accmname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                ayytpayp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
                ayytpayp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
                ayytpayp->(dbgotop())
                do while ! ayytpayp->(eof()) .and. ! (ayytpayp->payadjcod == "OA")
                        ayytpayp->(dbskip())
                enddo
                if (ayytpayp->payadjcod == "OA") .and. (ayytpayp->payamt>=5000)
                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                        if c999colp->(dbseek(a999accp->acccolcod))
                                ccourse := c999colp->coldesabr
                        elseif a999stcp->(dbseek(a999accp->acccolcod))
                                ccourse := a999stcp->stcdesabr
                        endif
                        @ prow()+01,00 say a999accp->accidno+" "+;
                                           a999accp->acclname+" "+;
                                           a999accp->accfname+" "+;
                                           a999accp->accmname+"  "+;
                                           transform(ayytpayp->payamt,"@Z 99,999.99")+"     "+;
                                           transform(a999accp->accsytass,"@Z 99,999.99")+"    "+;
                                           transform(a999accp->accsyttui,"@Z 99,999.99")
                        nOA     += ayytpayp->payamt
                        nAssess += a999accp->accsytass
                        nTuition+= a999accp->accsyttui
//                        ccourse := space(06)
                endif
                ayytpayp->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        a999accp->(dbskip())
enddo
@ prow()+01,00 say replicate("-",90)
@ prow()+01,00 say replicate(" ",51)+;
                   transform(nOA,"@Z 9,999,999.99")+"  "+;
                   transform(nAssess,"@Z 9,999,999.99")+" "+;
                   transform(nTuition,"@Z 9,999,999.99")

a999accp->(clearscope())
a999accp->(sx_settagorder(4))
__eject()
return(nil)

*------------------------------------------------------------------------------*


