*-------------------------------------------------------------------------------

function stats_compared(cstatus)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, pyytenrp, bprint, cprocsts, cterm, pterm, cdesc, pdesc, aentryscr,;
      dater, c_date, temp_term := space(5), test_term := space(5)

private cdummy := "stat"+strzero(memvar->naccess,2), header, detail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
pterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        restscr(aentryscr)
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Enrollment Statistics w/ Comparison Report  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        temp_term := ""
        term->(dbgotop())
        do while ! term->(eof())
                if substr(term->code,1,1) == "0"
                        test_term := "20"+term->code
                else
                        test_term := "19"+term->code
                endif
                if temp_term < test_term
                        temp_term := test_term
                endif
                term->(dbskip())
        enddo
        c_date := date()
        cterm := substr(temp_term,3,3)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        pterm := "1"+substr(cterm,1,2)
        if (val(pterm)-1)<100
                pterm := alltrim(str(val(pterm)-1))+substr(cterm,3,1)
        else
                pterm := substr(alltrim(str(val(pterm)-1)),2,2)+substr(cterm,3,1)
        endif
        @ 04,02 say "Previous Term  :";
                color memvar->colorarray[02];
                get pterm pict "@!";
                valid ! empty(cterm)
        @ 06,02 say "Current Date   :";
                color memvar->colorarray[02];
                get c_date ;
                valid ! empty(c_date)
        if isleap(c_date)
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)-5))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        else
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)-6))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        endif
        @ 08,02 say "Pivot Date     :";
                color memvar->colorarray[02];
                get dater ;
                valid ! empty(c_date)

        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        else
                cdesc := term->name
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! term->(dbseek(pterm))
                fask(10,"  School term "+pterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        else
                pdesc := term->name
        endif
        if ! file(alltrim("c"+pterm+"enrp.dbf"))
                fask(10,"  C"+pterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 04,23 say "- "+term->name
        @ 06,30 say "- "+cmonth(c_date) +" "+transform(day(c_date),"99") + ", " + ;
                           transform(year(c_date),"9999") +"  "+ cdow(c_date)
        @ 08,30 say "- "+cmonth(dater) +" "+transform(day(dater),"99") + ", " + ;
                           transform(year(dater),"9999") +"  "+ cdow(dater)
        term->(dbseek(cterm))
        @ 02,23 say "- "+term->name
        cyytenrp  := alltrim("c"+cterm+"enrp")
        pyytenrp  := alltrim("c"+pterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,, pyytenrp,"pyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||pstats_compared(cdesc,cstatus,cterm,pterm,c_date,dater)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+"H"+".TXT"); ccdx := (memvar->cdummy+"H"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"D"+".TXT"); ccdx := (memvar->cdummy+"D"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"P"+".TXT"); ccdx := (memvar->cdummy+"P"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function pstats_compared(cdesc,cstatus,cterm,pterm,c_date,dater)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,;
      n1st,n2nd,n3rd,n4th,nwbef,nwdur,nall,record_no,nTotal,nTotLstYr,nDiff,;
      nlst_yr,counter,out_text := space(255),out_text2 := space(255),diff,;
      nTotWdraw,nEnrToday

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0},;
                                     {"MALE"        ,"N",07,0},;
                                     {"FEMALE"      ,"N",06,0},;
                                     {"WBEFORE"     ,"N",03,0},;
                                     {"WDURING"     ,"N",03,0},;
                                     {"TERM"        ,"C",01,0},;
                                     {"UNITS"       ,"N",10,1}},{||cdxdstat()}) .or. ;
   ! createdummy(memvar->cdummy+"P",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0},;
                                     {"MALE"        ,"N",07,0},;
                                     {"FEMALE"      ,"N",06,0},;
                                     {"WBEFORE"     ,"N",03,0},;
                                     {"WDURING"     ,"N",03,0},;
                                     {"TERM"        ,"C",01,0},;
                                     {"UNITS"       ,"N",10,1}},{||cdxdstat()}) .or. ;
   ! createdummy(memvar->cdummy+"H",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0}},{||cdxhstatus()})
        dbcloseall()
        return(nil)
endif
memvar->header   := memvar->cdummy+"H"
memvar->detail   := memvar->cdummy+"D"
memvar->previous := memvar->cdummy+"P"
if(afile := openwcheck({{,,(memvar->header   +".TXT"),"header"  ,_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->previous +".TXT"),"previous",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->detail   +".TXT"),"detail"  ,_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
header->(__dbzap());header->(dbreindex())
detail->(__dbzap());detail->(dbreindex())
previous->(__dbzap());previous->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
if (cstatus == "A")
        aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
else
        aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"+space(16)+"Confirmed"})
endif
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("NUMBER OF STUDENTS",nmaxcol))+;
                              "NUMBER OF STUDENTS"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"--------------------------------------------------------------------------------"})
aadd(abtext,{||"  COURSE/YEAR    1ST YR   2ND YR   3RD YR   4TH YR      TOTAL   LST YR     DIFF "})
aadd(abtext,{||"============== ======== ======== ======== ======== ========== ======== ======== "})
aadd(abtext,{||""})

nEnrToday := 0
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10," Processing Term : "+cterm + "; ID number :"+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (cyytenrp->enrdte <= c_date) .and. ((cstatus == "A") .or. (cyytenrp->enrconfirm == "*"))

           if cyytenrp->enrdte==c_date
                nEnrToday += 1
           endif
                if detail->(dbseek(cyytenrp->enrcolcod+cyytenrp->enryrlevl))
                        detail->(reclock())
                        do case
                        case c999sm1p->sm1sex == "M" &&male
                             detail->male += 1
                        case c999sm1p->sm1sex == "F" &&Female
                             detail->female += 1
                        endcase
                        do case
                        case cyytenrp->enrenrst == _WITHDRAW_BEFORE
                             detail->wbefore += 1
                        case cyytenrp->enrenrst == _WITHDRAW_AFTER
                             detail->wduring += 1
                        endcase
                        detail->units += cyytenrp->enrunt
                else
                        detail->(dbappend())
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        detail->colcode := cyytenrp->enrcolcod
                        detail->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MR","-NIS",;
                                                                        if(cyytenrp->enrcolcod == "MI","-NIS",space(06)))))
                        detail->year    := cyytenrp->enryrlevl
                        do case
                        case c999sm1p->sm1sex == "M"
                             detail->male   := 1
                             detail->female := 0
                        case c999sm1p->sm1sex == "F"
                             detail->male   := 0
                             detail->female := 1
                        endcase
                        do case
                        case cyytenrp->enrenrst == _WITHDRAW_BEFORE
                             detail->wbefore := 1
                             detail->wduring := 0
                        case cyytenrp->enrenrst == _WITHDRAW_AFTER
                             detail->wbefore := 0
                             detail->wduring := 1
                        endcase
                        detail->units := cyytenrp->enrunt

                        if ! header->(dbseek(detail->coldesc + detail->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MR","-NIS",;
                                                                                if(cyytenrp->enrcolcod == "MI","-NIS",space(06)))))
                                header->colcode := detail->colcode
                                header->year := detail->year
                                header->(dbcommit())
                                header->(dbunlock())
                        endif
                detail->term := "D"
                endif
                detail->(dbcommit())
                detail->(dbunlock())
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(dbclearrelation())

/*-----------------------------------------------*/

pyytenrp->(dbsetrelation("c999sm1p",{||pyytenrp->enridno},"pyytenrp->enridno"))
pyytenrp->(dbgotop())
do while ! pyytenrp->(eof())
        fask(10," Processing Term : "+pterm + "; ID number :"+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (pyytenrp->enrdte <= dater) .and. ((cstatus == "A") .or. (pyytenrp->enrconfirm == "*"))
                if previous->(dbseek(pyytenrp->enrcolcod+pyytenrp->enryrlevl))
                        previous->(reclock())
                        do case
                        case c999sm1p->sm1sex == "M" &&male
                             previous->male += 1
                        case c999sm1p->sm1sex == "F" &&Female
                             previous->female += 1
                        endcase
                        do case
                        case pyytenrp->enrenrst == _WITHDRAW_BEFORE
                             previous->wbefore += 1
                        case pyytenrp->enrenrst == _WITHDRAW_AFTER
                             previous->wduring += 1
                        endcase
                        previous->units += pyytenrp->enrunt
                else
                        previous->(dbappend())
                        c999colp->(dbseek(pyytenrp->enrcolcod))
                        previous->colcode := pyytenrp->enrcolcod
                        previous->coldesc := alltrim(c999colp->coldesabr)+if(pyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                        if(pyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                        if(pyytenrp->enrcolcod == "MR","-NIS",;
                                                                        if(pyytenrp->enrcolcod == "MI","-NIS",space(06)))))
                        previous->year    := pyytenrp->enryrlevl
                        do case
                        case c999sm1p->sm1sex == "M"
                             previous->male   := 1
                             previous->female := 0
                        case c999sm1p->sm1sex == "F"
                             previous->male   := 0
                             previous->female := 1
                        endcase
                        do case
                        case pyytenrp->enrenrst == _WITHDRAW_BEFORE
                             previous->wbefore := 1
                             previous->wduring := 0
                        case pyytenrp->enrenrst == _WITHDRAW_AFTER
                             previous->wbefore := 0
                             previous->wduring := 1
                        endcase
                        previous->units := pyytenrp->enrunt

                        if ! header->(dbseek(previous->coldesc+previous->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(pyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                                if(pyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                                if(pyytenrp->enrcolcod == "MR","-NIS",;
                                                                                if(pyytenrp->enrcolcod == "MI","-NIS",space(06)))))
                                header->colcode := previous->colcode
                                header->year    := previous->year
                                header->(dbcommit())
                                header->(dbunlock())

                                detail->(dbappend())
                                detail->colcode := previous->colcode
                                detail->coldesc := previous->coldesc
                                detail->year    := previous->year
                                detail->male   := 0
                                detail->female := 0
                                detail->wbefore := 0
                                detail->wduring := 0
                                detail->units := 0
                        endif
                        previous->term := "P"
                endif
                previous->(dbcommit())
                previous->(dbunlock())
        endif
        if nextkey() == K_ESC
                exit
        endif
        pyytenrp->(dbskip())
enddo
pyytenrp->(dbclearrelation())

/*-----------------------------------------------*/


*-----------------
*/  printing    /*
*-----------------
n1st := n2nd := n3rd := n4th := nTotal := nTotLstYr := nDiff := ;
nwbef := nwdur := nall := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
header->(dbreindex())
detail->(dbreindex())
previous->(dbreindex())
header->(dbgotop())
do while ! header->(eof())
        fask(10,"  Printing course "+alltrim(header->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        out_text := header->colcode+"_"+header->coldesc
        out_text2 := ""
        nlst_yr := diff := nall := 0
        for counter := 1 to 4
           if previous->(dbseek(header->colcode+transform(counter,"9")))
                nlst_yr += (previous->male) + (previous->female) - ;
                           (previous->wbefore) - (previous->wduring)
           endif
           if detail->(dbseek(header->colcode+transform(counter,"9")))
                fask(10,"  Printing course "+alltrim(detail->coldesc)+" year "+detail->year+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                out_text2 := out_text2 + transform((detail->male)+(detail->female) - ;
                             (detail->wbefore) - (detail->wduring),"999,999")+space(02)
                nall  += (detail->male+detail->female-detail->wbefore-detail->wduring)
                nwbef += detail->wbefore
                nwdur += detail->wduring
                do case
                case detail->year == _FIRST_YEAR
                     n1st += (detail->male+detail->female-detail->wbefore-detail->wduring)
                case detail->year == _SECOND_YEAR
                     n2nd += (detail->male+detail->female-detail->wbefore-detail->wduring)
                case detail->year == _THIRD_YEAR
                     n3rd += (detail->male+detail->female-detail->wbefore-detail->wduring)
                case detail->year == _FOURTH_YEAR
                     n4th += (detail->male+detail->female-detail->wbefore-detail->wduring)
                endcase
           else
                out_text2 := out_text2 + transform(0,"999,999")+space(02)
           endif
           detail->(dbskip())
        next
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        diff := nall-nlst_yr
        ndiff += diff
        nTotal += nall
        nTotLstYr +=nlst_yr
        out_text := out_text + out_text2 + transform(nall,"9,999,999") + ;
                    transform(nlst_yr,"9,999,999") + transform(diff,"9,999,999")
        outexpr(prow()+01,00,out_text)
        header->(dbskip())
enddo
        outexpr(prow()+01,00,"")
        outexpr(prow()+01,00,"Total           "+ transform(n1st,       "999,999") + space(02) + ;
                                                 transform(n2nd,       "999,999") + space(02) + ;
                                                 transform(n3rd,       "999,999") + space(02) + ;
                                                 transform(n4th,       "999,999") + space(02) + ;
                                                 transform(nTotal,   "9,999,999") + ;
                                                 transform(nTotlstYr,"9,999,999") + ;
                                                 transform(nDiff,    "9,999,999"))
outexpr(prow()+01,00,replicate("Ф",80))
outexpr(prow()+01,00,"<< S U M M A R Y >>")
outexpr(prow()+01,00,"A.  Total Withdrawn                     => "+transform(nwbef+nwdur,"999,999"))
outexpr(prow()+01,00,"B.  Total Enrolled today                => "+transform(nEnrToday,"999,999"))

outexpr(prow()+01,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

static function cdxhstat()
field colcode,coldesc,year
private cdummyfile := alias()
//index on coldesc tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
//index on colcode+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)


static function cdxdstat()
field colcode,coldesc,year,term
private cdummyfile := alias()
//index on colcode+year tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
//index on coldesc+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
//index on colcode+year+term tag (memvar->cdummyfile+"3") of (memvar->cdummyfile)
return(nil)

static function cdxhstatus()
field colcode,coldesc,year
private cdummyfile := alias()
//index on coldesc+colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
//index on colcode+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

