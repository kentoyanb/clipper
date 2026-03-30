* Program       :  TERM.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function term()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[11]),;
      aentryscr,aprvsetup,ccode,cname,cstatus,cprocsts,lexist := .f.

if(aprvsetup := openwcheck({{,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"term_log",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

boxshadow(05,20,13,60,"лплллмлл ",memvar->colorarray[11],"  Term File Entry  ")
commandline("Г         F4 - View Term File          Г            ESC - Previous             Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        ccode   := space(len(term->code))
        cname   := space(len(term->name))
        cstatus := space(len(term->status))
        clearbuffer()
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 07,22 say "Term   :";
                color memvar->colorarray[02];
                get ccode       pict "@!";
                valid ! empty(ccode)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if lexist := term->(dbseek(ccode))
                if ! term->(reclock())
                        loop
                endif
                cname   := term->name
                cstatus := term->status
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 09,22 say "Name   :";
                color memvar->colorarray[02];
                get cname       pict "@!S25";
                valid ! empty(cname)
        @ 11,22 say "Status :";
                color memvar->colorarray[02];
                get cstatus     pict "@!";
                valid cstatus $ "C,L, "
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(11,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif

// Save log file
        term_log->(dbappend())
        term_log->code      := term->code
        term_log->name      := term->name
        term_log->status    := term->status
        term_log->user      := memvar->cusername
        term_log->rectrail  := term->rectrail
        term_log->(dbcommit())
        term_log->(dbunlock())

        if ! lexist
                if ! term->(recycle())
                        loop
                endif
        endif

        term->code      := ccode
        term->name      := cname
        term->status    := cstatus
        term->rectrail  := displaydate(date())+";"+time()+";"+memvar->cusername
        term->(dbcommit())
        term->(dbunlock())
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function aprentice()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[11]),;
      aentryscr,aprv1setup,aprv2setup,cprocsts,lexist:=.f.,cyytaprp,;
      cterm,cname,cidno,clname,cfname,cmname,dprocess,ccityadd,cprovadd,;
      cvesselname,cvesseltype,ngrosston,nnetton,cregistry,cowner,;
      cownadd,dembarkation,cyrlevel
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Apprentice Mate Data Entry  ")
        commandline("Г         F4 - View Term File          Г            ESC - Previous             Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
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
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        if ! file("c"+cterm+"aprp.dbf")
                fask(10,"  C"+cterm+"APRP.DBF not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytaprp        := "c"+cterm+"aprp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,, cyytaprp ,"cyytaprp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cidno := space(len(c999sm1p->sm1idno))
        do while .t.
                restscr(aentryscr)
                commandline("Г        F4 - View Student File         Г           ESC - Previous             Г")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "<<Student Information>>" color memvar->colorarray[02]
                @ 05,02 say "    Student Number . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cidno pict "@!" valid ! empty(cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(cidno))
                        fask(10,"  ID number "+cidno+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if cyytaprp->(dbseek(cidno))
                        clname          := cyytaprp->aprlname
                        cfname          := cyytaprp->aprfname
                        cmname          := cyytaprp->aprmname
                        dprocess        := cyytaprp->aprdate
                        cyrlevel        := cyytaprp->apryrlevel
                        ccityadd        := cyytaprp->aprcityadd
                        cprovadd        := cyytaprp->aprprovadd
                        cvesselname     := cyytaprp->aprvesname
                        cvesseltype     := cyytaprp->aprvestype
                        ngrosston       := cyytaprp->aprgrston
                        nnetton         := cyytaprp->aprnetton
                        cregistry       := cyytaprp->aprreg
                        cowner          := cyytaprp->aprowner
                        cownadd         := cyytaprp->aprownadd
                        dembarkation    := cyytaprp->aprembdate
                        commandline("Г            F3 - Delete               Г          ESC - Previous               Г")
                        setkey(K_F3,{||delapren()})
                else
                        commandline("Г                               ESC - Previous                                 Г")
                        c999sm2p->(dbseek(cidno))
                        clname          := c999sm1p->sm1lstnam
                        cfname          := c999sm1p->sm1fstnam
                        cmname          := c999sm1p->sm1midnam
                        dprocess        := ctod("")
                        cyrlevel        := space(len(cyytaprp->apryrlevel))
                        ccityadd        := c999sm2p->sm2citadr
                        cprovadd        := c999sm1p->sm1homadr
                        cvesselname     := space(len(cyytaprp->aprvesname))
                        cvesseltype     := space(len(cyytaprp->aprvestype))
                        ngrosston       := 0
                        nnetton         := 0
                        cregistry       := space(len(cyytaprp->aprreg))
                        cowner          := space(len(cyytaprp->aprowner))
                        cownadd         := space(len(cyytaprp->aprownadd))
                        dembarkation    := ctod("")
                endif
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 06,02 say "    Last Name  . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "    First Name . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
                @ 08,02 say "    Middle Initial . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cmname pict "@!"
                @ 09,02 say "    Date Processed . . . . . . . . :";
                        color memvar->colorarray[02];
                        get dprocess
                @ 10,02 say "    Year Level . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!" valid cyrlevel $ "12345"
                @ 11,02 say "    City Address . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get ccityadd pict "@!"
                @ 12,02 say "    Provincial Address . . . . . . :";
                        color memvar->colorarray[02];
                        get cprovadd pict "@!"
                @ 14,02 say "<<Vessel Information>>" color memvar->colorarray[02]
                @ 15,02 say "    Vessel Name  . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cvesselname pict "@!"
                @ 16,02 say "                                       [F-oreign/C-oastwise]" color memvar->colorarray[02]
                @ 16,02 say "    Vessel Type  . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cvesseltype pict "@!"
                @ 17,02 say "    Gross Tons . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get ngrosston pict "999,999,999.99"
                @ 18,02 say "    Net Tons . . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get nnetton pict "999,999,999.99"
             *   @ 19,02 say "                                       [P-hilippines/F-oreign]" color memvar->colorarray[02]
                @ 19,02 say "    Registry . . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cregistry pict "@!"
                @ 20,02 say "    Owner/Operator/Agent . . . . . :";
                        color memvar->colorarray[02];
                        get cowner pict "@!"
                @ 21,02 say "    Address  . . . . . . . . . . . :";
                        color memvar->colorarray[02];
                        get cownadd pict "@!"
                @ 22,02 say "    Date of Embarkation  . . . . . :";
                        color memvar->colorarray[02];
                        get dembarkation
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F3,nil)
                if lastkey() == K_ESC
                        loop
                endif
                if ! fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                if cyytaprp->(dbseek(cidno))
                        cyytaprp->(reclock())
                else
                        cyytaprp->(recycle())
                endif
                cyytaprp->apridno       := cidno
                cyytaprp->aprlname      := clname
                cyytaprp->aprfname      := cfname
                cyytaprp->aprmname      := cmname
                cyytaprp->aprdate       := dprocess
                cyytaprp->apryrlevel    := cyrlevel
                cyytaprp->aprcityadd    := ccityadd
                cyytaprp->aprprovadd    := cprovadd
                cyytaprp->aprvesname    := cvesselname
                cyytaprp->aprvestype    := cvesseltype
                cyytaprp->aprgrston     := ngrosston
                cyytaprp->aprnetton     := nnetton
                cyytaprp->aprreg        := cregistry
                cyytaprp->aprowner      := cowner
                cyytaprp->aprownadd     := cownadd
                cyytaprp->aprembdate    := dembarkation
                cyytaprp->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
                cyytaprp->(dbcommit())
                cyytaprp->(dbunlock())
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function delapren()
if fask(10,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        cyytaprp->(reclock())
        cyytaprp->apridno := _DELETE_TAG
        cyytaprp->(dbdelete())
        cyytaprp->(dbcommit())
        cyytaprp->(dbunlock())
        keyboard(chr(K_ESC))
endif
return(nil)
