* Program       :  ASSENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) October 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------

function assbystud()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,cname,cacctno,ayytassp,cyytskdp,lrecord:="Y",cvar:=""
private nfeeunit,nunits,ntuition,nlab,nreg,noth,nmisc,ntotass,cstatus,;
        cfeeyr,clname,cfname,cmname,ccourseyr,ccolcode,cyrlevl,ccls
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Create Assessment by Account  ")
        commandline("Г        F4 - View Term/College File       Г         ESC - Previous            Г")
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
        cyytenrp  := "c"+cterm+"enrp"
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999feep",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999lbfp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Account No.  :";
                        color memvar->colorarray[02];
                        get cacctno     pict "@!";
                        valid ! empty(cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if a999accp->(dbseek(cacctno)) .and.;
                   !cyytenrp->(dbseek(right(cacctno,8)))
                        fask(10,"  Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif !a999accp->(dbseek(cacctno)) .and.;
                       !cyytenrp->(dbseek(right(cacctno,8)))
                                fask(10,"   Student not enrolled this semester.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                elseif ayytassp->(dbseek(cacctno)) .and.;
                       !ayytassp->asstag $ _CHANGED+_POSTED
                                fask(10,"   Students assessment not yet posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
/*                elseif !ayytassp->(dbseek(cacctno))
                        fask(10," Students assessment not yet created and posted. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop*/
                endif
                if !ayytassp->(dbseek(cacctno))
                        fask(10," Students assessment not yet created and posted. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        if fask(10,"  Create Assessment?  ",{" No "," Yes "},memvar->colorarray[03],.t.,nil)==2
                                ayytassp->(recycle())
                                ayytassp->(reclock())
                                ayytassp->assidno := cacctno
                                ayytassp->asstag := "U"
                                ayytassp->(dbcommit())
                                ayytassp->(dbunlock())
                        else
                                loop
                        endif
                endif
                if a999ctrl->(dbseek(cterm+a999accp->acccolcod)) .and. a999ctrl->status == _CLOSED
                        fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                                "              No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                commandline("Г            F10 - Record              Г           ESC - Previous              Г")
                initvar()
                procsubj(cacctno)
                procassess(cterm,cacctno,cname)
                cvar := " "
                do while .t.
                        setkey(K_F10,{||record(cacctno,cterm)})
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

static function procsubj(cacctno)
local nline:=05,nctr:=0,skdno,xunit:=0
draw_box2(02,02,04,33,memvar->colorarray[30],memvar->colorarray[31],,.f.)
@ 03,13 say "SUBJECT" color memvar->colorarray[32]
draw_box1(05,02,23,33,memvar->colorarray[30],memvar->colorarray[31],,.f.)
cyytenrp->(dbseek(right(cacctno,8)))
for nctr := 1 to 20
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! (cyytenrp->&skdno == "00000") .or. !(alltrim(cyytenrp->&skdno) == "")
                cyytskdp->(dbseek(cyytenrp->&skdno))
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        @ ++nline,04 say "[*] "+cyytskdp->skdsubcod+;
                                         " " +cyytskdp->skdsubtyp+;
                                         " - "+transform(cyytskdp->skdunt,"999.9");
                                color memvar->colorarray[32]

                        * memvar->nunits += cyytskdp->skdunt

                endif
        else
                exit
        endif
next
*@ 23,05 say "<< Total Units -> "+transform(cyytenrp->enrunt,"999.9")+" >>" color memvar->colorarray[32]
memvar->nunits  := cyytenrp->enrunt
@ 22,05 say "<< Total Units -> "+transform(memvar->nunits,"999.9")+" >>" color memvar->colorarray[32]
memvar->ccls    := cyytenrp->enrcls
memvar->cyrlevl := cyytenrp->enryrlevl
return(nil)


static function procassess(cterm,cacctno,cname)
local skdno,nctr:=0
a999accp->(dbseek(cacctno))
memvar->clname  := a999accp->acclname
memvar->cfname  := a999accp->accfname
memvar->cmname  := a999accp->accmname
memvar->cfeeyr  := a999accp->accfeeyr
memvar->ccolcode:= a999accp->acccolcod
c999colp->(dbseek(a999accp->acccolcod))
memvar->ccourseyr := alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+right(cterm,1)))
memvar->nfeeunit := a999feep->feeperunit

/*
if ! memvar->nunits == int(memvar->nunits)
        xunit := memvar->nunits - 1.5
else
*/
        xunit := memvar->nunits
//endif

memvar->ntuition := xunit * memvar->nfeeunit
memvar->nmisc    := a999feep->feetotmisc
memvar->nreg     := a999feep->feereg
*memvar->noth     := a999feep->feeother1+a999feep->feeother2+a999feep->feeother3+a999feep->feeother4+a999feep->feeother5

cyytenrp->(dbseek(right(cacctno,8)))
        xunit := 0
        for nctr := 1 to 20
                skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                if !(cyytenrp->&skdno == "00000") .or. !(cyytenrp->&skdno == "")
                        cyytskdp->(dbseek(cyytenrp->&skdno))
                    // xunit += if((cyytskdp->skdsplcod=="C".and.(cyytskdp->skdsubtyp=="LEC" .or. cyytskdp->skdsubtyp=="LAB")) ,0,cyytskdp->skdunt)
                      xunit += if(((cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC") .or.(cyytskdp->skdsplcod=="S" .and. cyytskdp->skdsubtyp=="LAB")),0,cyytskdp->skdunt)
                else
                        exit
                endif
        next

cyytenrp->(reclock())
cyytenrp->enrunt := xunit
cyytenrp->(dbcommit())
cyytenrp->(dbunlock())
memvar->nunits  := cyytenrp->enrunt
memvar->ntuition := xunit * memvar->nfeeunit

for nctr := 1 to 20
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                cyytskdp->(dbseek(cyytenrp->&skdno))
              if left(cyytskdp->skdsubcod,2) $ "NS,NT,CW,LE,MT,NR" .and. cyytskdp->skdcolcod == "**"
                        xunit -= cyytskdp->skdunt
                        memvar->nunits -= cyytskdp->skdunt
                        a999lbfp->(dbseek(memvar->cfeeyr+cyytskdp->skdintcod+"**"))
                        if right(cterm,1) == "1"
                                memvar->nlab += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                memvar->nlab += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                memvar->nlab += a999lbfp->lbfamt3
                        endif
                else
                       if((cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC") .or.(cyytskdp->skdsplcod=="S" .and. cyytskdp->skdsubtyp=="LAB"))

                       else
                        a999lbfp->(dbseek(memvar->cfeeyr+cyytskdp->skdintcod+cyytskdp->skdcolcod))
                        if right(cterm,1) == "1"
                                memvar->nlab += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                memvar->nlab += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                memvar->nlab += a999lbfp->lbfamt3
                        endif
                       end if
                endif
        else
                exit
        endif
next
memvar->ntuition := xunit * memvar->nfeeunit
memvar->ntotass := memvar->ntuition+memvar->nlab+memvar->nreg+memvar->nmisc
dispass(cacctno,cterm,cname)
return(nil)

static function dispass(cacctno,cterm,cname)
draw_box2(02,35,04,77,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,51 say "ASSESSMENT" color memvar->colorarray[33]
draw_box1(05,35,23,77,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 06,37 say "Sch Term : "+cterm+" - "+cname color memvar->colorarray[33]
@ 08,37 say "Account No.   : "+cacctno color memvar->colorarray[33]
@ 09,37 say "Last Name     : "+memvar->clname color memvar->colorarray[33]
@ 10,37 say "First Name    : "+memvar->cfname color memvar->colorarray[33]
@ 11,37 say "Middle Initial: "+memvar->cmname color memvar->colorarray[33]
@ 12,37 say "Course & Year : "+memvar->ccourseyr color memvar->colorarray[33]
@ 13,37 say "Fee Year      : "+memvar->cfeeyr color memvar->colorarray[33]
@ 15,37 say "Fee Per Unit . . . . . . . : "+transform(memvar->nfeeunit,"999,999.99") color memvar->colorarray[33]
@ 16,37 say "No. of Units . . . . . . . : "+transform(memvar->nunits,"999,999.99") color memvar->colorarray[33]
@ 17,37 say "Tuition  . . . . . . . . . : "+transform(memvar->ntuition,"999,999.99") color memvar->colorarray[33]
@ 18,37 say "Laboratory . . . . . . . . : "+transform(memvar->nlab,"999,999.99") color memvar->colorarray[33]
@ 19,37 say "Registration . . . . . . . : "+transform(memvar->nreg,"999,999.99") color memvar->colorarray[33]
@ 20,37 say "Miscellaneous  . . . . . . : "+transform(memvar->nmisc,"999,999.99") color memvar->colorarray[33]
@ 21,37 say "Total Assessment . . . . . : "+transform(memvar->ntotass,"999,999.99") color memvar->colorarray[33]
@ 22,37 say "Status . . . . . . . . . . : "+if(ayytassp->asstag == "C","Changed","Created") color memvar->colorarray[33]
return(nil)

static function record(cacctno,cterm)
if ! fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        return(.f.)
endif
ayytassp->(dbseek(cacctno))
ayytassp->(reclock())
ayytassp->asscolcod     := memvar->ccolcode
ayytassp->assyrlevl     := memvar->cyrlevl
ayytassp->asscls        := memvar->ccls
ayytassp->assfeeyr      := memvar->cfeeyr
ayytassp->assfeeunt     := memvar->nfeeunit
ayytassp->assunt        := memvar->nunits
ayytassp->asstui        := memvar->ntuition
ayytassp->assreg        := memvar->nreg
ayytassp->asslab        := memvar->nlab
ayytassp->assmisc       := memvar->nmisc
ayytassp->asstotal      := memvar->ntotass
ayytassp->asspstdte     := date()
ayytassp->asscusrid     := substr(memvar->cusername,1,10)
ayytassp->asstag        := _CHANGED
ayytassp->(dbcommit())
ayytassp->(dbunlock())

a999accp->(dbseek(cacctno))
a999accp->(reclock())
a999accp->accfeeunt     := memvar->nfeeunit
a999accp->accsytunt     := memvar->nunits
a999accp->accsyttui     := memvar->ntuition
a999accp->accsytmisc    := memvar->nmisc
a999accp->accsytlab     := memvar->nlab
a999accp->accsytoth     := memvar->nreg
a999accp->accsytass     := memvar->ntotass
a999accp->accsyttot     := memvar->ntotass
a999accp->accduetot     := memvar->ntotass + a999accp->accbalold - a999accp->accadj - a999accp->accsytadsc
a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
a999accp->(dbcommit())
a999accp->(dbunlock())
keyboard(chr(K_ESC))
return(nil)

static function initvar()
memvar->nfeeunit        := 0
memvar->nunits          := 0
memvar->ntuition        := 0
memvar->nlab            := 0
memvar->nreg            := 0
memvar->noth            := 0
memvar->nmisc           := 0
memvar->ntotass         := 0
memvar->cstatus         := space(01)
memvar->cfeeyr          := space(02)
memvar->clname          := space(15)
memvar->cfname          := space(24)
memvar->cmname          := space(01)
memvar->ccourseyr       := space(10)
memvar->ccolcode        := space(02)
memvar->cyrlevl         := space(01)
memvar->ccls            := space(01)
return(nil)

*------------------------------------------------------------------------------*

function assbycol()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,cname,ccolcode,ayytassp,cyytskdp,cvar:="",adspscr

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Create Assessment by College  ")
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
        cyytenrp  := "c"+cterm+"enrp"
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999feep",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999lbfp",,_DBF_SHARED,,1},;
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
                        get ccolcode pict "@!" valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"  College code "+ccolcode+" not found.  ",{" OK "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                adspscr := savescr(01,00,24,79)
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->aflag == _POSTED
                        fask(10,"  College code "+ccolcode+" assessment already posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  College code "+ccolcode+" transaction already closed.  ;"+;
                                "         No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif !a999ctrl->(dbseek(cterm+ccolcode))
                        fask(10,"  College code "+ccolcode+" transaction not forwarded.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                assproc(cterm,ccolcode)
                fask(18,"   Processing completed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


static function assproc(cterm,ccolcode)
local nunit,noth,nlab,nctr,skdno,alastscr := savescr(01,00,24,79)
private nlast,nrec
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

        /*

        for nctr := 1 to 20
                skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                if ! cyytenrp->&skdno == "00000"
                        cyytskdp->(dbseek(cyytenrp->&skdno))
                        nunit += if(cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC",0,cyytskdp->skdunt)
                else
                        exit
                endif
        next

        cyytenrp->(reclock())
        cyytenrp->(dbcommit())
        cyytenrp->(dbunlock())

        */

        nunit := cyytenrp->enrunt
        ntuition := noth := nlab := 0
        a999accp->(dbseek("1"+cyytenrp->enridno))
        a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+right(cterm,1)))

        for nctr := 1 to 20
                skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                if ! cyytenrp->&skdno == "00000"
                        cyytskdp->(dbseek(cyytenrp->&skdno))
                        if left(cyytskdp->skdsubcod,2) $ "NS,NT,CW,LE,MT,NR" .and. cyytskdp->skdcolcod == "**"
                                nunit -= cyytskdp->skdunt
                                a999lbfp->(dbseek(a999accp->accfeeyr+cyytskdp->skdintcod+"**"))
                                if right(cterm,1) == "1"
                                        nlab += a999lbfp->lbfamt1
                                elseif right(cterm,1) == "2"
                                        nlab += a999lbfp->lbfamt2
                                elseif right(cterm,1) == "4"
                                        nlab += a999lbfp->lbfamt3
                                endif
                        else
                                a999lbfp->(dbseek(a999accp->accfeeyr+cyytskdp->skdintcod+cyytskdp->skdcolcod))
                                if right(cterm,1) == "1"
                                        nlab += a999lbfp->lbfamt1
                                elseif right(cterm,1) == "2"
                                        nlab += a999lbfp->lbfamt2
                                elseif right(cterm,1) == "4"
                                        nlab += a999lbfp->lbfamt3
                                endif
                        endif
                else
                        exit
                endif
        next

        ** assessment file **

        if ayytassp->(dbseek("1"+cyytenrp->enridno))
                ayytassp->(reclock())
        else
                ayytassp->(recycle())
        endif
        ayytassp->assidno       := "1"+cyytenrp->enridno
        ayytassp->asscolcod     := cyytenrp->enrcolcod
        ayytassp->assyrlevl     := cyytenrp->enryrlevl
        ayytassp->asscls        := cyytenrp->enrcls
        ayytassp->asssyt        := cterm
        ayytassp->assenrdte     := cyytenrp->enrdte
        ayytassp->assfeeyr      := a999accp->accfeeyr
        ayytassp->assfeeunt     := a999feep->feeperunit
        ayytassp->assunt        := cyytenrp->enrunt
        ayytassp->asstui        := nunit * a999feep->feeperunit
        ayytassp->assreg        := a999feep->feereg
        ayytassp->asslab        := nlab
        ayytassp->assmisc       := a999feep->feetotmisc
        ayytassp->asstotal      := (nunit * a999feep->feeperunit)+nlab+a999feep->feereg+a999feep->feetotmisc
        ayytassp->asscrtdte     := date()
        ayytassp->asscusrid     := substr(memvar->cusername,1,10)
        ayytassp->asstag        := " "
        ayytassp->(dbcommit())
        ayytassp->(dbunlock())


        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
return(nil)

*------------------------------------------------------------------------------*

function postass()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,;
      cterm,ccolcode,ayytassp
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Post Assessment by College  ")
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
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  A"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+cterm+"assp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!" valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"  College code "+ccolcode+" not found.  ",{" OK "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->aflag == _POSTED
                        fask(10,"  College code "+ccolcode+" assessment already posted.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  College code "+ccolcode+" transaction already closed.  ;"+;
                                "         No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif !a999ctrl->(dbseek(cterm+ccolcode))
                        fask(10,"  "+ccolcode+" transaction not forwarded and created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                ppostass(cterm,ccolcode)
                a999ctrl->(dbseek(cterm+ccolcode))
                a999ctrl->(reclock())
                a999ctrl->aflag := _POSTED
                a999ctrl->(dbcommit())
                a999ctrl->(dbunlock())
                fask(18,"   Processing completed.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function ppostass(cterm,ccolcode)
local alastscr := savescr(01,00,24,79)
private nlast,nrec
showretrieving()
ayytassp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
ayytassp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
count to memvar->nlast
restscr(alastscr)
statusbar()
ayytassp->(dbgotop())
do while ! ayytassp->(eof())
        showprogress()
        a999accp->(dbseek(ayytassp->assidno))
        a999accp->(reclock())
        a999accp->accfeeunt     := ayytassp->assfeeunt
        a999accp->accsytunt     := ayytassp->assunt
        a999accp->accsyttui     := ayytassp->asstui
        a999accp->accsytmisc    := ayytassp->assmisc
        a999accp->accsytoth     := ayytassp->assreg
        a999accp->accsytlab     := ayytassp->asslab
        a999accp->accsytass     := ayytassp->asstotal
        a999accp->accsyttot     := ayytassp->asstotal
        a999accp->accduetot     := ayytassp->asstotal + a999accp->accbalold + a999accp->accadj - a999accp->accsytadsc
        a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())

        ayytassp->(reclock())
        ayytassp->asstag        := _POSTED
        ayytassp->(dbcommit())
        ayytassp->(dbunlock())
        ayytassp->(dbskip())
enddo
ayytassp->(clearscope())
return(nil)

*------------------------------------------------------------------------------*
