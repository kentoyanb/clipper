* Program       :  INSTREP.PRG
* Author        :  Jun Benlot and Randy F. Santizo (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function classlist()
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
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Printing  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
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
        cyytenrp  := alltrim("c"+cterm+"enrp")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cedpcode := space(len(cyytskdp->skdcod))
        do while .t.
                restscr(aentryscr)
                commandline("Г           F4 - View Schedule         Г           ESC - Previous              Г")
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
 //               cskd := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
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
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+cinscode+" - "+cinsname})
aadd(abtext,{||"Schedule  : "+cedpcode+"  - "+cskd})
aadd(abtext,{||"          : "+csubject})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name        First Name      M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------- - ------ -- ----------"})

/*
Instructor: 123456 - 123456789012345678901234567890
Schedule  : 12345  - 1234567901534564
          : 123134313313131313131

      ID No.     Last Name        First Name       M Course Yr  Remarks
     -------- --------------- -------------------  - ------ -- ----------
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
   if prow() == 60
        outexpr(prow()+01,0,"UC-METC/REG.Doc/007/Rev.01")
   endif
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        cyytenrp->(dbseek(cyytenrr->enridno))
        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                             cyytenrr->enridno+space(01)+;
                             c999sm1p->sm1lstnam+;
                             c999sm1p->sm1fstnam+;
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

function loaducmain()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp,;
      bprint, cprocsts, cterm := space(03),cdesc,ccode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Instructors Load Printing for UC-Main  ")
        @ 03,01 say replicate("Ф",78)
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,25 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup := openwcheck({{,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        ccode := space(len(t999lst->tidno))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Instructor         Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode       pict "@!";
                        valid ! empty(ccode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode))
                        fask(10,"   Instructor code "+ccode+" is not existing.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||ploaducmain(cdesc,ccode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function ploaducmain(cdesc,ccode)
local abtext := {},ncol,nmaxcol := 80, npage := 0,nctr := 0,;
      nlechrs := 0,nlabhrs := 0,ntunits := 0
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
//aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||space(0)+"Date: "+displaydate(date())+space(ncol-18)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||space(0)+"Time: "+Time()+space(titlepos("Maritime Education And Training Center",nmaxcol)-14)+;
                                              "Maritime Education And Training Center"})
aadd(abtext,{||space(titlepos(space(0)+"Alumnos, Mambaling, Cebu City",nmaxcol))+;
                              space(0)+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(space(0)+"TEACHERS LOAD REPORT",nmaxcol))+;
                              space(0)+"TEACHERS LOAD REPORT"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})

pageprint(abtext)
header()
cyytskdp->(dbsetrelation("c999crsp",{||cyytskdp->skdintcod},"cyytskdp->skdintcod"))
cyytskdp->(dbsetrelation("c999colp",{||cyytskdp->skdcolcod},"cyytskdp->skdcolcod"))
cyytskdp->(sx_setscope(_TOP_SCOPE   ,ccode))
cyytskdp->(sx_setscope(_BOTTOM_SCOPE,ccode))
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())

//edited for IMEC instructors only        if cyytskdp->skdcolcod == "YN" .or. cyytskdp->skdcolcod == "YM"
        fask(10,"   Printing subject "+alltrim(cyytskdp->skdsubcod)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ++nctr > 13
                footer(nlechrs,nlabhrs,ntunits)
                __eject()
                pageprint(abtext)
                header()
                nctr := 0
        endif
        if ! ((cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp=="LEC") .or. (cyytskdp->skdsplcod == "S" .and. cyytskdp->skdsubtyp=="LAB"))

                outexpr(prow()+01,00,cyytskdp->skdcod+space(02)+;
                                     cyytskdp->skdsubcod+space(01)+;
                                     if(cyytskdp->skdsubtyp == "LAB","L"," ")+space(02)+;
                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(02)+;
                                     cyytskdp->skdday+space(02)+;
                                     cyytskdp->skdrom+space(02)+;
                                     c999colp->coldesabr+space(02)+;
                                     transform(cyytskdp->skdactsiz,"9999")+space(02)+;
                                     transform(c999crsp->crslechrs,"9.99")+space(03)+;
                                     transform(c999crsp->crslabhrs,"9.99")+space(02)+;
                                     transform(cyytskdp->skdunt,"999.9"))
                nlechrs += c999crsp->crslechrs
                nlabhrs += c999crsp->crslabhrs
                ntunits += cyytskdp->skdunt
        else
                outexpr(prow()+01,00,cyytskdp->skdcod+space(02)+;
                                     cyytskdp->skdsubcod+space(01)+;
                                     if(cyytskdp->skdsubtyp == "LAB","L"," ")+space(02)+;
                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(02)+;
                                     cyytskdp->skdday+space(02)+;
                                     cyytskdp->skdrom+space(02)+;
                                     c999colp->coldesabr+space(02)+;
                                     transform(cyytskdp->skdactsiz,"9999")+space(02)+;
                                     "----"+space(03)+;
                                     "----"+space(02)+;
                                     "-----")
        endif
//edited for IMEC instructors only        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
cyytskdp->(clearscope())
cyytskdp->(dbclearrelation())
footer(nlechrs,nlabhrs,ntunits)
__eject()
return(nil)


static function header(npage,cdesc)
outexpr(09,00,"ID NO:________  NAME:___________________________________________________________")
outexpr(09,07,t999lst->tidno)
outexpr(09,23,t999lst->tlname+", "+t999lst->tfname+ " "+t999lst->tmname+if(!empty(t999lst->tmname),"."," "))
outexpr(10,00,"DEGREE:__________________   MAJOR:__________________   MINOR:___________________")
outexpr(11,00,"________________________________________________________________________________")
outexpr(12,00,"For University use only:  Do not fill up")
outexpr(13,00,"STATUS: _____Full Time (Tenured)   _____Full Time (Non-Tenured)   _____Part Time")
outexpr(15,00,"RANK:___________________________   SCHOOL YEAR STARTED IN UC:___________________")
outexpr(16,00,"Teaching Experience in (UC):______________   Full-Time_______   Part-Time_______")
outexpr(17,00,"================================================================================")
outexpr(19,00,"                                                               NO OF HRS        ")
outexpr(20,00,"SKD #     SUBJECT         TIME      DAYS  ROOM   DEPT   SIZE   LEC   LAB   UNITS")
outexpr(21,00,"-----  --------------  -----------  ----  ----  ------  ----  -----------  -----")
return(nil)

static function footer(nlechrs,nlabhrs,ntunits)
outexpr(36,43,"TOTAL . . . . .  "+transform(nlechrs,"999.99")+space(02)+transform(nlabhrs,"999.99")+space(02)+transform(ntunits,"999.9"))
outexpr(38,43,"NUMBER OF LOADS . . . . __________")
outexpr(40,00,"Are you working in another company, agency, establishments or office?")
outexpr(41,00,"If yes give the name:________________________________________________________")
outexpr(42,00,"Are you teaching in other schools?____(Yes) ____(No), If yes, In what")
outexpr(43,00,"college or university?_______________________________________________________")
outexpr(44,00,"Number of subjects handled? __________ Number of Units? _____________________")

outexpr(46,00,"NOTE: You are hereby reminded of your contractual obligation to submit the midterm")
outexpr(47,00," and final grades on or before the deadline set for submission thereof. UC")
outexpr(48,00," management reserves the right to strictly impose the University's standing policy")
outexpr(49,00," on the imposition of sanctions for late submission of grades in the form of ")
outexpr(50,00," liquidated damages computed at FIFTY PESOS(P50) per subject per  day of delay to")
outexpr(51,00," be automatically deducted from your salary, and other imposable sanctions under ")
outexpr(52,00," the University Manual.")



outexpr(53,52,"_______________________")
outexpr(54,00,"Attested:")
outexpr(54,52,"  Teacher's Signature  ")
//outexpr(50,00,"Attested:")
outexpr(56,00,"_________________________________________           APPROVED:")
//outexpr(56,00,"    Academic Coordinator    ")
outexpr(57,00,"         Dean and Chairperson ")
//outexpr(55,00," Maritime Supt. / Asst. Maritime Supt. / ")
//outexpr(56,00,"          Gen. Ed. Coordinator  ")
//outexpr(57,57,"                       ")
outexpr(58,52,"____________________________")
//outexpr(59,57,"       METC Team   ")
//outexpr(58,52," VP-Personnel/Administrator")
outexpr(59,52,"       Campus Director ")

/*
outexpr(49,52,"_______________________")
outexpr(50,00,"Attested:")
outexpr(50,52,"  Teacher's Signature  ")
//outexpr(50,00,"Attested:")
outexpr(54,00,"_________________________________________           APPROVED:")
//outexpr(56,00,"    Academic Coordinator    ")
outexpr(55,00,"         Dean and Chairperson ")
//outexpr(55,00," Maritime Supt. / Asst. Maritime Supt. / ")
//outexpr(56,00,"          Gen. Ed. Coordinator  ")
//outexpr(57,57,"                       ")
outexpr(57,52,"____________________________")
//outexpr(59,57,"       METC Team   ")
//outexpr(58,52," VP-Personnel/Administrator")
outexpr(58,52,"       Campus Director ")*/
return(nil)

*-------------------------------------------------------------------------------
function instload()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp,;
      bprint, cprocsts, cterm := space(03),cdesc,ccode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Instructors Load Printing  ")
        @ 03,01 say replicate("Ф",78)
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,25 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup := openwcheck({{,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        *ccode := space(len(t999lst->tidno))
        ccode := "ALL   "
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Instructor         Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode       pict "@!";
                        valid ! empty(ccode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(ccode) == "ALL" .and. ! t999lst->(dbseek(ccode))
                        fask(10,"   Instructor code "+alltrim(ccode)+" is not existing.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pload(cdesc,ccode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pload(cdesc,ccode)
local abtext := {},ncol,nmaxcol := 80, npage := 0,nctr := 0,;
      nlec := 0,nlab := 0,ntunits := 0,ntloads := 0, lprint := .f.
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education And Training Center",nmaxcol)-14)+;
                                              "Maritime Education And Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+;
                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("TEACHERS LOAD REPORT",nmaxcol))+;
                              "TEACHERS LOAD REPORT"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"NUMBER : "+t999lst->tidno})
aadd(abtext,{||"NAME   : "+alltrim(t999lst->tlname)+" ,  "+alltrim(t999lst->tfname)+"  "+t999lst->tmname+"."})
aadd(abtext,{||""})
aadd(abtext,{||"REC#  SKD#     SUBJECT     TYP       TIME       DAYS  ROOM  UNIT  SPLCD  STUD"})
//aadd(abtext,{||"REC#  SKD#     SUBJECT     TYP       TIME       DAYS  DEPT     UNIT  SPLCD  STUD"})
aadd(abtext,{||"----  -----  ------------  ---  --------------  ----  ----  ----  -----  ----"})

/*
REC#  SKD#     SUBJECT     TYP       TIME       DAYS  ROOM  UNIT  SPLCD  STUD
----  -----  ------------  ---  --------------  ----  ----  ----  -----  ----
123.  12345  123456789012  123  12345-12345 12  1234  1234  12.1  12345  1234
----------------------------
TOTAL LECTURES     =>  123
TOTAL LABORATORIES =>  123
TOTAL LOADS        =>  123
TOTAL UNITS        =>  123.1
                                                                          
This serves as teachers guide for his/her load.    <<UC-METC-EDP/ACCOUNTING>>
*/

if alltrim(ccode) == "ALL"
        t999lst->(sx_settagorder(2))
else
        t999lst->(sx_setscope(_TOP_SCOPE   ,ccode))
        t999lst->(sx_setscope(_BOTTOM_SCOPE,ccode))
endif

*pageprint(abtext)
t999lst->(dbgotop())
do while ! t999lst->(eof())
        fask(10,"  Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        nctr := nlec := nlab := ntloads := ntunits := npage := 0
        if ! alltrim(t999lst->tidno) == "0" .and. ! alltrim(t999lst->tidno) == "ROTC"
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        fask(16,"   Printing subject "+alltrim(cyytskdp->skdsubcod)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                  abtext, prow() + 1, 50, {||__eject()})
                        //if !(cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC")
                                outexpr(prow()+01,00,transform(++nctr,"999")+"."+space(02)+;
                                                     cyytskdp->skdcod+space(02)+;
                                                     cyytskdp->skdsubcod+space(02)+;
                                                     cyytskdp->skdsubtyp+space(02)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(02)+;
                                                     cyytskdp->skdday+space(02)+;
                                                     cyytskdp->skdrom+space(02)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(02)+;
                                                     cyytskdp->skdsplskd+space(02)+;
                                                     transform(cyytskdp->skdactsiz,"9999"))

                                if cyytskdp->skdsubtyp == "LEC" .and. cyytskdp->skdsplcod $ "S "
                                        ++nlec
                                        ++ntloads
                                        ntunits += cyytskdp->skdunt
                                elseif cyytskdp->skdsubtyp == "LAB" .and. cyytskdp->skdsplcod $ "C "
                                        ++nlab
                                        ++ntloads
                                        ntunits += cyytskdp->skdunt
                                endif
                                lprint := .t.
                        //endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                enddo

                cyytskdp->(clearscope())
                if lprint
                        outexpr(prow()+01,00,"----------------------------")
                        outexpr(prow()+01,00,"TOTAL LECTURES     =>  "+transform(nlec,"999"))
                        outexpr(prow()+01,00,"TOTAL LABORATORIES =>  "+transform(nlab,"999"))
                        outexpr(prow()+01,00,"TOTAL LOADS        =>  "+transform(ntloads,"999"))
                        outexpr(prow()+01,00,"TOTAL UNITS        =>  "+transform(ntunits,"999.9"))
                        outexpr(prow()+01,00,replicate("",77))
                        outexpr(prow()+01,00,"This serves as teachers guide for his/her load.    <<UC-METC-EDP/ACCOUNTING>>")
                        outexpr(prow()+01,00,"")
                        outexpr(prow()+01,00,"NOTE: You are hereby reminded of your contractual obligation to submit the midterm ") 
                        outexpr(prow()+01,00," and final grades on or before the deadline set for submission thereof. UC management")
                        outexpr(prow()+01,00," reserves the right to strictly impose the University's standing policy on the")
                        outexpr(prow()+01,00," imposition of sanctions for late submission of grades in the form of liquidated")
                        outexpr(prow()+01,00," damages computed at FIFTY PESOS(P50) per subject per day of delay to be automatically")
                        outexpr(prow()+01,00," deducted from your salary, and other imposable sanctions under the University Manual.")
                        
                        __eject()
                        lprint := .f.
                endif
        endif
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(clearscope())
t999lst->(sx_settagorder(1))
return(nil)

*-------------------------------------------------------------------------------

function cllistbyinst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), cdesc,;
      ccode,lprint:=.f.

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Report by Instructor  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
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
        cdesc := term->name
        @ 02,24 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        ccode := "ALL   " &&space(len(t999lst->tidno))
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View Instructor        Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor(space(len(t999lst->tidno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode    pict "@!";
                        valid ! empty(ccode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode)) .and. ! alltrim(ccode) == "ALL"
                        fask(10,"   Instructor Code "+alltrim(ccode)+" not registered.   ",{" Ok "},memvar->colorarrayu[05],.t.,nil)
                        loop
                endif
                if ! ccode == "ALL   "
                        @ 04,27 say "- "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+" "+alltrim(t999lst->tlname)
                endif
                if alltrim(ccode) == "0"
                        if whereprint({||pdisbyinst(ccode,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||pcllistbyinst(ccode,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pcllistbyinst(ccode,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

if ! ccode == "ALL   "
        t999lst->(sx_setscope(_TOP_SCOPE   ,ccode))
        t999lst->(sx_setscope(_BOTTOM_SCOPE,ccode))
else
        t999lst->(sx_settagorder(2))
endif
t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" &&Disolved
                fask(10,"   Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        lprint := .f.
                        *fask(16,"   Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        /* if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC")) */
                        if ! cyytskdp->skdsplcod == "C"
                                cecode := cyytskdp->skdcod
                                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cesubj := alltrim(c999crsp->crsdsc1)
                                if cyytskdp->skdsplcod == "S"
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        ccecode := cyytskdp->skdcod
                                        cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                        cyytskdp->(sx_settagorder(6))
                                        cyytskdp->(dbgoto(nrecno))
                                else
                                        ccecode := " "
                                        cceskd  := " "
                                endif
                                lprint := .t.
                                nctr := npage := 0
                                ccode := t999lst->tidno
                                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                                pageprint(abtext)
                                cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                                cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                                cyytenrr->(dbgotop())
                                do while ! cyytenrr->(eof())
                                        fask(16,"   Printing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                                lprint := .f.
                                        endif
                                        c999colp->(dbseek(cyytenrr->enrcolcod))
                                        c999sm1p->(dbseek(cyytenrr->enridno))
                                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                                             cyytenrr->enridno+space(01)+;
                                                             c999sm1p->sm1lstnam+space(01)+;
                                                             c999sm1p->sm1fstnam+space(01)+;
                                                             c999sm1p->sm1midnam+space(01)+;
                                                             c999colp->coldesabr+space(02)+;
                                                             cyytenrr->enryrlevl+space(01)+;
                                                             "__________")
                                        if ! empty(cyytenrr->enrrem)
                                                outexpr(prow()+00,67,cyytenrr->enrrem)
                                        endif
                                        lprint := .t.
                                        if nextkey() == K_ESC
                                                exit
                                        endif
                                        cyytenrr->(dbskip())
                                enddo
                                cyytenrr->(clearscope())
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                        if lprint
                                outexpr(prow()+00,00,chr(18))
                                __eject()
                        endif
                enddo
                cyytskdp->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
t999lst->(clearscope())
return(nil)

static function pdisbyinst(ccode,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

cyytskdp->(sx_setscope(_TOP_SCOPE   ,ccode))
cyytskdp->(sx_setscope(_BOTTOM_SCOPE,ccode))
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        lprint := .f.
        fask(10,"   Processing inscode "+ccode+" skdcode "+cyytskdp->skdcod+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC"))
                cecode := cyytskdp->skdcod
                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                c999crsp->(dbseek(cyytskdp->skdintcod))
                cesubj := alltrim(c999crsp->crsdsc1)
                if cyytskdp->skdsplcod == "S"
                        nrecno:=cyytskdp->(recno())
                        cyytskdp->(sx_settagorder(1))
                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                        if ! cyytskdp->skdsubtyp == "LAB"
                                ccecode := cyytskdp->skdcod
                                cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                ccont   := "C"
                        endif
                        cyytskdp->(sx_settagorder(6))
                        cyytskdp->(dbgoto(nrecno))
                endif
                lprint := .t.
                nctr := npage := 0
                ccode := t999lst->tidno
                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                pageprint(abtext)
                cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                cyytenrr->(dbgotop())
                do while ! cyytenrr->(eof())
                        fask(10,"   Printing inscode "+t999lst->tidno+" name "+alltrim(cyytenrr->enrlname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999colp->(dbseek(cyytenrr->enrcolcod))
                        c999sm1p->(dbseek(cyytenrr->enridno))
                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             c999sm1p->sm1lstnam+space(01)+;
                                             c999sm1p->sm1fstnam+space(01)+;
                                             c999sm1p->sm1midnam+space(01)+;
                                             c999colp->coldesabr+space(02)+;
                                             cyytenrr->enryrlevl+space(01)+;
                                             "__________")
                        if ! empty(cyytenrr->enrrem)
                                outexpr(prow()+00,67,cyytenrr->enrrem)
                        endif
                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                lprint := .f.
                        else
                                lprint := .t.
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytenrr->(dbskip())
                enddo
                cyytenrr->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
        if lprint
                outexpr(prow()+00,00,chr(18))
                __eject()
        endif
enddo
cyytskdp->(clearscope())
return(nil)

*-------------------------------------------------------------------------------

function instsubject()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp,;
      ctermcode := space(03), ctermdesc := space(30),cpapersize := "S"

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Instructors List of Subject  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get ctermcode pict "@!";
                valid ! empty(ctermcode)
        @ 04,02 say "                 [S-hort, L-ong]" color memvar->colorarray[02]
        @ 04,02 say "Paper Size  :";
                color memvar->colorarray[02];
                get cpapersize pict "@!";
                valid cpapersize $ "SL"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
if ! term->(dbseek(ctermcode))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+ctermcode+"skdp.dbf"))
                fask(10,"  C"+ctermcode+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ctermdesc := term->name
        @ 02,20 say "- "+term->name
        cyytskdp := "c"+ctermcode+"skdp"
        if(aprv2setup := openwcheck({{,,"t999lst" ,,_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        if whereprint({||pinstsubject(ctermdesc,cpapersize)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

function pinstsubject(ctermdesc,cpapersize)
local abtext:={},ncol,nmaxcol:=80,npage:=0,cinstcode:=space(06),cinsname:=space(18),;
      lprint := .f.
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("TEACHERS LOAD REPORT",nmaxcol)-14)+"TEACHERS LOAD REPORT"})
aadd(abtext,{||space(titlepos("( LIST OF SUBJECT )",nmaxcol))+"( LIST OF SUBJECTS )"})
aadd(abtext,{||space(titlepos(alltrim(ctermdesc),nmaxcol))+alltrim(ctermdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                                                    RECEIVED (GRADE SHEETS)     "})
aadd(abtext,{||"I-CODE   INSTRUCTOR(S)    ECODE    SUBJECTS        MID_TERM          FINALS     "})
aadd(abtext,{||"------ ------------------ ----- -------------- ---------------- ----------------"})

/*
                                                    RECEIVED (GRADE SHEETS)
I-CODE   INSTRUCTOR(S)    ECODE    SUBJECTS        MID_TERM          FINALS
------ ------------------ ----- -------------- ---------------- ----------------
123456 123456789012345 1. 12345 123456789012 1 ________________ ________________
*/

pageprint(abtext)
t999lst->(dbgotop())
do while ! t999lst->(eof())
        fask(09,"  Processing name "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! alltrim(t999lst->tidno) == "0"
                cinstcode := t999lst->tidno
                cinstname := t999lst->tlname+" "+substr(t999lst->tfname,1,1)+"."
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        lprint := .t.
                        fask(15,"  Printing subjects "+cyytskdp->skdcod+" "+cyytskdp->skdsubcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
//                        if prow() > 70
//                              __eject()
//                                pageprint(abtext)
//                                cinstcode := t999lst->tidno
//                                cinstname := t999lst->tlname+" "+substr(t999lst->tfname,1,1)+"."
//                        endif
                        if cpapersize == "L"
                                if prow() > 70
                                      __eject()
                                        pageprint(abtext)
                                        cinstcode := t999lst->tidno
                                        cinstname := t999lst->tlname+" "+substr(t999lst->tfname,1,1)+"."
                                endif
                        elseif cpapersize == "S"
                                if prow() > _MAX_LINE
                                      __eject()
                                        pageprint(abtext)
                                        cinstcode := t999lst->tidno
                                        cinstname := t999lst->tlname+" "+substr(t999lst->tfname,1,1)+"."
                                endif
                        endif


                        @ prow()+01,00 say cinstcode+" "+;
                                           cinstname+" "+;
                                           cyytskdp->skdcod+" "+;
                                           cyytskdp->skdsubcod+" "+;
                                           if(cyytskdp->skdsubtyp == "LAB","L"," ")+" "+;
                                           "________________"+" "+;
                                           "________________"
                        cinstcode := space(06)
                        cinstname := space(18)
                        cyytskdp->(dbskip())
                enddo
        endif
        clearbuffer()
        cyytskdp->(clearscope())
        t999lst->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
        if .not. t999lst->(eof()) .and. lprint
                @ prow()+01,00 say " "
                lprint := .f.
        endif
enddo
__eject()
return(nil)

*------------------------------------------------------------------------------*

function classteacherprog()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp,;
      ctermcode := space(03), ctermdesc := space(30), cpapersize := "S"

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class and Teacher's Program Report  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get ctermcode pict "@!";
                valid ! empty(ctermcode)
        @ 04,02 say "                 [S-hort, L-ong]" color memvar->colorarray[02]
        @ 04,02 say "Paper Size  :";
                color memvar->colorarray[02];
                get cpapersize pict "@!";
                valid cpapersize $ "SL"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(ctermcode))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+ctermcode+"skdp.dbf"))
                fask(10,"  C"+ctermcode+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ctermdesc := term->name
        @ 02,20 say "- "+term->name
        cyytskdp := "c"+ctermcode+"skdp"
        if(aprv2setup := openwcheck({{,,"t999lst" ,,_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        if whereprint({||pclassteacherprog(ctermdesc,cpapersize)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

function pclassteacherprog(ctermdesc,cpapersize)
local abtext:={},ncol,nmaxcol:=75,npage:=0,cinstcode:=space(06),cinsname:=space(18),;
      lprint := .f.,nctr := 0,lfirst := .t.,nline := 0,cdot := " "
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos Mambaling, Cebu City",nmaxcol))+"Alumnos Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CLASS AND TEACHER'S PROGRAM",nmaxcol))+"CLASS AND TEACHER'S PROGRAM"})
aadd(abtext,{||space(titlepos(alltrim(ctermdesc),nmaxcol))+alltrim(ctermdesc)})
aadd(abtext,{||""})
//aadd(abtext,{||"               INSTRUCTOR(S)             SUBJECT        TIME     DAYS ROOM"})
aadd(abtext,{||"            INSTRUCTOR(S)       ECODE    SUBJECT        TIME     DAYS ROOM"})
aadd(abtext,{||"     -------------------------- ----- -------------- ----------- ---- ----"})

/*
               INSTRUCTOR(S)             SUBJECT        TIME     DAYS ROOM
     -------------------------------- -------------- ----------- ---- ----
123. 123456789012345678901234567890 1 123456789012 1 11:11-11:11 1234 1234
*/

pageprint(abtext)
t999lst->(dbgotop())
do while ! t999lst->(eof())
        fask(09,"  Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! alltrim(t999lst->tidno) == "0"
                cinstname := alltrim(t999lst->tlname)+" , "+alltrim(t999lst->tfname)+"   "+t999lst->tmname+space(35)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        lprint := .t.
                        if lfirst
                                ++nctr
                                lfirst := .f.
                                nline := nctr
                                cdot := "."
                        endif
                        fask(15,"  Printing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if cpapersize == "L"
                                if prow() > 70
                                        __eject()
                                        pageprint(abtext)
                                        nline := nctr
                                        cdot  := "."
                                        cinstname := alltrim(t999lst->tlname)+" , "+alltrim(t999lst->tfname)+"   "+t999lst->tmname+space(30)
                                endif
                        elseif cpapersize == "S"
                                if prow() > _MAX_LINE
                                        __eject()
                                        pageprint(abtext)
                                        nline := nctr
                                        cdot  := "."
                                        cinstname := alltrim(t999lst->tlname)+" , "+alltrim(t999lst->tfname)+"   "+t999lst->tmname+space(30)
                                endif
                        endif
//                                           substr(cinstname,1,32)+" "+;

                        @ prow()+01,00 say transform(nline,"@Z 999")+cdot+" "+;
                                           substr(cinstname,1,26)+" "+cyytskdp->skdcod+" "+;
                                           cyytskdp->skdsubcod+" "+;
                                           if(cyytskdp->skdsubtyp == "LAB","L"," ")+" "+;
                                           cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+;
                                           cyytskdp->skdday+" "+;
                                           cyytskdp->skdrom
                        cinstname := space(50)
                        nline := 0
                        cdot := " "
                        cyytskdp->(dbskip())
                enddo
        endif
        clearbuffer()
        cyytskdp->(clearscope())
        t999lst->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
        if .not. t999lst->(eof()) .and. lprint
                @ prow()+01,00 say " "
                lprint := .f.
                lfirst := .t.
        endif
enddo
__eject()
return(nil)

*------------------------------------------------------------------------------*

function gradclasslist()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), cdesc,;
      ccode
private lprint:=.f.

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Report for Graduating  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
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
        cdesc := term->name
        @ 02,24 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        ccode := "ALL   " &&space(len(t999lst->tidno))
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View Instructor        Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor(space(len(t999lst->tidno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode    pict "@!";
                        valid ! empty(ccode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode)) .and. ! alltrim(ccode) == "ALL"
                        fask(10,"   Instructor Code "+alltrim(ccode)+" not registered.   ",{" Ok "},memvar->colorarrayu[05],.t.,nil)
                        loop
                endif
                if ! ccode == "ALL   "
                        @ 04,27 say "- "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+" "+alltrim(t999lst->tlname)
                endif
/*
                if ! alltrim(ccode) == "ALL"
                        if whereprint({||pgradbyinst(ccode,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
*/
                        if whereprint({||pallgradbyinst(ccode,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                *endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pallgradbyinst(ccode,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

if ! alltrim(ccode) == "ALL"
        t999lst->(sx_setscope(_TOP_SCOPE   ,ccode))
        t999lst->(sx_setscope(_BOTTOM_SCOPE,ccode))
else
        t999lst->(sx_settagorder(2))
endif
t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" &&Disolved
                fask(10,"   Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        lprint := .f.
                        *fask(16,"   Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        /* if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC")) */
                        if ! cyytskdp->skdsplcod == "C"
                                cecode := cyytskdp->skdcod
                                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cesubj := alltrim(c999crsp->crsdsc1)
                                if cyytskdp->skdsplcod == "S"
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        ccecode := cyytskdp->skdcod
                                        cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                        cyytskdp->(sx_settagorder(6))
                                        cyytskdp->(dbgoto(nrecno))
                                else
                                        ccecode := " "
                                        cceskd  := " "
                                endif
                                nctr := npage := 0
                                ccode := t999lst->tidno
                                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                                checkgraduating()
                                if memvar->lprint
                                        pageprint(abtext)
                                        cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                                        cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                                        cyytenrr->(dbgotop())
                                        do while ! cyytenrr->(eof())
                                                fask(16,"   Printing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                if alltrim(cyytenrr->enrrem) == "GRADUATING"
                                                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                                                memvar->lprint := .f.
                                                        endif
                                                        c999colp->(dbseek(cyytenrr->enrcolcod))
                                                        c999sm1p->(dbseek(cyytenrr->enridno))
                                                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                                                             cyytenrr->enridno+space(01)+;
                                                                             c999sm1p->sm1lstnam+space(01)+;
                                                                             c999sm1p->sm1fstnam+space(01)+;
                                                                             c999sm1p->sm1midnam+space(01)+;
                                                                             c999colp->coldesabr+space(02)+;
                                                                             cyytenrr->enryrlevl+space(01)+;
                                                                             "__________")
                                                        if ! empty(cyytenrr->enrrem)
                                                                outexpr(prow()+00,67,cyytenrr->enrrem)
                                                        endif
                                                endif
                                                memvar->lprint := .t.
                                                if nextkey() == K_ESC
                                                        exit
                                                endif
                                                cyytenrr->(dbskip())
                                        enddo
                                        cyytenrr->(clearscope())
                                endif
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                        if memvar->lprint
                                outexpr(prow()+00,00,chr(18))
                                __eject()
                        endif
                enddo
                cyytskdp->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
t999lst->(clearscope())
return(nil)

static function checkgraduating()
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
        fask(16,"   Printing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if alltrim(cyytenrr->enrrem) == "GRADUATING"
                memvar->lprint := .t.
                exit
        endif
        cyytenrr->(dbskip())
enddo
cyytenrr->(clearscope())
return(nil)

*------------------------------------------------------------------------------*

function classbyyear()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), cdesc,;
      ccode,cyrlevel
private lprint:=.f.

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Report by Year Level  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
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
        cdesc := term->name
        @ 02,24 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        ccode := "ALL   " &&space(len(t999lst->tidno))
        cyrlevel := "3"
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View Instructor        Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor(space(len(t999lst->tidno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode    pict "@!";
                        valid ! empty(ccode)
                @ 05,02 say "Year Level      :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "12345"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode)) .and. ! alltrim(ccode) == "ALL"
                        fask(10,"   Instructor Code "+alltrim(ccode)+" not registered.   ",{" Ok "},memvar->colorarrayu[05],.t.,nil)
                        loop
                endif
                if ! ccode == "ALL   "
                        @ 04,27 say "- "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+" "+alltrim(t999lst->tlname)
                endif
                if whereprint({||pclassbyyear(ccode,cdesc,cyrlevel)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pclassbyyear(ccode,cdesc,cyrlevel)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

if ! alltrim(ccode) == "ALL"
        t999lst->(sx_setscope(_TOP_SCOPE   ,ccode))
        t999lst->(sx_setscope(_BOTTOM_SCOPE,ccode))
else
        t999lst->(sx_settagorder(2))
endif
t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" &&Disolved
                fask(10,"   Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        memvar->lprint := .f.
                        if ! cyytskdp->skdsplcod == "C"
                                cecode := cyytskdp->skdcod
                                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cesubj := alltrim(c999crsp->crsdsc1)
                                if cyytskdp->skdsplcod == "S"
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        ccecode := cyytskdp->skdcod
                                        cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                        cyytskdp->(sx_settagorder(6))
                                        cyytskdp->(dbgoto(nrecno))
                                else
                                        ccecode := " "
                                        cceskd  := " "
                                endif
                                nctr := npage := 0
                                ccode := t999lst->tidno
                                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                                checkyearlevel(cyrlevel)
                                if memvar->lprint
                                        pageprint(abtext)
                                        cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                                        cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                                        cyytenrr->(dbgotop())
                                        do while ! cyytenrr->(eof())
                                                fask(16,"   Printing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                                if cyytenrr->enryrlevl == cyrlevel
                                                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                                                memvar->lprint := .f.
                                                        endif
                                                        c999colp->(dbseek(cyytenrr->enrcolcod))
                                                        c999sm1p->(dbseek(cyytenrr->enridno))
                                                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                                                             cyytenrr->enridno+space(01)+;
                                                                             c999sm1p->sm1lstnam+space(01)+;
                                                                             c999sm1p->sm1fstnam+space(01)+;
                                                                             c999sm1p->sm1midnam+space(01)+;
                                                                             c999colp->coldesabr+space(02)+;
                                                                             cyytenrr->enryrlevl+space(01)+;
                                                                             "__________")
                                                        if ! empty(cyytenrr->enrrem)
                                                                outexpr(prow()+00,67,cyytenrr->enrrem)
                                                        endif
                                                endif
                                                memvar->lprint := .t.
                                                if nextkey() == K_ESC
                                                        exit
                                                endif
                                                cyytenrr->(dbskip())
                                        enddo
                                        cyytenrr->(clearscope())
                                endif
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                        if memvar->lprint
                                outexpr(prow()+00,00,chr(18))
                                __eject()
                        endif
                enddo
                cyytskdp->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
t999lst->(clearscope())
return(nil)

static function checkyearlevel(cyrlevel)
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
        fask(16,"   Processing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrr->enryrlevl == cyrlevel
                memvar->lprint := .t.
                exit
        endif
        cyytenrr->(dbskip())
enddo
cyytenrr->(clearscope())
return(nil)

*------------------------------------------------------------------------------*
//C L A S S   L I S T   B Y   S U B J E C T
*------------------------------------------------------------------------------*

function cllistsubj()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), cdesc,;
      ccode,lprint:=.f.,csubject

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Report by Instructor  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
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
        cdesc := term->name
        @ 02,24 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccode := "ALL   " &&space(len(t999lst->tidno))
        csubject := space(len(cyytskdp->(skdsubcod)))
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View Subject          Г           ESC - Previous              Г")
//                setkey(K_F4,{||vsubject(space(len(t999lst->tidno)),cprocsts,memvar->colorarray[10])})
                setkey(K_F4,{||vschedule(space(len(cyytskdp->skdcod)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Subject :";
                        color memvar->colorarray[02];
                        get csubject    pict "@!";
                        valid ! empty(csubject)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode)) .and. ! alltrim(ccode) == "ALL"
                        fask(10,"   Instructor Code "+alltrim(ccode)+" not registered.   ",{" Ok "},memvar->colorarrayu[05],.t.,nil)
                        loop
                endif
/*
                if ! ccode == "ALL   "
                        @ 04,27 say "- "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+" "+alltrim(t999lst->tlname)
                endif
*/
                if ! alltrim(csubject) == "0"
                        if whereprint({||pdisbysubj(csubject,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pdisbysubj(csubject,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

cyytskdp->(sx_setscope(_TOP_SCOPE   ,csubject))
cyytskdp->(sx_setscope(_BOTTOM_SCOPE,csubject))

cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        lprint := .f.
        fask(8,"   Processing subject "+csubject+" skdcode "+cyytskdp->skdcod+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
//        if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC"))
        if ! cyytskdp->skdsplcod=="C"
                cecode := cyytskdp->skdcod
                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                c999crsp->(dbseek(cyytskdp->skdintcod))
                cesubj := alltrim(c999crsp->crsdsc1)
                if cyytskdp->skdsplcod == "S"
                        nrecno:=cyytskdp->(recno())
                        cyytskdp->(sx_settagorder(1))
                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                        ccecode := cyytskdp->skdcod
                        cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
//                        ccont   := "C"
                        cyytskdp->(sx_settagorder(2))
                        cyytskdp->(dbgoto(nrecno))
                endif
                lprint := .t.
                nctr := npage := 0
                t999lst->(dbseek(cyytskdp->(skdinscod)))
                ccode := t999lst->tidno
                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                pageprint(abtext)
                cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                cyytenrr->(dbgotop())
                do while ! cyytenrr->(eof())
                        fask(12,"   "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999colp->(dbseek(cyytenrr->enrcolcod))
                        c999sm1p->(dbseek(cyytenrr->enridno))
                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             c999sm1p->sm1lstnam+space(01)+;
                                             c999sm1p->sm1fstnam+space(01)+;
                                             c999sm1p->sm1midnam+space(01)+;
                                             c999colp->coldesabr+space(02)+;
                                             cyytenrr->enryrlevl+space(01)+;
                                             "__________")
                        if ! empty(cyytenrr->enrrem)
                                outexpr(prow()+00,67,cyytenrr->enrrem)
                        endif
                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                lprint := .f.
                        else
                                lprint := .t.
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytenrr->(dbskip())
                enddo
                cyytenrr->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
        if lprint
                outexpr(prow()+00,00,chr(18))
                __eject()
        endif
enddo
cyytskdp->(clearscope())
return(nil)

