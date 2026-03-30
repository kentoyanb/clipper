* Program       : DBASE.PRG
* Author        : Randy F. Santizo (c) March 1999
* Updated       : Feb 2008 (Jun Benlot)
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function createdatabase()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      cyytskdp,cyytenrp,cyytflag,cyytstsp,cyytstsl,cyytsecp,afiles,alastscr := savescr(01,00,24,79),;
      ctagname,cyytenrr,cyytappp,cyytmdst


if fask(10,"  Create database for APPP.DBF file (cyytappp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytAPPP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"appp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytappp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytappp",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"app"
                        cdxappp(cyytappp,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)


if fask(10,"  Create database for ENRP.DBF file (cyytenrp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytENRP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"enrp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytenrp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytenrp",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"enr"
                        cdxenrp(cyytenrp,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)




if fask(10,"  Create database for ENRR.DBF file (cyytenrr.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytENRR.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"enrr"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytenrr",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytenrr",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"ens"
                        cdxenrr(cyytenrr,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)

if fask(10,"  Create database for MDST.DBF file (cyytmdst.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytMDST.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"mdst"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytmdst",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytmdst",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"mds"
                        cdxmdst(cyytmdst,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)




if fask(10,"  Create database for FLAG.DBF file (cyytflag.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytFLAG.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"flag"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytflag",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytflag",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"fla"
                        cdxflag(cyytflag,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)




if fask(10,"  Create database for SKDP.DBF file (cyytskdp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytSKDP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"skdp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytskdp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytskdp",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"skd"
                        cdxskdp(cyytskdp,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)

if fask(10,"  Create database for STSP.DBF file (cyytstsp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytSTSP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"stsp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytstsp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytstsp",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"sts"
                        cdxstsp(cyytstsp,ctagname)
                        dbclosearea()
                endif
                cfile := "c"+cterm+"stsl"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytstsl",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytstsl",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"stl"
                        cdxstsl(cyytstsl,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)

if fask(10,"  Create database for SECP.DBF file (cyytsecp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create cyytSECP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                __keyboard(chr(K_ESC)) &&exit
                restscr(alastscr)
        elseif lastkey() == K_ENTER
                cfile := "c"+cterm+"secp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytsecp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"cyytsecp",_DBF_EXCLUSIVE,,}})
                        ctagname := "c"+cterm+"sec"
                        cdxsecp(cyytsecp,ctagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)

return(nil)
