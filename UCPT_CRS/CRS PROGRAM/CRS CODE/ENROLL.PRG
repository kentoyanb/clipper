* Program       : ENROLL.PRG
* Author        : Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

#define _SKDNO          1
#define _SUBJECT        2
#define _SCHEDULE       3
#define _SIZE           4
#define _UNITS          5
#define _REM            6
#define _DAYX           7
#define _BEGTIMEX       8
#define _ENDTIMEX       9
#define _EMPTY_ELEMENT  {space(05),;
                         space(16),;
                         space(24),;
                         space(06),;
                         0,;
                         space(01),;
                         space(07),;
                         0,;
                         0}
function enroll()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,oenroll,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, aprv1setup,cyytenrr, cyytsecp
private aitems := {},nindex := 1, ntotunits := 0, lpassedit,;
        clname, cfname, cmname, csex, ccourse, nyrlevel,;
        csection, cclass, cterm := space(03), cidno := space(08),;
        lconf := .f.

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
oenroll := createabrowse(bitems,bindex,09,03,21,76,;
                        {|xnmode,xoabrowser,xaxparam|fenroll(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_SKDNO]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SUBJECT]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SCHEDULE]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SIZE]+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_UNITS],"@Z 999.9")+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_REM]+" "},nil}},;
                        {" SkdNo ", "      Subject     ", "       Schedule           ", " CCSize ", " Units ", "Rem"},;
                        {"ÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄ"},;
                        {"³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄ"})
*                         x12345x    x123456789012x345x    x123456789012345678901234x    x123456x    x123.1x    x1x

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment Entry  ")
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
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        if ! file(alltrim("c"+memvar->cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := alltrim("c"+memvar->cterm+"enrp")
        cyytenrr        := alltrim("c"+memvar->cterm+"enrr")
        cyytskdp        := alltrim("c"+memvar->cterm+"skdp")
        cyytsecp        := alltrim("c"+memvar->cterm+"secp")
        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                    {,,"c999crsp",,_DBF_SHARED,,1},;
                                    {,,"c999colp",,_DBF_SHARED,,1},;
                                    {,,"c999curp",,_DBF_SHARED,,2},;
                                    {,,"c999prsp",,_DBF_SHARED,,1},;
                                    {,,"blocklst",,_DBF_SHARED,,1},;
                                    {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                    {,, cyytsecp ,"cyytsecp",_DBF_SHARED,,1},;
                                    {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,1},;
                                    {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        do while .t.
                memvar->clname          := space(len(c999sm1p->sm1lstnam))
                memvar->cfname          := space(len(c999sm1p->sm1fstnam))
//                memvar->cmname          := space(len(c999sm1p->sm1midnam))
                memvar->cmname          := space(len(c999sm1p->sm1midname))
                memvar->nyrlevel        := 0
                memvar->cclass          := space(len(c999sm1p->sm1cls))
                memvar->csex            := space(len(c999sm1p->sm1sex))
                memvar->ccourse         := space(len(c999sm1p->sm1colcod))
                memvar->csection        := space(03)
                memvar->ntotunits       := 0
                restscr(aentryscr)
                commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno      pict "@!";
                        valid ! empty(memvar->cidno)
                        *valid checkidno(memvar->cidno,cprocsts)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if blocklst->(dbseek(memvar->cidno)) .and. (blocklst->blkreason != "BOUNCING CHECK")
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                endif
                if ! c999sm1p->(dbseek(memvar->cidno)) .and. ;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno)) .and. ;
                       cyytenrp->(dbseek(memvar->cidno))
                        if cyytenrp->enrenrst $ "WV"
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". has withdrawn... ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        else
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". already enrolled... ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        endif
                        loop
/*                elseif blocklst->(dbseek(memvar->cidno))
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
*/
                elseif c999sm1p->(dbseek(memvar->cidno))
                                memvar->clname          := c999sm1p->sm1lstnam
                                memvar->cfname          := c999sm1p->sm1fstnam
//                                memvar->cmname          := c999sm1p->sm1midnam
                                memvar->cmname          := c999sm1p->sm1midname
                                memvar->nyrlevel        := c999sm1p->sm1yrlevl
                                memvar->cclass          := c999sm1p->sm1cls
                                memvar->csex            := c999sm1p->sm1sex
                                memvar->ccourse         := c999sm1p->sm1colcod
                                memvar->csection        := space(03)
                                memvar->aitems := {_EMPTY_ELEMENT}
                        memvar->nindex := 1
                        dispbox(08,02,21,77,_SINGLE_LINE)
                        connectline(10,02,77)
                        @ 22,51 say "Total Units ==>" color memvar->colorarray[02]
                        oenroll:gotop()
                        stabilize(oenroll,.t.)
                        @ 09,03 say " SkdNo       Subject               Schedule            CCSize   Units  Rem" color memvar->colorarray[35]
                        commandline("³        F4 - View Course File          ³           ESC - Previous             ³")
                        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOURSE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),;
                                       if(readvar()=="MEMVAR->CSECTION",v_section(memvar->ccourse,space(len(cyytsecp->seccod)),cprocsts,memvar->colorarray[10]),))})
                        setcursor(1);set(_SET_CONFIRM,.t.)

/*
                        @ 04,02 say "Last Name   :";
                                color memvar->colorarray[02];
                                get memvar->clname      pict "@!"
                        @ 05,02 say "First Name  :";
                                color memvar->colorarray[02];
                                get memvar->cfname      pict "@!"

  */

                        @ 04,02 say "              " +memvar->clname
                        @ 04,02 say "Last Name   : " color memvar->colorarray[02]
                        @ 05,02 say "              " +memvar->cfname
                        @ 05,02 say "First Name  : " color memvar->colorarray[02]
                        @ 06,02 say "Middle Name :";
                                color memvar->colorarray[02];
                                get memvar->cmname      pict "@!";
                                valid ! empty(cmname)
                        @ 07,02 say "Sex [M,F]   :";
                                color memvar->colorarray[02];
                                get memvar->csex        pict "@!";
                                valid memvar->csex $ "MF"
                        @ 04,46 say "Course/Major  :";
                                color memvar->colorarray[02];
                                get memvar->ccourse     pict "@!";
                                valid ! empty(memvar->ccourse)
                        @ 05,46 say "Year Level    :";
                                color memvar->colorarray[02];
                                get memvar->nyrlevel    pict "9";
                                valid  memvar->nyrlevel > 0 .and. memvar->nyrlevel < 6
                        @ 06,46 say "Section       :";
                                color memvar->colorarray[02];
                                get memvar->csection    pict "@!"
                        @ 07,65 say "[C,H,O,R,S,T]";
                                color memvar->colorarray[02]
                        @ 07,46 say "Classification:";
                                color memvar->colorarray[02];
                                get memvar->cclass      pict "@!";
                                valid memvar->cclass $ _HIGH_SCHOOL  +;
                                                       _TRANSFEREE   +;
                                                       _RETURNEE     +;
                                                       _CROSS_ENROLEE+;
                                                       _OLD_STUDENT  +;
                                                       _SHIFTEE
                        read
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                        setkey(K_F4,nil)
                        setkey(K_F6,nil)
                        if lastkey() == K_ESC
                                dbunlockall();dbcommitall()
                                loop
                        endif
                        if ! empty(memvar->csection)
                                blocksubject()
                        endif
                        commandline("³   Ù - Add/Edit   ³     F10 - Save    ³   Del - Delete   ³   ESC - Previous  ³")
                        browsearray(oenroll,{""},{|b|b:gotop()})
                        dbunlockall();dbcommitall()
                endif
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


static function fenroll(nmode,oabrowser,axparam)
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
                @ 09,03 say " SkdNo       Subject               Schedule            CCSize   Units  Rem" color memvar->colorarray[35]
                return 1
        case lastkey() == K_ENTER
                editenroll(oabrowser)
        case lastkey() == K_DEL .and. ! (len(memvar->aitems) == 1)  /*.and. ! empty(memvar->aitems[memvar->nindex,_SKDNO])*/
                if fask(13,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        memvar->ntotunits -= memvar->aitems[memvar->nindex,_UNITS]
                        echototalunits()
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
                elseif term->status == "L" .and. ! memvar->clevel=="P"
                        fask(13,"  Can't save.  Records locked...  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(record())
                endif
                clearbuffer()
endcase
return 2

static function editenroll(oabrowser)
local getlist := {}, nrec, acmdline := savescr(24,00,24,79),acmddetail,;
      nlastcursor := setcursor(), lconfirm := set(_SET_CONFIRM),;
      nlastrec := len(memvar->aitems),nrow := row(), cprocsts,;
      nmax := 0, nctr := 0, llab := .f., lscode := .f.
private nactsize, nmaxsize, nbegtimex, nendtimex, cdayx, csubject,;
        cschedule, csize, nunits, cskdno, crem,;
        ncactsize,ncmaxsize,ncbegtimex,ncendtimex,ccdayx,ccsubject,;
        ccschedule,ccsize,ncunits,csplcode,ccrem
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
commandline("³           F4 - View Schedule         ³           ESC - Previous              ³")
acmddetail              := savescr(24,00,24,79)

** initialize S **
//LECTURE
memvar->cskdno          := memvar->aitems[memvar->nindex,_SKDNO]
memvar->csubject        := memvar->aitems[memvar->nindex,_SUBJECT]
memvar->cschedule       := memvar->aitems[memvar->nindex,_SCHEDULE]
memvar->csize           := memvar->aitems[memvar->nindex,_SIZE]
memvar->crem            := memvar->aitems[memvar->nindex,_REM]
memvar->nunits          := 0
memvar->cdayx           := space(07)
memvar->nbegtimex       := 0
memvar->nendtimex       := 0

* initialize C **
//LABORATORY
memvar->csplcode        := memvar->aitems[memvar->nindex,_SKDNO]
memvar->ccsubject       := memvar->aitems[memvar->nindex,_SUBJECT]
memvar->ccschedule      := memvar->aitems[memvar->nindex,_SCHEDULE]
memvar->ccsize          := memvar->aitems[memvar->nindex,_SIZE]
memvar->ccrem           := memvar->aitems[memvar->nindex,_REM]
memvar->ncunits         := 0
memvar->ccdayx          := space(07)
memvar->ncbegtimex      := 0
memvar->ncendtimex      := 0
do while .t.
        memvar->llab := .f.
        restscr(acmddetail)
        setkey(K_F4,{||if(memvar->clevel=="P",vschedule(space(len(cyytskdp->skdcod)),cprocsts,memvar->colorarray[10]),;
                                              fask(13,"    You have no rights to access this code.    ",{" Ok "},memvar->colorarray[05],.t.,nil))})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,04 get memvar->cskdno    pict "@!";
                  valid ! empty(memvar->cskdno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
        if (cyytskdp->(dbseek(memvar->cskdno)) .and. alltrim(cyytskdp->skdrescod) == "4")
           fask(13,"  Schedule number "+alltrim(memvar->cskdno)+" "+alltrim(cyytskdp->skdsubcod)+" Already dissolved...",,memvar->colorarray[06],.t.,nil)
             if!(fask(13," The Actual size is "+transform(cyytskdp->skdactsiz,"99")+"  Accept anyway  " ,{" ~Yes "," ~No "},memvar->colorarray[05],.t.,nil))==1
               loop
              endif
        endif
        if ! cyytskdp->(dbseek(memvar->cskdno))
                fask(13,"  Wrong EDP Code "+alltrim(memvar->cskdno),{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        elseif cyytskdp->(dbseek(memvar->cskdno)) .and.;
               !cyytskdp->skdsec == memvar->csection .and.;
               (!cyytskdp->skdmaxsiz == 200 .or. !cyytskdp->skdmaxsiz == 100) .and.;
               cyytskdp->skdblkcode == "Y"
                if (memvar->clevel $ "PA")
                        if ! fask(13,"  Schedule "+alltrim(cyytskdp->skdcod)+" "+alltrim(cyytskdp->skdsubcod)+" "+"Section:"+alltrim(cyytskdp->skdsec)+" is block subject. ;"+;
                                     "              A c c e p t   A n y w a y...",{" Yes "," No  "},memvar->colorarray[05]) == 1
                                loop
                        endif
                else
                        fask(13,"  Schedule "+alltrim(cyytskdp->skdcod)+" "+alltrim(cyytskdp->skdsubcod)+" "+"Section:"+alltrim(cyytskdp->skdsec)+" is block subject. ",;
                                     {" ~Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
        endif
        if cyytskdp->(dbseek(memvar->cskdno)) .and.;
               !cyytskdp->skdcolcod == memvar->ccourse .and.;
               !cyytskdp->skdcolcod $ "  **"
                        c999colp->(dbseek(cyytskdp->skdcolcod))
                        if ! fask(13, "  Schedule "+alltrim(cyytskdp->skdcod)+" "+alltrim(cyytskdp->skdsubcod)+" is restricted... ;"+;
                                      "  for "+alltrim(c999colp->coldesful)+" only.  Accept anyway ? ",{" Yes "," No  "},memvar->colorarray[03]) == 1
                                loop
                        endif
        endif

        ** transfer data to temporary variables
        memvar->nasize          := cyytskdp->skdactsiz + 1
        memvar->nmsize          := cyytskdp->skdmaxsiz
        memvar->csubject        := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
        memvar->cschedule       := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom
        memvar->csize           := cyytskdp->skdcolcod+strzero(memvar->nasize,4)
        memvar->crem            := cyytskdp->skdsplcod
        memvar->nunits          := cyytskdp->skdunt
        memvar->cdayx           := cyytskdp->skddayx
        memvar->nbegtimex       := cyytskdp->skdbegtimx
        memvar->nendtimex       := cyytskdp->skdendtimx

        if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_SKDNO] == memvar->cskdno})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"   Schedule number "+alltrim(memvar->cskdno)+" was already entered.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
        endif
        if ! (nrec := ascan(memvar->aitems,{|aelem|aelem[_SUBJECT] == memvar->csubject})) == 0
                if ! memvar->nindex == nrec
                        fask(13,"     Duplicate Subject...    ;     "+memvar->csubject+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
        endif
        ** check schedule
        if ! cyytskdp->skdsplcod == "C"
                if skedok()
                        if cyytskdp->skdsplcod == "S"
                                lscode := .t.
                                memvar->csplcode := cyytskdp->skdsplskd
                                memvar->cspltype := cyytskdp->skdsubtyp
                                if cyytskdp->(dbseek(memvar->csplcode))
                                        ** save temporary variables for split code(laboratory) **
                                        memvar->ncasize         := cyytskdp->skdactsiz + 1
                                        memvar->ccsubject       := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                        memvar->ccschedule      := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom
                                        memvar->ccsize          := cyytskdp->skdcolcod+strzero(memvar->nasize,4)
                                        memvar->ncunits         := if(cyytskdp->skdsubtyp=="LEC".or.cyytskdp->skdsubtyp==memvar->cspltype,0,cyytskdp->skdunt)
                                        memvar->ccrem           := cyytskdp->skdsplcod
                                        memvar->ccdayx          := cyytskdp->skddayx
                                        memvar->ncbegtimex      := cyytskdp->skdbegtimx
                                        memvar->ncendtimex      := cyytskdp->skdendtimx
                                        //if skedsplitok()
                                                llab := .t.
                                        //endif
                                endif
                        endif
                        if (lscode .and. llab) .or. (! lscode)
                                addtoarray(llab)
                                echototalunits()

                                if nlastrec == memvar->nindex
                                        aadd(memvar->aitems,_EMPTY_ELEMENT)
                                        oabrowser:gobottom()
                                endif
                        endif
                        exit
                endif
        else
                fask(10, "  Schedule "+alltrim(cyytskdp->skdcod)+" "+alltrim(cyytskdp->skdsubcod)+" is split code...  ;  USE => " + alltrim(cyytskdp->skdsplskd),{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
enddo
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
restscr(acmdline)
return(nil)


static function skedok()
local nctr:= 0, ncol := 0, lconflict := .f.
**Closed and Warning Schedule**
if ((memvar->nmsize-memvar->nasize) < 10) .and. ((memvar->nmsize - memvar->nasize) >= 5)
        if ! fask(13," "+memvar->cskdno+" "+alltrim(memvar->csubject)+" "+memvar->cschedule+" <--Warning. "+transform(memvar->nasize,"999")+" ;"+;
                   "                A c c e p t   A n y w a y...",{" Yes "," No  "},memvar->colorarray[05]) == 1
                return(.f.)
        endif
elseif (memvar->nmsize-memvar->nasize) <= 0
        fask(13," "+memvar->cskdno+" "+alltrim(memvar->csubject)+" "+memvar->cschedule+" <--Closed. "+transform(memvar->nasize,"999"),{" Ok "},memvar->colorarray[05],.t.,nil)
        return(.f.)
endif

**Split code and conflict**
if len(memvar->aitems) > 1
        for nctr := 1 to (len(memvar->aitems) - 1)
                for ncol := 1 to 7
                        if ! empty(substr(memvar->cdayx,ncol,1))
                                if substr(memvar->cdayx,ncol,1) == substr(memvar->aitems[nctr,_DAYX],ncol,1)
                                        if  memvar->nbegtimex+memvar->nendtimex == memvar->aitems[nctr,_BEGTIMEX]+memvar->aitems[nctr,_ENDTIMEX] .or.;
                                           (memvar->nbegtimex > memvar->aitems[nctr,_BEGTIMEX] .and. memvar->nbegtimex < memvar->aitems[nctr,_ENDTIMEX]) .or.;
                                           (memvar->aitems[nctr,_BEGTIMEX] > memvar->nbegtimex .and. memvar->aitems[nctr,_BEGTIMEX] < memvar->nendtimex) .or.;
                                           (memvar->nendtimex > memvar->aitems[nctr,_BEGTIMEX] .and. memvar->nendtimex < memvar->aitems[nctr,_ENDTIMEX]) .or.;
                                           (memvar->aitems[nctr,_ENDTIMEX] > memvar->nbegtimex .and. memvar->aitems[nctr,_ENDTIMEX] < memvar->nendtimex)
                                                fask(13," "+memvar->cskdno+" "+memvar->csubject+" "+memvar->cschedule+" <-Conflict ;"+;
                                                        " "+memvar->aitems[nctr,_SKDNO]+" "+memvar->aitems[nctr,_SUBJECT]+" "+memvar->aitems[nctr,_SCHEDULE]+" <-Conflict ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                                lconflict := .t.
                                                exit
                                        endif
                                endif
                        endif
                next
        next
        if lconflict
                return(.f.)
        endif
endif
return(.t.)


static function skedsplitok()
local nctr:= 0, ncol := 0, lconflict := .f.
if len(memvar->aitems) > 1
        for nctr := 1 to (len(memvar->aitems) - 1)
                for ncol := 1 to 7
                        if ! empty(substr(memvar->ccdayx,ncol,1))
                                if substr(memvar->ccdayx,ncol,1) == substr(memvar->aitems[nctr,_DAYX],ncol,1)
                                        if  memvar->ncbegtimex+memvar->ncendtimex == memvar->aitems[nctr,_BEGTIMEX]+memvar->aitems[nctr,_ENDTIMEX] .or.;
                                           (memvar->ncbegtimex > memvar->aitems[nctr,_BEGTIMEX] .and. memvar->ncbegtimex < memvar->aitems[nctr,_ENDTIMEX]) .or.;
                                           (memvar->aitems[nctr,_BEGTIMEX] > memvar->ncbegtimex .and. memvar->aitems[nctr,_BEGTIMEX] < memvar->ncendtimex) .or.;
                                           (memvar->ncendtimex > memvar->aitems[nctr,_BEGTIMEX] .and. memvar->ncendtimex < memvar->aitems[nctr,_ENDTIMEX]) .or.;
                                           (memvar->aitems[nctr,_ENDTIMEX] > memvar->ncbegtimex .and. memvar->aitems[nctr,_ENDTIMEX] < memvar->ncendtimex)
                                                fask(13," "+memvar->csplcode+" "+memvar->ccsubject+" "+memvar->ccschedule+" <-Conflict ;"+;
                                                        " "+memvar->aitems[nctr,_SKDNO]+" "+memvar->aitems[nctr,_SUBJECT]+" "+memvar->aitems[nctr,_SCHEDULE]+" <-Conflict ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                                lconflict := .t.
                                                exit
                                        endif
                                endif
                        endif
                next
        next
        if lconflict
                return(.f.)
        endif
endif
return(.t.)



static function echototalunits()
@ 22,67 say transform(memvar->ntotunits,"@Z 999.9")
return(nil)



static function addtoarray(llab)
local nlastelem
* transfer data to array
memvar->ntotunits -= memvar->aitems[memvar->nindex,_UNITS]
memvar->aitems[memvar->nindex,_SKDNO   ] := memvar->cskdno
memvar->aitems[memvar->nindex,_SUBJECT ] := memvar->csubject
memvar->aitems[memvar->nindex,_SCHEDULE] := memvar->cschedule
memvar->aitems[memvar->nindex,_SIZE    ] := memvar->csize
memvar->aitems[memvar->nindex,_UNITS   ] := memvar->nunits
memvar->aitems[memvar->nindex,_REM     ] := memvar->crem
memvar->aitems[memvar->nindex,_DAYX    ] := memvar->cdayx
memvar->aitems[memvar->nindex,_BEGTIMEX] := memvar->nbegtimex
memvar->aitems[memvar->nindex,_ENDTIMEX] := memvar->nendtimex
memvar->ntotunits += memvar->aitems[memvar->nindex,_UNITS]
if llab
        aadd(memvar->aitems,_EMPTY_ELEMENT)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_SKDNO   ] := memvar->csplcode
        memvar->aitems[nlastelem,_SUBJECT ] := memvar->ccsubject
        memvar->aitems[nlastelem,_SCHEDULE] := memvar->ccschedule
        memvar->aitems[nlastelem,_SIZE    ] := memvar->ccsize
        memvar->aitems[nlastelem,_UNITS   ] := memvar->ncunits
        memvar->aitems[nlastelem,_REM     ] := memvar->ccrem
        memvar->aitems[nlastelem,_DAYX    ] := memvar->ccdayx
        memvar->aitems[nlastelem,_BEGTIMEX] := memvar->ncbegtimex
        memvar->aitems[nlastelem,_ENDTIMEX] := memvar->ncendtimex
        memvar->ntotunits += memvar->aitems[nlastelem,_UNITS]
endif
return(nil)




static function record()
local ctime := "", nctr := 0, xtime := space(01),;
      cschedno := space(05),nmax:=0,;
      coldcolcod,coldmajcod,noldterm,noldyrlevel
cyytenrp->(recycle())
cyytenrp->enridno       := memvar->cidno
cyytenrp->enrdte        := date()
cyytenrp->enrcolcod     := memvar->ccourse
cyytenrp->enrcolcod2    := memvar->ccourse
cyytenrp->enryrlevl     := transform(memvar->nyrlevel,"9")
cyytenrp->enrcls        := memvar->cclass
cyytenrp->enrunt        := memvar->ntotunits
cyytenrp->enrenrst      := _ENROLL_NEW
cyytenrp->enrusrid      := substr(memvar->cusername,1,8)
cyytenrp->enrsection    := memvar->csection
for nctr := 1 to 8
        xtime := substr(time(),nctr,1)
        if (!xtime == ":")
                alltrim(ctime += xtime)
        endif
next
cyytenrp->enrtim        := ctime
for nctr := 1 to 25
        cschedno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if nctr > (len(memvar->aitems) - 1)
                cyytenrp->&cschedno     := "00000"
        else
                cyytenrp->&cschedno     := memvar->aitems[nctr,_SKDNO]
                if cyytskdp->(dbseek(memvar->aitems[nctr,_SKDNO]))
                        if ! cyytskdp->(reclock())
                                loop
                        endif
                        cyytskdp->skdactsiz += 1
                        cyytskdp->(dbcommit())
                        cyytskdp->(dbunlock())
                endif
        endif
next

**enrr file**
nmax := len(memvar->aitems)
nctr := 1
do while nctr <= nmax .and. ! len(memvar->aitems) == nctr
        fask(13,"   Saving code "+memvar->aitems[nctr,_SKDNO]+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytenrr->(recycle())
        cyytenrr->enridno       := memvar->cidno
        cyytenrr->enrskdcod     := memvar->aitems[nctr,_SKDNO]
        cyytenrr->enrlname      := memvar->clname
        cyytenrr->enrfname      := memvar->cfname
        cyytenrr->enrmname      := left(memvar->cmname,1)
        cyytenrr->enrcolcod     := memvar->ccourse
        cyytenrr->enryrlevl     := transform(memvar->nyrlevel,"9")
        cyytenrr->enrrem        := space(10)
        cyytenrr->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
        cyytenrr->(dbcommit())
        cyytenrr->(dbunlock())
        ++nctr
enddo
*************

***students master file***
if c999sm1p->(dbseek(memvar->cidno))
        c999sm1p->(reclock())
        coldcolcod      := c999sm1p->sm1colcod
        coldmajcod      := c999sm1p->sm1majcod
        noldterm        := transform(c999sm1p->sm1schtrm,"9999")
        noldyrlevel     := c999sm1p->sm1yrlevl

        cyytenrp->enrcolcodx    := coldcolcod
        cyytenrp->enrmajcodx    := coldmajcod
        cyytenrp->enryrlevlx    := transform(noldyrlevel,"99")
        cyytenrp->enrschtrmx    := right(noldterm,3)
        cyytenrp->enrcls        := memvar->cclass

        c999sm1p->sm1lstnam     := memvar->clname
        c999sm1p->sm1fstnam     := memvar->cfname
        c999sm1p->sm1midnam     := left(memvar->cmname,1)
        c999sm1p->sm1midname    := memvar->cmname
        c999sm1p->sm1colcod     := memvar->ccourse
        c999sm1p->sm1majcod     := right(memvar->ccourse,1)
        c999sm1p->sm1yrlevl     := memvar->nyrlevel
        c999sm1p->sm1schtrm     := val(memvar->cterm)
        c999sm1p->sm1cls        := memvar->cclass
        c999sm1p->sm1sex        := memvar->csex
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())
else
        c999sm1p->(recycle())
        c999sm1p->sm1idno       := memvar->cidno
        c999sm1p->sm1lstnam     := memvar->clname
        c999sm1p->sm1fstnam     := memvar->cfname
        c999sm1p->sm1midnam     := left(memvar->cmname,1)
        c999sm1p->sm1midname    := memvar->cmname
        c999sm1p->sm1colcod     := memvar->ccourse
        c999sm1p->sm1majcod     := right(memvar->ccourse,1)
        c999sm1p->sm1yrlevl     := memvar->nyrlevel
        c999sm1p->sm1cls        := memvar->cclass
        c999sm1p->sm1sex        := memvar->csex
        c999sm1p->sm1schtrm     := val(memvar->cterm)
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())
endif
cyytenrp->(dbcommit())
cyytenrp->(dbunlock())
return(0)




static function blocksubject()
local nlastelem,laccept:=.t.
cyytskdp->(sx_settagorder(3))
cyytskdp->(sx_setscope(_TOP_SCOPE   ,memvar->csection))
cyytskdp->(sx_setscope(_BOTTOM_SCOPE,memvar->csection))
cyytskdp->(dbgotop())
/*
if(((cyytskdp->skdmaxsiz-(cyytskdp->skdactsiz+1))<=10).and.(cyytskdp->skdmaxsiz-(cyytskdp->skdactsiz+1))>5)
        if ! fask(13," Block section "+memvar->csection+" <--Warning.  Accept Anyway ? ",{" Yes "," No  "},memvar->colorarray[05])==1
                cyytskdp->(sx_settagorder(1))
                cyytskdp->(clearscope())
                return(.f.)
        endif
elseif(cyytskdp->skdmaxsiz-(cyytskdp->skdactsiz+1)<=5)
        fask(13,"  Block section "+memvar->csection+" <--Closed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        cyytskdp->(sx_settagorder(1))
        cyytskdp->(clearscope())
        return(.f.)
endif
*/
do while ! cyytskdp->(eof())
        fask(13," Processing "+cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (cyytskdp->skdcolcod == memvar->ccourse .or. cyytskdp->skdcolcod == "**")
                if(((cyytskdp->skdmaxsiz-cyytskdp->skdactsiz)<=10).and.(cyytskdp->skdmaxsiz-cyytskdp->skdactsiz)>5)
                        if ! fask(13," "+cyytskdp->skdcod+" "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" <--Warning. "+transform(cyytskdp->skdactsiz,"999")+" ;"+;
                                     "                A c c e p t   A n y w a y...",{" Yes "," No  "},memvar->colorarray[05]) == 1
                                laccept := .f.
                        endif
                elseif(cyytskdp->skdmaxsiz-cyytskdp->skdactsiz<=5)
                        if memvar->clevel == "P" &&Supervisory
                                if ! fask(13," "+cyytskdp->skdcod+" "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" <--Closed. "+transform(cyytskdp->skdactsiz,"999")+" ",{" Yes "," No  "},memvar->colorarray[05])==1
                                        laccept := .f.
                                endif
                        else
                                fask(13," "+cyytskdp->skdcod+" "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" <--Closed. "+transform(cyytskdp->skdactsiz,"999")+" ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                laccept := .f.
                        endif
                endif
                if laccept
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_SKDNO   ] := cyytskdp->skdcod
                        memvar->aitems[nlastelem,_SUBJECT ] := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        memvar->aitems[nlastelem,_SCHEDULE] := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom
                        memvar->aitems[nlastelem,_SIZE    ] := cyytskdp->skdcolcod+strzero(cyytskdp->skdactsiz+1,4)
                        memvar->aitems[nlastelem,_UNITS   ] := if((cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC").or.(cyytskdp->skdsplcod=="S".and.cyytskdp->skdsubtyp=="LAB"),0,cyytskdp->skdunt)
                        memvar->aitems[nlastelem,_REM     ] := cyytskdp->skdsplcod
                        memvar->aitems[nlastelem,_DAYX    ] := cyytskdp->skddayx
                        memvar->aitems[nlastelem,_BEGTIMEX] := cyytskdp->skdbegtimx
                        memvar->aitems[nlastelem,_ENDTIMEX] := cyytskdp->skdendtimx
                        memvar->ntotunits += memvar->aitems[nlastelem,_UNITS]
                        aadd(memvar->aitems,_EMPTY_ELEMENT)
                endif
                laccept := .t.
        endif
        cyytskdp->(dbskip())
enddo
echototalunits()
cyytskdp->(sx_settagorder(1))
cyytskdp->(clearscope())
return(nil)

*-----------------------------------------------------------------------------*
*end of program
