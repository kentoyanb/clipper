* Program       :  ACCESSORIES.PRG
* Author        :  Lorenzo D. Benlot Jr. & Randy F. Santizo (c) May 1999
* Updated       :  June 1999
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*

function skdgrade()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,nctr,aprv1setup,aentryscr,cyytenrp,cyytstsp,cyytskdp,;
      cterm,ccolcode,cskdno,ccourse,adspscr
private nlast,nrec

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        cterm := space(len(term->code))
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Forward Schedule to Grade File  ")
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
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := alltrim("c"+cterm+"enrp")
        cyytstsp        := alltrim("c"+cterm+"stsp")
        cyytskdp        := alltrim("c"+cterm+"skdp")
        if(aprvsetup    := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                       {,,"c999colp",,_DBF_SHARED,,1},;
                                       {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,2},;
                                       {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                       {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10])})
                commandline("³        F4 - View Course File          ³           ESC - Previous             ³")
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                adspscr := savescr(01,00,24,79)
                if ! ccolcode == "UC"
                        if ! c999colp->(dbseek(ccolcode))
                                fask(10,"  College Code "+alltrim(ccolcode)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                endif
                if ! fask(10,"    Proceed forwarding ?    ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                showretrieving()
                if ccolcode == "UC"
                        @ 03,21 say "- All Course"
                        memvar->nlast := cyytenrp->(lastrec())
                else
                        @ 03,21 say "- "+c999colp->coldesabr
                        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
                        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
                        count to memvar->nlast
                endif
                restscr(adspscr)
                statusbar()
                cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
                cyytenrp->(dbgotop())
                do while ! cyytenrp->(eof())
                        *fask(10," Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        showprogress()
                        if ! empty(cyytenrp->enridno)
//tope                       for nctr := 1 to 16
                             for nctr := 1 to 25
                                        cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                                        if ! cyytenrp->&cskdno == "00000" .and. ! cyytenrp->enrcolcod $ "PB,HU,GS,TM,N1,K1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,GB,GC,ST"
                                                cyytskdp->(dbseek(cyytenrp->&cskdno))
                                                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                                                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                                        if cyytstsp->(dbseek(cyytenrp->&cskdno+cyytenrp->enridno))
                                                                cyytstsp->(reclock())
                                                        else
                                                                cyytstsp->(recycle())
                                                                if cyytenrp->enrenrst $ "VW"
                                                                        cyytstsp->stsmidgrd := "W "
                                                                        cyytstsp->stsfingrd := "W "
                                                       //                 cyytstsp->stscomgrd := "W "
                                                                else
                                                                        cyytstsp->stsmidgrd := space(02)
                                                                        cyytstsp->stsfingrd := space(02)
                                                       //                 cyytstsp->stscomgrd := space(02)
                                                                endif
                                                        endif
                                                        cyytstsp->stsidno       := cyytenrp->enridno
                                                        cyytstsp->stsskdcod     := cyytenrp->&cskdno
                                                        *cyytskdp->(dbseek(cyytenrp->&cskdno))
                                                        cyytstsp->stsintcod     := cyytskdp->skdintcod
                                                        cyytstsp->stslstnam     := c999sm1p->sm1lstnam
                                                        cyytstsp->stsfstnam     := c999sm1p->sm1fstnam
                                                        cyytstsp->stsmidnam     := c999sm1p->sm1midnam
                                                        c999colp->(dbseek(cyytenrp->enrcolcod))
                                                        cyytstsp->stscourse     := c999colp->coldesabr
                                                        cyytstsp->stsyrlevel    := cyytenrp->enryrlevl
                                                        cyytstsp->rectrail      := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
                                                        cyytstsp->(dbcommit())
                                                        cyytstsp->(dbunlock())
                                                endif
                                        else
                                                exit
                                        endif
                                next
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytenrp->(dbskip())
                enddo
                fask(18,"    Grade File Created...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
                cyytenrp->(clearscope())
                cyytenrp->(dbclearrelation())
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function updactsize()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,ccode := "ALL  ",cterm,;
      cyytskdp,cyytenrr,nsize,nctr,cskdno,netrec,nstrec,necrec,nscrec,adjno
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        cterm := space(len(term->code))
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Update Actual Size  ")
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
                fask(10,"  Term "+cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr     := savescr(01,00,24,79)
        cyytskdp      := alltrim("c"+cterm+"skdp")
        cyytenrr      := alltrim("c"+cterm+"enrr")
        if(aprv2setup := openwcheck({{,, cyytskdp,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrr,"cyytenrr",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccode := "ALL  "
        adjno := 0
        do while .t.
                restscr(aentryscr)
                commandline("³           F4 - View Schedule         ³          ESC - Previous               ³")
                setkey(K_F4,{||vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "EDP Code     :";
                        color memvar->colorarray[02];
                        get ccode       pict "@!";
                        valid ! empty(ccode)
                if (memvar->clevel $ "PA")
                        @ 04,02 say "No. to Adj.  :";
                                color memvar->colorarray[02];
                                get adjno       pict "99"
//                              valid ! empty(adjno)
                endif
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(ccode) == "ALL"
                        if ! cyytskdp->(dbseek(ccode))
                                fask(10,"  Schedule no. "+ccode+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        @ 03,23 say "- "+cyytskdp->skdsubcod
                        cyytskdp->(sx_setscope(_TOP_SCOPE   ,ccode))
                        cyytskdp->(sx_setscope(_BOTTOM_SCOPE,ccode))
                else
                        cyytskdp->(sx_settagorder(2))
                endif
                if ! fask(10,"     Proceed processing ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        nsize := adjno
                        fask(10,"  Processing subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                        cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                        cyytenrr->(dbgotop())
                        do while ! cyytenrr->(eof())
                                fask(10," Processing edpcode "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                if ! alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                                        ++nsize
                                endif
                                cyytenrr->(dbskip())
                        enddo
                        cyytenrr->(clearscope())
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(reclock())
                        cyytskdp->skdactsiz := nsize
                        cyytskdp->(dbcommit())
                        cyytskdp->(dbunlock())
                        cyytskdp->(dbskip())
                enddo
                cyytskdp->(sx_settagorder(1))
                cyytskdp->(clearscope())
                fask(10,"     Updating success...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*-------------------------------------------------------------------------------

function uploadall()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,cgrade,cunit,;
      cyytskdp,cyytstsp,cyytenrp,cskdno,cintcd,cfingd,ccomgd,nctr,cidno
private nlast,nrec

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload Grade File to TOR File  ")
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp      := alltrim("c"+cterm+"skdp")
        cyytstsp      := alltrim("c"+cterm+"stsp")
        cyytenrp      := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,, cyytskdp,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,2},;
                                     {,,"c999torp",,_DBF_SHARED,,2},;
                                     {,, cyytstsp,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if c999torp->(dbseek(cterm))
                if ! fask(10,"  Grade for "+alltrim(term->name)+" was already uploaded. ;"+;
                             "            C o n t i n u e   a n y w a y ?",{" Yes "," No  "},memvar->colorarray[05],.t.,nil) == 1
                        loop
                endif
        elseif ! fask(10,"     Proceed uploading ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        memvar->nlast := cyytstsp->(lastrec())
        cidno := space(len(cyytstsp->stsidno))
        statusbar()
        cyytstsp->(dbgotop())
        do while ! cyytstsp->(eof())
                showprogress()

               /* Clean Up Tor File */
                if ! cyytstsp->stsidno == cidno
                        if c999torp->(dbseek(cterm+cyytstsp->stsidno))
                                c999torp->(reclock())
                                for nctr := 1 to 25
                                        cintcd := "torintcd"+strzero(nctr,2)
                                        cfingd := "torfingd"+strzero(nctr,2)
                                        ccomgd := "torcomgd"+strzero(nctr,2)
                                        replace c999torp->&cintcd with space(6),;
                                                c999torp->&cfingd with space(2),;
                                                c999torp->&ccomgd with space(2)
                                next
                                c999torp->(dbcommit())
                                c999torp->(dbunlock())
                        endif
                endif
                cidno := cyytstsp->stsidno

                if ! empty(cyytstsp->stsidno)
                        cyytskdp->(dbseek(cyytstsp->stsskdcod))
                        cyytenrp->(dbseek(cyytstsp->stsidno))
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                if c999torp->(dbseek(cterm+cyytstsp->stsidno))
                                        c999torp->(reclock())
                                else
                                        c999torp->(recycle())
                                        replace c999torp->toridno       with cyytstsp->stsidno,;
                                                c999torp->torschtrm     with cterm,;
                                                c999torp->tordate       with cyytenrp->enrdte,;
                                                c999torp->torcolcod     with cyytenrp->enrcolcod,;
                                                c999torp->toryrlevl     with cyytenrp->enryrlevl
                                endif
                                for nctr := 1 to 25
                                        cintcd := "torintcd"+strzero(nctr,2)
                                        cfingd := "torfingd"+strzero(nctr,2)
                                      //  ccomgd := "torcomgd"+strzero(nctr,2)
                                        if c999torp->&cintcd == cyytstsp->stsintcod
                                                replace c999torp->&cintcd       with cyytstsp->stsintcod,;
                                                        c999torp->&cfingd       with cyytstsp->stsfingrd,;
                                                        c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                                                c999torp->(dbcommit())
                                                c999torp->(dbunlock())
                                                exit
                                        elseif empty(c999torp->&cintcd)
                                                replace c999torp->&cintcd       with cyytstsp->stsintcod,;
                                                        c999torp->&cfingd       with cyytstsp->stsfingrd,;
                                                        c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                                                c999torp->(dbcommit())
                                                c999torp->(dbunlock())
                                                exit
                                        endif
                                next
                        endif
                endif
                if nextkey() == K_ESC
                        exit
                endif
                cyytstsp->(dbskip())
        enddo
        fask(18,"    Uploading of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-------------------------------------------------------------------------------

function uploadbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,cidno,cgrade,cunit,;
      cyytskdp,cyytstsp,cyytenrp,cskdno,ntotrec,nrecpro:=0,aentryscr,;
      cintcd,cfingd,ccomgd,nctr,lfirst

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload Grade File to TOR File by Student  ")
        commandline("³        F4 - View Term/Student File       ³          ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr     := savescr(01,00,24,79)
        cyytskdp      := alltrim("c"+cterm+"skdp")
        cyytstsp      := alltrim("c"+cterm+"stsp")
        cyytenrp      := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,, cyytskdp,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp,"cyytstsp",_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999torp"     ,,_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        cidno := space(len(c999sm1p->sm1idno))
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No.  :";
                        color memvar->colorarray[02];
                        get cidno       pict "@!";
                        valid ! empty(cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                lfirst := .t.
                if ! c999sm1p->(dbseek(cidno)) .and.;
                   ! valid_id(cidno)
                        fask(10,"  "+alltrim(cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(cidno)) .and.;
                      !cyytstsp->(dbseek(cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                if ! fask(10,"     Proceed uploading ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                cyytstsp->(dbsetrelation("c999sm1p",{||cyytstsp->stsidno},"cyytstsp->stsidno"))
                cyytstsp->(dbsetrelation("cyytenrp",{||cyytstsp->stsidno},"cyytstsp->stsidno"))
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,cidno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cidno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        fask(10,"   Processing idno "+cyytstsp->stsidno+" skdno "+cyytstsp->stsskdcod+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)

                        if lfirst
                                if c999torp->(dbseek(cterm+cyytstsp->stsidno))
                                        c999torp->(reclock())
//tope                                  for nctr := 1 to 16
                                        for nctr := 1 to 25
                                                cintcd := "torintcd"+strzero(nctr,2)
                                                cfingd := "torfingd"+strzero(nctr,2)
                                                ccomgd := "torcomgd"+strzero(nctr,2)
                                                replace c999torp->&cintcd with space(6),;
                                                        c999torp->&cfingd with space(2),;
                                                        c999torp->&ccomgd with space(2)
                                        next
                                        c999torp->(dbcommit())
                                        c999torp->(dbunlock())
                                endif
                                lfirst := .f.
                        endif

                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)

                                if c999torp->(dbseek(cterm+cyytstsp->stsidno))
                                        c999torp->(reclock())
                                else
                                        c999torp->(recycle())
                                        replace c999torp->toridno       with cyytstsp->stsidno,;
                                                c999torp->torschtrm     with cterm,;
                                                c999torp->tordate       with cyytenrp->enrdte,;
                                                c999torp->torcolcod     with cyytenrp->enrcolcod,;
                                                c999torp->toryrlevl     with cyytenrp->enryrlevl
                                endif
//tope                          for nctr := 1 to 16
                                for nctr := 1 to 25
                                        cintcd := "torintcd"+strzero(nctr,2)
                                        cfingd := "torfingd"+strzero(nctr,2)
                                //        ccomgd := "torcomgd"+strzero(nctr,2)
                                        if c999torp->&cintcd == cyytstsp->stsintcod
                                                replace c999torp->&cintcd       with cyytstsp->stsintcod,;
                                                        c999torp->&cfingd       with cyytstsp->stsfingrd,;
                                                        c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                                                c999torp->(dbcommit())
                                                c999torp->(dbunlock())
                                                exit
                                        elseif empty(c999torp->&cintcd)
                                                replace c999torp->&cintcd       with cyytstsp->stsintcod,;
                                                        c999torp->&cfingd       with cyytstsp->stsfingrd,;
                                                        c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                                                c999torp->(dbcommit())
                                                c999torp->(dbunlock())
                                                exit
                                        endif
                                next
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytstsp->(dbskip())
                enddo
                cyytstsp->(dbclearrelation())
                cyytstsp->(clearscope())
                fask(10,"    Uploading of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-------------------------------------------------------------------------------

/*
function newidno()
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(),aprvsetup,cprocsts

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,2},;
                            {,,"para",,_DBF_SHARED,,}})) == nil
        return(nil)
endif

ostudent  := c999sm1p->(createbrowse(07,06,20,73,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstd(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","'  '+sm1colcod+'  '","' '+transform(sm1yrlevl,'@Z 9')+'  '"},;
                {" ID No. ", "        S t u d e n t   N a m e            ", "Sex", "C-Code", "Year"},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ"}))
                * 12345678    123456789012345, 123456789012345678901234 1    x1x    xx11xx    x1xx
setcolor(memvar->colorarray[10])
boxshadow(04,04,22,75,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,06,"Search Key =>")
dispbox(06,05,20,74,_SINGLE_LINE)
outexpr(08,05,"Ã"); outexpr(08,74,"´")
commandline("³  F6 - Create New ID No. ³  F10 - ReFresh  ³  F12 - Order  ³  ESC - Previous  ³")
clearbuffer()
c999sm1p->(dbgotop())
c999sm1p->(browsefile(ostudent,{"","",cprocsts},{|b|b:gotop()}))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
closewcheck(aprvsetup)
return(nil)

function fstd(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 20 say space(40)
                @ 05, 20 say axparam[01]
                @ 21, 06 say "Home Address: "+space(30)
                @ 21, 06 say "Home Address: "+c999sm1p->sm1homadr
                return 1
        case lastkey() == K_F6
                createidno()
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ID ~Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2


static function createidno()
local getlist:={},cidno,clname,cfname,cmname,;
      alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      lconfirm:=set(_SET_CONFIRM),clastcolor := setcolor(memvar->colorarray[11]),;
      i,fs,d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd

c999sm1p->(sx_settagorder(0))
c999sm1p->(dbgobottom())
i  := val(substr(c999sm1p->sm1idno,3,5))
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
    cidno := fs+"0"
else
    cidno := fs+transform(chd,"9")
end
boxshadow(08,17,20,65,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Create New Id Number  ")
@ 10,19 say "                     "+cidno
@ 10,19 say "Student ID Number -> " color memvar->colorarray[02]
do while .t.
        clname  := space(len(c999sm1p->sm1lstnam))
        cfname  := space(len(c999sm1p->sm1fstnam))
        cmname  := space(len(c999sm1p->sm1midnam))
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,19 say "Last Name         ->";
                color memvar->colorarray[02];
                get clname      pict "@!"
        @ 14,19 say "First Name        ->";
                color memvar->colorarray[02];
                get cfname      pict "@!"
        @ 16,19 say "Middle Initial    ->";
                color memvar->colorarray[02];
                get cmname      pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        if ! fask(13,"   Save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                exit
        endif
        c999sm1p->(recycle())
        c999sm1p->sm1idno       := cidno
        c999sm1p->sm1lstnam     := clname
        c999sm1p->sm1fstnam     := cfname
        c999sm1p->sm1midnam     := cmname
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())
        exit
enddo
restscr(alastscr)
c999sm1p->(sx_settagorder(2))
return(nil)
*/
*-------------------------------------------------------------------------------

function newidno()
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(),aprvsetup,cprocsts

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,2},;
                            {,,"idnocon",,_DBF_SHARED,,}})) == nil
        return(nil)
endif

ostudent  := c999sm1p->(createbrowse(07,06,20,73,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstd(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","'  '+sm1colcod+'  '","' '+transform(sm1yrlevl,'@Z 9')+'  '"},;
                {" ID No. ", "        S t u d e n t   N a m e            ", "Sex", "C-Code", "Year"},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ"}))
                * 12345678    123456789012345, 123456789012345678901234 1    x1x    xx11xx    x1xx
setcolor(memvar->colorarray[10])
boxshadow(04,04,22,75,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,06,"Search Key =>")
dispbox(06,05,20,74,_SINGLE_LINE)
outexpr(08,05,"Ã"); outexpr(08,74,"´")
commandline("³  F6 - Create New ID No. ³  F10 - ReFresh  ³  F12 - Order  ³  ESC - Previous  ³")
clearbuffer()

c999sm1p->(dbgotop())
c999sm1p->(browsefile(ostudent,{"","",cprocsts},{|b|b:gotop()}))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
closewcheck(aprvsetup)
return(nil)

function fstd(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 20 say space(40)
                @ 05, 20 say axparam[01]
                @ 21, 06 say "Home Address: "+space(30)
                @ 21, 06 say "Home Address: "+c999sm1p->sm1homadr
                return 1
        case lastkey() == K_F6
                createidno()
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ID ~Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2


static function createidno()
local getlist:={},cidno,clname,cfname,cmname,;
      alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      lconfirm:=set(_SET_CONFIRM),clastcolor := setcolor(memvar->colorarray[11]),;
      i,fs,d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd

idnocon->(dbgotop())
i  := val(substr(idnocon->idnumber,3,5))
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
    cidno := fs+"0"
else
    cidno := fs+transform(chd,"9")
end
boxshadow(08,17,20,65,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Create New Id Number  ")
@ 10,19 say "                     "+cidno
@ 10,19 say "Student ID Number -> " color memvar->colorarray[02]
do while .t.
        clname  := space(len(c999sm1p->sm1lstnam))
        cfname  := space(len(c999sm1p->sm1fstnam))
        cmname  := space(len(c999sm1p->sm1midnam))
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,19 say "Last Name         ->";
                color memvar->colorarray[02];
                get clname      pict "@!"
        @ 14,19 say "First Name        ->";
                color memvar->colorarray[02];
                get cfname      pict "@!"
        @ 16,19 say "Middle Initial    ->";
                color memvar->colorarray[02];
                get cmname      pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        if ! fask(13,"   Save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                exit
        endif
        c999sm1p->(recycle())
        c999sm1p->sm1idno       := cidno
        c999sm1p->sm1lstnam     := clname
        c999sm1p->sm1fstnam     := cfname
        c999sm1p->sm1midnam     := cmname
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())
        idnocon->(reclock())
        idnocon->idnumber       := cidno
        idnocon->rectrail       := dtoc(date())+";"+time()+";"+memvar->cusername
        idnocon->(dbcommit())
        idnocon->(dbunlock())
        exit
enddo
restscr(alastscr)
c999sm1p->(sx_settagorder(2))
return(nil)

*-------------------------------------------------------------------------------

function clrrom()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cskdno,nctr
if(aprvsetup:=openwcheck({{,,"c999room",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
do while .t.
        if ! fask(10,"  Proceed clearing room file ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                exit
        endif
        c999room->(dbgotop())
        do while ! c999room->(eof())
                fask(10," Processing room number "+c999room->roomno+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                for nctr := 1 to 24
                        cskdno := if(nctr < 10,"skd"+transform(nctr,"9"),"skd"+transform(nctr,"99"))
                        if ! empty(c999room->&cskdno)
                                c999room->(reclock())
                                c999room->&cskdno := space(05)
                                c999room->(dbcommit())
                                c999room->(dbunlock())
                        endif
                next
                c999room->(dbskip())
        enddo
        fask(10,"  Cleaning of File Success.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        exit
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

*-------------------------------------------------------------------------------

function upskdlist()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,cyytenrp,cyytenrr,;
      nctr:=0,cskdno:=space(05)
private nlast,nrec

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload ENRP File to ENRR File  ")
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytenrr      := alltrim("c"+cterm+"enrr")
        cyytenrp      := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if ! fask(10,"   Upload enrollment file ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
//        nlast := cyytenrp->(lastrec())
//        statusbar()
        cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
        cyytenrp->(dbgotop())
        do while ! cyytenrp->(eof())
                * fask(10,"   Processing idno "+cyytenrp->enridno+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
//                showprogress()
//                enrrdelete()
                if ! empty(cyytenrp->enridno)
                for nctr := 1 to 25
                                cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                                fask(10,"   Processing idno "+cyytenrp->enridno+" skdno "+cyytenrp->&cskdno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                if ! cyytenrp->&cskdno == "00000"
                                        if ! cyytenrr->(dbseek(cyytenrp->enridno+cyytenrp->&cskdno))
                                                cyytenrr->(recycle())
                                                cyytenrr->enridno       := cyytenrp->enridno
                                                cyytenrr->enrskdcod     := cyytenrp->&cskdno
                                                cyytenrr->enrlname      := c999sm1p->sm1lstnam
                                                cyytenrr->enrfname      := c999sm1p->sm1fstnam
                                                cyytenrr->enrmname      := c999sm1p->sm1midnam
                                                cyytenrr->enrcolcod     := cyytenrp->enrcolcod
                                                cyytenrr->enryrlevl     := cyytenrp->enryrlevl
                                                cyytenrr->enrrem        := if(cyytenrp->enrenrst $ _WITHDRAW_BEFORE+_WITHDRAW_AFTER,"WITHDRAWN ",space(10))
                                                cyytenrr->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
                                                cyytenrr->(dbcommit())
                                                cyytenrr->(dbunlock())
                                        endif
                                else
                                        exit
                                endif
                        next
                endif
                if nextkey() == K_ESC
                        exit
                endif
                cyytenrp->(dbskip())
        enddo
        cyytenrp->(dbclearrelation())
        fask(18,"     Uploading success...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function enrrdelete()
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
*        fask(10,"   Clearing idno "+cyytenrr->enridno+" skdno "+cyytenrr->enrskdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytenrr->(reclock())
        cyytenrr->enridno := _DELETE_TAG
        cyytenrr->(dbdelete())
        cyytenrr->(dbcommit())
        cyytenrr->(dbunlock())
        cyytenrr->(dbgotop())
enddo
cyytenrr->(clearscope())
return(nil)

*-------------------------------------------------------------------------------

function skdgrdstud()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,cidno,cskdno,;
      cyytskdp,cyytstsp,cyytenrp,aentryscr,nctr:=0

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Forward SKD File to GRADE File by Student  ")
        commandline("³        F4 - View Term/Student File       ³          ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr     := savescr(01,00,24,79)
        cyytskdp      := alltrim("c"+cterm+"skdp")
        cyytstsp      := alltrim("c"+cterm+"stsp")
        cyytenrp      := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,, cyytskdp,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp,"cyytstsp",_DBF_SHARED,,2},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cidno := space(len(c999sm1p->sm1idno))
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No.  :";
                        color memvar->colorarray[02];
                        get cidno       pict "@!";
                        valid ! empty(cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(cidno)) .and.;
                   ! valid_id(cidno)
                        fask(10,"  "+alltrim(cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(cidno)) .and.;
                      !cyytenrp->(dbseek(cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                if ! fask(10,"     Proceed uploading ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                cyytenrp->(dbseek(cidno))
// tope         for nctr := 1 to 16
//kenn                for nctr := 1 to 17 c999colp->colcod $ "MT,MV,ME,MI,MO,MS,PA,SN,YN,BN,NW,HN,NV"
                for nctr :=1 to 25          //for overload students
                        cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                        fask(10,"  Processing schedule no. "+cyytenrp->&cskdno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! cyytenrp->&cskdno == "00000" .and. ! cyytenrp->enrcolcod $ "PB,HU,GS,TM,N1,K1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,GB,GC,ST"
                                cyytskdp->(dbseek(cyytenrp->&cskdno))
                                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                        if cyytstsp->(dbseek(cyytenrp->&cskdno+cyytenrp->enridno))
                                                cyytstsp->(reclock())
                                        else
                                                cyytstsp->(recycle())
                                                if cyytenrp->enrenrst $ "VW"
                                                        cyytstsp->stsmidgrd := "W "
                                                        cyytstsp->stsfingrd := "W "
                                                        cyytstsp->stscomgrd := "W "
                                                else
                                                        cyytstsp->stsmidgrd := space(02)
                                                        cyytstsp->stsfingrd := space(02)
                                                        cyytstsp->stscomgrd := space(02)
                                                endif
                                        endif
                                        cyytstsp->stsidno       := cyytenrp->enridno
                                        cyytstsp->stsskdcod     := cyytenrp->&cskdno
                                        *cyytskdp->(dbseek(cyytenrp->&cskdno))
                                        cyytstsp->stsintcod     := cyytskdp->skdintcod
                                        c999sm1p->(dbseek(cyytenrp->enridno))
                                        cyytstsp->stslstnam     := c999sm1p->sm1lstnam
                                        cyytstsp->stsfstnam     := c999sm1p->sm1fstnam
                                        cyytstsp->stsmidnam     := c999sm1p->sm1midnam
                                        c999colp->(dbseek(cyytenrp->enrcolcod))
                                        cyytstsp->stscourse     := c999colp->coldesabr
                                        cyytstsp->stsyrlevel    := cyytenrp->enryrlevl
                                        cyytstsp->rectrail      := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
                                        cyytstsp->(dbcommit())
                                        cyytstsp->(dbunlock())
                                endif
                        else
                                exit
                        endif
                next
                fask(10,"    Grade File Created...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function maintometc()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,ccolcode,adspscr,nctr,;
      cintcod1,cfingrd1,ccomgrd1,;
      cintcod2,cfingrd2,ccomgrd2
private nlast,nrec

if(aprvsetup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999torp",,_DBF_SHARED,,2},;
                            {,,"metcprmp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload UC-Main File to METC File (C999TORP)  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
ccolcode  := "MT"
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10])})
        commandline("³        F4 - View Course File          ³           ESC - Previous             ³")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "College Code  :";
                color memvar->colorarray[02];
                get ccolcode pict "@!";
                valid ! empty(ccolcode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        adspscr := savescr(01,00,24,79)
        if ! c999colp->(dbseek(ccolcode))
                fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! fask(10,"    Proceed forwarding ?    ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        showretrieving()
        metcprmp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        metcprmp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
        count to memvar->nlast
        restscr(adspscr)
        statusbar()
        metcprmp->(dbgotop())
        do while ! metcprmp->(eof())
                showprogress()
                for nctr := 1 to 17
                        cintcod1 := "prmintcod"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        cfingrd1 := "prmfingrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        ccomgrd1 := "prmcomgrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))

                        cintcod2 := "torintcd"+strzero(nctr,2)
                        cfingrd2 := "torfingd"+strzero(nctr,2)
                        ccomgrd2 := "torcomgd"+strzero(nctr,2)

                        if ! empty(metcprmp->&cintcod1)
                                if c999torp->(dbseek(right(metcprmp->prmschtrm,3)+metcprmp->prmidno+metcprmp->prminst))
                                        c999torp->(reclock())
                                else
                                        c999torp->(recycle())
                                        replace c999torp->toridno       with metcprmp->prmidno,;
                                                c999torp->torschtrm     with right(metcprmp->prmschtrm,3),;
                                                c999torp->tordate       with ctod(substr(metcprmp->prmdte,3,2)+"/"+substr(metcprmp->prmdte,5,2)+"/"+substr(metcprmp->prmdte,1,2)),;
                                                c999torp->torcolcod     with metcprmp->prmcolcod,;
                                                c999torp->toryrlevl     with right(metcprmp->prmyrlevl,1),;
                                                c999torp->torinst       with metcprmp->prminst
                                endif
                                replace c999torp->&cintcod2     with metcprmp->&cintcod1,;
                                        c999torp->&cfingrd2     with metcprmp->&cfingrd1,;
                                        c999torp->&ccomgrd2     with metcprmp->&ccomgrd1
                        endif
                next
                replace c999torp->tortrail with dtoc(date())+","+time()+","+memvar->cusername
                        c999torp->(dbcommit())
                        c999torp->(dbunlock())

                if nextkey() == K_ESC
                        exit
                endif
                metcprmp->(dbskip())
        enddo
        metcprmp->(clearscope())
        fask(18,"  Uploading finished.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function closewarning()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Close/Warning Schedule Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
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
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ctype    := "C"
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[C-losed, W-arning]" color memvar->colorarray[02]
                @ 03,02 say "T y p e      :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "CW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pclosewarning(ccolcode,ctype,cdesc)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function pclosewarning(ccolcode,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cheaddesc,csection

if ctype == "C"
        cheaddesc := "LIST OF CLOSED SCHEDULE"
else
        cheaddesc := "LIST OF WARNING SCHEDULE"
endif

ncol := titlepos("UNIVERSITY OF CEBU - METC",nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU - METC"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU - METC")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(cheaddesc),nmaxcol))+alltrim(cheaddesc)})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"SCODE      SUBJECT          TIME      DAYS ROOM UNIT SIZE SECTION COURSE SPLCD"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- ------- ------ -----"})

/*
SCODE      SUBJECT          TIME      DAYS ROOM UNIT SIZE SECTION COURSE SPLCD
----- ---------------- -------------- ---- ---- ---- ---- ------- ------ -----
12345 123456789012 lec 12345-12345 pm days room unit size   123   course 12345
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+" course "+cyytskdp->skdcolcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ctype == "W"
                        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! cyytskdp->skdmajcod == "*"
//                        if ! cyytskdp->skdrescod == _DISSOLVED
/*
                                if ((cyytskdp->skdmaxsiz-cyytskdp->skdactsiz) <= 10) .and.;
                                   ((cyytskdp->skdmaxsiz-cyytskdp->skdactsiz) > 5)

                                if ((cyytskdp->skdactsiz <= 49) .and. (cyytskdp->skdactsiz >= 40))
*/
                                if ((cyytskdp->skdactsiz <= 40) .and. (cyytskdp->skdactsiz >= 35) .and. ! (cyytskdp->skdmaxsiz == 80))

                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                     abtext, prow() + 1, _MAX_LINE, {||__eject()})

                                        c999colp->(dbseek(cyytskdp->skdcolcod))
                                        @ prow()+01,00 say cyytskdp->skdcod+" "+;
                                                           cyytskdp->skdsubcod+" "+;
                                                           cyytskdp->skdsubtyp+" "+;
                                                           cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+;
                                                           cyytskdp->skdday+" "+;
                                                           cyytskdp->skdrom+" "+;
                                                           transform(cyytskdp->skdunt,"99.9")+" "+;
                                                           transform(cyytskdp->skdactsiz,"9999")+"   "+;
                                                           cyytskdp->skdsec+"   "+;
                                                           c999colp->coldesabr+" "+;
                                                           cyytskdp->skdsplskd

                                                cyytskdp->(reclock())
                                                cyytskdp->skdmajcod := "*"
                                                cyytskdp->(dbcommit())
                                                cyytskdp->(dbunlock())
                                endif
                        endif
                case ctype == "C"
                        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! cyytskdp->skdmajcod == "*"
//                        if ! cyytskdp->skdrescod == _DISSOLVED
/*
                                if ((cyytskdp->skdmaxsiz-cyytskdp->skdactsiz) <= 5)
                                if ((cyytskdp->skdactsiz >= 50) .and. ! (cyytskdp->skdmaxsiz == 80))
*/
                                if ((cyytskdp->skdactsiz >= 41) .and. ! (cyytskdp->skdmaxsiz == 80))

                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                     abtext, prow() + 1, _MAX_LINE, {||__eject()})

                                        c999colp->(dbseek(cyytskdp->skdcolcod))
                                        @ prow()+01,00 say cyytskdp->skdcod+" "+;
                                                           cyytskdp->skdsubcod+" "+;
                                                           cyytskdp->skdsubtyp+" "+;
                                                           cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+;
                                                           cyytskdp->skdday+" "+;
                                                           cyytskdp->skdrom+" "+;
                                                           transform(cyytskdp->skdunt,"99.9")+" "+;
                                                           transform(cyytskdp->skdactsiz,"9999")+"   "+;
                                                           cyytskdp->skdsec+"   "+;
                                                           c999colp->coldesabr+" "+;
                                                           cyytskdp->skdsplskd

                                                cyytskdp->(reclock())
                                                cyytskdp->skdmajcod := "*"
                                                cyytskdp->(dbcommit())
                                                cyytskdp->(dbunlock())

                                endif
                        endif
        endcase
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
@ prow()+01,00 say chr(18)
__eject()
return(nil)

*------------------------------------------------------------------------------*

function apprenall()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,;
      cyytappp,cidno,cvesname,cvesown,ngrston,ddembark
private nlast,nrec

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload Apprenticeship Data to TOR File  ")
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"appp.dbf"))
                fask(10,"  C"+cterm+"APPP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytappp      := alltrim("c"+cterm+"appp")
        if(aprv2setup := openwcheck({{,, cyytappp,"cyytappp",_DBF_SHARED,,1},;
                                     {,,"c999appp",,_DBF_SHARED,,1},;
                                     {,,"c999torp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if c999torp->(dbseek(cterm))
                if ! fask(10," Apprentice Data for "+alltrim(term->name)+" was already uploaded. ;"+;
                             "              C o n t i n u e   a n y w a y ?",{" Yes "," No  "},memvar->colorarray[05],.t.,nil) == 1
                        loop
                endif
        elseif ! fask(10,"     Proceed uploading ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        memvar->nlast := cyytappp->(lastrec())
        cidno := space(len(cyytappp->appidno))
        statusbar()
        cyytappp->(dbgotop())
        do while ! cyytappp->(eof())
                showprogress()

               /* Clean Up Tor File */
                if ! cyytappp->appidno == cidno
                        if c999torp->(dbseek(cterm+cyytappp->appidno))
                                c999torp->(reclock())
                                replace c999torp->torvesname with space(30),;
                                        c999torp->torvesown  with space(50)
                                c999torp->(dbcommit())
                                c999torp->(dbunlock())

                        endif
                endif
                cidno := cyytappp->appidno

                if ! empty(cyytappp->appidno)
                         c999appp->(dbseek(cterm+cyytappp->appidno))
                         if c999torp->(dbseek(cterm+cyytappp->appidno))
                                c999torp->(reclock())
                         else
                                c999torp->(recycle())
                                replace c999torp->toridno       with cyytappp->appidno,;
                                        c999torp->torschtrm     with c999appp->appterm,;
                                        c999torp->tordate       with c999appp->appdate,;
                                        c999torp->torcolcod     with c999appp->appcourse,;
                                        c999torp->toryrlevl     with c999appp->appyrlevel,;
                                        c999torp->torapgrd      with c999appp->appgrade,;
                                        c999torp->torvesname    with cyytappp->appvesname,;
                                        c999torp->torvesown     with cyytappp->appvesown,;
                                        c999torp->torgrston     with cyytappp->appgrston,;
                                        c999torp->torembark     with cyytappp->appembark,;
                                        c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                                 c999torp->(dbcommit())
                                 c999torp->(dbunlock())
//                                 exit
                         endif
                endif
                if nextkey() == K_ESC
                        exit
                endif
                cyytappp->(dbskip())
        enddo
        fask(18,"    Uploading of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-------------------------------------------------------------------------------

function apprenstud()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,;
      cyytappp,cidno,cvesname,cvesown,ngrston,ddembark,ntotrec,nrecpro:=0,aentryscr,;
      nctr,lfirst

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
cidno := space(08)
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload Apprenticeship Data to TOR File by Student  ")
        commandline("³        F4 - View Term/Student File       ³          ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"appp.dbf"))
                fask(10,"  C"+cterm+"APPP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr     := savescr(01,00,24,79)
        cyytappp      := alltrim("c"+cterm+"appp")
        if(aprv2setup := openwcheck({{,, cyytappp,"cyytappp",_DBF_SHARED,,1},;
                                     {,,"c999appp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999torp",,_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
//        cidno := space(len(c999sm1p->sm1idno))
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No.  :";
                        color memvar->colorarray[02];
                        get cidno       pict "@!";
                        valid ! empty(cidno)
               read
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(cidno))
                        fask(10,"  ID Number : "+cidno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                @ 04,25 say " => "+alltrim(c999sm1p->sm1lstnam)+", "+;
                                   alltrim(c999sm1p->sm1fstnam)+" "+;
                                   alltrim(c999sm1p->sm1midnam) ;
                        color memvar->colorarray[02]
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                lfirst := .t.
                if ! c999sm1p->(dbseek(cidno)) .and.;
                   ! valid_id(cidno)
                        fask(10,"  "+alltrim(cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999appp->(dbseek(cidno)) .and.;
                      !cyytappp->(dbseek(cidno))
                                fask(10," Student "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname+". has no Apprenticeship Data. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                if ! fask(10,"     Proceed uploading ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                cyytappp->(dbsetrelation("c999appp",{||cyytappp->appidno},"cyytappp->appidno"))
                cyytappp->(sx_setscope(_TOP_SCOPE   ,cidno))
                cyytappp->(sx_setscope(_BOTTOM_SCOPE,cidno))
                cyytappp->(dbgotop())
                do while ! cyytappp->(eof())
                        fask(10,"   Processing idno "+cyytappp->appidno+" Appno "+cyytappp->appno+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)

                        //clean-up torp
                        if lfirst
                                if c999torp->(dbseek(cterm+cyytappp->appidno))
                                        c999torp->(reclock())
                                                replace c999torp->torvesname with space(30),;
                                                        c999torp->torvesown  with space(50)
                                        c999torp->(dbcommit())
                                        c999torp->(dbunlock())
                                endif
                                lfirst := .f.
                        endif

                        c999appp->(dbseek(cterm+cidno))
                        if c999torp->(dbseek(cterm+cyytappp->appidno))
                                c999torp->(reclock())
                        else
                                c999torp->(recycle())
                        endif
                        replace c999torp->toridno       with cyytappp->appidno,;
                                c999torp->torschtrm     with c999appp->appterm,;
                                c999torp->tordate       with c999appp->appdate,;
                                c999torp->torcolcod     with c999appp->appcourse,;
                                c999torp->toryrlevl     with c999appp->appyrlevel,;
                                c999torp->torapgrd      with c999appp->appgrade,;
                                c999torp->torvesname    with cyytappp->appvesname,;
                                c999torp->torvesown     with cyytappp->appvesown,;
                                c999torp->torgrston     with cyytappp->appgrston,;
                                c999torp->torembark     with cyytappp->appembark,;
                                c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                        c999torp->(dbcommit())
                        c999torp->(dbunlock())
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytappp->(dbskip())
                enddo
                cyytappp->(dbclearrelation())
                cyytappp->(clearscope())
                fask(10,"    Uploading of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

*-------------------------------------------------------------------------------



function deleteapprenstud()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,aprv2setup,cprocsts,cterm,;
      cyytappp,cidno,cvesname,cvesown,ngrston,ddembark,ntotrec,nrecpro:=0,aentryscr,;
      nctr,lfirst

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
cidno := space(08)
do while .t.
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  DELETE Apprenticeship Data FROM TOR File by Student  ")
        commandline("³        F4 - View Term/Student File       ³          ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
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
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"appp.dbf"))
                fask(10,"  C"+cterm+"APPP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr     := savescr(01,00,24,79)
        cyytappp      := alltrim("c"+cterm+"appp")
        if(aprv2setup := openwcheck({{,, cyytappp,"cyytappp",_DBF_SHARED,,1},;
                                     {,,"c999appp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999torp",,_DBF_SHARED,,2}})) == nil
                return(nil)
        endif

        do while .t.
                clearbuffer()
                restscr(aentryscr)
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No.  :";
                        color memvar->colorarray[02];
                        get cidno       pict "@!";
                        valid ! empty(cidno)
               read
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(cidno))
                        fask(10,"  ID Number : "+cidno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                c999torp->(dbseek(cterm+cidno))
                @ 04,25 say " => "+alltrim(c999sm1p->sm1lstnam)+", "+;
                                   alltrim(c999sm1p->sm1fstnam)+" "+;
                                   alltrim(c999sm1p->sm1midnam);
                        color memvar->colorarray[02]
                @ 05,25 say " =>  VESSEL NAME: "+ alltrim(c999torp->torvesname);
                        color memvar->colorarray[02]
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                lfirst := .t.
                if ! c999sm1p->(dbseek(cidno)) .and.;
                   ! valid_id(cidno)
                        fask(10,"  "+alltrim(cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif ! c999appp->(dbseek(cidno)) .and.;
                      ! cyytappp->(dbseek(cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". has no Apprenticeship Data. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                if ! fask(10,"     Proceed deleting ?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif

               // if c999torp->(dbseek(cterm+cidno))
                        
                        if ! empty(alltrim(c999torp->torvesname))
                            c999torp->(dbdelete())
                            c999torp->(dbcommit())
                            c999torp->(dbunlock())
                             __keyboard(chr(K_ESC))
                            fask(10,"    Deleting of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        else
                            fask(10,"    No data is found in TORP(Please check the term or id number...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        endif
                //else
                           fask(10,"    No data is found in TORP(Please check the term or id number...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
                //endif
                
                /*cyytappp->(dbsetrelation("c999appp",{||cyytappp->appidno},"cyytappp->appidno"))
                cyytappp->(sx_setscope(_TOP_SCOPE   ,cidno))
                cyytappp->(sx_setscope(_BOTTOM_SCOPE,cidno))
                cyytappp->(dbgotop())*/

                //do while ! cyytappp->(eof())
                //        fask(10,"   Processing idno "+cyytappp->appidno+" Appno "+cyytappp->appno+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)

                        //clean-up torp
                        /*if lfirst
                                if c999torp->(dbseek(cterm+cyytappp->appidno))
                                        c999torp->(reclock())
                                                replace c999torp->torvesname with space(30),;
                                                        c999torp->torvesown  with space(50)
                                        c999torp->(dbcommit())
                                        c999torp->(dbunlock())
                                endif
                                lfirst := .f.
                        endif*/

                       // c999appp->(dbseek(cterm+cidno))
                        /*if c999torp->(dbseek(cterm+cidno))
                                c999torp->(reclock()) // UPDATE
                        else
                                c999torp->(recycle()) // INSERT
                        endif*/

                        /*replace c999torp->toridno       with cyytappp->appidno,;
                                c999torp->torschtrm     with c999appp->appterm,;
                                c999torp->tordate       with c999appp->appdate,;
                                c999torp->torcolcod     with c999appp->appcourse,;
                                c999torp->toryrlevl     with c999appp->appyrlevel,;
                                c999torp->torapgrd      with c999appp->appgrade,;
                                c999torp->torvesname    with cyytappp->appvesname,;
                                c999torp->torvesown     with cyytappp->appvesown,;
                                c999torp->torgrston     with cyytappp->appgrston,;
                                c999torp->torembark     with cyytappp->appembark,;
                                c999torp->tortrail      with dtoc(date())+","+time()+","+memvar->cusername
                        */
                       // c999torp->(dbcommit())
                       // c999torp->(dbunlock())
                       // if nextkey() == K_ESC
                       //         exit
                       // endif
                       // cyytappp->(dbskip())
               // enddo
                //cyytappp->(dbclearrelation())
                //cyytappp->(clearscope())
                //fask(10,"    Uploading of data finished...    ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)




function metctomain()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,cidno,adspscr,nctr,;
      cintcod1,cfingrd1,ccomgrd1,;
      cintcod2,cfingrd2,ccomgrd2
private nlast,nrec

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"mainprmp",,_DBF_SHARED,,1},;
                            {,,"c999torp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Download METC Records to UC Main File  ")
commandline("³        F4 - View Student File        ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
cidno  := space(8)
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number :";
                color memvar->colorarray[02];
                get cidno valid ! empty(cidno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        adspscr := savescr(01,00,24,79)
        if ! c999sm1p->(dbseek(cidno))
                fask(10,"  Student Id Number not found in Master File.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! fask(10,"    Proceed Downloading ?    ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        showretrieving()
        c999torp->(sx_setscope(_TOP_SCOPE   ,cidno))
        c999torp->(sx_setscope(_BOTTOM_SCOPE,cidno))
        count to memvar->nlast
        restscr(adspscr)
        statusbar()
        c999torp->(dbgotop())
        do while ! c999torp->(eof())
                showprogress()
                for nctr := 1 to 25
                        cintcod2 := "torintcd"+strzero(nctr,2)
                        cfingrd2 := "torfingd"+strzero(nctr,2)
                        ccomgrd2 := "torcomgd"+strzero(nctr,2)

                        cintcod1 := "prmintcod"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        cfingrd1 := "prmfingrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        ccomgrd1 := "prmcomgrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))

                        if ! empty(c999torp->&cintcod2)
                                if mainprmp->(dbseek(c999torp->toridno+if(left(c999torp->torschtrm,1)=="0","20"+c999torp->torschtrm,"19"+c999torp->torschtrm)+c999torp->torinst))
                                        mainprmp->(reclock())
                                else
                                        mainprmp->(recycle())
                                        replace mainprmp->prmidno       with c999torp->toridno,;
                                                mainprmp->prmschtrm     with (if(left(c999torp->torschtrm,1)=="0","20"+c999torp->torschtrm,"19"+c999torp->torschtrm)),;
                                                mainprmp->prmdte        with substr((dtos(c999torp->tordate)),3,6),;
                                                mainprmp->prmcolcod     with c999torp->torcolcod,;
                                                mainprmp->prmyrlevl     with c999torp->toryrlevl,;
                                                mainprmp->prminst       with c999torp->torinst
                                endif
                                replace mainprmp->&cintcod1     with c999torp->&cintcod2,;
                                        mainprmp->&cfingrd1     with c999torp->&cfingrd2,;
                                        mainprmp->&ccomgrd1     with c999torp->&ccomgrd2
                        endif
                next
                        if !empty(alltrim(c999torp->torinst))
                                replace mainprmp->prminst with c999torp->torinst
                        endif
                        mainprmp->(dbcommit())
                        mainprmp->(dbunlock())

                if nextkey() == K_ESC
                        exit
                endif
                c999torp->(dbskip())
        enddo
        c999torp->(clearscope())
        fask(18,"  Finished Downloading..  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*
function skedmonitor()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), ctdesc,cedpcode,cskd,csubject,;
      cinscode,cinsname

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Subject Schedule Monitoring  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        @ 03,01 say replicate("Ä",78)
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
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ctdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cedpcode := space(len(cyytskdp->skdcod))
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - Browse Schedule        ³           ESC - Previous              ³")
                setkey(K_F4,{||vschedule(space(len(cyytskdp->skdcod)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "EDP Code     :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! cyytskdp->(dbseek(cedpcode))
                        fask(10,"  Schedule no."+alltrim(cedpcode)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                @ 04,23 say "- "+cyytskdp->skdsubcod
                cskd := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9"+" "+cyytskdp->skdsec)
                if c999crsp->(dbseek(cyytskdp->skdintcod))
                        csubject := alltrim(c999crsp->crsdsc1)
                else
                        csubject := space(50)
                endif
                if t999lst->(dbseek(cyytskdp->skdinscod))
                        cinscode := t999lst->tidno
                        cinsname := alltrim(t999lst->tlname)+" "+alltrim(t999lst->tfname)+" "+t999lst->tmname+"."
                else
                        cinscode := space(06)
                        cinsname := space(50)
                endif
                if whereprint({||pclasslist(cedpcode,ctdesc,cskd,csubject,cinscode,cinsname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pclasslist(cedpcode,ctdesc,cskd,csubject,cinscode,cinsname)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(ctdesc),nmaxcol)-14)+alltrim(ctdesc)})
aadd(abtext,{||space(titlepos("MASTER LIST",nmaxcol))+"MASTER LIST"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+cinscode+" - "+cinsname})
aadd(abtext,{||"Schedule  : "+cedpcode+"  - "+cskd})
aadd(abtext,{||"          : "+csubject})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

/*
Instructor: 123456 - 123456789012345678901234567890
Schedule  : 12345  - 1234567901534564
          : 123134313313131313131

      ID No.     Last Name          First Name         M Course Yr  Remarks
     -------- --------------- ------------------------ - ------ -- ----------
123. 12345678 123456789012345 123456789012345678901234 1 123456  1 1234567890
*/

nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
        fask(10,"  Printing edp-code "+cedpcode+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                             cyytenrr->enridno+spac(01)+;
                             c999sm1p->sm1lstnam+space(01)+;
                             c999sm1p->sm1fstnam+space(01)+;
                             c999sm1p->sm1midnam+space(01)+;
                             c999colp->coldesabr+space(02)+;
                             cyytenrr->enryrlevl+space(01)+;
                             "__________")
        if ! empty(cyytenrr->enrrem)
                outexpr(prow()+00,67,cyytenrr->enrrem)
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        cyytenrr->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

*-------------------------------------------------------------------------------

function ucmntometc()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,ccolcode,adspscr,nctr,cidno := space(08),;
      cintcod1,cfingrd1,ccomgrd1,;
      cintcod2,cfingrd2,ccomgrd2
private nlast,nrec

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"ucmnprmp",,_DBF_SHARED,,1},;
                            {,,"ucmnsm1p",,_DBF_SHARED,,1},;
                            {,,"ucmncrsp",,_DBF_SHARED,,1},;
                            {,,"c999torp",,_DBF_SHARED,,2}})) == nil   // term+idno
        return(nil)
endif

boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload UC-Main File to METC File (C999TORP)  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||vmnstud(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student No.  :";
                color memvar->colorarray[02];
                get cidno pict "@!";
                valid ! empty(cidno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        adspscr := savescr(01,00,24,79)
        if ! ucmnsm1p->(dbseek(cidno))
                fask(10,"  ID No. : "+cidno+";  Name  : "+;
                         alltrim(c999sm1p->sm1lstnam)+",  "+;
                         alltrim(c999sm1p->sm1fstnam)+"  "+;
                         alltrim(c999sm1p->sm1midnam)+;
                         ";  Error  : Not found in UC-MAIN file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! c999sm1p->(dbseek(cidno))
                c999sm1p->(recycle())

                c999sm1p->sm1idno   := ucmnsm1p->sm1idno
                c999sm1p->sm1lstnam := ucmnsm1p->sm1lstnam
                c999sm1p->sm1fstnam := ucmnsm1p->sm1fstnam
                c999sm1p->sm1midnam := ucmnsm1p->sm1midnam
                c999sm1p->sm1sex    := ucmnsm1p->sm1sex
                c999sm1p->sm1homadr := ucmnsm1p->sm1homadr
                c999sm1p->sm1schtrm := ucmnsm1p->sm1schtrm
                //c999sm1p->sm1schtrm := transform(ucmnsm1p->sm1schtrm,"9999")
                c999sm1p->sm1colcod := ucmnsm1p->sm1colcod
                c999sm1p->sm1yrlevl := ucmnsm1p->sm1yrlevl
                //c999sm1p->sm1yrlevl := transform(ucmnsm1p->sm1yrlevl,"99")

                c999sm1p->(dbcommit())
                c999sm1p->(dbunlock())
        else
                fask(10,"  ID No. : "+cidno+" already exist...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif




        if ! fask(10,"    Proceed forwarding records of  ;"+;
                     "    "+alltrim(c999sm1p->sm1lstnam)+",  "+;
                            alltrim(c999sm1p->sm1fstnam)+"  "+;
                            alltrim(c999sm1p->sm1midnam)+" ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        restscr(adspscr)
        ucmnprmp->(dbgotop())
        ucmnprmp->(dbseek(cidno))
        do while (ucmnprmp->prmidno==cidno) .and. ! (ucmnprmp->(eof()))
                for nctr := 1 to 15
                        fask(10,"  Term   : "+ucmnprmp->prmschtrm+";"+;
                                "  ID No. : "+ucmnprmp->prmidno+";"+;
                                "  Counter: "+transform(nctr,"99")+";"+;
                                "  ",{" Ok "},memvar->colorarray[05],.f.,nil)
                        cintcod1 := "prmintcod"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        cfingrd1 := "prmfingrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))
                        ccomgrd1 := "prmcomgrd"+if(nctr < 10,str(nctr,1),chr(55+nctr))

                        cintcod2 := "torintcd"+strzero(nctr,2)
                        cfingrd2 := "torfingd"+strzero(nctr,2)
                        ccomgrd2 := "torcomgd"+strzero(nctr,2)

                        if ! empty(ucmnprmp->&cintcod1)
                                if (nctr == 1)
                                if c999torp->(dbseek(right(ucmnprmp->prmschtrm,3)+ucmnprmp->prmidno))
                                        c999torp->(reclock())
                                else
                                        c999torp->(recycle())
                                        replace c999torp->toridno       with ucmnprmp->prmidno,;
                                                c999torp->torschtrm     with right(ucmnprmp->prmschtrm,3),;
                                                c999torp->tordate       with ctod(substr(ucmnprmp->prmdte,3,2)+"/"+substr(ucmnprmp->prmdte,5,2)+"/"+substr(ucmnprmp->prmdte,1,2)),;
                                                c999torp->torcolcod     with ucmnprmp->prmcolcod,;
                                                c999torp->toryrlevl     with right(ucmnprmp->prmyrlevl,1)
                                endif
                                endif
                                replace c999torp->&cintcod2     with ucmnprmp->&cintcod1,;
                                        c999torp->&cfingrd2     with ucmnprmp->&cfingrd1,;
                                        c999torp->&ccomgrd2     with ucmnprmp->&ccomgrd1
                                if ! c999crsp->(dbseek(c999torp->&cintcod2))
                                        if ucmncrsp->(dbseek(c999torp->&cintcod2))
                                                c999crsp->(recycle())

                                                c999crsp->crsintcod := ucmncrsp->crsintcod
                                                c999crsp->crssubcod := ucmncrsp->crssubcod
                                                c999crsp->crssubtyp := ucmncrsp->crssubtyp
                                                c999crsp->crsdsc1   := ucmncrsp->crsdsc1
                                                c999crsp->crsdsc2   := ucmncrsp->crsdsc2
                                                c999crsp->crsgrpcod := ucmncrsp->crsgrpcod
                                                c999crsp->crscreunt := ucmncrsp->crscreunt
                                                c999crsp->crscrecod := ucmncrsp->crscrecod
                                                c999crsp->crslechrs := ucmncrsp->crslechrs
                                                c999crsp->crslabhrs := ucmncrsp->crslabhrs
                                                c999crsp->crsprncod := ucmncrsp->crsprncod
                                                c999crsp->rectrail  := "UC-MAIN"

                                                c999crsp->(dbcommit())
                                                c999crsp->(dbunlock())
                                        endif
                                endif
                        endif
                next
                replace c999torp->tortrail with dtoc(date())+","+time()+","+memvar->cusername
                        c999torp->(dbcommit())
                        c999torp->(dbunlock())

                if nextkey() == K_ESC
                        exit
                endif
                ucmnprmp->(dbskip())
        enddo
        ucmnprmp->(clearscope())
        fask(10,"  Uploading finished.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)

*-------------------------------------------------------------------------------

function uclmtometc()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,ccolcode,adspscr,nctr,cidno := space(08),;
      cintcod1,cfingrd1,ccomgrd1,clmidno := space(08),;
      cintcod2,cfingrd2,ccomgrd2,clmstud,cmetcstud
private nlast,nrec

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"c999sm2p",,_DBF_SHARED,,1},;
                            {,,"uclmtorp",,_DBF_SHARED,,1},;
                            {,,"uclmsm1p",,_DBF_SHARED,,1},;
                            {,,"uclmsm2p",,_DBF_SHARED,,1},;
                            {,,"uclmcrsp",,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999torp",,_DBF_SHARED,,2}})) == nil   // term+idno
        return(nil)
endif

boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload UC-LM Records to METC File (C999TORP)  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
//        setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
//        setkey(K_F4,{||vlmstud(space(len(uclmsm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
        setcursor(1);set(_SET_CONFIRM,.t.)
        setkey(K_F4,{||if(readvar()=="CLMIDNO",vlmstud(space(len(uclmsm1p->sm1idno)),cprocsts,memvar->colorarray[10]),;
                if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),))})
        @ 02,02 say "Student No. (UCLM)   :";
                color memvar->colorarray[02];
                get clmidno pict "@!";
                valid ! empty(clmidno)
        @ 03,02 say "Student No. (UCMETC) :";
                color memvar->colorarray[02];
                get cidno pict "@!"
        read
        if lastkey() == K_ESC
                exit
        endif
        if empty(cidno)
                cidno := clmidno
        endif
        if uclmsm1p->(dbseek(clmidno))
                clmstud := alltrim(uclmsm1p->sm1lstnam)+", "+alltrim(uclmsm1p->sm1fstnam)+" "+alltrim(uclmsm1p->sm1midnam)
                @ 02,35 say "==> "+ clmstud
        else
                fask(10,"  ID No. : "+clmidno+";  Name  : "+;
                         alltrim(uclmsm1p->sm1lstnam)+",  "+;
                         alltrim(uclmsm1p->sm1fstnam)+"  "+;
                         alltrim(uclmsm1p->sm1midnam)+;
                         ";  Error  : Not found in UC-LM file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if c999sm1p->(dbseek(cidno))
                cmetcstud := alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+alltrim(c999sm1p->sm1midnam)
                @ 03,35 say "==> "+cmetcstud
        else
                cmetcstud := space(0)
        endif
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        adspscr := savescr(01,00,24,79)
/*        if ! c999sm1p->(dbseek(cidno))
                uclmsm1p->(dbseek(cidno))
                c999sm1p->(recycle())
                c999sm1p->sm1idno       := cidno
                c999sm1p->sm1lstnam     := uclmsm1p->sm1lstnam
                c999sm1p->sm1fstnam     := uclmsm1p->sm1fstnam
                c999sm1p->sm1midnam     := uclmsm1p->sm1midnam
                c999sm1p->sm1midname    := uclmsm1p->sm1midname
                c999sm1p->sm1sex        := uclmsm1p->sm1sex
                c999sm1p->sm1homadr     := uclmsm1p->sm1homadr
                c999sm1p->sm1nceeno     := uclmsm1p->sm1nceeno
                c999sm1p->sm1nceesc     := uclmsm1p->sm1nceesc
                c999sm1p->sm1nceeyr     := uclmsm1p->sm1nceeyr
                c999sm1p->sm1schtrm     := uclmsm1p->sm1schtrm
                c999sm1p->sm1colcod     := uclmsm1p->sm1colcod
                c999sm1p->sm1yrlevl     := uclmsm1p->sm1yrlevl
                c999sm1p->sm1cls        := uclmsm1p->sm1cls
                c999sm1p->sm1feeapp     := uclmsm1p->sm1feeapp
                c999sm1p->sm1majcod     := uclmsm1p->sm1majcod
                c999sm1p->(dbcommit())
                c999sm1p->(dbunlock())

                uclmsm2p->(dbseek(cidno))
                c999sm2p->(recycle())
                c999sm2p->sm2idno       := cidno
                c999sm2p->sm2citadr     := uclmsm2p->sm2citadr
                c999sm2p->sm2telno      := uclmsm2p->sm2telno
                c999sm2p->sm2prisc      := uclmsm2p->sm2prisc
                c999sm2p->sm2priyr      := uclmsm2p->sm2priyr
                c999sm2p->sm2intsc      := uclmsm2p->sm2intsc
                c999sm2p->sm2intyr      := uclmsm2p->sm2intyr
                c999sm2p->sm2secsc      := uclmsm2p->sm2secsc
                c999sm2p->sm2secyr      := uclmsm2p->sm2secyr
                c999sm2p->sm2colsc      := uclmsm2p->sm2colsc
                c999sm2p->sm2colyr      := uclmsm2p->sm2colyr
                c999sm2p->sm2nat        := uclmsm2p->sm2nat
                c999sm2p->sm2civsts     := uclmsm2p->sm2civsts
                c999sm2p->sm2rel        := uclmsm2p->sm2rel
                c999sm2p->sm2gdn        := uclmsm2p->sm2gdn
                c999sm2p->sm2birdte     := uclmsm2p->sm2birdte
                c999sm2p->sm2birplc     := uclmsm2p->sm2birplc
                c999sm2p->sm2entdat     := uclmsm2p->sm2entdat
                c999sm2p->sm2malad1     := uclmsm2p->sm2malad1
                c999sm2p->sm2malad2     := uclmsm2p->sm2malad2
                c999sm2p->sm2paynum     := uclmsm2p->sm2paynum
                c999sm2p->sm2dgradas    := uclmsm2p->sm2dgradas
                c999sm2p->sm2dgradbs    := uclmsm2p->sm2dgradbs
                c999sm2p->sm2dadmit     := uclmsm2p->sm2dadmit
                c999sm2p->sm2honors     := uclmsm2p->sm2honors
                c999sm2p->(dbcommit())
                c999sm2p->(dbunlock())
        endif
*/

/*        if ! uclmsm1p->(dbseek(cidno))
                fask(10,"  ID No. : "+cidno+";  Name  : "+;
                         alltrim(c999sm1p->sm1lstnam)+",  "+;
                         alltrim(c999sm1p->sm1fstnam)+"  "+;
                         alltrim(c999sm1p->sm1midnam)+;
                         ";  Error  : Not found in UC-LM file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
*/
        if ! (clmstud == cmetcstud)
                fask(10,"    Student name does not match   ",{"  ~Ok  "},memvar->colorarray[05])
                loop
        endif
        if ! fask(10,"    Proceed forwarding of records ?   ",{" ~Yes "," ~No  "},memvar->colorarray[05]) == 1
                loop
        endif
        restscr(adspscr)
        uclmtorp->(dbgotop())
        uclmtorp->(dbseek(clmidno))
        do while (uclmtorp->toridno==clmidno) .and. ! (uclmtorp->(eof()))
                for nctr := 1 to 17
                        fask(10,"  Term   : "+uclmtorp->torschtrm+";"+;
                                "  ID No. : "+uclmtorp->toridno+";"+;
                                "  Counter: "+transform(nctr,"99")+";"+;
                                "  ",{" Ok "},memvar->colorarray[05],.f.,nil)
                        cintcod1 := "torintcd"+if(nctr<10,"0","")+alltrim(transform(nctr,"99"))
                        cfingrd1 := "torfingd"+if(nctr<10,"0","")+alltrim(transform(nctr,"99"))
                        ccomgrd1 := "torcomgd"+if(nctr<10,"0","")+alltrim(transform(nctr,"99"))

                        cintcod2 := "torintcd"+strzero(nctr,2)
                        cfingrd2 := "torfingd"+strzero(nctr,2)
                        ccomgrd2 := "torcomgd"+strzero(nctr,2)

                        if ! empty(uclmtorp->&cintcod1)
                                if (nctr == 1)
                                if c999torp->(dbseek(uclmtorp->torschtrm+cidno))
                                        c999torp->(reclock())
                                else
                                        c999torp->(recycle())
                                        replace c999torp->toridno       with cidno,;
                                                c999torp->torschtrm     with uclmtorp->torschtrm,;
                                                c999torp->tordate       with uclmtorp->tordate,;
                                                c999torp->torcolcod     with uclmtorp->torcolcod,;
                                                c999torp->toryrlevl     with uclmtorp->toryrlevl
                                endif
                                endif
                                replace c999torp->&cintcod2     with uclmtorp->&cintcod1,;
                                        c999torp->&cfingrd2     with uclmtorp->&cfingrd1,;
                                        c999torp->&ccomgrd2     with uclmtorp->&ccomgrd1
                                if ! c999crsp->(dbseek(c999torp->&cintcod2)) .and. uclmcrsp->(dbseek(c999torp->&cintcod2))
                                        c999crsp->(recycle())
                                        c999crsp->crsintcod     := uclmcrsp->crsintcod
                                        c999crsp->crssubcod     := uclmcrsp->crssubcod
                                        c999crsp->crssubtyp     := uclmcrsp->crssubtyp
                                        c999crsp->crsdsc1       := uclmcrsp->crsdsc1
                                        c999crsp->crsdsc2       := uclmcrsp->crsdsc2
                                        c999crsp->crsgrpcod     := uclmcrsp->crsgrpcod
                                        c999crsp->crscreunt     := uclmcrsp->crscreunt
                                        c999crsp->crslechrs     := uclmcrsp->crslechrs
                                        c999crsp->crslabhrs     := uclmcrsp->crslabhrs
                                        c999crsp->crsprncod     := uclmcrsp->crsprncod
                                        c999crsp->rectrail      := "UCLM"
                                        c999crsp->(dbcommit())
                                        c999crsp->(dbunlock())
                                endif
                        endif
                next
                replace c999torp->tortrail with dtoc(date())+","+time()+","+memvar->cusername
                        c999torp->(dbcommit())
                        c999torp->(dbunlock())

                if nextkey() == K_ESC
                        exit
                endif
                uclmtorp->(dbskip())
        enddo
        uclmtorp->(clearscope())
        fask(10,"  Uploading finished.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)


// added 11-21-2003 by the MEGAdestructor
function updatrmfil()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode, cskdno := space(5), ;
      i, num1, num2, xbegtime, xendtime, lapse, daycounter, counter

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Subject Schedule Printing  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
do while .t.
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                restscr(alastscr)
                return(nil)
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        exit
enddo
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999rfil",,_DBF_SHARED,,1},;
                                     {,,"c999room",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyytskdp->(dbsetrelation("c999room",{||cyytskdp->skdrom},"cyytskdp->skdrom"))
        rmfildelete(cterm)
        cyytskdp->(dbgotop())
        do while ! cyytskdp->(eof())
                fask(10,"  Processing EDP Code ==> "+cyytskdp->skdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if lastkey() == K_ESC
                        exit
                endif

                for i := 1 to 24
                        cskdno := if(i < 10,"skd"+transform(i,"9"),"skd"+transform(i,"99"))
                        if empty(c999room->&cskdno)
                                c999room->(reclock())
                                c999room->&cskdno := cyytskdp->skdcod
                                c999room->(dbcommit())
                                c999room->(dbunlock())
                                exit
                        endif
                next

                if ! c999room->status $ "LM"
                for daycounter := 1 to 7
                        if substr(cyytskdp->skddayx,daycounter,1) == "X"
                                num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
                                num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
                                xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
                                xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
                                lapse := (xendtime - xbegtime)/0.5
                                if c999rfil->(dbseek(cterm+cyytskdp->skdrom+transform(daycounter,"9")))
                                        c999rfil->(reclock())
                                else
                                        c999rfil->(recycle())
                                        c999rfil->term   := cterm
                                        c999rfil->roomno := cyytskdp->skdrom
                                        c999rfil->day    := transform(daycounter,"9")
                                endif

                                if lastkey() == K_ESC
                                        exit
                                endif

                                for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                                   if substr(c999rfil->timeavail,counter+1,1) != "Ü"
                                      c999rfil->timeavail := stuff(c999rfil->timeavail,counter+1,1,"Ü")
                                   else
                                      c999rfil->timeavail := stuff(c999rfil->timeavail,counter+1,1,"*")
                                   endif
                                next counter
                                c999rfil->(dbcommit())
                                c999rfil->(dbunlock())
                        endif

                                if lastkey() == K_ESC
                                        exit
                                endif

                next daycounter
                endif
                cyytskdp->(dbskip())
        enddo
        closewcheck(aprv2setup)
        fask(16,"  Processing Complete...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function rmfildelete(cterm)

//if fask(10,"    Clean-up Room File ?    ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        c999room->(dbgotop())
        do while ! c999room->(eof())
//                fask(10," cProcessing room number "+c999room->roomno+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                fask(10,"   C999ROOM, Clearing Room# =>  "+c999room->roomno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                for nctr := 1 to 24
                        cskdno := if(nctr < 10,"skd"+transform(nctr,"9"),"skd"+transform(nctr,"99"))
                        if ! empty(c999room->&cskdno)
                                c999room->(reclock())
                                c999room->&cskdno := space(05)
                                c999room->(dbcommit())
                                c999room->(dbunlock())
                        endif
                next
                c999room->(dbskip())
        enddo
//endif

c999rfil->(sx_setscope(_TOP_SCOPE   ,cterm))
c999rfil->(sx_setscope(_BOTTOM_SCOPE,cterm))
c999rfil->(dbgotop())
do while ! c999rfil->(eof())
        c999rfil->(dbgotop())
        fask(10,"   C999RFIL, Clearing Room# =>  "+c999rfil->roomno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999rfil->(reclock())
        c999rfil->roomno := _DELETE_TAG
        c999rfil->(dbdelete())
        c999rfil->(dbcommit())
        c999rfil->(dbunlock())
enddo
c999rfil->(clearscope())
return(nil)

*------------------------------------------------------------------------------*

function uplodmnskdp()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode, afiles, ;
      i, num1, num2, xbegtime, xendtime, lapse, daycounter, counter

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Upload MAINSKDP to METC File  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
do while .t.
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                restscr(alastscr)
                return(nil)
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        exit
enddo

        if file("MAINSKDP.CDX")
                ferase("MAINSKDP.CDX")
        endif
        if(afiles := openwcheck({{,,"mainskdp",,_DBF_SHARED,,1}})) == nil
                fask(10,"  MAINSKDP File does not exist...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                closewcheck(aprv1setup)
                return(nil)
        endif
        index on SKDCOD+SKDSUBCOD               tag mainskd1 of mainskdp option indexbar()
        closewcheck(afiles)

        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"mainskdp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        cyytskdp->(dbgotop())
        memvar->nlast := cyytskdp->(lastrec())
        statusbar()
        do while ! cyytskdp->(eof())
                showprogress()
                cyytskdp->(reclock())
                cyytskdp->skdmainsiz := 0
                cyytskdp->(dbcommit())
                cyytskdp->(dbunlock())
                cyytskdp->(dbskip())
        enddo
        i:=0
        mainskdp->(dbgotop())
        memvar->nlast := mainskdp->(lastrec())
        statusbar()
        do while ! mainskdp->(eof())
                showprogress()
                if cyytskdp->(dbseek(mainskdp->skdcod+mainskdp->skdsubcod))
                        cyytskdp->(reclock())
                else
                        cyytskdp->(dbappend())
                        cyytskdp->skdcod        := mainskdp->skdcod
                        cyytskdp->skdsubcod     := mainskdp->skdsubcod
                        cyytskdp->skdsubtyp     := mainskdp->skdsubtyp
                        cyytskdp->skdbegtim     := mainskdp->skdbegtim
                        cyytskdp->skdendtim     := mainskdp->skdendtim
                        cyytskdp->skdmdn        := mainskdp->skdmdn
                        cyytskdp->skdday        := mainskdp->skdday
                        cyytskdp->skdrom        := mainskdp->skdrom
                        cyytskdp->skdunt        := mainskdp->skdunt
                        cyytskdp->skdintcod     := mainskdp->skdintcod
                        cyytskdp->skdbegtimx    := mainskdp->skdbegtimx
                        cyytskdp->skdendtimx    := mainskdp->skdendtimx
                        cyytskdp->skddayx       := mainskdp->skddayx
                        cyytskdp->skdactsiz     := 0
                        cyytskdp->skdmaxsiz     := mainskdp->skdmaxsiz
                        cyytskdp->skdrevcod     := mainskdp->skdrevcod
                        cyytskdp->skdcolcod     := mainskdp->skdcolcod
                        cyytskdp->skdsec        := mainskdp->skdsec
                        cyytskdp->skdsplcod     := mainskdp->skdsplcod
                        cyytskdp->skdgrpcod     := mainskdp->skdgrpcod
                        cyytskdp->skdsplskd     := mainskdp->skdsplskd
                        cyytskdp->skdblkcode    := mainskdp->skdblkcode
                        cyytskdp->rectrail      := "MAIN"+dtoc(date())+";"+time()+";"+memvar->cusername
                endif
                cyytskdp->skdmainsiz := mainskdp->skdactsiz
                cyytskdp->(dbcommit())
                cyytskdp->(dbunlock())
                mainskdp->(dbskip())
        enddo

        fask(10,"  Uploading MAINSKDP completed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
restscr(alastscr)
closewcheck(aprv2setup)
closewcheck(aprv1setup)
return(nil)

* ------------------------------------------------------------------------
*       Remove Dissolved Subjects
* ------------------------------------------------------------------------

function remsubjdis()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,nctr,aprv1setup,aentryscr,cyytenrp,cyytenrr,cyytskdp,;
      cterm,ccolcode,cskdno,ccourse,adspscr,bfound:=.f.,i
private nlast,nrec

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        cterm := space(len(term->code))
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Remove Dissolve Subjects  ")
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
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := alltrim("c"+cterm+"enrp")
        cyytenrr        := alltrim("c"+cterm+"enrr")
        cyytskdp        := alltrim("c"+cterm+"skdp")
        if(aprvsetup    := openwcheck({{,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2},;
                                       {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                       {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyytskdp->(dbgotop())
        do while ! cyytskdp->(eof())
                if cyytskdp->skdrescod == "4"
                        cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                        cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                        do while ! cyytenrr->(eof())
                                bfound := .f.
                                fask(10,"  "+cyytenrr->enrskdcod+"   ",{" Ok "},memvar->colorarray[04],.f.,nil)
                                cyytenrp->(dbseek(cyytenrr->enridno))
                                for nctr := 1 to 25
                                        cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                                        if cyytenrp->&cskdno == cyytskdp->skdcod
                                                bfound := .t.

                                        endif
                                        if bfound .and. (nctr < 17)

                                        endif
                                next
                                cyytenrr->(reclock())
                                cyytenrr->enridno := _DELETE_TAG
                                cyytenrr->(dbdelete())
                                cyytenrr->(dbcommit())
                                cyytenrr->(dbunlock())
                                cyytenrr->(dbgotop())
                        enddo
                endif
                cyytskdp->(dbskip())
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*
/*

                             for nctr := 1 to 17
                                        cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                                        if ! cyytenrp->&cskdno == "00000"

                                        endif
                             next

*/

