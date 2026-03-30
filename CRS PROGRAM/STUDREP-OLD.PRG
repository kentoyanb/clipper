* Program       :  STUDREP.PRG
* Author        :  Jun Benlot and Randy F. Santizo (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

static function viewcoll(ccode,cprocsts)
if ccode $ "UC,NT,MG"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 03,23 say c999colp->coldesful+space(20)
return(.t.)

function gradlstprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, aentryscr,;
      bprint, cprocsts, cterm := space(03),ccolcode := space(02)
private cdummy := "gradlst"+strzero(memvar->naccess,2), gradfil

if(aprv1setup := openwcheck({{,,"term"    ,,_DBF_SHARED,,1},;
                             {,,"c999colp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Detailed Enrollment List Printing  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
/*        @ 03,25 say "[UC - All Course]" color memvar->colorarray[02]
        @ 03,02 say "College Code   :";
                color memvar->colorarray[02];
                get ccolcode    pict "@!";
                valid viewcoll(ccolcode,cprocsts)
*/
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
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        if(aprv2setup := openwcheck({{,,"c999offr",,_DBF_SHARED,,6},;
                                     {,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
                restscr(aentryscr)
                if whereprint({||pgradlstprn(cterm,ccolcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function pgradlstprn(cterm,ccolcode)
local abtext := {},ncol,nmaxcol := 140, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,cyeardesc,cskdno, nnautical := 0,;
      nmarine := 0, nmro := 0


fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",08,0},;
                                 {"DBIRTH"      ,"D",08,0},;
                                 {"HOMEADD"     ,"C",30,0},;
                                 {"CITYADD"     ,"C",30,0},;
                                 {"REMARKS"     ,"C",09,0}},{||cdxgradlst()})
        dbcloseall()
        return(nil)
endif
memvar->gradfil := memvar->cdummy
if(afile := openwcheck({{,,(memvar->gradfil+".TXT"),"gradfil",_DBF_EXCLUSIVE,,2}})) == nil
        dbcloseall()
        return(nil)
endif

gradfil->(__dbzap());gradfil->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+chr(15)})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(" LIST OF GRADUATES ",nmaxcol)-14)+;
                                              " LIST OF GRADUATES "})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})

*aadd(abtext,{||space(titlepos(alltrim(tempstr),nmaxcol))+alltrim(tempstr)})
*aadd(abtext,{||space(titlepos(alltrim(c999colp->coldesful),nmaxcol))+alltrim(c999colp->coldesful)})
*aadd(abtext,{||space(titlepos(alltrim(cyrlevel),nmaxcol))+alltrim(cyrlevel)})
aadd(abtext,{||""})
aadd(abtext,{||"       Last Name        First Name                M  COURSE    D - Birth   City Address                    Home Address                    "})
aadd(abtext,{||"       ---------------  ------------------------  -  --------  ----------  ------------------------------  ------------------------------  "})

/*
       Last Name        First Name                M  COURSE    D - Birth   Home Address                    Remarks
       ---------------  ------------------------  -  --------  ----------  ------------------------------  ---------
12345. 123456789012345  123456789012345678901234  1  12345678  11/11/1111  123456789012345678901234567890  _________
*/
c999offr->(sx_setscope(_TOP_SCOPE   ,cterm+"GR"))
c999offr->(sx_setscope(_BOTTOM_SCOPE,cterm+"GR"))
c999offr->(dbgotop())
do while ! c999offr->(eof())
        fask(10,"  Processing Student : "+alltrim(alltrim(c999offr->r_lname)+", "+alltrim(c999offr->r_fname)+" "+alltrim(c999offr->r_mname))+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        gradfil->(dbappend())
        gradfil->lname    := c999offr->r_lname
        gradfil->fname    := c999offr->r_fname
        gradfil->mname    := c999offr->r_mname
        if c999sm1p->(dbseek(c999offr->r_idno))
           if c999sm1p->sm1colcod $ "MT,MV,ME,MI,MO,MS,PA"
              gradfil->course := "NAUTICAL"
              nnautical += 1
           elseif c999sm1p->sm1colcod $ "MA,MM,MR,MB,MD,MP"
              gradfil->course := "MARINE  "
              nmarine += 1
           elseif c999sm1p->sm1colcod $ "RO"
              gradfil->course := "MRO     "
              nmro += 1
           else
              gradfil->course := space(8)
           endif
        endif
        if c999sm2p->(dbseek(c999offr->r_idno))
           gradfil->dbirth := c999sm2p->sm2birdte
        else
           gradfil->dbirth := ctod(space(8))
        endif
        gradfil->cityadd  := c999offr->r_caddr
        gradfil->homeadd  := c999offr->r_haddr
        c999offr->(dbskip())
enddo

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
gradfil->(dbgotop())
do while ! gradfil->(eof())
        fask(10,"  Printing name "+alltrim(gradfil->lname)+", "+alltrim(gradfil->fname)+" "+gradfil->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                             gradfil->lname+space(02)+;
                             gradfil->fname+space(02)+;
                             gradfil->mname+space(02)+;
                             gradfil->course+space(02)+;
                             dtoc(gradfil->dbirth)+space(02)+;
                             gradfil->cityadd+space(02)+;
                             gradfil->homeadd+space(02))
/*      if ! empty(gradfil->remarks)
                outexpr(prow()+00,128,gradfil->remarks)
        endif*/
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        gradfil->(dbskip())
enddo
        outexpr(prow()+02,07,"Summary:")
        outexpr(prow()+01,07,"Nautical => "+transform(nnautical,"9,999"))
        outexpr(prow()+01,07,"Marine   => "+transform(nmarine  ,"9,999"))
        if nmro>0
            outexpr(prow()+01,07,"MRO      => "+transform(nmro ,"9,999"))
        endif
        outexpr(prow()+01,07,"           -------")
        outexpr(prow()+01,07,"Total    => "+transform(nnautical+nmarine+nmro  ,"9,999"))
if npage > 0
        outexpr(prow()+00,00,chr(18))
        __eject()
endif
closewcheck(afile)
return(nil)

static function cdxgradlst()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

function detlstprn(nchoice)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, aentryscr,;
      bprint, cprocsts, cterm := space(03), cdesc,csubject,ccolcode:="UC"
private cdummy := "detlst"+strzero(memvar->naccess,2), yrlvlfil

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Detailed Enrollment List Printing  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyrlvl := space(len(cyytenrp->enryrlevl))
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View College File       ³           ESC - Previous              ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-nautical, MG-marine, UC-all course]" color memvar->colorarray[02]
                @ 04,23 say "[1 2 3 4 5  8-All]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                @ 04,02 say "Year Level     :";
                        color memvar->colorarray[02];
                        get cyrlvl    pict "@!";
                        valid cyrlvl $ _FIRST_YEAR+;
                                         _SECOND_YEAR+;
                                         _THIRD_YEAR+;
                                         _FOURTH_YEAR+;
                                         _FIFTH_YEAR+;
                                         _ALL_YEAR
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pdetlstprn(cdesc,cyrlvl,ccolcode,nchoice)}) == 1
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

static function pdetlstprn(cdesc,cyrlvl,ccolcode,nchoice)
local abtext := {},ncol,nmaxcol := 140, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,cyeardesc,cskdno

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"DENROLL"     ,"D",08,0},;
                                 {"DBIRTH"      ,"D",08,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"HOMEADD"     ,"C",30,0},;
                                 {"CITYADD"     ,"C",30,0},;
                                 {"REMARKS"     ,"C",09,0},;
                                 {"GUARDIAN"    ,"C",30,0},;
                                 {"ADDLINE1"    ,"C",35,0},;
                                 {"ADDLINE2"    ,"C",35,0}},{||cdxyrlevel()})
        dbcloseall()
        return(nil)
endif
memvar->yrlvlfil := memvar->cdummy
if(afile := openwcheck({{,,(memvar->yrlvlfil+".TXT"),"yrlvlfil",_DBF_EXCLUSIVE,,2}})) == nil
        dbcloseall()
        return(nil)
endif

cyrlevel := space(14)

do case
        case cyrlvl == "1"
                cyrlevel = "1st YEAR"
        case cyrlvl == "2"
                cyrlevel = "2nd YEAR"
        case cyrlvl == "3"
                cyrlevel = "3rd YEAR"
        case cyrlvl == "4"
                cyrlevel = "4th YEAR"
        case cyrlvl == "5"
                cyrlevel = "5th YEAR"
        case cyrlvl == "8"
                cyrlevel = "ALL YEAR LEVEL"
endcase

yrlvlfil->(__dbzap());yrlvlfil->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+chr(15)})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(" DETAILED ENROLLMENT LIST ",nmaxcol)-14)+;
                                              " DETAILED ENROLLMENT LIST "})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
c999colp->(dbseek(ccolcode))
do case
        case ccolcode == "UC"
                tempstr = space(len(alltrim("ALL  COURSES")))
                tempstr = "ALL  COURSES"
        case ccolcode == "MG"
                tempstr = space(len(alltrim("MARINE ENGINEERING - ALL")))
                tempstr = "MARINE ENGINEERING - ALL"
        case ccolcode == "NT"
                tempstr = space(len(alltrim("MARINE TRANSPORTATION - ALL")))
                tempstr = "MARINE TRANSPORTATION - ALL"
        otherwise
                tempstr = space(len(alltrim(c999colp->coldesful)))
                tempstr = c999colp->coldesful
endcase
aadd(abtext,{||space(titlepos(alltrim(tempstr),nmaxcol))+alltrim(tempstr)})
*aadd(abtext,{||space(titlepos(alltrim(c999colp->coldesful),nmaxcol))+alltrim(c999colp->coldesful)})
aadd(abtext,{||space(titlepos(alltrim(cyrlevel),nmaxcol))+alltrim(cyrlevel)})
aadd(abtext,{||""})
if nchoice==1
        aadd(abtext,{||"        ID No.      Last Name            First Name         M  D - Enroll  D - Birth   Course           Home Address            Remarks "})
        aadd(abtext,{||"       --------  ---------------  ------------------------  -  ----------  ----------  ------  ------------------------------  ---------"})
else
        aadd(abtext,{||"        ID No.              Guardian                      Home Address                    Add. Line 1                      Add. Line 2         "})
        aadd(abtext,{||"       --------  ------------------------------  ------------------------------  ------------------------------  ------------------------------"})
endif

/*
                             yrlvlfil->idno+space(02)+;
                             yrlvlfil->guardian+space(02)+;
                             yrlvlfil->cityadd+space(02)+;
                             yrlvlfil->homeadd+space(02)+;
                             yrlvlfil->addline1+space(02)+;
                             yrlvlfil->addline2+space(02)+;
*/

/*
        ID No.      Last Name            First Name         M  D - Enroll  D - Birth   Course           Home Address            Remarks
       --------  ---------------  ------------------------  -  ----------  ----------  ------  ------------------------------  ---------
12345. 12345678  123456789012345  123456789012345678901234  1  11/11/1111  11/11/1111  123456  123456789012345678901234567890  _________
*/

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
   if (cyytenrp->enryrlevl == cyrlvl) .or. (cyrlvl == "8")
        fask(10,"  Processing id number "+alltrim(cyytenrp->enridno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ccolcode == "UC"
                        detwritefile(cyrlvl)
                case ccolcode == "NT"
                        if cyytenrp->enrcolcod $ "MIMTPAMVSNYNHNBNETNVNW"
                                detwritefile(cyrlvl)
                        endif
                case ccolcode == "MG"
                        if cyytenrp->enrcolcod $ "MAMRMPMDMMSMYMHMBMERENELNMMW"
                                detwritefile(cyrlvl)
                        endif
                case ccolcode == cyytenrp->enrcolcod
                        detwritefile(cyrlvl)
        endcase
        if nextkey() == K_ESC
                exit
        endif
   endif
   cyytenrp->(dbskip())
enddo
cyytenrp->(dbclearrelation())

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
yrlvlfil->(dbgotop())
do while ! yrlvlfil->(eof())
        fask(10,"  Printing name "+alltrim(yrlvlfil->lname)+", "+alltrim(yrlvlfil->fname)+" "+yrlvlfil->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        if nchoice==1
        outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                             yrlvlfil->idno+space(02)+;
                             yrlvlfil->lname+space(02)+;
                             yrlvlfil->fname+space(02)+;
                             yrlvlfil->mname+space(02)+;
                             displaydate(yrlvlfil->denroll)+space(02)+;
                             displaydate(yrlvlfil->dbirth)+space(02)+;
                             yrlvlfil->course+space(02)+;
                             yrlvlfil->homeadd+space(02)+;
                             "__________")
        else
        outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                             yrlvlfil->idno+space(02)+;
                             yrlvlfil->guardian+space(02)+;
                             yrlvlfil->homeadd+space(02)+;
                             yrlvlfil->addline1+space(02)+;
                             yrlvlfil->addline2)
        endif
/*
                             yrlvlfil->lname+space(02)+;
                             yrlvlfil->fname+space(02)+;
                             yrlvlfil->mname+space(02)+;
*/
        if ! empty(yrlvlfil->remarks) .and. nchoice==1
                outexpr(prow()+00,128,yrlvlfil->remarks)
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        yrlvlfil->(dbskip())
enddo
if npage > 0
        outexpr(prow()+00,00,chr(18))
        __eject()
endif
closewcheck(afile)
return(nil)

static function detwritefile(cyrlvl)
      yrlvlfil->(dbappend())
      yrlvlfil->idno         := cyytenrp->enridno
      yrlvlfil->denroll      := cyytenrp->enrdte
      if cyytenrp->enrenrst $ _WITHDRAW_BEFORE+;
             _WITHDRAW_AFTER
             yrlvlfil->remarks := "WITHDRAWN"
      else
             yrlvlfil->remarks := space(09)
      endif
      yrlvlfil->lname        := c999sm1p->sm1lstnam
      yrlvlfil->fname        := c999sm1p->sm1fstnam
      yrlvlfil->mname        := c999sm1p->sm1midnam
      yrlvlfil->homeadd      := c999sm1p->sm1homadr
      c999sm2p->(dbseek(cyytenrp->enridno))
      yrlvlfil->dbirth       := c999sm2p->sm2birdte
      c999colp->(dbseek(cyytenrp->enrcolcod))
      yrlvlfil->course       := c999colp->coldesabr
      yrlvlfil->homeadd      := c999sm1p->sm1homadr
      yrlvlfil->cityadd      := c999sm2p->sm2citadr
      yrlvlfil->guardian     := c999sm2p->sm2gdn
      yrlvlfil->addline1     := left(c999sm2p->sm2malad1,35)
      yrlvlfil->addline2     := left(c999sm2p->sm2malad2,35)
return(nil)

static function cdxyrlevel()
field idno,lname,fname,mname
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on lname+fname+mname tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------
function subjlstprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, cyytskdp,aentryscr,;
      bprint, cprocsts, cterm := space(03), cdesc,csubject,ccolcode:="UC"
private cdummy := "sublst"+strzero(memvar->naccess,2), subjfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment List Printing (by Subject)  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := alltrim("c"+cterm+"enrp")
        cyytskdp := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,2},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        csubject := space(len(cyytskdp->skdsubcod))
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View College File       ³           ESC - Previous              ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-nautical, MG-marine, UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code   :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                @ 04,02 say "Subject        :";
                        color memvar->colorarray[02];
                        get csubject    pict "@!";
                        valid ! empty(csubject)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! cyytskdp->(dbseek(csubject))
                        fask(10,"  Subject "+alltrim(csubject)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||psubjlstprn(cdesc,csubject,ccolcode)}) == 1
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

static function psubjlstprn(cdesc,csubject,ccolcode)
local abtext := {},ncol,nmaxcol := 140, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,cyeardesc,cskdno

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"DENROLL"     ,"D",08,0},;
                                 {"DBIRTH"      ,"D",08,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"HOMEADD"     ,"C",30,0},;
                                 {"REMARKS"     ,"C",09,0}},{||cdxsubj()})
        dbcloseall()
        return(nil)
endif
memvar->subjfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->subjfile+".TXT"),"subjfile",_DBF_EXCLUSIVE,,2}})) == nil
        dbcloseall()
        return(nil)
endif
subjfile->(__dbzap());subjfile->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+chr(15)})
*aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("ENROLMENT LIST BY SUBJECT",nmaxcol)-14)+;
                                              "ENROLMENT LIST BY SUBJECT"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("Subject => "+alltrim(csubject),nmaxcol))+"Subject => "+alltrim(csubject)})
aadd(abtext,{||""})
aadd(abtext,{||"        ID No.      Last Name            First Name         M  D - Enroll  D - Birth   Course           Home Address            Remarks "})
aadd(abtext,{||"       --------  ---------------  ------------------------  -  ----------  ----------  ------  ------------------------------  ---------"})

/*
        ID No.      Last Name            First Name         M  D - Enroll  D - Birth   Course           Home Address            Remarks
       --------  ---------------  ------------------------  -  ----------  ----------  ------  ------------------------------  ---------
12345. 12345678  123456789012345  123456789012345678901234  1  11/11/1111  11/11/1111  123456  123456789012345678901234567890  _________
*/

cyytskdp->(sx_settagorder(1))
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing id number "+alltrim(cyytenrp->enridno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ccolcode == "UC"
                        writefile(csubject)
                case ccolcode == "NT"
                        if cyytenrp->enrcolcod $ "MIMTPAMVSNYNHNBNETNVNW"
                                writefile(csubject)
                        endif
                case ccolcode == "MG"
                        if cyytenrp->enrcolcod $ "MAMRMPMMSMYMHMBMERENELNMMW"
                                writefile(csubject)
                        endif
                case ccolcode == cyytenrp->enrcolcod
                        writefile(csubject)
        endcase
        cyytenrp->(dbskip())
        if nextkey() == K_ESC
                exit
        endif
enddo
cyytenrp->(dbclearrelation())
cyytskdp->(sx_settagorder(2))

** printing **
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
subjfile->(dbgotop())
do while ! subjfile->(eof())
        fask(10,"  Printing name "+alltrim(subjfile->lname)+", "+alltrim(subjfile->fname)+" "+subjfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                             subjfile->idno+space(02)+;
                             subjfile->lname+space(02)+;
                             subjfile->fname+space(02)+;
                             subjfile->mname+space(02)+;
                             displaydate(subjfile->denroll)+space(02)+;
                             displaydate(subjfile->dbirth)+space(02)+;
                             subjfile->course+space(02)+;
                             subjfile->homeadd+space(02)+;
                             "__________")
        if ! empty(subjfile->remarks)
                outexpr(prow()+00,128,subjfile->remarks)
        endif
        if nextkey() == K_ESC
                exit
        endif
        clearbuffer()
        subjfile->(dbskip())
enddo
if npage > 0
        outexpr(prow()+00,00,chr(18))
        __eject()
endif
closewcheck(afile)
return(nil)


static function writefile(csubject)
local nctr:=0,cskdno
for nctr := 1 to 25
        cskdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&cskdno == "00000"
                 cyytskdp->(dbseek(cyytenrp->&cskdno))
                 if alltrim(cyytskdp->skdsubcod) == alltrim(csubject)
                        subjfile->(dbappend())
                        subjfile->idno         := cyytenrp->enridno
                        subjfile->denroll      := cyytenrp->enrdte
                        if cyytenrp->enrenrst $ _WITHDRAW_BEFORE+;
                                                _WITHDRAW_AFTER
                                subjfile->remarks := "WITHDRAWN"
                        else
                                subjfile->remarks := space(09)
                        endif
                        subjfile->lname        := c999sm1p->sm1lstnam
                        subjfile->fname        := c999sm1p->sm1fstnam
                        subjfile->mname        := c999sm1p->sm1midnam
                        subjfile->homeadd      := c999sm1p->sm1homadr
                        c999sm2p->(dbseek(cyytenrp->enridno))
                        subjfile->dbirth       := c999sm2p->sm2birdte
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        subjfile->course       := c999colp->coldesabr
                        exit
                endif
        else
                exit
        endif
next
return(nil)


static function cdxsubj()
field idno,lname,fname,mname
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on lname+fname+mname tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

#define _SKDNO          1
#define _SUBJECT        2
#define _TIME           3
#define _DAYS           4
#define _ROOM           5
#define _UNITS          6
#define _TIMEX          7
#define _EMPTY_ELEM     {space(08),;
                         space(16),;
                         space(14),;
                         space(04),;
                         space(04),;
                         space(05),;
                         space(04)}
function studyload()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag,cyytmdst, aprv1setup
private aitems := {},nindex := 1,ntotunits := 0,;
        cidno,clname,cfname,cmname,ccourse,nyrlevel,cterm,cdesc,ctdesc,mctrlno

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ostudy  := createabrowse(bitems,bindex,08,03,21,76,;
                        {|xnmode,xoabrowser,xaxparam|fstudy(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_SKDNO]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SUBJECT]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_TIME]+" "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_DAYS]+"  "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_ROOM]+"  "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_UNITS]+" "},nil}},;
                        {" Sched No. ", "      Subject     ", "     Time       ", "  Days  ", "  Room  ", " Units "},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ"})
*                         xx1212345xx    x123456789012x345x    x12345-12345x12x    xx1234xx    xx1234xx    x123.1x

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Study Load Printing  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif

        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->ctdesc := term->name
        if ! file(alltrim("c"+memvar->cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := alltrim("c"+memvar->cterm+"enrp")
        cyytskdp        := alltrim("c"+memvar->cterm+"skdp")
        cyytflag        := alltrim("c"+memvar->cterm+"flag")
        cyytmdst        := alltrim("c"+memvar->cterm+"mdst")
        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                    {,,"c999crsp",,_DBF_SHARED,,1},;
                                    {,,"c999colp",,_DBF_SHARED,,1},;
                                    {,,"c999prsp",,_DBF_SHARED,,1},;
                                    {,,"t999lst" ,,_DBF_SHARED,,1},;
                                    {,,"blocklst",,_DBF_SHARED,,1},;
                                    {,,"c999sm2p",,_DBF_SHARED,,1},;
                                    {,, cyytflag ,"cyytflag",_DBF_SHARED,,1},;
                                    {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                    {,, cyytmdst ,"cyytmdst",_DBF_SHARED,,1},;
                                    {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        memvar->cidno := space(len(c999sm1p->sm1idno))


        do while .t.
                memvar->clname          := space(len(c999sm1p->sm1lstnam))
                memvar->cfname          := space(len(c999sm1p->sm1fstnam))
                memvar->cmname          := space(len(c999sm1p->sm1midname))
                memvar->ccourse         := space(len(c999sm1p->sm1colcod))
                memvar->nyrlevel        := 0
                memvar->aitems          := {_EMPTY_ELEM}
                memvar->nindex          := 1
                memvar->ntotunits       := 0
                restscr(aentryscr)
                commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno       pict "@!";
                        valid ! empty(memvar->cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif

                if cyytmdst->(dbseek(memvar->cidno))
                        if alltrim(cyytmdst->medremarks) == ""
                             fask(10,"NO MEDICAL REMARKS FROM CLINIC",{" Ok "},memvar->colorarray[05],.t.,nil)
                             loop
                        elseif alltrim(cyytmdst->medremarks) == "FAILED"
                             fask(10,"MEDICAL STATUS: "  +alltrim(cyytmdst->medremarks)+ "  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                             loop
                        endif
                else
                    fask(10,"NO MEDICAL RECORD FROM CLINIC",{" Ok "},memvar->colorarray[05],.t.,nil)
                    loop
                endif

                if blocklst->(dbseek(memvar->cidno)) .and. (alltrim(blocklst->blkreason) == "NO MEDICAL")
                        fask(10,"STUDENT CANNOT CLAIM THE STUDYLOAD; block listed...   "  +alltrim(blocklst->blkreason)+  "  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif blocklst->(dbseek(memvar->cidno)) .and. (alltrim(blocklst->blkreason) == "SEE THE REGISTRAR")
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+;
                                alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                elseif blocklst->(dbseek(memvar->cidno)) .and. (alltrim(blocklst->blkreason) == "NO CREDENTIALS")
                        fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+;
                                alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". is block listed...  ;  "+alltrim(blocklst->blkreason)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                endif
               
                if ! c999sm1p->(dbseek(memvar->cidno)) .and.;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytenrp->(dbseek(memvar->cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                elseif !c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytenrp->(dbseek(memvar->cidno))
                                fask(10,"   Student not yet enrolled.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midname
                memvar->ccourse         := cyytenrp->enrcolcod
                memvar->nyrlevel        := val(cyytenrp->enryrlevl)
                *memvar->ccourse         := c999sm1p->sm1colcod
                *memvar->nyrlevel        := c999sm1p->sm1yrlevl
                memvar->mctrlno         := cyytmdst->medctrlno
                c999colp->(dbseek(memvar->ccourse))
                memvar->cdesc           := c999colp->coldesabr
                processtrans()
                @ 03,47 say "               "+memvar->mctrlno
                @ 03,47 say "Med. Ctrl No.: "color memvar->colorarray[02]
                @ 04,02 say "              "+memvar->clname
                @ 04,02 say "Last Name   : " color memvar->colorarray[02]
                @ 05,02 say "              "+memvar->cfname
                @ 05,02 say "First Name  : " color memvar->colorarray[02]
                @ 06,02 say "              "+memvar->cmname
                @ 06,02 say "Middle Name : " color memvar->colorarray[02]
                @ 04,47 say "               "+memvar->ccourse+" - "+memvar->cdesc
                @ 04,47 say "Course/Major : " color memvar->colorarray[02]
                @ 05,47 say "               "+transform(memvar->nyrlevel,"9")+;
                        if(memvar->nyrlevel == 1," - First Year",;
                        if(memvar->nyrlevel == 2," - Second Year",;
                        if(memvar->nyrlevel == 3," - Third Year",;
                        if(memvar->nyrlevel == 4," - Fourth Year"," - Fifth Year"))))
                @ 05,47 say "Year Level   : " color memvar->colorarray[02]
                @ 06,47 say "               "+displaydate(cyytenrp->enrdte)
                @ 06,47 say "Date Enrolled: " color memvar->colorarray[02]
                @ 22,02 say "      "+displaydate(date())
                @ 22,02 say "Date: " color memvar->colorarray[02]
                @ 22,57 say "              "+transform(memvar->ntotunits,"999.9")
                @ 22,57 say "Total Units =>" color memvar->colorarray[02]
                @ 22,23 say "        "+if(cyytenrp->enrconfirm=="*","Confirmed        ","Not Yet Confirmed")
                @ 22,23 say "Status: " color memvar->colorarray[02]

                dispbox(07,02,21,77,_SINGLE_LINE)
                connectline(09,02,77)
/*                commandline("³             F10 - Print              ³           ESC - Previous              ³")*/
                commandline("³  F4 - View Instructor  ³        F10 - Print        ³     ESC - Previous      ³")
                stabilize(ostudy,.t.)
                browsearray(ostudy,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fstudy(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 08,03 say "  Sched No.        Subject           Time          Days     Room    Units " color memvar->colorarray[35]
                return 1
        case lastkey() == K_F4
                cyytskdp->(dbseek(right(memvar->aitems[nindex,_SKDNO],5)))
                if ! empty(cyytskdp->skdinscod)
                     t999lst->(dbseek(cyytskdp->skdinscod))
                     fask(13,"  "+alltrim(cyytskdp->skdsubcod)+" ==> "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06])
                else
                     fask(13,alltrim(cyytskdp->skdsubcod)+";  Not assigned to Instructor  ",{" Ok "},memvar->colorarray[05])
                endif
        case lastkey() == K_F10
           //   fask(10,"THE ADMIN/REGISTRAR DISABLED THIS FUNCTION!!!",{" Ok "},memvar->colorarray[05],.t.,nil)


                if ! cyytflag->(dbseek(memvar->cidno))
                        cyytflag->(recycle())
                        cyytflag->enridno := memvar->cidno
                        cyytflag->enrflag := "P"
                elseif cyytflag->(dbseek(memvar->cidno))
                        if ! fask(13,"  Study load already released.  Re-print ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                               return(1)
                        endif
                        cyytflag->(reclock())
                        cyytflag->enrflag := "R"
                        cyytflag->(dbcommit())
                        cyytflag->(dbunlock())
                endif
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||printstudyload()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif

        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function processtrans()
local nlastelem,nctr,cskdcode,nctr1,lfound:=.f.
for nctr := 1 to 25
        lfound := .f.
        cskdcode := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&cskdcode == "00000"
                if cyytskdp->(dbseek(cyytenrp->&cskdcode))
                        aadd(memvar->aitems,_EMPTY_ELEM)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_SKDNO]        := cyytskdp->skdcolcod+"-"+cyytenrp->&cskdcode
                        memvar->aitems[nlastelem,_SUBJECT]      := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        memvar->aitems[nlastelem,_TIME]         := cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn
                        memvar->aitems[nlastelem,_DAYS]         := cyytskdp->skdday
                        memvar->aitems[nlastelem,_ROOM]         := cyytskdp->skdrom
                        memvar->aitems[nlastelem,_UNITS]        := if((cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC").or.(cyytskdp->skdsplcod=="S".and.cyytskdp->skdsubtyp=="LAB"),"   - ",str(cyytskdp->skdunt,5,1))
                        memvar->aitems[nlastelem,_TIMEX]        := str(cyytskdp->skdbegtimx,4)
                        if cyytskdp->skdsplcod == "S" .and. cyytskdp->skdsubtyp == "LAB"
                                memvar->ntotunits += 0
                        else
                                if ! cyytskdp->skdsplcod == "C"
                                         memvar->ntotunits += cyytskdp->skdunt
                                elseif cyytskdp->skdsplcod == "C" .and. !cyytskdp->skdsubtyp == "LEC"
                                         memvar->ntotunits += cyytskdp->skdunt
                                endif
                        endif
               endif
        else
                exit
        endif
next
asort(memvar->aitems,,,{|a,b|a[_DAYS]+a[_TIMEX]<b[_DAYS]+b[_TIMEX]})
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_SKDNO])
                        adel(memvar->aitems,memvar->nindex)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)

static function printstudyload()
local nctr := 0
header()
for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing subject "+alltrim(memvar->aitems[nctr,_SUBJECT])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,;
                memvar->aitems[nctr,_SKDNO]+space(03)+;
                memvar->aitems[nctr,_SUBJECT]+space(06)+;
                memvar->aitems[nctr,_TIME]+space(04)+;
                memvar->aitems[nctr,_DAYS]+space(04)+;
                memvar->aitems[nctr,_ROOM]+space(01)+;
                memvar->aitems[nctr,_UNITS])
next
outexpr(prow()+01,00,replicate("-",70))
outexpr(prow()+01,00,displaydate(date())+space(40)+"TOTAL UNITS:  "+transform(ntotunits,"9999.9"))
outexpr(prow()+01,00,"UC-METC/REG.Doc/006/Rev.01")
//outexpr(19,00,"UC-METC/REG.Doc/006/Rev.01")
@ 22,00 say space(01)  /* to eject */
//setprc(00,00)
setprc(00,-1)
return(nil)

static function header()
*setprc(00,00)

outexpr(00,00,alltrim(memvar->ccompanyname)+space(03)+alltrim(memvar->ctdesc)+space(04)+"STUDY LOAD")
outexpr(01,00,replicate("-",70))
//outexpr(02,00,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->len(cfname)+space(01)+memvar->len(cmname)+space(04)+memvar->ccourse+"-"+memvar->len(cdesc)+space(03)+transform(memvar->nyrlevel,"9"))
//outexpr(02,00,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->cfname+space(01)+memvar->cmname+space(04)+space(03)+memvar->cdesc+space(04)+transform(memvar->nyrlevel,"9"))
outexpr(02,00,memvar->cidno+space(02)+alltrim(memvar->clname)+","+space(01)+alltrim(memvar->cfname)+space(02)+alltrim(memvar->cmname))
outexpr(02,60,memvar->cdesc+space(02)+transform(memvar->nyrlevel,"9"))
outexpr(03,00,replicate("-",70))
outexpr(04,00,"SCHED NO   COURSE NO                  TIME         DAYS    ROOM  UNITS")
return(nil)

*-------------------------------------------------------------------------------

function withdrawn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp,bprint, cprocsts, cterm,;
      ctdesc,cyear,ddate
private cdummy := "wdraw"+strzero(memvar->naccess,2), withdraw

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Student's Withdrawn Printing  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ctdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,3}})) == nil
                return(nil)
        endif
        cyear := space(01)
        do while .t.
                ddate := ctod("")
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                 [1 2 3 4 5  8-All]" color memvar->colorarray[02]

                @ 03,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyear       pict "@!";
                        vali cyear $ _FIRST_YEAR+;
                                     _SECOND_YEAR+;
                                     _THIRD_YEAR+;
                                     _FOURTH_YEAR+;
                                     _FIFTH_YEAR+;
                                     _ALL_YEAR
                @ 04,02 say "As of        :";
                        color memvar->colorarray[02];
                        get ddate
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pwithdrawn(cyear,ctdesc,ddate)}) == 1
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

static function pwithdrawn(cyear,ctdesc,ddate)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"LOAD"        ,"N",05,1},;
                                 {"YRLEVEL"     ,"C",01,0},;
                                 {"COURSE"      ,"C",06,0},;
                                 {"DATEENR"     ,"D",08,0}},{||cdxwithdrawn()})
        dbcloseall()
        return(nil)
endif
memvar->withdrawn := memvar->cdummy
if(afile := openwcheck({{,,(memvar->withdrawn+".TXT"),"withdrawn",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
withdrawn->(__dbzap());withdrawn->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("LIST OF STUDENT'S WITHDRAWN",nmaxcol))+;
                              "LIST OF STUDENT'S WITHDRAWN"})
aadd(abtext,{||space(titlepos(alltrim(ctdesc),nmaxcol))+alltrim(ctdesc)})
*aadd(abtext,{||space(titlepos(alltrim("AS OF :"+dtoc(ddate))))})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.      Last Name            First Name         M  Load   Yr  Course"})
aadd(abtext,{||"     --------  ---------------  ------------------------  -  -----  --  ------"})

/*
      ID No.      Last Name            First Name         M  Load   Yr  Course
     --------  ---------------  ------------------------  -  -----  --  ------
123. 12345678  123456789012345  123456789012345678901234  1  123.1   1  123456
*/

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
if ! cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10," Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if empty(ddate)
           if cyytenrp->enrenrst $ _WITHDRAW_BEFORE+;
                                _WITHDRAW_AFTER
                withdrawn->(dbappend())
                withdrawn->idno         := c999sm1p->sm1idno
                withdrawn->lname        := c999sm1p->sm1lstnam
                withdrawn->fname        := c999sm1p->sm1fstnam
                withdrawn->mname        := c999sm1p->sm1midnam
                withdrawn->load         := cyytenrp->enrunt
                withdrawn->yrlevel      := cyytenrp->enryrlevl
                c999colp->(dbseek(cyytenrp->enrcolcod))
                withdrawn->course       := c999colp->coldesabr
                withdrawn->(dbcommit())
                withdrawn->(dbunlock())
           endif
        elseif cyytenrp->enrdte <= ddate
           if cyytenrp->enrenrst $ _WITHDRAW_BEFORE+;
                                _WITHDRAW_AFTER
                withdrawn->(dbappend())
                withdrawn->idno         := c999sm1p->sm1idno
                withdrawn->lname        := c999sm1p->sm1lstnam
                withdrawn->fname        := c999sm1p->sm1fstnam
                withdrawn->mname        := c999sm1p->sm1midnam
                withdrawn->load         := cyytenrp->enrunt
                withdrawn->yrlevel      := cyytenrp->enryrlevl
                c999colp->(dbseek(cyytenrp->enrcolcod))
                withdrawn->course       := c999colp->coldesabr
                withdrawn->(dbcommit())
                withdrawn->(dbunlock())
           endif
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(dbclearrelation())
cyytenrp->(clearscope())

*-----------------
*/  printing    /*
*-----------------
nctr := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
withdrawn->(dbgotop())
do while ! withdrawn->(eof())
        fask(10,"  Printing name "+alltrim(withdrawn->lname)+", "+alltrim(withdrawn->fname)+" "+withdrawn->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                  abtext, prow() + 1, _MAX_LINE, {||__eject()})
        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                             withdrawn->idno+space(02)+;
                             withdrawn->lname+space(02)+;
                             withdrawn->fname+space(02)+;
                             withdrawn->mname+space(02)+;
                             transform(withdrawn->load,"999.9")+space(03)+;
                             withdrawn->yrlevel+space(02)+;
                             withdrawn->course)
        if nextkey() == K_ESC
                exit
        endif
        withdrawn->(dbskip())
enddo
if npage > 0
        outexpr(prow()+01,00,chr(18))
        __eject()
endif
closewcheck(afile)
return(nil)

static function cdxwithdrawn()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

function statistics(cstatus)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp,bprint, cprocsts, cterm, cdesc, aentryscr
private cdummy := "stat"+strzero(memvar->naccess,2), header, detail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        restscr(aentryscr)
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment Statistics Report  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        cyytenrp  := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||pstatistic(cdesc,cstatus)}) == 1
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
restscr(alastscr)
return(nil)

function isleap(param)
local nyy:= if(valtype(param) == "D", year(param),param)
local dtest := ctod("02/28/"+str(nyy,4))
return (month(dtest+1)==2)


static function pstatistic(cdesc,cstatus)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := npld := nfld := 0,;
      afile, lpageject, nline := 0,;
      n1st,n2nd,n3rd,n4th,nwbef,nwdur,nall

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
   ! createdummy(memvar->cdummy+"H",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0}},{||cdxhstat()})
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
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
if (cstatus == "A")
        aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"})
else
        aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"+space(16)+"Confirmed"})
endif
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("ENROLLMENT STATISTICS REPORT",nmaxcol))+;
                              "ENROLLMENT STATISTICS REPORT"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"--------------------------------------------------------------------------------"})
aadd(abtext,{||"   COURSE/YEAR      MALE(S)  FEMALE(S)  WITHDRAWN STUDENTS INCL. D  TOTAL UNITS"})
aadd(abtext,{||"================== ========= =========  ==B===D== ==Level===All===  ==========="})
aadd(abtext,{||""})

/*
--------------------------------------------------------------------------------
   COURSE/YEAR      MALE(S)  FEMALE(S)  WITHDRAWN STUDENTS INCL. D  TOTAL UNITS
================== ========= =========  ==B===D== ==Level===All===  ===========
12-123456-123456-1 1,123,123 1,123,123  123  123  123,123  123,123  12345,123.1
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
<< S U M M A R Y >>

A.  Total First Year                    => 123,123
B.  Total Second Year                   => 123,123
C.  Total Third Year                    => 123,123
D.  Total Fourth Year                   => 123,123

E.  Total Students                                      => 123,123


Less Total Students Withdrawn

F.  Withdrawn Before Classes            => 123,123
G.  Withdrawn During Classes            => 123,123
H.  Total Students Withdrawn                            => 123,123

I.  Total Students Enrolled                             => 123,123
*/

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing id number "+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (cstatus == "A") .or. (cyytenrp->enrconfirm == "*")
                if detail->(dbseek(cyytenrp->enrcolcod+cyytenrp->enryrlevl))
                        detail->(reclock())
                        if c999sm1p->sm1sex == "M" &&male
                                detail->male += 1
                        elseif c999sm1p->sm1sex == "F" &&Female
                                detail->female += 1
                        endif
                        if cyytenrp->enrenrst == _WITHDRAW_BEFORE
                                detail->wbefore += 1
                        elseif cyytenrp->enrenrst == _WITHDRAW_AFTER
                                detail->wduring += 1
                        endif
                        detail->units += cyytenrp->enrunt
                else
                        detail->(dbappend())
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        detail->colcode := cyytenrp->enrcolcod
                        detail->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MR","-NSA",;
                                                                        if(cyytenrp->enrcolcod == "MI","-NSA",space(06)))))
                        detail->year    := cyytenrp->enryrlevl
                        if c999sm1p->sm1sex == "M"
                                detail->male   := 1
                                detail->female := 0
                        else
                                detail->female := 1
                                detail->male   := 0
                        endif
                        if cyytenrp->enrenrst == _WITHDRAW_BEFORE
                                detail->wbefore := 1
                                detail->wduring := 0
                        elseif cyytenrp->enrenrst == _WITHDRAW_AFTER
                                detail->wduring := 1
                                detail->wbefore := 0
                        endif
                        detail->units := cyytenrp->enrunt

                        if ! header->(dbseek(detail->coldesc))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MR","-NSA",;
                                                                                if(cyytenrp->enrcolcod == "MI","-NSA",space(06)))))
                                header->(dbcommit())
                                header->(dbunlock())
                        endif
                endif
                if (cyytenrp->enrenrst != _WITHDRAW_BEFORE) .and. ;
                   (cyytenrp->enrenrst != _WITHDRAW_AFTER)
                        if cyytenrp->enrunt < 18
                                npld += 1
                        else
                                nfld += 1
                        endif
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

*-----------------
*/  printing    /*
*-----------------
detail->(sx_settagorder(2))
n1st := n2nd := n3rd := n4th := nwbef := nwdur := nall := 0
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
header->(dbgotop())
do while ! header->(eof())
        fask(10,"  Printing course "+alltrim(header->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        detail->(sx_setscope(_TOP_SCOPE   ,header->coldesc))
        detail->(sx_setscope(_BOTTOM_SCOPE,header->coldesc))
        detail->(dbgotop())
        do while ! detail->(eof())
                fask(10,"  Printing course "+alltrim(detail->coldesc)+" year "+detail->year+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                          abtext, prow() + 1, _MAX_LINE, {||__eject()})

                outexpr(prow()+01,00,detail->colcode+"-"+;
                                     detail->coldesc+" "+;
                                     detail->year+space(01)+;
                                     transform(detail->male,"9,999,999")+space(03)+;
                                     transform(detail->female,"999,999")+space(02)+;
                                     transform(detail->wbefore,"999")+space(01)+;
                                     transform(detail->wduring,"999")+space(03)+;
                                     transform(detail->male+detail->female,"999,999")+space(11)+;
                                     transform(detail->units,"99999,999.9"))
                nall  += detail->male+detail->female
                nwbef += detail->wbefore
                nwdur += detail->wduring
                if detail->year == _FIRST_YEAR
                        n1st += (detail->male+detail->female)
                elseif detail->year == _SECOND_YEAR
                        n2nd += (detail->male+detail->female)
                elseif detail->year == _THIRD_YEAR
                        n3rd += (detail->male+detail->female)
                elseif detail->year == _FOURTH_YEAR
                        n4th += (detail->male+detail->female)
                endif
                detail->(dbskip())
        enddo
        detail->(clearscope())
        outexpr(prow()+00,59,transform(nall,"999,999"))
        nall := 0
        header->(dbskip())
enddo
outexpr(prow()+01,00,replicate("Ä",80))
outexpr(prow()+01,00,"<< S U M M A R Y >>")
outexpr(prow()+02,00,"A.  Total First Year                    => "+transform(n1st,"999,999"))
outexpr(prow()+01,00,"B.  Total Second Year                   => "+transform(n2nd,"999,999"))
outexpr(prow()+01,00,"C.  Total Third Year                    => "+transform(n3rd,"999,999"))
outexpr(prow()+01,00,"D.  Total Fourth Year                   => "+transform(n4th,"999,999"))
outexpr(prow()+02,00,"E.  Total Students                                      => "+transform(n1st+n2nd+n3rd+n4th,"999,999"))
outexpr(prow()+03,00,"Less Total Students Withdrawn")
outexpr(prow()+02,00,"F.  Withdrawn Before Classes            => "+transform(nwbef,"999,999"))
outexpr(prow()+01,00,"G.  Withdrawn During Classes            => "+transform(nwdur,"999,999"))
outexpr(prow()+01,00,"H.  Total Students Withdrawn                            => "+transform(nwbef+nwdur,"999,999"))
outexpr(prow()+02,00,"I.  Total Students Enrolled                             => "+transform((n1st+n2nd+n3rd+n4th)-(nwbef+nwdur),"999,999"))
outexpr(prow()+02,00,"J.  Total Students below 18 units       => "+transform(npld,"999,999"))
outexpr(prow()+01,00,"K.  Total Students 18 units & above     => "+transform(nfld,"999,999"))

outexpr(prow()+01,00,chr(18))
__eject()
closewcheck(afile)
return(nil)
*-------------------------------------------------------------------------------

function stats_compared(cstatus)
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, pyytenrp, bprint, cprocsts, cterm, pterm, cdesc, pdesc, aentryscr,;
      dater, c_date, temp_term := space(5), test_term := space(5), nmainmt, nmainmm

private cdummy := "stat"+strzero(memvar->naccess,2), header, detail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
pterm := space(len(term->code))
nmainmt := 0
nmainmm := 0
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        restscr(aentryscr)
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment Statistics w/ Comparison Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
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
        @ 03,02 say "Previous Term  :";
                color memvar->colorarray[02];
                get pterm pict "@!";
                valid ! empty(cterm)
        @ 05,02 say "Current Date   :";
                color memvar->colorarray[02];
                get c_date ;
                valid ! empty(c_date)
        if isleap(c_date)
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)+1))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        else
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)+2))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        endif
        @ 06,02 say "Previous Date  :";
                color memvar->colorarray[02];
                get dater ;
                valid ! empty(dater)

        read

/*
       @ 08,02 say "UC-Main BSMT   :";
                color memvar->colorarray[02];
                get nmainmt pict "999"

        @ 09,02 say "UC-Main BSMarE :";
                color memvar->colorarray[02];
                get nmainmm pict "999"
        read
*/

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
        @ 03,23 say "- "+term->name
        @ 05,30 say "- "+cmonth(c_date) +" "+transform(day(c_date),"99") + ", " + ;
                           transform(year(c_date),"9999") +"  "+ cdow(c_date)
        @ 06,30 say "- "+cmonth(dater) +" "+transform(day(dater),"99") + ", " + ;
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
        if whereprint({||pstats_compared(cdesc,cstatus,cterm,pterm,c_date,dater,nmainmt,nmainmm)}) == 1
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

static function pstats_compared(cdesc,cstatus,cterm,pterm,c_date,dater,nmainmt,nmainmm)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,;
      n1st,n2nd,n3rd,n4th,nwbef,nwdur,nall,record_no,nTotal,nTotLstYr,nDiff,nPercent,nPer,;
      nlst_yr,counter,out_text := space(255),out_text2 := space(255),diff,;
      nwd1,nwd2,nTotWd,nEnrToday,nNew,nOld,nCT,nSR,nWdrToday
//added withdrawn today 4/14/2015
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0},;
                                     {"NEW"         ,"N",04,0},;
                                     {"OLD"         ,"N",04,0},;
                                     {"CT"          ,"N",04,0},;
                                     {"SR"          ,"N",04,0},;
                                     {"TERM"        ,"C",01,0},;
                                     {"UNITS"       ,"N",10,1}},{||cdxdstat()}) .or. ;
   ! createdummy(memvar->cdummy+"P",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"YEAR"        ,"C",01,0},;
                                     {"NEW"         ,"N",04,0},;
                                     {"OLD"         ,"N",04,0},;
                                     {"CT"          ,"N",04,0},;
                                     {"SR"          ,"N",04,0},;
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
aadd(abtext,{||space(titlepos("ENROLLMENT STATISTICS",nmaxcol))+;
                              "ENROLLMENT STATISTICS"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("Present:"+dtoc(c_date)+" - "+"Previous:"+dtoc(dater),nmaxcol))+"Present:"+dtoc(c_date)+"-"+"Previous:"+dtoc(dater)})
aadd(abtext,{||""})
aadd(abtext,{||"--------------------------------------------------------------------------------"})
aadd(abtext,{||"COLLEGE COURSE    1ST    2ND    3RD    4TH    TOTAL   LST YR    DIFF  %(INC/DEC)"})
aadd(abtext,{||"==============  =====  =====  =====  =====  =======  =======  ======  =========="})
aadd(abtext,{||""})

nEnrToday := 0
nwd1      := 0
nwd2      := 0
ntotwd    := 0
nWdrToday := 0
cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10," Processing Term : "+cterm + "; ID number :"+alltrim(c999sm1p->sm1idno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
if !(cyytenrp->enrenrst == "C") .and. (cyytenrp->enrconfirm == "*")
        if cyytenrp->enrenrst == _WITHDRAW_BEFORE
                nwd1 += 1
                if(cyytenrp->enrupdte == c_date)
                      nWdrToday += 1
                endif
        elseif cyytenrp->enrenrst == _WITHDRAW_AFTER
                nwd2 += 1
                if(cyytenrp->enrupdte == c_date)
                      nWdrToday += 1
                endif

        endif
end if

        if (cyytenrp->enrdte <= c_date) .and.(cyytenrp->enrenrst == "C") .and.((cstatus == "A") .or. (cyytenrp->enrconfirm == "*"))
//        if (cyytenrp->enrdte <= c_date) .and. ((cstatus == "A"))
           if cyytenrp->enrdte==c_date
                nEnrToday += 1
           endif
           if cyytenrp->enrenrst == _WITHDRAW_BEFORE
                nwd1 += 1
           elseif cyytenrp->enrenrst == _WITHDRAW_AFTER
                nwd2 += 1
           endif

                if detail->(dbseek(cyytenrp->enrcolcod+cyytenrp->enryrlevl))
                        detail->(reclock())
                        do case
                        case cyytenrp->enrcls == "H" &&New Students - High School
                             detail->new += 1
                        case cyytenrp->enrcls == "O" &&Old Students
                             detail->old += 1
                        case cyytenrp->enrcls == "C"
                             detail->ct  += 1
                        case cyytenrp->enrcls == "T"
                             detail->ct  += 1
                        case cyytenrp->enrcls == "S"
                             detail->sr  += 1
                        case cyytenrp->enrcls == "R"
                             detail->sr  += 1
                        endcase
                        detail->units += cyytenrp->enrunt
                else
                        detail->(dbappend())
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        detail->colcode := cyytenrp->enrcolcod
                        detail->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                        if(cyytenrp->enrcolcod == "MR","-NSA",;
                                                                        if(cyytenrp->enrcolcod == "MI","-NSA",space(06)))))
                        detail->year    := cyytenrp->enryrlevl
                        do case
                        case cyytenrp->enrcls == "H"
                             detail->new    := 1
                             detail->old    := 0
                        case cyytenrp->enrcls == "O"
                             detail->new    := 0
                             detail->old    := 1
                        case cyytenrp->enrcls == "C"
                             detail->ct     := 1
                             detail->sr     := 0
                        case cyytenrp->enrcls == "T"
                             detail->ct     := 1
                             detail->sr     := 0
                        case cyytenrp->enrcls == "S"
                             detail->ct     := 0
                             detail->sr     := 1
                        case cyytenrp->enrcls == "R"
                             detail->ct     := 0
                             detail->sr     := 1
                        endcase
                        detail->units := cyytenrp->enrunt

                        if ! header->(dbseek(detail->coldesc + detail->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(cyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                                if(cyytenrp->enrcolcod == "MR","-NSA",;
                                                                                if(cyytenrp->enrcolcod == "MI","-NSA",space(06)))))
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
                        case pyytenrp->enrcls == "H"
                             previous->new  += 1
                        case pyytenrp->enrcls == "O"
                             previous->old  += 1
                        case pyytenrp->enrcls == "C"
                             previous->ct   += 1
                        case pyytenrp->enrcls == "T"
                             previous->ct   += 1
                        case pyytenrp->enrcls == "S"
                             previous->sr   += 1
                        case pyytenrp->enrcls == "R"
                             previous->sr   += 1
                        endcase
                        previous->units += pyytenrp->enrunt
                else
                        previous->(dbappend())
                        c999colp->(dbseek(pyytenrp->enrcolcod))
                        previous->colcode := pyytenrp->enrcolcod
                        previous->coldesc := alltrim(c999colp->coldesabr)+if(pyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                        if(pyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                        if(pyytenrp->enrcolcod == "MR","-NSA",;
                                                                        if(pyytenrp->enrcolcod == "MI","-NSA",space(06)))))
                        previous->year    := pyytenrp->enryrlevl
                        do case
                        case pyytenrp->enrcls == "H"
                             previous->new    := 1
                             previous->old    := 0
                        case pyytenrp->enrcls == "O"
                             previous->new    := 0
                             previous->old    := 1
                        case pyytenrp->enrcls == "C"
                             previous->ct     := 1
                             previous->sr     := 0
                        case pyytenrp->enrcls == "T"
                             previous->ct     := 1
                             previous->sr     := 0
                        case pyytenrp->enrcls == "S"
                             previous->ct     := 0
                             previous->sr     := 1
                        case pyytenrp->enrcls == "R"
                             previous->ct     := 0
                             previous->sr     := 1
                        endcase
                        previous->units := pyytenrp->enrunt

                        if ! header->(dbseek(previous->coldesc+previous->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(pyytenrp->enrcolcod == "PA","-ALPHA",;
                                                                                if(pyytenrp->enrcolcod == "MP","-ALPHA",;
                                                                                if(pyytenrp->enrcolcod == "MR","-NSA",;
                                                                                if(pyytenrp->enrcolcod == "MI","-NSA",space(06)))))
                                header->colcode := previous->colcode
                                header->year    := previous->year
                                header->(dbcommit())
                                header->(dbunlock())

                                detail->(dbappend())
                                detail->colcode := previous->colcode
                                detail->coldesc := previous->coldesc
                                detail->year    := previous->year
                                detail->new     := 0
                                detail->old     := 0
                                detail->ct      := 0
                                detail->sr      := 0
                                detail->units   := 0
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
nNew := nOld := nCT  := nSR  := nall := nwithD := ;
nMVBSMT := nMMBSMARE := nMIBSMTNSA := nMRBSMARENSA := nCS := ;
nYNBSMT := nYMBSMARE := nSNBSMT := nSMBSMARE :=;
nHNBSMT := nHMBSMARE := nNVBSMT := nNMBSMARE := nNNBSNAME := nNWBSMT := nMWBSMARE := nBNBSMT := nBMBSMARE :=;
nlMVBSMT := nlMMBSMARE := nlMIBSMTNSA := nlMRBSMARENSA := nlCS := ;
nlYNBSMT := nlYMBSMARE := nlSNBSMT := nlSMBSMARE := ;
nlHNBSMT := nlHMBSMARE := nlNVBSMT := nlNMBSMARE := nlNNBSNAME := nlNWBSMT := nlMWBSMARE := nlBNBSMT := nlBMBSMARE :=;
ndiffsj := ntpersj := ;
ntMVBSMT := ntMMBSMARE := ntMIBSMTNSA := ntMRBSMARENSA := ntCS := ;
ntYNBSMT := ntYMBSMARE := ntSNBSMT := ntSMBSMARE :=;
ntHNBSMT := ntHMBSMARE := ntNVBSMT := ntNMBSMARE := ntNNBSNAME := ntNWBSMT := ntMWBSMARE := ntBNBSMT := ntBMBSMARE :=;
ntlMVBSMT := ntlMMBSMARE := ntlMIBSMTNSA := ntlMRBSMARENSA := ntlCS := ;
ntlYNBSMT := ntlYMBSMARE := ntlSNBSMT := ntlSMBSMARE := ;
ntlHNBSMT := ntlHMBSMARE := ntlNVBSMT := ntlNMBSMARE := ntlNNBSNAME := ntlNWBSMT := ntlMWBSMARE := ntlBNBSMT := ntlBMBSMARE :=;
ntdiffsj := ntpersj := 0

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
        out_text3 := ""
        nlst_yr := diff := nall := 0
        nNlst_yr := nNdiff := nNall := 0
        for counter := 1 to 4
           if previous->(dbseek(header->colcode+transform(counter,"9")))
                nlst_yr += (previous->new) + (previous->old) + ;
                           (previous->ct) + (previous->sr)
           endif

           if header->colcode == "MV"
                nlMVBSMT += previous->new
                ntlMVBSMT += previous->ct
           elseif header->colcode == "MM"
                nlMMBSMARE += previous->new
                ntlMMBSMARE += previous->ct
           elseif header->colcode == "MI"
                nlMIBSMTNSA += previous->new
                ntlMIBSMTNSA += previous->ct
           elseif header->colcode == "MR"
                nlMRBSMARENSA += previous->new
                ntlMRBSMARENSA += previous->ct
           elseif header->colcode == "SN"
                nlSNBSMT += previous->new
                ntlSNBSMT += previous->ct
           elseif header->colcode == "SM"
                nlSMBSMARE += previous->new
                ntlSMBSMARE += previous->ct
           elseif header->colcode == "YN"
                nlYNBSMT += previous->new
                ntlYNBSMT += previous->ct
           elseif header->colcode == "YM"
                nlYMBSMARE += previous->new
                ntlYMBSMARE += previous->ct
           elseif header->colcode == "HN"
                nlHNBSMT += previous->new
                ntlHNBSMT += previous->ct
           elseif header->colcode == "HM"
                nlHMBSMARE += previous->new
                ntlHMBSMARE += previous->ct
           elseif header->colcode == "NV"
                nlNVBSMT += previous->new
                ntlNVBSMT += previous->ct
           elseif header->colcode == "NM"
                nlNMBSMARE += previous->new
                ntlNMBSMARE += previous->ct
           elseif header->colcode == "NN"
                nlNNBSNAME += previous->new
                ntlNNBSNAME += previous->ct
           elseif header->colcode == "NW"
                nlNWBSMT += previous->new
                ntlNWBSMT += previous->ct
           elseif header->colcode == "MW"
                nlMWBSMARE += previous->new
                ntlMWBSMARE += previous->ct
           elseif header->colcode == "BN"
                nlBNBSMT += previous->new
                ntlBNBSMT += previous->ct
           elseif header->colcode == "BM"
                nlBMBSMARE += previous->new
                ntlBMBSMARE += previous->ct
           elseif header->colcode == "CS"
                nlCS += previous->new
                ntlCS += previous->ct
           endif

           if detail->(dbseek(header->colcode+transform(counter,"9")))
                fask(10,"  Printing course "+alltrim(detail->coldesc)+" year "+detail->year+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                out_text2 := out_text2 + transform((detail->new)+(detail->old) + ;
                             (detail->ct) + (detail->sr),"9,999")+space(02)

                        nall  += (detail->new + detail->old + detail->ct + detail->sr)
                        nNew  += detail->new
                        nOld  += detail->old
                        nCT   += detail->ct
                        nSR   += detail->sr

           if header->colcode == "MV"
                nMVBSMT += detail->new
                ntMVBSMT += detail->ct
           elseif header->colcode == "MM"
                nMMBSMARE += detail->new
                ntMMBSMARE += detail->ct
           elseif header->colcode == "MI"
                nMIBSMTNSA += detail->new
                ntMIBSMTNSA += detail->ct
           elseif header->colcode == "MR"
                nMRBSMARENSA += detail->new
                ntMRBSMARENSA += detail->ct
           elseif header->colcode == "SN"
                nSNBSMT += detail->new
                ntSNBSMT += detail->ct
           elseif header->colcode == "SM"
                nSMBSMARE += detail->new
                ntSMBSMARE += detail->ct
           elseif header->colcode == "YN"
                nYNBSMT += detail->new
                ntYNBSMT += detail->ct
           elseif header->colcode == "YM"
                nYMBSMARE += detail->new
                ntYMBSMARE += detail->ct
           elseif header->colcode == "CS"
                nCS += detail->new
                ntCS += detail->ct
           elseif header->colcode == "HN"
                nHNBSMT += detail->new
                ntHNBSMT += detail->ct
           elseif header->colcode == "HM"
                nHMBSMARE += detail->new
                ntHMBSMARE += detail->ct
           elseif header->colcode == "NV"
                nNVBSMT += detail->new
                ntNVBSMT += detail->ct
           elseif header->colcode == "NM"
                nNMBSMARE += detail->new
                ntNMBSMARE += detail->ct
           elseif header->colcode == "NN"
                nNNBSNAME += detail->new
                ntNNBSNAME += detail->ct
           elseif header->colcode == "MW"
                nMWBSMARE += detail->new
                ntMWBSMARE += detail->ct
           elseif header->colcode == "NW"
                nNWBSMT += detail->new
                ntNWBSMT += detail->ct
           elseif header->colcode == "BN"
                nBNBSMT += detail->new
                ntBNBSMT += detail->ct
           elseif header->colcode == "BM"
                nBMBSMARE += detail->new
                ntBMBSMARE += detail->ct
           endif

                if detail->colcode == "MV"
                        do case
                        case detail->year == _FIRST_YEAR
                             n1st += (detail->new + detail->old + detail->ct + detail->sr + nmainmt)
                        case detail->year == _SECOND_YEAR
                             n2nd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _THIRD_YEAR
                             n3rd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _FOURTH_YEAR
                             n4th += (detail->new + detail->old + detail->ct + detail->sr)
                        endcase
                elseif detail->colcode == "MM"
                        do case
                        case detail->year == _FIRST_YEAR
                             n1st += (detail->new + detail->old + detail->ct + detail->sr + nmainmm)
                        case detail->year == _SECOND_YEAR
                             n2nd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _THIRD_YEAR
                             n3rd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _FOURTH_YEAR
                             n4th += (detail->new + detail->old + detail->ct + detail->sr)
                        endcase
                else
                        do case
                        case detail->year == _FIRST_YEAR
                             n1st += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _SECOND_YEAR
                             n2nd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _THIRD_YEAR
                             n3rd += (detail->new + detail->old + detail->ct + detail->sr)
                        case detail->year == _FOURTH_YEAR
                             n4th += (detail->new + detail->old + detail->ct + detail->sr)
                        endcase
                endif
           else
                out_text2 := out_text2 + transform(0,"9,999")+space(02)
           endif


           detail->(dbskip())
        next

//        pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
//                  abtext, prow() + 1, _MAX_LINE, {||__eject()})

        ndiffsj := (nMVBSMT+nMMBSMARE+nMIBSMTNSA+nMRBSMARENSA+nCS+;
                   nYNBSMT+nYMBSMARE+nSNBSMT+nSMBSMARE+nHNBSMT+nHMBSMARE+;
                   nBNBSMT+nBMBSMARE+nNVBSMT+nNMBSMARE+nNNBSNAME+nNWBSMT+nMWBSMARE)-;
                   (nlYNBSMT+nlYMBSMARE+nSNBSMT+nlSMBSMARE+;
                   nlMVBSMT+nlMMBSMARE+nlMIBSMTNSA+nlMRBSMARENSA+nlCS+nlHNBSMT+nlHMBSMARE+;
                   nlBNBSMT+nlBMBSMARE+nlNVBSMT+nlNMBSMARE+nlNNBSNAME+nlNWBSMT+nlMWBSMARE)
        npersj := (ndiffsj / (nlMVBSMT+nlMMBSMARE+nlMIBSMTNSA+nlMRBSMARENSA+nlCS+;
                              nlYMBSMARE+nlYNBSMT+nlSMBSMARE+nlSNBSMT+;
                              nlHNBSMT+nlHMBSMARE+nlBNBSMT+nlBMBSMARE+nlNVBSMT+nlNMBSMARE+;
                              nlNNBSNAME+nlNWBSMT+nlMWBSMARE))*100

        ntdiffsj := (ntMVBSMT+ntMMBSMARE+ntMIBSMTNSA+ntMRBSMARENSA+ntCS+;
                     ntSNBSMT+ntSMBSMARE+ntYNBSMT+ntYMBSMARE+ntHNBSMT+ntHMBSMARE+;
                     ntBNBSMT+ntBMBSMARE+ntNVBSMT+ntNMBSMARE+ntNNBSNAME+ntNWBSMT+ntMWBSMARE)-;
                    (ntlMVBSMT+ntlMMBSMARE+ntlMIBSMTNSA+ntlMRBSMARENSA+ntlCS+;
                     ntlSNBSMT+ntlSMBSMARE+ntlYNBSMT+ntlYMBSMARE+ntlHNBSMT+ntlHMBSMARE+;
                     ntlBNBSMT+ntlBMBSMARE+ntlNVBSMT+ntlNMBSMARE+ntlNNBSNAME+ntlNWBSMT+ntlMWBSMARE)
        ntpersj := (ntdiffsj / (ntlMVBSMT+ntlMMBSMARE+ntlMIBSMTNSA+ntlMRBSMARENSA+ntlCS+;
                                ntlYMBSMARE+ntlYNBSMT+ntlSMBSMARE+ntlSNBSMT+ntlHNBSMT+ntlHMBSMARE+;
                                ntlBNBSMT+ntlBMBSMARE+ntlNVBSMT+ntlNMBSMARE+ntlNNBSNAME+ntlNWBSMT+ntlMWBSMARE))*100

        diff := nall-nlst_yr
        ndiff += diff
        nPer := (diff/nlst_yr)*100
        nTotal += nall
        nTotLstYr +=nlst_yr
        nPercent := (nDiff/nTotlstYr)*100

        out_text := out_text + out_text2 + transform(nall,"999,999") + space(2) + ;
                    transform(nlst_yr,"999,999") + space(1) + transform(diff,"999,999") + space(4) + transform(nPer,"9999.99")+"%"
        outexpr(prow()+01,00,out_text)
        header->(dbskip())
enddo
        outexpr(prow()+01,00,replicate("-",80))
        outexpr(prow()+01,00,"TOTALS          "+ transform(n1st,       "9,999") + space(02) + ;
                                                 transform(n2nd,       "9,999") + space(02) + ;
                                                 transform(n3rd,       "9,999") + space(02) + ;
                                                 transform(n4th,       "9,999") + space(02) + ;
                                                 transform(nTotal,     "999,999") + space(02) + ;
                                                 transform(nTotlstYr,  "999,999") + space(01) + ;
                                                 transform(nDiff,      "999,999") + space(04) + ;
                                                 transform(nPercent,   "9999.99") + "%")

outexpr(prow()+01,00,replicate("Ä",80))

//added line
outexpr(prow()+01,00,"Cross-Enr/Transferee    : "+transform(nCT,"999,999"))
outexpr(prow()+01,00,"Shiftee/Returnee        : "+transform(nSR,"999,999"))
//outexpr(prow()+02,00,"Total Students          : "+transform(nTotal,"999,999"))
outexpr(prow()+01,00,"Withdrawals             : "+transform(nwd1+nwd2,"999,999"))
outexpr(prow()+02,00,"Total Students Enrolled : "+transform(nTotal,"999,999"))
outexpr(prow()+02,00,"Withdrawn Today         : "+transform(nWdrToday,"999,999"))
outexpr(prow()+01,00,"Enrolled Today          : "+transform(nEnrToday,"999,999"))
outexpr(prow()+04,00,"Prepared by:                                      Noted by:")
outexpr(prow()+03,00,"CHERELYN A. ROSARIO                               JOVITA A. QUI¥ANOLA")
outexpr(prow()+01,00,"Records Clerk                                     Registrar (METC)")
outexpr(prow()+01,00,chr(18))
__eject()
//added ends here

//2nd add
outexpr(prow()+02,00,"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3))
outexpr(prow()+01,00,"Time: "+Time()+space(11)+"Alumnos, Mambaling, Cebu City"+space(16)+"Confirmed")
outexpr(prow()+02,00,space(29)+"ENROLLMENT STATISTICS")
outexpr(prow()+01,00,space(29)+alltrim(cdesc))
outexpr(prow()+01,00,space(19)+"Present:"+dtoc(c_date)+" - "+"Previous:"+dtoc(dater))
//2nd end

outexpr(prow()+02,00,"                                  NEW STUDENTS")
outexpr(prow()+01,00,replicate("Ä",80))
outexpr(prow()+01,00,"COLLEGE COURSE          PRESENT          LASTYR           DIFF        %(INC/DEC)")
outexpr(prow()+01,00,"==============          =======          ======          ======       ==========")
outexpr(prow()+01,00,"MV_BSMT                "+transform(nMVBSMT,"9999999")+space(10)+transform(nlMVBSMT,"999999")+space(10)+;
                                               transform((nMVBSMT-nlMVBSMT),"999999")+space(7)+transform((((nMVBSMT-nlMVBSMT)/nlMVBSMT)*100),"999999.99"+"%") )
outexpr(prow()+01,00,"MM_BSMARE              "+transform(nMMBSMARE,"9999999")+space(10)+transform(nlMMBSMARE,"999999")+space(10)+;
                                               transform((nMMBSMARE-nlMMBSMARE),"999999")+space(7)+transform((((nMMBSMARE-nlMMBSMARE)/nlMMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"MI_BSMT-NSA            "+transform(nMIBSMTNSA,"9999999")+space(10)+transform(nlMIBSMTNSA,"999999")+space(10)+;
                                               transform((nMIBSMTNSA-nlMIBSMTNSA),"999999")+space(7)+transform((((nMIBSMTNSA-nlMIBSMTNSA)/nlMIBSMTNSA)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"MR_BSMARE-NSA          "+transform(nMRBSMARENSA,"9999999")+space(10)+transform(nlMRBSMARENSA,"999999")+space(10)+;
                                               transform((nMRBSMARENSA-nlMRBSMARENSA),"999999")+space(7)+transform((((nMRBSMARENSA-nlMRBSMARENSA)/nlMRBSMARENSA)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"YN_BSMT-IMEC           "+transform(nYNBSMT,"9999999")+space(10)+transform(nlYNBSMT,"999999")+space(10)+;
                                               transform((nYNBSMT-nlYNBSMT),"999999")+space(7)+transform((((nYNBSMT-nlYNBSMT)/nlYNBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"YM_BSMARE-IMEC         "+transform(nYMBSMARE,"9999999")+space(10)+transform(nlYMBSMARE,"999999")+space(10)+;
                                               transform((nYMBSMARE-nlYMBSMARE),"999999")+space(7)+transform((((nYMBSMARE-nlYMBSMARE)/nlYMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"SN_BSMT-INC            "+transform(nSNBSMT,"9999999")+space(10)+transform(nlSNBSMT,"999999")+space(10)+;
                                               transform((nSNBSMT-nlSNBSMT),"999999")+space(7)+transform((((nSNBSMT-nlSNBSMT)/nlSNBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"SM_BSMARE-INC          "+transform(nSMBSMARE,"9999999")+space(10)+transform(nlSMBSMARE,"999999")+space(10)+;
                                               transform((nSMBSMARE-nlSMBSMARE),"999999")+space(7)+transform((((nSMBSMARE-nlSMBSMARE)/nlSMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"HN_BSMT-HONORS CLASS   "+transform(nHNBSMT,"9999999")+space(10)+transform(nlHNBSMT,"999999")+space(10)+;
                                               transform((nHNBSMT-nlHNBSMT),"999999")+space(7)+transform((((nHNBSMT-nlHNBSMT)/nlHNBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"HM_BSMARE-HONORS CLASS "+transform(nHMBSMARE,"9999999")+space(10)+transform(nlHMBSMARE,"999999")+space(10)+;
                                               transform((nHMBSMARE-nlHMBSMARE),"999999")+space(7)+transform((((nHMBSMARE-nlHMBSMARE)/nlHMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"BN_BSMT-BRIESE         "+transform(nBNBSMT,"9999999")+space(10)+transform(nlBNBSMT,"999999")+space(10)+;
                                               transform((nBNBSMT-nlBNBSMT),"999999")+space(7)+transform((((nBNBSMT-nlBNBSMT)/nlBNBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"BM_BSMARE-BRIESE       "+transform(nBMBSMARE,"9999999")+space(10)+transform(nlBMBSMARE,"999999")+space(10)+;
                                               transform((nBMBSMARE-nlBMBSMARE),"999999")+space(7)+transform((((nBMBSMARE-nlBMBSMARE)/nlBMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"NW_BSMT-MARLAW         "+transform(nNWBSMT,"9999999")+space(10)+transform(nlNWBSMT,"999999")+space(10)+;
                                               transform((nNWBSMT-nlNWBSMT),"999999")+space(7)+transform((((nNWBSMT-nlNWBSMT)/nlNWBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"MW_BSMARE-MARLAW       "+transform(nMWBSMARE,"9999999")+space(10)+transform(nlMWBSMARE,"999999")+space(10)+;
                                               transform((nMWBSMARE-nlMWBSMARE),"999999")+space(7)+transform((((nMWBSMARE-nlMWBSMARE)/nlMWBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"NV_BSMT-NIGERIAN       "+transform(nNVBSMT,"9999999")+space(10)+transform(nlNVBSMT,"999999")+space(10)+;
                                               transform((nNVBSMT-nlNVBSMT),"999999")+space(7)+transform((((nNVBSMT-nlNVBSMT)/nlNVBSMT)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"NM_BSMARE-NIGERIAN     "+transform(nNMBSMARE,"9999999")+space(10)+transform(nlNMBSMARE,"999999")+space(10)+;
                                               transform((nNMBSMARE-nlNMBSMARE),"999999")+space(7)+transform((((nNMBSMARE-nlNMBSMARE)/nlNMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"NN_BSNAME-NIGERIAN     "+transform(nNNBSNAME,"9999999")+space(10)+transform(nlNNBSNAME,"999999")+space(10)+;
                                               transform((nNNBSNAME-nlNNBSNAME),"999999")+space(7)+transform((((nNNBSNAME-nlNNBSNAME)/nlNNBSNAME)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"CS                     "+transform(nCS,"9999999")+space(10)+transform(nlCS,"999999")+space(10)+;
                                               transform((nCS-nlCS),"999999")+space(7)+transform((((nCS-nlCS)/nlCS)*100),"999999.99"+"%"))
outexpr(prow()+01,00,replicate("Ä",80))
outexpr(prow()+01,00,"TOTALS                 "+transform((nMVBSMT+nMMBSMARE+nMIBSMTNSA+nMRBSMARENSA+nCS+ nYNBSMT+nYMBSMARE+nSNBSMT+nSMBSMARE+nHNBSMT+nHMBSMARE+;
                                               nBNBSMT+nBMBSMARE+nNVBSMT+nNMBSMARE+nNNBSNAME+nNWBSMT+nMWBSMARE),"9999999")+space(10)+transform((nlMVBSMT+nlMMBSMARE+nlMIBSMTNSA+nlMRBSMARENSA+nlCS+nlYNBSMT+nlYMBSMARE+nlSNBSMT+nlSMBSMARE+nlHNBSMT+nlHMBSMARE+;
                                               nlBNBSMT+nlBMBSMARE+nlNVBSMT+nlNMBSMARE+nlNNBSNAME+nlNWBSMT+nlMWBSMARE),"999999")+space(10)+;
                                               transform(ndiffsj,"999999")+space(7)+transform(npersj,"999999.99"+"%"))
outexpr(prow()+01,00,replicate("Ä",80))

outexpr(prow()+04,00,"Prepared by:                                      Noted by:")
outexpr(prow()+03,00,"CHERELYN A. ROSARIO                               JOVITA A. QUI¥ANOLA")
outexpr(prow()+01,00,"Records Clerk                                     Registrar (METC)")

outexpr(prow()+01,00,chr(18))
__eject()

//3Rd add - Transferee
outexpr(prow()+02,00,"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3))
outexpr(prow()+01,00,"Time: "+Time()+space(11)+"Alumnos, Mambaling, Cebu City"+space(16)+"Confirmed")
outexpr(prow()+02,00,space(29)+"ENROLLMENT STATISTICS")
outexpr(prow()+01,00,space(29)+alltrim(cdesc))
outexpr(prow()+01,00,space(19)+"Present:"+dtoc(c_date)+" - "+"Previous:"+dtoc(dater))
//3rd end

outexpr(prow()+02,00,"                                   TRANSFEREE ")
outexpr(prow()+01,00,replicate("Ä",80))
outexpr(prow()+01,00,"COLLEGE COURSE          PRESENT          LASTYR           DIFF        %(INC/DEC)")
outexpr(prow()+01,00,"==============          =======          ======          ======       ==========")
outexpr(prow()+01,00,"MV_BSMT                "+transform(ntMVBSMT,"9999999")+space(10)+transform(ntlMVBSMT,"999999")+space(10)+;
                                               transform((ntMVBSMT-ntlMVBSMT),"999999")+space(7)+transform((((ntMVBSMT-ntlMVBSMT)/ntlMVBSMT)*100),"999999.99"+"%") )
outexpr(prow()+01,00,"MM_BSMARE              "+transform(ntMMBSMARE,"9999999")+space(10)+transform(ntlMMBSMARE,"999999")+space(10)+;
                                               transform((ntMMBSMARE-ntlMMBSMARE),"999999")+space(7)+transform((((ntMMBSMARE-ntlMMBSMARE)/ntlMMBSMARE)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"MI_BSMT-NSA            "+transform(ntMIBSMTNSA,"9999999")+space(10)+transform(ntlMIBSMTNSA,"999999")+space(10)+;
                                               transform((ntMIBSMTNSA-ntlMIBSMTNSA),"999999")+space(7)+transform((((ntMIBSMTNSA-ntlMIBSMTNSA)/ntlMIBSMTNSA)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"MR_BSMARE-NSA          "+transform(ntMRBSMARENSA,"9999999")+space(10)+transform(ntlMRBSMARENSA,"999999")+space(10)+;
                                               transform((ntMRBSMARENSA-ntlMRBSMARENSA),"999999")+space(7)+transform((((ntMRBSMARENSA-ntlMRBSMARENSA)/ntlMRBSMARENSA)*100),"999999.99"+"%"))
outexpr(prow()+01,00,"CS                     "+transform(ntCS,"9999999")+space(10)+transform(ntlCS,"999999")+space(10)+;
                                               transform((ntCS-ntlCS),"999999")+space(7)+transform((((ntCS-ntlCS)/ntlCS)*100),"999999.99"+"%"))
outexpr(prow()+01,00,replicate("Ä",80))
outexpr(prow()+01,00,"TOTALS                 "+transform((ntMVBSMT+ntMMBSMARE+ntMIBSMTNSA+ntMRBSMARENSA+ntCS),"9999999")+space(10)+transform((ntlMVBSMT+ntlMMBSMARE+ntlMIBSMTNSA+ntlMRBSMARENSA+ntlCS),"999999")+space(10)+;
                                               transform(ntdiffsj,"999999")+space(7)+transform(ntpersj,"999999.99"+"%"))
outexpr(prow()+01,00,replicate("Ä",80))

outexpr(prow()+04,00,"Prepared by:                                      Noted by:")
outexpr(prow()+03,00,"CHERELYN A. ROSARIO                               JOVITA A. QUI¥ANOLA")
outexpr(prow()+01,00,"Records Clerk                                     Registrar (METC)")

outexpr(prow()+01,00,chr(18))
__eject()

closewcheck(afile)
return(nil)

static function cdxhstat()
field colcode,coldesc,year
private cdummyfile := alias()
index on coldesc tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on colcode+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)


static function cdxdstat()
field colcode,coldesc,year,term
private cdummyfile := alias()
index on colcode+year tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on coldesc+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
index on colcode+year+term tag (memvar->cdummyfile+"3") of (memvar->cdummyfile)
return(nil)

static function cdxhstatus()
field colcode,coldesc,year
private cdummyfile := alias()
index on coldesc+colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on colcode+year tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

function enrlstprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp,bprint, cprocsts, cterm, cdesc, aentryscr,;
      ccolcode, cyrlevel, csex, ddate, ccls
private cdummy := "enls"+strzero(memvar->naccess,2),enrheader,enrdetail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment List Report  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        cyrlevel := "8"
        ccolcode := "UC"
        csex     := "B"
        ccls     := "A"
        do while .t.
                ddate := ctod("")
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,21 say "[NT-nautical,MG-marine,UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
                @ 04,21 say "[1 2 3 4 5  8-All]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel    pict "@!";
                        valid cyrlevel $ _FIRST_YEAR+;
                                         _SECOND_YEAR+;
                                         _THIRD_YEAR+;
                                         _FOURTH_YEAR+;
                                         _FIFTH_YEAR+;
                                         _ALL_YEAR
                @ 05,21 say "[M-ale,F-emale,B-oth]" color memvar->colorarray[02]
                @ 05,02 say "Sex          :";
                        color memvar->colorarray[02];
                        get csex        pict "@!";
                        valid csex $ "BFM"
//                @ 06,21 say "[A-ll,H-igh,T-rans,O-ld,C-ross,S-hiftee,R-eturnee,U-nconfirm]" color memvar->colorarray[02]
                @ 06,21 say "[All,High,Trans,Old,Cross,Shiftee,Returnee,Unconfirmed]" color memvar->colorarray[02]
                @ 06,22 say "A"  color memvar->colorarray[03]
                @ 06,26 say "H"  color memvar->colorarray[03]
                @ 06,31 say "T"  color memvar->colorarray[03]
                @ 06,37 say "O"  color memvar->colorarray[03]
                @ 06,41 say "C"  color memvar->colorarray[03]
                @ 06,47 say "S"  color memvar->colorarray[03]
                @ 06,55 say "R"  color memvar->colorarray[03]
                @ 06,64 say "U"  color memvar->colorarray[03]
//                   A   H    T     O   C     S       R        U         " color memvar->colorarray[01]

                @ 06,02 say "Class        :";
                        color memvar->colorarray[02];
                        get ccls        pict "@!";
                        valid ccls $ "AHTOCSRU"
                @ 07,02 say "D a t e      :";
                        color memvar->colorarray[02];
                        get ddate
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||penrlstprn(ccolcode,cyrlevel,csex,cdesc,ddate,ccls)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"H"+".TXT"); ccdx := (memvar->cdummy+"H"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"D"+".TXT"); ccdx := (memvar->cdummy+"D"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function penrlstprn(ccolcode,cyrlevel,csex,cdesc,ddate,ccls)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      csexdesc,ccourse
private lprocess := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"H",{{"COURSE"  ,"C",02,0},;
                                     {"DESC"    ,"C",35,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"YDESC"   ,"C",11,0}},{||cdxhenr()}) .or.;
   ! createdummy(memvar->cdummy+"D",{{"IDNO"    ,"C",08,0},;
                                     {"COURSE"  ,"C",02,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",24,0},;
                                     {"MNAME"   ,"C",01,0},;
                                     {"LOAD"    ,"N",05,1},;
                                     {"REMARKS" ,"C",11,0},;
                                     {"DATEENR" ,"D",08,0}},{||cdxdenr()})
        dbcloseall()
        return(nil)
endif
memvar->enrheader := memvar->cdummy+"H"
memvar->enrdetail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->enrheader+".TXT"),"enrheader",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->enrdetail+".TXT"),"enrdetail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
enrheader->(__dbzap()); enrheader->(dbreindex())
enrdetail->(__dbzap()); enrdetail->(dbreindex())

if csex == "M"
        csexdesc := "MALE"
elseif csex == "F"
        csexdesc := "FEMALE"
else
        csexdesc := "MALE/FEMALE"
endif

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("ENROLLMENT LIST"+if(ccls=="U"," - Unconfirmed",""),nmaxcol))+;
                              "ENROLLMENT LIST"+if(ccls=="U"," - Unconfirmed","")})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(enrheader->desc),nmaxcol))+alltrim(enrheader->desc)})
aadd(abtext,{||space(titlepos(alltrim(enrheader->ydesc)+" - "+alltrim(csexdesc),nmaxcol))+alltrim(enrheader->ydesc)+" - "+alltrim(csexdesc)})
if ! empty(ddate)
        aadd(abtext,{||space(titlepos("Date enrolled => "+displaydate(ddate),nmaxcol))+;
                                      "Date enrolled => "+displaydate(ddate)})
        aadd(abtext,{||""})
else
        aadd(abtext,{||""})
endif
aadd(abtext,{||"         ID NO.     LAST NAME            FIRST NAME         M  LOAD    REMARKS  "})
aadd(abtext,{||"       --------  ---------------  ------------------------  -  -----  -----------"})
//aadd(abtext,{||"         ID NO.     LAST NAME            FIRST NAME         M  LOAD   DATE ENRLD"})
//aadd(abtext,{||"       --------  ---------------  ------------------------  -  -----  ----------"})

/*
         ID NO.     LAST NAME            FIRST NAME         M  LOAD    REMARKS
       --------  ---------------  ------------------------  -  -----  -----------
12345. 12345678  123456789012345  123456789012345678901234  1  123.1  WITHDRAWN
*/

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
if ccolcode $ "NTMGUC" .and. ! cyrlevel == _ALL_YEAR
        cyytenrp->(sx_settagorder(3))
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
elseif ! ccolcode $ "NTMGUC" .and. cyrlevel == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
elseif ! ccolcode $ "NTMGUC" .and. ! cyrlevel == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyrlevel))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyrlevel))
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if empty(ddate)
                verifydata(ccolcode,cyrlevel,csex,cdesc,ccls)
        elseif cyytenrp->enrdte == ddate  &&not empty date
                verifydata(ccolcode,cyrlevel,csex,cdesc,ccls)
        endif
        if nextkey() == K_ESC
                exit
        endif
        if memvar->lprocess
                if ! enrheader->(dbseek(cyytenrp->enrcolcod+cyytenrp->enryrlevl))
                        enrheader->(dbappend())
                        enrheader->course       := cyytenrp->enrcolcod
                        enrheader->year         := cyytenrp->enryrlevl
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        enrheader->desc         := cyytenrp->enrcolcod+" - "+c999colp->coldesful
                        if cyytenrp->enryrlevl == _FIRST_YEAR
                                enrheader->ydesc := "FIRST YEAR"
                        elseif cyytenrp->enryrlevl == _SECOND_YEAR
                                enrheader->ydesc := "SECOND YEAR"
                        elseif cyytenrp->enryrlevl == _THIRD_YEAR
                                enrheader->ydesc := "THIRD YEAR"
                        elseif cyytenrp->enryrlevl == _FOURTH_YEAR
                                enrheader->ydesc := "FOURTH YEAR"
                        elseif cyytenrp->enryrlevl == _FIFTH_YEAR
                                enrheader->ydesc := "FIFTH YEAR"
                        endif
                        enrheader->(dbcommit())
                        enrheader->(dbunlock())
                endif
                memvar->lprocess := .f.
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*-------------------
*  printing data   *
*-------------------
nctr := 0
enrheader->(dbgotop())
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
do while ! enrheader->(eof())
        fask(10,"  Printing college code "+enrheader->course+" year "+enrheader->year+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        enrdetail->(sx_setscope(_TOP_SCOPE   ,enrheader->course+enrheader->year))
        enrdetail->(sx_setscope(_BOTTOM_SCOPE,enrheader->course+enrheader->year))
        enrdetail->(dbgotop())
        do while ! enrdetail->(eof())
                fask(16,"  Printing student "+alltrim(enrdetail->lname)+", "+alltrim(enrdetail->fname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                             abtext, prow() + 1, _MAX_LINE, {||__eject()})
                outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                                     enrdetail->idno+space(02)+;
                                     enrdetail->lname+space(02)+;
                                     enrdetail->fname+space(02)+;
                                     enrdetail->mname+space(02)+;
                                     transform(enrdetail->load,"999.9")+space(02)+;
                                     "___________")
//                                     dtoc(enrdetail->dateenr))

                if empty(enrdetail->remarks)
                        outexpr(prow()+00,70,"UNCONFIRMED")
                endif

                /*
                if ! empty(enrdetail->remarks)
                        outexpr(prow()+00,70,enrdetail->remarks)
                endif
                */
                if nextkey() == K_ESC
                        exit
                endif
                enrdetail->(dbskip())
        enddo
        enrdetail->(clearscope())
        enrheader->(dbskip())
        outexpr(prow()+01,00,chr(18))
        __eject()
        npage := nctr := 0
enddo
closewcheck(afile)
return(nil)

static function verifydata(ccolcode,cyrlevel,csex,cdesc,ccls)
if ccls == "A" .or. ccls == cyytenrp->enrcls .or. (ccls == "U" .and. empty(cyytenrp->enrconfirm))
        do case
                case ccolcode == "UC"  &&all course
                        if cyrlevel == _ALL_YEAR
                                if csex == "B"  &&both male and female
                                        writedata()
                                        memvar->lprocess := .t.
                                elseif csex == c999sm1p->sm1sex
                                        writedata()
                                        memvar->lprocess := .t.
                                endif
                        elseif cyrlevel == cyytenrp->enryrlevl
                                if csex == "B"  &&both male and female
                                        writedata()
                                        memvar->lprocess := .t.
                                elseif csex == c999sm1p->sm1sex
                                        writedata()
                                        memvar->lprocess := .t.
                                endif
                        endif
                case ccolcode == _NAUTICAL  &&all nautical
                        if cyytenrp->enrcolcod $ "MV,MS,MI,MT,PA,SN,YN,BN,HN,NW,NV,ET"
                                if cyrlevel == _ALL_YEAR
                                        if csex == "B"  &&both male and female
                                                writedata()
                                                memvar->lprocess := .t.
                                        elseif csex == c999sm1p->sm1sex
                                                writedata()
                                                memvar->lprocess := .t.
                                        endif
                                elseif cyrlevel == cyytenrp->enryrlevl
                                        if csex == "B"  &&both male and female
                                                writedata()
                                                memvar->lprocess := .t.
                                        elseif csex == c999sm1p->sm1sex
                                                writedata()
                                                memvar->lprocess := .t.
                                        endif
                                endif
                        endif
                case ccolcode == _MARINE    &&all marine
                        if cyytenrp->enrcolcod $ "MM,MA,MR,MP,SM,YM,BM,HM,MW,NM,EN,EL"
                                if cyrlevel == _ALL_YEAR
                                        if csex == "B"  &&both male and female
                                                writedata()
                                                memvar->lprocess := .t.
                                        elseif csex == c999sm1p->sm1sex
                                                writedata()
                                                memvar->lprocess := .t.
                                        endif
                                elseif cyrlevel == cyytenrp->enryrlevl
                                        if csex == "B"  &&both male and female
                                                writedata()
                                                memvar->lprocess := .t.
                                        elseif csex == c999sm1p->sm1sex
                                                writedata()
                                                memvar->lprocess := .t.
                                        endif
                                endif
                        endif
                case cyytenrp->enrcolcod == ccolcode  &&particular course
                        if cyrlevel == _ALL_YEAR
                                if csex == "B"  &&both male and female
                                        writedata()
                                        memvar->lprocess := .t.
                                elseif csex == c999sm1p->sm1sex
                                        writedata()
                                        memvar->lprocess := .t.
                                endif
                        elseif cyrlevel == cyytenrp->enryrlevl
                                if csex == "B"  &&both male and female
                                        writedata()
                                        memvar->lprocess := .t.
                                elseif csex == c999sm1p->sm1sex
                                        writedata()
                                        memvar->lprocess := .t.
                                endif
                        endif
        endcase
endif
return(nil)

static function writedata()
enrdetail->(dbappend())
enrdetail->idno         := c999sm1p->sm1idno
enrdetail->course       := cyytenrp->enrcolcod
enrdetail->lname        := c999sm1p->sm1lstnam
enrdetail->fname        := c999sm1p->sm1fstnam
enrdetail->mname        := c999sm1p->sm1midnam
enrdetail->year         := cyytenrp->enryrlevl
enrdetail->load         := cyytenrp->enrunt
enrdetail->dateenr      := cyytenrp->enrdte
enrdetail->remarks      := cyytenrp->enrconfirm

/*
if cyytenrp->enrenrst $ _WITHDRAW_BEFORE+;
                        _WITHDRAW_AFTER
        enrdetail->remarks      := "WITHDRAWN "
elseif cyytenrp->enrgrad == "*"
        enrdetail->remarks      := "GRADUATING"
else
        enrdetail->remarks      := space(10)
endif
*/

return(nil)

static function vcollege(ccode,cprocsts)
if ccode $ "NTMGUCRO"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 03,23 say c999colp->coldesful+space(20)
return(.t.)

function cdxhenr()
field course,year
private cdummyfile := alias()
index on course+year tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

function cdxdenr()
field course,lname,fname,mname,year
private cdummyfile := alias()
index on course+year+lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on lname+fname+mname tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

function aprenlist()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,cyytappp,aentryscr,;
      cprocsts,cterm,cdesc,cyrlevel,caddendum,npage,nline,ccolcod,;
      clastname,cfirstname

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[54],"  Aprenticeship List Printing  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        draw_box2(03,07,05,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        @ 04,09 say "School Term :";
                color memvar->colorarray[55]
        draw_box1(03,24,05,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        @ 04,25 get cterm pict "@!";
                valid ! empty(cterm) color memvar->colorarray[54]
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
        if ! file(alltrim("c"+cterm+"appp.dbf"))
                fask(10,"  C"+cterm+"APPP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        draw_box1(03,31,05,57,memvar->colorarray[28],memvar->colorarray[29],,.f.)
        @ 04,30 say "-" color memvar->colorarray[55]
        @ 04,32 say term->name pict "@S25" color memvar->colorarray[54]
        aentryscr := savescr(01,00,24,79)
        cyytappp := "c"+cterm+"appp"
        if(aprv2setup := openwcheck({{,,"c999appp",,_DBF_SHARED,,5},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,cyytappp,"cyytappp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyrlevel  := "8"
        ccolcode  := "  "
        caddendum := "N"
        npage := nline := 0
        clastname:=space(len(c999appp->(applname)))
        cfirstname:=space(len(c999appp->(appfname)))
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                draw_box2(06,07,08,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box2(06,31,08,70,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(06,24,08,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 07,33 say "[NT-Nautical MG-Marine RO-MRO]" color memvar->colorarray[55]
                @ 07,09 say "Course Code :";
                        color memvar->colorarray[55]
                @ 07,26 get ccolcode pict "@!";
                        valid vcoll1(ccolcode,cprocsts) color memvar->colorarray[54]
                draw_box2(09,07,11,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box2(09,31,11,55,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(09,24,11,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 10,33 say "[ 1 , 2 , 3 , 4 , 5 ]" color memvar->colorarray[55]
                @ 10,09 say "Year Level  :";
                        color memvar->colorarray[55]
                @ 10,26 get cyrlevel pict "@!" valid cyrlevel $ "123458" color memvar->colorarray[54]
                draw_box2(12,07,14,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box2(12,31,14,50,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(12,24,14,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 13,33 say "[ Y-yes / N-no ]" color memvar->colorarray[55]
                @ 13,09 say "Addendum ?  :";
                        color memvar->colorarray[55]
                @ 13,26 get caddendum pict "@!" valid caddendum $ "YN" color memvar->colorarray[54]

                draw_box2(15,07,17,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(15,24,17,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 16,09 say "Last Page   :";
                        color memvar->colorarray[55]
                @ 16,26 get npage pict "999" color memvar->colorarray[54]

                draw_box2(15,31,17,47,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(15,48,17,53,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 16,33 say "Last Line   :";
                        color memvar->colorarray[55]
                @ 16,49 get nline pict "9999" color memvar->colorarray[54]

                @ 18,09 say "Name of Apprentice last printed " color memvar->colorarray[55]


                draw_box2(19,07,22,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(19,24,22,51,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 20,09 say "Last Name   :";
                        color memvar->colorarray[55]
                @ 20,26 get clastname pict "@!" color memvar->colorarray[54]
                @ 21,09 say "First Name  :";
                        color memvar->colorarray[55]
                @ 21,26 get cfirstname pict "@!" color memvar->colorarray[54]


/*
                draw_box2(18,07,20,23,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                draw_box1(18,24,20,29,memvar->colorarray[28],memvar->colorarray[29],,.f.)
                @ 19,09 say "Last Line   :";
                        color memvar->colorarray[55]
                @ 19,25 get nline pict "9999" color memvar->colorarray[54]
*/

               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||paprenlist(cterm,cdesc,cyrlevel,caddendum,npage,nline,clastname,cfirstname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function paprenlist(cterm,cdesc,cyrlevel,caddendum,npage,nline,clastname,cfirstname)
local abtext := {},ncol,nmaxcol := 83, nctr := 0,wscolcod, i:=nline
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("ALUMNOS, MAMBALING, CEBU CITY",nmaxcol))+;
                              "ALUMNOS, MAMBALING, CEBU CITY"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("ENROLMENT LIST FOR "+alltrim(cdesc),nmaxcol))+;
                              "ENROLMENT LIST FOR "+alltrim(cdesc)})

if caddendum == "Y"
        aadd(abtext,{||space(titlepos("(ADDENDUM)",nmaxcol))+;
                                      "(ADDENDUM)"})
endif

/* aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION (BSMT)",nmaxcol))+;
                              "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION (BSMT)"})
aadd(abtext,{||"MARINE TRANSPORTATION "+cyrlevel+" - (Apprentice Mate on Board)"})
*/

//aadd(abtext,{||cdesc+" "+cyrlevel+" - (Apprentice Mate on Board)"})
//aadd(abtext,{||replicate("-",83)})
//pageprint(abtext)
ccolcode:=alltrim(ccolcode)

do case
   case ccolcode == _NAUTICAL
       wscolcod := "MIMTMSPAMVRO"
   case ccolcode == _MARINE
       wscolcod := "MAMRMMMEMDMP"
   case ccolcode == _MRO
       wscolcod := "RO"
   otherwise
       wscolcod := alltrim(ccolcode)
endcase

if ccolcode == _NAUTICAL .and. ! cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(4))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE TRANSPORTATION "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode == _NAUTICAL .and. cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(5))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE TRANSPORTATION "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode == _MARINE .and. ! cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(4))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE ENGINEERING",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE ENGINEERING"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE ENGINEERING "+cyrlevel+" - (Apprentice Engineer on Board)"})

elseif ccolcode == _MARINE .and.  cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(5))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE ENGINEERING",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE ENGINEERING"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE ENGINEERING "+cyrlevel+" - (Apprentice Engineer on Board)"})

elseif ccolcode == _MRO .and. ! cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(4))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTAION - MRO",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTAION - MRO"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE TRANSPORTATION - MRO "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode == _MRO .and.  cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(5))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTAION - MRO",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTAION - MRO"})
        aadd(abtext,{||""})
        aadd(abtext,{||"MARINE TRANSPORTATION - MRO "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode $ "MIMTMSPAMVRO" .and. ! cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(4))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION"})
        aadd(abtext,{||""})
        aadd(abtext,{||c999colp->coldesful+" "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode $ "MIMTMSPAMVRO" .and. cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(5))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION"})
        aadd(abtext,{||""})
        aadd(abtext,{||c999colp->coldesful+" "+cyrlevel+" - (Apprentice Mate on Board)"})

elseif ccolcode $ "MAMRMMMEMDMP" .and. ! cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(4))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE ENGINEERING",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE ENGINEERING"})
        aadd(abtext,{||""})
        aadd(abtext,{||c999colp->coldesful+" "+cyrlevel+" - (Apprentice Engineer on Board)"})

elseif ccolcode $ "MAMRMMMEMDMP" .and. cyrlevel == _ALL_YEAR
        c999appp->(sx_settagorder(5))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
        aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE ENGINEERING",nmaxcol))+;
                                      "BACHELOR OF SCIENCE IN MARINE ENGINEERING"})
        aadd(abtext,{||""})
        aadd(abtext,{||c999colp->coldesful+" "+cyrlevel+" - (Apprentice Engineer on Board)"})

/*
elseif ccolcode == _ALLCOURSE
        c999appp->(sx_settagorder(6))
        c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
        c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
*/

endif

aadd(abtext,{||replicate("-",83)})
pageprint(abtext)

c999appp->(dbgotop())

if !empty(clastname) .or. !empty(cfirstname)
        fask(10,"  Searching....  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        do while ! c999appp->(eof()) .and. (alltrim(c999appp->applname)<=alltrim(clastname));
                                     .and. (alltrim(c999appp->appfname<=alltrim(cfirstname)))
                fask(10,"  Locating name "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname+"  ",{" Ok "},memvar->colorarray[06],.t.,nil)
                if nextkey() == K_ESC
                        exit
                endif
                c999appp->(dbskip())
        enddo
endif

do while ! c999appp->(eof())
     if c999appp->appcourse $ wscolcod .and. c999appp->appterm == cterm
        fask(10,"  Printing name "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say transform(++nline,"@Z 9999")+". "+;
                           alltrim(c999appp->applname)+", "+;
                           alltrim(c999appp->appfname)+" "+;
                           alltrim(c999appp->appmname)+"."
        @ prow(),42 say "("+c999appp->appidno+")"
        @ prow(),54 say "Date Recognized: "+upper(substr(cmonth(c999appp->appdrecog),1,3))+" "+transform(day(c999appp->appdrecog),"99")+", "+transform(year(c999appp->appdrecog),"9999")
        @ prow()+01,06 say if(! empty(c999appp->appprovadd),c999appp->appprovadd,"C/O UC-METC REGISTRAR")
        cyytappp->(sx_setscope(_TOP_SCOPE   ,c999appp->appidno))
        cyytappp->(sx_setscope(_BOTTOM_SCOPE,c999appp->appidno))
        cyytappp->(dbgotop())
        do while ! cyytappp->(eof())
                fask(16,"  Printing vessel "+alltrim(cyytappp->appvesname)+"  ",{" Yes "},memvar->colorarray[06],.f.,nil)
                @ prow(),53 say "Embarkation Date: "+upper(substr(cmonth(appembark),1,3))+" "+transform(day(appembark),"99")+", "+transform(year(appembark),"9999")
                @ prow()+01,06 say "Name of Vessel: "+alltrim(cyytappp->appvesname)
                @ prow(),53 say "  Type of Vessel: "+if(cyytappp->appvestype=="F","Foreign","Coastwise")
//                @ prow(),50 say "Disembarkation Date: "+upper(substr(cmonth(appdembark),1,3))+" "+transform(day(appdembark),"99")+", "+transform(year(appdembark),"9999")
                @ prow()+01,06 say "Proprietor: "+substr(cyytappp->appvesown,1,35)+space(06)+"Gross Tons: "+transform(cyytappp->appgrston,"99999,999.99")
                if nextkey() == K_ESC
                        exit
                endif
                cyytappp->(dbskip())
        enddo
        cyytappp->(clearscope())
        outexpr(prow()+01,00,replicate("-",83))
        if nextkey() == K_ESC
                exit
        endif
        if ++nctr == 8
                outexpr(prow()+00,00,chr(18))
                __eject()
                pageprint(abtext)
                nctr := 0
        endif
     endif
     c999appp->(dbskip())
enddo
c999appp->(clearscope())
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

*------------------------------------------------------------------------------*

function enrlstucmain()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, cyytskdp,aentryscr,;
      bprint,cprocsts,cterm,cdesc,ccolcode,cyear,csex,cfile,ccdx,cname,npage,nctr,;
      cfname
private cdummy := "enruc"+strzero(memvar->naccess,2), ucfile, sexfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment List for UC Main  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        ccolcode := "NT"
        cyear    := "1"
        csex     := "B"
        cname    := space(15)
        cfname   := space(24)
        npage := nctr := 0
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-Nautical, MG-Marine, RO-MRO]" color memvar->colorarray[02]
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
                @ 06,02 say "Last Name      :";
                        color memvar->colorarray[02];
                        get cname       pict "@!"
                @ 07,02 say "First Name     :";
                        color memvar->colorarray[02];
                        get cfname      pict "@!"
                @ 08,02 say "Last Page      :";
                        color memvar->colorarray[02];
                        get npage       pict "999"
                @ 09,02 say "Last Line      :";
                        color memvar->colorarray[02];
                        get nctr        pict "9999"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||penrforuc(cterm,cdesc,ccolcode,cyear,csex,cname,npage,nctr,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"U"+".TXT"); ccdx := (memvar->cdummy+"U"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"S"+".TXT"); ccdx := (memvar->cdummy+"S"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function penrforuc(cterm,cdesc,ccolcode,cyear,csex,cname,npage,nctr,cfname)
local abtext := {},ncol,nmaxcol := 80, nline := 0, afile,;
      csexdesc,ccourse,ncol1,ncol2,ncol3,cskdno,nctr1,ntotunits,lprint := .f.,;
      lprint1:=.f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"S",{{"YEAR"    ,"C",01,0},;
                                     {"SEX"     ,"C",01,0},;
                                     {"CDESC"   ,"C",30,0},;
                                     {"YDESC"   ,"C",11,0},;
                                     {"SDESC"   ,"C",09,0}},{||cdxsex()}) .or.;
   ! createdummy(memvar->cdummy+"U",{{"IDNO"    ,"C",08,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",24,0},;
                                     {"MNAME"   ,"C",01,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"SEX"     ,"C",01,0},;
                                     {"ADDRESS" ,"C",30,0},;
                                     {"REMARKS" ,"C",19,0}},{||cdxforuc()})
        dbcloseall()
        return(nil)
endif
memvar->ucfile  := memvar->cdummy+"U"
memvar->sexfile := memvar->cdummy+"S"
if(afile := openwcheck({{,,(memvar->ucfile+".TXT"),"ucfile",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->sexfile+".TXT"),"sexfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
ucfile->(__dbzap()); ucfile->(dbreindex())
sexfile->(__dbzap()); sexfile->(dbreindex())

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("ENROLLMENT LIST",nmaxcol))+;
                              "ENROLLMENT LIST"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||sexfile->cdesc})
aadd(abtext,{||alltrim(sexfile->ydesc)+" - "+sexfile->sdesc})
aadd(abtext,{||"-------------------------------------------------------------------------------"})

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbsetrelation("c999colp",{||cyytenrp->enrcolcod},"cyytenrp->enrcolcod"))
if ccolcode $ "NTMGRO" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_settagorder(3))
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,cyear))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,cyear))
elseif ! ccolcode $ "NTMGRO" .and. cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
elseif ! ccolcode $ "NTMGRO" .and. ! cyear == _ALL_YEAR
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyear))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyear))
endif
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case ccolcode == _NAUTICAL
                        if cyytenrp->enrcolcod $ "MIMTPAMVSNYNHNBNETNVNW"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        if csex $ ("B"+c999sm1p->sm1sex)
                                                writedata1(ccolcode)
                                        endif
                                endif
                        endif
                case ccolcode == _MARINE
                        if cyytenrp->enrcolcod $ "MAMRMPMMMDSMYMHMBMERENELNMMW"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        if csex $ ("B"+c999sm1p->sm1sex)
                                                writedata1(ccolcode)
                                        endif
                                endif
                        endif
                case ccolcode == _MRO
                        if cyytenrp->enrcolcod = "RO"
                                if cyear $ (_ALL_YEAR+cyytenrp->enryrlevl)
                                        if csex $ ("B"+c999sm1p->sm1sex)
                                                writedata1(ccolcode)
                                        endif
                                endif
                        endif
                case cyytenrp->enrcolcod == ccolcode  &&particular course
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
ucfile->(dbsetrelation("cyytenrp",{||ucfile->idno},"ucfile->idno"))
sexfile->(dbgotop())
do while ! sexfile->(eof())
        nline := 0
        pageprint(abtext)
        ucfile->(sx_setscope(_TOP_SCOPE   ,sexfile->year+sexfile->sex))
        ucfile->(sx_setscope(_BOTTOM_SCOPE,sexfile->year+sexfile->sex))
        ucfile->(dbgotop())
        do while ! ucfile->(eof())
                ntotunits := 0
                fask(10,"  Printing name "+alltrim(ucfile->lname)+", "+alltrim(ucfile->fname)+" "+ucfile->mname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if alltrim(cname+cfname) < alltrim(ucfile->lname+ucfile->fname)
                        outexpr(prow()+01,00,transform(++nctr,"@Z 9999")+"."+space(01)+;
                                             ucfile->lname+space(01)+;
                                             ucfile->fname+space(01)+;
                                             ucfile->mname+"."+space(06)+;
                                             "("+ucfile->idno+")")
                        outexpr(prow()+01,06,ucfile->address+space(19)+;
                                             ucfile->remarks)
                        nline2 := 0
                        ncol1  := 1
                        ncol2  := 06
                        ncol3  := 20
                        lprint := .t.
                        *cyytenrp->(dbseek(ucfile->idno))
                        for nctr1 := 1 to 25
                                cskdno := if(nctr1 < 10,"enrskd"+transform(nctr1,"9"),"enrskd"+transform(nctr1,"99"))
                                if ! cyytenrp->&cskdno == "00000"
                                        cyytskdp->(dbseek(cyytenrp->&cskdno))
                                        fask(16,"  Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                                if ncol1 == 1
                                                        outexpr(prow()+01,ncol2,cyytskdp->skdsubcod+space(01)+;
                                                                                if(cyytskdp->skdsubtyp == "LEC"," ","L")+" - "+;
                                                                                transform(cyytskdp->skdunt,"@Z 99.9"))
                                                        outexpr(prow()+00,ncol3,"___")
                                                        ncol2 += 26
                                                        ncol3 += 26
                                                        ntotunits += cyytskdp->skdunt
                                                elseif str(ncol1,1) $ "23"
                                                        outexpr(prow()+00,ncol2,cyytskdp->skdsubcod+space(01)+;
                                                                                if(cyytskdp->skdsubtyp == "LEC"," ","L")+" - "+;
                                                                                transform(cyytskdp->skdunt,"@Z 99.9"))
                                                        outexpr(prow()+00,ncol3,"___")
                                                        ncol2 += 26
                                                        ncol3 += 26
                                                        ntotunits += cyytskdp->skdunt
                                                        if ncol1 == 3
                                                                ncol1  := 0
                                                                ncol2  := 06
                                                                ncol3  := 20
                                                        endif
                                                endif
                                                ++ncol1
                                        endif
                                else
                                        exit
                                endif
                        next
                        outexpr(prow()+01,56,"TOTAL UNITS : "+transform(ntotunits,"@Z 99.9"))
                        outexpr(prow()+01,00,replicate("-",80))
                endif
                if nextkey() == K_ESC
                        exit
                endif
                ucfile->(dbskip())
                if lprint
                        if substr(cterm,3,1) $ "12"
                                if ++nline == 6 .and. ! ucfile->(eof())
                                         __eject()
                                         pageprint(abtext)
                                         nline := 0
                                endif
                        else
                                if ++nline == 7 .and. ! ucfile->(eof())
                                        __eject()
                                        pageprint(abtext)
                                        nline := 0
                                endif
                        endif
                endif
                lprint := .f.
        enddo
        ucfile->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        sexfile->(dbskip())
        if ! sexfile->(eof())
                __eject()
        endif
        nctr := 0
        npage := 0
enddo
__eject()
closewcheck(afile)
cyytenrp->(sx_settagorder(2))
return(nil)

static function cdxsex()
field year,sex
private cdummyfile := alias()
index on year+sex tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function cdxforuc()
field year,sex,lname,fname,mname
private cdummyfile := alias()
index on year+sex+lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

static function writedata1(ccolcode)
if ! sexfile->(dbseek(cyytenrp->enryrlevl+c999sm1p->sm1sex))
        sexfile->(dbappend())
        sexfile->year   := cyytenrp->enryrlevl
        sexfile->sex    := c999sm1p->sm1sex
        sexfile->cdesc  := if(ccolcode $ _NAUTICAL+_MARINE+_MRO,c999colp->colnamcol,c999colp->coldesful)
        sexfile->sdesc  := if(c999sm1p->sm1sex == "M","MALE(S)  ","FEMALE(S)")
        sexfile->ydesc  := if(cyytenrp->enryrlevl == _FIRST_YEAR ,"FIRST YEAR ",;
                           if(cyytenrp->enryrlevl == _SECOND_YEAR,"SECOND YEAR",;
                           if(cyytenrp->enryrlevl == _THIRD_YEAR ,"THIRD YEAR ",;
                           if(cyytenrp->enryrlevl == _FOURTH_YEAR,"FOURTH YEAR",;
                                                                  "FIFTH TEAR "))))
endif
ucfile->(dbappend())
ucfile->idno    := c999sm1p->sm1idno
ucfile->lname   := c999sm1p->sm1lstnam
ucfile->fname   := c999sm1p->sm1fstnam
ucfile->mname   := c999sm1p->sm1midnam
ucfile->year    := cyytenrp->enryrlevl
ucfile->sex     := c999sm1p->sm1sex
ucfile->address := if(!empty(c999sm1p->sm1homadr),c999sm1p->sm1homadr,"C/O TO REGISTRAR UC-METC      ")
ucfile->remarks := if(cyytenrp->enrenrst $ _WITHDRAW_BEFORE+_WITHDRAW_AFTER,"WITHDRAWN "+dtoc(cyytenrp->enrdte),space(19))
return(nil)

*------------------------------------------------------------------------------*

function aprendetailed()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,aprv2setup,cyytappp,aentryscr,;
      cprocsts,cterm,cdesc,cyrlevel,npage,nline

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Aprenticeship Detailed Printing  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        @ 03,01 say replicate("Ä",78)
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
        if ! file(alltrim("c"+cterm+"appp.dbf"))
                fask(10,"  C"+cterm+"APPP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,20 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytappp := "c"+cterm+"appp"
        if(aprv2setup := openwcheck({{,,"c999appp",,_DBF_SHARED,,4},;
                                     {,,cyytappp,"cyytappp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyrlevel  := "4"
        npage := nline := 0
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "               [1, 2, 3, 4, 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!" valid cyrlevel $ "12345"
                @ 05,02 say "               [Y-es, N-o]" color memvar->colorarray[02]
                @ 06,02 say "Last Page  :";
                        color memvar->colorarray[02];
                        get npage pict "999"
                @ 07,02 say "Last Line  :";
                        color memvar->colorarray[02];
                        get nline pict "9999"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||paprendetail(cterm,cdesc,cyrlevel,npage,nline)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function paprendetail(cterm,cdesc,cyrlevel,npage,nline)
local abtext := {},ncol,nmaxcol := 83, nctr := 0
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("ALUMNOS, MAMBALING, CEBU CITY",nmaxcol))+;
                              "ALUMNOS, MAMBALING, CEBU CITY"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("ENROLMENT LIST FOR "+alltrim(cdesc),nmaxcol))+;
                              "ENROLMENT LIST FOR "+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("BACHELOR OF SCIENCE IN MARINE TRANSPORTATION (BSMT)",nmaxcol))+;
                              "BACHELOR OF SCIENCE IN MARINE TRANSPORTATION (BSMT)"})
aadd(abtext,{||""})
aadd(abtext,{||"MARINE TRANSPORTATION "+cyrlevel+" - (Apprentice Mate on Board)"})
aadd(abtext,{||replicate("-",83)})
pageprint(abtext)

c999appp->(sx_setscope(_TOP_SCOPE   ,cyrlevel))
c999appp->(sx_setscope(_BOTTOM_SCOPE,cyrlevel))
c999appp->(dbgotop())
do while ! c999appp->(eof())

        fask(10,"  Printing name "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)

        @ prow()+01,00 say transform(++nline,"@Z 9999")+". "+;
                           c999appp->applname+" "+;
                           c999appp->appfname+" "+;
                           c999appp->appmname+"   "+;
                           "("+c999appp->appidno+")"

        @ prow()+01,06 say if(! empty(c999appp->appprovadd),c999appp->appprovadd,"C/O UC-METC REGISTRAR")

        cyytappp->(sx_setscope(_TOP_SCOPE   ,c999appp->appidno))
        cyytappp->(sx_setscope(_BOTTOM_SCOPE,c999appp->appidno))
        cyytappp->(dbgotop())
        do while ! cyytappp->(eof())

                fask(16,"  Printing vessel "+alltrim(cyytappp->appvesname)+"  ",{" Yes "},memvar->colorarray[06],.f.,nil)
                @ prow(),53 say "Embarkation Date: "+upper(substr(cmonth(appembark),1,3))+" "+transform(day(appembark),"99")+", "+transform(year(appembark),"9999")
                @ prow()+01,06 say "Name of Vessel: "+alltrim(cyytappp->appvesname)
                @ prow(),50 say "Disembarkation Date: "+upper(substr(cmonth(appdembark),1,3))+" "+transform(day(appdembark),"99")+", "+transform(year(appdembark),"9999")
                @ prow()+01,06 say "Proprietor: "+substr(cyytappp->appvesown,1,35)+space(06)+"Gross Tons: "+transform(cyytappp->appgrston,"99999,999.99")
                @ prow()+01,06 say "Vessel Type: "+if(cyytappp->appvestype == "F","Foreign  ","CoastWise")


                if nextkey() == K_ESC
                        exit
                endif
                cyytappp->(dbskip())
        enddo
        cyytappp->(clearscope())
        outexpr(prow()+01,00,replicate("-",83))
        if nextkey() == K_ESC
                exit
        endif
        c999appp->(dbskip())
        if ++nctr == 8
                outexpr(prow()+00,00,chr(18))
                __eject()
                pageprint(abtext)
                nctr := 0
        endif
enddo
c999appp->(clearscope())
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

*------------------------------------------------------------------------------*

static function vcoll(ccode,cprocsts)
if ccode $ "NTMGUC"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 04,23 say space(2)+c999colp->coldesful+space(20)
return(.t.)

*------------------------------------------------------------------------------*

static function vcoll1(ccode,cprocsts)
if ccode $ "NTMG"
        return(.t.)
elseif ! c999colp->(dbseek(ccode))
        vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
@ 07,33 say c999colp->coldesful color memvar->colorarray[02]
return(.t.)


*------------------------------------------------------------------------------*
/*             C  H  A  N  G  E     I  D    N  U  M  B  E  R                  */
*------------------------------------------------------------------------------*
Function changeid()
local alastscr := savescr(01,00,24,79), cterm := space(3), nlastcursor := setcursor()
if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                             {,,"c999sm2p",,_DBF_SHARED,,1},;
                             {,,"c999torp",,_DBF_SHARED,,3},;
                             {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"},;
                             {,,"a999amlp",,_DBF_SHARED,,1,"/arunlib"},;
                             {,,"changeid",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

changeid->(dbgotop())

/* -------------------------------------------------- */
/*                R  E  C  O  R  D  S                 */        
/* -------------------------------------------------- */
do while ! changeid->(eof())
   fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: C999SM1P  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if c999sm1p->(dbseek(changeid->old_id_num))
      c999sm1p->(reclock())
      c999sm1p->sm1idno := changeid->new_id_num
      c999sm1p->(dbcommit())
      c999sm1p->(dbunlock())
   endif

   fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: C999SM2P  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if c999sm2p->(dbseek(changeid->old_id_num))
      c999sm2p->(reclock())
      c999sm2p->sm2idno := changeid->new_id_num
      c999sm2p->(dbcommit())
      c999sm2p->(dbunlock())
   endif

   fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: C999TORP  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   do while c999torp->(dbseek(changeid->old_id_num))
      c999torp->(reclock())
      c999torp->toridno := changeid->new_id_num
      c999torp->(dbcommit())
      c999torp->(dbunlock())
   enddo
/* -------------------------------------------------- */
/*            A  C  C  O  U  N  T  I  N  G            */        
/* -------------------------------------------------- */

   fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: A999ACCP  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if a999accp->(dbseek("1"+changeid->old_id_num))
      a999accp->(reclock())
      a999accp->accidno := "1"+changeid->new_id_num
      a999accp->(dbcommit())
      a999accp->(dbunlock())
   endif

   fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: A999AMLP  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if a999amlp->(dbseek("1"+changeid->old_id_num))
      a999amlp->(reclock())
      a999amlp->amlidno := "1"+changeid->new_id_num
      a999amlp->(dbcommit())
      a999amlp->(dbunlock())
   endif
   changeid->(dbskip())
enddo
closewcheck(aprv2setup)

lconfirm := set(_SET_CONFIRM)
do while .t.
        if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        boxshadow(10,20,14,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"   cyytAPPP.DBF   ")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,22 say "Enter term => ";
                color memvar->colorarray[11];
                get cterm       pict "@!";
                valid ! empty(cterm);
                color memvar->colorarray[11]
       read
       setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
       if lastkey() == 27
          return
       endif
       if ! term->(dbseek(cterm))
               fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("c"+cterm+"enrr.dbf"))
               fask(10,"  C"+cterm+"ENRR.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("c"+cterm+"stsp.dbf"))
               fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("c"+cterm+"flag.dbf"))
               fask(10,"  C"+cterm+"FLAG.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("\arunlib\a"+cterm+"assp.dbf"))
               fask(10,"  A"+cterm+"ASSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("\arunlib\a"+cterm+"payp.dbf"))
               fask(10,"  A"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       if ! file(alltrim("\arunlib\a"+cterm+"prsp.dbf"))
               fask(10,"  A"+cterm+"PRSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
               loop
       endif
       closewcheck(aprv1setup)

       cyytenrp := alltrim("c"+cterm+"enrp.dbf")
       cyytenrr := alltrim("c"+cterm+"enrr.dbf")
       cyytstsp := alltrim("c"+cterm+"stsp.dbf")
       cyytflag := alltrim("c"+cterm+"flag.dbf")
       ayytassp := alltrim("a"+cterm+"assp.dbf")
       ayytpayp := alltrim("a"+cterm+"payp.dbf")
       ayytprsp := alltrim("a"+cterm+"prsp.dbf")
       if(aprv2setup := openwcheck({{,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1},;
                                    {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,1},;
                                    {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1},;
                                    {,, cyytflag ,"cyytflag",_DBF_SHARED,,1},;
                                    {,, ayytassp ,"ayytassp",_DBF_SHARED,,1,"/arunlib"},;
                                    {,, ayytpayp ,"ayytpayp",_DBF_SHARED,,2,"/arunlib"},;
                                    {,, ayytprsp ,"ayytprsp",_DBF_SHARED,,1,"/arunlib"},;
                                    {,,"changeid",,_DBF_SHARED,,1,"/crunlib"}})) == nil
               return(nil)
       endif

       changeid->(dbgotop())
       do while ! changeid->(eof())
          if cyytenrp->(dbseek(changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+cyytenrr+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             cyytenrp->(reclock())
             cyytenrp->enridno := changeid->new_id_num
             cyytenrp->(dbcommit())
             cyytenrp->(dbunlock())
          endif

          do while cyytenrr->(dbseek(changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+cyytenrr+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             cyytenrr->(reclock())
             cyytenrr->enridno := changeid->new_id_num
             cyytenrr->(dbcommit())
             cyytenrr->(dbunlock())
          enddo

          do while cyytstsp->(dbseek(changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+cyytstsp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             cyytstsp->(reclock())
             cyytstsp->stsidno := changeid->new_id_num
             cyytstsp->(dbcommit())
             cyytstsp->(dbunlock())
          enddo

          if cyytflag->(dbseek(changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+cyytflag+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             cyytflag->(reclock())
             cyytflag->enridno := changeid->new_id_num
             cyytflag->(dbcommit())
             cyytflag->(dbunlock())
          endif

          if ayytassp->(dbseek("1"+changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+ayytassp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             ayytassp->(reclock())
             ayytassp->assidno := "1"+changeid->new_id_num
             ayytassp->(dbcommit())
             ayytassp->(dbunlock())
          endif

          do while ayytpayp->(dbseek("1"+changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+ayytpayp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             ayytpayp->(reclock())
             ayytpayp->payidno := "1"+changeid->new_id_num
             ayytpayp->(dbcommit())
             ayytpayp->(dbunlock())
          enddo

          if ayytprsp->(dbseek("1"+changeid->old_id_num))
             fask(10,"  Processing ID Number : "+changeid->old_id_num+"  ;  Filename: "+ayytprsp+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
             ayytprsp->(reclock())
             ayytprsp->prsidno := "1"+changeid->new_id_num
             ayytprsp->(dbcommit())
             ayytprsp->(dbunlock())
          endif

          changeid->(dbskip())
       enddo
       closewcheck(aprv2setup)
enddo

restscr(alastscr)
return(nil)

/*
R E C O R D S           A C C O U N T I N G
c999sm1p->sm1idno       a999accp->accidno
c999sm2p->sm2idno       a999amlp->amlidno
c999torp->toridno       ayytassp->assidno
cyytenrp->enridno       ayytpayp->payidno tags:2&4
cyytenrr->enridno       ayytprsp->prsidno
cyytstsp->stsidno       
cyytflag->enridno
changeid->old_id_num
*/


function gradstuds()
local alastscr := savescr(01,00,24,79), i:=0
        if(aprv2setup := openwcheck({{,,"students",,_DBF_SHARED,,1},;
                                     {,,"c022enrp",,_DBF_SHARED,,1},;
                                     {,,"c999sm1p",,_DBF_SHARED,,2}})) == nil
                return(nil)
        endif

        students->(dbgotop())
        do while ! students->(eof())
                fask(10,"  Processing Student : "+alltrim(students->last_name)+", "+alltrim(students->first_name)+" "+alltrim(students->middle_nam)+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if c999sm1p->(dbseek(students->last_name+students->first_name+students->middle_nam))
                        ++i
                        c022enrp->(dbseek(c999sm1p->sm1idno))
                        c022enrp->(reclock())
                        c022enrp->enrgrad := "*"
                        c022enrp->(dbcommit())
                        c022enrp->(dbunlock())
                endif
                students->(dbskip())
        enddo
        fask(10,"  "+transform(i,"9,999")+" Records found  ",{" Ok "},memvar->colorarray[06],.t.,nil)
        closewcheck(aprv2setup)
        restscr(alastscr)
return(nil)



/*
        G R A D U A T I N G    L I S T
*/

*-------------------------------------------------------------------------------

function grdlstprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp,bprint, cprocsts, cterm, cdesc, aentryscr,;
      ccolcode, cyrlevel, csex, ddate, ccls
private cdummy := "enls"+strzero(memvar->naccess,2),enrheader,enrdetail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Enrollment List Report  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyrlevel := "8"
        ccolcode := "UC"
        csex     := "B"
        ccls     := "A"
        do while .t.
                ddate := ctod("")
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,23 say "[NT-nautical,MG-marine,UC-all course]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid vcollege(ccolcode,cprocsts)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pgrdlstprn(ccolcode,cyrlevel,csex,cdesc,ddate,ccls)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"H"+".TXT"); ccdx := (memvar->cdummy+"H"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"D"+".TXT"); ccdx := (memvar->cdummy+"D"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function pgrdlstprn(ccolcode,cyrlevel,csex,cdesc,ddate,ccls)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      csexdesc,ccourse
private lprocess := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"H",{{"COURSE"  ,"C",02,0},;
                                     {"DESC"    ,"C",35,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"YDESC"   ,"C",11,0}},{||cdxhenr()}) .or.;
   ! createdummy(memvar->cdummy+"D",{{"IDNO"    ,"C",08,0},;
                                     {"COURSE"  ,"C",02,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",24,0},;
                                     {"MNAME"   ,"C",01,0},;
                                     {"LOAD"    ,"N",05,1},;
                                     {"DATEENR" ,"D",08,0}},{||cdxdenr()})
        dbcloseall()
        return(nil)
endif
memvar->enrheader := memvar->cdummy+"H"
memvar->enrdetail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->enrheader+".TXT"),"enrheader",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->enrdetail+".TXT"),"enrdetail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
enrheader->(__dbzap()); enrheader->(dbreindex())
enrdetail->(__dbzap()); enrdetail->(dbreindex())

if csex == "M"
        csexdesc := "MALE"
elseif csex == "F"
        csexdesc := "FEMALE"
else
        csexdesc := "MALE/FEMALE"
endif

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("GRADUATING LIST",nmaxcol))+;
                              "GRADUATING LIST"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(enrheader->desc),nmaxcol))+alltrim(enrheader->desc)})
aadd(abtext,{||space(titlepos(alltrim(enrheader->ydesc)+" - "+alltrim(csexdesc),nmaxcol))+alltrim(enrheader->ydesc)+" - "+alltrim(csexdesc)})
if ! empty(ddate)
        aadd(abtext,{||space(titlepos("Date enrolled => "+displaydate(ddate),nmaxcol))+;
                                      "Date enrolled => "+displaydate(ddate)})
        aadd(abtext,{||""})
else
        aadd(abtext,{||""})
endif
aadd(abtext,{||"         ID NO.     LAST NAME            FIRST NAME         M  LOAD   DATE ENRLD"})
aadd(abtext,{||"       --------  ---------------  ------------------------  -  -----  ----------"})

/*
         ID NO.     LAST NAME            FIRST NAME         M  LOAD    REMARKS
       --------  ---------------  ------------------------  -  -----  ----------
12345. 12345678  123456789012345  123456789012345678901234  1  123.1  WITHDRAWN
*/

*-------------------
*  printing data   *
*-------------------
nctr := 0
enrheader->(dbgotop())
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
do while ! cyytenrp->(eof())
        if cyytenrp->enrgrad == "*"
                c999sm1p->(dbseek(cyytenrp->enridno))
                fask(16,"  Printing student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                             abtext, prow() + 1, _MAX_LINE, {||__eject()})
                outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                                     c999sm1p->sm1idno+space(02)+;
                                     c999sm1p->sm1lstnam+space(02)+;
                                     c999sm1p->sm1fstnam+space(02)+;
                                     c999sm1p->sm1midnam+space(02))
//                                     transform(enrdetail->load,"999.9")+space(02)+;
//                                     dtoc(enrdetail->dateenr))
                if nextkey() == K_ESC
                        exit
                endif
        endif
        cyytenrp->(dbskip())
        outexpr(prow()+01,00,chr(18))
        __eject()
        npage := nctr := 0
enddo
closewcheck(afile)
return(nil)


*-------------------------------------------------------------------------------

function plotsked()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp, cyytenrr, cyytskdp, cprocsts, aentryscr,;
      cterm,cdesc
private cdummy := "rom"+strzero(memvar->naccess,2),roomfile, cidno

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
memvar->cidno := space(8)
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Plot Schedule  ")
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
                                     {,, cyytenrr,"cyytenrr",_DBF_SHARED,,1},;
                                     {,,"c999rmsk",,_DBF_SHARED,,1},;
                                     {,, cyytskdp,"cyytskdp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 04,02 say "Student No.  :";
                color memvar->colorarray[02];
                get memvar->cidno       pict "@!";
                valid ! empty(memvar->cidno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if whereprint({||pplotsked(memvar->cidno)}) == 1
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

static function pplotsked(cidno)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0
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

cyytenrr->(sx_setscope(_TOP_SCOPE   ,memvar->cidno))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,memvar->cidno))

cyytenrr->(dbsetrelation("cyytskdp",{||cyytenrr->enridno},"cyytenrr->enridno"))

cyytenrr->(dbgotop())
do while ! cyytenrr->(eof())
       cyytskdp->(dbseek(cyytenrr->enrskdcod))
//       fask(10,"  "+cyytskdp->skdcod+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
       for daycounter := 1 to 7
           if substr(cyytskdp->skddayx,daycounter,1) =="X"
               num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
               num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
               xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
               xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
               lapse := (xendtime - xbegtime)/0.5

//               fask(10,"  "+cyytenrr->enridno+transform(daycounter,"9")+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

               if ! detail->(dbseek(cyytenrr->enridno+transform(daycounter,"9")))
                   detail->(dbappend())
                   detail->idno   := cidno
                   detail->daynum := transform(daycounter,"9")
                   detail->rmtime := space(31)
               else
                   detail->(reclock())
               endif
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if substr(detail->rmtime,counter+1,1) != "Ü"
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"Ü")
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
   cyytenrr->(dbskip())
enddo

cyytskdp->(clearscope())

** Printing Data **
element := 0
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
return(nil)

function stdlstprn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrp,bprint, cprocsts, cterm, cdesc, aentryscr,;
      ccolcode, cyrlevel, csex, ddate, ccls, npageno:=0, clname, cfname
private cdummy := "enls"+strzero(memvar->naccess,2),enrheader,enrdetail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  STUDENT LIST FOR MAILING  ")
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
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,21 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := alltrim("c"+cterm+"enrp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytenrp,"cyytenrp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        clname := space(len(c999sm1p->sm1lstnam))
        cfname := space(len(c999sm1p->sm1fstnam))
        @ 03,02 say "Starting Page:";
                color memvar->colorarray[02];
                get npageno
        @ 04,02 say "Last Name  :";
                color memvar->colorarray[02];
                get clname pict "@!"
        @ 05,02 say "First Name :";
                color memvar->colorarray[02];
                get cfname pict "@!"
       read
        if whereprint({||pstdlstprn(cdesc,ddate,ccls,npageno,clname,cfname)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aprv2setup)
enddo
cfile := (memvar->cdummy+"H"+".TXT"); ccdx := (memvar->cdummy+"H"+".CDX")
ferase(cfile);ferase(ccdx)
cfile := (memvar->cdummy+"D"+".TXT"); ccdx := (memvar->cdummy+"D"+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
closewcheck(aprv1setup)

return(nil)

static function pstdlstprn(cdesc,ddate,ccls,npageno,clname,cfname)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      csexdesc, ccourse, ncntr := 0
private lprocess := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"H",{{"COURSE"  ,"C",02,0},;
                                     {"DESC"    ,"C",35,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"YDESC"   ,"C",11,0}},{||cdxhenr()}) .or.;
   ! createdummy(memvar->cdummy+"D",{{"IDNO"    ,"C",08,0},;
                                     {"COURSE"  ,"C",02,0},;
                                     {"YEAR"    ,"C",01,0},;
                                     {"LNAME"   ,"C",15,0},;
                                     {"FNAME"   ,"C",24,0},;
                                     {"MNAME"   ,"C",01,0},;
                                     {"LOAD"    ,"N",05,1},;
                                     {"DATEENR" ,"D",08,0}},{||cdxdenr()})
        dbcloseall()
        return(nil)
endif
memvar->enrheader := memvar->cdummy+"H"
memvar->enrdetail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->enrheader+".TXT"),"enrheader",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->enrdetail+".TXT"),"enrdetail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
enrheader->(__dbzap()); enrheader->(dbreindex())
enrdetail->(__dbzap()); enrdetail->(dbreindex())

ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("STUDENT LIST FOR MAILING",nmaxcol))+;
                              "STUDENT LIST FOR MAILING"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
if ! empty(ddate)
        aadd(abtext,{||space(titlepos("Date enrolled => "+displaydate(ddate),nmaxcol))+;
                                      "Date enrolled => "+displaydate(ddate)})
        aadd(abtext,{||""})
else
        aadd(abtext,{||""})
endif
aadd(abtext,{||"         ID NO.     LAST NAME            FIRST NAME         M  REMARKS   "})
aadd(abtext,{||"       --------  ---------------  ------------------------  -  ----------"})

/*
         ID NO.     LAST NAME            FIRST NAME         REMARKS
       --------  ---------------  ------------------------  ----------
12345. 12345678  123456789012345  123456789012345678901234  WITHDRAWN
*/

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing name "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if cyytenrp->enrconfirm == "*"
                enrdetail->(dbappend())
                enrdetail->idno         := c999sm1p->sm1idno
                enrdetail->course       := cyytenrp->enrcolcod
                enrdetail->lname        := c999sm1p->sm1lstnam
                enrdetail->fname        := c999sm1p->sm1fstnam
                enrdetail->mname        := c999sm1p->sm1midnam
                enrdetail->year         := cyytenrp->enryrlevl
                enrdetail->load         := cyytenrp->enrunt
                enrdetail->dateenr      := cyytenrp->enrdte
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*-------------------
*  printing data   *
*-------------------
nctr := 0
if npageno>0
        npage := npageno-1
        nctr  := (npageno-1)*50
endif
enrdetail->(sx_settagorder(2))
enrheader->(dbgotop())
enrdetail->(dbgotop())
pageeject(_PAGE_FIRST, ;
                abtext, prow() + 1, _MAX_LINE, {||__eject()})
do while ! enrdetail->(eof())
//        fask(10,"  "+alltrim(enrdetail->lname)+alltrim(enrdetail->fname)+";  "+alltrim(clname)+alltrim(cfname)+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! empty(enrdetail->idno)
        if ((alltrim(enrdetail->lname)+alltrim(enrdetail->fname)) > (alltrim(clname)+alltrim(cfname))) .or. npageno == 0
                fask(16,"  Printing student "+alltrim(enrdetail->lname)+", "+alltrim(enrdetail->fname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                        abtext, prow() + 1, _MAX_LINE, {||__eject()})
                outexpr(prow()+01,00,transform(++nctr,"99999")+"."+space(01)+;
                        enrdetail->idno+space(02)+;
                        enrdetail->lname+space(02)+;
                        enrdetail->fname+space(02)+;
                        enrdetail->mname+space(02)+;
                        "__________")
//                        transform(enrdetail->load,"999.9")+space(02)+;
//                        dtoc(enrdetail->dateenr))
        endif
        endif
        if nextkey() == K_ESC
                exit
        endif
        enrdetail->(dbskip())
enddo
closewcheck(afile)
return(nil)

*-------------------------------------------------------------------------------

function apprenstats()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, bprint, cprocsts, cterm, pterm, cdesc, pdesc, aentryscr,;
      dater, c_date, temp_term := space(5), test_term := space(5), nmainmt, nmainmm

private cdummy := "stat"+strzero(memvar->naccess,2), header, detail

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
pterm := space(len(term->code))
nmainmt := 0
nmainmm := 0
aentryscr := savescr(01,00,24,79)
do while .t.
        clearbuffer()
        restscr(aentryscr)
        boxshadow(01,00,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Apprenticeship Enrollment Statistics w/ Comparison Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
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
        @ 03,02 say "Previous Term  :";
                color memvar->colorarray[02];
                get pterm pict "@!";
                valid ! empty(cterm)
        @ 05,02 say "Current Date   :";
                color memvar->colorarray[02];
                get c_date ;
                valid ! empty(c_date)
        if isleap(c_date)
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)+1))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        else
        dater := ctod(alltrim(str(month (c_date)))+"/"+;
                      alltrim(str(day   (c_date)+2))+"/"+;
                      alltrim(str(year  (c_date)-1)))
        endif
        @ 06,02 say "Previous Date  :";
                color memvar->colorarray[02];
                get dater ;
                valid ! empty(dater)

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
        if ! term->(dbseek(pterm))
                fask(10,"  School term "+pterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        else
                pdesc := term->name
        endif
        @ 03,23 say "- "+term->name
        @ 05,30 say "- "+cmonth(c_date) +" "+transform(day(c_date),"99") + ", " + ;
                           transform(year(c_date),"9999") +"  "+ cdow(c_date)
        @ 06,30 say "- "+cmonth(dater) +" "+transform(day(dater),"99") + ", " + ;
                           transform(year(dater),"9999") +"  "+ cdow(dater)
        term->(dbseek(cterm))
        @ 02,23 say "- "+term->name

        if(aprv2setup := openwcheck({{,,"c999appp",,_DBF_SHARED,,6},;
                                     {,,"c999colp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||papprenstats(cdesc,cterm,pterm,c_date,dater)}) == 1
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

static function papprenstats(cdesc,cterm,pterm,c_date,dater)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0,;
      nall,record_no,nTotal,nTotLstYr,nDiff,nPercent,nPer,;
      nlst_yr,counter,out_text := space(255),out_text2 := space(255),diff,;
      nEnrToday,nsex

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"SEX"         ,"N",04,0},;
                                     {"TOTAL"       ,"N",04,0},;
                                     {"TERM"        ,"C",01,0}},{||cdxdstat1()}) .or. ;
   ! createdummy(memvar->cdummy+"P",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0},;
                                     {"TOTAL"       ,"N",04,0},;
                                     {"TERM"        ,"C",01,0}},{||cdxdstat1()}) .or. ;
   ! createdummy(memvar->cdummy+"H",{{"COLCODE"     ,"C",02,0},;
                                     {"COLDESC"     ,"C",13,0}},{||cdxhstats1()})
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
aadd(abtext,{||"Time: "+Time()+space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol)-14)+;
                                              "Alumnos, Mambaling, Cebu City"+space(16)})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("APPRENTICESHIP ENROLLMENT STATISTICS",nmaxcol))+;
                              "APPRENTICESHIP ENROLLMENT STATISTICS"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("Present:"+dtoc(c_date)+" - "+"Previous:"+dtoc(dater),nmaxcol))+"Present:"+dtoc(c_date)+"-"+"Previous:"+dtoc(dater)})
aadd(abtext,{||""})
aadd(abtext,{||"--------------------------------------------------------------------------------"})
aadd(abtext,{||space(13)+"COLLEGE COURSE    TOTAL   LST YR    DIFF  %(INC/DEC)"})
aadd(abtext,{||space(13)+"==============  =======  =======  ======  =========="})
aadd(abtext,{||""})

nEnrToday := 0
nSEX := 0

c999appp->(sx_setscope(_TOP_SCOPE   ,cterm))
c999appp->(sx_setscope(_BOTTOM_SCOPE,cterm))
c999appp->(dbgotop())
do while ! c999appp->(eof())
        fask(10," Processing Term : "+cterm + "; ID number :"+alltrim(c999appp->appidno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (c999appp->appdate <= c_date)
           if c999appp->appdate==c_date
                nEnrToday += 1
           endif
           if c999appp->appsex == "F"
                nsex += 1
           endif
                if detail->(dbseek(c999appp->appcourse))
                        detail->(reclock())
                        detail->total += 1
                else
                        detail->(dbappend())
                        c999colp->(dbseek(c999appp->appcourse))
                        detail->colcode := c999appp->appcourse
                        detail->coldesc := alltrim(c999colp->coldesabr)+if(c999appp->appcourse == "PA","-ALPHA",;
                                                                        if(c999appp->appcourse == "MP","-ALPHA",;
                                                                        if(c999appp->appcourse == "MR","-NSA",;
                                                                        if(c999appp->appcourse == "MI","-NSA",space(06)))))
                        if ! header->(dbseek(detail->coldesc + detail->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(c999appp->appcourse == "PA","-ALPHA",;
                                                                                if(c999appp->appcourse == "MP","-ALPHA",;
                                                                                if(c999appp->appcourse == "MR","-NSA",;
                                                                                if(c999appp->appcourse == "MI","-NSA",space(06)))))
                                header->colcode := detail->colcode
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
        c999appp->(dbskip())
enddo
c999appp->(clearscope())



// Previous comparison

c999appp->(sx_setscope(_TOP_SCOPE   ,pterm))
c999appp->(sx_setscope(_BOTTOM_SCOPE,pterm))
c999appp->(dbgotop())
do while ! c999appp->(eof())
        fask(10," Processing Term : "+pterm + "; ID number :"+alltrim(c999appp->appidno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (c999appp->appdate <= dater)
                if previous->(dbseek(c999appp->appcourse))
                        previous->(reclock())
                        previous->total += 1
                else
                        previous->(dbappend())
                        c999colp->(dbseek(c999appp->appcourse))
                        previous->colcode := c999appp->appcourse
                        previous->coldesc := alltrim(c999colp->coldesabr)+if(c999appp->appcourse == "PA","-ALPHA",;
                                                                        if(c999appp->appcourse == "MP","-ALPHA",;
                                                                        if(c999appp->appcourse == "MR","-NSA",;
                                                                        if(c999appp->appcourse == "MI","-NSA",space(06)))))
                        if ! header->(dbseek(previous->coldesc+previous->colcode))
                                header->(dbappend())
                                header->coldesc := alltrim(c999colp->coldesabr)+if(c999appp->appcourse == "PA","-ALPHA",;
                                                                                if(c999appp->appcourse == "MP","-ALPHA",;
                                                                                if(c999appp->appcourse == "MR","-NSA",;
                                                                                if(c999appp->appcourse == "MI","-NSA",space(06)))))
                                header->colcode := previous->colcode
                                header->(dbcommit())
                                header->(dbunlock())

                                detail->(dbappend())
                                detail->colcode := previous->colcode
                                detail->coldesc := previous->coldesc
                        endif
                        previous->term := "P"
                endif
                previous->(dbcommit())
                previous->(dbunlock())
        endif
        if nextkey() == K_ESC
                exit
        endif
        c999appp->(dbskip())
enddo
c999appp->(clearscope())


*-----------------
*/  printing    /*
*-----------------
nTotal := nTotLstYr := nDiff := nall := ;
nMVBSMT := nMMBSMARE := nMIBSMTNSA := nMRBSMARENSA := nCS := nMRO :=;
nlMVBSMT := nlMMBSMARE := nlMIBSMTNSA := nlMRBSMARENSA := nlCS := nlMRO :=;
ndiffsj := ntpersj := 0


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
        out_text3 := ""

        nlst_yr := diff := nall := 0
        nNlst_yr := nNdiff := nNall := 0

//        for counter := 1 to 4
           if previous->(dbseek(header->colcode))
                nlst_yr += previous->total
           endif


           if detail->(dbseek(header->colcode))
                fask(10,"  Printing course "+alltrim(detail->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                out_text2 := out_text2 + transform((detail->total),"9,999")+space(02)

                        nall  += (detail->total)

               if header->colcode == "MV"
                    nMVBSMT += detail->total
               elseif header->colcode == "MM"
                    nMMBSMARE += detail->total
               elseif header->colcode == "MI"
                    nMIBSMTNSA += detail->total
               elseif header->colcode == "MR"
                    nMRBSMARENSA += detail->total
               elseif header->colcode == "CS"
                    nCS += detail->total
               elseif header->colcode == "RO"
                    nMRO += detail->total
               endif

           else
                out_text2 := out_text2 + transform(0,"9,999")+space(02)
           endif

           detail->(dbskip())
//        next


        ndiffsj := (nMVBSMT+nMMBSMARE+nMIBSMTNSA+nMRBSMARENSA+nCS+nMRO)-;
                   (nlMVBSMT+nlMMBSMARE+nlMIBSMTNSA+nlMRBSMARENSA+nlCS+nlMRO)
        npersj := (ndiffsj / (nlMVBSMT+nlMMBSMARE+nlMIBSMTNSA+nlMRBSMARENSA+nlCS+nlMRO))*100

        diff := nall-nlst_yr
        ndiff += diff
        nPer := (diff/nlst_yr)*100
        nTotal += nall
        nTotLstYr +=nlst_yr
        nPercent := (nDiff/nTotlstYr)*100

        out_text := space(13) + out_text + out_text2 + space(2) + ;
                    transform(nlst_yr,"999,999") + space(1) + transform(diff,"999,999") + space(4) + transform(nPer,"9999.99")+"%"
        outexpr(prow()+01,00,out_text)
        header->(dbskip())
enddo
        outexpr(prow()+01,00,replicate("-",80))
        outexpr(prow()+01,00,space(13) + "TOTALS        "+ transform(nTotal,     "999,999") + space(4) + ;
                                                 transform(nTotlstYr,  "999,999") + space(01) + ;
                                                 transform(nDiff,      "999,999") + space(04) + ;
                                                 transform(nPercent,   "9999.99") + "%")

outexpr(prow()+01,00,replicate("Ä",80))

outexpr(prow()+01,00,"Total Apprentice    : "+transform(nTotal,"999,999"))
outexpr(prow()+01,00,"Total Female        : "+transform(nsex,"999,999"))
outexpr(prow()+02,00,"Enrolled Today      : "+transform(nEnrToday,"999,999"))
outexpr(prow()+04,00,"Prepared by:                                      Noted by:")
outexpr(prow()+03,00,"MARINES D. ROMANO                                 JOVITA A. QUI¥ANOLA")
outexpr(prow()+01,00,"Records Clerk                                     Registrar (METC)")
outexpr(prow()+01,00,chr(18))
__eject()

closewcheck(afile)
return(nil)

static function cdxhstat1()
field colcode,coldesc
private cdummyfile := alias()
index on coldesc tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on colcode tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)


static function cdxdstat1()
field colcode,coldesc,term
private cdummyfile := alias()
index on colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on coldesc tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
index on colcode+term tag (memvar->cdummyfile+"3") of (memvar->cdummyfile)
return(nil)

static function cdxhstats1()
field colcode,coldesc
private cdummyfile := alias()
index on coldesc+colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
index on colcode tag (memvar->cdummyfile+"2") of (memvar->cdummyfile)
return(nil)

*-------------------------------------------------------------------------------

