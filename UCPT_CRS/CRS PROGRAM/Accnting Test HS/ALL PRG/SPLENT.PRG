* Program       :       SPLENT.PRG - Special Course Entry
* Author        :       Randy F. Santizo
* Updated       :       Lorenzo D. Benlot Jr.
* Date          :       June 9, 2K
* Installation  :       UC-METC

#Include "Inkey.Ch"
#Include "SixCdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

*------------------------------------------------------------------------------*
function splacctent()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,lexist:=.f.,aentryscr,ayytpayp,cprocsts,;
      cterm
private cacctno,clname,cfname,cmname,ccode,cdesc,dstarted,ntotalfee,nstudents,lok

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(04,16,20,62,"лплллмлл ",memvar->colorarray[11],"  Special Course Account Entry  ")
        commandline("Г           F4 - View Term File            Г         ESC - Previous            Г")
        @ 06,17 say replicate("Ф",45)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,18 say "School Term :";
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
        @ 05,36 say "- "+substr(term->name,1,24)
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        ayytpayp        := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,1},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"idnocon",,_DBF_SHARED,,,"/crunlib"},;
                                   {,,"para",,_DBF_SHARED,,}})) == nil
                return(nil)
        endif
        do while .t.
                restscr(aentryscr)
                commandline("Г   F4 - View Account     Г      F6 - New Acct. #      Г    ESC - Previous     Г")
                memvar->cacctno   := space(len(a999accp->accidno))
                memvar->clname    := space(len(a999accp->acclname))
                memvar->cfname    := space(len(a999accp->accfname))
                memvar->cmname    := space(len(a999accp->accmname))
                memvar->ccode     := space(len(a999accp->acccolcod))
                memvar->cdesc     := space(len(a999stcp->stcdesabr))
                memvar->dstarted  := date()
                memvar->ntotalfee := 0
                memvar->nstudents := 1
                memvar->lok       := .f.
                clearbuffer()
                setkey(K_F4,{||vacctname(space(len(a999accp->accidno)),cprocsts,memvar->colorarray[10])})
                setkey(K_F6,{||createacctno()})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 07,18 say "Account Number :";
                        color memvar->colorarray[02];
                        get memvar->cacctno pict "@!";
                        valid ! empty(memvar->cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F6,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! memvar->lok
                        if ! a999accp->(dbseek(memvar->cacctno))
                                fask(10,"  Account no. not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        memvar->clname  := a999accp->acclname
                        memvar->cfname  := a999accp->accfname
                        memvar->cmname  := a999accp->accmname
                endif
                setkey(K_F4,{||if(readvar()=="MEMVAR->CCODE",vsplcode(space(len(a999stcp->stccod)),cprocsts),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 09,18 say "Last Name. . . :";
                        color memvar->colorarray[02];
                        get memvar->clname pict "@!"
                @ 10,18 say "First Name . . :";
                        color memvar->colorarray[02];
                        get memvar->cfname pict "@!"
                @ 11,18 say "Middle Initial :";
                        color memvar->colorarray[02];
                        get memvar->cmname pict "@!"
                @ 13,18 say "Short Term Code. . :";
                        color memvar->colorarray[02];
                        get memvar->ccode pict "@!";
                        valid checkcode(memvar->ccode,cprocsts,13)
                @ 14,18 say "Date Started . . . :";
                        color memvar->colorarray[02];
                        get memvar->dstarted valid ! empty(memvar->dstarted)
                @ 15,18 say "Total Fee. . . . . :";
                        color memvar->colorarray[02];
                        get memvar->ntotalfee pict "999,999.99";
                        valid memvar->ntotalfee > 0
                @ 16,18 say "Number of Students :";
                        color memvar->colorarray[02];
                        get memvar->nstudents pict "999"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F6,nil)
                if lastkey() == K_ESC
                        loop
                endif
                if a999ctrl->(dbseek(cterm+memvar->ccode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(20,"   Are you sure to save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ayytpayp->(recycle())
                para->(dbgoto(1))
                ayytpayp->payrefno := alltrim(str(para->seriesno))+space(08-len(alltrim(str(para->seriesno))))
                ayytpayp->payidno       := memvar->cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := memvar->dstarted
                ayytpayp->paycolcod     := memvar->ccode
                ayytpayp->payyrlevl     := space(01)
                ayytpayp->paysyt        := cterm
                ayytpayp->paymach       := str(memvar->nstudents,4)
                ayytpayp->paytelr       := space(02)
                ayytpayp->paybalbefr    := 0
                ayytpayp->payamt        := memvar->ntotalfee
                ayytpayp->paybalaftr    := 0
                ayytpayp->paytag        := _SHORT_TERM
                ayytpayp->payadjcod     := "ST"
                ayytpayp->payentdte     := date()
                ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                ayytpayp->payentws      := " "
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                para->(reclock())
                para->seriesno := para->seriesno + 1
                para->(dbcommit())
                para->(dbunlock())

                **updated account master file (accp)**
                if a999accp->(dbseek(memvar->cacctno))
                        a999accp->(reclock())
                else
                        a999accp->(recycle())
                endif
                a999accp->accidno       := memvar->cacctno
                a999accp->acclname      := memvar->clname
                a999accp->accfname      := memvar->cfname
                a999accp->accmname      := memvar->cmname
                a999accp->acccolcod     := memvar->ccode
                a999accp->accyrlevl     := space(01)
                a999accp->accsytstr     := space(05)
                a999accp->accsyt        := cterm+space(02)
                a999accp->accst         := space(01)
                a999accp->acccode       := space(04)
                a999accp->accadj        += memvar->ntotalfee
                a999accp->accduetot     += memvar->ntotalfee
                a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
                a999accp->(dbcommit())
                a999accp->(dbunlock())

        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function createacctno()
local i,fs,d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd

//a999accp->(sx_settagorder(0))
//a999accp->(dbgobottom())

idnocon->(dbgotop())
i := val(substr(idnocon->spnumber,4,5))
i++
fs := right(dtoc(date()),2)+transform(i,"99999")
d1 := substr(fs,1,1)
d2 := val(substr(fs,2,1))
d3 := substr(fs,3,1)
d4 := val(substr(fs,4,1))
d5 := substr(fs,5,1)
d6 := val(substr(fs,6,1))
d7 := substr(fs,7,1)
s1 := val(d1)*2
   s1 := transform(s1,"99")
   s1 := val(substr(s1,1,1))+val(substr(s1,2,1))
s2 := val(d3)*2
    s2 := transform(s2,"99")
    s2 := val(substr(s2,1,1))+val(substr(s2,2,1))
s3 := val(d5)*2
    s3 := transform(s3,"99")
    s3 := val(substr(s3,1,1))+val(substr(s3,2,1))
s4 := val(d7)*2
    s4 := transform(s4,"99")
    s4 := val(substr(s4,1,1))+val(substr(s4,2,1))
chd := transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
chd := int(10-val(chd))
if chd == 10
    memvar->cacctno := "3"+fs+"0"
else
    memvar->cacctno := "3"+fs+transform(chd,"9")
end
memvar->lok := .t.

idnocon->(reclock())
idnocon->spnumber       := memvar->cacctno
idnocon->rectrail       := dtoc(date())+";"+time()+";"+memvar->cusername
idnocon->(dbcommit())
idnocon->(dbunlock())

a999accp->(sx_settagorder(1))
return(nil)


static function checkcode(ccode,cprocsts,nline)
if ! a999stcp->(dbseek(ccode))
        vsplcode({||__keyboard(chr(K_CTRL_LEFT)+a999stcp->stccod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ nline,42 say "- "+a999stcp->stcdesabr
return(.t.)

*------------------------------------------------------------------------------*

function splpayentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate,ayytpayp,;
      cterm,cpayno,dpay,cacctno,xacctno,npayamt,xpayamt,ctype

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(04,17,21,64,"лплллмлл ",memvar->colorarray[11]," Special Course Payment Entry ")
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
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(name)+" was already closed.   ;"+;
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
                clearbuffer()
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
                if ayytpayp->(dbseek(cpayno+dtos(dpay)))
                        fask(10,"   Record already exists.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
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
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil);setkey(K_F12,nil)
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
                ayytpayp->(recycle())
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
                ayytpayp->payentdte     := date()
                ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                ayytpayp->payentws      := " "
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                **updated account master file (accp)**
                a999accp->(dbseek(cacctno))
                a999accp->(reclock())
                a999accp->accamtpd  += npayamt
                a999accp->accbaltot -= npayamt
                a999accp->(dbcommit())
                a999accp->(dbunlock())
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function forsplbal()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,ccolcode,nbal,nadj,ctime:="",xtime,nctr,ncol,;
      ayytpayp,xyytpayp,xyytassp
private xterm
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Forward Account Balances by College  ")
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
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+cterm+"payp"
        xyytpayp  := "a"+memvar->xterm+"payp"
        xyytassp  := "a"+memvar->xterm+"assp"
        if(aprv2setup:=openwcheck({{,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,"a999accp",,_DBF_SHARED,,3},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,1},;
                                   {,,xyytpayp,"xyytpayp",_DBF_SHARED,,2},;
                                   {,,xyytassp,"xyytassp",_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"para",,_DBF_SHARED,,}}))==nil
                return(nil)
        endif
        if ! fask(10,"  Proceed processing ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        para->(dbgotop())
        nctr := para->seriesno
        a999stcp->(dbgotop())
        do while ! a999stcp->(eof())
                fask(06,"  Processing code "+a999stcp->stccod+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
                if a999ctrl->(dbseek(cterm+a999stcp->stccod)) .and. a999ctrl->fflag == _FORWARDED
                        fask(10,"  Transaction for "+a999stcp->stccod+" "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                else
                        **begin processing**
                        a999accp->(sx_setscope(_TOP_SCOPE   ,a999stcp->stccod))
                        a999accp->(sx_setscope(_BOTTOM_SCOPE,a999stcp->stccod))
                        a999accp->(dbgotop())
                        do while ! a999accp->(eof())
                                fask(12," Processing student number "+a999accp->accidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                store 0 to nbal
                                if xyytassp->(dbseek(a999accp->accidno))
                                        nbal := xyytassp->asstotal
                                endif
                                xyytpayp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
                                xyytpayp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
                                xyytpayp->(dbgotop())
                                do while ! xyytpayp->(eof())
                                        fask(18,"  Processing document no. "+alltrim(xyytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        do case
                                                case xyytpayp->paytag == _SHORT_TERM
                                                        nbal += xyytpayp->payamt
                                                case xyytpayp->paytag == _DISCOUNT
                                                        nbal -= xyytpayp->payamt
                                                case xyytpayp->paytag == _POSTED
                                                        nbal -= xyytpayp->payamt
                                                case xyytpayp->paytag == _ADJUSTMENT
                                                        nbal += xyytpayp->payamt
                                                case xyytpayp->paytag == _FORWARDED
                                                        nbal += xyytpayp->payamt
                                        endcase
                                        xyytpayp->(dbskip())
                                enddo
                                xyytpayp->(clearscope())
                                if ! alltrim(str(nbal,9,2)) == "0.00"
                                        a999accp->(reclock())
                                        a999accp->acccode       := space(04)
                                        a999accp->accsytpdsc    := 0
                                        a999accp->accsytadsc    := 0
                                        a999accp->accfeeunt     := 0
                                        a999accp->accsytunt     := 0
                                        a999accp->accsyttui     := 0
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
                                        ayytpayp->(dbappend())
                                        ayytpayp->payrefno      := alltrim(str(++nctr,8))
                                        ayytpayp->payidno       := a999accp->accidno
                                        ayytpayp->paytyp        := space(01)
                                        ayytpayp->paydte        := date()
                                        ayytpayp->paycolcod     := a999accp->acccolcod
                                        ayytpayp->payyrlevl     := a999accp->accyrlevl
                                        ayytpayp->paysyt        := cterm
                                        ayytpayp->payamt        := nbal
                                        ayytpayp->paytag        := _FORWARDED
                                        ayytpayp->payadjcod     := if(nbal>0,"OA","EP")
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
                                endif
                                a999accp->(dbskip())
                        enddo
                        a999accp->(clearscope())

                        ** write control file **
                        if a999ctrl->(dbseek(memvar->xterm+a999stcp->stccod))
                                a999ctrl->(reclock())
                        else
                                a999ctrl->(recycle())
                        endif
                        a999ctrl->term          := memvar->xterm
                        a999ctrl->ccode         := a999stcp->stccod
                        a999ctrl->date          := date()
                        a999ctrl->fflag         := _FORWARDED
                        a999ctrl->status        := _CLOSED
                        a999ctrl->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
                        a999ctrl->(dbcommit())
                        a999ctrl->(dbunlock())

                        if a999ctrl->(dbseek(cterm+a999stcp->stccod))
                                a999ctrl->(reclock())
                        else
                                a999ctrl->(recycle())
                        endif
                        a999ctrl->term      := cterm
                        a999ctrl->ccode     := a999stcp->stccod
                        a999ctrl->date      := date()
                        a999ctrl->fflag     := _FORWARDED
                        a999ctrl->status    := space(01)
                        a999ctrl->rectrail  := dtoc(date())+","+time()+","+memvar->cusername
                        a999ctrl->(dbcommit())
                        a999ctrl->(dbunlock())
                endif
                a999stcp->(dbskip())
        enddo
        ** write para file **
        para->(reclock())
        para->seriesno := ++nctr
        para->(dbcommit())
        para->(dbunlock())
        fask(18,"   Processing finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
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

*------------------------------------------------------------------------------*

function updsplacct()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,ayytpayp,;
      cterm,cacctno,ctrnno,clname,cfname,cmname,ccode,;
      dstarted,ntotalfee,nstudents,xacctno,xtotalfee
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(04,16,20,62,"лплллмлл ",memvar->colorarray[11],"  Update Special Course Account  ")
        commandline("Г           F4 - View Term File            Г         ESC - Previous            Г")
        @ 06,17 say replicate("Ф",45)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,18 say "School Term :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
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
        @ 05,36 say "- "+alltrim(term->name)
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet available.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        ayytpayp        := "a"+cterm+"payp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,8},;
                                   {,,"a999stcp",,_DBF_SHARED,,1},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        do while .t.
                restscr(aentryscr)
                ctrnno    := space(len(ayytpayp->payrefno))
                cacctno   := space(len(a999accp->accidno))
                clname    := space(len(a999accp->acclname))
                cfname    := space(len(a999accp->accfname))
                cmname    := space(len(a999accp->accmname))
                ccode     := space(len(a999accp->acccolcod))
                dstarted  := date()
                ntotalfee := 0
                nstudents := 1
                clearbuffer()
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 07,18 say "Transaction No.:";
                        color memvar->colorarray[02];
                        get ctrnno pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if ayytpayp->(dbseek(ctrnno+_SHORT_TERM))
                        fask(10,"   Record is not a short term course.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! ayytpayp->(dbseek(ctrnno))
                        fask(10,"   Record not found in file.   ",{" OK "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ayytpayp->(dbseek(ctrnno+_SHORT_TERM))
                        a999accp->(dbseek(ayytpayp->payidno))
                        cacctno         := ayytpayp->payidno
                        clname          := a999accp->acclname
                        cfname          := a999accp->accfname
                        cmname          := a999accp->accmname
                        ccode           := ayytpayp->paycolcod
                        dstarted        := ayytpayp->paydte
                        ntotalfee       := ayytpayp->payamt
                        nstudents       := val(ayytpayp->paymach)
                        xacctno         := ayytpayp->payidno
                        xtotalfee       := ayytpayp->payamt
                        if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. ! a999ctrl->status == _CLOSED
                                if rights("[RESTRICT]")
                                        setkey(K_F12,{||delsplacct(cacctno,ntotalfee,ctrnno)})
                                endif
                        endif
                        commandline("Г     F4 - View Student    Г       F12 - Delete        Г     ESC - Previous    Г")
                endif
                setkey(K_F4,{||if(readvar()=="CACCTNO",vacct(space(len(a999accp->accidno)),cprocsts,memvar->colorarray[10]),;
                               if(readvar()=="CCODE",vsplcode(space(len(a999stcp->stccod)),cprocsts,memvar->colorarray[10]),))})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 09,18 say "Account Number :";
                        color memvar->colorarray[02];
                        get cacctno pict "@!";
                        valid vacct(cacctno,cprocsts)
                @ 10,18 say "Last Name. . . :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 11,18 say "First Name . . :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
                @ 12,18 say "Middle Initial :";
                        color memvar->colorarray[02];
                        get cmname pict "@!"
                @ 14,18 say "Short Term Code. . :";
                        color memvar->colorarray[02];
                        get ccode pict "@!";
                        valid checkcode(ccode,cprocsts,14)
                @ 15,18 say "Date Started . . . :";
                        color memvar->colorarray[02];
                        get dstarted valid ! empty(dstarted)
                @ 16,18 say "Total Fee. . . . . :";
                        color memvar->colorarray[02];
                        get ntotalfee pict "999,999.99";
                        valid ntotalfee > 0
                @ 17,18 say "Number of Students :";
                        color memvar->colorarray[02];
                        get nstudents pict "999"
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
                ayytpayp->(reclock())
                ayytpayp->payidno       := cacctno
                ayytpayp->paytyp        := space(01)
                ayytpayp->paydte        := dstarted
                ayytpayp->paycolcod     := ccode
                ayytpayp->payyrlevl     := space(01)
                ayytpayp->paysyt        := cterm
                ayytpayp->paymach       := str(nstudents,4)
                ayytpayp->paytelr       := space(02)
                ayytpayp->paybalbefr    := 0
                ayytpayp->payamt        := ntotalfee
                ayytpayp->paybalaftr    := 0
                ayytpayp->paytag        := _SHORT_TERM
                ayytpayp->payadjcod     := "ST"
                ayytpayp->payentdte     := date()
                ayytpayp->payenttme     := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                ayytpayp->payentusr     := substr(memvar->cusername,1,8)
                ayytpayp->payentws      := " "
                ayytpayp->(dbcommit())
                ayytpayp->(dbunlock())

                **updated account master file (accp)**
                if ! cacctno = xacctno
                        ** new file **
                        a999accp->(dbseek(cacctno))
                        a999accp->(reclock())
                        a999accp->accadj    += ntotalfee
                        a999accp->accduetot += ntotalfee
                        a999accp->accbaltot += ntotalfee
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())

                        ** old file **
                        a999accp->(dbseek(xacctno))
                        a999accp->(reclock())
                        a999accp->accadj    -= xtotalfee
                        a999accp->accduetot -= xtotalfee
                        a999accp->accbaltot -= xtotalfee
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                else
                        a999accp->(dbseek(cacctno))
                        a999accp->(reclock())
                        a999accp->accadj    -= xtotalfee
                        a999accp->accduetot -= xtotalfee
                        a999accp->accbaltot -= xtotalfee
                        a999accp->accadj    += ntotalfee
                        a999accp->accduetot += ntotalfee
                        a999accp->accbaltot += ntotalfee
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

function vacct(cacctno,cprocsts)
if ! a999accp->(dbseek(cacctno))
        vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 10,18 say "                 "+a999accp->acclname
@ 10,18 say "Last Name. . . : " color memvar->colorarray[02]
@ 11,18 say "                 "+a999accp->accfname
@ 11,18 say "First Name . . : " color memvar->colorarray[02]
@ 12,18 say "                 "+a999accp->accmname
@ 12,18 say "Middle Initial : " color memvar->colorarray[02]
return(.t.)


static function delsplacct(cacctno,ntotalfee,ctrnno)
if fask(20,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        **payment file**
        ayytpayp->(reclock())
        ayytpayp->payrefno := _DELETE_TAG
        ayytpayp->(dbdelete())
        ayytpayp->(dbcommit())
        ayytpayp->(dbunlock())

        **account master file**
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accadj    -= ntotalfee
        a999accp->accduetot -= ntotalfee
        a999accp->accbaltot -= ntotalfee
        a999accp->(dbcommit())
        a999accp->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*------------------------------------------------------------------------------*
