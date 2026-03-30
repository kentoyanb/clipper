* Program       :  SCHOLREP.PRG
* Author        :  Randy F. Santizo (rb) February 1999
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*

#define _P_ACCTNO       1
#define _P_LNAME        2
#define _P_FNAME        3
#define _P_MNAME        4
#define _P_COURSE       5
#define _P_PERCENT      6
#define _P_AMOUNT       7
#define _X_COURSE       8
#define _P_EMPTY        {space(09),space(15),space(24),space(01),;
                         space(08),space(03),0,space(06)}
function studprivilege()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,oscholar,bindex,bitems,;
      ayytprsp,cfile,ccdx,cnotedby:=cdesgn:=space(35)
private aitems := {},nindex,cterm,cdesc,cprivcode,ntotalamt,nctr,cprivdesc,;
        cdummy := "priv"+strzero(memvar->naccess,2),privilege,summary,cstud

bindex   := memvarblock("NINDEX")
bitems   := memvarblock("AITEMS")
oscholar := createabrowse(bitems,bindex,06,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fstdpriv(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitems[memvar->nindex,_P_ACCTNO]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_LNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_FNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_MNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_COURSE]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_PERCENT]},nil},;
                         {{||transform(memvar->aitems[memvar->nindex,_P_AMOUNT],"9,999,999.99")},nil}},;
                        {"Account #", "   Last Name   ", "       First Name       ", "M", " Course ", " % ", "  Amount  "},;
                        {"ÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ"})
                      *   123456789    123456789012345    123456789012345678901234    1    123456-1    123    123,123.12

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Students Receiving Privilege for Basic Ed ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        initfiles()
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"a999stcp",,_DBF_SHARED,,1},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,2},;
                                      {,,(memvar->privilege+".TXT"),"privilege",_DBF_EXCLUSIVE,,1},;
                                      {,,(memvar->summary+".TXT"),"summary",_DBF_EXCLUSIVE,,1}})) == nil
                return(nil)
        endif
        memvar->cprivcode := space(len(a999prcp->prccode))
        memvar->cstud := "A"
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View Privilege         ³           ESC - Previous              ³")
                setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Privilege Code :";
                        color memvar->colorarray[02];
                        get memvar->cprivcode pict "@!";
                        valid ! empty(memvar->cprivcode)
                
                @ 05,02 say "                     [S-Senior High, J-Junior High, E-Elementary, A-ALL]" color memvar->colorarray[02]
                @ 05,02 say "Courses :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "SJEA"
                
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999prcp->(dbseek(memvar->cprivcode))
                        fask(10,"  Privilege code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                @ 04,24 say "- "+a999prcp->prcdescr
                memvar->cprivdesc := a999prcp->prcdescr
                memvar->aitems := {_P_EMPTY}
                memvar->nindex := 1
                privilege->(__dbzap()); privilege->(dbreindex())
                summary->(__dbzap()); summary->(dbreindex())
                processprivilege()
                dispbox(05,01,21,78,_SINGLE_LINE)
                connectline(07,01,78)
                commandline("³ F6 - Print Student Privilege ³ F10 - Print Students Billing ³ ESC - Previous ³")
                @ 22,02 say "                        "+ltrim(transform(memvar->nctr,"9999"))
                @ 22,02 say "Total No. of Students : " color memvar->colorarray[02]
                @ 22,51 say "               "+transform(memvar->ntotalamt,"9,999,999.99")
                @ 22,51 say "Total Amount : " color memvar->colorarray[02]
                stabilize(oscholar,.t.)
                browsearray(oscholar,{""},{|b|b:gotop()})
        enddo
        closewcheck(aopen2files)
        cfile := (memvar->cdummy+"P"+".TXT"); ccdx := (memvar->cdummy+"P"+".CDX")
        ferase(cfile);ferase(ccdx)
        cfile := (memvar->cdummy+"S"+".TXT"); ccdx := (memvar->cdummy+"S"+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function fstdpriv(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_F6
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pstudpriv()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pstudbilling()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function processprivilege()
local nlastelem,nctr1,cpercent
memvar->ntotalamt := memvar->nctr := 0

ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cprivcode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cprivcode))

ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        a999accp->(dbseek(ayytprsp->prsidno))
    //TRAP PARA MO DISPLAY KY MGA BASIC ED codes  RA
    if memvar->cstud == "S" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM" .or. ;
      memvar->cstud == "J" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "G7,G8,G9,GA" .or. ;
      memvar->cstud == "E" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6" .or. ;
      memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" 

   
        fask(10,"  Processing student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := ayytprsp->prsidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname

        c999colp->(dbseek(ayytprsp->prscolcod))
        memvar->aitems[nlastelem,_P_COURSE]     := alltrim(c999colp->coldesabr)
        memvar->aitems[nlastelem,_X_COURSE]     := alltrim(c999colp->coldesabr)

        /*if   c999colp->(dbseek(ayytprsp->prscolcod))
                memvar->aitems[nlastelem,_P_COURSE]     := alltrim(c999colp->coldesabr)
                memvar->aitems[nlastelem,_X_COURSE]     := alltrim(c999colp->coldesabr)
        else
           a999stcp->(dbseek(ayytprsp->prscolcod))
                memvar->aitems[nlastelem,_P_COURSE]     := alltrim(a999stcp->stcdesabr)
                memvar->aitems[nlastelem,_X_COURSE]     := alltrim(a999stcp->stcdesabr)
        endif*/

        if ayytprsp->prstuipdsc > 0
                memvar->aitems[nlastelem,_P_PERCENT]      := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
                cpercent := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
        else
                memvar->aitems[nlastelem,_P_PERCENT]      := " FF"
                cpercent := " FF"
        endif

        memvar->aitems[nlastelem,_P_AMOUNT]     := ayytprsp->prstuiadsc

        memvar->ntotalamt += ayytprsp->prstuiadsc
        ++memvar->nctr


        if ! privilege->(dbseek(cpercent+alltrim(c999colp->coldesabr)))
                privilege->(dbappend())
                privilege->percent      := cpercent
                privilege->course       := alltrim(c999colp->coldesabr)
        endif

       

        if ! summary->(dbseek(cpercent))
                summary->(dbappend())
                summary->percent        := cpercent
        endif


   endif
        if nextkey() == K_ESC
                exit
        endif
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())

if len(memvar->aitems) > 1
        for nctr1 := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr1,_P_ACCTNO])
                        adel(memvar->aitems,nctr1)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
asort(memvar->aitems,,,{|a,b|a[_P_LNAME]+a[_P_FNAME]<b[_P_LNAME]+b[_P_FNAME]})
return(nil)


static function pstudpriv()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0, nline := 0,;
      npagetotal := 0, ngrandtotal := 0, namt := 0, nstud := 0, privcourse := space(8)
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-14)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos(alltrim(a999prcp->prcdescr),nmaxcol))+alltrim(a999prcp->prcdescr)})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"      Account#    Last Name          First Name         M  Course   %    Amount  "})
aadd(abtext,{||"     --------- --------------- ------------------------ - -------- --- ----------"})

/*
      Account#    Last Name          First Name         M  Course   %    Amount
     --------- --------------- ------------------------ - -------- --- ----------
123. 123456789 123456789012345 123456789012345678901234 1 12345678 123 123,123.12
                                                                       ----------
                                                         Page Total -> 123,123.12
                                                      Running Total -> 123,123.12
                                                        Grand Total -> 123,123.12


*/

pageprint(abtext)
//privilege->(dbgobottom())
//do while ! privilege->(bof())
privilege->(dbgotop())
do while ! privilege->(eof())
        for nctr := 1 to len(memvar->aitems)
                privcourse := privilege->course
                fask(10," Printing name "+alltrim(memvar->aitems[nctr,_P_LNAME])+", "+alltrim(memvar->aitems[nctr,_P_FNAME])+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if privilege->percent == memvar->aitems[nctr,_P_PERCENT] .and. ;
                   memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)
                        if prow() > 55
                                __eject()
                                pageprint(abtext)
                        endif
                        @ prow()+01,00 say transform(++nline,"999")+". "+;
                                           memvar->aitems[nctr,_P_ACCTNO]+" "+;
                                           memvar->aitems[nctr,_P_LNAME]+" "+;
                                           memvar->aitems[nctr,_P_FNAME]+" "+;
                                           memvar->aitems[nctr,_P_MNAME]+" "+;
                                           padR(memvar->aitems[nctr,_P_COURSE],8)+" "+;
                                           memvar->aitems[nctr,_P_PERCENT]+" "+;
                                           transform(memvar->aitems[nctr,_P_AMOUNT],"@Z 999,999.99")
                        npagetotal  += memvar->aitems[nctr,_P_AMOUNT]
                        ngrandtotal += memvar->aitems[nctr,_P_AMOUNT]

                        ++nstud
                        namt += memvar->aitems[nctr,_P_AMOUNT]
                endif
                privcourse := ""
        next
        privilege->(reclock())
        privilege->student := nstud
        privilege->amount  := namt
        privilege->(dbcommit())
        privilege->(dbunlock())
        privilege->(dbskip())
//        privilege->(dbskip(-1))
        @ prow()+01,00 say ""
        nstud := namt := 0
enddo
@ prow()+00,71 say "----------"
@ prow()+01,52 say "  T O T A L  --> "+transform(ngrandtotal,"@Z 9,999,999.99")
__eject()
summary(npage)
return(nil)


static function summary(npage)
local abtext1 := {}, ncol, nmaxcol := 80, ntotstud := 0, ntotamt := 0
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
*aadd(abtext1,{||"Date: "+displaydate(date())+space(ncol-14)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
*aadd(abtext1,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
*aadd(abtext1,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
*aadd(abtext1,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephon Number: 261-9963"})
*aadd(abtext1,{||""})
aadd(abtext1,{||space(titlepos(alltrim(a999prcp->prcdescr),nmaxcol))+alltrim(a999prcp->prcdescr)})
aadd(abtext1,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext1,{||""})
aadd(abtext1,{||""})
aadd(abtext1,{||space(titlepos("SUMMARY",nmaxcol))+"SUMMARY"})
aadd(abtext1,{||space(titlepos("=======",nmaxcol))+"======="})
aadd(abtext1,{||""})
aadd(abtext1,{||""})

pageprint(abtext1)
summary->(dbgobottom())
do while ! summary->(bof())
        if summary->percent == " FF"
                @ prow()+01,36 say "FULL FREE"
                @ prow()+01,36 say "========="
        else
                @ prow()+01,36 say summary->percent+"%"
                @ prow()+01,36 say "===="
        endif
        privilege->(sx_setscope(_TOP_SCOPE   ,summary->percent))
        privilege->(sx_setscope(_BOTTOM_SCOPE,summary->percent))
        privilege->(dbgotop())
        do while ! privilege->(eof())
           if privilege->amount > 0
                @ prow()+01,19 say privilege->course
                @ prow()+00,38 say transform(privilege->student,"999")
                @ prow()+00,51 say transform(privilege->amount,"99,999,999.99")

                ntotstud += privilege->student
                ntotamt  += privilege->amount
           endif
           privilege->(dbskip())
        enddo
        privilege->(clearscope())
        summary->(dbskip(-1))
        if ! summary->(bof())
                @ prow()+01,00 say ""
        endif
enddo
@ prow()+01,36 say "========="
@ prow()+00,51 say "============="
@ prow()+01,37 say transform(ntotstud,"9999")
@ prow()+00,51 say transform(ntotamt,"99,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
return(nil)



static function initfiles()
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"P",{{"PERCENT"     ,"C",03,0},;
                                     {"COURSE"      ,"C",08,0},;
                                     {"STUDENT"     ,"N",03,0},;
                                     {"AMOUNT"      ,"N",14,2}},{||cdxpercent()}) .or.;
   ! createdummy(memvar->cdummy+"S",{{"PERCENT"     ,"C",03,0}},{||cdxsummary()})
        dbcloseall()
        return(nil)
endif
memvar->privilege := memvar->cdummy+"P"
memvar->summary   := memvar->cdummy+"S"
return(nil)


static function cdxpercent()
field percent,course
private cdummyfile := alias()
index on percent+course tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)


static function cdxsummary()
field percent
private cdummyfile := alias()
index on percent tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)


static function pstudbilling()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0, nline := 0,;
      npagetotal := 0, ngrandtotal := 0, namt := 0, nstud := 0, privcourse := space(8)
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"+chr(27)+"E"})
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})

/*
      Account#    Last Name          First Name         M  Course   %    Amount
     --------- --------------- ------------------------ - -------- --- ----------
123. 123456789 123456789012345 123456789012345678901234 1 12345678 123 123,123.12
                                                                       ----------
                                                              TOTAL -> 123,123.12


*/

pageprint(abtext)
bhead1()
bhead2()
//privilege->(dbgobottom())
//do while ! privilege->(bof())
privilege->(dbgotop())
do while ! privilege->(eof())
        for nctr := 1 to len(memvar->aitems)
                privcourse := privilege->course
                fask(10," Printing name "+alltrim(memvar->aitems[nctr,_P_LNAME])+", "+alltrim(memvar->aitems[nctr,_P_FNAME])+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                if privilege->percent == memvar->aitems[nctr,_P_PERCENT].and. ;
                   memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)
                        if prow() > 52
                                __eject()
                                bhead2()
                        endif
                        @ prow()+01,00 say transform(++nline,"999")+". "+;
                                           memvar->aitems[nctr,_P_ACCTNO]+" "+;
                                           memvar->aitems[nctr,_P_LNAME]+" "+;
                                           memvar->aitems[nctr,_P_FNAME]+" "+;
                                           memvar->aitems[nctr,_P_MNAME]+" "+;
                                           padR(memvar->aitems[nctr,_P_COURSE],8)+" "+;
                                           memvar->aitems[nctr,_P_PERCENT]+" "+;
                                           transform(memvar->aitems[nctr,_P_AMOUNT],"@Z 999,999.99")
                        npagetotal  += memvar->aitems[nctr,_P_AMOUNT]
                        ngrandtotal += memvar->aitems[nctr,_P_AMOUNT]

                        ++nstud
                        namt += memvar->aitems[nctr,_P_AMOUNT]
                endif
                privcourse := ""
        next
        privilege->(reclock())
        privilege->student := nstud
        privilege->amount  := namt
        privilege->(dbcommit())
        privilege->(dbunlock())
        privilege->(dbskip())
//        privilege->(dbskip(-1))
        @ prow()+01,00 say ""
        nstud := namt := 0
enddo
@ prow()+00,71 say "----------"
@ prow()+01,54 say "  T O T A L  --> "+transform(ngrandtotal,"@Z 9,999,999.99")
bfoot1()
//bfoot1(cnotedby,cdesgn)
return(nil)


static function bhead1()
@ prow()+02,00 say "Date: "+cmonth(date())+str(day(date()))+","+str(year(date()))
@ prow()+02,00 say "To  : "+memvar->cprivdesc

@ prow()+03,00 say "TO WHOM THIS MAY CONCERN :"

@ prow()+02,00 say "This is to certify that the following students are enrolled in this"
@ prow()+01,00 say "institution for the "+if(right(cterm,1)=="4",substr(cdesc,1,6),substr(cdesc,1,12))+" of school year "+if(right(cterm,1)=="4",substr(cdesc,8,4),substr(cdesc,14,9))+":"
return(nil)


static function bhead2()
@ prow()+02,00 say "      Account#    Last Name          First Name         M  Course   %    Amount  "
@ prow()+01,00 say "     --------- --------------- ------------------------ - -------- --- ----------"
return(nil)


static function bfoot1(cnotedby,cdesgn)
@ 55,00 say "Please facilitate your payments thru:"
@ 57,00 say "Chancellor"
@ 58,00 say "University of Cebu"
@ 59,00 say "Banco De Oro Unibank"
@ 60,05 say "Elizabeth Mall Branch"
@ 61,05 say "Cebu City"
@ 62,05 say "Peso   SA # 1850000024"
@ 63,05 say "Dollar SA # 1850000032"

@ 65,05 say "Note: Please fax your deposit slip at 262-0555 for verification and"
@ 66,05 say "      posting of payment."

@ 68,05 say "Prepared by:"

@ 71,05 say "ENena T. Duran"
@ 72,05 say "Acctg In-charge"

//@ 73,00 say "Noted by: E"+cnotedby+""
//@ 74,00 say "          "+cdesgn

@ 77,00 say "UC-METC\SAC.DOC.\REV.02"

__eject()
return(nil)

*------------------------------------------------------------------------------*

function privbytype()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,ayytprsp,cyytenrp,cnotedby:=cdesgn:=space(35)
private cterm,cdesc,ctype,nnumber,namount,cstud,;
        npageno,npageamt,ngrandno,ngrandamt

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Students Receiving Privilege by Type (Basic Ed)  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif

        memvar->ctype := "B"
        memvar->cstud := "A"
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "                     [I-nternal, E-xternal, B-oth(I-E)]" color memvar->colorarray[02]
                @ 04,02 say "Privilege Type :";
                        color memvar->colorarray[02];
                        get ctype pict "@!";
                        valid ctype $ "IEB"

                @ 06,02 say "                     [S-Senior High, J-Junior High, E-Elementary, A-ALL]" color memvar->colorarray[02]
                @ 06,02 say "Course Type :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "SJEA"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pprivbytype()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pprivbytype()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, lprint := .f.

ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-14)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Pardo - Talisay",nmaxcol)-14)+"Pardo - Talisay"})
aadd(abtext,{||space(titlepos("Bulacao, Cebu City",nmaxcol))+"Bulacao, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 272-2985",nmaxcol))+"Telephon Number: 272-2985"})
aadd(abtext,{||""})

if memvar->cstud == "S" 
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Senior Highschool Students ",nmaxcol))+"Discounts and Privileges Granted to Senior Highschool Students"})
elseif memvar->cstud == "J"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Junior Highschool Students ",nmaxcol))+"Discounts and Privileges Granted to Junior Highschool Students"})
elseif memvar->cstud == "E"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Elementary Students",nmaxcol))+"Discounts and Privileges Granted to Elementary Students"})
elseif memvar->cstud == "A"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to All Basic Education Students",nmaxcol))+"Discounts and Privileges Granted to All Basic Education Students"})
endif

if memvar->ctype == "I"
        aadd(abtext,{||space(titlepos("( Internal Privileges )",nmaxcol))+"( Internal Privileges )"})
elseif memvar->ctype == "E"
        aadd(abtext,{||space(titlepos("( External Privileges )",nmaxcol))+"( External Privileges )"})
elseif memvar->ctype == "B"
        aadd(abtext,{||space(titlepos("( Both Internal and External Privileges )",nmaxcol))+"( Both Internal and External Privileges )"})
endif

aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                     N A T U R E                NUMBER      AMOUNT    "})
aadd(abtext,{||"          -----------------------------------   ------   -------------"})

/*
                     N A T U R E                NUMBER      AMOUNT
          -----------------------------------   ------   -------------
          1234 123456789012345678901234567890   12,345   12,123,123.12
                                                ------   -------------
                                Page Total -->  12,123   12,123,123.12
                             Running Total
                               Grand Total
*/

memvar->npageno := memvar->npageamt := memvar->ngrandno := memvar->ngrandamt := 0
pageprint(abtext)
a999prcp->(dbgotop())
do while ! a999prcp->(eof())
        memvar->nnumber := memvar->namount := 0
        fask(10,"  Printing "+alltrim(a999prcp->prccode)+" "+alltrim(a999prcp->prcdescr)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case memvar->ctype == "I" .and. ! left(a999prcp->prccode,1) == "X" .and. ;
                     ! a999prcp->prccode $ "ALM ,CV10,SPD "
                        summdata()
                        lprint := .t.
                case memvar->ctype == "E" .and. left(a999prcp->prccode,1) == "X"
                        summdata()
                        lprint := .t.
                case memvar->ctype == "B"
                        summdata()
                        lprint := .t.
        endcase
        if lprint .and. memvar->namount > 0
                if prow() > 55
                        __eject()
                        pageprint(abtext)
                        memvar->npageno := memvar->npageamt := 0
                endif

                @ prow()+01,10 say a999prcp->prccode+" "+a999prcp->prcdescr
                @ prow()+00,48 say transform(memvar->nnumber,"99,999")
                @ prow()+00,57 say transform(memvar->namount,"99,999,999.99")

                lprint := .f.
        endif
        if nextkey() == K_ESC
                exit
        endif
        a999prcp->(dbskip())
enddo
@ prow()+01,48 say "------   -------------"
@ prow()+01,29 say "  T O T A L  --->  "+transform(memvar->ngrandno,"99,999")+"   "+transform(memvar->ngrandamt,"99,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
return(nil)


static function summdata()
ayytprsp->(sx_setscope(_TOP_SCOPE   ,a999prcp->prccode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,a999prcp->prccode))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        fask(16,"  Processing student number "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   /*
   if memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "MA,MM,MT,MV,MI,MR,PA,MP,CS" .or. ;
      memvar->cstud == "U" .and. !cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .or. ;
      memvar->cstud == "B"
    */

    if memvar->cstud == "S" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM" .or. ;
      memvar->cstud == "J" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "G7,G8,G9,GA" .or. ;
      memvar->cstud == "E" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6" .or. ;
      memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" 

        ++memvar->nnumber
        ++memvar->npageno
        ++memvar->ngrandno
        memvar->namount   += ayytprsp->prstuiadsc
        memvar->npageamt  += ayytprsp->prstuiadsc
        memvar->ngrandamt += ayytprsp->prstuiadsc
    endif
        if nextkey() == K_ESC
                exit
        endif
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())
return(nil)

*------------------------------------------------------------------------------*

function privsummary()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytprsp,cfile,ccdx,cyytenrp,cnotedby:=cdesgn:=space(35)
private aitems := {},nindex,cterm,cdesc,ctype,cstud,;
        cdummy := "psumm"+strzero(memvar->naccess,2),privsumm

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Privileges Summary by Type (Basic Ed)  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,2}})) == nil
                return(nil)
        endif
        memvar->ctype := "B"
        memvar->cstud := "A"
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "                     [I-nternal, E-xternal, B-oth(I-E)]" color memvar->colorarray[02]
                @ 04,02 say "Privilege Type :";
                        color memvar->colorarray[02];
                        get ctype pict "@!";
                        valid ctype $ "IEB"
                @ 06,02 say "                     [S-Senior High, J-Junior High, E-Elementary, A-ALL]" color memvar->colorarray[02]
                @ 06,02 say "Course Type :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "SJEA"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if whereprint({||pprivsumm()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pprivsumm()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile,npageno := 0,npageamt := 0,ntotno := 0,ntotamt := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"PERCENT"     ,"C",03,0},;
                                 {"NUMBER"      ,"N",06,0},;
                                 {"AMOUNT"      ,"N",12,2}},{||cdxsummary()})
        dbcloseall()
        return(nil)
endif
memvar->privsumm := memvar->cdummy
if(afile := openwcheck({{,,(memvar->privsumm+".TXT"),"privsumm",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
privsumm->(__dbzap()); privsumm->(dbreindex())
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-14)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephon Number: 261-9963"})
aadd(abtext,{||""})

if memvar->cstud == "S" 
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Senior Highschool Students ",nmaxcol))+"Discounts and Privileges Granted to Senior Highschool Students"})
elseif memvar->cstud == "J"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Junior Highschool Students ",nmaxcol))+"Discounts and Privileges Granted to Junior Highschool Students"})
elseif memvar->cstud == "E"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to Elementary Students",nmaxcol))+"Discounts and Privileges Granted to Elementary Students"})
elseif memvar->cstud == "A"
    aadd(abtext,{||space(titlepos("Discounts and Privileges Granted to All Basic Education Students",nmaxcol))+"Discounts and Privileges Granted to All Basic Education Students"})
endif

if memvar->ctype == "I"
        aadd(abtext,{||space(titlepos("( Internal Privileges )",nmaxcol))+"( Internal Privileges )"})
elseif memvar->ctype == "E"
        aadd(abtext,{||space(titlepos("( External Privileges )",nmaxcol))+"( External Privileges )"})
elseif memvar->ctype == "B"
        aadd(abtext,{||space(titlepos("( Both Internal and External Privileges )",nmaxcol))+"( Both Internal and External Privileges )"})
endif
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"                 PERCENTAGE         NUMBER             AMOUNT    "})
aadd(abtext,{||"                 ----------         ------         --------------"})

/*
                 PERCENTAGE         NUMBER             AMOUNT
                 ----------         ------         --------------
                 1234567890         12,123         123,123,123.12
                                    -----------------------------
                      Page Total -> 12,123         123,123,123.12
                   Running Total ->
                     Grand Total ->
*/

** Filtering data **
a999prcp->(dbgotop())
do while ! a999prcp->(eof())
        fask(10,"  Processing "+a999prcp->prccode+" "+alltrim(a999prcp->prcdescr)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        do case
                case memvar->ctype == "I" .and. ! left(a999prcp->prccode,1) == "X"
                        getsumm()
                case memvar->ctype == "E" .and. left(a999prcp->prccode,1) == "X"
                        getsumm()
                case memvar->ctype == "B"
                        getsumm()
        endcase
        if nextkey() == K_ESC
                exit
        endif
        a999prcp->(dbskip())
enddo

** printing **
pageprint(abtext)
//privsumm->(dbgobottom()) // descending order
privsumm->(dbgotop())//ascending order
do while ! privsumm->(eof())
//do while ! privsumm->(bof())
        if prow() > 55
                __eject()
                pageprint(abtext)
                npageno := npageamt := 0
        endif
        if alltrim(privsumm->percent) == "FF"
                @ prow()+01,17 say "FULL FREE"
        else
                @ prow()+01,17 say privsumm->percent+".00%"
        endif
        @ prow()+00,36 say transform(privsumm->number,"99,999")
        @ prow()+00,51 say transform(privsumm->amount,"999,999,999.99")

        npageno  += privsumm->number
        npageamt += privsumm->amount
        ntotno   += privsumm->number
        ntotamt  += privsumm->amount

        if nextkey() == K_ESC
                exit
        endif
        //privsumm->(dbskip(-1))
        privsumm->(dbskip())
enddo
@ prow()+01,36 say "-----------------------------"
@ prow()+01,19 say "  T O T A L  --> "+transform(ntotno,"99,999")+space(09)+transform(ntotamt,"999,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function getsumm()
local cpercent := ""
ayytprsp->(sx_setscope(_TOP_SCOPE   ,a999prcp->prccode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,a999prcp->prccode))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
        fask(16,"  Processing student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   /*
   if memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "MT,MV,MA,MM,MI,MR,PA,MP,CS" .or. ;
      memvar->cstud == "U" .and. !cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .or. ;
      memvar->cstud == "B"
   */

    if memvar->cstud == "S" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM" 

        if ayytprsp->prstuipdsc == 0
                cpercent := "FF "
        else
                cpercent := str(ayytprsp->prstuipdsc * 100,3)
        endif

        if ! privsumm->(dbseek(cpercent))
                privsumm->(dbappend())
                privsumm->percent       := cpercent
                privsumm->number        := 1
                privsumm->amount        := ayytprsp->prstuiadsc
        else
                privsumm->(reclock())
                privsumm->number        := privsumm->number + 1
                privsumm->amount        := privsumm->amount + ayytprsp->prstuiadsc
                privsumm->(dbcommit())
                privsumm->(dbunlock())
        endif

    elseif memvar->cstud == "J" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "G7,G8,G9,GA"  

            if ayytprsp->prstuipdsc == 0
                    cpercent := "FF "
            else
                    cpercent := str(ayytprsp->prstuipdsc * 100,3)
            endif

            if ! privsumm->(dbseek(cpercent))
                    privsumm->(dbappend())
                    privsumm->percent       := cpercent
                    privsumm->number        := 1
                    privsumm->amount        := ayytprsp->prstuiadsc
            else
                    privsumm->(reclock())
                    privsumm->number        := privsumm->number + 1
                    privsumm->amount        := privsumm->amount + ayytprsp->prstuiadsc
                    privsumm->(dbcommit())
                    privsumm->(dbunlock())
            endif

    elseif memvar->cstud == "E" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6"
            
            if ayytprsp->prstuipdsc == 0
                cpercent := "FF "
            else
                cpercent := str(ayytprsp->prstuipdsc * 100,3)
            endif

            if ! privsumm->(dbseek(cpercent))
                    privsumm->(dbappend())
                    privsumm->percent       := cpercent
                    privsumm->number        := 1
                    privsumm->amount        := ayytprsp->prstuiadsc
            else
                    privsumm->(reclock())
                    privsumm->number        := privsumm->number + 1
                    privsumm->amount        := privsumm->amount + ayytprsp->prstuiadsc
                    privsumm->(dbcommit())
                    privsumm->(dbunlock())
            endif
    
    elseif  memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"

            if ayytprsp->prstuipdsc == 0
                    cpercent := "FF "
            else
                    cpercent := str(ayytprsp->prstuipdsc * 100,3)
            endif

            if ! privsumm->(dbseek(cpercent))
                    privsumm->(dbappend())
                    privsumm->percent       := cpercent
                    privsumm->number        := 1
                    privsumm->amount        := ayytprsp->prstuiadsc
            else
                    privsumm->(reclock())
                    privsumm->number        := privsumm->number + 1
                    privsumm->amount        := privsumm->amount + ayytprsp->prstuiadsc
                    privsumm->(dbcommit())
                    privsumm->(dbunlock())
            endif
    endif
        if nextkey() == K_ESC
                exit
        endif
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())
return(nil)

*------------------------------------------------------------------------------*

function billsbycode()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytprsp,cfile,ccdx,cnotedby:=cdesgn:=space(35)
private cterm,cdesc,cprivcode,cprivdesc,cstud,;
        cdummy := "bcode"+strzero(memvar->naccess,2),student

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Bills by Privilege Code (Basic Ed)  ")
        commandline("³      F4 - View Term/Privilege        ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytprsp  := "a"+memvar->cterm+"prsp"
        if(aopen2files := openwcheck({{,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,2},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999stcp",,_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        memvar->cprivcode := space(len(a999prcp->prccode))
        memvar->cstud := "A"

//        cnotedby := "MR. BARTOLOME T. POZON            "
//        cdesgn   := "Campus Administrative Director    "
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Privilege Code :";
                        color memvar->colorarray[02];
                        get memvar->cprivcode pict "@!";
                        valid ! empty(memvar->cprivcode)

                @ 05,02 say "                     [S-Senior High, J-Junior High, E-Elementary, A-ALL]" color memvar->colorarray[02]
                @ 05,02 say "Course Type :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "SJEA"
                                
                @ 06,02 say "     Noted by  :";
                        color memvar->colorarray[02];
                        get cnotedby pict "@!"
                @ 07,02 say "   Designation :";
                        color memvar->colorarray[02];
                        get cdesgn pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999prcp->(dbseek(memvar->cprivcode))
                        fask(10,"  Privilege code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                memvar->cprivdesc := a999prcp->prcdescr
                if whereprint({||pbillsbycode(cnotedby,cdesgn)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pbillsbycode(cnotedby,cdesgn)
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lfirst := .t., grandTot, adjamt := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",09,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"UNITS"       ,"N",11,2}},{||cdxname()})
        dbcloseall()
        return(nil)
endif
memvar->student := memvar->cdummy
if(afile := openwcheck({{,,(memvar->student+".TXT"),"student",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
student->(__dbzap()); student->(dbreindex())

**filtering data**
ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cprivcode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cprivcode))
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())

        if memvar->cstud == "S" .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM" .or. ;
        memvar->cstud == "J"  .and. ayytprsp->prscolcod $ "G7,G8,G9,GA" .or. ;
        memvar->cstud == "E"  .and. ayytprsp->prscolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6" .or. ;
        memvar->cstud == "A"  .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" 

            fask(10,"  Processing student number "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
            a999accp->(dbseek(ayytprsp->prsidno))
            student->(dbappend())
            student->idno   := a999accp->accidno
            student->lname  := a999accp->acclname
            student->fname  := a999accp->accfname
            student->mname  := a999accp->accmname
            student->units  := a999accp->accsytunt
        endif
        if nextkey() == K_ESC
                exit
        endif
        ayytprsp->(dbskip())
enddo
ayytprsp->(clearscope())

**printing data**
header()
student->(dbgotop())
grandTot := 0
do while ! student->(eof())
        fask(10,"  Printing student "+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        a999accp->(dbseek(student->idno))
        if c999colp->(dbseek(a999accp->acccolcod))
                @ prow()+01,05 say "E"+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+space(07)+alltrim(c999colp->coldesabr)+" - ";
                           +a999accp->accyrlevl+"  ("+transform(a999accp->accsytunt,"99.99")+" UNITS)"+""
        else
           a999stcp->(dbseek(a999accp->acccolcod))
                @ prow()+01,05 say "E"+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+space(07)+alltrim(a999stcp->stcdesabr)+"   ";
                           +" "+"  ("+transform(a999accp->accsytunt,"99.99")+" UNITS)"+""
        endif
        @ prow()+01,10 say "Tuition. . . . . . . . P "+transform(a999accp->accsyttui,"999,999.99")
        @ prow()+01,10 say "Miscellaneous. . . . .   "+transform(a999accp->accsytmisc,"999,999.99")
        @ prow()+01,10 say "Laboratory . . . . . .   "+transform(a999accp->accsytlab,"999,999.99")
        @ prow()+01,10 say "Registration . . . . .   "+transform(a999accp->accsytoth,"999,999.99")
        @ prow()+01,10 say "Total Fee. . . . . . .   "+transform(a999accp->accsytass,"999,999.99")
/*
        if ! a999accp->accbalold == 0
                @ prow()+01,10 say "Old Account. . . . . .   "+transform(a999accp->accbalold,"999,999.99")
        endif
        if ! a999accp->accadj == 0
                @ prow()+01,10 say "Adjustment . . . . . .   "+transform(a999accp->accadj,"999,999.99")
        endif                                        123,123.12
*/
        adjamt := 0
        Do Case
                Case memvar->cprivcode == 'XNNI'
                        adjamt := 3401.07
                        @ prow()+01,10 say "Adjustment . . . . . .   "+transform(adjamt,"999,999.99")
                Case memvar->cprivcode == 'XMNI'
                        adjamt := 3568.99
                        @ prow()+01,10 say "Adjustment . . . . . .   "+transform(adjamt,"999,999.99")
        EndCase
/*
        @ prow()+01,10 say "ETOTAL . . . . . . . . . . . . =P= "+transform(a999accp->accsytass +;
                                                                          a999accp->accbalold +;
                                                                          a999accp->accadj,"999,999.99")+;
                                                                          chr(18)
*/
        @ prow()+01,10 say "ETOTAL . . . . . . . . . . . . =P= "+transform(a999accp->accsytass + adjamt ;
                                                                          ,"999,999.99")+;
                                                                          chr(18)
        grandTot += a999accp->accsytass
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
        if ! student->(eof())
                ++nctr
                if nctr == 5 .and. lfirst
                        __eject()
                        lfirst := .f.
                        nctr := 0
                elseif nctr == 6
                        __eject()
                        nctr := 0
                endif
                @ prow()+01,00 say ""
        endif
/*
        if ! student->(eof())
                ++nctr
                if nctr == 3 .and. lfirst
                        __eject()
                        lfirst := .f.
                        nctr := 0
                elseif nctr == 4
                        __eject()
                        nctr := 0
                endif
                @ prow()+01,00 say ""
        endif
*/

enddo
@ prow()+01,06 say "                                    ==============="+chr(18)
@ prow()+01,06 say "ETOTAL . . . . . . . . . . . . . . =P= "+transform(grandTot,"999,999.99")+chr(18)
footer(cnotedby,cdesgn)
__eject()
closewcheck(afile)
return(nil)


static function header()
/*
@ 01,20 say "E          UNIVERSITY OF CEBU        "
@ 02,20 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 03,20 say "     Alumnos, Mambaling, Cebu City    "
@ 04,20 say "        Telephone No.: 261-9963       "
*/
@ 06,05 say "Date: "+cmonth(date())+str(day(date()))+","+str(year(date()))
@ 08,05 say "To  : "+memvar->cprivdesc

@ 11,05 say "ETO WHOM THIS MAY CONCERN :"

@ 13,05 say "This is to certify that the following students are enrolled"
@ 14,05 say "in this institution for the "+if(right(cterm,1)=="4",substr(cdesc,1,6),substr(cdesc,1,12))+" of school year "+if(right(cterm,1)=="4",substr(cdesc,8,4),substr(cdesc,14,9))+":"
@ 15,00 say ""
return(nil)


static function footer(cnotedby,cdesgn)
bfoot1(cnotedby,cdesgn)
return(nil)
@ 44,05 say "Please facilitate your payments thru:"
@ 46,05 say "Chancellor"
@ 47,05 say "University of Cebu"
@ 48,05 say "Banco De Oro Unibank"
@ 49,05 say "Cebu-Osme¤a Blvd. Branch"
@ 50,05 say "Savings Acct. # 0760061084"

@ 52,05 say "Very Truly Yours,"
@ 55,05 say "ENena T. Duran"
@ 56,05 say "Acctg In-Charge"

@ 59,05 say "Noted by: "+cnotedby
@ 60,05 say "          "+cdesgn

@ 62,05 say "UC-PT\SAC-015-00"
//@ 62,05 say "UC-METC\SAC.DOC.\REV.02"
return(nil)

static function cdxname()
field idno,lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

function privnature()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,bindex,bitems,;
      ayytprsp,cfile,ccdx,cyytenrp,cnotedby:=cdesgn:=space(35)
private cdummy := "prin"+strzero(memvar->naccess,2),privnature,;
        cterm, cdesc, cstud

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Privileges Summary by Nature (Basic Ed)  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cstud := "A"

        @ 04,02 say "                     [S-Senior High, J-Junior High, E-Elementary, A-ALL]" color memvar->colorarray[02]
                @ 04,02 say "Privilege Type :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "SJEA"

        read

        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"prsp.dbf")
                fask(10,"  A"+memvar->cterm+"PRSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        if whereprint({||pprivnature()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aopen2files)
enddo
closewcheck(aopen1files)
restscr(alastscr)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)


static function pprivnature()
local abtext := {}, ncol, nmaxcol := 76, npage := 0, nctr := 0, lprint := .f.,;
      afile, cpercent := space(3), cperdesc := space(30), ntotstd, ntotamt,;
      ngrdstd := 0, ngrdamt := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"PRIVILEGE"   ,"C",04,0},;
                                 {"PERCENT"     ,"C",03,0},;
                                 {"STUDENT"     ,"N",04,0},;
                                 {"AMOUNT"      ,"N",12,2}},{||cdxnature()})
        dbcloseall()
        return(nil)
endif
memvar->privnature := memvar->cdummy
if(afile := openwcheck({{,,(memvar->privnature+".TXT"),"privnature",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
privnature->(__dbzap()); privnature->(dbreindex())
ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||"         N A T U R E            %  #STUDENTS          A M O U N T         "})
aadd(abtext,{||"------------------------------ --- --------- -----------------------------"})

/*
         N A T U R E            %  #STUDENTS          A M O U N T
------------------------------ --- --------- -----------------------------
123456789012345678901234567890 123 1234 1234 123,123,123.12 123,123,123.12
                               -------------------------------------------
                                        ----                --------------
                        T O T A L  -->  1234                123,123,123.12
*/

** filtering data **
ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
   
   /*
   if memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "MT,MV,MA,MM,MI,MR,PA,MP,CS" .or. ;
      memvar->cstud == "U" .and. !cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .or. ;
      memvar->cstud == "B"
    */

    if memvar->cstud == "S" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM" .or. ;
      memvar->cstud == "J" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "G7,G8,G9,GA" .or. ;
      memvar->cstud == "E" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6" .or. ;
      memvar->cstud == "A" .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "AG,OO,GS,ST,HU,IC,AM,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"

        fask(10,"  Processing student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! left(ayytprsp->prscode,1) == "X"
                cpercent := if(ayytprsp->prstuipdsc > 0,str(ayytprsp->prstuipdsc * 100,3),"FF ")
                if privnature->(dbseek(left(ayytprsp->prscode,4)+cpercent))
                        privnature->(reclock())
                else
                        privnature->(dbappend())
                endif
                privnature->privilege   := left(ayytprsp->prscode,4)
                privnature->percent     := cpercent
                privnature->student     += 1
                privnature->amount      += ayytprsp->prstuiadsc
                privnature->(dbcommit())
                privnature->(dbunlock())
        endif
   endif
        if nextkey() == K_ESC
                exit
        endif
        ayytprsp->(dbskip())
enddo

** printing **
pageprint(abtext)
a999prcp->(dbgotop())
do while ! a999prcp->(eof())
        fask(10,"  Processing "+alltrim(a999prcp->prcdescr)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! left(a999prcp->prccode,1) == "X"
                cperdesc := a999prcp->prcdescr
                ntotstd := ntotamt := 0
                lprint := .f.
                privnature->(sx_setscope(_TOP_SCOPE   ,a999prcp->prccode))
                privnature->(sx_setscope(_BOTTOM_SCOPE,a999prcp->prccode))
                privnature->(dbgotop())
                do while ! privnature->(eof())
                        fask(16,"  Processing code "+privnature->privilege+" percentage "+privnature->percent+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)

                        if prow() > 55
                                __eject()
                                pageprint(abtext)
                                cperdesc := a999prcp->prcdescr
                        endif

                        @ prow()+01,00 say cperdesc
                        @ prow()+00,31 say privnature->percent
                        @ prow()+00,35 say transform(privnature->student,"9999")
                        @ prow()+00,45 say transform(privnature->amount,"999,999,999.99")

                        ntotstd += privnature->student
                        ntotamt += privnature->amount

                        ngrdstd += privnature->student
                        ngrdamt += privnature->amount

                        cperdesc := space(30)
                        lprint := .t.

                        if nextkey() == K_ESC
                                exit
                        endif

                        privnature->(dbskip())
                enddo
                privnature->(clearscope())
                if lprint
                        @ prow()+00,40 say transform(ntotstd,"9999")
                        @ prow()+00,60 say transform(ntotamt,"999,999,999.99")
                        @ prow()+00,31 say "___________________________________________"
                        @ prow()+01,00 say ""
                endif
        endif
        if nextkey() == K_ESC
                exit
        endif
        a999prcp->(dbskip())
enddo
@ prow()+00,40 say "----                --------------"
@ prow()+01,24 say "T O T A L  -->"
@ prow()+00,40 say transform(ngrdstd,"9999")
@ prow()+00,60 say transform(ngrdamt,"999,999,999.99")
@ prow()+01,40 say "====                =============="
@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function cdxnature()
field privilege,percent
private cdummyfile := alias()
index on privilege+percent tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
