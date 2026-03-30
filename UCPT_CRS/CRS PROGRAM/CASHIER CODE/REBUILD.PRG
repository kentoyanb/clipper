* Program       : REBUILD.PRG
* Author        : jHUN bENLOT & tOPZ fLORETiNO
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function buildfile()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      byytpayp,afiles,alastscr := savescr(01,00,24,79),atagname


if fask(10,"        Rebuild B999CHRT ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"b999chrt",,_DBF_EXCLUSIVE,,}}
        if file("b999chrt.CDX")
                ferase("b999chrt.CDX")
        endif
        openwcheck(afiles)
        index on CODE                   tag B999CHR1 of B999CHRT option indexbar()
        index on DESC                   tag B999CHR2 of B999CHRT option indexbar()
        index on ACCCODE                tag B999CHR3 of B999CHRT option indexbar()
        index on left(CODE,1)+DESC      tag B999CHR4 of B999CHRT option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild PARA ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"para",,_DBF_EXCLUSIVE,,}}
        if file("para.CDX")
                ferase("para.CDX")
        endif
        openwcheck(afiles)
        index on SEQNO                  tag PARA1 of PARA option indexbar()
        index on C1ORSEQNO              tag PARA2 of PARA option indexbar()
        index on C2ORSEQNO              tag PARA3 of PARA option indexbar()
        dbclosearea()
endif

/*
if fask(10,"        Rebuild CASHIER 1?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"cs01",,_DBF_EXCLUSIVE,,}}
        if file("cs01.CDX")
                ferase("cs01.CDX")
        endif
        openwcheck(afiles)
        index on ORSEQNO                tag PARA1 of PARA option indexbar()
        dbclosearea()
endif
*/

do while fask(10,"        Rebuild BYYTPAYP.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   BYYTPAYP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm       pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        elseif lastkey() == K_ENTER
                if ! file(alltrim("b"+cterm+"payp.dbf"))
                        fask(13,"   File B"+cterm+"PAYP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                byytpayp := "B"+cterm+"PAYP"
                atagname := "B"+cterm+"PAY"
                afiles   := {{,,byytpayp,,_DBF_EXCLUSIVE,,}}
                if file(byytpayp+".CDX")
                        ferase(byytpayp+".CDX")
                endif
                openwcheck(afiles)
                cdxpayp(byytpayp,atagname)
                dbclosearea()
        endif
enddo
fask(10,"  Rebuilding Indexes Success !  ",{" Ok "},memvar->colorarray[05],.t.,nil)

restscr(alastscr)
return(nil)


//index on PAYSEQNO                               tag (atagname+"1") of (byytpayp) option indexbar()
function cdxpayp(byytpayp,atagname)
index on PAYORNO                                tag (atagname+"1") of (byytpayp) option indexbar()
index on PAYORNO+DTOS(PAYDTE)                   tag (atagname+"2") of (byytpayp) option indexbar()
index on PAYCOLCOD+PAYIDNO                      tag (atagname+"3") of (byytpayp) option indexbar()
index on PAYIDNO+PAYCLASS                       tag (atagname+"4") of (byytpayp) option indexbar()
index on PAYIDNO+DTOS(PAYDTE)+PAYCODE           tag (atagname+"5") of (byytpayp) option indexbar()
index on PAYIDNO+PAYTAG                         tag (atagname+"6") of (byytpayp) option indexbar()
index on PAYENTUSR+PAYTAG+PAYCODE               tag (atagname+"7") of (byytpayp) option indexbar()
index on PAYENTUSR+PAYORNO+PAYCODE              tag (atagname+"8") of (byytpayp) option indexbar()
index on PAYORNO+PAYCODE                        tag (atagname+"9") of (byytpayp) option indexbar()
index on PAYIDNO+PAYORNO                        tag (atagname+"10") of (byytpayp) option indexbar()
index on PAYCODE                                tag (atagname+"11") of (byytpayp) option indexbar()
return(nil)

