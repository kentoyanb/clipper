* Program       :  SKDREP.PRG
* Author        :  Jun Benlot and Randy F. Santizo (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function subjskdprn(cmain)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctype,ccolcode
private cdummy := "subskd"+strzero(memvar->naccess,2),subjskd

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Subject Schedule Printing  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,4}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        ctype    := "A"
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   - [UC-all course]" color memvar->colorarray[02]
//                @ 03,23 say "[UC - All Course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
                @ 04,23 say "[O-pen , C-losed  , W-arning, D-issolved, A-ll ]" color memvar->colorarray[02]
                @ 05,23 say "[B-lock, N-onBlock, S-ection, U-CM-ain  , R-otc]" color memvar->colorarray[02]
                @ 04,02 say "T y p e      :";
                        color memvar->colorarray[02];
                        get ctype       pict "@!";
                        valid ctype $ "OCWDABNSRU"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||psubjskdprn(ccolcode,ctype,cdesc,cmain)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function psubjskdprn(ccolcode,ctype,cdesc,cmain)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cheaddesc,csection,nactsize

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"SCODE"       ,"C",05,0},;
                                 {"SUBJECT"     ,"C",16,0},;
                                 {"TIME"        ,"C",14,0},;
                                 {"DAYS"        ,"C",04,0},;
                                 {"ROOM"        ,"C",04,0},;
                                 {"UNIT"        ,"N",04,1},;
                                 {"SIZE"        ,"N",04,0},;
                                 {"SECTION"     ,"C",03,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"INSCODE"     ,"C",15,0},;
                                 {"SPLCODE"     ,"C",05,0},;
                                 {"MAINSIZE"    ,"N",04,0}},{||cdxsubjskd()})
        dbcloseall()
        return(nil)
endif
memvar->subjskd := memvar->cdummy
if(afile := openwcheck({{,,(memvar->subjskd+".TXT"),"subjskd",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
subjskd->(__dbzap()); subjskd->(dbreindex())

if ctype == "O"
        cheaddesc := "LIST OF OPEN SCHEDULE"
elseif ctype == "W"
        cheaddesc := "LIST OF WARNING SCHEDULE"
elseif ctype == "C"
        cheaddesc := "LIST OF CLOSED SCHEDULE"
elseif ctype == "D"
        cheaddesc := "LIST OF DISSOLVED SCHEDULE"
elseif ctype == "A"
        cheaddesc := "LIST OF ALL SCHEDULE"
elseif ctype == "S"
        cheaddesc := "LIST OF SCHEDULE BY SECTION"
elseif ctype == "B"
        cheaddesc := "LIST OF SCHEDULE BY BLOCKED"
elseif ctype == "N"
        cheaddesc := "LIST OF SCHEDULE BY NON-BLOCKED"
elseif ctype == "R"
        cheaddesc := "LIST OF ROTC SCHEDULE"
elseif ctype == "U"
        cheaddesc := "LIST OF SCHEDULE TAKEN AT UC-MAIN"

elseif ccolcode == "MT"
        cheaddesc := "LIST OF SCHEDULE - A.M.T."
elseif ccolcode == "MA"
        cheaddesc := "LIST OF SCHEDULE - A.M.A.R.E."
elseif ccolcode $ "MPA"
        cheaddesc := "LIST OF SCHEDULE - PROJECT ALPHA"
elseif ccolcode $ "MIMR"
        cheaddesc := "LIST OF SCHEDULE - NIS"

endif

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos(alltrim(cheaddesc),nmaxcol))+alltrim(cheaddesc)})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})                                                       
aadd(abtext,{||"SCODE      SUBJECT          TIME      DAYS ROOM UNIT SIZE "+if(cmain==0,"","MAIN ")+"SEC COURSE SPLCD INSTRUCTOR"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- "+if(cmain==0,"","---- ")+"--- ------ ----- ----------"})

/*
SCODE      SUBJECT          TIME      DAYS ROOM UNIT SIZE SEC COURSE SPLCD INSTRUCTOR
----- ---------------- -------------- ---- ---- ---- ---- --- ------ ----- ----------
12345 123456789012 lec 12345-12345 pm days room unit size 123 course 12345
*/

if ! ccolcode $ "UC,NT,MG,MI,MR,PA,MP" .and. ! ctype == "R"
        cyytskdp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytskdp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif
cyytskdp->(dbgotop())

do while ! cyytskdp->(eof())
        if (ccolcode == "NT" .and. cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA,SN,YN,HN,BN,NV,NW") .or. ;
           (ccolcode == "MG" .and. cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD,SM,YM,HM,BM,NM,MW") .or. ;
           (ccolcode == "UC") .or. (cyytskdp->skdcolcod == ccolcode)
//        fask(10,"  "+ccolcode+"  "+cyytskdp->skdcolcod+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+" course "+cyytskdp->skdcolcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
//        nactsize := cyytskdp->skdactsiz + if(cmain==0,0,cyytskdp->skdmainsiz)
        nactsize := cyytskdp->skdactsiz
                do case
                case ctype == "O"
                        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                if ((cyytskdp->skdmaxsiz-nactsize) > 5)
//                                if (nactsize) <= cyytskdp->skdmaxsiz
                                        writesubjskd(cmain)
                                endif
                        endif
                case ctype == "W" &&Warning
                        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                if ((cyytskdp->skdmaxsiz-nactsize) <= 10) .and.;
                                   ((cyytskdp->skdmaxsiz-nactsize) > 5)
                                        writesubjskd(cmain)
                                endif
                        endif
                case ctype == "C"
                        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                if ((cyytskdp->skdmaxsiz-nactsize) <= 5)
                                        writesubjskd(cmain)
                                endif
                        endif
                case ctype == "D"
                        if cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                writesubjskd(cmain)
                        endif
                case ctype $ "AS"
                        if ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                writesubjskd(cmain)
                        endif
                case ctype == "B"
                        if cyytskdp->skdblkcode == "Y" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                writesubjskd(cmain)
                        endif
/*
                        if ! empty(cyytskdp->skdsec)
                                writesubjskd(cmain)
                        endif
*/
                case ctype == "N"
                        if empty(cyytskdp->skdsec) .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                writesubjskd(cmain)
                        endif
                case ctype == "R"
//                        if cyytskdp->skdunt == 1.5
                        if left(cyytskdp->skdsubcod,2) $ "NS,NT,CW,LE,MT,NR" .and. cyytskdp->skdcolcod == "**"
                                writesubjskd(cmain)
                        endif
                case ctype == "U"
                        if alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                writesubjskd(cmain)
                        endif
        endcase
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
cyytskdp->(clearscope())
cyytskdp->(sx_settagorder(4))

*--------------------
*   printing data   *
*--------------------
if ! ccolcode == "UCNTMG"
//        if ctype $ "OWCDRU"
        if ctype $ "OWDRU"
                subjskd->(sx_settagorder(1))
        elseif ctype $ "BSCN"
                subjskd->(sx_settagorder(3))
        elseif ctype $ "A"
                subjskd->(sx_settagorder(4))
        endif
else
        if ctype == "R"
                subjskd->(sx_settagorder(1))
        elseif ctype == "S"
                subjskd->(sx_settagorder(3))
        else
                subjskd->(sx_settagorder(2))
        endif
endif
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
subjskd->(dbgotop())
csection := subjskd->section
do while ! subjskd->(eof())
        fask(10,"  Printing code "+subjskd->scode+" subject "+subjskd->subject+" course "+subjskd->course+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})

                outexpr(prow()+01,00,subjskd->scode+space(01)+;
                             subjskd->subject+space(01)+;
                             subjskd->time+space(01)+;
                             subjskd->days+space(01)+;
                             subjskd->room+space(01)+;
                             transform(subjskd->unit,"99.9")+space(01)+;
                             transform(subjskd->size,"9999")+;
                             if(cmain==0,"",transform(subjskd->mainsize,"9,999"))+space(01)+;
                             subjskd->section+space(01)+;
                             subjskd->course+space(01)+;
                             subjskd->splcode+" "+subjskd->inscode)
        if nextkey() == K_ESC
                exit
        endif
        subjskd->(dbskip())

        if ctype $ "BSC" .and. ! csection == subjskd->section
                @ prow()+01,00 say ""
                csection := subjskd->section
        endif

enddo
outexpr(prow()+01,00,chr(18))
__eject()
closewcheck(afile)
return(nil)

static function writesubjskd(cmain)
subjskd->(dbappend())
subjskd->scode          := cyytskdp->skdcod
subjskd->subject        := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
subjskd->subject        := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
subjskd->time           := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn
subjskd->days           := cyytskdp->skdday
subjskd->room           := cyytskdp->skdrom
subjskd->unit           := cyytskdp->skdunt
//subjskd->size           := cyytskdp->skdactsiz + if(cmain==0,0,cyytskdp->skdmainsiz)
subjskd->size           := cyytskdp->skdactsiz
subjskd->section        := cyytskdp->skdsec
*subjskd->revcode        := cyytskdp->skdrevcod
subjskd->splcode        := cyytskdp->skdsplskd
//subjskd->mainsize       := cyytskdp->skdmainsiz


if t999lst->(dbseek(cyytskdp->skdinscod))
        subjskd->inscode := t999lst->tlname
else
        subjskd->inscode := space(15)
endif

if c999colp->(dbseek(cyytskdp->skdcolcod))
        subjskd->course := c999colp->coldesabr
else
        subjskd->course := space(06)
endif
return(nil)

static function cdxsubjskd()
field course,subject
private cdummyfile := alias()
index on subject tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on course+subject tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
index on section+subject+course tag (memvar->cdummyfile+"3") of (memvar->cdummyfile)
index on section+subject+course tag (memvar->cdummyfile+"4") of (memvar->cdummyfile)
return(nil)

static function viewcoll(ccode,cprocsts)
if ccode $ "UC,NT,MG"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 03,23 say c999colp->coldesful+space(20)
return(.t.)

*-------------------------------------------------------------------------------
function consolidated()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ctime

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule Printing  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"t999lst",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,5}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        do while .t.
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   - [UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pconsolidated(cdesc,ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
//        restscr(aentryscr)
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pconsolidated(cdesc,ccolcode)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cinstruc

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CONSOLIDATED SCHEDULE OF CLASSES",nmaxcol))+;
                              "CONSOLIDATED SCHEDULE OF CLASSES"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"   TIME       INSTRUCTOR    CODE      SUBJECT      DAYS ROOM UNIT SIZE REMARKS"})
aadd(abtext,{||"----------- --------------- ----- ---------------- ---- ---- ---- ---- -------"})

/*
   TIME       INSTRUCTOR    CODE      SUBJECT      DAYS ROOM UNIT SIZE REMARKS
----------- --------------- ----- ---------------- ---- ---- ---- ---- -------
11:11-11:11 123456789012345 12345 123456789012 123 1234 1234 12.1 1234 _______
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
ctime:=cyytskdp->skdbegtim+cyytskdp->skdendtim
do while ! cyytskdp->(eof())
   if   ccolcode == "UC" .or.;
        (ccolcode == "NT" .and. cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA,SN,YN,BN,HN,NV,NW") .or.;
        (ccolcode == "MG" .and. cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD,SM,YM,BM,HM,NM,MW")
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
//        if ! empty(cyytskdp->skdinscod) .and. ! cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) == "ROTC";
        if ! cyytskdp->skdrescod == _DISSOLVED .and. ! alltrim(cyytskdp->skdinscod) == "ROTC" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2,3,4"
                t999lst->(dbseek(cyytskdp->skdinscod))
                cinstruc := t999lst->tlname
                outexpr(prow()+01,00,cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                     cinstruc+space(01)+;
                                     cyytskdp->skdcod+space(01)+;
                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                     cyytskdp->skdday+space(01)+;
                                     cyytskdp->skdrom+space(01)+;
                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                     "_______")
        endif
        if nextkey() == K_ESC
                exit
        endif
        if !(ctime == cyytskdp->skdbegtim+cyytskdp->skdendtim)
             outexpr(prow()+01,00," ")
             ctime:=cyytskdp->skdbegtim+cyytskdp->skdendtim
        endif
   endif
   cyytskdp->(dbskip())
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

*-------------------------------------------------------------------------------

function roomskdavail()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc
private cdummy := "rom"+strzero(memvar->naccess,2),roomfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Available Room Report  ")
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
        if ! file("c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999room",,_DBF_SHARED,,1},;
                                     {,,"c999rmsk",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,7}})) == nil
                return(nil)
        endif
        if whereprint({||proomskdavail(cterm,cdesc)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
cfile:=(memvar->cdummy+".TXT");ccdx:=(memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function proomskdavail(cterm,cdesc)
local abtext := {},ncol,nmaxcol := 140, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"RMCODE"      ,"C",05,0},;
                                 {"RMNO"        ,"C",05,0}},{||cdxromskd()})
        dbcloseall()
        return(nil)
endif
memvar->roomfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->roomfile+".TXT"),"roomfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
roomfile->(__dbzap());roomfile->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+chr(15)+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("LIST OF AVAILABLE ROOM NUMBER",nmaxcol))+;
                              "LIST OF AVAILABLE ROOM NUMBER"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||replicate("-",140)})
aadd(abtext,{||""})
c999rmsk->(dbgotop())
do while ! c999rmsk->(eof())
        cdayx := c999rmsk->rmdayx
        c999room->(dbgotop())
        do while ! c999room->(eof())
                fask(10,"  Processing room# "+c999room->roomno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
//                if ! c999room->roomno $ "AFLD ,AGYM ,AVR1 " .and. ! c999room->type $ "A,R,L,M"
                if ! c999room->roomno $ "AFLD ,AGYM ,AVR1 " .and. c999room->status == " "
                        cyytskdp->(sx_setscope(_TOP_SCOPE   ,c999room->roomno))
                        cyytskdp->(sx_setscope(_BOTTOM_SCOPE,c999room->roomno))
                        cyytskdp->(dbgotop())
                        do while ! cyytskdp->(eof())
                                fask(10,"  Processing room# "+c999room->roomno+" schedule# "+cyytskdp->skdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                for nctr := 1 to 7
                                        if ! empty(substr(cyytskdp->skddayx,nctr,1))
                                                if substr(cyytskdp->skddayx,nctr,1) == substr(cdayx,nctr,1)
                                                        if  c999rmsk->rmbegtimex+c999rmsk->rmendtimex == cyytskdp->skdbegtimx+cyytskdp->skdendtimx .or.;
                                                           (c999rmsk->rmbegtimex > cyytskdp->skdbegtimx .and. c999rmsk->rmbegtimex < cyytskdp->skdendtimx) .or.;
                                                           (cyytskdp->skdbegtimx > c999rmsk->rmbegtimex .and. cyytskdp->skdbegtimx < c999rmsk->rmendtimex) .or.;
                                                           (c999rmsk->rmendtimex > cyytskdp->skdbegtimx .and. c999rmsk->rmendtimex < cyytskdp->skdendtimx) .or.;
                                                           (cyytskdp->skdendtimx > c999rmsk->rmbegtimex .and. cyytskdp->skdendtimx < c999rmsk->rmendtimex)
                                                                lused := .t.
                                                                exit
                                                        endif
                                                endif
                                        endif
                                next
                                if lused
                                        exit
                                endif
                                if nextkey() == K_ESC
                                        exit
                                endif
                                cyytskdp->(dbskip())
                        enddo
                        cyytskdp->(clearscope())
                endif
//                if ! lused .and. ! c999room->roomno $ "AFLD ,AGYM ,AVR1 " .and. ! c999room->type $ "A,R,L,M"
                if ! lused .and. ! c999room->roomno $ "AFLD ,AGYM ,AVR1 " .and. c999room->status == " "
                        roomfile->(dbappend())
                        roomfile->rmcode        := c999rmsk->rmskdno
                        roomfile->rmno          := c999room->roomno
                endif
                lused := .f.
                if nextkey() == K_ESC
                        exit
                endif
                c999room->(dbskip())
        enddo
        if nextkey() == K_ESC
                exit
        endif
        c999rmsk->(dbskip())
enddo
** Printing Data **
pageprint(abtext)
c999rmsk->(dbgotop())
do while ! c999rmsk->(eof())
        nctr := 16
        nctr1 := 0
        fask(10,"  Printing code "+c999rmsk->rmskdno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,c999rmsk->rmbegtime+"-"+c999rmsk->rmendtime+" "+c999rmsk->rmday)
        roomfile->(sx_setscope(_TOP_SCOPE   ,c999rmsk->rmskdno))
        roomfile->(sx_setscope(_BOTTOM_SCOPE,c999rmsk->rmskdno))
        roomfile->(dbgotop())
        do while ! roomfile->(eof())
                fask(10,"  Printing code "+c999rmsk->rmskdno+" room# "+roomfile->rmno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                outexpr(prow()+00,nctr,"- "+roomfile->rmno)
                nctr += 7
                if ++nctr1 > 17
                        nctr1 := 0
                        nctr  := 16
                        outexpr(prow()+01,00,"")
                endif
                roomfile->(dbskip())
        enddo
        roomfile->(clearscope())
        c999rmsk->(dbskip())
enddo
outexpr(prow()+00,00,chr(18))
__eject()
closewcheck(afile)
return(nil)


static function cdxromskd()
field rmcode
private cdummyfile := alias()
index on rmcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)


*-------------------------------------------------------------------------------

function roomtimeavail()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc, counter
local room1 := "A102 ", room2 := "A415 "

private cdummy := "rom"+strzero(memvar->naccess,2),roomfile
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Room Schedule Availability ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        @ 04,02 say "Room No. (Top Scope)     :";
                color memvar->colorarray[02];
                get room1 pict "@!"
        @ 05,02 say "Room No. (Bottom Scope)  :";
                color memvar->colorarray[02];
                get room2 pict "@!"
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
        if ! file("c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999room",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,7}})) == nil
                return(nil)
        endif
        if whereprint({||proomtimeavail(cterm,cdesc,room1,room2)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
cfile:=(memvar->cdummy+"D.TXT");ccdx:=(memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
cfile:=(memvar->cdummy+"H.TXT");ccdx:=(memvar->cdummy+"H.CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function proomtimeavail(cterm,cdesc,room1,room2)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0
local num1, num2, xbegtime, xendtime, lapse, counter, daycounter, element
local dayz := {"Monday     ", ;
               "Tuesday    ", ;
               "Wednesday  ", ;
               "Thursday   ", ;
               "Friday     ", ;
               "Saturday   "}

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"RMNO"        ,"C",05,0},;
                                     {"DayNum"      ,"C",01,0},;
                                     {"RMTIME"      ,"C",31,0}},{||cdxromtime()}) .or. ;
   ! createdummy(memvar->cdummy+"H",{{"RMNO"        ,"C",05,0},;
                                     {"Desc"        ,"C",15,0}},{||cdxromtimh()})
        dbcloseall()
        return(nil)
endif
memvar->header := memvar->cdummy+"H"
memvar->detail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->header+".TXT"),"header",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->detail+".TXT"),"detail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
header->(__dbzap());header->(dbreindex())
detail->(__dbzap());detail->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("ROOM SCHEDULE AVAILABILITY",nmaxcol))+;
                              "ROOM SCHEDULE AVAILABILITY"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||replicate("-",140)})
aadd(abtext,{||""})

*-----------------------
* Set Scope for Room No.
*-----------------------

if ! empty(room1) .or. ! empty(room2)
   if ! empty(room1)
      if empty(room2)
         room2 := room1
      endif
      cyytskdp->(sx_setscope(_TOP_SCOPE   ,room1))
      cyytskdp->(sx_setscope(_BOTTOM_SCOPE,room2))
   endif
endif

cyytskdp->(dbgotop())

do while ! cyytskdp->(eof())
   fask(10,"  Gathering Information for Room No. "+cyytskdp->skdrom+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if (c999room->(dbseek(cyytskdp->skdrom))) .and. !(c999room->status $ "LM")
       for daycounter := 1 to 6
           if substr(cyytskdp->skddayx,daycounter,1) =="X"
               num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
               num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
               xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
               xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
               lapse := (xendtime - xbegtime)/0.5

               if ! detail->(dbseek(cyytskdp->skdrom+transform(daycounter,"9")))
                   detail->(dbappend())
                   detail->rmno := cyytskdp->skdrom
                   detail->daynum := transform(daycounter,"9")
                   detail->rmtime := space(31)
                   if ! header->(dbseek(cyytskdp->skdrom))
                        header->(dbappend())
                        header->rmno := cyytskdp->skdrom
                        header->desc := c999room->type
                   endif
               else
                   detail->(reclock())
               endif
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if substr(detail->rmtime,counter+1,1) != "м"
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"м")
                   else
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"*")
                   endif
               next counter
               detail->(dbcommit())
               detail->(dbunlock())
               if nextkey() == K_ESC
                       exit
               endif
           endif
       next daycounter
   endif
   cyytskdp->(dbskip())
enddo

cyytskdp->(clearscope())

** Printing Data **
element := 0
pageprint(abtext)
//header->(dbgotop())
c999room->(dbgotop())
//do while ! header->(eof())
do while ! c999room->(eof())
   fask(10,"  Printing Room No. "+c999room->roomno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   detail->(sx_settagorder(2))
//   if detail->(c999room->roomno)
   if ! c999room->status $ "LM"
        if empty(c999room->type)
           outexpr(prow()+01,00,c999room->roomno)
        else
           outexpr(prow()+01,00,c999room->roomno + " ==> " + c999room->type)
        endif
        outexpr(prow()+01,00,   "                          1 1 1                   1")
        outexpr(prow()+01,00,   "                    7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0")
        detail->(sx_settagorder(1))
        detail->(sx_setscope(_TOP_SCOPE   ,c999room->roomno))
        detail->(sx_setscope(_BOTTOM_SCOPE,c999room->roomno))
        for daycounter := 1 to 6
           if detail->(dbseek(c999room->roomno+transform(daycounter,"9")))
              outexpr(prow()+01,00,"      "+dayz[daycounter]+"   "+detail->rmtime)
           else
              outexpr(prow()+01,00,"      "+dayz[daycounter])
           endif
        next daycounter
        detail->(clearscope())
        if (element += 1) == 5
           outexpr(prow()+01,00,chr(12)+chr(13))
           pageprint(abtext)
           element := 0
        else
           outexpr(prow()+01,00,"")
        endif
   endif
//   header->(dbskip())
   c999room->(dbskip())
enddo
__eject()
closewcheck(afile)
return(nil)


static function cdxromtime()
field rmno,daynum
private cdummyfile := alias()
index on rmno+daynum tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on rmno        tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

static function cdxromtimh()
field rmno
private cdummyfile := alias()
index on rmno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

function woinst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ccolcode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule Printing by Subject without Instructor  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        /* @ 03,01 say replicate("Ф",78) */
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   - [UC-All courses]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pwoinst(cdesc,ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pwoinst(cdesc,ccolcode)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cinstruc,nrecno
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CONSOLIDATED SCHEDULE OF CLASSES",nmaxcol))+;
                              "CONSOLIDATED SCHEDULE OF CLASSES"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                                                                   SPLIT "})
aadd(abtext,{||"CODE      SUBJECT           TIME      DAYS ROOM UNIT SIZE  SKD  T CC  SEC RV"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- ----- - --  --- --"})

/*
                                                                   SPLIT
CODE      SUBJECT           TIME      DAYS ROOM UNIT SIZE  SKD  T CC  SEC
----- ---------------- -------------- ---- ---- ---- ---- ----- - --  ---
12345 123456789012 123 11:11-11:11 12 1234 1234 12.1 1234 12345 1 MT  123
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
//        if cyytskdp->skdblkcode != "Y" .and. ((cyytskdp->skdmaxsiz-cyytskdp->skdactsiz) > 5) .and. ! (cyytskdp->skdinscod $ "0,1,2") .and. ! (cyytskdp->skdrescod == "4") .and. ! (cyytskdp->skdsubcod $ "CWTS,NS")
        do case
                case ccolcode == "UC"
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(02)+;
                                                     cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(02)+;
                                                     cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
                case ccolcode == "NT" &&nautical
                        if cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                                .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(02)+;
                                                             cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(02)+;
                                                             cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == "MG" &&marine
                        if cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                                .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(02)+;
                                                             cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(02)+;
                                                             cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == cyytskdp->skdcolcod
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(02)+;
                                                     cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(02)+;
                                                     cyytskdp->skdsec+" "+cyytskdp->skdrevcod)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
        endcase
//        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

*-------------------------------------------------------------------------------
/* beginning of the cut
function winst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ccolcode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule Printing (by Subject with Instructor)  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        // @ 03,01 say replicate("Ф",78)
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   - [UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pwinst(cdesc,ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pwinst(cdesc,ccolcode)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cinstruc,nrecno
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CONSOLIDATED SCHEDULE OF CLASSES",nmaxcol))+;
                              "CONSOLIDATED SCHEDULE OF CLASSES"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                                                           SPLIT               "})
aadd(abtext,{||"CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------"})

/*
                                                           SPLIT
CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD
----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------
12345 123456789012 123 11:11-11:11 12 1234 1234 12.1 1234 12345 1 MT 123 123456
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
        do case
                case ccolcode == "UC"
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cyytskdp->skdinscod)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cyytskdp->skdinscod)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
                case ccolcode == "NT" &&nautical
                                if cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA,SN,YN,BN,HN,NV,NW" .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == "MG" &&marine
                        if cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD,SM,YM,BM,HM,NM,MW" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                                .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == cyytskdp->skdcolcod
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cyytskdp->skdinscod)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cyytskdp->skdinscod)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
        endcase
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)
*/ end of the cut
*-------------------------------------------------------------------------------

function disolved()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ccolcode,nsize

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Schedule Report with Specified Size  ")
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        nsize    := 15
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "                     [UC-all course]" color memvar->colorarray[02]
                @ 04,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
                @ 05,02 say "Dissolved Size :";
                        color memvar->colorarray[02];
                        get nsize       pict "999";
                        valid ! nsize = 0
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pdisolved(cdesc,ccolcode,nsize)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pdisolved(cdesc,ccolcode,nsize)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cinstruc,nrecno
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SCHEDULE WITH SPECIFIED SIZE REPORT",nmaxcol))+;
                              "SCHEDULE WITH SPECIFIED SIZE REPORT"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                                                           SPLIT               "})
aadd(abtext,{||"CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------"})

/*
                                                           SPLIT
CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD
----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------
12345 123456789012 123 11:11-11:11 12 1234 1234 12.1 1234 12345 1 MT 123 123456
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        if cyytskdp->skdactsiz <= nsize
                fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                             abtext, prow() + 1, _MAX_LINE, {||__eject()})
                do case
                        case ccolcode == "UC"
                          if ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                          endif
                        case ccolcode == "NT" &&nautical
                                if cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA,SN,YN,BN,HN,NV,NW" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                        if ! cyytskdp->skdsplcod=="C"
                                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                                     cyytskdp->skdmdn+space(01)+;
                                                                     cyytskdp->skdday+space(01)+;
                                                                     cyytskdp->skdrom+space(01)+;
                                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                                     cyytskdp->skdsplskd+space(01)+;
                                                                     cyytskdp->skdsplcod+space(01)+;
                                                                     cyytskdp->skdcolcod+space(01)+;
                                                                     cyytskdp->skdsec+space(01)+;
                                                                     cyytskdp->skdinscod)
                                        endif
                                        if cyytskdp->skdsplcod=="S"
                                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                nrecno:=cyytskdp->(recno())
                                                cyytskdp->(sx_settagorder(1))
                                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                                     cyytskdp->skdmdn+space(01)+;
                                                                     cyytskdp->skdday+space(01)+;
                                                                     cyytskdp->skdrom+space(01)+;
                                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                                     cyytskdp->skdsplskd+space(01)+;
                                                                     cyytskdp->skdsplcod+space(01)+;
                                                                     cyytskdp->skdcolcod+space(01)+;
                                                                     cyytskdp->skdsec+space(01)+;
                                                                     cyytskdp->skdinscod)
                                                cyytskdp->(sx_settagorder(2))
                                                cyytskdp->(dbgoto(nrecno))
                                        endif
                                endif
                        case ccolcode == "MG" &&marine
                                if cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD,SM,YM,BM,HM,NM,MW" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                        if ! cyytskdp->skdsplcod=="C"
                                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                                     cyytskdp->skdmdn+space(01)+;
                                                                     cyytskdp->skdday+space(01)+;
                                                                     cyytskdp->skdrom+space(01)+;
                                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                                     cyytskdp->skdsplskd+space(01)+;
                                                                     cyytskdp->skdsplcod+space(01)+;
                                                                     cyytskdp->skdcolcod+space(01)+;
                                                                     cyytskdp->skdsec+space(01)+;
                                                                     cyytskdp->skdinscod)
                                        endif
                                        if cyytskdp->skdsplcod=="S"
                                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                                nrecno:=cyytskdp->(recno())
                                                cyytskdp->(sx_settagorder(1))
                                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                                     cyytskdp->skdmdn+space(01)+;
                                                                     cyytskdp->skdday+space(01)+;
                                                                     cyytskdp->skdrom+space(01)+;
                                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                                     cyytskdp->skdsplskd+space(01)+;
                                                                     cyytskdp->skdsplcod+space(01)+;
                                                                     cyytskdp->skdcolcod+space(01)+;
                                                                     cyytskdp->skdsec+space(01)+;
                                                                     cyytskdp->skdinscod)
                                                cyytskdp->(sx_settagorder(2))
                                                cyytskdp->(dbgoto(nrecno))
                                        endif
                                endif
                        case ccolcode == cyytskdp->skdcolcod
                          if ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cyytskdp->skdinscod)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                          endif
                endcase
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

*------------------------------------------------------------------------------*

function skdforcsu()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ccdx,cfile
private cdummy := "csu"+strzero(memvar->naccess,2),csumaster,csudetail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule for C.S.U. File  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,20 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"t999lst",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif

        if whereprint({||pskdforcsu(cterm,cdesc)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"M.TXT"); ccdx := (memvar->cdummy+"M.CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"D.TXT"); ccdx := (memvar->cdummy+"D.CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"P.TXT"); ccdx := (memvar->cdummy+"P.CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

function pskdforcsu(cterm,cdesc)
local abtext := {},ncol,nmaxcol := 76, npage := 0, nctr := 0, afile,;
      abtext1 := {},nrow := 0,ncol1:=0,nrow1:=0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"M",{{"BTIMEX"  ,"C",04,0},;
                                     {"ETIMEX"  ,"C",04,0},;
                                     {"DAYS"    ,"C",04,0},;
                                     {"BTIME"   ,"C",05,0},;
                                     {"ETIME"   ,"C",05,0}},{||cdxmcsu()}) .or.;
   ! createdummy(memvar->cdummy+"D",{{"BTIMEX"  ,"C",04,0},;
                                     {"ETIMEX"  ,"C",04,0},;
                                     {"DAYS"    ,"C",04,0},;
                                     {"ROOM"    ,"C",04,0},;
                                     {"UNIT"    ,"N",05,1},;
                                     {"ECODE"   ,"C",05,0},;
                                     {"SUBJ"    ,"C",12,0},;
                                     {"TYPE"    ,"C",03,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",01,0}},{||cdxdcsu()})
        dbcloseall()
        return(nil)
endif
memvar->csumaster := memvar->cdummy+"M"
memvar->csudetail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->csumaster+".TXT"),"csumaster",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->csudetail+".TXT"),"csudetail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
csumaster->(__dbzap()); csumaster->(dbreindex())
csudetail->(__dbzap()); csudetail->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+;
                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Civil Security Unit",nmaxcol))+;
                              "Civil Security Unit"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})

**filtering data**
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if empty(cyytskdp->skdrescod) .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2"

                if ! csumaster->(dbseek(cyytskdp->skdday+str(cyytskdp->skdbegtimx,4)+str(cyytskdp->skdendtimx,4)))
                        csumaster->(dbappend())
                        csumaster->btimex       := str(cyytskdp->skdbegtimx,4)
                        csumaster->etimex       := str(cyytskdp->skdendtimx,4)
                        csumaster->days         := cyytskdp->skdday
                        csumaster->btime        := cyytskdp->skdbegtim
                        csumaster->etime        := cyytskdp->skdendtim
                endif

                t999lst->(dbseek(cyytskdp->skdinscod))
                csudetail->(dbappend())
                csudetail->btimex       := str(cyytskdp->skdbegtimx,4)
                csudetail->etimex       := str(cyytskdp->skdendtimx,4)
                csudetail->days         := cyytskdp->skdday
                csudetail->room         := cyytskdp->skdrom
                csudetail->unit         := cyytskdp->skdunt
                csudetail->ecode        := cyytskdp->skdcod
                csudetail->subj         := cyytskdp->skdsubcod
                csudetail->type         := if(cyytskdp->skdsubtyp=="LAB","LAB","   ")
                csudetail->lname        := t999lst->tlname
                csudetail->fname        := left(t999lst->tfname,1)

        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
enddo

**printing**
pageprint(abtext)
head2()
head1()
csumaster->(dbgotop())
do while ! csumaster->(eof())
        fask(10,"  Printing time "+csumaster->btime+"-"+csumaster->etime+" days "+csumaster->days+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        csudetail->(sx_setscope(_TOP_SCOPE   ,csumaster->days+csumaster->btimex+csumaster->etimex))
        csudetail->(sx_setscope(_BOTTOM_SCOPE,csumaster->days+csumaster->btimex+csumaster->etimex))
        csudetail->(dbgotop())
        do while ! csudetail->(eof())
                fask(16,"  Printing instructor "+alltrim(csudetail->lname)+" subject "+alltrim(csudetail->subj)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if prow() > 60
                        __eject()
                        pageprint(abtext)
                        head2()
                        head1()
                endif
               if !empty(csudetail->lname)
                @ prow()+01,ncol1 say chr(15)+csudetail->lname+csudetail->fname+". "+;
                                   csudetail->ecode+"  "+;
                                   csudetail->subj+" "+csudetail->type+"  "+;
                                   csudetail->room+"  "+;
                                   "____________"+chr(18)
                 ncol1 := 66
                else
                 ncol1 := 00
                 @ prow()+01,00 say ""
               endif
                csudetail->(dbskip())
                if nextkey() == K_ESC
                        exit
                endif
               if !empty(csudetail->lname)
                  @ prow()+00,ncol1 say chr(15)+csudetail->lname+csudetail->fname+". "+;
                                   csudetail->ecode+"  "+;
                                   csudetail->subj+" "+csudetail->type+"  "+;
                                   csudetail->room+"  "+;
                                   "____________"+chr(18)
               endif
                csudetail->(dbskip())
                ncol1:=00
        enddo
        csudetail->(clearscope())

        if nextkey() == K_ESC
                exit
        endif
        csumaster->(dbskip())
        if ! csumaster->(eof())
                nrow := prow()+2
                if ! nrow > 60
                       * @ prow()+01,00 say ""
                        head2()
                        nrow := 0
                endif
        endif
enddo
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)
*------------------------------------------------------------------------------*
static function cdxmcsu()
field btimex,etimex,days
private cdummyfile := alias()
index on days+btimex+etimex tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
*index on btimex+etimex+days tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)
*------------------------------------------------------------------------------*
static function cdxdcsu()
field btimex,etimex,days,room
private cdummyfile := alias()
*index on btimex+etimex+days+room tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on days+btimex+etimex+room tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)
*------------------------------------------------------------------------------*
static function head1()
@ prow()+01,00 say chr(15)+"  INSTRUCTOR      ECODE      SUBJECT       RM#     REMARKS   "+chr(18)
@ prow()+00,66 say chr(15)+"  INSTRUCTOR      ECODE      SUBJECT       RM#     REMARKS   "+chr(18)
@ prow()+00,00 say chr(15)+"________________  _____  ________________  ____  ____________"+chr(18)
@ prow()+00,66 say chr(15)+"________________  _____  ________________  ____  ____________"+chr(18)
return(nil)
*------------------------------------------------------------------------------*
static function head2()
@ prow()+01,00 say chr(15)+"  TIME: "+csumaster->btime+"-"+csumaster->etime+space(10)+"DAYS: "+csumaster->days+chr(18)
@ prow()+00,00 say chr(15)+"  "+replicate("_",37)+chr(18)
*@ prow()+01,00 say " "
return(nil)
*------------------------------------------------------------------------------*
function genedpcode()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aentryscr, cstartcode, cendcode

boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Generate EDP Code  ")
commandline("Г                               ESC - Previous                                 Г")
aentryscr := savescr(01,00,24,79)
cstartcode := cendcode := space(5)

do while .t.
        restscr(aentryscr)
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Starting EDP Code  :";
                color memvar->colorarray[02];
                get cstartcode pict "@!";
                valid ! empty(cstartcode)
        @ 03,02 say "Ending EDP Code    :";
                color memvar->colorarray[02];
                get cendcode pict "@!";
                valid cendcode >= cstartcode
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        if val(cstartcode) == 0
                fask(10,"  Starting EDP code entered not valid.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if val(cendcode) == 0
                fask(10,"  Ending EDP code entered not valid.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if whereprint({||pgenedpcode(cstartcode,cendcode)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
enddo
restscr(alastscr)
return(nil)

static function pgenedpcode(cstartcode,cendcode)
local nrecno, nck, n, i, nctr := 0, nctr1 := 0
@ prow()+00,00 say chr(17)+chr(15)
@ prow()+01,00 say "<<EDP Code>>"
@ prow()+01,nctr say strzero(val(cstartcode),5)+"; "
nctr += 7
++nctr1
do while ! cstartcode > cendcode
        fask(10,"  Printing edp code "+cstartcode+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        nrecno := val(substr(cstartcode,1,4)) + 1
        cstartcode := transform(nrecno,"9999")
        nck := val(substr(cstartcode,1,1))+val(substr(cstartcode,3,1))
        n   := val(substr(cstartcode,2,1))
        nck := nck + if(n>=5,n*2-9,n*2)
        n   := val(substr(cstartcode,4,1))
        nck := nck + if(n>=5,n*2-9,n*2)
        nck := if(nck%10==0,0,10-(nck%10))
        cstartcode := cstartcode+transform(nck,"9")
        for n := 1 to 3
                cstartcode := if(substr(cstartcode,n,1) == " ",stuff(cstartcode,n,1,"0"),cstartcode)
        next

        @ prow()+00,nctr say strzero(val(cstartcode),5)+"; "

        nctr += 7
        if ++nctr1 > 16
                nctr1 := 0
                nctr := 0
                @ prow()+01,00 say ""
        endif
enddo
__eject()
return(nil)


*-------------------------------------------------------------------------------

function consroomtime()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule Printing by Room/Time ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,, cyytskdp,"cyytskdp",_DBF_SHARED,,7},;
                                     {,, "t999lst",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||pconsroomtime(cdesc)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pconsroomtime(cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile, croom, cinstr

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CONSOLIDATED SCHEDULE OF CLASSES BY ROOM/TIME",nmaxcol))+;
                              "CONSOLIDATED SCHEDULE OF CLASSES BY ROOM/TIME"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
/*
aadd(abtext,{||" ROOM    TIME     DAYS CODE      SUBJECT      SIZE CRSE   INSTRUCTOR    REMARKS"})
aadd(abtext,{||" ---- ----------- ---- ----- ---------------- ---- ---- --------------- -------"})
*/

aadd(abtext,{||" ROOM    TIME     DAYS CODE      SUBJECT      UNIT SIZE   INSTRUCTOR    REMARKS "})
aadd(abtext,{||" ---- ----------- ---- ----- ---------------- ---- ---- --------------- ------- "})

/*
ROOM    TIME     DAYS CODE      SUBJECT      SIZE CRSE   INSTRUCTOR    REMARKS
---- ----------- ---- ----- ---------------- ---- ---- --------------- -------
1234 11:11-11:11 1234 12345 123456789012 123 12.1 1234 123456789012345 _______
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
croom := cyytskdp->skdrom
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})

        if ! alltrim(str(cyytskdp->skdunt,5,1)) == "1.5" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                .and. ! cyytskdp->skdrescod == _DISSOLVED
        /*
        if ! alltrim(str(cyytskdp->skdunt,5,1)) == "1.5" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                .and. ! cyytskdp->skdrescod == _DISSOLVED  .and. ! cyytskdp->skdcolcod $ "MTMIPAROCS**"
        */
                t999lst->(dbseek(cyytskdp->skdinscod))
                cinstr := t999lst->tlname
                outexpr(prow()+01,00,space(01)+cyytskdp->skdrom+space(01)+;
                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                     cyytskdp->skdday+space(01)+;
                                     cyytskdp->skdcod+space(01)+;
                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                     cyytskdp->skdcolcod+space(01)+;
                                     cinstr+" _______")
        /*
                outexpr(prow()+01,00,space(01)+cyytskdp->skdrom+space(01)+;
                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                     cyytskdp->skdday+space(01)+;
                                     cyytskdp->skdcod+space(01)+;
                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                     transform(cyytskdp->skdunt,"9.9")+space(01)+;
                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                     cinstr+" _______")
        */

        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
        if ! alltrim(cyytskdp->skdinscod) $ "0,1,2"
                if ! croom == cyytskdp->skdrom
                        outexpr(prow()+01,00," ")
                        croom := cyytskdp->skdrom
                endif
        endif
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

*-------------------------------------------------------------------------------
function winst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,ccolcode

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Consolidated Schedule Printing (by Subject with Instructor)  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        /* @ 03,01 say replicate("Ф",78) */
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
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                     {,,"t999lst",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View College File      Г          ESC - Previous               Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   - [NT-nautical MG-marine UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid viewcoll(ccolcode,cprocsts)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pwinst(cdesc,ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pwinst(cdesc,ccolcode)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cinstruc,nrecno,csubject
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("CONSOLIDATED SCHEDULE OF CLASSES",nmaxcol))+;
                              "CONSOLIDATED SCHEDULE OF CLASSES"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                                                           SPLIT               "})
aadd(abtext,{||"CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD"})
aadd(abtext,{||"----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------"})

/*
                                                           SPLIT
CODE       SUBJECT         TIME       DAYS ROOM UNIT SIZE  SKD  T CC SEC INSCOD
----- ---------------- -------------- ---- ---- ---- ---- ------- -- --- ------
12345 123456789012 123 11:11-11:11 12 1234 1234 12.1 1234 12345 1 MT 123 123456
*/

pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
cyytskdp->(dbgotop())
csubject := cyytskdp->skdsubcod
do while ! cyytskdp->(eof())
        fask(10,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+" "+cyytskdp->skdsubtyp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                     abtext, prow() + 1, _MAX_LINE, {||__eject()})
        t999lst->(dbseek(cyytskdp->skdinscod))
        cinstruc := t999lst->tlname
        do case
                case ccolcode == "UC"
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cinstruc)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cinstruc)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
                case ccolcode == "NT" &&nautical
                        if cyytskdp->skdcolcod $ "MV,MS,MI,MT,PA,SN,YN,BN,HN,NV,NW" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                                .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cinstruc)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cinstruc)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == "MG" &&marine
                        if cyytskdp->skdcolcod $ "MM,MA,MR,MP,MD,SM,YM,BM,HM,NM,MW" .and. ! alltrim(cyytskdp->skdinscod) $ "0,1,2";
                                .and. ! cyytskdp->skdrescod == _DISSOLVED
                                if ! cyytskdp->skdsplcod=="C"
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cinstruc)
                                endif
                                if cyytskdp->skdsplcod=="S"
                                        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                             cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                             cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                             cyytskdp->skdmdn+space(01)+;
                                                             cyytskdp->skdday+space(01)+;
                                                             cyytskdp->skdrom+space(01)+;
                                                             transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                             transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                             cyytskdp->skdsplskd+space(01)+;
                                                             cyytskdp->skdsplcod+space(01)+;
                                                             cyytskdp->skdcolcod+space(01)+;
                                                             cyytskdp->skdsec+space(01)+;
                                                             cinstruc)
                                        cyytskdp->(sx_settagorder(2))
                                        cyytskdp->(dbgoto(nrecno))
                                endif
                        endif
                case ccolcode == cyytskdp->skdcolcod
                  if ! alltrim(cyytskdp->skdinscod) $ "0,1,2" .and. ! cyytskdp->skdrescod == _DISSOLVED
                        if ! cyytskdp->skdsplcod=="C"
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cinstruc)
                        endif
                        if cyytskdp->skdsplcod=="S"
                                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                                nrecno:=cyytskdp->(recno())
                                cyytskdp->(sx_settagorder(1))
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                outexpr(prow()+01,00,cyytskdp->skdcod+space(01)+;
                                                     cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp+space(01)+;
                                                     cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+space(01)+;
                                                     cyytskdp->skdmdn+space(01)+;
                                                     cyytskdp->skdday+space(01)+;
                                                     cyytskdp->skdrom+space(01)+;
                                                     transform(cyytskdp->skdunt,"99.9")+space(01)+;
                                                     transform(cyytskdp->skdactsiz,"9999")+space(01)+;
                                                     cyytskdp->skdsplskd+space(01)+;
                                                     cyytskdp->skdsplcod+space(01)+;
                                                     cyytskdp->skdcolcod+space(01)+;
                                                     cyytskdp->skdsec+space(01)+;
                                                     cinstruc)
                                cyytskdp->(sx_settagorder(2))
                                cyytskdp->(dbgoto(nrecno))
                        endif
                  endif
        endcase
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
        if ! csubject == cyytskdp->skdsubcod
                outexpr(prow()+01,00," ")
                csubject := cyytskdp->skdsubcod
        endif
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

*-------------------------------------------------------------------------------

function plotselsked()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, cyytenrr, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc,cedpcode
private cdummy := "rom"+strzero(memvar->naccess,2),roomfile, cidno

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
memvar->cidno := space(8)
cedpcode := space(5)
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Plot Schedule  ")
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
        if ! file("c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytenrp  := alltrim("c"+cterm+"enrp")
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1},;
                                     {,, cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,"c999RMSK",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

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
                loop
        endif
        if whereprint({||pplotselsked(cedpcode)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aprv2setup)
enddo
cfile:=(memvar->cdummy+".TXT");ccdx:=(memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function pplotselsked(cedpcode)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0, cschedno, cchar := space(1)
local num1, num2, xbegtime, xendtime, lapse, counter, daycounter, element
        
local dayz := {"Monday     ", ;
               "Tuesday    ", ;
               "Wednesday  ", ;
               "Thursday   ", ;
               "Friday     ", ;
               "Saturday   ", ;
               "Sunday     "}

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"IDNO"        ,"C",08,0},;
                                     {"DayNum"      ,"C",01,0},;
                                     {"RMTIME"      ,"C",31,0}},{||cdxplotsked()})

//    ! createdummy(memvar->cdummy+"H",{{"RMNO"        ,"C",04,0},;
//                                   {"Desc"        ,"C",15,0}},{||cdxromtimh()})
//
        dbcloseall()
        return(nil)
endif
memvar->detail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->detail+".TXT"),"detail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
detail->(__dbzap());detail->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("PLOT SCHEDULE",nmaxcol))+;
                              "PLOT SCHEDULE"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||replicate("-",140)})
aadd(abtext,{||""})

*-----------------------
* Set Scope for ID No.
*-----------------------

cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))

//cyytenrr->(dbsetrelation("cyytskdp",{||cyytenrr->enridno},"cyytenrr->enridno"))

detail->(sx_settagorder(3))
cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
                   if lastkey() == K_ESC
                           exit
                   endif

       c999sm1p->(dbseek(cyytenrr->enridno))
//       fask(10,"  "+c999sm1p->sm1lstnam+", "+c999sm1p->sm1fstnam+"  ",{" Ok "},memvar->colorarray[05],.f.,nil)
   if cyytenrp->(dbseek(cyytenrr->enridno))
       nctr := 1
       cschedno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
       do while (cyytenrp->&cschedno != "00000")
       if cyytskdp->(dbseek(cyytenrp->&cschedno))
       for daycounter := 1 to 7
                   if lastkey() == K_ESC
                           exit
                   endif
           if substr(cyytskdp->skddayx,daycounter,1) =="X"
               num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
               num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
               xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
               xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
               lapse := (xendtime - xbegtime)/0.5

//               fask(10,"  "+cyytenrr->enridno+transform(daycounter,"9")+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

               if ! detail->(dbseek(transform(daycounter,"9")))
                   detail->(dbappend())
                   detail->daynum := transform(daycounter,"9")
                   detail->rmtime := space(31)
               else
                   detail->(reclock())
               endif
/*
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if substr(detail->rmtime,counter+1,1) != "м"
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"м")
                   else
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"*")
                   endif
               next counter
*/
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if lastkey() == K_ESC
                           exit
                   endif

                   cchar := substr(detail->rmtime,counter+1,1)
//                   fask(10,"  "+cchar+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                   if substr(detail->rmtime,counter+1,1) == " "
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"1")
                   elseif (cchar > "0" ) .and. (cchar < "9" )
//                      fask(10,"  1 -> "+substr(detail->rmtime,counter+1,1)+" + 1 = "+str(val(cchar)+1)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,alltrim(str(val(cchar)+1)))
//                      fask(10,"  2 -> "+substr(detail->rmtime,counter+1,1)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                   else
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"*")
                   endif
               next counter

               detail->(dbcommit())
               detail->(dbunlock())
               if nextkey() == K_ESC
                       exit
               endif
           endif
       next daycounter
       endif
       nctr += 1
       cschedno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
       enddo
   endif

   cyytenrr->(dbskip())
enddo

cyytskdp->(clearscope())

** Printing Data **
element := 0

detail->(sx_settagorder(1))
detail->(dbgotop())

//pageprint(abtext)
        outexpr(prow()+01,00,   "                          1 1 1                   1")
        outexpr(prow()+01,00,   "                    7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0")
        for daycounter := 1 to 7
           if detail->(dbseek(cidno+transform(daycounter,"9")))
              outexpr(prow()+01,00,"      "+dayz[daycounter]+"   "+detail->rmtime)
           else
              outexpr(prow()+01,00,"      "+dayz[daycounter])
           endif
        next daycounter
        detail->(clearscope())
        if (element += 1) == 5
           outexpr(prow()+01,00,chr(12)+chr(13))
           pageprint(abtext)
           element := 0
        else
           outexpr(prow()+01,00,"")
        endif
__eject()
closewcheck(afile)
return(nil)


static function cdxplotsked()
field idno,daynum
private cdummyfile := alias()
index on idno+daynum tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on idno        tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
index on daynum      tag (memvar->cdummyfile+"3") of (memvar->cdummyfile)
return(nil)




*-------------------------------------------------------------------------------

function chkskdbysec()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytskdp, cyytsecp, cprocsts, aentryscr,;
      cterm,cdesc, counter
private cdummy := "sec"+strzero(memvar->naccess,2)

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Check Schedule by Section ")
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
        if ! file("c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("c"+cterm+"secp.dbf")
                fask(10,"  C"+cterm+"SECP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytskdp  := alltrim("c"+cterm+"skdp")
        cyytsecp  := alltrim("c"+cterm+"secp")
        if(aprv2setup := openwcheck({{,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytsecp,"cyytsecp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||pchkskdbysec(cterm,cdesc)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
cfile:=(memvar->cdummy+"D.TXT");ccdx:=(memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
cfile:=(memvar->cdummy+"H.TXT");ccdx:=(memvar->cdummy+"H.CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function pchkskdbysec(cterm,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0
local num1, num2, xbegtime, xendtime, lapse, counter, daycounter, element
local dayz := {"Monday     ", ;
               "Tuesday    ", ;
               "Wednesday  ", ;
               "Thursday   ", ;
               "Friday     ", ;
               "Saturday   "}


fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"SEC"         ,"C",03,0},;
                                     {"DayNum"      ,"C",01,0},;
                                     {"TIME"        ,"C",31,0}},{||cdxsecd()}) .or. ;
   ! createdummy(memvar->cdummy+"H",{{"SEC"         ,"C",03,0},;
                                     {"Desc"        ,"C",30,0}},{||cdxsech()})
        dbcloseall()
        return(nil)
endif
memvar->header := memvar->cdummy+"H"
memvar->detail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->header+".TXT"),"header",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->detail+".TXT"),"detail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
header->(__dbzap());header->(dbreindex())
detail->(__dbzap());detail->(dbreindex())
header->(sx_settagorder(1))
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(" ",nmaxcol)-14)+;
                                              " "})
aadd(abtext,{||space(titlepos("CHECK SCHEDULE BY SECTION",nmaxcol))+;
                              "CHECK SCHEDULE BY SECTION"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||replicate("-",140)})
aadd(abtext,{||""})

cyytskdp->(sx_settagorder(1))
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
   fask(10,"  Gathering Information for EDP CODE: "+cyytskdp->skdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
//   if (c999room->(dbseek(cyytskdp->skdrom))) .and. !(c999room->status $ "LM")
   if !empty(cyytskdp->skdsec)
       for daycounter := 1 to 6
           if substr(cyytskdp->skddayx,daycounter,1) =="X"
               num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
               num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
               xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
               xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
               lapse := (xendtime - xbegtime)/0.5

               if ! detail->(dbseek(cyytskdp->skdsec+transform(daycounter,"9")))
                   detail->(dbappend())
                   detail->sec    := cyytskdp->skdsec
                   detail->daynum := transform(daycounter,"9")
                   detail->time := space(31)
                   if ! header->(dbseek(cyytskdp->skdsec))
                        c999colp->(dbseek(cyytskdp->skdcolcod))
                        header->(dbappend())
                        header->sec := cyytskdp->skdsec
//                        header->desc := c999colp->colnamcol
                        header->desc := c999colp->coldesful
                   endif
               else
                   detail->(reclock())
               endif
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if substr(detail->time,counter+1,1) != "м"
                      detail->time := stuff(detail->time,counter+1,1,"м")
                   else
                      detail->time := stuff(detail->time,counter+1,1,"*")
                   endif
               next counter
               detail->(dbcommit())
               detail->(dbunlock())
               if nextkey() == K_ESC
                       exit
               endif
           endif
       next daycounter
   endif
   cyytskdp->(dbskip())
enddo

** Printing Data **
element := 0
pageprint(abtext)
header->(sx_settagorder(2))
header->(dbgotop())
do while ! header->(eof())
   fask(10,"  Printing college of "+header->desc+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,header->sec+"  "+header->desc)
        outexpr(prow()+01,00,   "                          1 1 1                   1")
        outexpr(prow()+01,00,   "                    7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0")
        detail->(sx_setscope(_TOP_SCOPE   ,header->sec))
        detail->(sx_setscope(_BOTTOM_SCOPE,header->sec))
        for daycounter := 1 to 6
           if detail->(dbseek(header->sec+transform(daycounter,"9")))
              outexpr(prow()+01,00,"      "+dayz[daycounter]+"   "+detail->time)
           else
              outexpr(prow()+01,00,"      "+dayz[daycounter])
           endif
        next daycounter
        detail->(clearscope())
        if (element += 1) == 5
           outexpr(prow()+01,00,chr(12)+chr(13))
           pageprint(abtext)
           element := 0
        else
           outexpr(prow()+01,00,"")
        endif
   header->(dbskip())
enddo
__eject()
closewcheck(afile)
return(nil)

static function cdxsecd()
field sec,daynum,time
private cdummyfile := alias()
index on sec+daynum     tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function cdxsech()
field sec,desc
private cdummyfile := alias()
index on sec            tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on desc+sec       tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)


