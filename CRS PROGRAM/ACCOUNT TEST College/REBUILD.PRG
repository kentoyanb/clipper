* Program       : REBUILD.PRG
* Author        : Randy F. Santizo and Jun Benlot (c) August 1998
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function buildfile()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      ayytpayp,ayytassp,ayytprsp,cyytstsp,cyytsecp,afiles,alastscr := savescr(01,00,24,79),;
      atagname

if fask(10,"        Rebuild A999FEEP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999feep",,_DBF_EXCLUSIVE,,}}
        if file("a999feep.CDX")
                ferase("a999feep.CDX")
        endif
        openwcheck(afiles)
        index on FEESCHYR+FEECOLCOD+FEETRM      tag A999FEE1 of A999FEEP option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999LBFP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999lbfp",,_DBF_EXCLUSIVE,,}}
        if file("a999lbfp.CDX")
                ferase("a999lbfp.CDX")
        endif
        openwcheck(afiles)
        index on LBFSCHYR+LBFINTCOD+LBFCOLCOD   tag A999LBF1 of A999LBFP option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild  A999ACCP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999accp",,_DBF_EXCLUSIVE,,}}
        if file("a999accp.CDX")
                ferase("a999accp.CDX")
        endif
        openwcheck(afiles)
        index on ACCIDNO                                tag A999ACC1 of A999ACCP option indexbar()
        index on ACCLNAME+ACCFNAME+ACCMNAME             tag A999ACC2 of A999ACCP option indexbar()
        index on ACCCOLCOD+ACCIDNO                      tag A999ACC3 of A999ACCP option indexbar()
        index on ACCCOLCOD+ACCLNAME+ACCFNAME+ACCMNAME   tag A999ACC4 of A999ACCP option indexbar()
        index on ACCSYT+ACCIDNO                         tag A999ACC5 of A999ACCP option indexbar()
        dbclosearea()
endif


if fask(10,"        Rebuild  A999AMLP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999amlp",,_DBF_EXCLUSIVE,,}}
        if file("a999amlp.CDX")
                ferase("a999amlp.CDX")
        endif
        openwcheck(afiles)
        index on AMLIDNO+AMLSYT         tag A999AML1 of A999AMLP option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999PAYD ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999payd",,_DBF_EXCLUSIVE,,}}
        if file("a999payd.CDX")
                ferase("a999payd.CDX")
        endif
        openwcheck(afiles)
        index on PDSCHTERM+PDGDPERIOD   tag A999PAY1 of A999PAYD option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999PRCP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999prcp",,_DBF_EXCLUSIVE,,}}
        if file("a999prcp.CDX")
                ferase("a999prcp.CDX")
        endif
        openwcheck(afiles)
        index on PRCCODE        tag A999PRC1 of A999PRCP option indexbar()
        index on PRCDESCR       tag A999PRC2 of A999PRCP option indexbar()
        dbclosearea()
endif


if fask(10,"        Rebuild A999STCP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999stcp",,_DBF_EXCLUSIVE,,}}
        if file("a999stcp.cdx")
                ferase("a999stcp.cdx")
        endif
        openwcheck(afiles)
        index on STCCOD        tag A999STC1 of A999STCP option indexbar()
        index on STCDESFUL     tag A999STC2 of A999STCP option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999CTRL ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999ctrl",,_DBF_EXCLUSIVE,,}}
        if file("a999ctrl.CDX")
                ferase("a999ctrl.CDX")
        endif
        openwcheck(afiles)
        index on TERM+CCODE   tag A999CTR1 of A999CTRL option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999CHRT ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999chrt",,_DBF_EXCLUSIVE,,}}
        if file("a999chrt.CDX")
                ferase("a999chrt.CDX")
        endif
        openwcheck(afiles)
        index on CODE   tag A999CHR1 of A999CHRT option indexbar()
        index on DESC   tag A999CHR2 of A999CHRT option indexbar()
        dbclosearea()
endif

if fask(10,"        Rebuild A999STRA ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999stra",,_DBF_EXCLUSIVE,,}}
        if file("a999stra.CDX")
                ferase("a999stra.CDX")
        endif
        openwcheck(afiles)
        index on STRNDYR+STRNDBCOD+STRNDTRM+STRNDSBSID      tag A999STRA1 of A999STRA option indexbar()
        dbclosearea()
endif


do while fask(10,"        Rebuild AYYTPAYP.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   AYYTPAYP.DBF   ")
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
                if ! file(alltrim("a"+cterm+"payp.dbf"))
                        fask(13,"   File A"+cterm+"PAYP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytpayp := "A"+cterm+"PAYP"
                atagname := "A"+cterm+"PAY"
                afiles   := {{,,ayytpayp,,_DBF_EXCLUSIVE,,}}
                if file(ayytpayp+".CDX")
                        ferase(ayytpayp+".CDX")
                endif
                openwcheck(afiles)
                cdxpayp(ayytpayp,atagname)
                dbclosearea()
        endif
enddo

do while fask(10,"        Rebuild AYYTASSP.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   AYYTASSP.DBF   ")
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
                if ! file(alltrim("a"+cterm+"assp.dbf"))
                        fask(13,"   File A"+cterm+"ASSP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytassp := "A"+cterm+"ASSP"
                atagname := "A"+cterm+"ASS"
                afiles   := {{,,ayytassp,,_DBF_EXCLUSIVE,,}}
                if file(ayytassp+".CDX")
                        ferase(ayytassp+".CDX")
                endif
                openwcheck(afiles)
                cdxassp(ayytassp,atagname)
                dbclosearea()
        endif
enddo

do while fask(10,"        Rebuild AYYTPRSP.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   AYYTPRSP.DBF   ")
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
                if ! file(alltrim("a"+cterm+"prsp.dbf"))
                        fask(13,"   File A"+cterm+"PRSP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytprsp := "A"+cterm+"PRSP"
                atagname := "A"+cterm+"PRS"
                afiles   := {{,,ayytprsp,,_DBF_EXCLUSIVE,,}}
                if file(ayytprsp+".CDX")
                        ferase(ayytprsp+".CDX")
                endif
                openwcheck(afiles)
                cdxprsp(ayytprsp,atagname)
                dbclosearea()
        endif
enddo

//todo
do while fask(10,"        Rebuild AYYTEPC.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   AYYTEPC.DBF   ")
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
                if ! file(alltrim("a"+cterm+"epc.dbf"))
                        fask(13,"   File A"+cterm+"EPC.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytepc := "A"+cterm+"EPC"
                atagname := "A"+cterm+"PRS"
                afiles   := {{,,ayytepc,,_DBF_EXCLUSIVE,,}}
                if file(ayytepc+".CDX")
                        ferase(ayytepc+".CDX")
                endif
                openwcheck(afiles)
                cdxepc(ayytepc,atagname)
                dbclosearea()
        endif
enddo
//todo
do while fask(10,"        Rebuild AYYTEPB.DBF ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   AYYTEPB.DBF   ")
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
                if ! file(alltrim("a"+cterm+"epb.dbf"))
                        fask(13,"   File A"+cterm+"EPB.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytepb := "A"+cterm+"EPB"
                atagname := "A"+cterm+"PRS"
                afiles   := {{,,ayytepb,,_DBF_EXCLUSIVE,,}}
                if file(ayytepb+".CDX")
                        ferase(ayytepb+".CDX")
                endif
                openwcheck(afiles)
                cdxepb(ayytepb,atagname)
                dbclosearea()
        endif
enddo


if fask(10,"     Rebuild Cashier Control?     ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"csctrl",,_DBF_EXCLUSIVE,,}}
        if file("csctrl.CDX")
                ferase("csctrl.CDX")
        endif
        openwcheck(afiles)
        index on TERM      tag TERM of CSCTRL option indexbar()
        dbclosearea()
endif

if fask(10,"          Rebuild DORM?           ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"dorm",,_DBF_EXCLUSIVE,,}}
        if file("dorm.CDX")
                ferase("dorm.CDX")
        endif
        openwcheck(afiles)
        index on D_IDNO      tag DORM1 of DORM option indexbar()
        dbclosearea()
endif

restscr(alastscr)
return(nil)



function cdxpayp(ayytpayp,atagname)
index on PAYREFNO+DTOS(PAYDTE)          tag (atagname+"1") of (ayytpayp) option indexbar()
index on PAYIDNO+DTOS(PAYDTE)           tag (atagname+"2") of (ayytpayp) option indexbar()
index on PAYCOLCOD+PAYIDNO              tag (atagname+"3") of (ayytpayp) option indexbar()
index on PAYIDNO+PAYTAG                 tag (atagname+"4") of (ayytpayp) option indexbar()
index on PAYCOLCOD+STR(PAYAMT)          tag (atagname+"5") of (ayytpayp) option indexbar()
index on PAYTAG+PAYCOLCOD               tag (atagname+"6") of (ayytpayp) option indexbar()
index on PAYIDNO+PAYREFNO+DTOS(PAYDTE)  tag (atagname+"7") of (ayytpayp) option indexbar()
index on PAYREFNO+PAYTAG                tag (atagname+"8") of (ayytpayp) option indexbar()
index on PAYIDNO+PAYCOLCOD              tag (atagname+"9") of (ayytpayp) option indexbar()
index on PAYIDNO+PAYADJCOD              tag (atagname+"10") of (ayytpayp) option indexbar()
index on PAYIDNO                        tag (atagname+"11") of (ayytpayp) option indexbar()
index on PAYIDNO+PAYREFNO+PAYENTTME  tag (atagname+"12") of (ayytpayp) option indexbar()

return(nil)


function cdxassp(ayytassp,atagname)
index on ASSIDNO                tag (atagname+"1") of (ayytassp) option indexbar()
index on ASSCOLCOD              tag (atagname+"2") of (ayytassp) option indexbar()
index on ASSYRLEVL+ASSCOLCOD    tag (atagname+"3") of (ayytassp) option indexbar()
index on ASSIDNO+ASSEXAMTAG     tag (atagname+"4") of (ayytassp) option indexbar()
return(nil)



function cdxprsp(ayytprsp,atagname)
index on PRSIDNO+PRSCOLCOD        tag (atagname+"1") of (ayytprsp) option indexbar()
index on PRSCOLCOD                tag (atagname+"2") of (ayytprsp) option indexbar()
index on PRSCODE                  tag (atagname+"3") of (ayytprsp) option indexbar()
index on PRSCOLCOD                tag (atagname+"4") of (ayytprsp) option indexbar()
return(nil)


function cdxepc(ayytepc,atagname)
index on EPIDNO                   tag (atagname+"1") of (ayytepc) option indexbar()
index on EPLNAME                  tag (atagname+"2") of (ayytepc) option indexbar()
index on EPCOURSE                 tag (atagname+"3") of (ayytepc) option indexbar()
index on EPPERIOD                 tag (atagname+"4") of (ayytepc) option indexbar()
return(nil)

function cdxepb(ayytepb,atagname)
index on BEPIDNO                   tag (atagname+"1") of (ayytepb) option indexbar()
index on BEPLNAME                  tag (atagname+"2") of (ayytepb) option indexbar()

return(nil)