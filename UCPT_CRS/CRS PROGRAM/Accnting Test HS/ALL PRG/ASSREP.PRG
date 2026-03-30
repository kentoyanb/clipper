* Program       :  ASSREP.PRG
* Author        :  Randy F. Santizo (rb) February 1999
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*

function displayassessment()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,cprocsts,nctr,aentryscr,cyytassp,;
      cterm,oacct

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Students Assessment  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
cterm := space(len(term->code))
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
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
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+cterm+"assp.dbf"))
                fask(10,"  A"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ayytassp := "a"+cterm+"assp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        oacct := a999accp->(createbrowse(06,01,22,78,;
                {|xnmode,xacfields,xobrowser,xaxparam|faccount(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+accidno+' '","' '+acclname+', '+accfname+' '+accmname+' '","' '+acccolcod+' '","' '+accyrlevl+' '","transform(accbaltot,'@Z 999,999.99')+' '"},;
                {"  Account# ", "              Student Name                   ", " CC ", "YrL", " Balances  "},;
                {"ÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ"}))
*                 x123456789x    x123456789012345, 123456789012345678901234 1x    x11x    x1x    123,123.12x
        commandline("³          Ù - View Assessment        ³         ESC - Previous                ³")
        @ 03,01 say replicate("Ä",78)
        @ 05,01 say replicate("Ä",78)
        a999accp->(browsefile(oacct,{"",""},{|b|b:gotop()}))
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

static function faccount(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 04,02 say space(30)
                @ 04,02 say "Search key:" color memvar->colorarray[02]
                @ 04,15 say axparam[01]
                return 1
        case lastkey() == K_ENTER
                displayamount(obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                *axparam[01]:=axparam[01]+chr(lastkey())
                *dynamicseacrh(axparam[02]+axparam[01],obrowser)
                dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2

static function displayamount(obrowser)
local alastscr := savescr(01,00,24,79), cexit := "",;
      nlastcursor := setcursor(), lconfirm := set(_SET_CONFIRM),;
      cfeeyr := "", nfeeperunit := 0, ntotunits := 0,;
      nregfee := 0, ntuifee := 0, nmisfee := 0, nlabfee := 0, ntotamt := 0
*boxshadow(04,20,21,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[06],"  Assessment  ")
commandline("³                               ESC - Previous                                 ³")
if ayytassp->(dbseek(a999accp->accidno))
        cfeeyr          := ayytassp->assfeeyr
        nfeeperunit     := ayytassp->assfeeunt
        ntotunits       := ayytassp->assunt
        nregfee         := ayytassp->assreg
        ntuifee         := ayytassp->asstui
        nmisfee         := ayytassp->assmisc
        nlabfee         := ayytassp->asslab
        ntotamt         := ayytassp->asstotal
endif
draw_box2(03,20,05,60,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 04,31 say "A s s e s s m e n t" color memvar->colorarray[33]
draw_box1(06,20,22,60,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 07,22 say "Fee Year          : "+cfeeyr color memvar->colorarray[33]
@ 09,22 say "Fee Per Unit      : "+ltrim(transform(nfeeperunit,"999,999.99")) color memvar->colorarray[33]
@ 11,22 say "Total Units       : "+ltrim(transform(ntotunits,"999.9")) color memvar->colorarray[33]
@ 13,22 say "Tuition Fee       : "+ltrim(transform(ntuifee,"999,999.99")) color memvar->colorarray[33]
@ 15,22 say "Registration Fee  : "+ltrim(transform(nregfee,"999,999.99")) color memvar->colorarray[33]
@ 17,22 say "Miscellaneous Fee : "+ltrim(transform(nmisfee,"999,999.99")) color memvar->colorarray[33]
@ 19,22 say "Laboratory Fee    : "+ltrim(transform(nlabfee,"999,999.99")) color memvar->colorarray[33]
@ 21,22 say "Total Amount      : "+ltrim(transform(ntotamt,"999,999.99")) color memvar->colorarray[33]
cexit := " "
do while .t.
        @ 24,78 get cexit pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
enddo
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function assessnotice()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopen1files,aopen2files,cprocsts,cterm,cdesc,ccolcode,cyrlevel,aentryscr,;
      cfile,ccdx,clname,cfname,cyytenrp,ayytpayp,ayytassp

private cdummy := "ass"+strzero(memvar->naccess,2), assnotice

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Assessment Notice Report  ")
        commandline("³           F4 - View Term             ³              ESC - Previous           ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
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
        if ! file("\crunlib\c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  A"+cterm+"PAYP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  A"+cterm+"ASSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,23 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := alltrim("c"+cterm+"enrp")
        ayytpayp  := "a"+cterm+"payp"
        ayytassp  := "a"+cterm+"assp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        cyrlevel := space(01)
        clname   := space(15)
        cfname   := space(24)
        do while .t.
                restscr(aentryscr)
                commandline("³         F4 - View College File       ³           ESC - Previous              ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                *setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!"
                @ 04,02 say "                 [1 2 3 4 5]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "12345"
                @ 05,02 say "Student name last printed:" color memvar->colorarray[02]
                @ 06,02 say "     Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "     First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||passessnotice(cterm,cdesc,ccolcode,cyrlevel,cfname,clname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)



static function passessnotice(cterm,cdesc,ccolcode,cyrlevel,cfname,clname)
local abtext := {},ncol,nmaxcol := 140, npage := 0,afile, namt := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",12,0},;
                                 {"AMOUNT"      ,"N",12,2},;
                                 {"YEAR"        ,"C",01,0}},{||cdxassess()})
        dbcloseall()
        return(nil)
endif
memvar->assnotice := memvar->cdummy
if(afile := openwcheck({{,,(memvar->assnotice+".TXT"),"assessment",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
assessment->(__dbzap());assessment->(dbreindex())
cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+cyrlevel))
cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+cyrlevel))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing id no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        namt := 0
        if ! cyytenrp->enrenrst $ "VW"

                if ayytassp->(dbseek("1"+cyytenrp->enridno))
                        namt += ayytassp->asstotal
                endif

                ayytpayp->(sx_setscope(_TOP_SCOPE   ,"1"+cyytenrp->enridno))
                ayytpayp->(sx_setscope(_BOTTOM_SCOPE,"1"+cyytenrp->enridno))
                ayytpayp->(dbgotop())
                do while ! ayytpayp->(eof())
                        fask(16," Processing trx# "+alltrim(ayytpayp->payrefno)+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        do case
                                case ayytpayp->paytag == _POSTED
                                        namt -= ayytpayp->payamt
                                case ayytpayp->paytag == _DISCOUNT
                                        namt -= ayytpayp->payamt
                                case ayytpayp->paytag == _SHORT_TERM
                                        namt += ayytpayp->payamt
                                case ayytpayp->paytag == _ADJUSTMENT
                                        namt += ayytpayp->payamt
                                case ayytpayp->paytag == _FORWARDED
                                        namt += ayytpayp->payamt
                        endcase
                        if nextkey() == K_ESC
                                exit
                        endif
                        ayytpayp->(dbskip())
                enddo
                ayytpayp->(clearscope())

                if namt > 99.99
                        a999accp->(dbseek("1"+cyytenrp->enridno))
                        c999colp->(dbseek(cyytenrp->enrcolcod))
                        assessment->(dbappend())
                        assessment->idno        := cyytenrp->enridno
                        assessment->lname       := a999accp->acclname
                        assessment->fname       := a999accp->accfname
                        assessment->mname       := a999accp->accmname
                        assessment->year        := cyytenrp->enryrlevl
                        assessment->course      := c999colp->coldesabr
                        assessment->amount      := namt
                        if ccolcode $ "MI,MR"
                                assessment->course := alltrim(assessment->course)+"-NIS  "
                        elseif ccolcode $ "PA,MP"
                                assessment->course := alltrim(assessment->course)+"-ALPHA"
                        endif
                endif
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())

assessment->(dbgotop())
do while ! assessment->(eof())
        fask(10,"  Printing student "+alltrim(assessment->lname)+", "+alltrim(assessment->fname)+" "+alltrim(assessment->mname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if clname+cfname < assessment->lname+assessment->fname
                @ 04,19 say "E          UNIVERSITY OF CEBU          "
                @ 05,19 say "Maritime Education and Training Center"
                @ 06,19 say "    Alumnos, Mambaling, Cebu City     "
                @ 07,19 say "            Tel# 261-9963             "

                @ 10,05 say cmonth(date())+str(day(date()))+","+str(year(date()))
                @ 13,05 say "Dear Parents/Guardian:"
                @ 16,10 say "Greetings!"
                @ 18,10 say "This is to inform you that Cdt. "+alltrim(assessment->lname)+", "+alltrim(assessment->fname)+" "+assessment->mname+" ("+assessment->idno+"), "
                @ 19,05 say alltrim(assessment->course)+"-"+assessment->year+".   "+"Has a remaining balance of =P= "+alltrim(transform(assessment->amount,"999,999.99"))+"  for this"
                @ 20,05 say valyyt(cterm,cdesc)+"."
                @ 22,10 say "Please settle your remaining balance.  Disregard this notice"
                @ 23,05 say "if you have already paid this Amount."

                @ 27,50 say "NENA T. DURAN"
                @ 28,50 say "Head - SAS Dept."
                @ 33,05 say "UC-METC/SAC.DOC./010/REV.00"
                @ 44,01 say space(01)
                setprc(00,-1)
        endif
        if nextkey() == K_ESC
                exit
        endif
        assessment->(dbskip())
enddo
closewcheck(afile)
return(nil)


static function valyyt(cterm,cdesc)
local wrktrm := right(cterm,1),;
      schtrm,cyear
do case
        case wrktrm == "1"
                schtrm := "1st Semester, School Year "+alltrim(substr(cdesc,13))
        case wrktrm == "2"
                schtrm := "2nd Semester, School Year "+alltrim(substr(cdesc,13))
        case wrktrm == "4"
                schtrm := "S U M M E R, School Year "+alltrim(substr(cdesc,7))
end case
Return(schtrm)

static function cdxassess()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

function assbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopen1files,aopen2files,cprocsts,cterm,cdesc,ccolcode,cyrlevel,aentryscr,;
      cfile,ccdx,clname,cfname,cyytenrp,ayytpayp,ayytassp
return(nil)
