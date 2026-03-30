* Program       : DBASE.PRG
* Author        : jHUN bENLOT & tOPZ fLORENTiNO
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
      atagname,byytpayp

if fask(10,"  Create database for Cashier PAYP.DBF file (byytpayp.dbf) ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   Create byytPAYP.DBF   ")
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
                cfile := "b"+cterm+"payp"
                if ! file(cfile+".dbf")
                        afiles := {{,,"zyytpayp",,_DBF_EXCLUSIVE,,}}
                        openwcheck(afiles)
                        copy structure to &(cfile)
                        dbclosearea()
                        openwcheck({{,,cfile,"byytpayp",_DBF_EXCLUSIVE,,}})
                        atagname := "b"+cterm+"pay"
                        cdxpayp(byytpayp,atagname)
                        dbclosearea()
                endif
        endif
endif
restscr(alastscr)
return(nil)
