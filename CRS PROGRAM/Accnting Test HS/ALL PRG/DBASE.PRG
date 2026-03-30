* Program       : DBASE.PRG
* Author        : Randy F. Santizo (c) March 1999
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function createdatabase()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      ayytpayp,ayytassp,ayytprsp,afiles,alastscr := savescr(01,00,24,79),;
      atagname



if fask(10,"  Create database for ASSP.DBF file (ayytassp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create ayytASSP.DBF   ")
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
                cfile := "a"+cterm+"assp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytassp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"ayytassp",_DBF_EXCLUSIVE,,}})
                        atagname := "a"+cterm+"ass"
                        cdxassp(ayytassp,atagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)




if fask(10,"  Create database for PAYP.DBF file (ayytpayp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create ayytPAYP.DBF   ")
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
                cfile := "a"+cterm+"payp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytpayp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"ayytpayp",_DBF_EXCLUSIVE,,}})
                        atagname := "a"+cterm+"pay"
                        cdxpayp(ayytpayp,atagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)




if fask(10,"  Create database for PRSP.DBF file (ayytprsp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create ayytPRSP.DBF   ")
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
                cfile := "a"+cterm+"prsp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"xyytprsp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"ayytprsp",_DBF_EXCLUSIVE,,}})
                        atagname := "a"+cterm+"prs"
                        cdxprsp(ayytpayp,atagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)

return(nil)
