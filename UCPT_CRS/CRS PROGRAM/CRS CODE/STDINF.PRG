* Program       :  SDTINF.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function stdinf()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup, crefrec, cprocsts,nctr
private cidno,clname,cfname,cmname,csex,cgradas,chomeadd,chomeadd2,ccityadd,nyearlevel,nschterm,;
        ctelno,cnational,cdbirth,cbirthplace,ccstatus,creligion,cprimary,;
        cpriyear,cintermed,cintyear,csecond,csecyear,ccollege,ccolyear,csenhigh,csenhighyear,;
        cmailadd1,cmailadd2,cemail,;
        cguardian,centdata,cmajor,lexist1 := .f., lexist2 := .f.

if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"c999sm2p",,_DBF_SHARED,,1},;
                            {,,"zip_area",,_DBF_SHARED,,3},;
                            {,,"zip_prov",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cidno := space(len(c999sm1p->sm1idno))
boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Student's Directory Entry  ")
commandline("Г          F4 - View Student           Г           ESC - Previous              Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        memvar->clname          := space(len(c999sm1p->sm1lstnam))
        memvar->cfname          := space(len(c999sm1p->sm1fstnam))
        memvar->cmname          := space(len(c999sm1p->sm1midnam))
        memvar->cmidname        := space(len(c999sm1p->sm1midname))
        memvar->csex            := space(len(c999sm1p->sm1sex))
        memvar->cgradas         := c999sm2p->sm2dgradas
        memvar->chomeadd        := space(len(c999sm1p->sm1homadr))
        memvar->chomeadd2       := space(len(c999sm1p->sm1homadr2))
        memvar->ccityadd        := space(len(c999sm2p->sm2citadr))
        memvar->cmailadd1       := space(len(c999sm2p->sm2malad1))
        memvar->cmailadd2       := space(len(c999sm2p->sm2malad2))
        memvar->nyearlevel      := 0
        memvar->nschterm        := 0
        memvar->ctelno          := space(len(c999sm2p->sm2telno))
        memvar->cnational       := space(len(c999sm2p->sm2nat))
        memvar->cdbirth         := ctod("")
        memvar->cbirthplace     := space(len(c999sm2p->sm2birplc))

        memvar->ccstatus        := space(len(c999sm2p->sm2civsts))
        memvar->creligion       := space(len(c999sm2p->sm2rel))
        memvar->cprimary        := space(len(c999sm2p->sm2prisc))
        memvar->cpriyear        := space(len(c999sm2p->sm2priyr))
        memvar->cintermed       := space(len(c999sm2p->sm2intsc))
        memvar->cintyear        := space(len(c999sm2p->sm2intyr))
        memvar->csecond         := space(len(c999sm2p->sm2secsc))
        memvar->csecyear        := space(len(c999sm2p->sm2secyr))

        memvar->csenhigh        := space(len(c999sm2p->sm2sh))
        memvar->csenhighyear    := space(len(c999sm2p->sm2shyr))
        memvar->cemail          := space(len(c999sm2p->sm2email))
        
        memvar->ccollege        := space(len(c999sm2p->sm2colsc))
        memvar->ccolyear        := space(len(c999sm2p->sm2colyr))
        memvar->cguardian       := space(len(c999sm2p->sm2gdn))
        memvar->centdata        := space(len(c999sm2p->sm2entdat))
        memvar->cmajor          := space(len(c999sm1p->sm1colcod))
        clearbuffer()
        setkey(K_F4,{||vstudent({||__keyboard(chr(K_CTRL_LEFT)+c999sm1p->sm1idno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02, 02 say "Students ID # :";
                color memvar->colorarray[02];
                get memvar->cidno       pict "@!" ;
                valid ! empty(memvar->cidno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999sm1p->(dbseek(memvar->cidno))
                fask(10,"  Sorry, ID No. not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if memvar->lexist1 := c999sm1p->(dbseek(memvar->cidno))

                do while ! c999sm1p->(reclock())
                        if inkey() = K_ESC
                                exit
                        endif
                enddo

                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midnam          //middle initial
                memvar->cmidname        := if(!empty(c999sm1p->sm1midname),c999sm1p->sm1midname,;
                                           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."+space(18),space(20)))         //full middle name
                memvar->csex            := c999sm1p->sm1sex
                memvar->chomeadd        := c999sm1p->sm1homadr
                memvar->chomeadd2       := c999sm1p->sm1homadr2
                memvar->nyearlevel      := c999sm1p->sm1yrlevl
                memvar->cmajor          := c999sm1p->sm1colcod
                memvar->nschterm        := c999sm1p->sm1schtrm
        endif
        if memvar->lexist2 := c999sm2p->(dbseek(memvar->cidno))
                if ! c999sm2p->(reclock())
                        loop
                endif
                memvar->cgradas         := c999sm2p->sm2dgradas
                memvar->ccityadd        := c999sm2p->sm2citadr
                memvar->cmailadd1       := c999sm2p->sm2malad1
                memvar->cmailadd2       := c999sm2p->sm2malad2
                memvar->ctelno          := c999sm2p->sm2telno
                memvar->cnational       := c999sm2p->sm2nat
                memvar->cdbirth         := c999sm2p->sm2birdte
                memvar->cbirthplace     := c999sm2p->sm2birplc
                memvar->ccstatus        := c999sm2p->sm2civsts
                memvar->creligion       := c999sm2p->sm2rel
                memvar->cprimary        := c999sm2p->sm2prisc
                memvar->cpriyear        := c999sm2p->sm2priyr
                memvar->cintermed       := c999sm2p->sm2intsc
                memvar->cintyear        := c999sm2p->sm2intyr
                memvar->csecond         := c999sm2p->sm2secsc
                memvar->csecyear        := c999sm2p->sm2secyr
                memvar->csenhigh        := c999sm2p->sm2sh
                memvar->csenhighyear    := c999sm2p->sm2shyr
                memvar->ccollege        := c999sm2p->sm2colsc
                memvar->ccolyear        := c999sm2p->sm2colyr
                memvar->cguardian       := c999sm2p->sm2gdn
                memvar->centdata        := c999sm2p->sm2entdat
                memvar->cemail          := c999sm2p->sm2email

        endif
        do while .t.
                commandline("Г    F4 - View Zip Code   Г     F10 - Record        Г      ESC - Previous      Г")
                setkey(K_F10,{||savedata()})
                setkey(K_F4,{||if(readvar()=="MEMVAR->CMAILADD2",vzipcode(space(4),cprocsts,memvar->colorarray[10]),)})

                nctr := 02
                setcursor(1);set(_SET_CONFIRM,.t.)
                @     02, 38 say "Date Grad (AS):";
                        color memvar->colorarray[02];
                        get memvar->cgradas     pict "@!"
                @ ++nctr, 02 say "Last Name     :";
                        color memvar->colorarray[02];
                        get memvar->clname      pict "@!"
                @ ++nctr, 02 say "First Name    :";
                        color memvar->colorarray[02];
                        get memvar->cfname      pict "@!"
                @ ++nctr, 02 say "Middle Name   :";
                        color memvar->colorarray[02];
                        get memvar->cmidname    pict "@!"

                @   nctr, 37 say "  Email       :";
                        color memvar->colorarray[02];
                        get memvar->cemail   pict "@!"

                @ ++nctr, 02 say "                  [M,F]";
                        color memvar->colorarray[02]
                @   nctr, 02 say "Sex           :";
                        color memvar->colorarray[02];
                        get memvar->csex        pict "@!";
                        valid memvar->csex $ "MF"

                                
                @   nctr, 38 say "Nationality   :";
                        color memvar->colorarray[02];
                        get memvar->cnational   pict "@!"
                @ ++nctr, 02 say "School Term   :";
                        color memvar->colorarray[02];
                        get memvar->nschterm    pict "9999"

                @   nctr, 38 say "Date of Birth :";
                        color memvar->colorarray[02];
                        get memvar->cdbirth
                @ ++nctr, 02 say "Course/Major  :";
                        color memvar->colorarray[02];
                        get memvar->cmajor      pict "@!";
                        valid ! empty(memvar->cmajor)

                @   nctr, 38 say "Place of Birth:";
                        color memvar->colorarray[02];
                        get memvar->cbirthplace pict "@S20"
                @ ++nctr, 02 say "                  [1,2,3,4,5]";
                        color memvar->colorarray[02]
                @   nctr, 02 say "Year Level    :";
                        color memvar->colorarray[02];
                        get memvar->nyearlevel  pict "9";
                        valid memvar->nyearlevel > 0 .and. memvar->nyearlevel < 6

                @   nctr, 38 say "                  [S,M,W]";
                        color memvar->colorarray[02]

                @   nctr, 38 say "Civil Status  :";
                        color memvar->colorarray[02];
                        get memvar->ccstatus    pict "@!";
                        valid memvar->ccstatus $ "SMW"
                @ ++nctr, 02 say "Telephone No. :";
                        color memvar->colorarray[02];
                        get memvar->ctelno      pict "@!"

                @   nctr, 38 say "Religion      :";
                        color memvar->colorarray[02];
                        get memvar->creligion   pict "@!"
               
                @ ++nctr, 02 say "City Address  :";
                        color memvar->colorarray[02];
                        get memvar->ccityadd    pict "@!"

                @ ++nctr, 02 say "Home Address  :";
                        color memvar->colorarray[02];
                        get memvar->chomeadd    pict "@!"
                @ ++nctr, 02 say "Address Cont..:";
                        color memvar->colorarray[02];
                        get memvar->chomeadd2   pict "@!"
                @ ++nctr, 02 say "------------------------ Mailing Address for Grades ------------------------";
                        color memvar->colorarray[02]
                @ ++nctr, 02 say "House #/Street/Barangay :";
                        color memvar->colorarray[02];
                        get memvar->cmailadd1   pict "@!"      // first line
                @ ++nctr, 02 say "ZipCode/City/Muncipality:";
                        color memvar->colorarray[02];
                        get memvar->cmailadd2   pict "@!"      // second line
                @ ++nctr, 02 say "Primary School      :";
                        color memvar->colorarray[02];
                        get memvar->cprimary    pict "@S30"
                @   nctr, 57 say "Year Attended:";
                        color memvar->colorarray[02];
                        get memvar->cpriyear    pict "@!"
                @ ++nctr, 02 say "Intermediate School :";
                        color memvar->colorarray[02];
                        get memvar->cintermed   pict "@S30"
                @   nctr, 57 say "Year Attended:";
                        color memvar->colorarray[02];
                        get memvar->cintyear    pict "@!"
                @ ++nctr, 02 say "Secondary School    :";
                        color memvar->colorarray[02];
                        get memvar->csecond     pict "@S30"
                @   nctr, 57 say "Year Attended:";
                        color memvar->colorarray[02];
                        get memvar->csecyear    pict "@!"
                @ ++nctr, 02 say "SeniorHigh School   :"; 
                        color memvar->colorarray[02];
                        get memvar->csenhigh   pict "@S30"
                @   nctr, 57 say "Year Attended:";
                        color memvar->colorarray[02];
                        get memvar->csenhighyear pict "@!"
                @ ++nctr, 02 say "College School      :";
                        color memvar->colorarray[02];
                        get memvar->ccollege    pict "@S30"
                @   nctr, 57 say "Year Attended:";
                        color memvar->colorarray[02];
                        get memvar->ccolyear    pict "@!"
                @ ++nctr, 02 say "Guardian            :";
                        color memvar->colorarray[02];
                        get memvar->cguardian    pict "@!"
                @ ++nctr, 02 say "Entrance Data       :";
                        color memvar->colorarray[02];
                        get memvar->centdata     pict "@!"
                read
                if lastkey() == K_ESC
                        exit
                endif
        enddo
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        setkey(K_F10,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)


function savedata()
if fask(13,"  Are you sure to save this record ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        ** record c999sm1p **
        if ! memvar->lexist1
                if ! c999sm1p->(recycle())
                        __keyboard(chr(K_ESC))
                endif
        endif
        c999sm1p->sm1idno       := memvar->cidno
        c999sm1p->sm1lstnam     := memvar->clname
        c999sm1p->sm1fstnam     := memvar->cfname
        c999sm1p->sm1midname    := memvar->cmidname
        c999sm1p->sm1midnam     := left(memvar->cmidname,1)
        c999sm1p->sm1sex        := memvar->csex
        c999sm1p->sm1homadr     := memvar->chomeadd
        c999sm1p->sm1homadr2    := memvar->chomeadd2
        c999sm1p->sm1schtrm     := memvar->nschterm
        c999sm1p->sm1colcod     := memvar->cmajor
        c999sm1p->sm1yrlevl     := memvar->nyearlevel
        c999sm1p->sm1yrlevl     := memvar->nyearlevel
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())

        ** record c999sm2p **
        if ! memvar->lexist2
                if ! c999sm2p->(recycle())
                        __keyboard(chr(K_ESC))
                endif
        endif
        c999sm2p->sm2idno       := memvar->cidno
        c999sm2p->sm2dgradas    := memvar->cgradas
        c999sm2p->sm2citadr     := memvar->ccityadd
        c999sm2p->sm2malad1     := memvar->cmailadd1
        c999sm2p->sm2malad2     := memvar->cmailadd2
        c999sm2p->sm2telno      := memvar->ctelno
        c999sm2p->sm2prisc      := memvar->cprimary
        c999sm2p->sm2priyr      := memvar->cpriyear
        c999sm2p->sm2intsc      := memvar->cintermed
        c999sm2p->sm2intyr      := memvar->cintyear
        c999sm2p->sm2secsc      := memvar->csecond
        c999sm2p->sm2secyr      := memvar->csecyear
        
        c999sm2p->sm2sh         := memvar->csenhigh
        c999sm2P->sm2shyr        := memvar->csenhighyear
        c999sm2p->sm2colsc      := memvar->ccollege
        c999sm2p->sm2colyr      := memvar->ccolyear
        c999sm2p->sm2nat        := memvar->cnational
        c999sm2p->sm2civsts     := memvar->ccstatus
        c999sm2p->sm2rel        := memvar->creligion
        c999sm2p->sm2gdn        := memvar->cguardian
        c999sm2p->sm2birdte     := memvar->cdbirth
        c999sm2p->sm2birplc     := memvar->cbirthplace
        c999sm2p->sm2entdat     := memvar->centdata
        c999sm2p->sm2email      := memvar->cemail
        c999sm2p->(dbcommit())
        c999sm2p->(dbunlock())

        __keyboard(chr(K_ESC))
endif
return(nil)
