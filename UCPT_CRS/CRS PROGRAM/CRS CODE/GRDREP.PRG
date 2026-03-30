* Program       :  GRDREP.PRG
* Author        :  Jun Benlot and Randy F. Santizo (c) July 1998
* Updated       :  March 21, 2000
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

#define _SUBJ        1
#define _GRD         2
#define _UNTS        3
#define _EMPTY_ELEMENT  {space(13),;
                         space(03),;
                         space(04)}
*------------------------------------------------------------------------------*
//Grade Average
function compgrdave()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      ccolcode,cyear,cgrade,cterm,cdesc,cscope,ctype,aprv1setup,aprv2setup,;
      bprint, cprocsts, cyytstsp, cyytenrp, cyytskdp
private cdummy := "grdave"+strzero(memvar->naccess,2), grdave

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Compute Students Grade Average  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytstsp := alltrim("c"+cterm+"stsp")
        cyytenrp := alltrim("c"+cterm+"enrp")
        cyytskdp := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "1"
        cgrade   := "F"
        cscope   := "R"
        ctype    := "W"
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                //@ 03,23 say "[NT-nautical,MG-marine, NA-name]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcode(ccolcode,cprocsts)
                @ 04,23 say "[1 2 3 4 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear  pict "@!";
                        valid cyear $ "12345"
                @ 05,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Grade          :";
                        color memvar->colorarray[02];
                        get cgrade      pict "@!";
                        valid cgrade $ "MF"
                @ 06,23 say "[T-op100, D-eansLister, R-anking]" color memvar->colorarray[02]
                @ 06,02 say "Scope          :";
                        color memvar->colorarray[02];
                        get cscope      pict "@!";
                        valid cscope $ "DTR"
                @ 07,23 say "[P-GPA, W-GWA]" color memvar->colorarray[02]
                @ 07,02 say "Computation    :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "PW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ccolcode $ "NT,MG,NA"
                        bprint := {||pgrdavegroup(ccolcode,cyear,cgrade,cscope,ctype,cdesc,"NF")}
                else
                        bprint := {||pgrdave(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                endif
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

function pgrdave(ccolcode,cyear,cgrade,cscope,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == "1"
        cyeardesc := "FIRST YEAR"
elseif cyear == "2"
        cyeardesc := "SECOND YEAR"
elseif cyear == "3"
        cyeardesc := "THIRD YEAR"
elseif cyear == "4"
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
if cscope == "D"
        aadd(abtext,{||space(titlepos("STUDENTS' DEANS LISTER",nmaxcol))+"STUDENTS' DEANS LISTER"})
elseif cscope == "T"
        aadd(abtext,{||space(titlepos("TOP 100 STUDENTS",nmaxcol))+"TOP 100 STUDENTS"})
elseif cscope == "R"
        aadd(abtext,{||space(titlepos("STUDENTS RANKING",nmaxcol))+"STUDENTS RANKING"})
endif
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc,nmaxcol))+cyeardesc})
aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/


cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        //fask(10," WAAA Processing id-no."+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
        cyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
        cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
        cyytstsp->(dbgotop())
        do while ! cyytstsp->(eof())
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0) 
                   //.and.  (!left(cyytskdp->skdsubcod,2) $ "NST" .or. !left(cyytskdp->skdsubcod,2) $ "PE")
                        do case
                                case cgrade == "M"
                                   if val(cyytstsp->stsmidgrd) > 0 .and. isdigit(cyytstsp->stsmidgrd)
                                            if val(cyytstsp->stsmidgrd) >= 10 .and. val(cyytstsp->stsmidgrd) <= 27
                                               if !left(cyytskdp->skdsubcod,2) $ "NST" .or. !left(cyytskdp->skdsubcod,2) $ "PE"
                                                    if ctype == "P"  //&&GPA
                                                            ntgrade += (val(cyytstsp->stsmidgrd) / 10)
                                                    else // &&GWA
                                                            nequi   := (val(cyytstsp->stsmidgrd) / 10) * cyytskdp->skdunt
                                                            ntequi  += nequi
                                                            ntunits += cyytskdp->skdunt
                                                    endif
                                                    lprocess := .t.
                                                    ++nctr
                                                else 
                                                     lprocess := .f.
                                                   exit
                                                endif
                                            else // W DR NA 5.0
                                                    lprocess := .f.
                                                   exit
                                            endif

                                        else
                                            if val(cyytstsp->stsfingrd) >= 10 .and. val(cyytstsp->stsfingrd) <= 27
                                                    if ctype == "P"  //&&GPA
                                                            ntgrade += (val(50) / 10)

                                                    else // &&GWA
                                                            nequi   := (val(50) / 10) * cyytskdp->skdunt
                                                            ntequi  += nequi
                                                            ntunits += cyytskdp->skdunt
                                                    endif

                                                lprocess := .t.
                                                ++nctr

                                            else // W DR NA 5.0
                                                    lprocess := .f.
                                                   exit
                                            endif

                                        endif
                                case cgrade == "F"
                                        if val(cyytstsp->stsfingrd) > 0 .and. isdigit(cyytstsp->stsfingrd)
                                            if val(cyytstsp->stsfingrd) >= 10 .and. val(cyytstsp->stsfingrd) <= 27
                                               if !left(cyytskdp->skdsubcod,2) $ "NST" .or. !left(cyytskdp->skdsubcod,2) $ "PE"
                                                    if ctype == "P"  //&&GPA
                                                            ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                    else // &&GWA
                                                            nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                            ntequi  += nequi
                                                            ntunits += cyytskdp->skdunt
                                                    endif
                                                    lprocess := .t.
                                                    ++nctr
                                                else 
                                                     lprocess := .f.
                                                   exit
                                                endif
                                            else // W DR NA 5.0
                                                    lprocess := .f.
                                                   exit
                                            endif

                                        else
                                            if val(cyytstsp->stsfingrd) >= 10 .and. val(cyytstsp->stsfingrd) <= 27
                                                    if ctype == "P"  //&&GPA
                                                            ntgrade += (val(50) / 10)

                                                    else // &&GWA
                                                            nequi   := (val(50) / 10) * cyytskdp->skdunt
                                                            ntequi  += nequi
                                                            ntunits += cyytskdp->skdunt
                                                    endif

                                                lprocess := .t.
                                                ++nctr

                                            else // W DR NA 5.0
                                                    lprocess := .f.
                                                   exit
                                            endif

                                        endif
        
                        endcase
                endif
                cyytstsp->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
        enddo
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(ccolcode))
                grdave->course  := c999colp->coldesabr
                if ctype == "P" // &&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

*------------------------------------------------------------------------------*
function gradegrad()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      ccolcode,cyear,cgrade,cterm,cdesc,ctype,aprv1setup,aprv2setup,;
      bprint, cprocsts, cyytstsp, cyytskdp
private cdummy := "grade"+strzero(memvar->naccess,2), grade

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Compute Graduating Students Grade Average  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytstsp := alltrim("c"+cterm+"stsp")
        cyytskdp := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,3},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "PN"
        cyear    := "3"
        cgrade   := "F"
        ctype    := "W"
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcode(ccolcode,cprocsts)
                @ 04,23 say "[3 4 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear  pict "@!";
                        valid cyear $ "345"
                @ 05,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Grade          :";
                        color memvar->colorarray[02];
                        get cgrade      pict "@!";
                        valid cgrade $ "MF"
                @ 06,23 say "[P-GPA, W-GWA]" color memvar->colorarray[02]
                @ 06,02 say "Computation    :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "PW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                bprint := {||pgradegrad(ccolcode,cyear,cgrade,ctype,cdesc)}
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

function pgradegrad(ccolcode,cyear,cgrade,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grade := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grade+".TXT"),"grade",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grade->(__dbzap());grade->(dbreindex())

if cyear == "1"
        cyeardesc := "FIRST YEAR"
elseif cyear == "2"
        cyeardesc := "SECOND YEAR"
elseif cyear == "3"
        cyeardesc := "THIRD YEAR"
elseif cyear == "4"
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("Graduating Students Ranking",nmaxcol))+;
                              "Graduating Students Ranking"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc,nmaxcol))+cyeardesc})
aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/


c999sm1p->(sx_setscope(_TOP_SCOPE   ,ccolcode+" "+cyear))
c999sm1p->(sx_setscope(_BOTTOM_SCOPE,ccolcode+" "+cyear))
c999sm1p->(dbgotop())
do while ! c999sm1p->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10," Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
        cyytstsp->(sx_setscope(_TOP_SCOPE   ,c999sm1p->sm1idno))
        cyytstsp->(sx_setscope(_BOTTOM_SCOPE,c999sm1p->sm1idno))
        cyytstsp->(dbgotop())
        do while ! cyytstsp->(eof())
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        do case
                                case cgrade == "M"
                                    if val(cyytstsp->stsmidgrd) > 0 
                                        if val(cyytstsp->stsmidgrd) >= 10 .and. cyytstsp->stsmidgrd <= 30
                                                if ctype == "P"  //&&GPA
                                                        ngvar := val(cyytstsp->stsmidgrd) / 10
                                                        ntgrade += ngvar
                                                elseif ctype == "W"  //&&GWA
                                                        ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                        nequi   := ngvar * cyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                                    endif
                                case cgrade == "F"
                                    if val(cyytstsp->stsfingrd) > 0 
                                        if val(cyytstsp->stsfingrd) > 10 .and. val(cyytstsp->stsfingrd) <= 30
                                                if ctype == "P"  //&&GPA
                                                        ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                else  //&&GWA
                                                        nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                                    endif
                        endcase
                endif
                cyytstsp->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
        enddo
        if lprocess
                grade->(dbappend())
                grade->idno    := c999sm1p->sm1idno
                grade->lname   := c999sm1p->sm1lstnam
                grade->fname   := c999sm1p->sm1fstnam
                grade->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(ccolcode))
                grade->course  := c999colp->coldesabr
                if ctype == "P"  //&&GPA
                        grade->grade := ntgrade / nctr
                else  //&&GWA
                        grade->grade := ntequi / ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        c999sm1p->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
c999sm1p->(clearscope())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grade->(dbgotop())
do while ! grade->(eof())
        fask(10,"  Printing name "+alltrim(grade->lname)+", "+alltrim(grade->fname)+" "+grade->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                             grade->idno   + space(02) + ;
                             grade->lname  + space(02) + ;
                             grade->fname  + space(02) + ;
                             grade->mname  + space(02) + ;
                             grade->course + space(02) + ;
                             transform(grade->grade,"9.999"))
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grade->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

*------------------------------------------------------------------------------*

#define _SUBJECT        1
#define _DESC           2
#define _GRADE          3
#define _UNITS          4
#define _SKDNO          5
#define _EMPTY_ELEM     {space(14),;
                         space(39),;
                         space(03),;
                         space(04),;
                         space(05)}
function grdindividual()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, aprv2setup
private aitems := {},nindex,ntotunits,ntotequi,cgrade,lok,nsubcount,;
        cidno,clname,cfname,cmname,ccolcode,cyear,cterm,cdesc,ccoldesc

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ogrdind := createabrowse(bitems,bindex,07,03,21,76,;
                        {|xnmode,xoabrowser,xaxparam|fgrdind(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_SUBJECT]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_DESC]+" "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_GRADE]+"  "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_UNITS]+"  "},nil}},;
                        {"     Subject    ", "              Description                ", " Grade ", " Units "},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ"})
*                         x123456789012x1x    x123456789012345678901234567890123456789x    xx1.1xx    x12.1xx

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
memvar->cterm  := space(len(term->code))
memvar->cgrade := "F"
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing Individual  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)
        @ 02,57say "Period:";
                color memvar->colorarray[02];
                get memvar->cgrade      pict "@!";
                valid cgrade $ "MF"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->cdesc := term->name
        @ 02,67 say if(cgrade == "M","- Midterm","- Final  ")
        if ! file(alltrim("c"+memvar->cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "c"+memvar->cterm+"stsp"
        cyytskdp := "c"+memvar->cterm+"skdp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        memvar->cidno := space(len(c999sm1p->sm1idno))
        aentryscr := savescr(01,00,24,79)
        do while .t.
                memvar->clname          := space(len(c999sm1p->sm1lstnam))
                memvar->cfname          := space(len(c999sm1p->sm1fstnam))
                memvar->cmname          := space(len(c999sm1p->sm1midname))
                memvar->ccolcode        := space(len(c999sm1p->sm1colcod))
                memvar->cyear           := space(01)
                memvar->aitems          := {_EMPTY_ELEM}
                memvar->nindex          := 1
                memvar->ntotunits       := 0
                memvar->ntotequi        := 0
                memvar->nsubcount       := 0
                memvar->lok             := .t.
                restscr(aentryscr)
                commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno       pict "@!";
                        valid ! empty(memvar->cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(memvar->cidno)) .and.;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytstsp->(dbseek(memvar->cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                elseif !c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytstsp->(dbseek(memvar->cidno))
                                fask(10,"   Student not enrolled.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midname
                memvar->ccolcode        := c999sm1p->sm1colcod
                memvar->cyear           := transform(cyytstsp->stsyrlevel,"9")  //gipa ilisan ni Wena
                *memvar->cyear           := transform(c999sm1p->sm1yrlevl,"9")  //mao ni ang original
                c999colp->(dbseek(memvar->ccolcode))
                memvar->ccoldesc        := c999colp->coldesabr
                process()
                @ 04,25 say "- "+alltrim(memvar->clname)+" , "+alltrim(memvar->cfname)+"  "+memvar->cmname+"."
                @ 05,02 say "              "+memvar->ccolcode+" - "+memvar->ccoldesc
                @ 05,02 say "Course/Major: " color memvar->colorarray[02]
                @ 05,34 say "            "+memvar->cyear+;
                        if(memvar->cyear == _FIRST_YEAR, " - First Year ",;
                        if(memvar->cyear == _SECOND_YEAR," - Second Year",;
                        if(memvar->cyear == _THIRD_YEAR, " - Third Year ",;
                        if(memvar->cyear == _FOURTH_YEAR," - Fourth Year",;
                                                         " - Fifth Year "))))
                @ 05,34 say "Year Level: " color memvar->colorarray[02]
                @ 22,02 say "      "+displaydate(date())
                @ 22,02 say "Date: " color memvar->colorarray[02]
//                @ 22,63 say if(lok,transform((memvar->ntotequi),"@Z 99.99"),"     ")
//                @ 22,63 say if(lok,transform((memvar->ntotequi/memvar->ntotunits),"@Z 99.99"),"     ")
//                @ 22,63 say if(lok,transform(memvar->ntotequi/memvar->nsubcount,"@Z 99.99"),"     ")
                @ 22,63 say transform(memvar->ntotunits,"@Z 99.9")
                dispbox(06,02,21,77,_SINGLE_LINE)
                connectline(08,02,77)
                commandline("³ F8 - Print in blank form ³ F10 - Print in printed form ³   ESC - Previous    ³")
                stabilize(ogrdind,.t.)
                browsearray(ogrdind,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fgrdind(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 07,03 say "     Subject                   Description                  Grade   Units " color memvar->colorarray[35]
                return 1
        case lastkey() == K_F4
                cyytskdp->(dbseek(right(memvar->aitems[nindex,_SKDNO],5)))
                if ! empty(cyytskdp->skdinscod)
                     t999lst->(dbseek(cyytskdp->skdinscod))
                     fask(13,"  "+alltrim(cyytskdp->skdsubcod)+" ==> "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06])
                else
                     fask(13,alltrim(cyytskdp->skdsubcod)+";  Not assigned to Instructor  ",{" Ok "},memvar->colorarray[05])
                endif
        case lastkey() == K_F8
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pgrdblankform()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pgrdprintedform()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif

        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function process()
local nlastelem
private ncount, nsubcount
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
cyytstsp->(sx_setscope(_TOP_SCOPE   ,memvar->cidno))
cyytstsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cidno))
lok := .t.
count to ncount
memvar->nsubcount := 0
cyytstsp->(dbgotop())
do while ! cyytstsp->(eof())
   if (ncount <= 19) .or. ((ncount > 19) .and. (cyytskdp->skdsplcod != "C"))   

        fask(13,"  Processing code "+cyytstsp->stsskdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                aadd(memvar->aitems,_EMPTY_ELEM)
                nlastelem := len(memvar->aitems)
                memvar->aitems[nlastelem,_SKDNO]     := cyytstsp->stsskdcod
                memvar->aitems[nlastelem,_SUBJECT]   := c999crsp->crssubcod+" "+if(c999crsp->crssubtyp == "R"," ","L")
                memvar->aitems[nlastelem,_DESC]      := alltrim(c999crsp->crsdsc1)+if(!empty(c999crsp->crsdsc2),"...","   ")+;
                                                        space(36-len(alltrim(c999crsp->crsdsc1)))
                do case
                        case memvar->cgrade == "M" // &&Midterm
                                if val(cyytstsp->stsmidgrd) > 0
                                        if substr(cyytstsp->stsmidgrd,2,1) == "W"  /*  for 3W  */
                                                memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsmidgrd+" "
                                        else  /* for 30-10 */
                                                memvar->aitems[nlastelem,_GRADE] := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                        endif
                                        if cyytstsp->stsmidgrd <= "30"
                                                filterunits(nlastelem)
                                                //ntotequi += (val(cyytstsp->stsmidgrd)/10)
                                                nsubcount += 1
                                                ntotequi += ((val(cyytstsp->stsmidgrd)/10) * cyytskdp->skdunt)
                                        else
                                                memvar->aitems[nlastelem,_UNITS] := "  0 "
                                                lok := .f.
                                        endif
                                elseif ! empty(cyytstsp->stsmidgrd)
                                        memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsmidgrd+" "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                elseif empty(cyytstsp->stsmidgrd)
                                        memvar->aitems[nlastelem,_GRADE] := " - "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                endif
                        case memvar->cgrade == "F"  // &&Final
                                if val(cyytstsp->stsfingrd) > 0
                                        if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsfingrd+" "
                                        else /* for 30 - 10 grade */
                                                memvar->aitems[nlastelem,_GRADE] := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                        endif
                                        if cyytstsp->stsfingrd <= "30"
                                                filterunits(nlastelem)
                                              //  ntotequi += (val(cyytstsp->stsfingrd)/10)
                                                ntotequi += ((val(cyytstsp->stsfingrd)/10) * (cyytskdp->skdunt))
                                                nsubcount += 1
                                        else
                                                memvar->aitems[nlastelem,_UNITS] := "  0 "
                                                lok := .f.
                                        endif
                                elseif ! empty(cyytstsp->stsfingrd)
                                        memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsfingrd+" "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                elseif empty(cyytstsp->stsfingrd)
                                        memvar->aitems[nlastelem,_GRADE] := " - "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                endif
                endcase
        endif
   endif
   cyytstsp->(dbskip())
enddo
cyytstsp->(clearscope())
cyytstsp->(dbclearrelation())
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_SUBJECT])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)


static function filterunits(nlastelem)
private nunits

memvar->ntotunits += cyytskdp->skdunt

nunits := cyytskdp->skdunt

if (ncount > 19) .and. (cyytskdp->skdsplcod=="S")
        cyytskdp->(dbseek(cyytstsp->stsskdcod))
        cyytskdp->(dbseek(cyytskdp->skdsplskd))
        if cyytskdp->skdsubtyp=="LAB"
                nunits += cyytskdp->skdunt
                memvar->ntotunits += cyytskdp->skdunt
        endif
endif
/*
memvar->aitems[nlastelem,_UNITS] := if(substr(str(cyytskdp->skdunt,5,1),5,1) == "0",;
                                       substr(str(cyytskdp->skdunt,5,1),1,3)+" ",;
                                       substr(str(cyytskdp->skdunt,5,1),2,4))
*/
memvar->aitems[nlastelem,_UNITS] := if(substr(str(nunits,5,1),5,1) == "0",;
                                       substr(str(nunits,5,1),1,3)+" ",;
                                       substr(str(nunits,5,1),2,4))

return(nil)


static function pgrdblankform()
local nctr := 0
header()
for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing subject "+alltrim(memvar->aitems[nctr,_DESC])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,memvar->aitems[nctr,_SUBJECT]+space(02)+;
                             memvar->aitems[nctr,_DESC]+space(04)+;
                             memvar->aitems[nctr,_GRADE]+space(03)+;
                             memvar->aitems[nctr,_UNITS])
next
outexpr(prow()+01,00,replicate("-",70))
//outexpr(prow()+01,58,transform(memvar->ntotequi/memvar->ntotunits,"99.999"))
//outexpr(prow()+01,58,transform(memvar->ntotequi/memvar->nsubcount,"99.999"))
outexpr(prow()+01,66,transform(memvar->ntotunits,"99.9"))
//outexpr(prow()+01,00,displaydate(date())+space(57)+transform(memvar->ntotunits,"99.9"))
//outexpr(prow()+00,58,if(memvar->cgrade == "F" .and. memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"99.99"),"    "))
//outexpr(prow()+00,58,transform(memvar->ntotequi/memvar->ntotunits,"99.99"))
outexpr(19,00,"UC-PT/REG.Doc/009/Rev.01")
@ 22,00 say space(01)  /* to eject */
setprc(00,00)
return(nil)


static function header()
*setprc(00,00)
//outexpr(00,00,substr(memvar->ccompanyname,1,28)+space(01)+substr(memvar->cdesc,1,22)+space(06)+if(memvar->cgrade == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(00,00,substr(memvar->ccompanyname,1,32)+space(01)+substr(memvar->cdesc,1,22)+space(02)+if(memvar->cgrade == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(01,00,replicate("-",70))
//outexpr(02,00,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->cfname+space(01)+memvar->cmname+space(07)+memvar->ccoldesc+space(04)+memvar->cyear)
outexpr(02,00,memvar->cidno+space(02)+alltrim(memvar->clname)+","+space(01)+alltrim(memvar->cfname)+space(02)+alltrim(memvar->cmname))
outexpr(02,60,memvar->ccoldesc+space(02)+memvar->cyear)
outexpr(03,00,replicate("-",70))
outexpr(04,00,"SUBJECT         DESCRIPTION                               GRADE  UNITS")
return(nil)


static function pgrdprintedform()
local nctr := 0
outexpr(00,30,substr(memvar->cdesc,1,22))
//outexpr(02,01,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->cfname+space(01)+memvar->cmname+space(02)+memvar->ccoldesc+space(01)+memvar->cyear+space(02)+if(memvar->cgrade == "M","MIDTERM","FINAL"))
outexpr(02,01,memvar->cidno+space(02)+alltrim(memvar->clname)+","+space(01)+alltrim(memvar->cfname)+space(02)+alltrim(memvar->cmname))
//outexpr(02,61,memvar->ccoldesc+space(01)+memvar->cyear+space(02)+if(memvar->cgrade == "M","MIDTERM","FINAL"))
outexpr(02,55,memvar->ccoldesc+space(01)+memvar->cyear+space(03)+if(memvar->cgrade == "M","MIDTERM"," FINAL "))
outexpr(03,00,space(01))
for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing subject "+alltrim(memvar->aitems[nctr,_DESC])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,memvar->aitems[nctr,_SUBJECT]+space(01)+;
                             memvar->aitems[nctr,_DESC]+space(08)+;
                             memvar->aitems[nctr,_GRADE]+space(02)+;
                             memvar->aitems[nctr,_UNITS])
next
outexpr(19,02,"UC-PT/REG.Doc/009/Rev.01")
outexpr(19,40,dtoc(date()))
//outexpr(18,60,if(memvar->cgrade == "F" .and. memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"99.99"),"    "))
outexpr(19,60,transform(memvar->ntotequi/memvar->ntotunits,"99.999"))
//outexpr(18,60,transform(memvar->ntotequi/memvar->nsubcount,"99.999"))
outexpr(19,67,transform(memvar->ntotunits,"99.9"))
outexpr(22,00,space(01)) /* to eject */
setprc(00,00)
return(nil)

*------------------------------------------------------------------------------*
//GRADE PRINTING FOR DISTRIBUTION
function grdcourse()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, cyytenrp, aprv2setup,;
      cterm,cdesc,cperiod,ccolcode,cyear,cpaper,clname,cfname
private cdummy := "gcours"+strzero(memvar->naccess,2),mstfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cperiod  := "F"
ccolcode := "NT"
cyear    := "1"
cpaper   := "B"
clname   := space(15)
cfname   := space(24)
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing by Course (For Distribution)  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "c"+cterm+"stsp"
        cyytskdp := "c"+cterm+"skdp"
        cyytenrp := "c"+cterm+"enrp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                //commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                //@ 03,23 say "[NT-nautical,MG-marine,CS-SEACAST,NN-NAME]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewallgradefordistribution(ccolcode,cprocsts)

                @ 04,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 04,02 say "Grading Period :";
                        color memvar->colorarray[02];
                        get cperiod     pict "@!";
                        valid cperiod $ "FM"
                @ 05,23 say "[1 2 3 4 5  ]" color memvar->colorarray[02]
                @ 05,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        valid cyear $ "12345"
                @ 06,23 say "[B-lank Form, P-rinted Form]" color memvar->colorarray[02]
                @ 06,02 say "Paper Type     :";
                        color memvar->colorarray[02];
                        get cpaper      pict "@!";
                        valid cpaper $ "BP"
                @ 07,02 say "Last Name      :";
                        color memvar->colorarray[02];
                        get clname      pict "@!"
                @ 08,02 say "First Name     :";
                        color memvar->colorarray[02];
                        get cfname      pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||prngrdcourse(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)


static function prngrdcourse(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname)
local afile
private ntotunits,ntotequi,lok,ntotgrade,csubject,csubdesc,cgrade,cunit,ncredits,lprint,ncount,ncnt,nsubcount,ccolgroup

fask(13,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"PERIOD"      ,"C",07,0}},{||cdxgrdcrs()})
        dbcloseall()
        return(nil)
endif
memvar->mstfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->mstfile+".TXT"),"mstfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif

mstfile->(__dbzap()); mstfile->(dbreindex())

if ccolcode == "NT"
    ccolgroup := "MIMTPAMVHNBNYNSNETNVNWSDTL"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))  
elseif ccolcode == "MG"
    ccolgroup := "MAMRMPMMHMBMYMSMENELERNMMWSEML"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))

elseif ccolcode == "CS"
    ccolgroup := "CS"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
   
elseif ccolcode == "NN"
    ccolgroup := "NN"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
    
endif

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))

ncnt:=0
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrp->enrcolcod $ ccolgroup
            mstfile->(dbappend())
            mstfile->idno   := c999sm1p->sm1idno
            mstfile->lname  := c999sm1p->sm1lstnam
            mstfile->fname  := c999sm1p->sm1fstnam
            mstfile->mname  := c999sm1p->sm1midnam
            mstfile->course := c999colp->coldesabr
            mstfile->year   := cyytenrp->enryrlevl
            mstfile->period := if(cperiod == "M","MIDTERM","FINAL  ")
            if nextkey() == K_ESC
                    exit
            endif
            ncnt += 1
        endif 
        cyytenrp->(dbskip())
enddo

//fask(10,"  "+ str(ncnt,5,0)  +"  ",{" Ok "},memvar->colorarray[06],.t.,nil)

cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*------------------
*  Printing data  *
*------------------
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))

mstfile->(dbgotop())
do while ! mstfile->(eof())
        memvar->ntotunits := memvar->ntotequi := memvar->ntotgrade := 0
        memvar->lok             := .t.
        memvar->lprint          := .f.
        memvar->csubject        := space(13)
        memvar->csubdesc        := space(39)
        memvar->cgrade          := space(03)
        memvar->cunit           := space(04)
        memvar->ncredits        := 0
//        fask(10,"  Grade Printing by College  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        fask(10,"  Processing student "+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+" "+mstfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(mstfile->lname)+alltrim(mstfile->fname))        
                    cyytstsp->(sx_setscope(_TOP_SCOPE   ,mstfile->idno))
                    cyytstsp->(sx_setscope(_BOTTOM_SCOPE,mstfile->idno))
                    nsubcount := 0
                    ncount := 0                 
                    do while ! cyytstsp->(eof())
                            ncount += 1
                            cyytstsp->(dbskip())
                    enddo

                    cyytstsp->(dbgotop())
                    do while ! cyytstsp->(eof())
                       if (ncount <= 13) .or. ((ncount > 13) .and. (cyytskdp->skdsplcod != "C"))
                            fask(16,"  Printing code "+alltrim(c999crsp->crsintcod)+" subject "+alltrim(c999crsp->crssubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                            memvar->csubject := c999crsp->crssubcod+if(c999crsp->crssubtyp == "R"," ","L")
                            memvar->csubdesc := alltrim(c999crsp->crsdsc1)+if(!empty(c999crsp->crsdsc2),"...","   ")
                            if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                               ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                    nsubcount += 1
                                    do case
                                            case cperiod == "M" // &&Midterm
                                                    memvar->lok := .f.
                                                    if val(cyytstsp->stsmidgrd) > 0
                                                            if substr(cyytstsp->stsmidgrd,2,1) == "W"  /* for 3W grade */
                                                                    memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                            else  /* for 30 - 10 grade */
                                                                    memvar->cgrade := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                                            endif
                                                            if cyytstsp->stsmidgrd <= "30"
                                                                    memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                                                    _getunits()
                                                            else
                                                                    memvar->cunit := "  0 "
                                                            endif
                                                    elseif ! empty(cyytstsp->stsmidgrd)
                                                            memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                            memvar->cunit  := "  0 "
                                                    elseif empty(cyytstsp->stsmidgrd)
                                                            memvar->cgrade := " - "
                                                            memvar->cunit  := "  0 "
                                                    endif
                                            case cperiod == "F"  // &&Final
                                                    if val(cyytstsp->stsfingrd) > 0
                                                            if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                                    memvar->cgrade := cyytstsp->stsfingrd+" "
                                                            else /* for 30-10 grade */
                                                                    memvar->cgrade := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                                            endif
                                                            if cyytstsp->stsfingrd <= "30"
                                                                    memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                                                    _getunits()
                                                            else
                                                                    memvar->cunit := "  0 "
                                                                    memvar->lok := .f.
                                                            endif
                                                    elseif ! empty(cyytstsp->stsfingrd)
                                                            memvar->cgrade := cyytstsp->stsfingrd+" "
                                                            memvar->cunit  := "  0 "
                                                            memvar->lok := .f.
                                                    elseif empty(cyytstsp->stsfingrd)
                                                            memvar->cgrade := " - "
                                                            memvar->cunit  := "  0 "
                                                            memvar->lok := .f.
                                                    endif
                                    endcase
                                    *---------------------------------
                                    *  check the paper to be printed *
                                    *---------------------------------
                                    do case
                                            case cpaper == "B"  /* Blank Form */
                                                    if ! lprint
                                                            blankheader(cdesc,cperiod)
                                                            memvar->lprint := .t.
                                                    endif
                                                    
                                                    //LIST OF SUBJECTS AND THEIR GRADES
                                                    outexpr(prow()+01,00,memvar->csubject)
                                                    outexpr(prow()+00,16,memvar->csubdesc)
                                                    outexpr(prow()+00,59,memvar->cgrade)
                                                    outexpr(prow()+00,65,memvar->cunit)

                                            case cpaper == "P"  /* Printed Form */
                                                    if ! lprint
                                                            printedheader(cdesc)
                                                            memvar->lprint := .t.
                                                    endif
                                                    //LIST OF SUBJECTS AND THEIR GRADES
                                                    outexpr(prow()+01,00,memvar->csubject)
                                                    outexpr(prow()+00,15,memvar->csubdesc)
                                                    outexpr(prow()+00,62,memvar->cgrade)
                                                    outexpr(prow()+00,67,memvar->cunit)
                                    endcase
                            endif
                            if nextkey() == K_ESC
                                    exit
                            endif
                       endif
                       cyytstsp->(dbskip())
                    enddo
           // endif
                cyytstsp->(clearscope())
                if nextkey() == K_ESC
                        exit
                endif
                /* print footer */
                do case
                        case cpaper == "B"  /* Blank Form   */
                                outexpr(prow()+01,00,replicate("Ä",70))
                                outexpr(prow()+01,00,displaydate(date()))
                                outexpr(prow()+00,59,if(memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"9.99"),"    "))
                                outexpr(prow()+00,65,transform(memvar->ntotunits,"99.9"))
                        case cpaper == "P"  /* Printed Form */
                                outexpr(18,02,displaydate(date()))
                                outexpr(18,61,if(memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"9.99"),"    "))
                                outexpr(18,68,transform(memvar->ntotunits,"99.9"))
                endcase
                @ 22,00 say space(01)  /* to eject */
                setprc(00,-1)
        endif
//        fask(10,"  Processing student "+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+" "+mstfile->mname+".  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        mstfile->(dbskip())
enddo
cyytstsp->(dbclearrelation())
closewcheck(afile)
__eject()
return(nil)

//------------------------------------------------------------------------
//GRADE PRINTING FOR MAILING
function grd4mail()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, cyytenrp, aprv2setup,;
      cterm,cdesc,cperiod,ccolcode,cyear,cpaper,clname,cfname,nbal
private cdummy := "gcours"+strzero(memvar->naccess,2),mstfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cperiod  := "F"
ccolcode := "NT"
cyear    := "1"
cpaper   := "B"
clname   := space(15)
cfname   := space(24)
nbal     := 0
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing for Mailing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "c"+cterm+"stsp"
        cyytskdp := "c"+cterm+"skdp"
        cyytenrp := "c"+cterm+"enrp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                //commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                //setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
               // @ 03,23 say "[NT-nautical,MG-marine,CS-SEACAST,NN-NAME]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewallgradefordistribution(ccolcode,cprocsts)

                @ 04,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 04,02 say "Grading Period :";
                        color memvar->colorarray[02];
                        get cperiod     pict "@!";
                        valid cperiod $ "FM"
                @ 05,23 say "[1 2 3 4 5 ]" color memvar->colorarray[02]
                @ 05,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        valid cyear $ "12345"
                @ 06,23 say "[B-lank Form, P-rinted Form]" color memvar->colorarray[02]
                @ 06,02 say "Paper Type     :";
                        color memvar->colorarray[02];
                        get cpaper      pict "@!";
                        valid cpaper $ "BP"
                @ 07,02 say "Last Name      :";
                        color memvar->colorarray[02];
                        get clname      pict "@!"
                @ 08,02 say "First Name     :";
                        color memvar->colorarray[02];
                        get cfname      pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
        if whereprint({||prngrd4mail(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname,cterm,nbal)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)


static function prngrd4mail(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname,cterm,nbal)
local afile,nindex:=0,stext:="",nlen,i
private ntotunits,ntotequi,lok,ntotgrade,csubject,csubdesc,cgrade,cunit,ncredits,lprint,;
        aitems := {}

fask(13,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"PERIOD"      ,"C",07,0},;
                                 {"BAL"         ,"N",10,2}},{||cdxgrdcrs()})
        dbcloseall()
        return(nil)
endif
memvar->mstfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->mstfile+".TXT"),"mstfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
mstfile->(__dbzap()); mstfile->(dbreindex())

if ccolcode == "NT"
    ccolgroup := "MIMTPAMVHNBNYNSNETNVNWTL"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
elseif ccolcode == "MG"
    ccolgroup := "MAMRMPMMHMBMYMSMENELERNMMWML"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))

elseif ccolcode == "CS"
    ccolgroup := "CS"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
   
elseif ccolcode == "NN"
    ccolgroup := "NN"
    cyytenrp->(sx_settagorder(3))
    cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
    cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
    
endif

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        if cyytenrp->enrconfirm == "*"
            if cyytenrp->enrcolcod $ ccolgroup
                fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                mstfile->(dbappend())
                mstfile->idno   := c999sm1p->sm1idno
                mstfile->lname  := c999sm1p->sm1lstnam
                mstfile->fname  := c999sm1p->sm1fstnam
                mstfile->mname  := c999sm1p->sm1midnam
                mstfile->course := c999colp->coldesabr
                mstfile->year   := cyytenrp->enryrlevl
                mstfile->period := if(cperiod == "M","MIDTERM","FINAL  ")
        //      mstfile->bal    := a999accp->accbaltot
                if nextkey() == K_ESC
                        exit
                endif
            endif
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*------------------
*  Printing data  *
*------------------
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
mstfile->(dbgotop())
do while ! mstfile->(eof())
        memvar->ntotunits := memvar->ntotequi := 0
        memvar->ntotgrade := memvar->ncredits := 0
        memvar->lok             := .t.
        memvar->lprint          := .f.
        memvar->csubject        := space(13)
        memvar->csubdesc        := space(39)
        memvar->cgrade          := space(03)
        memvar->cunit           := space(04)
        memvar->nindex := 1
        asize(memvar->aitems,0)
        fask(10,"  Processing student "+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+" "+mstfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(mstfile->lname)+alltrim(mstfile->fname))
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,mstfile->idno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,mstfile->idno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        fask(16,"  Printing code "+alltrim(c999crsp->crsintcod)+" subject "+alltrim(c999crsp->crssubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        memvar->csubject := c999crsp->crssubcod+if(c999crsp->crssubtyp == "R"," ","L")
                        memvar->csubdesc := alltrim(c999crsp->crsdsc1)+if(!empty(c999crsp->crsdsc2),"...","   ")
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                do case
                                        case cperiod == "M" // &&Midterm
                                                memvar->lok := .f.
                                                if val(cyytstsp->stsmidgrd) > 0
                                                        if substr(cyytstsp->stsmidgrd,2,1) == "W"  /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                        else  /* for 30 - 10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                                        endif
                                                        if cyytstsp->stsmidgrd <= "30"
                                                                getunits()
                                                        else
                                                                memvar->cunit := "  0 "
                                                        endif
                                                elseif ! empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                        memvar->cunit  := "  0 "
                                                elseif empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := " - "
                                                        memvar->cunit  := "  0 "
                                                endif
                                        case cperiod == "F"  // &&Final
                                                if val(cyytstsp->stsfingrd) > 0
                                                        if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        else /* for 30-10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                                        endif
                                                        if cyytstsp->stsfingrd <= "30"
                                                                getunits()
                                                                memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                                        else
                                                                memvar->cunit := "  0 "
                                                                memvar->lok := .f.
                                                        endif
                                                elseif ! empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        memvar->cunit  := "  0 "
                                                        memvar->lok := .f.
                                                elseif empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := " - "
                                                        memvar->cunit  := "  0 "
                                                        memvar->lok := .f.
                                                endif
                                endcase
                                *---------------------------------
                                *  check the paper to be printed *
                                *---------------------------------
                                aadd(memvar->aitems,_EMPTY_ELEMENT)

                                memvar->aitems[memvar->nindex,_SUBJ] := memvar->csubject
                                memvar->aitems[memvar->nindex,_GRD]  := memvar->cgrade
                                memvar->aitems[memvar->nindex,_UNTS] := memvar->cunit
                                memvar->nindex += 1
/*                                do case
                                        case cpaper == "B"   Blank Form
                                                if ! lprint
                                                        bhead4mail(cdesc,cperiod)
                                                        memvar->lprint := .t.
                                                endif
                                                outexpr(prow()+01,00,memvar->csubject)
                                                outexpr(prow()+00,16,memvar->csubdesc)
                                                outexpr(prow()+00,59,memvar->cgrade)
                                                outexpr(prow()+00,65,memvar->cunit)
                                        case cpaper == "P"   Printed Form
                                                if ! lprint
                                                        phead4mail(cdesc)
                                                        memvar->lprint := .t.
                                                endif
                                                outexpr(prow()+01,00,memvar->csubject)
                                                outexpr(prow()+00,15,memvar->csubdesc)
                                                outexpr(prow()+00,62,memvar->cgrade)
                                                outexpr(prow()+00,67,memvar->cunit)
                                endcase
*/
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif

                        memvar->ntotunits += cyytskdp->skdunt

                        cyytstsp->(dbskip())
                enddo
                cyytstsp->(clearscope())
                if nextkey() == K_ESC
                        exit
                endif
bhead4mail(cdesc,cperiod)

nlen := if(len(memvar->aitems)>10,10,len(memvar->aitems))

if len(memvar->aitems)>10
        outexpr(prow()+1,35,"-1Subject          Grade  Units-0          -1Subject          Grade  Units-0")
else
    if ! right(cterm,1)=="4"
        outexpr(prow()+1,35,""+space(39)+"-1Subject          Grade  Units-0")
    else
        outexpr(prow()+1,45,"-1Subject          Grade  Units-0")
    endif
endif

c999sm2p->(dbseek(mstfile->idno))

for i = 1 to 10
    outexpr(prow()+1,00,"")
    do case
        case prow() == 07
                outexpr(prow(),03,"Total Units: "+ transform(memvar->ntotunits,"99.9"))
        case prow() == 08
                outexpr(prow(),00,"Credits Earned: "+transform(memvar->ncredits,"99.9"))
//        case prow() == 09
//                outexpr(prow(),07,"G.W.A. :")
        case prow() == 14
                outexpr(prow(),00,chr(27)+"E"+alltrim(c999sm2p->sm2gdn)+chr(27)+"F")
        case prow() == 15
                outexpr(prow(),00,alltrim(c999sm2p->sm2malad1))
//                outexpr(prow(),00,alltrim(c999sm2p->sm2malad1)+space(15)+IIF(mstfile->bal>0,"Has a remaining balance of P "+alltrim(transform(mstfile->bal,"999,999.99")),""))
        case prow() == 16
                outexpr(prow(),00,alltrim(c999sm2p->sm2malad2)+"")
    endcase

/*
    if (i+10) <= len(memvar->aitems)
        outexpr(prow(),35,  ""+memvar->aitems[i+10,_SUBJ]+"     "+;
                            memvar->aitems[i+10,_GRD]+"   "+;
                            memvar->aitems[i+10,_UNTS])
    else
        outexpr(prow(),35,  ""+space(28))
    endif
    if i <= len(memvar->aitems)
        if ! right(cterm,1)=="4"
        outexpr(prow(),75,  if(prow()==14,space(07),"")+""+;
                            memvar->aitems[i,_SUBJ]+"     "+;
                            memvar->aitems[i,_GRD]+"   "+;
                            memvar->aitems[i,_UNTS])
        else
        outexpr(prow(),45,  if(prow()==14,space(07),"")+""+;
                            memvar->aitems[i,_SUBJ]+"     "+;
                            memvar->aitems[i,_GRD]+"   "+;
                            memvar->aitems[i,_UNTS])
        endif
    endif
*/

    if (i+10) <= len(memvar->aitems)
        if ! right(cterm,1)=="4"
                outexpr(prow(),35,  ""+memvar->aitems[i+10,_SUBJ]+"     "+;
                            memvar->aitems[i+10,_GRD]+"   "+;
                            memvar->aitems[i+10,_UNTS])
        else
                outexpr(prow(),35,  +memvar->aitems[i+10,_SUBJ]+"     "+;
                            memvar->aitems[i+10,_GRD]+"   "+;
                            memvar->aitems[i+10,_UNTS])
        endif
    else
        if ! right(cterm,1)=="4"
                outexpr(prow(),35,  ""+space(28))
        else
                outexpr(prow(),35,  +space(28))
        endif
    endif
    if i <= len(memvar->aitems)
        if ! right(cterm,1)=="4"
        outexpr(prow(),75,  if(prow()==14,space(07),"")+""+;
                            memvar->aitems[i,_SUBJ]+"     "+;
                            memvar->aitems[i,_GRD]+"   "+;
                            memvar->aitems[i,_UNTS])
        else
        outexpr(prow(),45,  if(prow()==14,space(07),"")+;
                            memvar->aitems[i,_SUBJ]+"     "+;
                            memvar->aitems[i,_GRD]+"   "+;
                            memvar->aitems[i,_UNTS])
        endif
    endif
        outexpr(prow(),pcol(),"")
next
                @ 22,00 say space(01)  /* to eject */
                setprc(00,-1)
        endif
        mstfile->(dbskip())
enddo
cyytstsp->(dbclearrelation())
closewcheck(afile)
__eject()
return(nil)


//------------------------------------------------------------------------

static function getunits()
memvar->cunit := if(substr(str(cyytskdp->skdunt,5,1),5,1) == "0",;
                    substr(str(cyytskdp->skdunt,5,1),1,3)+" ",;
                    substr(str(cyytskdp->skdunt,5,1),2,4))
memvar->ncredits += cyytskdp->skdunt
//fask(10,"  "+str(memvar->ncredits)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
return(nil)


//------------------------------------------------------------------------



static function blankheader(cdesc,cperiod)
outexpr(00,00,substr(memvar->ccompanyname,1,28)+space(01)+substr(cdesc,1,22)+space(06)+if(cperiod == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(01,00,replicate("-",70))
outexpr(02,00,mstfile->idno+space(02)+mstfile->lname+space(01)+mstfile->fname+space(01)+mstfile->mname+space(07)+mstfile->course+space(04)+mstfile->year)
outexpr(03,00,replicate("-",70))
outexpr(04,00,"SUBJECT         REFERENCE                                 GRADE  UNITS")
return(nil)


static function printedheader(cdesc)
outexpr(00,30,alltrim(cdesc))
outexpr(02,01,mstfile->idno+space(02)+mstfile->lname+space(01)+mstfile->fname+space(01)+mstfile->mname+space(02)+mstfile->course+space(01)+mstfile->year+space(02)+mstfile->period)
outexpr(03,00,space(01))
return(nil)

static function bhead4mail(cdesc,cperiod)
private stext
stext := mstfile->idno+space(02)+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+space(01)+if(len(mstfile->mname)==0,"",mstfile->mname)
stext := padr(stext,50," ")+mstfile->course+space(02)+mstfile->year+space(03)+if(cperiod == "M","MIDTERM GRADE","  FINAL GRADE")
*outexpr(00,75-(len("UNIVERSITY OF CEBU -  PT")/2),"UNIVERSITY OF CEBU -  PT")
outexpr(00,27,"UNIVERSITY OF CEBU -  PT")
outexpr(01,26,"Bulacao, Pardo, Cebu City")
outexpr(02,40-round(len(alltrim(cdesc)) / 2,0),alltrim(cdesc))
outexpr(03,00,replicate("-",75))
//outexpr(04,00,chr(27)+"E"+stext+chr(27)+"F")
outexpr(04,00,stext)
outexpr(05,00,replicate("-",75))
return(nil)

static function phead4mail(cdesc)
outexpr(00,30,alltrim(cdesc))
outexpr(02,01,mstfile->idno+space(02)+mstfile->lname+space(01)+mstfile->fname+space(01)+mstfile->mname+space(02)+mstfile->course+space(01)+mstfile->year+space(02)+mstfile->period)
outexpr(03,00,space(01))
return(nil)



static function cdxgrdcrs()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

function grdshtprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytskdp,cyytenrr,aprv2setup,;
      cfile,cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinstcode,cinstname,cskdcont,ccedpcode,ccsubject,ncunits,;
      clname,cfname

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cedpcode := space(05)
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Sheet Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp := "c"+cterm+"skdp"
        cyytenrr := "c"+cterm+"enrr"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(t999lst->tlname))
        cfname := space(len(t999lst->tfname))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar()=="CEDPCODE",vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Schedule Code  :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
                @ 04,02 say "Instructors Starting Name Printed :" color memvar->colorarray[02]
                @ 05,05 say "Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 06,05 say "First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(cedpcode) == "ALL"
                        if ! cyytskdp->(dbseek(cedpcode))
                                fask(10,"   Schedule code "+cedpcode+" does not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        if cyytskdp->skdsplcod == "C" /* .and. cyytskdp->skdsubtyp == "LEC" */
                                fask(10,"  Schedule code "+cedpcode+" is continuation code.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                        nunits    := cyytskdp->skdunt
                        c999crsp->(dbseek(cyytskdp->skdintcod))
                        cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                        if t999lst->(dbseek(cyytskdp->skdinscod))
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                        else
                                cinscode := space(06)
                                cinsname := space(30)
                        endif
                        if cyytskdp->skdsplcod == "S"
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                ccedpcode := cyytskdp->skdcod
                                ncunits   := cyytskdp->skdunt
                                ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        else
                                cskdcont  := " "
                                ccedpcode := " "
                                ncunits   := 0
                                ccsubject := " "
                        endif
                        if whereprint({||pgradesheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,10)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||pallgradesheet(cdesc,clname,cfname)}) == 1
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

static function pgradesheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,npost)
local nctr := 0, cskdno, npage := 0, nline := 0
grdshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits)
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
        fask(npost,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        outexpr(prow()+01,05,transform(++nctr,"@Z 999")+"."+space(02)+;
                             cyytenrr->enridno+space(02)+;
                             c999sm1p->sm1lstnam+space(01)+;
                             c999sm1p->sm1fstnam+space(01)+;
                             c999sm1p->sm1midnam+space(02)+;
                             c999colp->coldesabr+;
                             cyytenrr->enryrlevl+space(01)+;
                             replicate("_",34))
        if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                outexpr(prow()+00,82,"W I T H D R A W N")
        elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                outexpr(prow()+00,82,"G R A D U A T I N G")
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrr->(dbskip())
        if ++nline == 53 .and. ! cyytenrr->(eof())
                outexpr(prow()+00,00,chr(18))
                __eject()
                grdshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits)
                nline := 0
        endif
enddo
cyytenrr->(clearscope())
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

static function grdshtheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,npage,ccedpcode,ccsubject,ncunits)
setprc(00,00)
outexpr(00,03,cinscode)
outexpr(00,11,cinsname)
outexpr(00,96,alltrim(cdesc))
outexpr(00,130,strzero(npage,2))
outexpr(03,03,cedpcode)
outexpr(03,11,csubject)
outexpr(03,30,cschedule)
outexpr(03,55,transform(nunits,"@Z 99.9"))
outexpr(03,70,cdesctitle)
outexpr(04,03,ccedpcode)
outexpr(04,11,ccsubject)
outexpr(04,30,cskdcont)
outexpr(04,55,transform(ncunits,"@Z 99.9"))
outexpr(06,00,"")
return(nil)


static function pallgradesheet(cdesc,clname,cfname)
local cinscode:=" ",cinsname:=" ",cedpcode:=" ",csubject:=" ",cschedule:=" ",;
      nunits:=0,cdesctitle:=" ",cskdcont:=" ",npage:=0,ccedpcode,;
      ccsubject:=" ",ncunits:=0,nrec

t999lst->(sx_settagorder(2))
cyytskdp->(sx_settagorder(6))

t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" .and. (alltrim(t999lst->tlname)+alltrim(t999lst->tfname)) >= (alltrim(clname)+alltrim(cfname))
                fask(06,"  Processing name "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        npage := 0
                        fask(12,"  Processing code "+alltrim(cyytskdp->skdcod)+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! cyytskdp->skdsplcod == "C"
                                cedpcode  := cyytskdp->skdcod
                                csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                nunits    := cyytskdp->skdunt
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                                if cyytskdp->skdsplcod == "S"
                                        nrec := cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                        ccedpcode := cyytskdp->skdcod
                                        ncunits   := cyytskdp->skdunt
                                        ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                        cyytskdp->(dbgoto(nrec))
                                        cyytskdp->(sx_settagorder(6))
                                else
                                        cskdcont  := " "
                                        ccedpcode := " "
                                        ncunits   := 0
                                        ccsubject := " "
                                endif
                                **Printing**
                                pgradesheet(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,18)
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                enddo
        endif
        cyytskdp->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
cyytskdp->(sx_settagorder(1))
return(nil)

*------------------------------------------------------------------------------*

function form19()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,cyytenrp,cyytskdp,cyytstsp,aentryscr,;
      bprint,cprocsts,cterm,cdesc,ccolcode,cyear,csex,cfile,ccdx,;
      clname,cfname,npage,nline
private cdummy := "form"+strzero(memvar->naccess,2), form19, sex19

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"     Form X1X Report     ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        cyytstsp := "c"+cterm+"stsp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,2},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "1"
        csex     := "B"
        clname   := space(15)
        cfname   := space(24)
        npage    := 0
        nctr     := 0
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-nautical, MG-marine]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                @ 04,23 say "[1 2 3 4 5  8-All]" color memvar->colorarray[02]
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        valid cyear $ "123458"
                @ 05,23 say "[M-ale, F-emale, B-oth]" color memvar->colorarray[02]
                @ 05,02 say "S e x          :";
                        color memvar->colorarray[02];
                        get csex        pict "@!";
                        valid csex $ "MFB"
                @ 06,02 say "Last Name Printed  :";
                        color memvar->colorarray[02];
                        get clname      pict "@!"
                @ 07,02 say "First Name Printed :";
                        color memvar->colorarray[02];
                        get cfname      pict "@!"
                @ 08,02 say "Last Page Printed  :";
                        color memvar->colorarray[02];
                        get npage       pict "999"
                @ 09,02 say "Last Line Printed  :";
                        color memvar->colorarray[02];
                        get nctr        pict "9999"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pform19(cterm,cdesc,ccolcode,cyear,csex,clname,cfname,npage,nctr)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"X"+".TXT"); ccdx := (memvar->cdummy+"X"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"S"+".TXT"); ccdx := (memvar->cdummy+"S"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function pform19(cterm,cdesc,ccolcode,cyear,csex,clname,cfname,npage,nctr)
local abtext := {},ncol,nmaxcol := 80, afile,;
      csexdesc,ccourse,nline,ncol1,ncol2,ncol3,cskdno,nctr1,ntotunits,;
      cgrade,nunits,lprint:=.f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"S",{{"YEAR"    ,"C",01,0},;
                                     {"SEX"     ,"C",01,0},;
                                     {"CDESC"   ,"C",30,0},;
                                     {"YDESC"   ,"C",11,0},;
                                     {"SDESC"   ,"C",09,0}},{||cdxsex19()}) .or.;
   ! createdummy(memvar->cdummy+"X",{{"IDNO"    ,"C",08,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",24,0},;
                                     {"MNAME"   ,"C",01,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"SEX"     ,"C",01,0},;
                                     {"ADDRESS" ,"C",30,0},;
                                     {"REMARKS" ,"C",19,0}},{||cdxform19()})
        dbcloseall()
        return(nil)
endif
memvar->form19 := memvar->cdummy+"X"
memvar->sex19  := memvar->cdummy+"S"
if(afile := openwcheck({{,,(memvar->form19+".TXT"),"form19",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->sex19+".TXT"),"sex19",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
form19->(__dbzap()); form19->(dbreindex())
sex19->(__dbzap()); sex19->(dbreindex())

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("PARDO - TALISAY",nmaxcol)-14)+;
                                              "PARDO - TALISAY"})
aadd(abtext,{||space(titlepos("FORM X1X",nmaxcol))+;
                              "FORM X1X"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||sex19->cdesc})
aadd(abtext,{||alltrim(sex19->ydesc)+" - "+sex19->sdesc})
aadd(abtext,{||replicate("-",81)})

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))
if ccolcode $ "NT,MG" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_settagorder(3))
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
elseif ! ccolcode $ "NT,MG" .and. cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
elseif ! ccolcode $ "NT,MG" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ccolcode == _NAUTICAL
                        if cyytenrp->enrcolcod $ "MT,MV,MS,PA,MI,YN,SN,BN,HN,NW,NV"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        if csex $ ("B"+c999sm1p->sm1sex)
                                                writedata1(ccolcode)
                                        endif
                                endif
                        endif
                case ccolcode == _MARINE
                        if cyytenrp->enrcolcod $ "MA,MM,MD,MP,MR,YM,SM,BM,HM,MW,NM"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        if csex $ ("B"+c999sm1p->sm1sex)
                                                writedata1(ccolcode)
                                        endif
                                endif
                        endif
                case cyytenrp->enrcolcod == ccolcode  //&&particular course
                        if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                if csex $ ("B"+c999sm1p->sm1sex)
                                        writedata1(ccolcode)
                                endif
                        endif
        endcase
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())

*------------------
*  Printing data  *
*------------------
cyytenrp->(sx_settagorder(1))
form19->(dbsetrelation("cyytenrp",{||form19->idno},"form19->idno"))
sex19->(dbgotop())
do while ! sex19->(eof())
        nline := 0
        lprint := .f.
        pageprint(abtext)
        form19->(sx_setscope(_TOP_SCOPE   ,sex19->year+sex19->sex))
        form19->(sx_setscope(_BOTTOM_SCOPE,sex19->year+sex19->sex))
        form19->(dbgotop())
        do while ! form19->(eof())
                ntotunits := 0
                fask(10,"  Processing name "+alltrim(form19->lname)+", "+alltrim(form19->fname)+" "+form19->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if (clname+cfname) < (form19->lname+form19->fname)
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+". "+;
                                             form19->lname+space(01)+;
                                             form19->fname+space(01)+;
                                             form19->mname+"."+space(06)+;
                                             "("+form19->idno+")")
                        outexpr(prow()+01,06,form19->address+space(19)+;
                                             form19->remarks)
                        nline2 := 0
                        ncol1  := 1
                        ncol2  := 06
                        ncol3  := 21
                        lprint := .t.
                        for nctr1 := 1 to 16
                                cgrade := space(03)
                                nunits := 0
                                cskdno := if(nctr1 < 10,"enrskd"+transform(nctr1,"9"),"enrskd"+transform(nctr1,"99"))
                                if ! cyytenrp->&cskdno == "00000"
                                        cyytskdp->(dbseek(cyytenrp->&cskdno))
                                        fask(16,"  Printing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                                cyytstsp->(dbseek(cyytenrp->&cskdno+form19->idno))
                                                if val(cyytstsp->stsfingrd) > 0
                                                        cgrade := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                                        if cyytstsp->stsfingrd <= "30"
                                                                nunits := cyytskdp->skdunt
                                                        endif
                                                else
                                                        cgrade := cyytstsp->stsfingrd+space(01)
                                                endif
                                                if ncol1 == 1
                                                        outexpr(prow()+01,ncol2,cyytskdp->skdsubcod+space(01)+;
                                                                                if(cyytskdp->skdsubtyp == "LEC"," ","L")+space(01)+;
                                                                                cgrade+space(01)+;
                                                                                transform(nunits,"99.9"))
                                                        outexpr(prow()+00,ncol3,"___")
                                                        ncol2 += 26
                                                        ncol3 += 26
                                                        ntotunits += nunits
                                                elseif str(ncol1,1) $ "23"
                                                        outexpr(prow()+00,ncol2,cyytskdp->skdsubcod+space(01)+;
                                                                                if(cyytskdp->skdsubtyp == "LEC"," ","L")+space(01)+;
                                                                                cgrade+space(01)+;
                                                                                transform(nunits,"99.9"))
                                                        outexpr(prow()+00,ncol3,"___")
                                                        ncol2 += 26
                                                        ncol3 += 26
                                                        ntotunits += nunits
                                                        if ncol1 == 3
                                                                ncol1  := 0
                                                                ncol2  := 06
                                                                ncol3  := 21
                                                        endif
                                                endif
                                                ++ncol1
                                        endif
                                else
                                        exit
                                endif
                        next
                        outexpr(prow()+01,50,"TOTAL UNITS EARNED : "+transform(ntotunits,"99.9"))
                        outexpr(prow()+01,00,replicate("-",81))
                endif
                if nextkey() == K_ESC
                        exit
                endif
                form19->(dbskip())
                if lprint
                        if substr(cterm,3,1) $ "12"
                                if ccolcode $ "MG,MA,MR,MP,RO"
                                        if ++nline == 6 .and. ! form19->(eof())
                                                __eject()
                                                pageprint(abtext)
                                                nline := 0
                                        endif
                                else
                                        if ++nline == 6 .and. ! form19->(eof())
                                                __eject()
                                                pageprint(abtext)
                                                nline := 0
                                        endif
                                endif
                        else
                                if ++nline == 8 .and. ! form19->(eof())
                                        __eject()
                                        pageprint(abtext)
                                        nline := 0
                                endif
                        endif
                endif
        enddo
        form19->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        sex19->(dbskip())
        if ! sex19->(eof())
                __eject()
                npage := 0
                nctr  := 0
        endif
enddo
__eject()
closewcheck(afile)
cyytenrp->(sx_settagorder(2))
return(nil)

static function cdxsex19()
field year,sex
private cdummyfile := alias()
index on year+sex tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function cdxform19()
field year,sex,lname,fname,mname
private cdummyfile := alias()
index on year+sex+lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function writedata1(ccolcode)
if ! sex19->(dbseek(cyytenrp->enryrlevl+c999sm1p->sm1sex))
        sex19->(dbappend())
        sex19->year   := cyytenrp->enryrlevl
        sex19->sex    := c999sm1p->sm1sex
//        sex19->cdesc  := if(ccolcode $ _NAUTICAL+_MARINE,c999colp->colnamcol,c999colp->coldesful)
        sex19->cdesc  := if(ccolcode == _NAUTICAL, "MARINE TRANSPORTAION",;
                         if(ccolcode == _MARINE  , "MARINE ENGINEERING  ",;
                                                    c999colp->coldesful))
        sex19->sdesc  := if(c999sm1p->sm1sex == "M","MALE(S)  ","FEMALE(S)")
        sex19->ydesc  := if(cyytenrp->enryrlevl == _FIRST_YEAR ,"FIRST YEAR ",;
                         if(cyytenrp->enryrlevl == _SECOND_YEAR,"SECOND YEAR",;
                         if(cyytenrp->enryrlevl == _THIRD_YEAR ,"THIRD YEAR ",;
                         if(cyytenrp->enryrlevl == _FOURTH_YEAR,"FOURTH YEAR",;
                                                                "FIFTH TEAR "))))
endif
form19->(dbappend())
form19->idno    := c999sm1p->sm1idno
form19->lname   := c999sm1p->sm1lstnam
form19->fname   := c999sm1p->sm1fstnam
form19->mname   := c999sm1p->sm1midnam
form19->year    := cyytenrp->enryrlevl
form19->sex     := c999sm1p->sm1sex
form19->address := if(!empty(c999sm1p->sm1homadr),c999sm1p->sm1homadr,"C/O TO REGISTRAR UC-PT      ")
form19->remarks := if(cyytenrp->enrenrst $ _WITHDRAW_BEFORE+_WITHDRAW_AFTER,"WITHDRAWN "+dtoc(cyytenrp->enrdte),space(19))
return(nil)

function vcollege(ccode,cprocsts)
if ccode $ "NT,MG,UC"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 03,23 say c999colp->coldesful+space(20)
return(.t.)

@ 03,23 say c999colp->coldesful+space(20)
return(.t.)

static function viewallgradefordistribution(ccode,cprocsts)
if ccode $ "NT,MG,CS,NN"
        return(.t.)
else
     fask(10,"  Invalid College Code "+ccode+" ...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
          return(.t.)     
endif



*------------------------------------------------------------------------------*

//FOR GRADUATED ALREADY(ALL COURSE)
function tor()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,bprint,cprocsts,cfile,ccdx,;
      cidno,cnceeper,cyrtaken,cexamno,cpurpose,n99,cbarhead,corno,cdategrad,;
      cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder,ladder,ctorcont,;
      ctordate,ctorserial,question := " "
private navfile:="reptor"+strzero(memvar->naccess,2),navtor,afile
if(aprvsetup := openwcheck({{,,"c999torp",,_DBF_SHARED,,1},;
                            {,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999grad",,_DBF_SHARED,,1},;
                            {,,"oldcuraj",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"blocklst",,_DBF_SHARED,,1},;
                            {,,"torcont",,_DBF_SHARED,,1},;
                            {,,"PARA",,_DBF_SHARED,,},;
                            {,,"tor_log",,_DBF_SHARED,,5},;
                            {,,"c999sm2p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Transcript of Record Printing (Graduated Already)  ")
commandline("³           F4 - View Student          ³              ESC - Previous           ³")
aentryscr := savescr(01,00,24,79)

//fask(10,"  User level ==> "+memvar->clevel+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

if ! alltrim(memvar->clevel) == "P"
        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")
//        fask(10,"  TOR Serial: "+LEFT(ctorcont,7)+" <----- ",{" Ok "},memvar->colorarray[05],.t.,nil)
        para->(reclock())
        para->torserial      := LEFT(ctorcont,7)
        para->(dbcommit())
        para->(dbunlock())
else
        ctorcont  := "SN#"
endif

cidno     := space(len(c999sm1p->sm1idno))
cnceeper  := "N.A."
cyrtaken  := "N.A."
cexamno   := "N.A.      "
//cpurpose  := "FOR EVALUATION"+space(36)
cpurpose  := ""+space(36)
cprepared := memvar->cuserfname + space(30-len(memvar->cuserfname))
cchecked  := ""+space(35)



cflag     := " "
sporderno := space(20)
sporderdte:= ctod("  /  /  ")
seriesno  := space(4)
ladder    := space(1)
nstpact   := space(20)
ctordate  := ctod("  /  /  ")
ctorserial:= space(8)
cregistrar:= ""+space(35)
cposition := "REGISTRAR"+space(11)

create_navfile()
do while .t.
        sporder := 0
        navtor->(__dbzap());navtor->(dbreindex())
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number        :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)

        @ 03,02 say "TOR Serial Number     :";
                color memvar->colorarray[02];
                get ctorserial
        read
        if lastkey() == K_ESC
                exit
        endif
        if !c999sm1p->(dbseek(cidno))
                fask(10,"  Student Number : "+cidno+" not found  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if blocklst->(dbseek(cidno)) .and. (blocklst->blkreason != "BOUNCING CHECK")
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif

        if c999sm2p->(dbseek(cidno))
                corno      := c999sm2p->sm2paynum
                cdategrad  := c999sm2p->sm2dgradas
                //cdategrad1 := c999sm2p->sm2dgradbs
                cdateadmit := c999sm2p->sm2dadmit
                chonrec    := c999sm2p->sm2honors
                sporderno  := c999sm2p->sm2sono
                sporderdte := c999sm2p->sm2sodate
                seriesno   := c999sm2p->sm2series
        else
                c999sm2p->(dbappend())
                c999sm2p->sm2idno := cidno
                corno     := space(10)
                cdategrad := ctod("  /  /  ")
                cdategrad1:= ctod("  /  /  ")
                cdateadmit:= ctod("  /  /  ")
                chonrec   := space(20)
                sporderno := space(20)
                sporderdte:= ctod("  /  /  ")
                seriesno  := space(4)
        endif

        if tor_log->(dbseek(cidno+LEFT(ctorserial,7)))
            cpurpose := tor_log->purpose        
        else
            cpurpose := space(30)
        endif

        @ 04,02 say "NCEE Percentile       :";
                color memvar->colorarray[02];
                get cnceeper    pict "@!"
        @ 05,02 say "Year Taken            :";
                color memvar->colorarray[02];
                get cyrtaken    pict "@!"
        @ 06,02 say "Examinee Number       :";
                color memvar->colorarray[02];
                get cexamno     pict "@!"
        @ 07,02 say "Purpose               :";
                color memvar->colorarray[02];
                get cpurpose    pict "@!"
        @ 08,02 say "Prepared by           :";
                color memvar->colorarray[02];
                get cprepared   pict "@!"
        @ 09,02 say "Noted by              :";
                color memvar->colorarray[02];
                get cchecked    pict "@!";
                valid !empty(cchecked)

        @ 10,02 say "Registrar Head        :";
                color memvar->colorarray[02];
                get cregistrar    pict "@!";
                valid !empty(cregistrar)

        @ 11,02 say "Payment Number        :";
                color memvar->colorarray[02];
                get corno       pict "@!"
        @ 12,02 say "Date Graduated       :";
                color memvar->colorarray[02];
                get cdategrad   //pict "@!"
      
        @ 13,02 say "Date Admitted         :";
                color memvar->colorarray[02];
                get cdateadmit   //pict "@!"
        @ 14,02 say "Honor Received        :";
                color memvar->colorarray[02];
                get chonrec   pict "@!"

        @ 15,02 say "Special Order No.     :";
                color memvar->colorarray[02];
                get sporderno pict "@!"
        @ 16,02 say "Dated                 :";
                color memvar->colorarray[02];
                get sporderdte //pict "@!"
        @ 17,02 say "Series of             :";
                color memvar->colorarray[02];
                get seriesno pict "@!"
        @ 18,02 say "NSTP Serial No.       :";
                color memvar->colorarray[02];
                get nstpact pict "@!";
                
        @ 19,02 say "TOR Date              :";
                color memvar->colorarray[02];
                get ctordate
  
        
        @ 20,02 say "            [ 1-W/out Autonomous|2-W/Autonomous|3-Pacucoa|4-W/out STCW|5-SO ]" color memvar->colorarray[02]
        @ 21,02 say "Phrase To Put :";
                color memvar->colorarray[02];
                get question pict "@!";
                valid question $ "12345"
        read


        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")

        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        nptor(cidno) //&& additional function for millennium compliance

        if c999sm2p->(dbseek(cidno))
                c999sm2p->(reclock()) //update c999sm2p data
                c999sm2p->sm2paynum := corno
                c999sm2p->sm2dgradas := cdategrad
                //c999sm2p->sm2dgradbs := cdategrad1
                c999sm2p->sm2dadmit  := cdateadmit
                c999sm2p->sm2honors  := chonrec
                c999sm2p->sm2sono    := sporderno
                c999sm2p->sm2sodate  := sporderdte
                c999sm2p->sm2series  := seriesno
                c999sm2p->(dbcommit())
                c999sm2p->(dbunlock())
        endif

        tor_log->(recycle()) //INSERT
        tor_log->studidno     := cidno
        tor_log->purpose      := cpurpose
        tor_log->date         := ctordate
        tor_log->preparedby   := cprepared
        tor_log->paynum       := corno
        tor_log->serial       := LEFT(ctorcont,7)
        tor_log->(dbcommit())
        tor_log->(dbunlock())

        if ! alltrim(memvar->clevel) == "P"
                torcont->(dbappend())
                torcont->torserial   := ctorcont
                torcont->toridno     := cidno
                torcont->tordate     := date()
                torcont->rectrail    := dtoc(date())+","+time()+","+memvar->cusername
                torcont->(dbcommit())
                torcont->(dbunlock())
        endif

       

        if whereprint({||ptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition,question)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                 viewtextfile()
        endif
enddo
restscr(alastscr)
closewcheck(aprvsetup)
navtor->(dbclosearea())
memvar->navfile+=".*"
ferase(memvar->navfile)
return(nil)


//TRANSCRIPT OF RECORD PRINTING FOR GRADUATED ALREADY
function ptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition,question)
local afile,nline := 0, nctr := 0, nctrunt := 0, cnterm:=space(3), lterm:=space(3), ;
      cintcod,cfingrd,ccomgrd,ctrmdesc,ncredit:=0,ccredit:=space(3),yrlevel:=" ",;
      bgrad := 0, cint_cod, nunit := 0, addunit := 0, ccors, npage := 1, srchvess := 0, cyytappp, apterm, tempasm := 0, tempasy := 0, tempbsm := 0,tempby := 0, totalas := 0, totalbs := 0



torfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
torheader()

navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))

navtor->(dbgotop())
do while ! empty(navtor->torintcd01) .and. ! navtor->(eof())
        lterm := right(navtor->torschtrm,3)
        navtor->(dbskip())
enddo


navtor->(dbgotop())
do while ! navtor->(eof())
        yrlevel := navtor->toryrlevl
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.F.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := alltrim(if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "A","FIRST "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "B","SECOND "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "C","THIRD "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1))))))))+;
                    if(!empty(alltrim(navtor->torinst))," w/ PERMIT","")
        if (prow() >= 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                tefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
        endif

           if !empty(navtor->torinst)
                   @ prow()+01,18 say alltrim(navtor->torinst)
                   @ prow()+00,18 say replicate("_",len(alltrim(navtor->torinst)))
           endif
           @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
           @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))


        for nctr := 1 to 20 
                nctrunt := 1
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                addunit := 0
                if oldcuraj->(dbseek(navtor->&cintcod))
                        addunit := 1
                        for nctrunt := 1 to 19
                            cint_cod := "torintcd"+strzero(nctrunt,2)
                            if navtor->&cint_cod == oldcuraj->courslcod
                                addunit := 0
                                exit
                            endif
                        next
                endif
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                        nunit := c999crsp->crscreunt
                        if addunit == 1
                           nunit += 1
                        endif
                      //  if prow() > 50
                        if prow() >= 39
                                footline()
                                tefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                                torheader()

                                @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                               
                        endif
                        
                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1
                        if ! empty(c999crsp->crsdsc2)
                            @ prow()+01,18 say c999crsp->crsdsc2
                        endif
                        if ! empty(c999crsp->crsdsc3)
                            @ prow()+01,18 say c999crsp->crsdsc3
                        endif
                        if ! empty(c999crsp->crsdsc4)
                           @ prow()+01,18 say c999crsp->crsdsc4
                        endif
                        @ prow()+00,57 say ;
                        if(empty(navtor->&cfingrd),"---",;
                        if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                        if(empty(navtor->&ccomgrd),"   ",;
                        if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                        if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
                        if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))
                else
                        exit
                endif
        next

        if nextkey() == K_ESC
                exit
        endif
        ccors := c999colp->colcod
        navtor->(dbskip())

enddo
navtor->(clearscope())



if !empty(nstpact)
        outexpr(prow()+01,02,"NSTP SERIAL NO. "+alltrim(nstpact)+" ")
        outexpr(prow()+01,02," ")        
endif


        //CHECK IF BUTANGAN OG STCW 
        if (question == "1")
      

            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE")
            outexpr(prow()+01,02,if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
            outexpr(prow()+01,02,"OF "+format_date(cdategrad)+" MEETING THE REQUIREMENTS OF THE 2010 MANILA AMENDMENTS ")
            outexpr(prow()+01,02,"TO THE 1978 STCW CONVENTION AND CODE AS AMENDED. PACUCOA ACCREDITED ")
            outexpr(prow()+01,02,"EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER. ")

       elseif (question == "2")
      

            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE")
            outexpr(prow()+01,02,if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
            outexpr(prow()+01,02,"OF "+format_date(cdategrad)+" MEETING THE REQUIREMENTS OF THE 2010 MANILA AMENDMENTS ")
            outexpr(prow()+01,02,"TO THE 1978 STCW CONVENTION AND CODE AS AMENDED. EXEMPTED FROM THE ISSUANCE ")
            outexpr(prow()+01,02,"OF SPECIAL ORDER GRANTED AUTONOMOUS STATUS PER COMMISSION ON HIGHER ")
            outexpr(prow()+01,02,"EDUCATION MEMORANDUM ORDER (CMO) 12, SERIES 2019." )

        elseif (question == "3") 

            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE")
            outexpr(prow()+01,02,if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
            outexpr(prow()+01,02,"OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF ")
            outexpr(prow()+01,02,"SPECIAL ORDER. " )

        elseif (question == "4")

            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE")
            outexpr(prow()+01,02,if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
            outexpr(prow()+01,02,"OF "+format_date(cdategrad)+" EXEMPTED FROM THE ISSUANCE ")
            outexpr(prow()+01,02,"OF SPECIAL ORDER GRANTED AUTONOMOUS STATUS PER COMMISSION ON HIGHER ")
            outexpr(prow()+01,02,"EDUCATION MEMORANDUM ORDER (CMO) 12, SERIES 2019." )

        elseif (question == "5")

            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE "+if(left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+ " OF ")
            outexpr(prow()+01,02,"(" +alltrim(c999colp->colnamabr2)+ ") "+alltrim(c999colp->colnamdeg) +" AS OF "+format_date(cdategrad))
            outexpr(prow()+01,02,"PER SPECIAL ORDER (R-VII) NO. "+alltrim(sporderno)+"S. "+alltrim(seriesno)+" DATED "+format_date(sporderdte)  )
            outexpr(prow()+01,02,"ISSUED BY THE COMMISSION ON HIGHER EDUCATION CENTRAL VISAYAS AREA CEBU CITY.")
            /* outexpr(prow()+01,02,"CENTRAL VISAYAS AREA CEBU CITY.") */

        /*
            outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol))
            outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg))
            outexpr(prow()+01,02,"("+alltrim(c999colp->colnamabr2)+") AS OF "+format_date(cdategrad) + " PER SPECIAL ORDER (R-VII) NO. "+alltrim(sporderno))
            outexpr(prow()+01,02,"S. "+alltrim(seriesno)+" DATED "+format_date(sporderdte)+" ISSUED BY THE COMMISSION ON HIGHER EDUCATION ")
            outexpr(prow()+01,02,"CENTRAL VISAYAS AREA CEBU CITY.") 
        */

        endif


        outexpr(prow()+01,02,replicate("-",74))
        outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")

        tefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
return(nil)

static function torfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,ctorcont,cregistrar,cposition)
ccolcod := space(2)



headeject()
setprc(00,00)
outexpr(prow()+06,02,"NAME              :")



outexpr(prow()+00,22,alltrim(strtran(c999sm1p->sm1lstnam,"¥",chr(165)))+", "+alltrim(strtran(c999sm1p->sm1fstnam,"¥",chr(165)))+" "+   ;
        if(!empty(c999sm1p->sm1midname),strtran(c999sm1p->sm1midname,"¥",chr(165)),                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
outexpr(prow()+01,02,"STUDENT NUMBER    :")
outexpr(prow()+00,22,cidno)
outexpr(prow()+01,02,"SEX               :")
outexpr(prow()+00,22,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
outexpr(prow()+01,02,"CIVIL STATUS      :")
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,22,if(c999sm2p->sm2civsts $ "S ","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE        :")
outexpr(prow()+00,22,format_date(c999sm2p->sm2birdte))
outexpr(prow()+01,02,"BIRTHPLACE        :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY       :")
outexpr(prow()+00,22,c999sm2p->sm2nat)
outexpr(prow()+01,02,"RELIGION          :")
outexpr(prow()+00,22,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN   :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS :")         
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),strtran(c999sm1p->sm1homadr,"¥",chr(165)),"C/O REGISTRAR, UC-PT"))
if(!empty(c999sm1p->sm1homadr2))
        outexpr(prow()+01,02,"                  :")
        outexpr(prow()+00,22,strtran(c999sm1p->sm1homadr2,"¥",chr(165)))
endif
outexpr(prow()+01,02,"DATE ADMITTED     :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,22,format_date(cdateadmit))
outexpr(prow()+01,02,"COLLEGE OF        :")
c999colp->(dbseek(c999sm1p->sm1colcod))
ccolcod := c999sm1p->sm1colcod
outexpr(prow()+00,22,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA     :")
outexpr(prow()+00,22,c999sm2p->sm2entdat)

outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY  :");outexpr(prow()+00,16,trim(c999sm2p->sm2prisc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2priyr)

outexpr(prow()+01,02,"HIGH SCHOOL :");outexpr(prow()+00,16,trim(c999sm2p->sm2secsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH :");outexpr(prow()+00,16,trim(c999sm2p->sm2sh),49)
    outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif


outexpr(prow()+01,02,"COLLEGE     :");outexpr(prow()+00,16,trim(c999sm2p->sm2colsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+01,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")


tefooter2(1,cpurpose,corno,ctorcont)
return(nil)
//end of ptor function



static function torfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
headeject()
setprc(00,00)
outexpr(prow()+06,02,"NAME              :")
outexpr(prow()+00,22,alltrim(strtran(c999sm1p->sm1lstnam,"¥",chr(165)))+", "+alltrim(strtran(c999sm1p->sm1fstnam,"¥",chr(165)))+" "+   ;
        if(!empty(c999sm1p->sm1midname),strtran(c999sm1p->sm1midname,"¥",chr(165)),                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
outexpr(prow()+01,02,"STUDENT NUMBER    :")
outexpr(prow()+00,22,cidno)
outexpr(prow()+01,02,"SEX               :")
outexpr(prow()+00,22,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
outexpr(prow()+01,02,"CIVIL STATUS      :")
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,22,if(c999sm2p->sm2civsts $ "S ","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE        :")
outexpr(prow()+00,22,format_date(c999sm2p->sm2birdte))
outexpr(prow()+01,02,"BIRTHPLACE        :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY       :")
outexpr(prow()+00,22,c999sm2p->sm2nat)
outexpr(prow()+01,02,"RELIGION          :")
outexpr(prow()+00,22,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN   :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS :")         
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),strtran(c999sm1p->sm1homadr,"¥",chr(165)),"C/O REGISTRAR, UC-PT"))
if(!empty(c999sm1p->sm1homadr2))
        outexpr(prow()+01,02,"                  :")
        outexpr(prow()+00,22,strtran(c999sm1p->sm1homadr2,"¥",chr(165)))
endif
outexpr(prow()+01,02,"DATE ADMITTED     :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,22,format_date(cdateadmit))
outexpr(prow()+01,02,"COLLEGE OF        :")
c999colp->(dbseek(c999sm1p->sm1colcod))
outexpr(prow()+00,22,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA     :")
outexpr(prow()+00,22,c999sm2p->sm2entdat)

outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY  :");outexpr(prow()+00,16,trim(c999sm2p->sm2prisc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2priyr)
outexpr(prow()+01,02,"HIGH SCHOOL :");outexpr(prow()+00,16,trim(c999sm2p->sm2secsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH :");outexpr(prow()+00,16,trim(c999sm2p->sm2sh),49)
    outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif

outexpr(prow()+01,02,"COLLEGE     :");outexpr(prow()+00,16,trim(c999sm2p->sm2colsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+01,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")
tefooter2(1,cpurpose,corno,ctorcont,ctordate)
return(nil)

//function para UC-MAIN NGA GE REKLAMO SA GOBYERNO
static function kaduhangtorfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
headeject()
setprc(00,00)
outexpr(prow()+06,02,"NAME              :")
outexpr(prow()+00,22,alltrim(strtran(c999sm1p->sm1lstnam,"¥",chr(165)))+", "+alltrim(strtran(c999sm1p->sm1fstnam,"¥",chr(165)))+" "+   ;
        if(!empty(c999sm1p->sm1midname),strtran(c999sm1p->sm1midname,"¥",chr(165)),                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
outexpr(prow()+01,02,"STUDENT NUMBER    :")
outexpr(prow()+00,22,cidno)
outexpr(prow()+01,02,"SEX               :")
outexpr(prow()+00,22,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
outexpr(prow()+01,02,"CIVIL STATUS      :")
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,22,if(c999sm2p->sm2civsts $ "S ","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE        :")
outexpr(prow()+00,22,format_date(c999sm2p->sm2birdte))
outexpr(prow()+01,02,"BIRTHPLACE        :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY       :")
outexpr(prow()+00,22,c999sm2p->sm2nat)
outexpr(prow()+01,02,"RELIGION          :")
outexpr(prow()+00,22,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN   :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS :")         
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),strtran(c999sm1p->sm1homadr,"¥",chr(165)),"C/O REGISTRAR, UC-PT"))
if(!empty(c999sm1p->sm1homadr2))
        outexpr(prow()+01,02,"                  :")
        outexpr(prow()+00,22,strtran(c999sm1p->sm1homadr2,"¥",chr(165)))
endif
outexpr(prow()+01,02,"DATE ADMITTED     :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,22,format_date(cdateadmit))
outexpr(prow()+01,02,"COLLEGE OF        :")
c999colp->(dbseek(c999sm1p->sm1colcod))
outexpr(prow()+00,22,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA     :")
outexpr(prow()+00,22,c999sm2p->sm2entdat)

outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY  :");outexpr(prow()+00,16,trim(c999sm2p->sm2prisc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2priyr)
outexpr(prow()+01,02,"HIGH SCHOOL :");outexpr(prow()+00,16,trim(c999sm2p->sm2secsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH :");outexpr(prow()+00,16,trim(c999sm2p->sm2sh),49)
    outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif

outexpr(prow()+01,02,"COLLEGE     :");outexpr(prow()+00,16,trim(c999sm2p->sm2colsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+02,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")
kaduhatefooter2(1,cpurpose,corno,ctorcont,ctordate)
return(nil)


static function torheader()
headeject()
setprc(00,00)
//outexpr(prow()+02,02,"NAME:  (HP Laser Jet)
outexpr(prow()+06,02,"NAME:______________________________________________  STUDENT NO.:_________")
//outexpr(prow()+00,09,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+if(!empty(c999sm1p->sm1midnam),"."," "))

outexpr(prow()+00,08,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+   ;
        if(!empty(c999sm1p->sm1midname),c999sm1p->sm1midname,                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))

//outexpr(prow()+00,69,c999sm1p->sm1idno) (HP Laser Jet)
outexpr(prow()+00,68,c999sm1p->sm1idno)

outexpr(prow()+02,02,"--------------------------------------------------------------------------")
outexpr(prow()+01,02,"COURSE NO.      DESCRIPTIVE TITLES                    FINAL RE-EXAM CREDIT")
outexpr(prow()+01,02,"--------------------------------------------------------------------------")
return(nil)



static function torheader2(cGWA)
headeject()
setprc(00,00)
//outexpr(prow()+02,02,"NAME:  (HP Laser Jet)
outexpr(prow()+06,02,"NAME:______________________________________________  STUDENT NO.:_________")
//outexpr(prow()+00,09,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+if(!empty(c999sm1p->sm1midnam),"."," "))

outexpr(prow()+00,08,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+   ;
        if(!empty(c999sm1p->sm1midname),c999sm1p->sm1midname,                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))

//outexpr(prow()+00,69,c999sm1p->sm1idno) (HP Laser Jet)
outexpr(prow()+00,68,c999sm1p->sm1idno)

outexpr(prow()+02,02,if(cGWA=="Y",replicate("-",77),replicate("-",74)))
if cGWA == "Y"
        outexpr(prow()+01,02,"COURSE NO.      DESCRIPTIVE TITLES                    FINAL CREDIT EQUIVALENT")
else
        outexpr(prow()+01,02,"COURSE NO.      DESCRIPTIVE TITLES                    FINAL RE-EXAM CREDIT")
endif
outexpr(prow()+01,02,if(cGWA=="Y",replicate("-",77),replicate("-",74)))
return(nil)


static function tefooter1(npage,cpurpose,corno,ctorcont)
outexpr(55,02,"REMARKS:                                             DATE ISSUED:")
outexpr(55,11,cpurpose);outexpr(55,68,dtoc(date()))
outexpr(56,06,"NOT VALID WITHOUT SEAL")
outexpr(58,06,"    OR NO.__________                           JOVITA A. QUIÑANOLA   ")
outexpr(58,17,corno)
outexpr(58,49,"____________________________")
outexpr(59,06,"        PAGE "+str(npage,2)+"                                 REGISTRAR")
outexpr(60,06,"   SN: "+ctorcont)
__eject()
return(nil)




static function tefooter2(npage,cpurpose,corno,ctorcont,ctordate)
local i:=46
if ! (npage == 1)
        i+=1
endif

outexpr(49,02,"REMARKS:                                             DATE ISSUED:")
//outexpr(+00,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,(if(!empty(ctordate),ctordate,displaydate(date()))))
outexpr(prow()+01,02,"PREPARED BY                                          CHECKED BY ")
outexpr(prow()+01,02,cprepared)
outexpr(prow()+00,55,cchecked)

outexpr(prow()+01,27,"    "+cregistrar+"   ")
outexpr(prow()+00,27,"__________________________")
outexpr(prow()+01,27,"     CAMPUS REGISTRAR    ")
outexpr(prow()+01,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)


static function kaduhatefooter2(npage,cpurpose,corno,ctorcont,ctordate)
local i:=46
if ! (npage == 1)
        i+=1
endif
outexpr(48,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,(if(!empty(ctordate),ctordate,displaydate(date()))))
outexpr(prow()+02,02,"PREPARED BY                                          CHECKED BY ")
outexpr(prow()+02,02,cprepared)
outexpr(prow()+00,55,cchecked)
//outexpr(prow()+01,27,"   EDGAR  J. ESGUERRA   ")
outexpr(prow()+01,27,"     "+cregistrar+"   ")
outexpr(prow()+00,27,"__________________________")
outexpr(prow()+01,27,"      ASST. REGISTRAR    ")
outexpr(prow()+01,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
//outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)



static function tefoot(npage,cpurpose,corno,ctorcont,ccolcod)
local i:=46
if ! (npage == 1)
        i+=1
endif
outexpr(i,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
if ccolcod == "MI"
        outexpr(prow()+02,02,"PREPARED BY                                          CHECKED & VERIFIED BY ")
        outexpr(prow()+03,02,cprepared)
        outexpr(prow()+00,55,cchecked)
        outexpr(prow()+01,55,"___________________")
        outexpr(prow()+01,55,"  ASST. REGISTRAR  ")
elseif ccolcod == "MR"
        outexpr(prow()+02,02,"PREPARED BY                                          CHECKED & VERIFIED BY ")
        outexpr(prow()+03,02,cprepared)
        outexpr(prow()+00,55,cchecked)
        outexpr(prow()+01,55,"___________________")
        outexpr(prow()+01,55,"  ASST. REGISTRAR  ")
else
        outexpr(prow()+02,02,"PREPARED BY                                          CHECKED BY ")
        outexpr(prow()+03,02,cprepared)
        outexpr(prow()+00,55,cchecked)
        //outexpr(prow()+01,27,"  JOVITA  A. QUI¥ANOLA   ")
        outexpr(prow()+01,27,"     "+cregistrar+"   ")
        outexpr(prow()+00,27,"__________________________")
        outexpr(prow()+01,27,"      ASST. REGISTRAR    ")
endif
outexpr(prow()+02,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)

/*
static function tefoot(npage,cpurpose,corno,ctorcont)
local i:=46
if ! (npage == 1)
        i+=1
endif
outexpr(i,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
outexpr(prow()+02,02,"PREPARED BY                                          CHECKED & VERIFIED BY ")
outexpr(prow()+03,02,cprepared)
outexpr(prow()+00,55,cchecked)
outexpr(prow()+01,55,"___________________")
outexpr(prow()+01,55,"   REGISTRAR ")
outexpr(prow()+02,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)
*/

static function tefoot2(npage,cpurpose,corno,ctorcont)
local i:=46
if ! (npage == 1)
        i+=1
endif
outexpr(i,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
outexpr(prow()+02,02,"PREPARED BY                                          CHECKED BY ")
outexpr(prow()+03,02,cprepared)
outexpr(prow()+00,55,cchecked)
//outexpr(prow()+01,27,"  JOVITA  A. QUI¥ANOLA  ")
outexpr(prow()+01,27,"      "+cregistrar+"   ")
outexpr(prow()+00,27,"________________________")
outexpr(prow()+01,27,"      ASST. REGISTRAR    ")
outexpr(prow()+02,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)

//footer for evaluation
static function tefooter2A(npage,cpurpose,corno,ctorcont)
local i:=46

if ! (npage == 1)
        i+=1
endif
outexpr(i,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
outexpr(prow()+02,02,"PREPARED BY                                          CHECKED BY ")
outexpr(prow()+03,02,cprepared)
outexpr(prow()+00,55,cchecked)
outexpr(prow()+01,27,"      "+cregistrar+"   ")
outexpr(prow()+00,27,"__________________________")
outexpr(prow()+01,27,"      CAMPUS REGISTRAR    ")
outexpr(prow()+02,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()

return(nil)

static function headeject()
local nctr:=0
for nctr := 1 to 3
        outexpr(prow()+01,00,"")
next
return(nil)

static function headejectname()
local nctr:=0
for nctr := 1 to 3
        outexpr(prow()+01,00,"")
next
return(nil)

static function tehead2()
local nctr:=0
for nctr := 1 to 10
        outexpr(prow()+01,00,"")
next
return(nil)

static function footline()
outexpr(prow()+01,02,replicate("-",74))
outexpr(prow()+01,29,"(MORE ENTRIES NEXT PAGE)")
return(nil)

static function cdxtor()
field term,idno
private cdummyfile := alias()
index on term+idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

function foreval() //TOR FOR EVALUATION PRINTING
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,bprint,cprocsts,cfile,ccdx,ctorcont,;
      cidno,cnceeper,cyrtaken,cexamno,cpurpose,n99,cbarhead,corno,cdateadmit
private navfile:="reptor"+strzero(memvar->naccess,2),navtor,afile
if(aprvsetup := openwcheck({{,,"c999torp",,_DBF_SHARED,,1},;
                            {,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"oldcuraj",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"PARA",,_DBF_SHARED,,},;
                            {,,"c999sm2p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Transcript of Record Printing (For Evaluation)  ")
commandline("³           F4 - View Student          ³              ESC - Previous           ³")
aentryscr := savescr(01,00,24,79)

if ! alltrim(memvar->clevel) == "P"
        ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"
//        fask(10,"  TOR Serial: "+LEFT(ctorcont,7)+" <----- ",{" Ok "},memvar->colorarray[05],.t.,nil)
        para->(reclock())
        para->torserial      := LEFT(ctorcont,7)
        para->(dbcommit())
        para->(dbunlock())
else
        ctorcont  := "testingSN#"
endif

cidno     := space(len(c999sm1p->sm1idno))
cnceeper  := "N.A."
cyrtaken  := "N.A."
cexamno   := "N.A.      "
cpurpose  := "FOR EVALUATION"+space(36)
cprepared := memvar->cuserfname + space(30-len(memvar->cuserfname))
nstpact   := space(20)
//cprepared := "MARINES D. ROMANO"+space(13)
//cchecked  := "MARINES D. ROMANO"+space(11)
cchecked  := space(36)
//cchecked  := strtran(cchecked,"¥",chr(165)) 
//CHERELYN A. ROSARIO

//cregistrar:= "JOVITA A. QUIÑANOLA"+space(13)
//cregistrar:= "CHERELYN A. ROSARIO"+space(13)
cregistrar:= space(36)
corno     := space(10)
cdateadmit:= ctod("  /  /  ")
create_navfile()
cGWA := "N"
do while .t.
        navtor->(__dbzap());navtor->(dbreindex())
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number   :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)
        read
        if lastkey() == K_ESC
                exit
        endif
        if ! c999sm1p->(dbseek(cidno))
                fask(13,"     Student number "+alltrim(cidno)+" not exists...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if c999sm2p->(dbseek(cidno))
                corno      := c999sm2p->sm2paynum
                cdateadmit := c999sm2p->sm2dadmit
        else
                c999sm2p->(dbappend())
                c999sm2p->sm2idno := cidno
                corno     := space(10)
                cdateadmit:= ctod("  /  /  ")
        endif

        @ 03,02 say "NCEE Percentile  :";
                color memvar->colorarray[02];
                get cnceeper    pict "@!"
        @ 04,02 say "Year Taken       :";
                color memvar->colorarray[02];
                get cyrtaken    pict "@!"
        @ 05,02 say "Examinee Number  :";
                color memvar->colorarray[02];
                get cexamno     pict "@!"
        @ 06,02 say "Purpose          :";
                color memvar->colorarray[02];
                get cpurpose    pict "@!"
        @ 07,02 say "Prepared by      :";
                color memvar->colorarray[02];
                get cprepared   pict "@!"
        @ 08,02 say "Checked by         :";
                color memvar->colorarray[02];
                get cchecked   pict "@!"

        @ 09,02 say "Registrar Head    :";
                color memvar->colorarray[02];
                get cregistrar    pict "@!"
                //valid ! empty(cregistrar)

        @ 10,02 say "Payment Number   :";
                color memvar->colorarray[02];
                get corno       pict "@!"
        @ 11,02 say "Date Admitted    :";
                color memvar->colorarray[02];
                get cdateadmit  //pict "@!"
        @ 12,02 say "w/ Ave. (G.W.A.) :";
                color memvar->colorarray[02];
                get cGWA pict "Y";
                valid cGWA $ "YN"
        @ 13,02 say "NSTP Serial No.    :";
                color memvar->colorarray[02];
                get nstpact pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if c999sm2p->(dbseek(cidno))
                c999sm2p->(reclock())
                c999sm2p->sm2paynum := corno
                c999sm2p->sm2dadmit  := cdateadmit
                c999sm2p->(dbcommit())
                c999sm2p->(dbunlock())
        endif

        nptor(cidno)
        if whereprint({||pforeval(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,cGWA,ctorcont,nstpact)}) == 1
        //if whereprint({||ptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif


enddo

restscr(alastscr)
closewcheck(aprvsetup)
navtor->(dbclosearea())
memvar->navfile+=".*"
ferase(memvar->navfile)
return(nil)

*------------------------------------------------------------------------------*

function nptor(cidno)
local nctr := 0,cintcod,cfingrd,ccomgrd,cappgrd,cnavterm:=space(5)
c999torp->(sx_setscope(_TOP_SCOPE   ,cidno))
c999torp->(sx_setscope(_BOTTOM_SCOPE,cidno))
c999torp->(dbgotop())
do while ! c999torp->(eof())
        fask(10,"  Processing School Term"+c999torp->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(c999torp->torcolcod))
        term->(dbseek(c999torp->torschtrm))
             cnavterm:=modi_terms(c999torp->torschtrm)
             navtor->(dbappend())
             //navtor->(recycle())
             navtor->toridno   :=c999torp->toridno
             navtor->torschtrm :=cnavterm
             navtor->tordate   :=c999torp->tordate
             navtor->torcolcod :=c999torp->torcolcod
             navtor->toryrlevl :=c999torp->toryrlevl
             navtor->torinst   :=c999torp->torinst
 //change 20 to desire number of subject to display and go to create_navfile() ============================================================
			for nctr := 1 to 20 
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
             navtor->&cintcod  :=c999torp->&cintcod
             navtor->&cfingrd  :=c999torp->&cfingrd
             navtor->&ccomgrd  :=c999torp->&ccomgrd
            next nctr
        c999torp->(dbskip())
enddo
c999torp->(clearscope())
return(nil)

static function modi_terms(nterm)
local cnterm:=space(5)
      //if alltrim(nterm) == "001" .or. alltrim(nterm) == "002"
      if substr(nterm,1,1) == "0"
            cnterm:="20"
      elseif substr(nterm,1,1) == "1"
            cnterm:="21"
      elseif substr(nterm,1,1) == "2"
            cnterm:="22"
      elseif substr(nterm,1,1) == "3"
            cnterm:="23"
      elseif substr(nterm,1,1) == "4"
            cnterm:="24"
      elseif substr(nterm,1,1) == "5"
            cnterm:="25"
      elseif substr(nterm,1,1) == "6"
            cnterm:="26"
      else
            cnterm:="19"
      endif
     cnterm+=alltrim(nterm)
return(cnterm)

*------------------------------------------------------------------------------*

function pforeval(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,cGWA,ctorcont,nstpact)
local afile,nline := 0, npage := 01,nctr := 0,cnterm:=space(3),ccolcod:=space(2),;
      cintcod,cfingrd,ccomgrd,ctrmdesc, addunit:=0, nctrunt := 0, ntotunits, nAve, ntotequiv
/*
if ! alltrim(memvar->clevel) == "P"
        ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"
else
        ctorcont  := "testingSN#"
endif
*/
torfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,ctorcont)
torheader2(cGWA)
navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))

navtor->(dbgotop())
do while ! navtor->(eof())
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        ccolcod:=navtor->torcolcod
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "A","FIRST"+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "B","SECOND"+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "C","THIRD"+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1)))))))
//        if prow() > 51
        if prow() >= 39
                footline()
                if navtor->torcolcod $ "MIMR"
                        tefoot(++npage,cpurpose,corno,ctorcont,ccolcod)
                endif
                tefooter2A(++npage,cpurpose,corno,ctorcont)
                torheader2(cGWA)
        endif
        @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
        @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))

        if empty(navtor->torintcd01)
                c999torp->(dbseek(cidno+cnterm))
                @ prow()+01,02 say "NAME OF VESSEL     : "+c999torp->torvesname
                @ prow()+01,02 say "PROPRIETOR         : "+c999torp->torvesown
                @ prow()+01,02 say "GROSS TONS         : "+transform(c999torp->torgrston,"9,999,999.99")
                @ prow()+01,02 say "DATE OF EMBARKATION: "+upper(cmonth(c999torp->torembark))+str(day(c999torp->torembark))+","+str(year(c999torp->torembark))
                @ prow()+00,57 say if(empty(c999torp->torapgrd),"---"+space(10)+"20",;
                                   if(val(c999torp->torapgrd) > 0,;
                                   left(c999torp->torapgrd,1)+"."+right(c999torp->torapgrd,1)+space(11)+"20",c999torp->torapgrd))

//                @ prow()+00,71 say "18"
        endif

        ntotunits := nAve := ntotequiv := 0

        for nctr := 1 to 20 //melchor
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                addunit := 0
                if oldcuraj->(dbseek(navtor->&cintcod))
                        addunit := 1
                        for nctrunt := 1 to 19 //melchor
                            cint_cod := "torintcd"+strzero(nctrunt,2)
                            if navtor->&cint_cod == oldcuraj->courslcod
                                addunit := 0
                                exit
                            endif
                        next
                endif
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                        nunit := c999crsp->crscreunt
                        ntotunits += c999crsp->crscreunt
                        ntotequiv += val(left(navtor->&cfingrd,1))+val(right(navtor->&cfingrd,1))/10
                        nAve      += (val(left (navtor->&cfingrd,1))+val(right(navtor->&cfingrd,1))/10) ;
                                     * c999crsp->crscreunt

                        //fask(10,"  "+transform((val(left (navtor->&cfingrd,1))+val(right(navtor->&cfingrd,1))/10),"999.99")+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)


                        if addunit == 1
                           nunit += 1
                        endif
                      //  if prow() > 50
                        if prow() >= 39
                                footline()
                                if navtor->torcolcod $ "MIMR"
                                        tefoot(++npage,cpurpose,corno,ctorcont,ccolcod)
                                endif
                                tefooter2A(++npage,cpurpose,corno,ctorcont)
                                torheader2(cGWA)
                                @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                        endif

                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1

                       // @ prow()+01,18 say c999crsp->crsdsc2
                       // @ prow()+01,18 say c999crsp->crsdsc3
                       //@ prow()+01,18 say c999crsp->crsdsc4

                        
                        if ! empty(c999crsp->crsdsc2)
                             @ prow()+01,18 say c999crsp->crsdsc2
                        endif
                        if ! empty(c999crsp->crsdsc3)
                             @ prow()+01,18 say c999crsp->crsdsc3
                        endif
                        if ! empty(c999crsp->crsdsc4)
                             @ prow()+01,18 say c999crsp->crsdsc4
                        endif
                        

                        @ prow()+00,57 say if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(cGWA=="N",;
                                                        if(empty(navtor->&ccomgrd),"   ",;
                                                        if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2),"")+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31") ,;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))+;
                                                   if(cGWA=="Y",space(5)+transform((val(left(navtor->&cfingrd,1))+val(right(navtor->&cfingrd,1))/10)*c999crsp->crscreunt,"99.9"),"")        
                else
                        exit
                endif
        next
        if cGWA=="Y"
                @ prow()+01,55 say transform(nAve/ntotunits,"@Z 999.999")+space(3)+transform(ntotunits,"@Z 99.9")+space(4)+transform(nAve,"@Z 999.9")
        endif
        if nextkey() == K_ESC
                exit
        endif
        navtor->(dbskip())

       
enddo

navtor->(clearscope())

if !empty(nstpact)
        outexpr(prow()+01,02,"NSTP SERIAL NO. "+alltrim(nstpact)+" ")
        outexpr(prow()+01,02," ")        
endif

//navtor->(sx_SetTagOrder(1))
outexpr(prow()+01,02,replicate("-",74))
outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")
if navtor->torcolcod $ "MIMR"
        tefoot(++npage,cpurpose,corno,ctorcont,ccolcod)
endif
tefooter2A(++npage,cpurpose,corno,ctorcont)
return(nil)

static function endline(nline)
outexpr(++nline,04,replicate("-",74))
outexpr(++nline,29,"(MORE ENTRIES NEXT PAGE)")
return(nil)

*------------------------------------------------------------------------------*

function grdsubj()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytstsp,cyytskdp,aprv2setup,;
      cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinscode,cinsname,appby,subby

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cedpcode := space(05)
appby    := space(30)
subby    := space(30)
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing (by Subject)  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp := "c"+cterm+"skdp"
        cyytstsp := "c"+cterm+"stsp"
        if(aprv2setup := openwcheck({{,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,3}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vschedule({||__keyboard(chr(K_CTRL_LEFT)+cyytskdp->skdcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Schedule Code  :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
                @ 04,02 say "Submitted by  :";
                        color memvar->colorarray[02];
                        get subby    pict "@!";
                        
                @ 05,02 say "Approved by  :";
                        color memvar->colorarray[02];
                        get appby    pict "@!";
                        
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! cyytskdp->(dbseek(cedpcode))
                        fask(10,"   Schedule code "+cedpcode+" does not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                nunits    := cyytskdp->skdunt
                c999crsp->(dbseek(cyytskdp->skdintcod))
                cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                if t999lst->(dbseek(cyytskdp->skdinscod))
                        cinscode := t999lst->tidno
                        cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                else
                        cinscode := space(06)
                        cinsname := space(30)
                endif
                if whereprint({||pgrdsubj(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,subby,appby)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pgrdsubj(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,subby,appby)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("Grade Printing by Subject",nmaxcol))+;
                              "Grade Printing by Subject"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+cinscode+" - "+cinsname})
aadd(abtext,{||"Subject   : "+cedpcode+" - "+csubject+" "+cschedule+" "+transform(nunits,"99.9")})
aadd(abtext,{||"          : "+cdesctitle})
aadd(abtext,{||""})
aadd(abtext,{||"     ID No.      Last Name           First Name          M  Course/Yr  MG  FG"})
aadd(abtext,{||"    --------  ---------------  ------------------------  -  ---------  --  --"})

/*
     ID No.      Last Name           First Name          M  Course/Yr  MG  FG
    --------  ---------------  ------------------------  -  ---------  --  --
11. 12345678  123456789012345  123456789012345678901234  1  123456  1  11  11
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytstsp->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytstsp->(dbgotop())
do while ! cyytstsp->(eof())
        fask(10,"  Printing name "+alltrim(cyytstsp->stslstnam)+", "+alltrim(cyytstsp->stsfstnam)+" "+cyytstsp->stsmidnam+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        outexpr(prow()+01,00,transform(++nctr,"99")+"."+space(01)+;
                             cyytstsp->stsidno+space(02)+;
                             cyytstsp->stslstnam+space(02)+;
                             cyytstsp->stsfstnam+space(02)+;
                             cyytstsp->stsmidnam+space(02)+;
                             cyytstsp->stscourse+space(02)+;
                             cyytstsp->stsyrlevel+space(02)+;
                             cyytstsp->stsmidgrd+space(02)+;
                             cyytstsp->stsfingrd)
        if nextkey() == K_ESC
                exit
        endif
        cyytstsp->(dbskip())
enddo
cyytstsp->(clearscope())

/*
aadd(abtext,{||"Submitted by: "+subby})
aadd(abtext,{||" "})
aadd(abtext,{||"Approved by : "+appby})
aadd(abtext,{||" "})
*/

outexpr(prow()+01,00," ")
outexpr(prow()+01,00," ")
outexpr(prow()+01,00,"Submitted by: "+subby+" ")
outexpr(prow()+01,00," ")
outexpr(prow()+01,00," ")
outexpr(prow()+01,00,"Approved by : "+appby+" ")
outexpr(prow()+01,00,"             ---------------------")
outexpr(prow()+01,00,"               Dean/Chairperson")
outexpr(prow()+01,00," ")
outexpr(prow()+01,00,chr(18))



__eject()
return(nil)

*------------------------------------------------------------------------------*

function grdspecial()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      ccolcode,cyear,cgrade,cterm,cdesc,cscope,ctype,aprv1setup,aprv2setup,;
      bprint, cprocsts, cyytstsp, cyytenrp, cyytskdp, xyytstsp,xterm,xdesc,xyytskdp
private cdummy := "grdave"+strzero(memvar->naccess,2), grdave

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
xterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Compute Students Grade Average (Special)  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Current School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        @ 03,02 say "Previous School Term :";
                color memvar->colorarray[02];
                get xterm pict "@!";
                valid ! empty(xterm)
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
        cdesc := term->name
        if ! term->(dbseek(xterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        xdesc := term->name
        if ! file(alltrim("c"+xterm+"stsp.dbf"))
                fask(10,"  C"+xterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+xterm+"skdp.dbf"))
                fask(10,"  C"+xterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,29 say "- "+cdesc
        @ 03,29 say "- "+xdesc
        aentryscr := savescr(01,00,24,79)
        xyytstsp := alltrim("c"+xterm+"stsp")
        cyytenrp := alltrim("c"+cterm+"enrp")
        xyytskdp := alltrim("c"+xterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, xyytstsp ,"xyytstsp",_DBF_SHARED,,1},;
                                     {,, xyytskdp ,"xyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "1"
        cgrade   := "F"
        cscope   := "R"
        ctype    := "W"
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,23 say "[NT-nautical,MG-marine]" color memvar->colorarray[02]
                @ 04,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcode(ccolcode,cprocsts)
                @ 05,23 say "[1 2 3 4 5]" color memvar->colorarray[02]
                @ 05,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear  pict "@!";
                        valid cyear $ "12345"
                @ 06,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 06,02 say "Grade          :";
                        color memvar->colorarray[02];
                        get cgrade      pict "@!";
                        valid cgrade $ "MF"
                @ 07,23 say "[T-op100, D-eansLister, R-anking]" color memvar->colorarray[02]
                @ 07,02 say "Scope          :";
                        color memvar->colorarray[02];
                        get cscope      pict "@!";
                        valid cscope $ "DTR"
                @ 08,23 say "[P-GPA, W-GWA]" color memvar->colorarray[02]
                @ 08,02 say "Computation    :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "PW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ccolcode $ "NT,MG"
                        bprint := {||pgroupspecial(ccolcode,cyear,cgrade,cscope,ctype,cdesc,xdesc)}
                else
                        bprint := {||pindspecial(ccolcode,cyear,cgrade,cscope,ctype,cdesc,xdesc)}
                endif
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

function pindspecial(ccolcode,cyear,cgrade,cscope,ctype,cdesc,xdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == "1"
        cyeardesc := "FIRST YEAR"
elseif cyear == "2"
        cyeardesc := "SECOND YEAR"
elseif cyear == "3"
        cyeardesc := "THIRD YEAR"
elseif cyear == "4"
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("Students Ranking",nmaxcol))+;
                              "Students Ranking"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc+" - "+cgrdesc,nmaxcol))+cyeardesc+" - "+cgrdesc})
*aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||"Grade based on "+alltrim(xdesc)})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/


cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing id-no."+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        xyytstsp->(dbsetrelation("xyytskdp",{||xyytstsp->stsskdcod},"xyytstsp->stsskdcod"))
        xyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
        xyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
        xyytstsp->(dbgotop())
        do while ! xyytstsp->(eof())
                fask(16,"  Processing schedule no. "+xyytstsp->stsskdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if ! (xyytskdp->skdsplcod == "C" .and. xyytskdp->skdsubtyp == "LEC") .and.;
                   ! (xyytskdp->skdsplcod == "C" .and. xyytskdp->skdunt == 0)
                        do case
                                case cgrade == "M"
                                        if val(xyytstsp->stsmidgrd) > 0 .and. xyytstsp->stsmidgrd <= "30"
                                                if ctype == "P"  //&&GPA
                                                        ngvar := val(xyytstsp->stsmidgrd) / 10
                                                        ntgrade += ngvar
                                                elseif ctype == "W"  //&&GWA
                                                        ngvar   := val(xyytstsp->stsmidgrd) / 10
                                                        nequi   := ngvar * xyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += xyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                                case cgrade == "F"
                                        if val(xyytstsp->stsfingrd) > 0 .and. xyytstsp->stsfingrd <= "30"
                                                if ctype == "P"  //&&GPA
                                                        ntgrade += (val(xyytstsp->stsfingrd) / 10)
                                                else // &&GWA
                                                        nequi   := (val(xyytstsp->stsfingrd) / 10) * xyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += xyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                        endcase
                endif
                xyytstsp->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
        enddo
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(ccolcode))
                grdave->course  := c999colp->coldesabr
                if ctype == "P"  //&&GPA
                        grdave->grade := ntgrade / nctr
                else // &&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        xyytstsp->(clearscope())
        xyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

*------------------------------------------------------------------------------*

function pgroupspecial(ccolcode,cyear,cgrade,cscope,ctype,cdesc,xdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc, ccolgroup

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == _FIRST_YEAR
        cyeardesc := "FIRST YEAR"
elseif cyear == _SECOND_YEAR
        cyeardesc := "SECOND YEAR"
elseif cyear == _THIRD_YEAR
        cyeardesc := "THIRD YEAR"
elseif cyear == _FOURTH_YEAR
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("Students Ranking",nmaxcol))+;
                              "Students Ranking"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc+" - "+cgrdesc,nmaxcol))+cyeardesc+" - "+cgrdesc})
*aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||"Grade based on "+alltrim(xdesc)})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR - BS MARINE ENGINEERING

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/

if ccolcode == _NAUTICAL
        ccolgroup := "MSMIMTPA"
elseif ccolcode == _MARINE
        ccolgroup := "MAMRMP"
endif

cyytenrp->(sx_settagorder(3))
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing idno. "+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrp->enrcolcod $ ccolgroup
                xyytstsp->(dbsetrelation("xyytskdp",{||xyytstsp->stsskdcod},"xyytstsp->stsskdcod"))
                xyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
                xyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
                xyytstsp->(dbgotop())
                do while ! xyytstsp->(eof())
                        fask(16,"  Processing schedule no. "+xyytstsp->stsskdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! (xyytskdp->skdsplcod == "C" .and. xyytskdp->skdsubtyp == "LEC") .and.;
                           ! (xyytskdp->skdsplcod == "C" .and. xyytskdp->skdunt == 0)
                                do case
                                        case cgrade == "M"
                                                if val(xyytstsp->stsmidgrd) > 0 .and. xyytstsp->stsmidgrd <= "30"
                                                        if ctype == "P"  //&&GPA
                                                                ngvar := val(xyytstsp->stsmidgrd) / 10
                                                                ntgrade += ngvar
                                                        elseif ctype == "W" // &&GWA
                                                                ngvar   := val(xyytstsp->stsmidgrd) / 10
                                                                nequi   := ngvar * xyytskdp->skdunt
                                                                ntequi  += nequi
                                                                ntunits += xyytskdp->skdunt
                                                        endif
                                                        lprocess := .t.
                                                        ++nctr
                                                else
                                                        lprocess := .f.
                                                        exit
                                                endif
                                        case cgrade == "F"
                                                if val(xyytstsp->stsfingrd) > 0 .and. xyytstsp->stsfingrd <= "30"
                                                        if ctype == "P"  //&&GPA
                                                                ntgrade += (val(xyytstsp->stsfingrd) / 10)
                                                        else  //&&GWA
                                                                nequi   := (val(xyytstsp->stsfingrd) / 10) * xyytskdp->skdunt
                                                                ntequi  += nequi
                                                                ntunits += xyytskdp->skdunt
                                                        endif
                                                        lprocess := .t.
                                                        ++nctr
                                                else
                                                        lprocess := .f.
                                                        exit
                                                endif
                                endcase
                        endif
                        xyytstsp->(dbskip())
                        if nextkey() == K_ESC
                                exit
                        endif
                enddo
        endif
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(cyytenrp->enrcolcod))
                grdave->course  := c999colp->coldesabr
                if ctype == "P"  //&&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        xyytstsp->(clearscope())
        xyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

*------------------------------------------------------------------------------*



*------------------------------------------------------------------------------*

function failgrade()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,cyytenrp,cyytskdp,cyytstsp,aentryscr,;
      bprint,cprocsts,cterm,cdesc,ccolcode,cyear,cfile,ccdx,;
      clname,cfname,cperiod,nctr,npage
private cdummy := "fail"+strzero(memvar->naccess,2),failed

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Students with Failing Grades Report  ")
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
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        cyytstsp := "c"+cterm+"stsp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "8"
        clname   := space(15)
        cfname   := space(24)
        cperiod  := "M"
        nctr := npage := 0
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                     [NT-nautical, MG-marine, UC-All]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                @ 04,02 say "                     [1 2 3 4 5  8-All]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        valid cyear $ "123458"
                @ 05,02 say "                     [M-idterm, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Period       :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "MF"
                @ 06,02 say "Students Name Last Printed:" color memvar->colorarray[02]
                @ 07,02 say "     Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 08,02 say "     First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
                @ 09,02 say "     Last Line  :";
                        color memvar->colorarray[02];
                        get nctr pict "9999"
                @ 10,02 say "     Last Page  :";
                        color memvar->colorarray[02];
                        get npage pict "999"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pfailgrade(cterm,cdesc,ccolcode,cyear,clname,cfname,cperiod,nctr,npage)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pfailgrade(cterm,cdesc,ccolcode,cyear,clname,cfname,cperiod,nctr,npage)
local abtext := {},ncol,nmaxcol := 80, afile,lcheck := .f.,;
      lfirst := .t.,cperiodesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"    ,"C",08,0},;
                                 {"LNAME"   ,"C",15,0},;
                                 {"FNAME"   ,"C",24,0},;
                                 {"MNAME"   ,"C",01,0},;
                                 {"COURSE"  ,"C",08,0}},{||cdxgrdcrs()})
        dbcloseall()
        return(nil)
endif
memvar->failed := memvar->cdummy
if(afile := openwcheck({{,,(memvar->failed+".TXT"),"failed",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
failed->(__dbzap()); failed->(dbreindex())

cperiodesc := if(cperiod=="M","MIDTERM Grade","FINAL Grade")
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("List of Students with Failing Grades",nmaxcol))+"List of Students with Failing Grades"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("Period: "+if(cperiod=="M","MIDTERM Grade","FINAL Grade"),nmaxcol))+"Period: "+if(cperiod=="M","MIDTERM Grade","FINAL Grade")})
aadd(abtext,{||""})

*aadd(abtext,{||space(titlepos("Period: "+cperiodesc,nmaxcol))+"Period: "+cperiodesc})


cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))
if ! ccolcode == "UC"
        if ccolcode $ "NT,MG" .and. ! cyear == _ALL_YEAR
                cyytenrp->(sx_settagorder(3))
                cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
                cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
        elseif ! ccolcode $ "NT,MG" .and. cyear == _ALL_YEAR
                cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
                cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
        elseif ! ccolcode $ "NT,MG" .and. ! cyear == _ALL_YEAR
                cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
                cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
        endif
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ccolcode == _NAUTICAL
                        if cyytenrp->enrcolcod $ "MS,MI,MT,PA,MV"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        wfailed(ccolcode)
                                endif
                        endif
                case ccolcode == _MARINE
                        if cyytenrp->enrcolcod $ "MA,MR,MP,MD,MM"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        wfailed(ccolcode)
                                endif
                        endif
                case ccolcode == "UC"// &&all course
                        if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                wfailed(ccolcode)
                        endif
                case cyytenrp->enrcolcod == ccolcode  //&&particular course
                        if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                wfailed(ccolcode)
                        endif
        endcase
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())

*Printing*
pageprint(abtext)
failed->(dbgotop())
do while ! failed->(eof())
        fask(10,"  Processing student "+alltrim(failed->lname)+", "+alltrim(failed->fname)+" "+failed->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (clname+cfname) < (failed->lname+failed->fname)
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,failed->idno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,failed->idno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        fask(16,"  Printing code "+cyytstsp->stsskdcod+" int "+cyytstsp->stsintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        do case
                                case cperiod == "M" //&&midterm
                                        if cyytstsp->stsmidgrd == "DR" .or. val(cyytstsp->stsmidgrd) > 30 .or. cyytstsp->stsmidgrd == "  "
                                                if pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                             abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                        lfirst := .t.
                                                endif
                                                if lfirst
                                                        @ prow()+01,00 say transform(++nctr,"@Z 9999")+". "+;
                                                                           failed->lname+"  "+;
                                                                           failed->fname+"  "+;
                                                                           failed->mname+"  "+;
                                                                           failed->course+"  "+;
                                                                           "("+failed->idno+")"
                                                        lfirst := .f.
                                                endif
                                                if pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                          abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                        lfirst := .t.
                                                endif
                                                cyytskdp->(dbseek(cyytstsp->stsskdcod))
                                                @ prow()+01,12 say cyytskdp->skdsubcod+"  "+;
                                                                   cyytskdp->skdsubtyp+"  "+;
                                                                   if(val(cyytstsp->stsmidgrd) > 0,left(cyytstsp->stsmidgrd,1)+"."+right(cyytstsp->stsmidgrd,1),cyytstsp->stsmidgrd+" ")+"  "+;
                                                                   transform(cyytskdp->skdunt,"99.9")
                                                @ prow()+00,31 say "___"
                                        endif
                                case cperiod == "F" //&&final
                                        if cyytstsp->stsfingrd == "DR" .or. val(cyytstsp->stsfingrd) > 30 .or. cyytstsp->stsfingrd == "  "
                                                if pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                          abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                        lfirst := .t.
                                                endif
                                                if lfirst
                                                        @ prow()+01,00 say transform(++nctr,"@Z 9999")+". "+;
                                                                           failed->lname+"  "+;
                                                                           failed->fname+"  "+;
                                                                           failed->mname+"  "+;
                                                                           failed->course+"  "+;
                                                                           "("+failed->idno+")"
                                                        lfirst := .f.
                                                endif
                                                if pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                          abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                        lfirst := .t.
                                                endif
                                                cyytskdp->(dbseek(cyytstsp->stsskdcod))
                                                @ prow()+01,12 say cyytskdp->skdsubcod+"  "+;
                                                                   cyytskdp->skdsubtyp+"  "+;
                                                                   if(val(cyytstsp->stsfingrd) > 0,left(cyytstsp->stsfingrd,1)+"."+right(cyytstsp->stsfingrd,1),cyytstsp->stsfingrd+" ")+"  "+;
                                                                   transform(cyytskdp->skdunt,"99.9")
                                                @ prow()+00,31 say "___"
                                        endif
                        endcase
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytstsp->(dbskip())
                enddo
        endif
        cyytstsp->(clearscope())
        lfirst := .t.
        failed->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)

static function wfailed(ccolcode)
failed->(dbappend())
failed->idno    := c999sm1p->sm1idno
failed->lname   := c999sm1p->sm1lstnam
failed->fname   := c999sm1p->sm1fstnam
failed->mname   := c999sm1p->sm1midnam
failed->course  := c999colp->coldesabr+" "+cyytenrp->enryrlevl
return(nil)

*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
//DISPLAY THE CODE IN THE C999TORP 20
static function  create_navfile()//melchor
fask(10,"Initializing File(s) ...",,memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->navfile,{{"toridno"    ,"c",8,0},;
                           {"torschtrm"  ,"c",5,0},{"tordate"    ,"d",8,0},;
                           {"torcolcod"  ,"c",2,0},{"toryrlevl"  ,"c",1,0},;
                           {"torintcd01" ,"c",6,0},{"torfingd01" ,"c",2,0},;
                           {"torcomgd01" ,"c",2,0},{"torintcd02" ,"c",6,0},;
                           {"torfingd02" ,"c",2,0},{"torcomgd02" ,"c",2,0},;
                           {"torintcd03" ,"c",6,0},{"torfingd03" ,"c",2,0},;
                           {"torcomgd03" ,"c",2,0},{"torintcd04" ,"c",6,0},;
                           {"torfingd04" ,"c",2,0},{"torcomgd04" ,"c",2,0},;
                           {"torintcd05" ,"c",6,0},{"torfingd05" ,"c",2,0},;
                           {"torcomgd05" ,"c",2,0},{"torintcd06" ,"c",6,0},;
                           {"torfingd06" ,"c",2,0},{"torcomgd06" ,"c",2,0},;
                           {"torintcd07" ,"c",6,0},{"torfingd07" ,"c",2,0},;
                           {"torcomgd07" ,"c",2,0},{"torintcd08" ,"c",6,0},;
                           {"torfingd08" ,"c",2,0},{"torcomgd08" ,"c",2,0},;
                           {"torintcd09" ,"c",6,0},{"torfingd09" ,"c",2,0},;
                           {"torcomgd09" ,"c",2,0},{"torintcd10" ,"c",6,0},;
                           {"torfingd10" ,"c",2,0},{"torcomgd10" ,"c",2,0},;
                           {"torintcd11" ,"c",6,0},{"torfingd11" ,"c",2,0},;
                           {"torcomgd11" ,"c",2,0},{"torintcd12" ,"c",6,0},;
                           {"torfingd12" ,"c",2,0},{"torcomgd12" ,"c",2,0},;
                           {"torintcd13" ,"c",6,0},{"torfingd13" ,"c",2,0},;
                           {"torcomgd13" ,"c",2,0},{"torintcd14" ,"c",6,0},;
                           {"torfingd14" ,"c",2,0},{"torcomgd14" ,"c",2,0},;
                           {"torintcd15" ,"c",6,0},{"torfingd15" ,"c",2,0},;
                           {"torcomgd15" ,"c",2,0},{"torintcd16" ,"c",6,0},;
                           {"torfingd16" ,"c",2,0},{"torcomgd16" ,"c",2,0},;
                           {"torintcd17" ,"c",6,0},{"torfingd17" ,"c",2,0},;
                           {"torcomgd17" ,"c",2,0},{"torintcd18" ,"c",6,0},;
                           {"torfingd18" ,"c",2,0},{"torcomgd18" ,"c",2,0},;
                           {"torintcd19" ,"c",6,0},{"torfingd19" ,"c",2,0},;
						   {"torcomgd19" ,"c",2,0},{"torintcd20" ,"c",6,0},;
						   {"torintcd20" ,"c",6,0},{"torfingd20" ,"c",2,0},;
						   {"torcomgd20" ,"c",2,0},{"torinst"    ,"c",30,0},;
                           {"torvesname" ,"c",30,0},{"torvesown" ,"c",50,0},;
                           {"torgrston" ,"n",9,2},{"torembark" ,"d",8,0}},{||cdxnavtr()})
       dbcloseall()
       return(nil)
endif
memvar->navtor:=memvar->navfile
if(afile:=openwcheck({{,,(memvar->navtor+".TXT"),"navtor",_DBF_EXCLUSIVE,,1}}))==nil
   dbcloseall()
   return(nil)
endif
navtor->(__dbzap());navtor->(dbreindex())
return(nil)
*------------------------------------------------------------------------------*
static function cdxnavtr()
field  toridno,torschtrm
private cnavfile:=alias()
   index on toridno+torschtrm  tag (memvar->cnavfile+"1") of (memvar->cnavfile)
   index on toridno            tag (memvar->cnavfile+"2") of (memvar->cnavfile)
   index on torschtrm+toridno  tag (memvar->cnavfile+"3") of (memvar->cnavfile)
return(nil)

*------------------------------------------------------------------------------*
function tormain()//TOR PRINTING (MAIN)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,bprint,cprocsts,cfile,ccdx,;
      cidno,cnceeper,cyrtaken,cexamno,cpurpose,n99,cbarhead,corno,;
      cdategrad,cdateadmit,chonrec
private navfile:="reptor"+strzero(memvar->naccess,2),navtor,afile
if(aprvsetup := openwcheck({{,,"c999torp",,_DBF_SHARED,,1},;
                            {,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"c999sm2p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Transcript of Record Printing for UC-Main ")
commandline("³           F4 - View Student          ³              ESC - Previous           ³")
aentryscr := savescr(01,00,24,79)
cidno     := space(len(c999sm1p->sm1idno))
cnceeper  := "N.A."
cyrtaken  := "N.A."
cexamno   := "N.A.      "
cpurpose  := "FOR EVALUATION"+space(36)
cprepared := "APOLINARIO Y. YU"+space(14)
cchecked  := "MARINES D. ROMANO"+space(11)
cregistrar:= "JOVITA A. QUIÑANOLA"+space(13)
corno     := space(10)
cflag     := " "
cdategrad := space(20)
cdateadmit:= space(20)
chonrec   := space(20)
create_navfile()
do while .t.
        navtor->(__dbzap());navtor->(dbreindex())
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number   :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)
        @ 03,02 say "NCEE Percentile  :";
                color memvar->colorarray[02];
                get cnceeper    pict "@!"
        @ 04,02 say "Year Taken       :";
                color memvar->colorarray[02];
                get cyrtaken    pict "@!"
        @ 05,02 say "Examinee Number  :";
                color memvar->colorarray[02];
                get cexamno     pict "@!"
        @ 06,02 say "Purpose          :";
                color memvar->colorarray[02];
                get cpurpose    pict "@!"
        @ 07,02 say "Prepared by      :";
                color memvar->colorarray[02];
                get cprepared   pict "@!"
        @ 08,02 say "Checked by       :";
                color memvar->colorarray[02];
                get cchecked    pict "@!"

        @ 09,02 say "Registrar  Head  :";
                color memvar->colorarray[02];
                get cregistrar    pict "@!"
                //valid ! empty(cregistrar)    

        @ 10,02 say "Payment Number   :";
                color memvar->colorarray[02];
                get corno       pict "@!"
        @ 11,02 say "Date Graduated   :";
                color memvar->colorarray[02];
                get cdategrad   pict "@!"
        @ 12,02 say "Date Admitted    :";
                color memvar->colorarray[02];
                get cdateadmit  pict "@!"
        @ 13,02 say "Honor Received   :";
                color memvar->colorarray[02];
                get chonrec  pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999sm1p->(dbseek(cidno))
                fask(13,"     Student number "+alltrim(cidno)+" not exists...     ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
         nptor(cidno)// && additional function for Y2K compliance
         if whereprint({||mptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec)}) == 1
                 __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                  viewtextfile()
         endif
enddo
restscr(alastscr)
closewcheck(aprvsetup)
navtor->(dbclosearea())
memvar->navfile+=".*"
ferase(memvar->navfile)
return(nil)

//TOR PRINTING FOR UCMAIN
function mptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec)
local afile,nline := 0, npage := 01,nctr := 0,cnterm:=space(3),;
      cintcod,cfingrd,ccomgrd,ctrmdesc
mtorfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec)
mtorheader()
navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))
navtor->(dbgotop())
do while ! navtor->(eof())
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1))))
//        if prow() > 51
        if prow() > 46
                mfootline()
                mtefooter1(++npage,cpurpose,corno)
                mtorheader()
        endif
        @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
        @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))

        if empty(navtor->torintcd01)
                c999torp->(dbseek(cidno+cnterm))
                @ prow()+01,02 say "NAME OF VESSEL     : "+c999torp->torvesname
                @ prow()+01,02 say "PROPRIETOR         : "+c999torp->torvesown
                @ prow()+01,02 say "GROSS TONS         : "+transform(c999torp->torgrston,"9,999,999.99")
                @ prow()+01,02 say "DATE OF EMBARKATION: "+upper(cmonth(c999torp->torembark))+str(day(c999torp->torembark))+","+str(year(c999torp->torembark))
                @ prow()+00,71 say "18"
        endif

        for nctr := 1 to 16 //melchor IF 16 ERROR CTORCONT
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                      //  if prow() > 50
                        if prow() > 45
                                mfootline()
                                mtefooter1(++npage,cpurpose,corno)
                                mtorheader()
                                @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                        endif





                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1
                        if ! empty(c999crsp->crsdsc2)
                                @ prow()+01,18 say c999crsp->crsdsc2+"   "+;
                                                   if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31") ,;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(c999crsp->crscreunt,"@Z 999")),transform(0,"999"))
                                                  // &&if(val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31",transform(c999crsp->crscreunt,"@Z 999.9"),transform(0,"99999"))
                        elseif empty(c999crsp->crsdsc2)
                                @ prow()+00,57 say if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31") ,;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(c999crsp->crscreunt,"@Z 999")),transform(0,"999"))
                                                  // &&if(val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31",transform(c999crsp->crscreunt,"@Z 999.9"),transform(0,"99999"))
                        endif
                else
                        exit
                endif
        next
        if nextkey() == K_ESC
                exit
        endif
        navtor->(dbskip())
enddo
navtor->(clearscope())
//navtor->(sx_SetTagOrder(1))

c999colp->(dbseek(c999sm1p->sm1colcod))
outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN ";
                     +alltrim(c999colp->colnamcol))
//outexpr(prow()+01,02,"THE TITLE OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")"+" AS")
outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")")
outexpr(prow()+01,02,"AS OF "+alltrim(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
outexpr(prow()+01,02,"OF SPECIAL ORDER.")
outexpr(prow()+01,02,replicate("-",74))
outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")
mtefooter2(++npage,cpurpose,corno)
return(nil)

static function mtorfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit)
mheadeject()
setprc(00,00)
outexpr(prow()+01,02,"NAME:_____________________________________________    ...................")
outexpr(prow()+00,09,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+if(!empty(c999sm1p->sm1midnam),"."," "))
outexpr(prow()+01,02,"STUDENT NUMBER:___________________________________    :                 :")
outexpr(prow()+00,19,cidno)
outexpr(prow()+01,02,"SEX:_____________________CIVIL STATUS:____________    :                 :")
outexpr(prow()+00,08,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,42,if(c999sm2p->sm2civsts == "S","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE:_______________________________________    :                 :")
outexpr(prow()+00,15,upper(cmonth(c999sm2p->sm2birdte))+" "+transform(day(c999sm2p->sm2birdte),"99")+", "+transform(year(c999sm2p->sm2birdte),"9999"))
outexpr(prow()+01,02,"BIRTHPLACE:_______________________________________    :                 :")
outexpr(prow()+00,15,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY:_____________RELIGION:________________    :                 :")
outexpr(prow()+00,16,c999sm2p->sm2nat);outexpr(prow()+00,38,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN:__________________________________    :                 :")
outexpr(prow()+00,20,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS:________________________________    :                 :")
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),c999sm1p->sm1homadr,"C/O REGISTRAR, UC-PT"))
outexpr(prow()+01,02,"DATE ADMITTED:____________________________________    :                 :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,18,cdateadmit)
//outexpr(prow()+00,17,upper(cmonth(navtor->tordate))+" "+transform(day(navtor->tordate),"99")+", "+transform(year(navtor->tordate),"9999"))
outexpr(prow()+01,02,"COLLEGE OF:_______________________________________    :                 :")
c999colp->(dbseek(c999sm1p->sm1colcod))
outexpr(prow()+00,15,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA:____________________________________    :.................:")
outexpr(prow()+00,18,c999sm2p->sm2entdat)
outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY:__________________________________________________  YEAR:______")
outexpr(prow()+00,15,c999sm2p->sm2prisc);outexpr(prow()+00,72,c999sm2p->sm2priyr)
outexpr(prow()+01,02,"HIGH SCHOOL:_________________________________________________  YEAR:______")
outexpr(prow()+00,16,c999sm2p->sm2secsc);outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH:_________________________________________________  YEAR:______")
    outexpr(prow()+00,16,c999sm2p->sm2sh);outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif

outexpr(prow()+01,02,"COLLEGE:_____________________________________________________  YEAR:______")
outexpr(prow()+00,12,c999sm2p->sm2colsc);outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+01,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")
outexpr(prow()+03,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
outexpr(prow()+03,02,"PREPARED BY:                                         CHECKED BY:")
outexpr(prow()+03,02,cprepared)
outexpr(prow()+00,55,cchecked)
outexpr(prow()+00,02,replicate("_",22))
outexpr(prow()+00,55,replicate("_",22))
//outexpr(prow()+04,27,"    FRANCISCO C. SALES    ")

outexpr(prow()+03,27,"      "+cregistrar+"   ")
//outexpr(prow()+03,27,"    JOVITA  A. QUI¥ANOLA  ")
outexpr(prow()+00,27,"__________________________")
outexpr(prow()+01,27,"      ASST.  REGISTRAR   ")
outexpr(prow()+03,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________    ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,04,"        PAGE  1       ")
__eject()
return(nil)

static function mtorheader()
mheadeject()
setprc(00,00)
outexpr(prow()+01,02,"NAME:______________________________________________  STUDENT NO.:_________")
outexpr(prow()+00,09,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+if(!empty(c999sm1p->sm1midnam),"."," "))
outexpr(prow()+00,69,c999sm1p->sm1idno)
outexpr(prow()+02,02,"--------------------------------------------------------------------------")
outexpr(prow()+01,02,"COURSE NO.      DESCRIPTIVE TITLES                    FINAL RE-EXAM CREDIT")
outexpr(prow()+01,02,"--------------------------------------------------------------------------")
return(nil)

/*
static function mtefooter1(npage,cpurpose,corno)
outexpr(prow()+02,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,dtoc(date()))
outexpr(prow()+02,06,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,06,"    OR NO.__________                           JOVITA A. QUI¥ANOLA    ")
outexpr(prow()+00,17,corno);outexpr(prow()+00,49,"____________________________")
outexpr(prow()+01,06,"        PAGE "+str(npage,2)+"                            UCMETC - REGISTRAR")
__eject()
return(nil)
*/

static function mtefooter1(npage,cpurpose,corno)
outexpr(55,02,"REMARKS:                                             DATE ISSUED:")
outexpr(55,11,cpurpose);outexpr(55,68,dtoc(date()))
outexpr(57,06,"NOT VALID WITHOUT SEAL")
outexpr(58,06,"    OR NO.__________                           JOVITA A. QUIÑANOLA    ")
outexpr(58,17,corno);outexpr(58,49,"____________________________")
outexpr(59,06,"        PAGE "+str(npage,2)+"                                REGISTRAR")
__eject()
return(nil)

static function mtefooter2(npage,cpurpose,corno)
outexpr(55,02,"REMARKS:                                             DATE ISSUED:")
outexpr(55,11,cpurpose);outexpr(55,68,dtoc(date()))
outexpr(57,06,"NOT VALID WITHOUT SEAL")
outexpr(58,06,"    OR NO.__________                           JOVITA A. QUIÑANOLA   ")
outexpr(58,17,corno);outexpr(58,49,"____________________________")
outexpr(59,06,"        PAGE "+str(npage,2)+"                               REGISTRAR")
__eject()
return(nil)



static function mheadeject()
local nctr:=0
for nctr := 1 to 3
        outexpr(prow()+01,00,"")
next
return(nil)

static function mtehead2()
local nctr:=0
for nctr := 1 to 10
        outexpr(prow()+01,00,"")
next
return(nil)

static function mfootline()
outexpr(prow()+01,02,replicate("-",74))
outexpr(prow()+01,29,"(MORE ENTRIES NEXT PAGE)")
return(nil)

static function mcdxtor()
field term,idno
private cdummyfile := alias()
index on term+idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
* Grade printing by course for deliberation
function grddel()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, cyytenrp, aprv2setup,;
      cterm,cdesc,cperiod,ccolcode,cyear,cpaper,clname,cfname,cgrad
private cdummy := "gcours"+strzero(memvar->naccess,2),mstfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
cperiod  := "F"
ccolcode := "UC"
cyear    := "8"
cpaper   := "B"
cgrad    := "*"
clname   := space(15)
cfname   := space(24)
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing by Course for Deliberation ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "c"+cterm+"stsp"
        cyytskdp := "c"+cterm+"skdp"
        cyytenrp := "c"+cterm+"enrp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,5},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.) //TODO
                @ 03,23 say "[UC - All Course]" color memvar->colorarray[02]
                  @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                
                @ 04,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 04,02 say "Grading Period :";
                        color memvar->colorarray[02];
                        get cperiod     pict "@!";
                        valid cperiod $ "FM"
                @ 05,23 say "[1 2 3 4 5  8-All]" color memvar->colorarray[02]
                @ 05,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        valid cyear $ "123458"
                @ 06,23 say "[B-lank Form, P-rinted Form]" color memvar->colorarray[02]
                @ 06,02 say "Paper Type     :";
                        color memvar->colorarray[02];
                        get cpaper      pict "@!";
                        valid cpaper $ "BP"
                @ 07,02 say "Last Name      :";
                        color memvar->colorarray[02];
                        get clname      pict "@!"
                @ 08,02 say "First Name     :";
                        color memvar->colorarray[02];
                        get cfname      pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||_prngrdcourse(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname,cgrad)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif

                /*if ccolcode $ "NT,MG"
                        bprint := {||pgrdavegroup(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                else
                        bprint := {||pgrdave(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                endif
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif*/
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)


static function _prngrdcourse(ccolcode,cyear,cperiod,cpaper,cdesc,clname,cfname,cgrad)
local afile
private ntotunits,ntotequi,lok,ntotgrade,csubject,csubdesc,cgrade,cunit,lprint

fask(13,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"PERIOD"      ,"C",07,0}},{||_cdxgrdcrs()})
        dbcloseall()
        return(nil)
endif
memvar->mstfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->mstfile+".TXT"),"mstfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
mstfile->(__dbzap()); mstfile->(dbreindex())

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))
if ! ccolcode == "UC" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear+cgrad))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear+cgrad))
elseif ! ccolcode == "UC" .and. cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cgrad))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cgrad))
elseif ccolcode == "UC" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_settagorder(3))
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear+cgrad))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear+cgrad))
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        mstfile->(dbappend())
        mstfile->idno   := c999sm1p->sm1idno
        mstfile->lname  := c999sm1p->sm1lstnam
        mstfile->fname  := c999sm1p->sm1fstnam
        mstfile->mname  := c999sm1p->sm1midnam
        mstfile->course := c999colp->coldesabr
        mstfile->year   := cyytenrp->enryrlevl
        mstfile->period := if(cperiod == "M","MIDTERM","FINAL  ")
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*------------------
*  Printing data  *
*------------------
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
mstfile->(dbgotop())
do while ! mstfile->(eof())
        memvar->ntotunits := memvar->ntotequi := memvar->ntotgrade := 0
        memvar->lok             := .t.
        memvar->lprint          := .f.
        memvar->csubject        := space(13)
        memvar->csubdesc        := space(39)
        memvar->cgrade          := space(03)
        memvar->cunit           := space(04)
        fask(10,"  Processing student "+alltrim(mstfile->lname)+", "+alltrim(mstfile->fname)+" "+mstfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(mstfile->lname)+alltrim(mstfile->fname))
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,mstfile->idno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,mstfile->idno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        fask(16,"  Printing code "+alltrim(c999crsp->crsintcod)+" subject "+alltrim(c999crsp->crssubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        memvar->csubject := c999crsp->crssubcod+if(c999crsp->crssubtyp == "R"," ","L")
                        //memvar->csubdesc := alltrim(c999crsp->crsdsc1)+if(!empty(c999crsp->crsdsc2),"...","   ")+if(!empty(c999crsp->crsdsc3),"...","   ")

                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                do case
                                        case cperiod == "M" // &&Midterm
                                                memvar->lok := .f.
                                                if val(cyytstsp->stsmidgrd) > 0
                                                        if substr(cyytstsp->stsmidgrd,2,1) == "W"  /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                        else  /* for 30 - 10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                                        endif
                                                        if cyytstsp->stsmidgrd <= "30"
                                                                _getunits()
                                                        else
                                                                memvar->cunit := "  0 "
                                                        endif
                                                elseif ! empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                        memvar->cunit  := "  0 "
                                                elseif empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := " - "
                                                        memvar->cunit  := "  0 "
                                                endif
                                        case cperiod == "F"  // &&Final
                                                if val(cyytstsp->stsfingrd) > 0
                                                        if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        else /* for 30-10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                                        endif
                                                        if cyytstsp->stsfingrd <= "30"
                                                                _getunits()
                                                                memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                                        else
                                                                memvar->cunit := "  0 "
                                                                memvar->lok := .f.
                                                        endif
                                                elseif ! empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        memvar->cunit  := "  0 "
                                                        memvar->lok := .f.
                                                elseif empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := " - "
                                                        memvar->cunit  := "  0 "
                                                        memvar->lok := .f.
                                                endif
                                endcase
                                *---------------------------------
                                *  check the paper to be printed *
                                *---------------------------------
                                do case
                                        case cpaper == "B"  /* Blank Form */
                                                if ! lprint
                                                        _blankheader(cdesc,cperiod)
                                                        memvar->lprint := .t.
                                                endif

                                                //LIST OF SUBJECT AND ILANG GRADES
                                                outexpr(prow()+01,00,memvar->csubject)
                                               // outexpr(prow()+00,16,memvar->csubdesc)
                                                outexpr(prow()+00,59,memvar->cgrade)
                                                outexpr(prow()+00,65,memvar->cunit)

                                        case cpaper == "P"  /* Printed Form */
                                                if ! lprint
                                                        _printedheader(cdesc)
                                                        memvar->lprint := .t.
                                                endif

                                                //LIST OF SUBJECT AND ILANG GRADES
                                                outexpr(prow()+01,00,memvar->csubject)
                                                //outexpr(prow()+00,15,memvar->csubdesc)
                                                outexpr(prow()+00,62,memvar->cgrade)
                                                outexpr(prow()+00,67,memvar->cunit)
                                endcase
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytstsp->(dbskip())
                enddo
                cyytstsp->(clearscope())
                if nextkey() == K_ESC
                        exit
                endif
                /* print footer */
                do case
                        case cpaper == "B"  /* Blank Form   */
                                outexpr(prow()+01,00,replicate("Ä",70))
                                outexpr(prow()+01,00,displaydate(date()))
                                outexpr(prow()+00,59,if(memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"9.99"),"    "))
                                outexpr(prow()+00,65,transform(memvar->ntotunits,"99.9"))
                        case cpaper == "P"  /* Printed Form */
                                outexpr(18,02,displaydate(date()))
                                outexpr(18,61,if(memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"9.99"),"    "))
                                outexpr(18,68,transform(memvar->ntotunits,"99.9"))
                endcase
                @ 18,00 say space(01)  /* to eject */
                setprc(00,-1)
        endif
        mstfile->(dbskip())
enddo
cyytstsp->(dbclearrelation())
closewcheck(afile)
__eject()
return(nil)

static function _getunits()
private nunits
memvar->ntotunits += cyytskdp->skdunt

nunits := cyytskdp->skdunt
if (ncount > 13) .and. (cyytskdp->skdsplcod=="S")
        cyytskdp->(dbseek(cyytstsp->stsskdcod))
        cyytskdp->(dbseek(cyytskdp->skdsplskd))
        if cyytskdp->skdsubtyp=="LAB"
                nunits += cyytskdp->skdunt
                memvar->ntotunits += cyytskdp->skdunt
                memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
        endif
endif
memvar->cunit := if(substr(str(nunits,5,1),5,1) == "0",;
                    substr(str(nunits,5,1),1,3)+" ",;
                    substr(str(nunits,5,1),2,4))
/*
memvar->cunit := if(substr(str(cyytskdp->skdunt,5,1),5,1) == "0",;
                    substr(str(cyytskdp->skdunt,5,1),1,3)+" ",;
                    substr(str(cyytskdp->skdunt,5,1),2,4))
*/
return(nil)


static function _blankheader(cdesc,cperiod)
outexpr(00,00,substr(memvar->ccompanyname,1,28)+space(01)+substr(cdesc,1,22)+space(06)+if(cperiod == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(01,00,replicate("-",70))
outexpr(02,00,mstfile->idno+space(02)+mstfile->lname+space(01)+mstfile->fname+space(01)+mstfile->mname+space(07)+mstfile->course+space(04)+mstfile->year)
outexpr(03,00,replicate("-",70))
outexpr(04,00,"SUBJECT         REFERENCE                                 GRADE  UNITS")
return(nil)


static function _printedheader(cdesc)
outexpr(00,30,alltrim(cdesc))
outexpr(02,01,mstfile->idno+space(02)+mstfile->lname+space(01)+mstfile->fname+space(01)+mstfile->mname+space(02)+mstfile->course+space(01)+mstfile->year+space(02)+mstfile->period)
outexpr(03,00,space(01))
return(nil)


static function _cdxgrdcrs()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
function _compgrdave()  // apil tanan bisag naay 5.0,W,NG,NA,NC
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      ccolcode,cyear,cgrade,cterm,cdesc,cscope,ctype,aprv1setup,aprv2setup,;
      bprint, cprocsts, cyytstsp, cyytenrp, cyytskdp
private cdummy := "grdave"+strzero(memvar->naccess,2), grdave

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Compute Students Grade Average w/ Failures ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytstsp := alltrim("c"+cterm+"stsp")
        cyytenrp := alltrim("c"+cterm+"enrp")
        cyytskdp := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        cyear    := "1"
        cgrade   := "F"
        cscope   := "R"
        ctype    := "W"
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                //@ 03,23 say "[NT-nautical,MG-marine, NA-name]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcode(ccolcode,cprocsts)
                @ 04,23 say "[1 2 3 4 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear  pict "@!";
                        valid cyear $ "12345"
                @ 05,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Grade          :";
                        color memvar->colorarray[02];
                        get cgrade      pict "@!";
                        valid cgrade $ "MF"
                @ 06,23 say "[T-op100, D-eansLister, R-anking]" color memvar->colorarray[02]
                @ 06,02 say "Scope          :";
                        color memvar->colorarray[02];
                        get cscope      pict "@!";
                        valid cscope $ "DTR"
                @ 07,23 say "[P-GPA, W-GWA]" color memvar->colorarray[02]
                @ 07,02 say "Computation    :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "PW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ccolcode $ "NT,MG,NA"
                        bprint := {||pgrdavegroup(ccolcode,cyear,cgrade,cscope,ctype,cdesc,"WF")}
                else
                        bprint := {||_pgrdave(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                endif
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

function _pgrdave(ccolcode,cyear,cgrade,cscope,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == "1"
        cyeardesc := "FIRST YEAR"
elseif cyear == "2"
        cyeardesc := "SECOND YEAR"
elseif cyear == "3"
        cyeardesc := "THIRD YEAR"
elseif cyear == "4"
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
if cscope == "D"
        aadd(abtext,{||space(titlepos("STUDENTS' DEANS LISTER",nmaxcol))+"STUDENTS' DEANS LISTER"})
elseif cscope == "T"
        aadd(abtext,{||space(titlepos("TOP 100 STUDENTS",nmaxcol))+"TOP 100 STUDENTS"})
elseif cscope == "R"
        aadd(abtext,{||space(titlepos("STUDENTS RANKING",nmaxcol))+"STUDENTS RANKING"})
endif
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc,nmaxcol))+cyeardesc})
aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/


cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing id-no."+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
        cyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
        cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
        cyytstsp->(dbgotop())
        do while ! cyytstsp->(eof())
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        do case
                                case cgrade == "M"
                                        if !cyytstsp->stsmidgrd == " "
                                                if ctype == "P" // &&GPA
                                                        *ngvar := val(cyytstsp->stsmidgrd) / 10
                                                        ngvar := iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                        ntgrade += ngvar
                                                elseif ctype == "W"  //&&GWA
                                                        *ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                        ngvar := iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                        nequi   := ngvar * cyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                                case cgrade == "F"
                                        if !cyytstsp->stsfingrd == "  "
                                                if ctype == "P"  //&&GPA
                                                        *ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                        ntgrade += iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                else // &&GWA
                                                        *nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                        nequi   := iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10)*cyytskdp->skdunt,5.0* cyytskdp->skdunt)
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                exit
                                        endif
                        endcase
                endif
                cyytstsp->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
        enddo
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(ccolcode))
                grdave->course  := c999colp->coldesabr
                if ctype == "P" // &&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

function pgrdavegroup(ccolcode,cyear,cgrade,cscope,ctype,cdesc,ilhanan)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,totunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc, ccolgroup

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())



if cyear == _FIRST_YEAR
        cyeardesc := "FIRST YEAR"
elseif cyear == _SECOND_YEAR
        cyeardesc := "SECOND YEAR"
elseif cyear == _THIRD_YEAR
        cyeardesc := "THIRD YEAR"
elseif cyear == _FOURTH_YEAR
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
if cscope == "D"
        aadd(abtext,{||space(titlepos("STUDENTS' DEANS LISTER",nmaxcol))+"STUDENTS' DEANS LISTER"})
elseif cscope == "T"
        aadd(abtext,{||space(titlepos("TOP 100 STUDENTS",nmaxcol))+"TOP 100 STUDENTS"})
elseif cscope == "R"
        aadd(abtext,{||space(titlepos("STUDENTS RANKING",nmaxcol))+"STUDENTS RANKING"})
endif
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc+" - "+cgrdesc,nmaxcol))+cyeardesc+" - "+cgrdesc})
*aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
/*
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif
*/

if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE   TOTAL UNITS   G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------       --        ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE   TOTAL UNITS    G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------       --        ------"})
endif

/*
FIRST YEAR - BS MARINE ENGINEERING

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/

if ccolcode == _NAUTICAL
        ccolgroup := "MIMTPAMVHNBNYNETNVNWTL"
       // ccolgroup := "HNMV"
elseif ccolcode == _MARINE
         ccolgroup := "MAMRMPMMHMBMYMSMENELERNMMWML"
      // ccolgroup := "HMMM"
elseif ccolcode == "NA"
        ccolgroup := "MNNS"
endif

cyytenrp->(sx_settagorder(3))
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing idno. "+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrp->enrcolcod $ ccolgroup
                cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                
                                do case
                                        case cgrade == "M" // KUNG MIDTERM ANG GE SELECT
                                            if ilhanan == "NF"
                                                if val(cyytstsp->stsmidgrd) > 0 //trap tanan grado nga dili blank, dr, na, w
                                                    if val(cyytstsp->stsmidgrd) >= 10 .and. val(cyytstsp->stsmidgrd) <= 30
                                                            if ctype == "P"  //&&GPA
                                                                    ngvar := val(cyytstsp->stsmidgrd) / 10
                                                                    ntgrade += ngvar
                                                            elseif ctype == "W"  //&&GWA
                                                                    ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                                    nequi   := ngvar * cyytskdp->skdunt
                                                                    ntequi  += nequi
                                                                    ntunits += cyytskdp->skdunt
                                                            endif
                                                            lprocess := .t.
                                                            //++nctr
                                                    else
                                                            lprocess := .f.
                                                            exit
                                                    endif
                                                    ++nctr
                                                endif
                                            elseif ilhanan == "WF" //if ge tawag sa with failure ang function
                                                if !cyytstsp->stsmidgrd == " "
                                                    if ctype == "P" // &&GPA
                                                            *ngvar := val(cyytstsp->stsmidgrd) / 10
                                                            ngvar := iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                            ntgrade += ngvar
                                                    elseif ctype == "W"  //&&GWA
                                                            *ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                            ngvar := if(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                            nequi   := ngvar * cyytskdp->skdunt
                                                            ntequi  += nequi
                                                            ntunits += cyytskdp->skdunt
                                                    endif
                                                    lprocess := .t.
                                                    ++nctr
                                                else
                                                    lprocess := .f.
                                                    exit
                                                endif
                                            endif
                                               
                                        case cgrade == "F" //KUNG FINALS ANG GE SELECT
                                                if ilhanan == "NF"

                                                    if val(cyytstsp->stsfingrd) > 0 //trap tanan grado nga dili blank, dr, na, w
                                                        if val(cyytstsp->stsfingrd) >= 10 .and. val(cyytstsp->stsfingrd) <= 30
                                                                if ctype == "P"  //&&GPA
                                                                        ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                                else  //&&GWA
                                                                        nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                                        ntequi  += nequi
                                                                        ntunits += cyytskdp->skdunt
                                                                endif
                                                                lprocess := .t.
                                                                //++nctr
                                                        else
                                                                lprocess := .f.
                                                                exit
                                                        endif
                                                        ++nctr
                                                    endif

                                                elseif ilhanan == "WF" //if ge tawag sa with failure ang function

                                                    if !cyytstsp->stsfingrd == " "
                                                            if ctype == "P"  //&&GPA
                                                                    *ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                                    ntgrade += iif(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10),5.0)
                                                            else // &&GWA
                                                                    *nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                                    nequi   := if(val(cyytstsp->stsfingrd) > 0,(val(cyytstsp->stsfingrd)/10)*cyytskdp->skdunt,5.0* cyytskdp->skdunt)
                                                                    ntequi  += nequi
                                                                    ntunits += cyytskdp->skdunt
                                                            endif
                                                            lprocess := .t.
                                                            //++nctr
                                                    else
                                                        lprocess := .f.
                                                        exit
                                                    endif 

                                                endif
                                endcase
                        endif
                        cyytstsp->(dbskip())
                        if nextkey() == K_ESC
                                exit
                        endif
                enddo
        endif
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(cyytenrp->enrcolcod))
                grdave->course  := c999colp->coldesabr
                if ctype == "P" // &&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                        totunits := ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(07) + ;
                                     transform(totunits,"99") + space(09) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(07) + ;
                                             transform(totunits,"99") + space(09) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(07) + ;
                                     transform(totunits,"99")+ space(09) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)




function cdxgrdave()
field idno,grade,lname,fname
private cdummyfile := alias()
index on str(grade,5,3)+lname+fname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function viewcode(ccode,cprocsts)
if ccode $ "NT,MG,NA"
*        @ 03,23 say if(ccode == "NT","NAUTICAL               ",if(ccode == "MG","MARINE                 ", "NAVAL ARCHITECTURE      "))
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
*@ 03,23 say c999colp->coldesful
return(.t.)

*------------------------------------------------------------------------------*

function format_date(sdate)
local num
num := alltrim(transform(day(sdate),"99"))
if len(num)==1
        num := "0"+num
endif
if !empty(sdate)
        return alltrim(upper(cmonth(sdate)))+" "+num+", "+transform(year(sdate),"9999")
else
        return space(0)
endif
return

//========================================================================
//   R O U T I N E   T O   P R I N T   G R A D E S  4  C H E C K I N G
//========================================================================

function grdlistbysubj()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytstsp, cyytskdp,;
      bprint, cprocsts, cterm := space(03), ctdesc,cedpcode,cskd,csubject,;
      cinscode,cinsname

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grades Printing for Checking  ")
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
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ctdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytstsp  := alltrim("c"+cterm+"stsp")
        cyytenrp  := alltrim("c"+cterm+"enrp")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,3},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cedpcode := space(len(cyytskdp->skdcod))
        do while .t.
                restscr(aentryscr)
                commandline("³           F4 - View Schedule         ³           ESC - Previous              ³")
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
                if whereprint({||pgrdlistbysubj(cedpcode,ctdesc,cskd,csubject,cinscode,cinsname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pgrdlistbysubj(cedpcode,ctdesc,cskd,csubject,cinscode,cinsname)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(ctdesc),nmaxcol)-14)+alltrim(ctdesc)})
aadd(abtext,{||space(titlepos("GRADES PRINTING FOR CHECKING",nmaxcol))+"GRADES PRINTING FOR CHECKING"})
//                                Grades Printing for Checking
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+cinscode+" - "+cinsname})
aadd(abtext,{||"Schedule  : "+cedpcode+"  - "+cskd})
aadd(abtext,{||"          : "+csubject})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr MG FG  Rem  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- -- -- -----"})

/*
Instructor: 123456 - 123456789012345678901234567890
Schedule  : 12345  - 1234567901534564
          : 123134313313131313131

      ID No.     Last Name          First Name         M Course Yr MG FG  Rem
     -------- --------------- ------------------------ - ------ -- -- -- -----
123. 12345678 123456789012345 123456789012345678901234 1 123456  1 12 12 12345
*/

nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytstsp->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytstsp->(dbgotop())
do while ! cyytstsp->(eof())
   fask(10,"  Printing edp-code "+cedpcode+" student "+alltrim(cyytstsp->stslstnam)+", "+alltrim(cyytstsp->stsfstnam)+" "+cyytstsp->stsmidnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if prow() == 60
        outexpr(prow()+01,0,"UC-PT/REG.Doc/007/Rev.01")
   endif
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
//        c999colp->(dbseek(cyytstsp->enrcolcod))
        c999sm1p->(dbseek(cyytstsp->stsidno))
        cyytenrp->(dbseek(cyytstsp->stsidno))
        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                             cyytstsp->stsidno+spac(01)+;
                             c999sm1p->sm1lstnam+space(01)+;
                             c999sm1p->sm1fstnam+space(01)+;
                             c999sm1p->sm1midnam+space(01)+;
                             cyytstsp->stscourse+space(01)+;
                             cyytstsp->stsyrlevel+space(01)+;
                             cyytstsp->stsmidgrd+space(01)+;
                             cyytstsp->stsfingrd+space(01)+;
                             "_____")
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        cyytstsp->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

*---THIS PORTION IS CREATED BY KENN FOR CAMPUS LINKAGE (RANKING WITHOUT SCHOLARS/NIGERIANS--------*

function compgrdav()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      ccolcode,cyear,cgrade,cterm,cdesc,cscope,ctype,aprv1setup,aprv2setup,;
      bprint, cprocsts, cyytstsp, cyytenrp, cyytskdp
private cdummy := "grdave"+strzero(memvar->naccess,2), grdave

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Compute Students Grade Average (w/o SCHOLARS) ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytstsp := alltrim("c"+cterm+"stsp")
        cyytenrp := alltrim("c"+cterm+"enrp")
        cyytskdp := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "1"
        cgrade   := "F"
        cscope   := "R"
        ctype    := "W"
        do while .t.
                clearbuffer()
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-nautical,MG-marine]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcode(ccolcode,cprocsts)
                @ 04,23 say "[1 2 3 4 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyear  pict "@!";
                        valid cyear $ "12345"
                @ 05,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Grade          :";
                        color memvar->colorarray[02];
                        get cgrade      pict "@!";
                        valid cgrade $ "MF"
                @ 06,23 say "[T-op100, D-eansLister, R-anking]" color memvar->colorarray[02]
                @ 06,02 say "Scope          :";
                        color memvar->colorarray[02];
                        get cscope      pict "@!";
                        valid cscope $ "DTR"
                @ 07,23 say "[P-GPA, W-GWA]" color memvar->colorarray[02]
                @ 07,02 say "Computation    :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "PW"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ccolcode $ "NT,MG"
                        bprint := {||pgrdavegrp(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                else
                        bprint := {||pgrdav(ccolcode,cyear,cgrade,cscope,ctype,cdesc)}
                endif
                if whereprint(bprint) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

function pgrdavegrp(ccolcode,cyear,cgrade,cscope,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc, ccolgroup

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == _FIRST_YEAR
        cyeardesc := "FIRST YEAR"
elseif cyear == _SECOND_YEAR
        cyeardesc := "SECOND YEAR"
elseif cyear == _THIRD_YEAR
        cyeardesc := "THIRD YEAR"
elseif cyear == _FOURTH_YEAR
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
if cscope == "D"
        aadd(abtext,{||space(titlepos("STUDENTS' DEANS LISTER",nmaxcol))+"STUDENTS' DEANS LISTER"})
elseif cscope == "T"
        aadd(abtext,{||space(titlepos("TOP 100 STUDENTS",nmaxcol))+"TOP 100 STUDENTS"})
elseif cscope == "R"
        aadd(abtext,{||space(titlepos("STUDENTS RANKING",nmaxcol))+"STUDENTS RANKING"})
endif
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc+" - "+cgrdesc,nmaxcol))+cyeardesc+" - "+cgrdesc})
*aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR - BS MARINE ENGINEERING

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/

if ccolcode == _NAUTICAL
        ccolgroup := "MIMTPAMVETNW"
elseif ccolcode == _MARINE
        ccolgroup := "MAMRMPMMENELERMW"
endif

cyytenrp->(sx_settagorder(3))
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing idno. "+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrp->enrcolcod $ ccolgroup
                cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                do case
                                        case cgrade == "M"
                                            if val(cyytstsp->stsmidgrd) > 0
                                                if val(cyytstsp->stsmidgrd) >= 10 .and. val(cyytstsp->stsmidgrd) <= 30
                                                        if ctype == "P"  //&&GPA
                                                                ngvar := val(cyytstsp->stsmidgrd) / 10
                                                                ntgrade += ngvar
                                                        elseif ctype == "W" // &&GWA
                                                                ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                                nequi   := ngvar * cyytskdp->skdunt
                                                                ntequi  += nequi
                                                                ntunits += cyytskdp->skdunt
                                                        endif
                                                        lprocess := .t.
                                                        //++nctr
                                                else
                                                        lprocess := .f.
                                                       // exit
                                                endif
                                                ++nctr

                                            endif

                                        case cgrade == "F"
                                            if val(cyytstsp->stsfingrd) > 0
                                                if val(cyytstsp->stsfingrd) >= 10 .and. val(cyytstsp->stsfingrd) <= 30
                                                        if ctype == "P"  //&&GPA
                                                                ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                        else // &&GWA
                                                                nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                                ntequi  += nequi
                                                                ntunits += cyytskdp->skdunt
                                                        endif
                                                        lprocess := .t.
                                                        //++nctr
                                                else
                                                        lprocess := .f.
                                                        //exit
                                                endif
                                                ++nctr
                                            endif
                                endcase
                        endif
                        cyytstsp->(dbskip())
                        if nextkey() == K_ESC
                                exit
                        endif
                enddo
        endif
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(cyytenrp->enrcolcod))
                grdave->course  := c999colp->coldesabr
                if ctype == "P"  //&&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

function pgrdav(ccolcode,cyear,cgrade,cscope,ctype,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, cyeardesc,;
      lprocess := .f., ntgrade := 0, ngvar := 0, ntunits := 0,;
      nequi := 0, ntequi := 0, cgrdesc

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"YEAR"        ,"C",01,0},;
                                 {"GRADE"       ,"N",05,3}},{||cdxgrdave()})
        dbcloseall()
        return(nil)
endif
memvar->grdave := memvar->cdummy
if(afile := openwcheck({{,,(memvar->grdave+".TXT"),"grdave",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
grdave->(__dbzap());grdave->(dbreindex())

if cyear == "1"
        cyeardesc := "FIRST YEAR"
elseif cyear == "2"
        cyeardesc := "SECOND YEAR"
elseif cyear == "3"
        cyeardesc := "THIRD YEAR"
elseif cyear == "4"
        cyeardesc := "FOURTH YEAR"
else
        cyeardesc := "FIFTH YEAR"
endif
if cgrade == "M"
        cgrdesc := "MIDTERM GRADE"
else
        cgrdesc := "FINAL GRADE"
endif
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
*aadd(abtext,{||chr(27)+"P"})
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+;
                                              "Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Pardo, Cebu City",nmaxcol))+;
                              "Bulacao, Pardo, Cebu City"})
aadd(abtext,{||""})
if cscope == "D"
        aadd(abtext,{||space(titlepos("STUDENTS' DEANS LISTER",nmaxcol))+"STUDENTS' DEANS LISTER"})
elseif cscope == "T"
        aadd(abtext,{||space(titlepos("TOP 100 STUDENTS",nmaxcol))+"TOP 100 STUDENTS"})
elseif cscope == "R"
        aadd(abtext,{||space(titlepos("STUDENTS RANKING",nmaxcol))+"STUDENTS RANKING"})
endif
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(cyeardesc,nmaxcol))+cyeardesc})
aadd(abtext,{||space(titlepos(cgrdesc,nmaxcol))+cgrdesc})
aadd(abtext,{||""})
if ctype == "P"
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
else
        aadd(abtext,{||"        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.W.A."})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ------  ------"})
endif

/*
FIRST YEAR

        ID.NO.      LAST NAME           FIRST NAME          M  COURSE  G.P.A.
       --------  ---------------  ------------------------  -  ------  ------
1234.) 12345678  123456789012345  123456789012345678901234  1  123456  12.123
*/


cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        nctr := ngvar := nequi := ntequi := ntgrade := ntunits := 0
        lprocess := .f.
        fask(10,"  Processing id-no."+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
        cyytstsp->(sx_setscope(_TOP_SCOPE   ,cyytenrp->enridno))
        cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cyytenrp->enridno))
        cyytstsp->(dbgotop())
        do while ! cyytstsp->(eof())
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        do case
                                case cgrade == "M"
                                    if val(cyytstsp->stsmidgrd) > 0
                                        if val(cyytstsp->stsmidgrd) >= 10 .and. val(cyytstsp->stsmidgrd) <= 30
                                                if ctype == "P"  //&&GPA
                                                        ngvar := val(cyytstsp->stsmidgrd) / 10
                                                        ntgrade += ngvar
                                                elseif ctype == "W"  //&&GWA
                                                        ngvar   := val(cyytstsp->stsmidgrd) / 10
                                                        nequi   := ngvar * cyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                                //exit
                                        endif
                                    endif
                                case cgrade == "F"

                                    if val(cyytstsp->stsfingrd) > 0
                                        if val(cyytstsp->stsfingrd) >= 10 .and. cyytstsp->stsfingrd <= 30
                                                if ctype == "P"  //&&GPA
                                                        ntgrade += (val(cyytstsp->stsfingrd) / 10)
                                                else  //&&GWA
                                                        nequi   := (val(cyytstsp->stsfingrd) / 10) * cyytskdp->skdunt
                                                        ntequi  += nequi
                                                        ntunits += cyytskdp->skdunt
                                                endif
                                                lprocess := .t.
                                                ++nctr
                                        else
                                                lprocess := .f.
                                               // exit
                                        endif
                                    endif
                        endcase
                endif
                cyytstsp->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
        enddo
        if lprocess
                grdave->(dbappend())
                grdave->idno    := c999sm1p->sm1idno
                grdave->lname   := c999sm1p->sm1lstnam
                grdave->fname   := c999sm1p->sm1fstnam
                grdave->mname   := c999sm1p->sm1midnam
                c999colp->(dbseek(ccolcode))
                grdave->course  := c999colp->coldesabr
                if ctype == "P"  //&&GPA
                        grdave->grade := ntgrade / nctr
                else  //&&GWA
                        grdave->grade := ntequi / ntunits
                endif
        endif
        cyytstsp->(clearscope())
        cyytstsp->(dbclearrelation())
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelaton())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
grdave->(dbgotop())
do while ! grdave->(eof())
        fask(10,"  Printing name "+alltrim(grdave->lname)+", "+alltrim(grdave->fname)+" "+grdave->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if cscope == "T"  /* Top 100 */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
                if nctr == 100
                        exit
                endif
        elseif cscope == "D"  /* deans lister */
                if grdave->grade <= 1.5
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                             grdave->idno   + space(02) + ;
                                             grdave->lname  + space(02) + ;
                                             grdave->fname  + space(02) + ;
                                             grdave->mname  + space(02) + ;
                                             grdave->course + space(02) + ;
                                             transform(grdave->grade,"9.999"))
                endif
        elseif cscope == "R"  /* stundets ranking (all) */
                outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+".) "+;
                                     grdave->idno   + space(02) + ;
                                     grdave->lname  + space(02) + ;
                                     grdave->fname  + space(02) + ;
                                     grdave->mname  + space(02) + ;
                                     grdave->course + space(02) + ;
                                     transform(grdave->grade,"9.999"))
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        grdave->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

//FUNCTION TOR FOR UC MAIN NGA GE REKLAMO SA GOBYERNO
function formainkaduhangtor()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,bprint,cprocsts,cfile,ccdx,;
      cidno,cnceeper,cyrtaken,cexamno,cpurpose,n99,cbarhead,corno,cdategrad,;
      cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder,ladder,ctorcont,;
      ctordate,ctorserial
private navfile:="reptor"+strzero(memvar->naccess,2),navtor,afile
if(aprvsetup := openwcheck({{,,"c999torp",,_DBF_SHARED,,1},;
                            {,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999grad",,_DBF_SHARED,,1},;
                            {,,"oldcuraj",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"torcont",,_DBF_SHARED,,1},;
                            {,,"PARA",,_DBF_SHARED,,},;
                            {,,"c999sm2p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Transcript of Record Printing  ")
commandline("³           F4 - View Student          ³              ESC - Previous           ³")
aentryscr := savescr(01,00,24,79)

//fask(10,"  User level ==> "+memvar->clevel+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

if ! alltrim(memvar->clevel) == "P"
        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")
//        fask(10,"  TOR Serial: "+LEFT(ctorcont,7)+" <----- ",{" Ok "},memvar->colorarray[05],.t.,nil)
        para->(reclock())
        para->torserial      := LEFT(ctorcont,7)
        para->(dbcommit())
        para->(dbunlock())
else
        ctorcont  := "SN#"
endif

cidno     := space(len(c999sm1p->sm1idno))
cnceeper  := "N.A."
cyrtaken  := "N.A."
cexamno   := "N.A.      "
cpurpose  := "FOR EVALUATION"+space(36)
cprepared := memvar->cuserfname + space(30-len(memvar->cuserfname))
//cprepared := "LAURA C. TEMPLADO"+space(13)
cchecked  := "JOVITA  A. QUIÑANOLA"+space(11)
//cchecked  := strtran(cchecked,"¥","Å")
cchecked  := strtran(cchecked,"¥",chr(165))
cflag     := " "
sporderno := space(20)
sporderdte:= ctod("  /  /  ")
seriesno  := space(4)
ladder    := space(1)
nstpact   := space(20)
ctordate  := ctod("  /  /  ")
ctorserial:= space(8)
cregistrar:= "EDGAR J. ESGUERRA"+space(13)
cposition := "REGISTRAR"+space(11)

create_navfile()
do while .t.
        sporder := 0
        navtor->(__dbzap());navtor->(dbreindex())
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number        :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)
        read
        if lastkey() == K_ESC
                exit
        endif
        if !c999sm1p->(dbseek(cidno))
                fask(10,"  Student Number : "+cidno+" not found  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if c999sm2p->(dbseek(cidno))
                corno      := c999sm2p->sm2paynum
                cdategrad  := c999sm2p->sm2dgradas
                cdategrad1 := c999sm2p->sm2dgradbs
                cdateadmit := c999sm2p->sm2dadmit
                chonrec    := c999sm2p->sm2honors
                sporderno  := c999sm2p->sm2sono
                sporderdte := c999sm2p->sm2sodate
                seriesno   := c999sm2p->sm2series
        else
                c999sm2p->(dbappend())
                c999sm2p->sm2idno := cidno
                corno     := space(10)
                cdategrad := ctod("  /  /  ")
                cdategrad1:= ctod("  /  /  ")
                cdateadmit:= ctod("  /  /  ")
                chonrec   := space(20)
                sporderno := space(20)
                sporderdte:= ctod("  /  /  ")
                seriesno  := space(4)
        endif

        @ 03,02 say "NCEE Percentile       :";
                color memvar->colorarray[02];
                get cnceeper    pict "@!"
        @ 04,02 say "Year Taken            :";
                color memvar->colorarray[02];
                get cyrtaken    pict "@!"
        @ 05,02 say "Examinee Number       :";
                color memvar->colorarray[02];
                get cexamno     pict "@!"
        @ 06,02 say "Purpose               :";
                color memvar->colorarray[02];
                get cpurpose    pict "@!"
        @ 07,02 say "Prepared by           :";
                color memvar->colorarray[02];
                get cprepared   pict "@!"
        @ 08,02 say "Noted by              :";
                color memvar->colorarray[02];
                get cchecked    pict "@!";
                valid ! empty(cchecked)

        @ 09,02 say "Registrar Head        :";
                color memvar->colorarray[02];
                get cregistrar    pict "@!";
                valid ! empty(cregistrar)

        @ 10,02 say "Payment Number        :";
                color memvar->colorarray[02];
                get corno       pict "@!"
        @ 11,02 say "Date Graduated (AS)   :";
                color memvar->colorarray[02];
                get cdategrad   //pict "@!"
        @ 12,02 say "Date Graduated (BS)   :";
                color memvar->colorarray[02];
                get cdategrad1   //pict "@!"
        @ 13,02 say "Date Admitted         :";
                color memvar->colorarray[02];
                get cdateadmit   //pict "@!"
        @ 14,02 say "Honor Received        :";
                color memvar->colorarray[02];
                get chonrec   pict "@!"

        @ 15,02 say "Special Order No.     :";
                color memvar->colorarray[02];
                get sporderno pict "@!"
        @ 16,02 say "Dated                 :";
                color memvar->colorarray[02];
                get sporderdte //pict "@!"
        @ 17,02 say "Series of             :";
                color memvar->colorarray[02];
                get seriesno pict "@!"
        @ 18,02 say "NSTP Serial No.       :";
                color memvar->colorarray[02];
                get nstpact pict "@!"
               
        @ 19,02 say "TOR Date              :";
                color memvar->colorarray[02];
                get ctordate
        @ 20,02 say "TOR Serial Number     :";
                color memvar->colorarray[02];
                get ctorserial
/*        @ 20,02 say "Name of Registrar     :";
                color memvar->colorarray[02];
                get cregistar   pict "@!"
        @ 21,02 say "Position              :";
                color memvar->colorarray[02];
                get cposition   pict "@!"
*/

/*        @ 16,02 say "Ladderized Program?   :";
                color memvar->colorarray[02];
                get ladder pict "Y";
                valid !empty(ladder)
*/
        read

        if len(alltrim(sporderno))!=0 .and. len(alltrim(seriesno))!=0
                sporder:=2
        endif

        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")

        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        nptor(cidno) //&& additional function for mellinium compliance

        if c999sm2p->(dbseek(cidno))
                c999sm2p->(reclock())
                c999sm2p->sm2paynum := corno
                c999sm2p->sm2dgradas := cdategrad
                c999sm2p->sm2dgradbs := cdategrad1
                c999sm2p->sm2dadmit  := cdateadmit
                c999sm2p->sm2honors  := chonrec
                c999sm2p->sm2sono    := sporderno
                c999sm2p->sm2sodate  := sporderdte
                c999sm2p->sm2series  := seriesno
                c999sm2p->(dbcommit())
                c999sm2p->(dbunlock())
        endif
        if ! alltrim(memvar->clevel) == "P"
                torcont->(dbappend())
                torcont->torserial   := ctorcont
                torcont->toridno     := cidno
                torcont->tordate     := date()
                torcont->rectrail    := dtoc(date())+","+time()+","+memvar->cusername
                torcont->(dbcommit())
                torcont->(dbunlock())
        endif

        if empty(cdategrad1)
            cdategrad1 := cdategrad
        endif

        if whereprint({||kaduhangptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                 viewtextfile()
        endif
enddo
restscr(alastscr)
closewcheck(aprvsetup)
navtor->(dbclosearea())
memvar->navfile+=".*"
ferase(memvar->navfile)
return(nil)


//TRANSCRIPT OF RECORD PRINTING UC-MAIN NGA GE REKLAMO SA GOBYERNO
function kaduhangptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition)
local afile,nline := 0, nctr := 0, nctrunt := 0, cnterm:=space(3), lterm:=space(3), ;
      cintcod,cfingrd,ccomgrd,ctrmdesc,ncredit:=0,ccredit:=space(3),yrlevel:=" ",;
      bgrad := 0, cint_cod, nunit := 0, addunit := 0, ccors, npage := 1, srchvess := 0, cyytappp, apterm

//ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"
/*
//if ! alltrim(memvar->clevel) == "P"
//        ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"
//else
//      ctorcont  := "testingSN#"
//endif
*/

kaduhangtorfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
torheader()

navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))

navtor->(dbgotop())
do while ! empty(navtor->torintcd01) .and. ! navtor->(eof())
        lterm := right(navtor->torschtrm,3)
        navtor->(dbskip())
enddo
//fask(10,"  Term: "+lterm+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

//navtor->(sx_SetTagOrder(3))
navtor->(dbgotop())
do while ! navtor->(eof())
        yrlevel := navtor->toryrlevl
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.F.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := alltrim(if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "A","FIRST "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "B","SECOND "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "C","THIRD "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1))))))))+;
                    if(!empty(alltrim(navtor->torinst))," w/ PERMIT","")
        if (prow() >= 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
        endif

        if empty(navtor->torintcd01)
           if bgrad == 0
                if c999colp->colcod $ "MT,MV,ME,MI,MO,MS,PA,SN,YN,BN,NW,HN,NV"
                   @ prow()+01,18 say "ONE YEAR APPRENTICESHIP/SHIPBOARD TRAINING   WITH LOG BOOK"
                   @ prow()+00,18 say replicate("_",44)
                elseif c999colp->colcod $ "MA,MM,MR,MB,MD,MP,EN,EL,SM,YM,BM,MW,HM,NM"
                   @ prow()+01,18 say "ONE YEAR APPRENTICESHIP/SHIPBOARD TRAINING   WITH LOG BOOK"
                   @ prow()+00,18 say replicate("_",44)
                elseif c999colp->colcod == "CS"
                   if yrlevel == "2"
                   @ prow()+01,18 say "APPRENTICE ON BOARD"
                   @ prow()+00,18 say replicate("_",19)
                   end if
                endif
                bgrad := 1
           endif

//           fask(10,"  "+alltrim(str(c999sm1p->sm1schtrm))+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
           if srchvess == 0
           if alltrim(c999colp->coldesabr)=="CS"
                   @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I",if(navtor->toryrlevl=="2","II","III"))+")"+space(2)+ctrmdesc
                   @ prow()+00,02 say replicate("_",13)+if(navtor->toryrlevl=="3","_","_ ")+space(2)+replicate("_",len(alltrim(ctrmdesc)))
           elseif padl(alltrim(str(c999sm1p->sm1schtrm)),3,"0") >= "031" .and. ;
                  padl(alltrim(str(c999sm1p->sm1schtrm)),3,"0") <= "221"
//                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl//+space(8)+ctrmdesc
                   @ prow()+00,02 say ;
                        if(alltrim(c999colp->colcod)=="MA","BSMARE",;
                        if(alltrim(c999colp->colcod)=="MT","BSMT",;
                           c999colp->coldesabr))+" "+navtor->toryrlevl//+space(6)+ctrmdesc
                   @ prow()+00,02 say replicate("_",10)//+space(6)+replicate("_",len(alltrim(ctrmdesc)))
           else
                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl//+space(6)+ctrmdesc
                 //  @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
           endif

           c999torp->(dbseek(cidno+cnterm))
                if c999colp->colcod != "CS"
//                if (left(cidno,2) >= "01") .and. (left(cidno,2) <= "10")
                        @ prow()+01,57 say if(empty(c999torp->torapgrd),"---"+space(10)+"40",;
                                           if(val(c999torp->torapgrd) > 0,;
                                           left(c999torp->torapgrd,1)+"."+right(c999torp->torapgrd,1)+space(11)+"40",c999torp->torapgrd))
          //edited by KENN JULY 5, 2012
                elseif c999colp->colcod = "CS"
                        @ prow()+01,57 say if(empty(c999torp->torapgrd),"---"+space(10)+"7",;
                                           if(val(c999torp->torapgrd) > 0,;
                                           left(c999torp->torapgrd,1)+"."+right(c999torp->torapgrd,1)+space(11)+"7",c999torp->torapgrd))
                endif
           @ prow()+01,02 say "VESSEL"+space(15)+"EMBARKATION"+space(08)+"DISEMBARKATION"+space(5)+"GROSS TONNAGE"
           srchvess = 1
           endif
        cyytappp := alltrim("c"+cnterm+"appp")
        if(aprvsetup := openwcheck({{,,"c999appp",,_DBF_SHARED,,1},;
                         {,, cyytappp ,"cyytappp",_DBF_SHARED,,11}})) == nil
                return(nil)
        endif

       //----------------REVISED BY MARINA 5/20/2015
        cyytappp->(sx_settagorder(11))
        cyytappp->(dbgotop())
        do while ! cyytappp->(eof())

           if cyytappp->appidno == cidno
                @ prow()+01,02 say alltrim(cyytappp->appvesname)
                @ prow()+00,23 say upper(cmonth(cyytappp->appembark))+str(day(cyytappp->appembark))+","+str(year(cyytappp->appembark))
                @ prow()+00,42 say upper(cmonth(cyytappp->appdembark))+str(day(cyytappp->appdembark))+","+str(year(cyytappp->appdembark))
                @ prow()+00,60 say transform(cyytappp->appgrston,"9,999,999.99")
           endif
           cyytappp->(dbskip())
        enddo

/*
           @ prow()+01,02 say "NAME OF VESSEL     : "+c999torp->torvesname
           @ prow()+01,02 say "PROPRIETOR         : "+c999torp->torvesown
           @ prow()+01,02 say "GROSS TONS         : "+transform(c999torp->torgrston,"9,999,999.99")
//           @ prow()+01,02 say "DATE OF EMBARKATION: "+upper(cmonth(c999torp->torembark))+str(day(c999torp->torembark))+","+str(year(c999torp->torembark))
           @ prow()+01,02 say "DATE OF EMBARKATION: "+format_date(c999torp->torembark)
*/
        else
           if !empty(navtor->torinst)
                   @ prow()+01,18 say alltrim(navtor->torinst)
                   @ prow()+00,18 say replicate("_",len(alltrim(navtor->torinst)))
           endif

           if alltrim(c999colp->coldesabr)=="CS"
                   @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I ","II")+")"+space(3)+ctrmdesc
                   @ prow()+00,02 say replicate("_",13)+space(3)+replicate("_",len(alltrim(ctrmdesc)))
           elseif lterm >= "031" .and. ;
                  lterm <= "221"
//                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(8)+ctrmdesc
                   @ prow()+01,02 say ;
                        if(alltrim(c999colp->colcod)=="MA","BSMARE",;
                        if(alltrim(c999colp->colcod)=="MT","BSMT  ",;
                           c999colp->coldesabr))+" "+navtor->toryrlevl+space(6)+ctrmdesc
                   @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
           else
                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                   @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
           endif

        endif
        for nctr := 1 to 20 //melchor
                nctrunt := 1
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                addunit := 0
                if oldcuraj->(dbseek(navtor->&cintcod))
                        addunit := 1
                        for nctrunt := 1 to 19 //melchor
                            cint_cod := "torintcd"+strzero(nctrunt,2)
                            if navtor->&cint_cod == oldcuraj->courslcod
                                addunit := 0
                                exit
                            endif
                        next
                endif
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                        nunit := c999crsp->crscreunt
                        if addunit == 1
                           nunit += 1
                        endif
                      //  if prow() > 50
                        if prow() >= 39
                                footline()
                                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                                torheader()
                                if alltrim(c999colp->coldesabr)=="CS"
                                        @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I","II")+")"+space(3)+ctrmdesc
                                        @ prow()+00,02 say replicate("_",13)+space(3)+replicate("_",len(alltrim(ctrmdesc)))
                                elseif lterm <= "221" .and. ;
                                       lterm >= "031"
                                        @ prow()+01,02 say ;
                                             if(alltrim(c999colp->colcod)=="MA","BSMARE",;
                                             if(alltrim(c999colp->colcod)=="MT","BSMT",;
                                                c999colp->coldesabr))+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                        @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                                else
                                        @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                        @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                                endif
                        endif
                        
                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1
                        if ! empty(c999crsp->crsdsc2)
                                @ prow()+01,18 say c999crsp->crsdsc2+"   "+;
                                                   if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))

                        elseif empty(c999crsp->crsdsc2)
                                @ prow()+00,57 say ;
                                                   if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))

                                                  // &&if(val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31",transform(c999crsp->crscreunt,"@Z"),transform(0,"99999"))
                        endif
                else
                        exit
                endif
        next

        if nextkey() == K_ESC
                exit
        endif
//        lterm := navtor->torschtrm
        ccors := c999colp->colcod
        navtor->(dbskip())

/* ----------------------------------------------------------------- */

        if (navtor->toryrlevl == "4" .or. c999colp->colcod == "CS") .and. bgrad == 0 .and. empty(navtor->torintcd01)
           if nstpact=="Y"
                outexpr(prow()+01,02,"ROTC  AS  REQUISITE  FOR  GRADUATION  SET-ASIDE  PURSUANT  TO  SECTION 12.")
                outexpr(prow()+01,02,"RULE VI OF THE IMPLEMENTING RULES AND REGULATIONS OF THE NSTP ACT OF 2001,")
                outexpr(prow()+01,02,"WHICH TOOK EFFECT ON MARCH 23, 2002.")
                if (prow() >= 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                        footline()
//                        tefooter1(++npage,cpurpose,corno)
                        kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
                endif
           endif

           if ccors == "ET"
                outexpr(prow()+01,02,"GRADUATED FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE DEGREE OF")
                outexpr(prow()+01,02,+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF "+format_date(cdategrad))
                outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER. UNDER THE")
                outexpr(prow()+01,02,"EXPANDED TERTIARY EDUCATION EQUIVALENCY AND ACCREDITATION PROGRAM (ETEEAP)")
                outexpr(prow()+01,02,"PER EXECUTIVE ORDER NO. 330 DATED MAY 10, 1996.")
           elseif ccors == "ER"
                outexpr(prow()+01,02,"GRADUATED FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE DEGREE")
                outexpr(prow()+01,02,"THE TITLE OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF"+format_date(cdategrad))
                outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER. UNDER THE")
                outexpr(prow()+01,02,"EXPANDED TERTIARY EDUCATION EQUIVALENCY AND ACCREDITATION PROGRAM (ETEEAP)")
                outexpr(prow()+01,02,"PER EXECUTIVE ORDER NO. 330 DATED MAY 10, 1996.")
           elseif ccors == "MT"
                outexpr(prow()+01,02,"GRADUATED FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE ")
                outexpr(prow()+01,02,"THE TITLE OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
                outexpr(prow()+01,02,"OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE ")
                outexpr(prow()+01,02,"OF SPECIAL ORDER.")


           elseif ccors == "EN"
                outexpr(prow()+01,02,"COMPLETED THE REQUIRED SUBJECTS OF THE BRIDGING PROGRAM FROM BACHELOR")
                outexpr(prow()+01,02,"OF SCIENCE IN MECHANICAL ENGINEERING TO BACHELOR OF SCIENCE IN MARINE")
                outexpr(prow()+01,02,"ENGINEERING (BSMARE) AS REQUIRED BY THE COMMISSION ON HIGHER EDUCATION")
                outexpr(prow()+01,02,"(CHED) AND UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA")
                outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")

           elseif ccors == "EL"
                outexpr(prow()+01,02,"COMPLETED THE REQUIRED SUBJECTS OF THE BRIDGING PROGRAM FROM BACHELOR")
                outexpr(prow()+01,02,"OF SCIENCE IN ELECTRICAL ENGINEERING TO BACHELOR OF SCIENCE IN MARINE")
                outexpr(prow()+01,02,"ENGINEERING (BSMARE) AS REQUIRED BY THE COMMISSION ON HIGHER EDUCATION")
                outexpr(prow()+01,02,"(CHED) AND UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA")
                outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")

           elseif ccors == "AM"
                outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
                outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF ASSOCIATE IN")
                outexpr(prow()+01,02,"MARINE ENGINEERING (A.MAR.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
                outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
 //SF ADDED APRIL 18, 2016
           elseif ccors == "SF"
                outexpr(prow()+01,02,"COMPLETED THE THEORETICAL REQUIREMENT LEADING TO THE COMPLETION OF THE")
                outexpr(prow()+01,02,"STEEL FABRICATION TECHNOLOGY PROGRAM")
                outexpr(prow()+01,02,"AS OF "+format_date(cdategrad)+".")

           elseif sporder==2 .and. ! c999colp->colcod == "CS"
                outexpr(prow()+01,02,"GRADUATED FROM THE "+yrlevel+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH")
                outexpr(prow()+01,02,"THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF")
                outexpr(prow()+01,02,format_date(cdategrad)+". PER SPECIAL ORDER (B ) NO. "+alltrim(sporderno)+", S. "+alltrim(seriesno))
                outexpr(prow()+01,02,"DATED "+format_date(sporderdte)+" ISSUED BY DECS, REGION VII, CEBU CITY.")
                sporder  :=0
                seriesno :=""
         //---remove by jun for eteeap
           elseif lterm >= "031" .and. ;
                  lterm <= "221" .and. ;
                ccors != "CS"
                outexpr(prow()+01,02,"COMPLETED THE THREE-YEAR THEORETICAL REQUIREMENTS OF THE COURSE LEADING TO THE")
                outexpr(prow()+01,02,"DEGREE  OF  BACHELOR  OF  SCIENCE  IN "+alltrim(c999colp->colnamcol)+" "+if(alltrim(c999colp->colcod)=="MT"," (B.S.M.T.)",if(alltrim(c999colp->colcod)=="MA"," (B.S.MAR.E)","("+alltrim(c999colp->colnamabr2)+")")))
                outexpr(prow()+01,02,"AS   REQUIRED  BY  THE   COMMISSION  ON  HIGHER  EDUCATION  (CHED)  AND")
                outexpr(prow()+01,02,"UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
                outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
                
 //SF ADDED APRIL 18, 2016
           elseif ccors == "SF"
                outexpr(prow()+01,02,"COMPLETED THE THEORETICAL REQUIREMENT LEADING TO THE COMPLETION OF THE")
                outexpr(prow()+01,02,"STEEL FABRICATION TECHNOLOGY PROGRAM")
                outexpr(prow()+01,02,"AS OF "+format_date(cdategrad)+".")
   //  elseif ccors != "CS"
         //       outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol))
         //       outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")")
         //       outexpr(prow()+01,02,"AS OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
         //      outexpr(prow()+01,02,"OF SPECIAL ORDER.")
         // lines below are added by Jun (ETEEAP)
         // else
         //       outexpr(prow()+01,02,"COMPLETED  THE  THEORETICAL  REQUIREMENTS  OF THE COURSE LEADING TO THE")
         //       outexpr(prow()+01,02,"DEGREE  OF  BACHELOR  OF  SCIENCE  IN "+alltrim(c999colp->colnamcol)+" "+if(alltrim(c999colp->colcod)=="MT"," (B.S.M.T.)",if(alltrim(c999colp->colcod)=="MA"," (B.S.MAR.E)","("+alltrim(c999colp->colnamabr2)+")")))
         //       outexpr(prow()+01,02,"AS   REQUIRED  BY  THE   COMMISSION  ON  HIGHER  EDUCATION  (CHED)  AND")
         //       outexpr(prow()+01,02,"UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+".")
           endif

           if (prow() >= 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
//                tefooter1(++npage,cpurpose,corno)
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
           endif
           if c999colp->colcod $ "MT,MV,ME,MI,MO,MS,PA,SN,YN,BN,NW,NV,HN"
                @ prow()+01,18 say "ONE YEAR APPRENTICESHIP/SHIPBOARD TRAINING   WITH LOG BOOK"
                @ prow()+00,18 say replicate("_",44)
           elseif c999colp->colcod $ "MA,MM,MR,MB,MD,MP,AM,EN,EL,SM,YM,BM,MW,NM,HM"
                @ prow()+01,18 say "ONE YEAR APPRENTICESHIP/SHIPBOARD TRAINING   WITH LOG BOOK"
                @ prow()+00,18 say replicate("_",44)
           elseif c999colp->colcod == "CS" .and. yrlevel = "2"
                @ prow()+01,18 say "APPRENTICE ON BOARD"
                @ prow()+00,18 say replicate("_",19)

           endif
           bgrad := 1
        endif
/* ----------------------------------------------------------------- */

        if navtor->toryrlevl == "2" .and. c999colp->colcod == "RO" ;
                   .and. bgrad == 0 .and. (empty(navtor->torintcd01))
           outexpr(prow()+01,02,"GRADUATED FROM THE SPECIAL ACADEMIC PROGRAM IN MARINE TRANSPORTATION")
           outexpr(prow()+01,02,"COURSE FOR  MARINE RADIO OPERATORS  WITH THE TITLE OF  ASSOCIATE IN")
           outexpr(prow()+01,02,"MARINE TRANSPORTATION (A.M.T.)  AS OF "+format_date(cdategrad)+". PACUCOA")
           outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
           if (prow() > 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
//                tefooter1(++npage,cpurpose,corno,npage)
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
           endif
           bgrad := 1

        endif
/* ----------------------------------------------------------------- */
// for bridging program
        if navtor->toryrlevl == "4" .and. c999colp->colcod == "EN" ;
                   .and. bgrad == 0 .and. (empty(navtor->torintcd01))
           outexpr(prow()+01,02,"GRADUATED FROM MARINE ENGINEERING COURSE UNDER THE BRIDGING")
           outexpr(prow()+01,02,"PROGRAM WITH DEGREE OF BACHELOR OF SCIENCE IN MARINE ENGINEERING")
           outexpr(prow()+01,02,"(BSMARE) AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
           outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
           if (prow() > 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
           endif
           bgrad := 1

        endif
        if navtor->toryrlevl == "3" .and. c999colp->colcod == "MT" ;
                   .and. bgrad == 0 .and. (empty(navtor->torintcd01))
           outexpr(prow()+01,02,"GRADUATED FROM 3-YEAR COURSE IN MARINE TRANSPORTATION WITH")
           outexpr(prow()+01,02,"THE TITLE OF ASSOCIATE IN MARINE TRANSPORTATION (A.M.T.) AS")
           outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
           outexpr(prow()+01,02,"OF SPECIAL ORDER.")
           if (prow() > 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
           endif
           bgrad := 1

        endif

        if navtor->toryrlevl == "4" .and. c999colp->colcod == "EL" ;
                   .and. bgrad == 0 .and. (empty(navtor->torintcd01))
           outexpr(prow()+01,02,"GRADUATED FROM MARINE ENGINEERING COURSE UNDER THE BRIDGING")
           outexpr(prow()+01,02,"PROGRAM WITH DEGREE OF BACHELOR OF SCIENCE IN MARINE ENGINEERING")
           outexpr(prow()+01,02,"(BSMARE) AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
           outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
           if (prow() > 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                torheader()
           endif
           bgrad := 1

        endif

/* ----------------------------------------------------------------- */
enddo
navtor->(clearscope())

//if(val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31",(if (c999crsp->crscreunt),transform(c999crsp->crscreunt,"999.9"),transform(c999crsp->crscreunt,"999")),transform(0,"99999")))
//navtor->(sx_SetTagOrder(1))

if nstpact=="Y" .and. bgrad==0
        outexpr(prow()+01,02,"ROTC  AS  REQUISITE  FOR  GRADUATION  SET-ASIDE  PURSUANT  TO  SECTION 12.")
        outexpr(prow()+01,02,"RULE VI OF THE IMPLEMENTING RULES AND REGULATIONS OF THE NSTP ACT OF 2001,")
        outexpr(prow()+01,02,"WHICH TOOK EFFECT ON MARCH 23, 2002.")
endif

if c999colp->colcod == "MB"
        outexpr(prow()+01,02,"COMPLETED FROM THE FIRST "+yrlevel+"-YEARS IN BSMARE COURSE LADDERIZED")
        outexpr(prow()+01,02,"CURRICULUM WITH THE CERTIFICATE IN MARINE ENGINEERING (C.M.E.) AS OF")
        outexpr(prow()+01,02,format_date(cdategrad)+".")

/*        outexpr(prow()+01,02,"COMPLETED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
        outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF CERTIFICATE")
        outexpr(prow()+01,02,"IN MARINE ENGINEERING (C.M.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
*/
elseif sporder==2 .and. ! c999colp->colcod == "CS"
        outexpr(prow()+01,02,"GRADUATED FROM THE "+yrlevel+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH")
        outexpr(prow()+01,02,"THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF")
        outexpr(prow()+01,02,format_date(cdategrad)+". PER SPECIAL ORDER (B ) NO. "+alltrim(sporderno)+", S. "+alltrim(seriesno))
        outexpr(prow()+01,02,"DATED "+format_date(sporderdte)+" ISSUED BY DECS, REGION VII, CEBU CITY.")
        //outexpr(prow()+01,02,"DATED "+format_date(cdategrad1)+" ISSUED BY DECS, REGION VII, CEBU CITY.")
//added for NIS & Alpha
elseif  c999colp->colcod $ "MI,MR,PA,MP,MH"
        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol))
        outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")")
        outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
        outexpr(prow()+01,02,"OF SPECIAL ORDER.")
//added for NIS & Alpha
elseif c999colp->colcod == "AM"
        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
        outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF ASSOCIATE IN")
        outexpr(prow()+01,02,"MARINE ENGINEERING (A.MAR.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "RO" .and. yrlevel == "1"
        outexpr(prow()+01,02,"GRADUATED FROM THE SPECIAL ACADEMIC PROGRAM IN MARINE TRANSPORTATION")
        outexpr(prow()+01,02,"COURSE FOR  MARINE RADIO OPERATORS  WITH THE TITLE OF  ASSOCIATE IN")
        outexpr(prow()+01,02,"MARINE TRANSPORTATION - MRO (A.M.T. - MRO )  AS OF "+format_date(cdategrad)+".")
        outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "EN" .and. yrlevel == "3"
        outexpr(prow()+01,02,"COMPLETED THE REQUIRED SUBJECTS OF THE BRIDGING PROGRAM FROM BACHELOR")
        outexpr(prow()+01,02,"OF SCIENCE IN MECHANICAL ENGINEERING TO BACHELOR OF SCIENCE IN MARINE")
        outexpr(prow()+01,02,"ENGINEERING (BSMARE) AS REQUIRED BY THE COMMISSION ON HIGHER EDUCATION")
        outexpr(prow()+01,02,"(CHED) AND UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "EL" .and. yrlevel == "3"
        outexpr(prow()+01,02,"COMPLETED THE REQUIRED SUBJECTS OF THE BRIDGING PROGRAM FROM BACHELOR")
        outexpr(prow()+01,02,"OF SCIENCE IN ELECTRICAL ENGINEERING TO BACHELOR OF SCIENCE IN MARINE")
        outexpr(prow()+01,02,"ENGINEERING (BSMARE) AS REQUIRED BY THE COMMISSION ON HIGHER EDUCATION")
        outexpr(prow()+01,02,"(CHED) AND UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "MT" .and. yrlevel == "3"
        outexpr(prow()+01,02,"GRADUATED FROM THE 3-YEAR COURSE IN MARINE TRANSPORTATION WITH")
        outexpr(prow()+01,02,"THE TITLE OF ASSOCIATE IN MARINE TRANSPORTATION (A.M.T.) AS ")
        outexpr(prow()+01,02,"ENGINEERING (BSMARE) AS REQUIRED BY THE COMMISSION ON HIGHER EDUCATION")
        outexpr(prow()+01,02,"OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROMT THE ISSUANCE")
        outexpr(prow()+01,02,"OF SPECIAL ORDER.")
elseif c999colp->colcod == "ET"
        outexpr(prow()+01,02,"GRADUATED FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE DEGREE OF")
        outexpr(prow()+01,02,+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF "+format_date(cdategrad))
        outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER. UNDER THE")
        outexpr(prow()+01,02,"EXPANDED TERTIARY EDUCATION EQUIVALENCY AND ACCREDITATION PROGRAM (ETEEAP)")
        outexpr(prow()+01,02,"PER EXECUTIVE ORDER NO. 330 DATED MAY 10, 1996.")
elseif c999colp->colcod == "ER"
        outexpr(prow()+01,02,"GRADUATED FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE DEGREE OF")
        outexpr(prow()+01,02,+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS OF "+format_date(cdategrad))
        outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER. UNDER THE")
        outexpr(prow()+01,02,"EXPANDED TERTIARY EDUCATION EQUIVALENCY AND ACCREDITATION PROGRAM (ETEEAP)")
        outexpr(prow()+01,02,"PER EXECUTIVE ORDER NO. 330 DATED MAY 10, 1996.")
elseif c999colp->colcod == "EN" .and. yrlevel == "4"
        outexpr(prow()+01,02,"GRADUATED FROM MARINE ENGINEERING COURSE UNDER THE BRIDGING")
        outexpr(prow()+01,02,"PROGRAM WITH DEGREE OF BACHELOR OF SCIENCE IN MARINE ENGINEERING")
        outexpr(prow()+01,02,"(BSMARE) AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
        outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "EL" .and. yrlevel == "4"
        outexpr(prow()+01,02,"GRADUATED FROM MARINE ENGINEERING COURSE UNDER THE BRIDGING")
        outexpr(prow()+01,02,"PROGRAM WITH DEGREE OF BACHELOR OF SCIENCE IN MARINE ENGINEERING")
        outexpr(prow()+01,02,"(BSMARE) AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
        outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "RO" .and. !(yrlevel == "1")
        outexpr(prow()+01,02,"GRADUATED FROM THE SPECIAL ACADEMIC PROGRAM IN MARINE TRANSPORTATION")
        outexpr(prow()+01,02,"COURSE FOR  MARINE RADIO OPERATORS  WITH THE DEGREE OF BACHELOR OF")
        outexpr(prow()+01,02,"SCIENCE IN MARINE TRANSPORTATION (B.S.M.T.)  AS OF "+format_date(cdategrad1)+".")
        outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "CS" .and. yrlevel == "1"
                outexpr(prow()+01,02,"COMPLETED THE THEORETICAL REQUIREMENTS OF THE ONE-YEAR ")
                outexpr(prow()+01,02,"SEAFARER'S CATERING/STEWARDING COURSE (SCS) AS OF "+format_date(cdategrad1)+".")
elseif c999colp->colcod == "SF"
                outexpr(prow()+01,02,"COMPLETED THE THEORETICAL REQUIREMENT LEADING TO THE COMPLETION ")
                outexpr(prow()+01,02,"OF THE STEEL FABRICATION TECHNOLOGY PROGRAM AS OF "+format_date(cdategrad)+".")

elseif c999colp->colcod == "CS" .and. yrlevel == "2"
       if alltrim(sporderno) == ""
/*
                outexpr(prow()+01,02,"GRADUATED FROM THE ONE YEAR COURSE IN SEAFARER'S CATERING/STEWARDING ")
                outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+".  SPECIAL ORDER APPLIED FOR.")
*/

                outexpr(prow()+01,02,"RECOMMENDED FOR GRADUATION TOWARDS THE ONE YEAR COURSE IN SEAFARER'S ")
                outexpr(prow()+01,02,"CATERING STEWARDING COURSE (CSC) AS OF "+format_date(cdategrad1)+".")
        else
                outexpr(prow()+01,02,"GRADUATED FROM THE ONE YEAR COURSE IN SEAFARER'S CATERING/STEWARDING ")
                outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+".  PER SPECIAL ORDER (D ) NO. "+alltrim(sporderno)+", S. "+alltrim(seriesno))
                outexpr(prow()+01,02,"DATED "+format_date(sporderdte)+" ISSUED BY TESDA, REGION VII, CENTRAL VISAYAS.")
        endif
//---remove by jun for eteeap

elseif padl(alltrim(str(c999sm1p->sm1schtrm)),3,"0") >= "031" .and. ;
       padl(alltrim(str(c999sm1p->sm1schtrm)),3,"0") <= "221" .and. ;
       bgrad == 0
       
        outexpr(prow()+01,02,"COMPLETED  THE THREE-YEAR THEORETICAL REQUIREMENTS OF THE COURSE LEADING TO THE")
        outexpr(prow()+01,02,"DEGREE  OF  BACHELOR  OF  SCIENCE  IN "+alltrim(c999colp->colnamcol)+" "+if(alltrim(c999colp->colcod)=="MT"," (B.S.M.T.)",if(alltrim(c999colp->colcod)=="MA"," (B.S.MAR.E)","("+alltrim(c999colp->colnamabr2)+")")))
        outexpr(prow()+01,02,"AS   REQUIRED  BY  THE   COMMISSION  ON  HIGHER  EDUCATION  (CHED)  AND")
        outexpr(prow()+01,02,"UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE")
        outexpr(prow()+01,02,"ISSUANCE OF SPECIAL ORDER.")
else
//original        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec) .and. !empty(navtor->torintcd01) ,alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol) + " WITH THE")
        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol)+" WITH THE")
        outexpr(prow()+01,02,if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+") AS")
        outexpr(prow()+01,02,"OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF ")
        outexpr(prow()+01,02,"SPECIAL ORDER.")

/*
else
        outexpr(prow()+01,02,"COMPLETED  THE  THEORETICAL  REQUIREMENTS  OF THE COURSE LEADING TO THE")
        outexpr(prow()+01,02,"DEGREE  OF  BACHELOR  OF  SCIENCE  IN "+alltrim(c999colp->colnamcol)+" "+if(alltrim(c999colp->colcod)=="MT"," (B.S.M.T.)",if(alltrim(c999colp->colcod)=="MA"," (B.S.MAR.E)","("+alltrim(c999colp->colnamabr2)+")")))
        outexpr(prow()+01,02,"AS   REQUIRED  BY  THE   COMMISSION  ON  HIGHER  EDUCATION  (CHED)  AND")
        outexpr(prow()+01,02,"UNIVERSITY OF CEBU AS OF "+format_date(cdategrad)+".")
*/

endif
        outexpr(prow()+01,02,replicate("-",74))
        outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")
//        tefooter2(++npage,cpurpose,corno,npage,ctorcont)
        kaduhatefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
return(nil)

static function kaduhatorfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,ctorcont,cregistrar,cposition)
ccolcod := space(2)
//ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"

/*
if ! alltrim(memvar->clevel) == "P"
        ctorcont  := strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A"
else
        ctorcont  := "testingSN#"
endif
*/

headeject()
setprc(00,00)
outexpr(prow()+06,02,"NAME              :")

/*
outexpr(prow()+00,22,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+   ;
        if(!empty(c999sm1p->sm1midname),c999sm1p->sm1midname,                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
*/

outexpr(prow()+00,22,alltrim(strtran(c999sm1p->sm1lstnam,"¥",chr(165)))+", "+alltrim(strtran(c999sm1p->sm1fstnam,"¥",chr(165)))+" "+   ;
        if(!empty(c999sm1p->sm1midname),strtran(c999sm1p->sm1midname,"¥",chr(165)),                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
outexpr(prow()+01,02,"STUDENT NUMBER    :")
outexpr(prow()+00,22,cidno)
outexpr(prow()+01,02,"SEX               :")
outexpr(prow()+00,22,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
outexpr(prow()+01,02,"CIVIL STATUS      :")
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,22,if(c999sm2p->sm2civsts $ "S ","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE        :")
outexpr(prow()+00,22,format_date(c999sm2p->sm2birdte))
outexpr(prow()+01,02,"BIRTHPLACE        :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY       :")
outexpr(prow()+00,22,c999sm2p->sm2nat)
outexpr(prow()+01,02,"RELIGION          :")
outexpr(prow()+00,22,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN   :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS :")         
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),strtran(c999sm1p->sm1homadr,"¥",chr(165)),"C/O REGISTRAR, UC-PT"))
if(!empty(c999sm1p->sm1homadr2))
        outexpr(prow()+01,02,"                  :")
        outexpr(prow()+00,22,strtran(c999sm1p->sm1homadr2,"¥",chr(165)))
endif
outexpr(prow()+01,02,"DATE ADMITTED     :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,22,format_date(cdateadmit))
outexpr(prow()+01,02,"COLLEGE OF        :")
c999colp->(dbseek(c999sm1p->sm1colcod))
ccolcod := c999sm1p->sm1colcod
outexpr(prow()+00,22,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA     :")
outexpr(prow()+00,22,c999sm2p->sm2entdat)

outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY  :");outexpr(prow()+00,16,trim(c999sm2p->sm2prisc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2priyr)
outexpr(prow()+01,02,"HIGH SCHOOL :");outexpr(prow()+00,16,trim(c999sm2p->sm2secsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH :");outexpr(prow()+00,16,trim(c999sm2p->sm2sh),49)
    outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif


outexpr(prow()+01,02,"COLLEGE     :");outexpr(prow()+00,16,trim(c999sm2p->sm2colsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+02,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")

/*
//outexpr(prow()+03,02,"REMARKS:                                             DATE ISSUED:")
//outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,displaydate(date()))
//outexpr(prow()+03,02,"PREPARED BY:                                         NOTED BY:  ")
//outexpr(prow()+03,02,cprepared)
//outexpr(prow()+00,55,cchecked)
//outexpr(prow()+00,02,replicate("_",22))
//outexpr(prow()+00,55,replicate("_",22))
//outexpr(prow()+04,27,"    FRANCISCO C. SALES    ")
//outexpr(prow()+00,27,"__________________________")
//outexpr(prow()+01,27,"   UNIVERSITY REGISTRAR   ")
//outexpr(prow()+02,04,"NOT VALID WITHOUT SEAL")
//outexpr(prow()+01,04,"    OR NO.________        ")
//outexpr(prow()+00,04,"           "+corno)
//outexpr(prow()+01,04,"        PAGE  1       ")
//__eject()
*/

kaduhatefooter2(1,cpurpose,corno,ctorcont)
return(nil)
//end of kaduhangptor function

/* ------------------------------------------------------------------------------------------------------------------------------------------------ */
//FOR GRADUATED ALREADY( FOR HCS )
function torhcs()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,bprint,cprocsts,cfile,ccdx,;
      cidno,cnceeper,cyrtaken,cexamno,cpurpose,n99,cbarhead,corno,cdategrad,;
      cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder,ladder,ctorcont,;
      ctordate,ctorserial,question := " "
private navfile:="hcstor"+strzero(memvar->naccess,2),navtor,afile
if(aprvsetup := openwcheck({{,,"c999torp",,_DBF_SHARED,,1},;
                            {,,"term"    ,,_DBF_SHARED,,1},;
                            {,,"c999crsp",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1},;
                            {,,"c999grad",,_DBF_SHARED,,1},;
                            {,,"oldcuraj",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"blocklst",,_DBF_SHARED,,1},;
                            {,,"torcont",,_DBF_SHARED,,1},;
                            {,,"PARA",,_DBF_SHARED,,},;
                            {,,"tor_log",,_DBF_SHARED,,5},;
                            {,,"c999sm2p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Transcript of Record Printing (Graduated Already for HCS )  ")
commandline("³           F4 - View Student          ³              ESC - Previous           ³")
aentryscr := savescr(01,00,24,79)


if ! alltrim(memvar->clevel) == "P"
        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")
        para->(reclock())
        para->torserial      := LEFT(ctorcont,7)
        para->(dbcommit())
        para->(dbunlock())
else
        ctorcont  := "SN#"
endif

cidno     := space(len(c999sm1p->sm1idno))
cnceeper  := "N.A."
cyrtaken  := "N.A."
cexamno   := "N.A.      "
cpurpose  := ""+space(36)
cprepared := memvar->cuserfname + space(30-len(memvar->cuserfname))
cchecked  := ""+space(35)



cflag     := " "
sporderno := space(20)
sporderdte:= ctod("  /  /  ")
seriesno  := space(4)
ladder    := space(1)
nstpact   := space(20)
ctordate  := ctod("  /  /  ")
ctorserial:= space(8)
cregistrar:= ""+space(35)
cposition := "REGISTRAR"+space(11)

create_navfile()
do while .t.
        sporder := 0
        navtor->(__dbzap());navtor->(dbreindex())
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Student Number        :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)

        @ 03,02 say "TOR Serial Number     :";
                color memvar->colorarray[02];
                get ctorserial
        read
        if lastkey() == K_ESC
                exit
        endif
        if !c999sm1p->(dbseek(cidno))
                fask(10,"  Student Number : "+cidno+" not found  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if blocklst->(dbseek(cidno)) .and. (blocklst->blkreason != "BOUNCING CHECK")
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        endif

        if c999sm2p->(dbseek(cidno))
                corno      := c999sm2p->sm2paynum
                cdategrad  := c999sm2p->sm2dgradas
                //cdategrad1 := c999sm2p->sm2dgradbs
                cdateadmit := c999sm2p->sm2dadmit
                chonrec    := c999sm2p->sm2honors
                sporderno  := c999sm2p->sm2sono
                sporderdte := c999sm2p->sm2sodate
                seriesno   := c999sm2p->sm2series
        else
                c999sm2p->(dbappend())
                c999sm2p->sm2idno := cidno
                corno     := space(10)
                cdategrad := ctod("  /  /  ")
                cdategrad1:= ctod("  /  /  ")
                cdateadmit:= ctod("  /  /  ")
                chonrec   := space(20)
                sporderno := space(20)
                sporderdte:= ctod("  /  /  ")
                seriesno  := space(4)
        endif

        if tor_log->(dbseek(cidno+LEFT(ctorserial,7)))
            cpurpose := tor_log->purpose        
        else
            cpurpose := space(30)
        endif

        @ 04,02 say "NCEE Percentile       :";
                color memvar->colorarray[02];
                get cnceeper    pict "@!"
        @ 05,02 say "Year Taken            :";
                color memvar->colorarray[02];
                get cyrtaken    pict "@!"
        @ 06,02 say "Examinee Number       :";
                color memvar->colorarray[02];
                get cexamno     pict "@!"
        @ 07,02 say "Purpose               :";
                color memvar->colorarray[02];
                get cpurpose    pict "@!"
        @ 08,02 say "Prepared by           :";
                color memvar->colorarray[02];
                get cprepared   pict "@!"
        @ 09,02 say "Noted by              :";
                color memvar->colorarray[02];
                get cchecked    pict "@!";
                valid !empty(cchecked)

        @ 10,02 say "Registrar Head        :";
                color memvar->colorarray[02];
                get cregistrar    pict "@!";
                valid !empty(cregistrar)

        @ 11,02 say "Payment Number        :";
                color memvar->colorarray[02];
                get corno       pict "@!"
        @ 12,02 say "Date Graduated       :";
                color memvar->colorarray[02];
                get cdategrad   //pict "@!"
      
        @ 13,02 say "Date Admitted         :";
                color memvar->colorarray[02];
                get cdateadmit   //pict "@!"
        @ 14,02 say "Honor Received        :";
                color memvar->colorarray[02];
                get chonrec   pict "@!"

        @ 15,02 say "Special Order No.     :";
                color memvar->colorarray[02];
                get sporderno pict "@!"
        @ 16,02 say "Dated                 :";
                color memvar->colorarray[02];
                get sporderdte //pict "@!"
        @ 17,02 say "Series of             :";
                color memvar->colorarray[02];
                get seriesno pict "@!"
        @ 18,02 say "NSTP Serial No.       :";
                color memvar->colorarray[02];
                get nstpact pict "@!";
                
        @ 19,02 say "TOR Date              :";
                color memvar->colorarray[02];
                get ctordate
  
        
        /*
        @ 20,02 say "            [ 1-W/out Autonomous|2-W/Autonomous|3-Pacucoa|4-W/out STCW|5-SO ]" color memvar->colorarray[02]
        @ 21,02 say "Phrase To Put :";
                color memvar->colorarray[02];
                get question pict "@!";
                valid question $ "12345"
                */
        read


        ctorcont  := if(!empty(ctorserial),ctorserial,strtran(transform(val(left(para->torserial,7))+1,"#######")," ","0")+"A")

        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        nptor(cidno) //&& additional function for millennium compliance

        if c999sm2p->(dbseek(cidno))
                c999sm2p->(reclock()) //update c999sm2p data
                c999sm2p->sm2paynum := corno
                c999sm2p->sm2dgradas := cdategrad
                //c999sm2p->sm2dgradbs := cdategrad1
                c999sm2p->sm2dadmit  := cdateadmit
                c999sm2p->sm2honors  := chonrec
                c999sm2p->sm2sono    := sporderno
                c999sm2p->sm2sodate  := sporderdte
                c999sm2p->sm2series  := seriesno
                c999sm2p->(dbcommit())
                c999sm2p->(dbunlock())
        endif

        tor_log->(recycle()) //INSERT
        tor_log->studidno     := cidno
        tor_log->purpose      := cpurpose
        tor_log->date         := ctordate
        tor_log->preparedby   := cprepared
        tor_log->paynum       := corno
        tor_log->serial       := LEFT(ctorcont,7)
        tor_log->(dbcommit())
        tor_log->(dbunlock())

        if ! alltrim(memvar->clevel) == "P"
                torcont->(dbappend())
                torcont->torserial   := ctorcont
                torcont->toridno     := cidno
                torcont->tordate     := date()
                torcont->rectrail    := dtoc(date())+","+time()+","+memvar->cusername
                torcont->(dbcommit())
                torcont->(dbunlock())
        endif

       

        if whereprint({||hcsptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition,question)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                 viewtextfile()
        endif
enddo
restscr(alastscr)
closewcheck(aprvsetup)
navtor->(dbclosearea())
memvar->navfile+=".*"
ferase(memvar->navfile)
return(nil)


//TRANSCRIPT OF RECORD PRINTING FOR GRADUATED ALREADY
function hcsptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdateadmit,chonrec,sporderno,seriesno,sporder,ctorcont,ctordate,ctorserial,cregistrar,cposition,question)
local afile,nline := 0, nctr := 0, nctrunt := 0, cnterm:=space(3), lterm:=space(3), ;
      cintcod,cfingrd,ccomgrd,ctrmdesc,ncredit:=0,ccredit:=space(3),yrlevel:=" ",;
      bgrad := 0, cint_cod, nunit := 0, addunit := 0, ccors, npage := 1, srchvess := 0, cyytappp, apterm, tempasm := 0, tempasy := 0, tempbsm := 0,tempby := 0, totalas := 0, totalbs := 0,hrs := 0 ,totalhrs := 0



hcstorfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
hcstorheader()

navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))

navtor->(dbgotop())
do while ! empty(navtor->torintcd01) .and. ! navtor->(eof())
        lterm := right(navtor->torschtrm,3)
        navtor->(dbskip())
enddo


navtor->(dbgotop())
do while ! navtor->(eof())
        yrlevel := navtor->toryrlevl
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.F.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := alltrim(if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "A","FIRST "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "B","SECOND "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "C","THIRD "+substr(term->name,4),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1))))))))+;
                    if(!empty(alltrim(navtor->torinst))," w/ PERMIT","")
        if (prow() >= 39) .or. (empty(navtor->torintcd01) .and. (prow()+6)>39)
                footline()
                hcstefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                hcstorheader()
        endif

           if !empty(navtor->torinst)
                   @ prow()+01,18 say alltrim(navtor->torinst)
                   @ prow()+00,18 say replicate("_",len(alltrim(navtor->torinst)))
           endif
           @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
           @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))


        for nctr := 1 to 20 
                nctrunt := 1
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                addunit := 0
                if oldcuraj->(dbseek(navtor->&cintcod))
                        addunit := 1
                        for nctrunt := 1 to 19
                            cint_cod := "torintcd"+strzero(nctrunt,2)
                            if navtor->&cint_cod == oldcuraj->courslcod
                                addunit := 0
                                exit
                            endif
                        next
                endif
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                        nunit := c999crsp->crscreunt
                        if addunit == 1
                           nunit += 1
                        endif
                      //  if prow() > 50
                        if prow() >= 39
                                footline()
                                hcstefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
                                hcstorheader()

                                @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(6)+ctrmdesc
                                @ prow()+00,02 say replicate("_",10)+space(6)+replicate("_",len(alltrim(ctrmdesc)))
                               
                        endif
                        
                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1
                        if ! empty(c999crsp->crsdsc2)
                            @ prow()+01,18 say c999crsp->crsdsc2
                        endif
                        if ! empty(c999crsp->crsdsc3)
                            @ prow()+01,18 say c999crsp->crsdsc3
                        endif
                        if ! empty(c999crsp->crsdsc4)
                           @ prow()+01,18 say c999crsp->crsdsc4
                        endif

                        @ prow()+00,57 say ;
                        if(empty(navtor->&cfingrd),"---",;
                        if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                        if(empty(navtor->&ccomgrd),"   ",;
                        if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                        if(c999crsp->crslechrs > 0.0 ,transform(c999crsp->crslechrs,"@Z 999"),transform(0,"999"))

                        hrs += c999crsp->crslechrs
                else
                        exit
                endif
        next
 //if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
        if nextkey() == K_ESC
                exit
        endif
        ccors := c999colp->colcod
        navtor->(dbskip())

enddo

totalhrs := hrs

navtor->(clearscope())



if !empty(nstpact)
        outexpr(prow()+01,02,"NSTP SERIAL NO. "+alltrim(nstpact)+" ")
        outexpr(prow()+01,02," ")        
endif
        //outexpr(prow()+01,02," ")
        outexpr(prow()+01,02,""+space(16)+"TOTAL "+space(43)+if(totalhrs > 0 , transform(totalhrs, "@Z 999"),transform(0,"999"))+" hrs")
        outexpr(prow()+01,02," ")
        outexpr(prow()+01,02," ")
        outexpr(prow()+01,02,"GRADUATED FROM THE "+alltrim(c999colp->colnamdeg)+" AS OF "+format_date(cdategrad))
        outexpr(prow()+01,02,"PER SPECIAL ORDER (R-VII) NO. "+alltrim(sporderno)+" S. "+alltrim(seriesno)) 
        outexpr(prow()+01,02,"DATED "+format_date(sporderdte)+" ISSUED BY THE TECHNICAL EDUCATION AND SKILLS ")
        outexpr(prow()+01,02,"DEVELOPMENT AUTHORITY (TESDA) REGION VII, CENTRAL VISAYAS, CEBU CITY.") 


        outexpr(prow()+01,02,replicate("-",74))
        outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")

        hcstefooter2(++npage,cpurpose,corno,ctorcont,ctordate)
return(nil)


static function hcstorfront1(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec,npage,ctorcont,ctordate,cregistrar,cposition)
headeject()
setprc(00,00)
outexpr(prow()+06,02,"NAME              :")
outexpr(prow()+00,22,alltrim(strtran(c999sm1p->sm1lstnam,"¥",chr(165)))+", "+alltrim(strtran(c999sm1p->sm1fstnam,"¥",chr(165)))+" "+   ;
        if(!empty(c999sm1p->sm1midname),strtran(c999sm1p->sm1midname,"¥",chr(165)),                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))
outexpr(prow()+01,02,"STUDENT NUMBER    :")
outexpr(prow()+00,22,cidno)
outexpr(prow()+01,02,"SEX               :")
outexpr(prow()+00,22,if(c999sm1p->sm1sex == "F","FEMALE","MALE  "))
outexpr(prow()+01,02,"CIVIL STATUS      :")
c999sm2p->(dbseek(cidno))
outexpr(prow()+00,22,if(c999sm2p->sm2civsts $ "S ","SINGLE","MARRIED"))
outexpr(prow()+01,02,"BIRTH DATE        :")
outexpr(prow()+00,22,format_date(c999sm2p->sm2birdte))
outexpr(prow()+01,02,"BIRTHPLACE        :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2birplc))
outexpr(prow()+01,02,"NATIONALITY       :")
outexpr(prow()+00,22,c999sm2p->sm2nat)
outexpr(prow()+01,02,"RELIGION          :")
outexpr(prow()+00,22,c999sm2p->sm2rel)
outexpr(prow()+01,02,"PARENT/GUARDIAN   :")
outexpr(prow()+00,22,alltrim(c999sm2p->sm2gdn))
outexpr(prow()+01,02,"PERMANENT ADDRESS :")         
outexpr(prow()+00,22,if(!empty(c999sm1p->sm1homadr),strtran(c999sm1p->sm1homadr,"¥",chr(165)),"C/O REGISTRAR, UC-PT"))
if(!empty(c999sm1p->sm1homadr2))
        outexpr(prow()+01,02,"                  :")
        outexpr(prow()+00,22,strtran(c999sm1p->sm1homadr2,"¥",chr(165)))
endif
outexpr(prow()+01,02,"DATE ADMITTED     :")
c999torp->(dbseek(cidno))
outexpr(prow()+00,22,format_date(cdateadmit))
outexpr(prow()+01,02,"COLLEGE OF        :")
c999colp->(dbseek(c999sm1p->sm1colcod))
outexpr(prow()+00,22,c999colp->colnamcol)
outexpr(prow()+01,02,"ENTRANCE DATA     :")
outexpr(prow()+00,22,c999sm2p->sm2entdat)

outexpr(prow()+02,30,"PRELIMINARY EDUCATION")
outexpr(prow()+00,30,"_____________________")
outexpr(prow()+02,02,"ELEMENTARY  :");outexpr(prow()+00,16,trim(c999sm2p->sm2prisc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2priyr)
outexpr(prow()+01,02,"HIGH SCHOOL :");outexpr(prow()+00,16,trim(c999sm2p->sm2secsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2secyr)

if ! empty(c999sm2p->sm2sh)
    outexpr(prow()+01,02,"SENIOR HIGH :");outexpr(prow()+00,16,trim(c999sm2p->sm2sh),49)
    outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2shyr)
endif

outexpr(prow()+01,02,"COLLEGE     :");outexpr(prow()+00,16,trim(c999sm2p->sm2colsc),49)
outexpr(prow()+00,65,"YEAR :");outexpr(prow()+00,72,c999sm2p->sm2colyr)
outexpr(prow()+02,02,"NCEE PERCENTILE:_______  YEAR TAKEN:________  EXAMINEE NUMBER:____________")
outexpr(prow()+00,20,cnceeper);outexpr(prow()+00,40,cyrtaken);outexpr(prow()+00,66,cexamno)
outexpr(prow()+02,33,"GRADING SYSTEM")
outexpr(prow()+00,33,"______________")
outexpr(prow()+02,07,"NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT  NUMBER  PERCENT")
outexpr(prow()+01,07," 1.0    95-100    1.6      89      2.1      84      2.6      79   ")
outexpr(prow()+01,07," 1.1      94      1.7      88      2.2      83      2.7      78   ")
outexpr(prow()+01,07," 1.2      93      1.8      87      2.3      82      2.8      77   ")
outexpr(prow()+01,07," 1.3      92      1.9      86      2.4      81      2.9      76   ")
outexpr(prow()+01,07," 1.4      91      2.0      85      2.5      80      3.0      75   ")
outexpr(prow()+01,07," 1.5      90                                        5.0    FAILURE")
outexpr(prow()+01,02,"IC, IL, IE = INCOMPLETE   W = WITHDRAWN   DR = DROPPED   NA = NO ATTENDANCE")
outexpr(prow()+02,37,"CREDIT")
outexpr(prow()+00,37,"______")
outexpr(prow()+02,02,"ONE COLLEGIATE UNIT OF CREDIT IS ONE HOUR LECTURE OR RECITATION EACH WEEK")
outexpr(prow()+01,02,"OR A TOTAL OF 18 HOURS IN A SEMESTER.   THREE HOURS  OF LABORATORY  WORK,")
outexpr(prow()+01,02,"DRAFTING, OR SHOP WORK EACH WEEK OR A TOTAL OF 54 HOURS  A  SEMESTER  ARE")
outexpr(prow()+01,02,"REGARDED AS EQUIVALENT ALSO TO ONE UNIT OF CREDIT.")
outexpr(prow()+01,02,"THE STUDENT IS IN GOOD MORAL STANDING UNLESS OTHERWISE INDICATED  IN  THE")
outexpr(prow()+01,02,"TRANSCRIPT.")
hcstefooter2(1,cpurpose,corno,ctorcont,ctordate)
return(nil)

static function hcstefooter2(npage,cpurpose,corno,ctorcont,ctordate)
local i:=46
if ! (npage == 1)
        i+=1
endif

outexpr(49,02,"REMARKS:                                             DATE ISSUED:")
//outexpr(+00,02,"REMARKS:                                             DATE ISSUED:")
outexpr(prow()+00,11,cpurpose);outexpr(prow()+00,68,(if(!empty(ctordate),ctordate,displaydate(date()))))
outexpr(prow()+01,02,"PREPARED BY                                          CHECKED BY ")
outexpr(prow()+01,02,cprepared)
outexpr(prow()+00,55,cchecked)

outexpr(prow()+01,27,"    "+cregistrar+"   ")
outexpr(prow()+00,27,"__________________________")
outexpr(prow()+01,27,"     CAMPUS REGISTRAR    ")
outexpr(prow()+01,04,"NOT VALID WITHOUT SEAL")
outexpr(prow()+01,04,"    OR NO.________        ")
outexpr(prow()+00,04,"           "+corno)
outexpr(prow()+01,06,"        PAGE "+str(npage,2))
outexpr(prow()+01,06,"   SN: "+ctorcont)
__eject()
return(nil)


static function hcstorheader()
headeject()
setprc(00,00)
//outexpr(prow()+02,02,"NAME:  (HP Laser Jet)
outexpr(prow()+06,02,"NAME:______________________________________________  STUDENT NO.:_________")
//outexpr(prow()+00,09,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+if(!empty(c999sm1p->sm1midnam),"."," "))

outexpr(prow()+00,08,alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+   ;
        if(!empty(c999sm1p->sm1midname),c999sm1p->sm1midname,                              ;
           if(!empty(c999sm1p->sm1midnam),c999sm1p->sm1midnam+"."," ")))

//outexpr(prow()+00,69,c999sm1p->sm1idno) (HP Laser Jet)
outexpr(prow()+00,68,c999sm1p->sm1idno)

outexpr(prow()+02,02,"--------------------------------------------------------------------------")
outexpr(prow()+01,02,"COURSE NO.      DESCRIPTIVE TITLES                    FINAL RE-EXAM HOURS")
outexpr(prow()+01,02,"--------------------------------------------------------------------------")
return(nil)