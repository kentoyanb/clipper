*=============================================================================
* Program       : REBUILD.PRG
* Author        : Randy F. Santizo and Jun Benlot (c) August 1998
* Installation  : UC-METC
*=============================================================================
#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"
*-----------------------------------------------------------------------------
function buildfile()
buildfile1()
buildfile2()
return(nil)

function buildfile1()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      cyytskdp,cyytenrp,cyytflag,cyytstsp,cyytsecp,afiles,alastscr := savescr(01,00,24,79),;
      ctagname,cyytenrr,cyytappp,cyytmdst

*-----------------------------------------------------------------------------
if fask(10,"     Rebuild TERM.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1

        afiles := {{,,"TERM",,_DBF_EXCLUSIVE,,}}
        if file("TERM.CDX")
                ferase("TERM.CDX")
        endif
        openwcheck(afiles)
        index on CODE   tag TERM1 of TERM option indexbar()
        dbclosearea()

        afiles := {{,,"TERM_LOG",,_DBF_EXCLUSIVE,,}}
        if file("TERM_LOG.CDX")
                ferase("TERM_LOG.CDX")
        endif
        openwcheck(afiles)
        index on CODE+RECTRAIL   tag TERM1 of TERM_LOG option indexbar()
        index on USER+RECTRAIL   tag TERM2 of TERM_LOG option indexbar()
        dbclosearea()
endif

*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999COLP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999COLP",,_DBF_EXCLUSIVE,,}}
        if file("C999COLP.CDX")
                ferase("C999COLP.CDX")
        endif
        openwcheck(afiles)
        index on COLCOD         tag C999COL1 of C999COLP option indexbar()
        index on COLNAMCOL      tag C999COL2 of C999COLP option indexbar()
        index on COLDESFUL      tag C999COL3 of C999COLP option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999CRSP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999CRSP",,_DBF_EXCLUSIVE,,}}
        if file("C999CRSP.CDX")
                ferase("C999CRSP.CDX")
        endif
        openwcheck(afiles)
        index on CRSINTCOD      tag C999CRS1 of C999CRSP option indexbar()
        index on crssubcod      tag C999CRS2 of C999CRSP option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999CURP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999CURP",,_DBF_EXCLUSIVE,,}}
        if file("C999CURP.CDX")
                ferase("C999CURP.CDX")
        endif
        openwcheck(afiles)
        index on CURREVCOD+CURCOLCOD+CURSUBCOD+CURSUBTYP        tag C999CUR1 of C999CURP option indexbar()
        index on CURINTCOD                                      tag C999CUR2 of C999CURP option indexbar()
        index on CURREVCOD+CURSEMSEQ+CURCOLCOD+CURSUBCOD        tag C999CUR3 of C999CURP option indexbar()
        index on CURSUBCOD                                      tag C999CUR4 of C999CURP option indexbar()
        dbclosearea()
endif

if fask(10,"     Rebuild C999GRAD.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999GRAD",,_DBF_EXCLUSIVE,,}}
        if file("C999GRAD.CDX")
                ferase("C999GRAD.CDX")
        endif
        openwcheck(afiles)
        index on GRDIDNO+GRDTERM       tag C999GRA1 of C999GRAD option indexbar()
        dbclosearea()
endif

if fask(10,"     Rebuild C999OFFR.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"c999OFFR",,_DBF_EXCLUSIVE,,}}
        if file("C999OFFR.CDX")
                ferase("C999OFFR.CDX")
        endif
        openwcheck(afiles)
        index on r_idno+r_term                             tag c999offr1 of c999offr option indexbar()
        index on r_term                                    tag c999offr2 of c999offr option indexbar()
        index on r_code                                    tag c999offr3 of c999offr option indexbar()
        index on r_idno                                    tag c999offr4 of c999offr option indexbar()
        index on r_lname+r_fname+r_mname                   tag c999offr5 of c999offr option indexbar()
        index on r_term+r_code+r_lname+r_fname+r_mname     tag c999offr6 of c999offr option indexbar()
        index on r_code+r_lname+r_fname+r_mname            tag c999offr7 of c999offr option indexbar()
        dbclosearea()
endif

*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999PRSP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999PRSP",,_DBF_EXCLUSIVE,,}}
        if file("C999PRSP.CDX")
                ferase("C999PRSP.CDX")
        endif
        openwcheck(afiles)
        index on PROSYRT+PROSCOLCOD     tag C999PRS1 of C999PRSP option indexbar()
        dbclosearea()
endif

if fask(10,"     Rebuild C999RANK.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"c999RANK",,_DBF_EXCLUSIVE,,}}
        if file("C999RANK.CDX")
                ferase("C999RANK.CDX")
        endif
        openwcheck(afiles)
        index on r_code                 tag c999rank1 of c999rank option indexbar()
        dbclosearea()
endif

if fask(10,"     Rebuild C999RMSK.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"c999rmsk",,_DBF_EXCLUSIVE,,}}
        if file("C999RMSK.CDX")
                ferase("C999RMSK.CDX")
        endif
        openwcheck(afiles)
        index on rmskdno        tag c999rms1 of c999rmsk option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999ROOM.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999ROOM",,_DBF_EXCLUSIVE,,}}
        if file("C999ROOM.CDX")
                ferase("C999ROOM.CDX")
        endif
        openwcheck(afiles)
        index on ROOMNO         tag C999ROM1 of C999ROOM option indexbar()
        index on TYPE+ROOMNO    tag C999ROM2 of C999ROOM option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999RFIL.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999RFIL",,_DBF_EXCLUSIVE,,}}
        if file("C999RFIL.CDX")
                ferase("C999RFIL.CDX")
        endif
        openwcheck(afiles)
        index on TERM+ROOMNO+DAY        tag C999RFI1 of C999RFIL option indexbar()
        index on TERM+DAY+ROOMNO        tag C999RFI2 of C999RFIL option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999SM1P.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999SM1P",,_DBF_EXCLUSIVE,,}}
        if file("C999SM1P.CDX")
                ferase("C999SM1P.CDX")
        endif
        openwcheck(afiles)
        index on SM1IDNO                                 tag C999SM11 of C999SM1P option indexbar()
        index on SM1LSTNAM+SM1FSTNAM+SM1MIDNAM           tag C999SM12 of C999SM1P option indexbar()
        index on SM1COLCOD+STR(SM1YRLEVL,2)              tag C999SM13 of C999SM1P option indexbar()
        index on SM1SCHTRM                               tag C999SM14 of C999SM1P option indexbar()
        dbclosearea()

endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999SM2P.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"C999SM2P",,_DBF_EXCLUSIVE,,}}
        if file("C999SM2P.CDX")
                ferase("C999SM2P.CDX")
        endif
        openwcheck(afiles)
        index on SM2IDNO                        tag C999SM21 of C999SM2P option indexbar()
        index on SM2IDNO+DTOC(SM2BIRDTE)        tag C999SM22 of C999SM2P option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild C999TORP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"c999torp",,_DBF_EXCLUSIVE,,}}
        if file("C999TORP.CDX")
                ferase("C999TORP.CDX")
        endif
        openwcheck(afiles)
        index on toridno+torschtrm+torinst      tag c999tor1 of c999torp option indexbar()
        index on torschtrm+toridno+torinst      tag c999tor2 of c999torp option indexbar()
        index on toridno                        tag c999tor3 of c999torp option indexbar()
        index on torcolcod                      tag c999tor4 of c999torp option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild T999LST.DBF  ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"T999LST",,_DBF_EXCLUSIVE,,}}
        if file("T999LST.CDX")
                ferase("T999LST.CDX")
        endif
        openwcheck(afiles)
        index on TIDNO                  tag T999LST1 of T999LST option indexbar()
        index on TLNAME+TFNAME+TMNAME   tag T999LST2 of T999LST option indexbar()
        dbclosearea()
endif

*-----------------------------------------------------------------------------
if fask(10,"     Rebuild BLOCKLST.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"BLOCKLST",,_DBF_EXCLUSIVE,,}}
        if file("BLOCKLST.CDX")
                ferase("BLOCKLST.CDX")
        endif
        openwcheck(afiles)
        index on BLKIDNO                                tag BLCKLST1 of BLOCKLST option indexbar()
        index on BLKLSTNAM+BLKFSTNAM+BLKMIDNAM          tag BLCKLST2 of BLOCKLST option indexbar()
        index on BLKLSTNAM+BLKFSTNAM+BLKMIDNAM+BLKIDNO  tag BLCKLST3 of BLOCKLST option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild SECTION.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"SECTION",,_DBF_EXCLUSIVE,,}}
        if file("SECTION.CDX")
                ferase("SECTION.CDX")
        endif
        openwcheck(afiles)
        index on SECCODE                                tag SECTION1 of SECTION option indexbar()
        index on SECDESC                                tag SECTION2 of SECTION option indexbar()
        index on SECDESC+SECCODE                        tag SECTION3 of SECTION option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild OLDCURAJ.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"OLDCURAJ",,_DBF_EXCLUSIVE,,}}
        if file("OLDCURAJ.CDX")
                ferase("OLDCURAJ.CDX")
        endif
        openwcheck(afiles)
        index on COURSRCOD                              tag OLDCURA1 of OLDCURAJ option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCMNSM1P.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCMNSM1P",,_DBF_EXCLUSIVE,,}}
        if file("UCMNSM1P.CDX")
                ferase("UCMNSM1P.CDX")
        endif
        openwcheck(afiles)
        index on SM1IDNO   tag UCMNSM11 of UCMNSM1P option indexbar()
        index on SM1LSTNAM+SM1FSTNAM+SM1MIDNAM tag UCMNSM12 of UCMNSM1P option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCMNPRMP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCMNPRMP",,_DBF_EXCLUSIVE,,}}
        if file("UCMNPRMP.CDX")
                ferase("UCMNPRMP.CDX")
        endif
        openwcheck(afiles)
        index on PRMIDNO+PRMSCHTRM   tag UCMNPRM1 of UCMNPRMP option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCMNCRSP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCMNCRSP",,_DBF_EXCLUSIVE,,}}
        if file("UCMNCRSP.CDX")
                ferase("UCMNCRSP.CDX")
        endif
        openwcheck(afiles)
        index on CRSINTCOD           tag UCMNCRS1 of UCMNCRSP option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCLMSM1P.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCLMSM1P",,_DBF_EXCLUSIVE,,}}
        if file("UCLMSM1P.CDX")
                ferase("UCLMSM1P.CDX")
        endif
        openwcheck(afiles)
        index on SM1IDNO   tag UCLMSM11 of UCLMSM1P option indexbar()
        index on SM1LSTNAM+SM1FSTNAM+SM1MIDNAM tag UCMNSM12 of UCLMSM1P option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCLMSM2P.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCLMSM2P",,_DBF_EXCLUSIVE,,}}
        if file("UCLMSM2P.CDX")
                ferase("UCLMSM2P.CDX")
        endif
        openwcheck(afiles)
        index on SM2IDNO   tag UCLMSM21 of UCLMSM2P option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCLMTORP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCLMTORP",,_DBF_EXCLUSIVE,,}}
        if file("UCLMTORP.CDX")
                ferase("UCLMTORP.CDX")
        endif
        openwcheck(afiles)
        index on TORIDNO+TORSCHTRM   tag UCLMTOR1 of UCLMTORP option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild UCLMCRSP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"UCLMCRSP",,_DBF_EXCLUSIVE,,}}
        if file("UCLMCRSP.CDX")
                ferase("UCLMCRSP.CDX")
        endif
        openwcheck(afiles)
        index on CRSINTCOD tag UCLMCRS1 of UCLMCRSP option indexbar()
        dbclosearea()
endif

return(nil) // buildfile1

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------

function buildfile2()
local cterm := space(03),nlastcursor := setcursor(), lconfirm := (_SET_CONFIRM),;
      cyytskdp,cyytenrp,cyytflag,cyytstsp,cyytsecp,afiles,alastscr := savescr(01,00,24,79),;
      ctagname,cyytenrr,cyytappp, cyytmdst
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytENRP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytENRP.DBF   ")
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
                if ! file(alltrim("c"+cterm+"enrp.dbf"))
                        fask(13,"   File C"+cterm+"ENRP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytenrp := "C"+cterm+"ENRP"
                ctagname := "C"+cterm+"ENR"
                afiles   := {{,,cyytenrp,,_DBF_EXCLUSIVE,,}}
                if file(cyytenrp+".CDX")
                        ferase(cyytenrp+".CDX")
                endif
                openwcheck(afiles)
                cdxenrp(cyytenrp,ctagname)
                dbclosearea()
        endif
enddo
restscr(alastscr)
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytENRR.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytENRR.DBF   ")
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
                if ! file(alltrim("c"+cterm+"enrr.dbf"))
                        fask(13,"   File C"+cterm+"ENRR.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytenrr := "c"+cterm+"enrr"
                ctagname := "c"+cterm+"ens"
                afiles   := {{,,cyytenrr,,_DBF_EXCLUSIVE,,}}
                if file(cyytenrr+".CDX")
                        ferase(cyytenrr+".CDX")
                endif
                openwcheck(afiles)
                cdxenrr(cyytenrr,ctagname)
                dbclosearea()
        endif
enddo
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytFLAG.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytFLAG.DBF   ")
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
                if ! file(alltrim("c"+cterm+"flag.dbf"))
                        fask(13,"   File C"+cterm+"FLAG.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytflag := "c"+cterm+"flag"
                ctagname := "c"+cterm+"fla"
                afiles   := {{,,cyytflag,,_DBF_EXCLUSIVE,,}}
                if file(cyytflag+".CDX")
                        ferase(cyytflag+".CDX")
                endif
                openwcheck(afiles)
                cdxflag(cyytflag,ctagname)
                dbclosearea()
        endif
enddo
restscr(alastscr)
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytSECP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytSECP.DBF   ")
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
                if ! file(alltrim("c"+cterm+"secp.dbf"))
                        fask(13,"   File C"+cterm+"SECP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytsecp := "c"+cterm+"secp"
                ctagname := "c"+cterm+"sec"
                afiles   := {{,,cyytsecp,,_DBF_EXCLUSIVE,,}}
                if file(cyytsecp+".CDX")
                        ferase(cyytsecp+".CDX")
                endif
                openwcheck(afiles)
                cdxsecp(cyytsecp,ctagname)
                dbclosearea()
        endif
enddo
restscr(alastscr)
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytSKDP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytSKDP.DBF   ")
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
                if ! file(alltrim("c"+cterm+"skdp.dbf"))
                        fask(13,"   File C"+cterm+"SKDP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytskdp := "c"+cterm+"skdp"
                ctagname := "c"+cterm+"skd"
                afiles   := {{,,cyytskdp,,_DBF_EXCLUSIVE,,}}
                if file(cyytskdp+".CDX")
                        ferase(cyytskdp+".CDX")
                endif
                openwcheck(afiles)
                cdxskdp(cyytskdp,ctagname)
                dbclosearea()
        endif
enddo
restscr(alastscr)
*-----------------------------------------------------------------------------
do while fask(10,"     Rebuild cyytSTSP.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytSTSP.DBF   ")
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
                if ! file(alltrim("c"+cterm+"stsp.dbf"))
                        fask(13,"   File C"+cterm+"STSP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytstsp := "c"+cterm+"stsp"
                ctagname := "c"+cterm+"sts"
                afiles   := {{,,cyytstsp,,_DBF_EXCLUSIVE,,}}
                if file(cyytstsp+".CDX")
                        ferase(cyytstsp+".CDX")
                endif
                openwcheck(afiles)
                cdxstsp(cyytstsp,ctagname)
                dbclosearea()
        endif
enddo
*-----------------------------------------------------------------------------
//--------------------------------------------------------
//        
//--------------------------------------------------------
do while fask(10,"     Rebuild cyytSTSL.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytSTSL.DBF   ")
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
                if ! file(alltrim("c"+cterm+"stsl.dbf"))
                        fask(13,"   File C"+cterm+"STSL.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytstsl := "c"+cterm+"stsl"
                ctagname := "c"+cterm+"sts"
                afiles   := {{,,cyytstsl,,_DBF_EXCLUSIVE,,}}
                if file(cyytstsl+".CDX")
                        ferase(cyytstsl+".CDX")
                endif
                openwcheck(afiles)
                cdxstsl(cyytstsl,ctagname)
                dbclosearea()
        endif
enddo
*-----------------------------------------------------------------------------

do while fask(10,"     Rebuild cyytMDST.DBF ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytMDST.DBF   ")
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
                if ! file(alltrim("c"+cterm+"mdst.dbf"))
                        fask(13,"   File C"+cterm+"MDST.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytmdst := "c"+cterm+"mdst"
                ctagname := "c"+cterm+"mds"
                afiles   := {{,,cyytmdst,,_DBF_EXCLUSIVE,,}}
                if file(cyytmdst+".CDX")
                        ferase(cyytmdst+".CDX")
                endif
                openwcheck(afiles)
                cdxmdst(cyytmdst,ctagname)
                dbclosearea()
        endif
enddo
*-----------------------------------------------------------------------------
if fask(10,"     Rebuild TOR CONTOL File ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"TORCONT",,_DBF_EXCLUSIVE,,}}
        if file("TORCONT.CDX")
                ferase("TORCONT.CDX")
        endif
        openwcheck(afiles)
        index on TORSERIAL tag TORCONT1 of TORCONT option indexbar()
        index on TORIDNO   tag TORCONT2 of TORCONT option indexbar()
        index on TORDATE   tag TORCONT3 of TORCONT option indexbar()
        dbclosearea()
endif

if fask(10,"     Rebuild TOR LOG File ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"TOR_LOG",,_DBF_EXCLUSIVE,,}}
        if file("TOR_LOG.CDX")
                ferase("TOR_LOG.CDX")
        endif
        openwcheck(afiles)
        index on STUDIDNO         tag TOR_LOG1 of TOR_LOG option indexbar()
        index on DATE             tag TOR_LOG2 of TOR_LOG option indexbar()
        index on PREPAREDBY       tag TOR_LOG3 of TOR_LOG option indexbar()
        index on PAYNUM           tag TOR_LOG4 of TOR_LOG option indexbar()
        index on STUDIDNO+SERIAL  tag TOR_LOG5 of TOR_LOG option indexbar()
        dbclosearea()
endif
*-----------------------------------------------------------------------------

/*
if fask(10,"     Rebuild ZIP CODE Database ?     ",{" Yes "," No  "},memvar->colorarray[03]) == 1
        afiles := {{,,"ZIP_PROV",,_DBF_EXCLUSIVE,,}}
        if file("ZIP_PROV.CDX")
                ferase("ZIP_PROV.CDX")
        endif
        openwcheck(afiles)
        index on PROV_ID   tag ZIP_PRO1 of ZIP_PROV option indexbar()
        index on PROV_NAME tag ZIP_PRO2 of ZIP_PROV option indexbar()
        dbclosearea()
        afiles := {{,,"ZIP_AREA",,_DBF_EXCLUSIVE,,}}
        if file("ZIP_AREA.CDX")
                ferase("ZIP_AREA.CDX")
        endif
        openwcheck(afiles)
        index on AREAID                 tag ZIP_ARE1 of ZIP_AREA option indexbar()
        index on AREA_NAME+ZIP_CODE     tag ZIP_ARE2 of ZIP_AREA option indexbar()
        index on ZIP_CODE+AREA_NAME     tag ZIP_ARE3 of ZIP_AREA option indexbar()
        dbclosearea()
endif
*/
*-----------------------------------------------------------------------------
fask(10,"  Rebuilding Indexes Success !  ",{" Ok "},memvar->colorarray[05],.t.,nil)
*-----------------------------------------------------------------------------
restscr(alastscr)
return(nil)
*-----------------------------------------------------------------------------
function cdxenrp(cyytenrp,ctagname)
index on ENRIDNO                        tag (ctagname+"1") of (cyytenrp) option indexbar()
index on ENRCOLCOD+ENRYRLEVL            tag (ctagname+"2") of (cyytenrp) option indexbar()
index on ENRYRLEVL                      tag (ctagname+"3") of (cyytenrp) option indexbar()
index on ENRDTE                         tag (ctagname+"4") of (cyytenrp) option indexbar()
index on ENRCOLCOD+ENRYRLEVL+ENRGRAD    tag (ctagname+"5") of (cyytenrp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxflag(cyytflag,ctagname)
index on ENRIDNO        tag (ctagname+"1") of (cyytflag) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxskdp(cyytskdp,ctagname)
index on SKDCOD                                                 tag (ctagname+"1") of (cyytskdp) option indexbar()
index on SKDSUBCOD+SKDCOD                                       tag (ctagname+"2") of (cyytskdp) option indexbar()
index on SKDSEC                                                 tag (ctagname+"3") of (cyytskdp) option indexbar()
index on SKDCOLCOD+SKDSUBCOD                                    tag (ctagname+"4") of (cyytskdp) option indexbar()
index on STR(SKDBEGTIMX)+STR(SKDENDTIMX)+SKDDAY                 tag (ctagname+"5") of (cyytskdp) option indexbar()
index on SKDINSCOD                                              tag (ctagname+"6") of (cyytskdp) option indexbar()
index on SKDROM+SKDDAY+STR(SKDBEGTIMX)+STR(SKDENDTIMX)+SKDMDN   tag (ctagname+"7") of (cyytskdp) option indexbar()
index on STR(SKDENDTIMX)+STR(SKDBEGTIMX)+SKDDAY                 tag (ctagname+"8") of (cyytskdp) option indexbar()
index on SKDDAY                                                 tag (ctagname+"9") of (cyytskdp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxstsp(cyytstsp,ctagname)
index on STSIDNO                                        tag (ctagname+"1") of (cyytstsp) option indexbar()
index on STSSKDCOD+STSIDNO                              tag (ctagname+"2") of (cyytstsp) option indexbar()
index on STSSKDCOD+STSLSTNAM+STSFSTNAM+STSMIDNAM        tag (ctagname+"3") of (cyytstsp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxstsl(cyytstsl,ctagname)
index on STSIDNO+RECTRAIL                               tag (ctagname+"1") of (cyytstsl) option indexbar()
index on STSSKDCOD+STSLSTNAM+STSFSTNAM+RECTRAIL         tag (ctagname+"2") of (cyytstsl) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxenrr(cyytenrr,ctagname)
index on ENRIDNO+ENRSKDCOD                      tag (ctagname+"1") of (cyytenrr) option indexbar()
index on ENRSKDCOD+ENRLNAME+ENRFNAME+ENRMNAME   tag (ctagname+"2") of (cyytenrr) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxsecp(cyytsecp,ctagname)
index on SECCOLCOD+SECCOD       tag (ctagname+"1") of (cyytsecp) option indexbar()
index on           SECCOD       tag (ctagname+"2") of (cyytsecp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
function cdxmdst(cyytmdst,ctagname)
index on           MEDIDNO      tag (ctagname+"1") of (cyytmdst) option indexbar()
index on MEDLSTNAM+MEDFSTNAM    tag (ctagname+"2") of (cyytmdst) option indexbar()
index on MEDREASON+MEDLSTNAM    tag (ctagname+"3") of (cyytmdst) option indexbar()
return(nil)
*-----------------------------------------------------------------------------

function cdxappp(cyytappp,ctagname)
index on APPIDNO+APPNO          tag (ctagname+"1") of (cyytappp) option indexbar()
index on APPIDNO+APPVESNAME     tag (ctagname+"2") of (cyytappp) option indexbar()
index on APPIDNO                tag (ctagname+"3") of (cyytappp) option indexbar()
return(nil)

*-----------------------------------------------------------------------------
