* Program       :  ENTRY.PRG
* Author        :  jHUN bENLOT and tOPE fLORENTINO (c) Dec 2001
* Installation  :  UC-METC

#Include "Inkey.Ch"
#Include "SixCdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

#define _CODE           1
#define _DESCRIPTION    2
#define _AMOUNT         3
#define _EMPTY_ELEMENT {space(04),;
                        space(20),;
                        0}

*------------------------------------------------------------------------------*
* start of payment entry codes
*------------------------------------------------------------------------------*
function setscr()
@ 03,05 say "ÜÛÛßÛÜ                                                 ÛßÛÛ   ÛßÛÛ ÛßÛÛ" color memvar->colorarray[51]
@ 04,05 say " ÛÛ Û                                                  Û ÛÛ   Û ÛÛ Û ÛÛ" color memvar->colorarray[51]
@ 05,05 say "ßÛÛÜÛß                                                 Û ÛÛ   Û ÛÛ Û ÛÛ" color memvar->colorarray[51]
@ 06,05 say " ÛÛ                                                    ÛÜÛÛ ß ÛÜÛÛ ÛÜÛÛ" color memvar->colorarray[51]
return(nil)

function setscr1()
@ 03,12 say "                                                ÛßÛÛ   ÛßÛÛ ÛßÛÛ" color memvar->colorarray[51]
@ 04,12 say "                                                Û ÛÛ   Û ÛÛ Û ÛÛ" color memvar->colorarray[51]
@ 05,12 say "                                                Û ÛÛ   Û ÛÛ Û ÛÛ" color memvar->colorarray[51]
@ 06,12 say "                                                ÛÜÛÛ ß ÛÜÛÛ ÛÜÛÛ" color memvar->colorarray[51]
return(nil)

function payent(cunit)
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist,aentryscr,opay,bindex,bitems,aetryscr,;
      ayytpayp,byytpayp,aprv1setup,ascr3,ccashno
private aitems := {},nindex := 1, ntotamt := 0, lpassedit,;
        cstudnam,ccourse,cyear,cterm := space(03), cacctno := space(08),;
        corno:=space(7),ndollrate:=0,nrendered:=0,nchange:=0,lconf := .f.,;
        vtotamt:="",vchange:="",vchholder:=0, orseqno:=space(8)

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ocash := createabrowse(bitems,bindex,11,03,21,53,;
                        {|xnmode,xoabrowser,xaxparam|fpay(xnmode,xoabrowser,xaxparam,cunit)},;
                        {{{||"  "+memvar->aitems[memvar->nindex,_CODE]+"  "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_DESCRIPTION]+"   "},nil},;
                         {{||"  "+transform(memvar->aitems[memvar->nindex,_AMOUNT],"@Z 99,999,999.99")+" "},nil}},;
                        {"  Code  ","  D e s c r i p t i o n  ","      Amount    "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"})
*                         xx1234xx    xx12345678901234567890xx    x23,123,456.12xx
/*
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
*/

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"},;
                           {,,"csctrl",,_DBF_SHARED,,1,"/arunlib"}}))==nil
        return(nil)
endif

do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Payment Entry  ")
        draw_box1(02,02,07,77,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        ascr := savescr(01,00,24,79)
        draw_box2(10,21,14,58,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        draw_box1(11,45,13,54,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        @ 12,25 say "Enter School Term :";
                color memvar->colorarray[02]
        @ 12,48 get memvar->cterm pict "@!";
                color memvar->colorarray[02];
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
        if term->status == "C"
                fask(10,"   Transaction for "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if csctrl->(dbseek(memvar->cterm))
                fask(10,"   Transaction for "+alltrim(term->name)+" was already forwarded.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\arunlib\a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("b"+memvar->cterm+"payp.dbf")
                fask(10,"  B"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

//memvar->orseqno := strtran(transform(val(left(para->c1orseqno,6))+1,"######")," ","0")+"C"
/*
        if ! file("cs0"+right(cunit,1)+".dbf")
                fask(10,"  CS0"+right(cunit,1)+".DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
*/
        aentryscr    := savescr(01,00,24,79)
        ayytpayp     := alltrim("a"+memvar->cterm+"payp")
        byytpayp     := alltrim("b"+memvar->cterm+"payp")
//        ccashno      := alltrim("cs0"+right(cunit,1))
        if(aprvsetup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                                  {,,"a999ctrl",,_DBF_SHARED,,1,"/arunlib"},;
                                  {,,"a999stcp",,_DBF_SHARED,,1,"/arunlib"},;
                                  {,,"b999chrt",,_DBF_SHARED,,1},;
                                  {,,"blocklst",,_DBF_SHARED,,1,"/crunlib"},;
                                  {,,"para"    ,,_DBF_SHARED,,1},;
                                  {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,7,"/arunlib"},;
                                  {,, byytpayp ,"byytpayp",_DBF_SHARED,,5}}))==nil
                return(nil)
        endif
        do while .t.
                memvar->cacctno := space(len(a999accp->(accidno)))
                memvar->cname   := space(35)
                memvar->ccolcod := space(02)
                memvar->cyear   := space(01)
                memvar->aitems := {_EMPTY_ELEMENT}
                memvar->nindex := 1
                inkey(0)
                restscr(ascr)
                commandline("³            F4 - View Student          ³            ESC - Previous            ³")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 08,03 say "ID Number       : ";
                        color memvar->colorarray[02];
                        get memvar->cacctno     pict "@!";
                        //valid !empty(memvar->cacctno)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if ! empty(memvar->cacctno) .and. ! a999accp->(dbseek(memvar->cacctno))
                        fask(10,"  Student number: "+memvar->cacctno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if blocklst->(dbseek(right(memvar->cacctno,8)))
                        fask(10," Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                endif

                if empty(memvar->cacctno)
                setcursor(1);set(_SET_CONFIRM,.t.)
                        @ 09,03 say "Student Name    :  " color memvar->colorarray[02]
                        @ 08,58 say "Course    :  "       color memvar->colorarray[02]
                        @ 09,58 say "Year      :  "       color memvar->colorarray[02]

                        @ 09,22 get memvar->cname pict "@!"
                        @ 08,71 get memvar->ccolcod pict "@!"
                        @ 09,71 get memvar->cyear pict "9"
                        read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                endif

                if ! a999accp->(dbseek(memvar->cacctno))
                        fask(10,"  TESDA Student...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
//                        fask(10,"  ID No. : "+alltrim(memvar->cacctno)+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
//                        loop
                endif

                setkey(K_F4,nil)
                para->(dbgotop())
//                ccashno->(dbgotop())
                memvar->dollrate := para->dollrate
                memvar->ntenderamt := 0
                do case
                        case cunit == "C1"
                                memvar->orseqno := strtran(transform(val(left(para->c1orseqno,6))+1,"######")," ","0")+"C"
//                                memvar->orseqno := strtran(transform(val(left(ccashno->orseqno,6))+1,"######")," ","0")+"C"
                        case cunit == "C2"
                                memvar->orseqno := strtran(transform(val(left(para->c2orseqno,6))+1,"######")," ","0")+"B"
                        case cunit == "C3"
                                memvar->orseqno := strtran(transform(val(left(para->c3orseqno,6))+1,"######")," ","0")+"A"
                        case cunit == "E1"
                                memvar->orseqno := "123456A"
                endcase
//                fask(10,"  O.R. Sequence No. : "+memvar->orseqno+"  ",{" Ok "},memvar->colorarray[02],.t.,nil)
                bdollar := .f.
                draw_box2(10,56,21,77,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(16,57,20,76,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 12, 57 to 12, 76 color memvar->colorarray[02]
                if !empty(memvar->cacctno)
                @ 09,03 say "Student Name    :  "+alltrim(a999accp->(acclname))+", "+alltrim(a999accp->(accfname))+" "+alltrim(a999accp->(accmname))+".";
                        color memvar->colorarray[02]
                @ 08,58 say "Course    :  "+alltrim(a999accp->(acccolcod));
                        color memvar->colorarray[02]
                @ 09,58 say "Year      :  "+a999accp->(accyrlevl);
                        color memvar->colorarray[02]

                @ 09,22 say alltrim(a999accp->(acclname))+", "+alltrim(a999accp->(accfname))+" "+alltrim(a999accp->(accmname))+".";
                        color memvar->colorarray[01]
                @ 08,71 say alltrim(a999accp->(acccolcod));
                        color memvar->colorarray[01]
                @ 09,71 say a999accp->(accyrlevl);
                        color memvar->colorarray[01]
                endif
                @ 11,67 say memvar->orseqno;
                        color memvar->colorarray[01]
                @ 11,58 say "OR No. :";
                        color memvar->colorarray[02]
                @ 14,58 say "® Exchange  Rate ¯";
                        color memvar->colorarray[02]
                @ 18,61 say "$ 1 = P "+transform(memvar->dollrate,"99.99");
                        color memvar->colorarray[02]

                @ 22,03 say "Total: P "    color memvar->colorarray[02]
                @ 22,28 say "Tendered: P " color memvar->colorarray[02]
                @ 22,56 say "Change: P " color memvar->colorarray[02]
                setscr()
                ntotamt := 0
                byytpayp->(dbgotop())
                echototalamt()
                dispbox(10,02,21,54,_SINGLE_LINE)
                connectline(12,02,54)
                ocash:gotop()
                stabilize(ocash,.t.)
                commandline("³Ù-Add/Edit³Del-Delete³F1-$Payment³F5-Tender³F8-Update$³F10-Save ³ESC-Previous³")
                browsearray(ocash,{""},{|b|b:gotop()})
                dbunlockall();dbcommitall()
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return nil

static function fpay(xnmode,xoabrowser,xaxparam,cunit)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case xnmode == 0
                @ 11,03 say "  Code     D e s c r i p t i o n        Amount     "color memvar->colorarray[35]
                return 1
        case lastkey() == K_ENTER
                editcash(xoabrowser)
                echototalamt()
        case lastkey() == K_DEL .and. ! (len(memvar->aitems) == 1)
                if fask(13,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        memvar->ntotamt -= memvar->aitems[memvar->nindex,_AMOUNT]
                        echototalamt()
                        adel(memvar->aitems,memvar->nindex)
                        asize(memvar->aitems,len(memvar->aitems) - 1)
                        xoabrowser:refreshall()
                        stabilize(xoabrowser)
                        __keyboard(chr(K_F10))
                else
                        clearbuffer()
                endif
        case lastkey() == K_F10
                tenderamt(xoabrowser)
                if len(memvar->aitems) <= 1
                        fask(13,"  Can't save.  No items entered.  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(record(bdollar,cunit))
                endif
                clearbuffer()
        case lastkey() == K_F8
                rdollar(xoabrowser)
        case lastkey() == K_F5
                tenderamt(xoabrowser)
        case lastkey() == K_F1
                bdollar := !bdollar
                if bdollar
                        @ 03,05 say "ÜÛÜÛÜ " color memvar->colorarray[51]
                        @ 04,05 say "ÛÛÜÜÜ " color memvar->colorarray[51]
                        @ 05,05 say "   ÛÛ " color memvar->colorarray[51]
                        @ 06,05 say "ßÛßÛß " color memvar->colorarray[51]
                        @ 22,11 say "$" color memvar->colorarray[02]
                        @ 22,39 say "$" color memvar->colorarray[02]
                        @ 22,67 say "$" color memvar->colorarray[02]
                else
                        @ 03,05 say "ÜÛÛßÛÜ" color memvar->colorarray[51]
                        @ 04,05 say " ÛÛ Û " color memvar->colorarray[51]
                        @ 05,05 say "ßÛÛÜÛß" color memvar->colorarray[51]
                        @ 06,05 say " ÛÛ   " color memvar->colorarray[51]
                        @ 22,11 say "P" color memvar->colorarray[02]
                        @ 22,39 say "P" color memvar->colorarray[02]
                        @ 22,67 say "P" color memvar->colorarray[02]
                endif
        endcase
return 2

static function echototalamt(cunit)
local i,nlen,ntotamt:=0
setscr1()
nlen := len(memvar->aitems)
if nlen>1
        for i := 1 to nlen-1
                ntotamt += memvar->aitems[i,_AMOUNT]
        next
endif
ascr1 := savescr(06,76,07,80)
@ 22,12 say transform(memvar->ntotamt,"@ZP 99,999,999.99")
@ 03,47 say vtotamt := AmtToVisio(ntotamt)
        if ntotamt >= 1000
                @ 6, 46 say " ßÝ" color memvar->colorarray[51]
        endif

        if ntotamt >= 10000000
                @ 6, 28 say " ßÝ" color memvar->colorarray[51]
                @ 6, 46 say " ßÝ" color memvar->colorarray[51]
        endif
restscr(ascr1)
return(nil)

static function record(bdollar,cunit)
local nlastelem
nmax := len(memvar->aitems)
nctr := 1
        para->(dbgotop())
        do while ! para->(reclock())
                fask(20," Saving record(s)...  ",{" Ok "},memvar->colorarray[05],.f.,nil)
        enddo
        do case
                case cunit == "C1"
                        para->c1orseqno := left(memvar->orseqno,7)
                case cunit == "C2"
                        para->c2orseqno := left(memvar->orseqno,7)
                case cunit == "C3"
                        para->c3orseqno := left(memvar->orseqno,7)
        endcase
        para->(dbcommit())
        para->(dbunlock())

while !Isprinter()
        fask(17," ERROR Printer not ready....",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
printor(cunit)

do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"   Saving code "+alltrim(memvar->aitems[nctr,_DESCRIPTION])+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        //byytpayp->(recycle())
        byytpayp->(dbappend())
        if empty(alltrim(memvar->cacctno))
                byytpayp->payidno    := "TESDA"
        endif
                byytpayp->payidno    := memvar->cacctno
                byytpayp->paydte     := date()
                byytpayp->paycode    := memvar->aitems[nctr,_CODE]
                byytpayp->payorno    := memvar->orseqno+if(bdollar,"$","")
                if b999chrt->(dbseek(byytpayp->paycode))
                        byytpayp->paycolcod  := b999chrt->(acccode)
                endif
                byytpayp->payyrlevl  := a999accp->(accyrlevl)
                byytpayp->paysyt     := memvar->cterm
        if !bdollar
                byytpayp->paypesoamt := memvar->aitems[nctr,_AMOUNT]
        else
                byytpayp->paypesoamt := memvar->aitems[nctr,_AMOUNT]*para->dollrate
                byytpayp->paydollamt := memvar->aitems[nctr,_AMOUNT]
        endif
        para->(dbgotop())
        byytpayp->payentdte  := date()
        byytpayp->payenttme  := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
        byytpayp->payentusr  := substr(memvar->cusername,1,8)
        byytpayp->payclass   := left(memvar->aitems[nctr,_CODE],1)
        byytpayp->payseqno   := para->seqno+1
        byytpayp->paytag     := "P"
        byytpayp->(dbcommit())
        byytpayp->(dbunlock())
        para->(reclock())
        ++para->seqno
        para->(dbcommit())
        para->(dbunlock())

        if  byytpayp->payclass != "M"
                if ! ayytpayp->(dbseek(byytpayp->payidno+byytpayp->payorno+dtos(byytpayp->paydte)))
                        ayytpayp->(recycle())
                        ayytpayp->payidno   := byytpayp->payidno
                        ayytpayp->payrefno  := byytpayp->payorno
                        ayytpayp->paydte    := byytpayp->paydte
                        ayytpayp->paycolcod := byytpayp->paycolcod
                        ayytpayp->payyrlevl := byytpayp->payyrlevl
                        ayytpayp->paysyt    := byytpayp->paysyt
                        ayytpayp->payamt    := if(right(byytpayp->payorno,1)=="$",byytpayp->paydollamt,byytpayp->paypesoamt)
                        ayytpayp->payentdte := byytpayp->paydte
                        ayytpayp->payenttme := byytpayp->payenttme
                        ayytpayp->payentusr := byytpayp->payentusr
                        ayytpayp->paytag    := _POSTED
                else
                        ayytpayp->(reclock())
                        ayytpayp->payamt += if(right(byytpayp->payorno,1)=="$",byytpayp->paydollamt,byytpayp->paypesoamt)
                endif
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                if a999accp->(dbseek(ayytpayp->payidno))
                        a999accp->(reclock())
                        a999accp->accamtpd  += if(right(byytpayp->payorno,1)=="$",byytpayp->paydollamt,byytpayp->paypesoamt)
                        a999accp->accbaltot -= if(right(byytpayp->payorno,1)=="$",byytpayp->paydollamt,byytpayp->paypesoamt)
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
        endif

        ++nctr
enddo
return(0)

static function editcash(oabrowser)
local getlist := {}, nrec, acmdline := savescr(24,00,24,79),acmddetail,;
      nlastcursor := setcursor(), lconfirm := set(_SET_CONFIRM),;
      nlastrec := len(memvar->aitems),nrow := row(), cprocsts,;
      nmax := 0, nctr := 0, llab := .f., lscode := .f.

oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
acmddetail               := savescr(24,00,24,79)

** initialize **
memvar->ccode            := memvar->aitems[memvar->nindex,_CODE]
memvar->desc             := memvar->aitems[memvar->nindex,_DESCRIPTION]
memvar->amount           := memvar->aitems[memvar->nindex,_AMOUNT]
memvar->ntotamt          += memvar->aitems[memvar->nindex,_AMOUNT]
do while .t.
        restscr(acmddetail)
        commandline("³              F4-View Code            ³             ESC-Previous              ³")
        setcursor(1);set(_SET_CONFIRM,.t.)
        setkey(K_F4,{||viewchart({||__keyboard(chr(K_CTRL_LEFT)+;
        b999chrt->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,05 get memvar->ccode    pict "@!";
                  valid validate(memvar->ccode)
        @ nrow,40 get memvar->amount   pict "@Z  ##,###,###.##";
                  valid !zero(memvar->amount)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
/*
        if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_CODE] == memvar->ccode})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"     Duplicate Entries...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
        endif
*/
        if lastkey() == K_ENTER
                nlastelem := len(memvar->aitems)
                        memvar->aitems[nindex,_CODE] := memvar->ccode
                        b999chrt->(dbseek(memvar->ccode))
                        memvar->aitems[nindex,_DESCRIPTION] := b999chrt->desc
                        memvar->aitems[nindex,_AMOUNT] := memvar->amount
                        memvar->ntotamt += memvar->aitems[memvar->nindex,_AMOUNT]
                        if nlastelem == memvar->nindex
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

static function validate(ccode)
local nrec
if empty(ccode) .or. ! b999chrt->(dbseek(ccode))
        return(.f.)
endif
if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_CODE] == ccode})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"     Duplicate Entries...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        return(.f.)
                endif
endif

if b999chrt->(dbseek(ccode))
        @ row(),14 say b999chrt->desc
endif
return(.t.)

static function zero(num)
if num==0
        return(.t.)
endif
return(.f.)


static Function AmtToVisio( nAmt )
Local   GetList := {}, nStrAmt:=" ", nChrAmt:=" ", nDecPlace := 1

nStrAmt := str( nAmt, 12, 2 )
nChrAmt := " "
prow := 0
If nAmt <= 0.00
        Return( nChrAmt )
EndIf
Do While .T.
        If ! SubStr( nStrAmt, nDecPlace, 1 ) == " "
                Do Case
                        Case nDecPlace == 1     //(" ")
                                prow := 13
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 2     //(" ")
                                prow := 18
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 3     //(1)
                                prow := 23
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 4     //(2)
                                prow := 31
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 5     //(3)
                                prow := 36
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 6     //(4)
                                prow := 41
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 7     //(5)
                                prow := 49
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 8     //(6)
                                prow := 54
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 9     //(7)
                                prow := 59
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 10    //(.)
                                prow := 64
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 11    //(0)
                                prow := 66
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                        Case nDecPlace == 12    //(0)
                                prow := 71
                                nChrAmt := DotToNine( SubStr( nStrAmt, nDecPlace, 1 ), prow )
                EndCase
        EndIf
        ++nDecPlace
        If nDecPlace > 12
                Exit
        EndIf
EndDo
Return( nChrAmt )


static Function DotToNine( nAmt, prow )
Do Case
        Case nAmt == "."
                @ 3, 64 say "  " color memvar->colorarray[51]
                @ 4, 64 say "  " color memvar->colorarray[51]
                @ 5, 64 say "  " color memvar->colorarray[51]
                @ 6, 64 say " ß" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "0"
                @ 3, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 4, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 5, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 6, prow say " ÛÜÛÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "1"
                @ 3, prow say " ßÛÛ " color memvar->colorarray[51]
                @ 4, prow say "  ÛÛ " color memvar->colorarray[51]
                @ 5, prow say "  ÛÛ " color memvar->colorarray[51]
                @ 6, prow say " ÜÛÛÜ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "2"
                @ 3, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 4, prow say "   ÛÛ" color memvar->colorarray[51]
                @ 5, prow say "  ÜÛß" color memvar->colorarray[51]
                @ 6, prow say " ÛÛÜÜ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "3"
                @ 3, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 4, prow say "   ÛÛ" color memvar->colorarray[51]
                @ 5, prow say "  ßÛÜ" color memvar->colorarray[51]
                @ 6, prow say " ÛÜÛÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "4"
                @ 3, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 4, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 5, prow say " ßßÛÛ" color memvar->colorarray[51]
                @ 6, prow say "   ÛÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "5"
                @ 3, prow say " ÛÛßß" color memvar->colorarray[51]
                @ 4, prow say " ÛÛ  " color memvar->colorarray[51]
                @ 5, prow say " ßßÛÛ" color memvar->colorarray[51]
                @ 6, prow say " ÛÜÛÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "6"
                @ 3, prow say " ÛÛßÛ" color memvar->colorarray[51]
                @ 4, prow say " ÛÛ  " color memvar->colorarray[51]
                @ 5, prow say " ÛÛßÛ" color memvar->colorarray[51]
                @ 6, prow say " ÛÛÜÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "7"
                @ 3, prow say " ßßÛÛ" color memvar->colorarray[51]
                @ 4, prow say "   ÛÛ" color memvar->colorarray[51]
                @ 5, prow say " ÜÛß " color memvar->colorarray[51]
                @ 6, prow say " ÛÛ  " color memvar->colorarray[51]
                prow := 0
        Case nAmt == "8"
                @ 3, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 4, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 5, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 6, prow say " ÛÜÛÛ" color memvar->colorarray[51]
                prow := 0
        Case nAmt == "9"
                @ 3, prow say " ÛßÛÛ" color memvar->colorarray[51]
                @ 4, prow say " Û ÛÛ" color memvar->colorarray[51]
                @ 5, prow say " ßßÛÛ" color memvar->colorarray[51]
                @ 6, prow say " ÛÜÛÛ" color memvar->colorarray[51]
                prow := 0
EndCase
return (nil)


static function rdollar(oabrowser)
local nlastcursor:=setcursor(),lconfirm:=set(_SET_CONFIRM)
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})

        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 18,69 get memvar->dollrate pict "99.99";
                color memvar->colorarray[56];
                valid ! empty(memvar->dollrate)
        read
        @ 18,69 say memvar->dollrate pict "99.99";
                color memvar->colorarray[02]
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
                return
        endif
        if (para->(dollrate)  != memvar->dollrate) .or. ;
           (para->(rdolldate) != date())
                para->(reclock())
                para->dollrate  := memvar->dollrate
                para->rdolldate := date()
                para->(dbcommit())
                para->(dbunlock())
        endif
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
return(nil)

static function tenderamt(oabrowser)
local nlastcursor:=setcursor(),lconfirm:=set(_SET_CONFIRM)
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})

        setcursor(1);set(_SET_CONFIRM,.t.)
        setscr1()
        ascr2 := savescr(06,76,07,80)
        @ 22,40 get memvar->ntenderamt pict "99,999,999.99";
                color memvar->colorarray[56];
                valid ! empty(memvar->ntenderamt)
        read
        @ 22,40 say memvar->ntenderamt pict "99,999,999.99";
                color memvar->colorarray[01]
        @ 22,65 say vchholder:=memvar->ntenderamt-memvar->ntotamt pict "99,999,999.99";
                color memvar->colorarray[01]
        @ 03,47 say vchange := AmtToVisio(vchholder)
        if vchholder >= 1000
                @ 6, 46 say " ßÝ" color memvar->colorarray[51]
        endif

        if vchholder >= 1000000
                @ 6, 28 say " ßÝ" color memvar->colorarray[51]
                @ 6, 46 say " ßÝ" color memvar->colorarray[51]
        endif
        restscr(ascr2)
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
                return
        endif

oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
return(nil)


static function printOR(cunit)
local nmax, nctr, ntotamt, stext
set device to printer
@ 00,02 say "     UNIVERSITY OF CEBU -  METC"
@ 01,02 say "    Alumnos Mambaling, Cebu City"
// OLD TIN # // @ 02,02 say "        TIN  600-000-551-709"
@ 02,02 say "        TIN  000-551-709-002"
//@ 03,02 say "          S/N "+if(cunit=="C1","212240800165","212200200132")
@ 03,02 say "          S/N "+if(cunit=="C1","212240800165","212240800165")
@ 04,02 say "-------------------------------------"
@ 05,02 say "  4OFFICIAL RECEIPT5"       //Large size red color
//@ 05,02 say "          OFFICIAL RECEIPT"     //Normal size no color
//@ 05,02 say "          4OFFICIAL RECEIPT5"   //Normal size red color
@ 06,02 say "-------------------------------------"
@ 07,02 say "OR NO. "+memvar->orseqno
@ 07,19 say displaydate(date())+"  "+AmPm(time())
if alltrim(memvar->cacctno) == ""
        stext := memvar->cname
else
        stext := right(memvar->cacctno,8)+" ";
                +alltrim(a999accp->(acclname))+", ";
                +alltrim(a999accp->(accfname))+" ";
                +alltrim(a999accp->(accmname))+"."
        stext := strtran(stext,"¥","Å")
endif
@ 09,02 say stext
@ 10,02 say ""
@ 11,02 say "-1CODE-0 -1DESCRIPTION-0               -1AMOUNT-0"

nmax := len(memvar->aitems)
nctr := 1
ntotamt := 0
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        b999chrt->(dbseek(memvar->aitems[nctr,_CODE]))
        stext := memvar->aitems[nctr,_CODE] + " " + alltrim(b999chrt->desc)
        stext := padr(stext,37-len(transform(memvar->aitems[nctr,_AMOUNT],"99,999,999.99")))
        stext+=transform(memvar->aitems[nctr,_AMOUNT],"99,999,999.99")
        @prow()+01,02 say stext
        ntotamt += memvar->aitems[nctr,_AMOUNT]
        ++nctr
enddo
stext := padl("TOTAL",19)
stext := padr(stext,37-len("P "+alltrim(transform(ntotamt,"99,999,999.99"))))
if !bdollar
        stext += ("P "+alltrim(transform(ntotamt,"99,999,999.99")))
else
        stext += ("$ "+alltrim(transform(ntotamt,"99,999,999.99")))
endif
//@ prow()+02,02 say chr(27)+"E"+stext+chr(27)+"F"
@ prow()+02,02 say stext
@ prow()+02,02 say "           Keep this O.R."
@ prow()+01,02 say "  for future complaints.  Thank you."
//@ prow()+02,02 say "          File and present"
//@ prow()+01,02 say "  for further references. Thank you."
@ prow()+02,02 say "CS-"+right(cunit,1)+" "+alltrim(substr(memvar->cusername,1,8))

@ prow()+01,00 say chr(27)+"a"+chr(8)
//@ prow()+01,00 say space(01)
setprc(00,00)

set device to screen
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
*------------------------------------------------------------------------------*
* end of payment entry codes
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* start of chart entry codes
*------------------------------------------------------------------------------*
function chartent()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      ccode,cname,namt,lexist:=.f.,aprvsetup,aentryscr,cprocsts
if(aprvsetup:=openwcheck({{,,"b999chrt",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
boxshadow(06,19,15,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Chart Entry  ")
commandline("³           F4 - View Code             ³           ESC - Previous              ³")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        ccode   := space(len(b999chrt->code))
        cname   := space(len(b999chrt->desc))
        namt    := 0
        setkey(K_F4,{||viewchart({||__keyboard(chr(K_CTRL_LEFT)+;
        b999chrt->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 08,21 say "Code  :";
                color memvar->colorarray[02];
                get ccode pict "@!";
                valid ! empty(ccode)
        read
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if lexist := b999chrt->(dbseek(ccode))
                b999chrt->(reclock())
                cname := b999chrt->desc
                namt  := b999chrt->amt
        endif
        commandline("³              F12 - Delete            ³             ESC - Previous            ³")
        setkey(K_F12,{||delcode(ccode)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 10,21 say "Desc. :";
                color memvar->colorarray[02];
                get cname pict "@!"
        @ 12,21 say "Amount:";
                color memvar->colorarray[02];
                get namt pict "9999999.99"
        read
        @ 12,29 say namt pict "9,999,999.99"
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(16,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
        if ! lexist
                b999chrt->(recycle())
        endif
        b999chrt->code          := ccode
        b999chrt->desc          := cname
        b999chrt->amt           := namt
        b999chrt->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
        b999chrt->(dbcommit())
        b999chrt->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

static function delcode(ccode)
if fask(17,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        b999chrt->code := _DELETE_TAG
        b999chrt->(dbdelete())
        b999chrt->(dbcommit())
        b999chrt->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*------------------------------------------------------------------------------*
* end of chart entry codes
*------------------------------------------------------------------------------*

