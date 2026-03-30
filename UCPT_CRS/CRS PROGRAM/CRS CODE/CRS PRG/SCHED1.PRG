* Program       :  SCHEDULE.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function sched1()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,nctr,aprv1setup,aentryscr,cyytskdp,cyytsecp,;
      ctimex
private cterm,cedpcode,csubject,ctype,nbegtimex,nendtimex,campm,cdayx,croom,;
        nunit,nmaxsize,crevision,ccolcode,cmajcode,csection,cplitcode,cgroupcode,;
        cbegtime,cendtime,cintcode,cday,ntimex1,ntimex2,csplittype,xroom,nactsize,;
        cblockcode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1},;
                             {,,"para",,_DBF_SHARED,, }})) == nil
        return(nil)
endif
do while .t.
        memvar->cterm := space(len(term->code))
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Schedule Entry  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,02 say "School Term  :";
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
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 03,21 say "- "+term->name
        if ! file(alltrim("c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+memvar->cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"secp.dbf"))
                fask(10,"  C"+memvar->cterm+"SECP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytskdp        := alltrim("c"+memvar->cterm+"skdp")
        cyytsecp        := alltrim("c"+memvar->cterm+"secp")
        if(aprvsetup    := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                       {,,"c999room",,_DBF_SHARED,,1},;
                                       {,,"c999curp",,_DBF_SHARED,,1},;
                                       {,,"c999crsp",,_DBF_SHARED,,1},;
                                       {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                       {,, cyytsecp ,"cyytsecp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        memvar->cedpcode := space(len(cyytskdp->skdcod))
        getedpcode()
        do while .t.
                restscr(aentryscr)
                commandline("Г           F4 - View Schedule         Г          ESC - Previous               Г")
                memvar->csubject        := space(len(cyytskdp->skdsubcod))
                memvar->ctype           := space(len(cyytskdp->skdsubtyp)-2)
                memvar->nbegtimex       := 0
                memvar->nendtimex       := 0
                memvar->campm           := space(len(cyytskdp->skdmdn))
                memvar->cdayx           := space(len(cyytskdp->skddayx))
                memvar->croom           := space(len(cyytskdp->skdrom))
                memvar->xroom           := space(len(cyytskdp->skdrom))
                memvar->nunit           := 0
                memvar->nmaxsize        := 0
                memvar->nactsize        := 0
                memvar->crevision       := space(len(cyytskdp->skdrevcod))
                memvar->ccolcode        := space(len(cyytskdp->skdcolcod))
                memvar->csection        := space(len(cyytskdp->skdsec))
                memvar->csplittype      := space(len(cyytskdp->skdsplcod))
                memvar->cgroupcode      := space(len(cyytskdp->skdgrpcod))
                memvar->cbegtime        := space(len(cyytskdp->skdbegtim))
                memvar->cendtime        := space(len(cyytskdp->skdendtim))
                memvar->cintcode        := space(len(cyytskdp->skdintcod))
                memvar->cday            := space(len(cyytskdp->skdday))
                memvar->csplitcode      := space(len(cyytskdp->skdsplskd))
                memvar->cblockcode      := space(len(cyytskdp->skdblkcode))
                memvar->ntimex1         := 0
                memvar->ntimex2         := 0
                *setkey(K_F4,{||vschedule(space(len(cyytskdp->skdcod)),cprocsts)})
                setkey(K_F4,{||vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 05,02 say "EDP Code     :";
                        color memvar->colorarray[02];
                        get memvar->cedpcode    pict "@!";
                        valid ! empty(memvar->cedpcode)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if lexist := cyytskdp->(dbseek(memvar->cedpcode))
                        if ! cyytskdp->(reclock())
                                loop
                        endif
                        if val(substr(cyytskdp->skdbegtim,4,2)) == 0
                                memvar->nbegtimex := val(substr(cyytskdp->skdbegtim,1,2))*100
                        else
                                ctimex := substr(cyytskdp->skdbegtim,1,2)+substr(cyytskdp->skdbegtim,4,2)
                                memvar->nbegtimex := val(ctimex)
                        endif
                        if val(substr(cyytskdp->skdendtim,4,2)) == 0
                                memvar->nendtimex := val(substr(cyytskdp->skdendtim,1,2))*100
                        else
                                ctimex := substr(cyytskdp->skdendtim,1,2)+substr(cyytskdp->skdendtim,4,2)
                                memvar->nendtimex := val(ctimex)
                        endif
                        memvar->csubject        := cyytskdp->skdsubcod
                        memvar->ctype           := if(cyytskdp->skdsubtyp == "LEC","R","L")
                        memvar->campm           := cyytskdp->skdmdn
                        memvar->cdayx           := cyytskdp->skddayx
                        memvar->croom           := cyytskdp->skdrom
                        memvar->xroom           := cyytskdp->skdrom
                        memvar->nunit           := cyytskdp->skdunt
                        memvar->nmaxsize        := cyytskdp->skdmaxsiz
                        memvar->nactsize        := cyytskdp->skdactsiz
                        memvar->crevision       := cyytskdp->skdrevcod
                        memvar->ccolcode        := cyytskdp->skdcolcod
                        memvar->csection        := cyytskdp->skdsec
                        memvar->csplittype      := cyytskdp->skdsplcod
                        memvar->cgroupcode      := cyytskdp->skdgrpcod
                        memvar->cbegtime        := cyytskdp->skdbegtim
                        memvar->cendtime        := cyytskdp->skdendtim
                        memvar->cintcode        := cyytskdp->skdintcod
                        memvar->cday            := cyytskdp->skdday
                        memvar->csplitcode      := cyytskdp->skdsplskd
                        memvar->cblockcode      := cyytskdp->skdblkcode
                        @ 05,38 say "Internal Code => "+memvar->cintcode
                endif
                do while .t.
                        commandline("Г  F4 - View College Code/Room File  Г    F10 - Record   Г    ESC - Previous   Г")
                        setkey(K_F4,{||if(readvar() == "MEMVAR->CROOM",viewroom(space(len(c999room->roomno)),cprocsts,memvar->colorarray[10]),;
                                       if(readvar() == "MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),;
                                       if(readvar() == "MEMVAR->CSPLITCODE",vschedule(space(len(cyytskdp->skdcod)),cprocsts,memvar->colorarray[10]),)))},)
                        setkey(K_F10,{||record()})
                        nctr := 5
                        setcursor(1);set(_SET_CONFIRM,.t.)
                        @ ++nctr,02 say "Subject      :";
                                color memvar->colorarray[02];
                                get memvar->csubject    pict "@!";
                                valid ! empty(memvar->csubject)
                        @ ++nctr,02 say "Type [L,R]   :";
                                color memvar->colorarray[02];
                                get memvar->ctype       pict "@!";
                                valid memvar->ctype $ "LR"
                        @ ++nctr,02 say "Revision     :";
                                color memvar->colorarray[02];
                                get memvar->crevision   pict "@!";
                                valid ! empty(memvar->crevision)
                        @ ++nctr,02 say "College Code :";
                                color memvar->colorarray[02];
                                get memvar->ccolcode    pict "@!";
                                valid checkcolcode(memvar->ccolcode)
                        @ ++nctr,02 say "Time In      :";
                                color memvar->colorarray[02];
                                get memvar->nbegtimex   pict "9999";
                                valid (memvar->nbegtimex >= 100 .and. memvar->nbegtimex <= 1259)
                        @ ++nctr,02 say "Time Out     :";
                                color memvar->colorarray[02];
                                get memvar->nendtimex   pict "9999";
                                valid (memvar->nendtimex >= 100 .and. memvar->nendtimex <= 1259)
                        @ ++nctr,02 say "AM/PM        :";
                                color memvar->colorarray[02];
                                get memvar->campm       pict "@!";
                                valid memvar->campm $ "AMPM"
                        @ ++nctr,20 say "MTWTFSS";
                                color memvar->colorarray[02]
                        @ ++nctr,02 say "Day in X Value : ";
                                color memvar->colorarray[02];
                                get memvar->cdayx       pict "@!";
                                valid ! empty(memvar->cdayx)
                        @ ++nctr,02 say "Room         :";
                                color memvar->colorarray[02];
                                get memvar->croom       pict "@!";
                                valid ! empty(memvar->croom)
                        @ ++nctr,02 say "Maximum Size :";
                                color memvar->colorarray[02];
                                get memvar->nmaxsize    pict "9999"
                        @ ++nctr,02 say "Section      :";
                                color memvar->colorarray[02];
                                get memvar->csection    pict "@!"
                        @ ++nctr,02 say "Split Type   :";
                                color memvar->colorarray[02];
                                get memvar->csplittype  pict "@!";
                                valid memvar->csplittype $ " SC"
                        @ ++nctr,02 say "Group Code   :";
                                color memvar->colorarray[02];
                                get memvar->cgroupcode  pict "@!"
                        @ ++nctr,02 say "Split Code   :";
                                color memvar->colorarray[02];
                                get memvar->csplitcode  pict "@!"
                        @ ++nctr,02 say "                 [Y,N]";
                                color memvar->colorarray[02]
                        @   nctr,02 say "Block Subject:";
                                color memvar->colorarray[02];
                                get memvar->cblockcode  pict "@!";
                                valid memvar->cblockcode $ "YN"
                       read
                        if lastkey() == K_ESC
                                exit
                        endif
                enddo
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil);setkey(K_F10,nil)
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


static function record()
local nctr := 0, i := 0, cskdno := space(05), lfound := .f.
if fask(17,"  Are you sure to record this entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        if ! validate()
                return(nil)
        endif
        *------------------------
        *  record section file  *
        *------------------------
        if ! memvar->csection == "   "
                if cyytsecp->(dbseek(memvar->ccolcode+memvar->csection))
                        if cyytsecp->secctr < 15
                                cyytsecp->(reclock())
                                cyytsecp->secctr++
                                cyytsecp->(fieldput(cyytsecp->secctr+3,memvar->cedpcode))
                                cyytsecp->(dbcommit())
                                cyytsecp->(dbunlock())
                        endif
                else
                        cyytsecp->(recycle())
                        cyytsecp->seccolcod := memvar->ccolcode
                        cyytsecp->seccod    := memvar->csection
                        cyytsecp->secctr    := 1
                        cyytsecp->secskd1   := memvar->cedpcode
                        cyytsecp->(dbcommit())
                        cyytsecp->(dbunlock())
                endif
        endif

        *-------------------------
        *  schedule file record  *
        *-------------------------
        if cyytskdp->(dbseek(memvar->cedpcode))
                cyytskdp->(reclock())
        else
                cyytskdp->(recycle())
        endif
        cyytskdp->skdcod        := memvar->cedpcode
        cyytskdp->skdsubcod     := memvar->csubject
        cyytskdp->skdsubtyp     := if(memvar->ctype == "R","LEC","LAB")
        cyytskdp->skdbegtim     := memvar->cbegtime
        cyytskdp->skdendtim     := memvar->cendtime
        cyytskdp->skdmdn        := memvar->campm
        cyytskdp->skdday        := memvar->cday
        cyytskdp->skdrom        := memvar->croom
        cyytskdp->skdunt        := memvar->nunit
        cyytskdp->skdintcod     := memvar->cintcode
        cyytskdp->skdbegtimx    := memvar->ntimex1
        cyytskdp->skdendtimx    := memvar->ntimex2
        cyytskdp->skddayx       := memvar->cdayx
        cyytskdp->skdactsiz     := memvar->nactsize
        cyytskdp->skdmaxsiz     := memvar->nmaxsize
        cyytskdp->skdrevcod     := memvar->crevision
        cyytskdp->skdcolcod     := memvar->ccolcode
        cyytskdp->skdsec        := memvar->csection
        cyytskdp->skdsplcod     := memvar->csplittype
        cyytskdp->skdgrpcod     := memvar->cgroupcode
        cyytskdp->skdsplskd     := memvar->csplitcode
        cyytskdp->skdblkcode    := memvar->cblockcode
        cyytskdp->rectrail      := dtoc(date())+";"+time()+";"+memvar->cusername
        cyytskdp->(dbcommit())
        cyytskdp->(dbunlock())

        *----------------------
        * Room file updating  *
        *----------------------
        if ! memvar->croom == memvar->xroom
                *//new room location
                c999room->(dbseek(memvar->croom))
                c999room->(reclock())
                for i := 1 to 24
                        cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                        if empty(c999room->&cskdno)
                                c999room->(reclock())
                                c999room->&cskdno := memvar->cedpcode
                                c999room->(dbcommit())
                                c999room->(dbunlock())
                                exit
                        endif
                next
                c999room->(dbunlock())

                *//old room location
                c999room->(dbseek(memvar->xroom))
                c999room->(reclock())
                for i := 1 to 24
                        cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                        if c999room->&cskdno == memvar->cedpcode
                                c999room->&cskdno := space(05)
                                c999room->(dbcommit())
                                c999room->(dbunlock())
                                exit
                        endif
                next
                c999room->(dbunlock())
        elseif memvar->croom == memvar->xroom
                c999room->(dbseek(memvar->croom))
                *c999room->(reclock())
                for i := 1 to 24
                        cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                        if c999room->&cskdno == memvar->cedpcode
                                lfound := .t.
                                exit
                        else
                                lfound := .f.
                        endif
                next
                if ! lfound
                        for i := 1 to 24
                                cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                                if empty(c999room->&cskdno)
                                        c999room->(reclock())
                                        c999room->&cskdno := memvar->cedpcode
                                        c999room->(dbcommit())
                                        c999room->(dbunlock())
                                        exit
                                endif
                        next
                endif
        endif
        genedpcode()
        __keyboard(chr(K_ESC))
endif
return(nil)

static function validate()
local aday  := {"MON ","TUE ","MT  ","WED ","MW  ","TW  ","MTW ","THU ", ;
                "MTH ","TTH ","MTTH","WTH ","MWTH","TWTH","M-TH","FRI ", ;
                "MF  ","TF  ","MTF ","WF  ","MWF ","TWF ","MTWF","THF ", ;
                "MTHF","TTHF","MTTF","WTHF","MWTF","TWTF","M-F ","SAT ", ;
                "MS  ","TS  ","MTS ","WS  ","MWS ","TWS ","MTWS","THS ", ;
                "MTHS","TTHS","MTTS","WTHS","MWTS","TWTS","DXF ","FS  ", ;
                "MFS ","TFS ","MTFS","WFS ","MWFS","TWFS","DXTH","THFS", ;
                "MHFS","TTFS","DXW ","WTFS","DXT ","DXM ","M-S ","SUN "}
local ahx := {1,2,4,8,16,32,64}
local i,j,c,n,cskdno
local ndn,nxhr,nxmin

memvar->ntimex1 := memvar->nbegtimex
memvar->ntimex2 := memvar->nendtimex

*----------------------------
* check the beginning time  *
*----------------------------
nxhr  := val(substr(transform(memvar->ntimex1,"9999"),1,2))
nxmin := val(substr(transform(memvar->ntimex1,"9999"),3,2))
if (nxhr == 0) .or. (nxhr > 12) .or. (nxmin > 59)
        fask(13,"  Error: check time start entry.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif
memvar->cbegtime := transform(memvar->nbegtimex,"9999")
memvar->cbegtime := stuff(memvar->cbegtime,3,0,":")

*-------------------------
*  check the ending time *
*-------------------------
nxhr  := val(substr(transform(memvar->ntimex2,"9999"),1,2))
nxmin := val(substr(transform(memvar->ntimex2,"9999"),3,2))
if (nxhr == 0) .or. (nxhr > 12) .or. (nxmin > 59)
        fask(13,"  Error: check time end entry.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif
memvar->cendtime := transform(memvar->nendtimex,"9999")
memvar->cendtime := stuff(memvar->cendtime,3,0,":")

*-----------------
*  check am-pm   *
*-----------------
if (memvar->campm == "PM") .and. (memvar->ntimex1 < 1200)
        memvar->ntimex1 := memvar->ntimex1 + 1200
endif
if (memvar->campm == "PM") .and. (memvar->ntimex2 < 1200)
        memvar->ntimex2 := memvar->ntimex2 + 1200
endif
if (memvar->ntimex1 > memvar->ntimex2)
        memvar->ntimex1 := memvar->ntimex1 - 1200
endif

*----------------------
*   check day entry  *
*----------------------
ndn := 0
for i := 1 to 7
        if !(substr(memvar->cdayx,i,1) $ " X")
                fask(13,"  Error: check day entry.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
        ndn := ndn + if(substr(memvar->cdayx,i,1) == "X",ahx[i],0)
next
if (ndn > 64)
        fask(13,"  Error: check day entry.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif
memvar->cday := aday[ndn]

*---------------------
*   check maxsize    *
*---------------------
if (memvar->nmaxsize <= 0)
        fask(13,"  Error: check maximum class size.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif

*------------------------
*   check college code  *
*------------------------
if ! c999colp->(dbseek(memvar->ccolcode))
        fask(13,"  Error: check college code.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif

*-----------------------------------------
*    check relation in curriculum file   *
*-----------------------------------------
if ! c999curp->(dbseek(memvar->crevision+memvar->ccolcode+memvar->csubject+memvar->ctype))
        fask(13,"  Error: check subject, type, effectivity relation.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif
memvar->cintcode := c999curp->curintcod
@ 05,38 say "Internal Code => "+memvar->cintcode

*--------------------------
*  check in course file   *
*--------------------------
if ! c999crsp->(dbseek(memvar->cintcode))
        fask(13,"  Error: can't read course file. Refer to supervisor.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif
memvar->nunit := c999crsp->crscreunt

*----------------------
*   check group code  *
*----------------------
if memvar->cgroupcode = "  "
        memvar->cgroupcode := substr(memvar->cintcode,1,2)
endif

*---------------------------
*  check section overflow  *
*---------------------------
if ! memvar->csection == "   "
        if cyytsecp->(dbseek(memvar->ccolcode+memvar->csection))
                if cyytsecp->secctr == 16  &&15
                        fask(13,"  Error: section record overflow.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        return(.f.)
                endif
        endif
endif

*--------------------------------
*  check room schedule conflict *
*--------------------------------
if(!memvar->croom==memvar->xroom).and.(!memvar->croom $ "AFLD,AGYM,SHP1,SHP2,SHP3,SHP4,SHP5,SHP6,SHP7")
        if ! c999room->(dbseek(memvar->croom))
                fask(13,"  Room no. "+memvar->croom+" does not exists...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        elseif c999room->(dbseek(memvar->croom))
                if c999room->status == "F"
                        fask(13,"  Room no. "+memvar->croom+" fully booked...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        return(.f.)
/*
                elseif ! c999room->type == memvar->ctype
                        fask(13,"  Room no. "+memvar->croom+" and schedule not compatible...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        return(.f.)
*/
                endif
        endif
        for i := 1 to 24
                cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                if ! c999room->&cskdno $ "    "
                        for j := 1 to 7
                                if ! empty(substr(memvar->cdayx,j,1))
                                        cyytskdp->(dbseek(c999room->&cskdno))
                                        if substr(memvar->cdayx,j,1) == substr(cyytskdp->skddayx,j,1)
                                                if  memvar->ntimex1+memvar->ntimex2 == cyytskdp->skdbegtimx+cyytskdp->skdendtimx .or.;
                                                   (memvar->ntimex1 > cyytskdp->skdbegtimx .and. memvar->ntimex1 < cyytskdp->skdendtimx) .or.;
                                                   (cyytskdp->skdbegtimx > memvar->ntimex1 .and. cyytskdp->skdbegtimx < memvar->ntimex2) .or.;
                                                   (memvar->ntimex2 > cyytskdp->skdbegtimx .and. memvar->ntimex2 < cyytskdp->skdendtimx) .or.;
                                                   (cyytskdp->skdendtimx > memvar->ntimex1 .and. cyytskdp->skdendtimx < memvar->ntimex2)
                                                        fask(13,"  Room no. "+memvar->croom+" is used by schedule "+alltrim(cyytskdp->skdcod)+".  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                                        return(.f.)
                                                endif
                                        endif
                                endif
                        next
                endif
        next
endif
return(.t.)



function viewroom()
return(nil)

static function getedpcode()
if ! cyytskdp->(lastrec()) > 0
        para->(reclock())
        para->edpcode := 18
        memvar->cedpcode := strzero(para->edpcode,5)
        para->(dbcommit())
        para->(dbunlock())
else
        cyytskdp->(dbgobottom())
        memvar->cedpcode := cyytskdp->skdcod
        para->(reclock())
        para->edpcode := val(cyytskdp->skdcod)
        para->(dbcommit())
        para->(dbunlock())
        genedpcode()
endif
return(nil)


static function genedpcode()
local nrecno,nck,n,i
if val(memvar->cedpcode) == para->edpcode
        nrecno := val(substr(memvar->cedpcode,1,4)) + 1
        memvar->cedpcode := transform(nrecno,"9999")
        nck := val(substr(memvar->cedpcode,1,1))+val(substr(memvar->cedpcode,3,1))
        n   := val(substr(memvar->cedpcode,2,1))
        nck := nck + if(n>=5,n*2-9,n*2)
        n   := val(substr(memvar->cedpcode,4,1))
        nck := nck + if(n>=5,n*2-9,n*2)
        nck := if(nck%10==0,0,10-(nck%10))
        memvar->cedpcode := memvar->cedpcode+transform(nck,"9")
        for n := 1 to 3
                memvar->cedpcode := if(substr(memvar->cedpcode,n,1) == " ",stuff(memvar->cedpcode,n,1,"0"),memvar->cedpcode)
        next
        para->(reclock())
        para->edpcode := val(memvar->cedpcode)
        para->(dbcommit())
        para->(dbunlock())
endif
return(nil)

static function checkcolcod(ccode,cprocsts)
if ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
return(.t.)
