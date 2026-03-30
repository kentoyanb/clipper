* Program       :  DAILYREP.PRG
* Author        :  Kent Bascon
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*
//space(03)
#define _P_ACCTNO       1
#define _P_LNAME        2
#define _P_FNAME        3
#define _P_MNAME        4
#define _P_COURSE       5
#define _P_PERCENT      6
#define _P_AMOUNT       7
#define _X_COURSE       8
#define _X_PRIV         9
#define _P_EMPTY        {space(09),space(15),space(24),space(01),;
                         space(08),space(03),0,space(06),space(06)}

function per_discount()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,oscholar,bindex,bitems,;
      ayytprsp,cfile,ccdx,cnotedby:=cdesgn:=space(35)
private aitems := {},nindex,cterm,cdesc,cprivcode,ntotalamt,nctr,cprivdesc,;
        cdummy := "priv"+strzero(memvar->naccess,2),privilege,summary,cstud

bindex   := memvarblock("NINDEX")
bitems   := memvarblock("AITEMS")
oscholar := createabrowse(bitems,bindex,06,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fstdperdiscount(xnmode,xoabrowser,xaxparam)},;
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
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Daily Postings per Discount Code ")
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
        initfilesdaily()
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"a999stcp",,_DBF_SHARED,,1},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,3},;
                                      {,,(memvar->privilege+".TXT"),"privilege",_DBF_EXCLUSIVE,,1},;
                                      {,,(memvar->summary+".TXT"),"summary",_DBF_EXCLUSIVE,,1}})) == nil
                return(nil)
        endif
        memvar->cprivcode := space(len(a999prcp->prccode))
        memvar->cstud := "B"
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View Privilege         ³           ESC - Previous              ³")
                setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Privilege Code :";
                        color memvar->colorarray[02];
                        get memvar->cprivcode pict "@!";
                        valid ! empty(memvar->cprivcode)
                @ 05,02 say "                     [A-Academic, U-Upgrading, B-Both]" color memvar->colorarray[02]
                @ 05,02 say "Privilege Type :";
                        color memvar->colorarray[02];
                        get cstud pict "@!";
                        valid cstud $ "AUB"
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
                //processbydisc()
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



function per_training()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,oscholar,bindex,bitems,;
      ayytprsp,cfile,ccdx,cnotedby:=cdesgn:=space(35)
private aitems := {},nindex,cterm,cdesc,cprivcode,ntotalamt,nctr,cprivdesc,colcode,;
        cdummy := "priv"+strzero(memvar->naccess,2),privilege,summary,cstud

bindex   := memvarblock("NINDEX")
bitems   := memvarblock("AITEMS")
oscholar := createabrowse(bitems,bindex,06,02,21,77,;
                        {|xnmode,xoabrowser,xaxparam|fstdprivpertraining(xnmode,xoabrowser,xaxparam)},;
                        {{{||memvar->aitems[memvar->nindex,_P_ACCTNO]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_LNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_FNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_MNAME]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_COURSE]},nil},;
                         {{||memvar->aitems[memvar->nindex,_P_PERCENT] +" "+memvar->aitems[memvar->nindex,_X_PRIV]},nil},;
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
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Display Daily Postings per Training ")
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
        initfilesdaily()
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"a999stcp",,_DBF_SHARED,,1},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,2},;
                                      {,,(memvar->privilege+".TXT"),"privilege",_DBF_EXCLUSIVE,,1},;
                                      {,,(memvar->summary+".TXT"),"summary",_DBF_EXCLUSIVE,,1}})) == nil
                return(nil)
        endif
        memvar->cprivcode := space(len(a999prcp->prccode))
        memvar->colcode := space(len(cyytenrp->enrcolcod))
        memvar->cstud := "B"
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View Privilege         ³           ESC - Previous              ³")
                //setkey(K_F4,{||vschpriv(space(len(a999prcp->prccode)),cprocsts,memvar->colorarray[10])})
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get memvar->colcode pict "@!";
                        valid ! empty(memvar->colcode)

               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                /*if ! c999colp->(dbseek(memvar->colcode)) .and. cstud == "A"
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop*/
                if memvar->colcode $ "PB,TM,GS,ST,HU,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
                        fask(10,"  BasicEd Code is not allowed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                /*elseif ! a999stcp->(dbseek(memvar->colcode)) .and. cstud == "U"
                       fask(10,"  Training code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop*/
                endif

                if c999colp->(dbseek(memvar->colcode))
                    @ 04,24 say "- "+c999colp->coldesabr
                    memvar->cprivdesc := c999colp->coldesabr
                elseif a999stcp->(dbseek(memvar->colcode))
                    @ 04,24 say "- "+a999stcp->stcdesabr
                    memvar->cprivdesc := a999stcp->stcdesabr
                endif

                //memvar->cprivdesc := a999prcp->prcdescr
                //memvar->cprivdesc := c999colp->coldesabr
                memvar->aitems := {_P_EMPTY}
                memvar->nindex := 1
                privilege->(__dbzap()); privilege->(dbreindex())
                summary->(__dbzap()); summary->(dbreindex())
                processpertraining()
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



static function fstdperdiscount(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_F6
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pstudperdisc()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        /*case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pstudbilling()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif*/
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function fstdprivpertraining(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_F6
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||studpertraining()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        /*case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pstudbilling()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif*/
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2



static function processbydisc()
local nlastelem,nctr1,cpercent
memvar->ntotalamt := memvar->nctr := 0

ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->cprivcode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cprivcode))

ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())

    if memvar->cstud == "A"  .and. cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .and. ayytprsp->prscolcod $ "MA,MM,MT,MV,MI,MR,PA,MP,CS,MN,NS,HN,HM,NN,ML,TL"

        a999accp->(dbseek(ayytprsp->prsidno))
        fask(10,"  Processing Academic student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := ayytprsp->prsidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname

        c999colp->(dbseek(ayytprsp->prscolcod))

        memvar->aitems[nlastelem,_P_COURSE]     := alltrim(c999colp->coldesabr)+" "+ayytprsp->prsyrlvl
        memvar->aitems[nlastelem,_X_COURSE]     := alltrim(c999colp->coldesabr)

        

        if ayytprsp->prstuipdsc  > 0
                    memvar->aitems[nlastelem,_P_PERCENT]    := transform(ayytprsp->prstuipdsc * 100, "@Z 999")
                    cpercent := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
        elseif ayytprsp->prstuipdsc  == 0
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

        /*if ! privilege->(dbseek(cpercent+alltrim(a999stcp->stcdesabr)))
                privilege->(dbappend())
                privilege->percent      := cpercent
                privilege->course       := alltrim(a999stcp->stcdesabr)
        endif*/

        if ! summary->(dbseek(cpercent))
                summary->(dbappend())
                summary->percent        := cpercent
        endif

    elseif memvar->cstud == "U" .and. !ayytprsp->prscolcod $ "MA,MM,MT,MV,MI,MR,PA,MP,CS,MN,NS,HN,HM,NN,ML,TL,PB,TM,GS,ST,HU,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
        a999accp->(dbseek(ayytprsp->prsidno))
        fask(10,"  Processing Training student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := ayytprsp->prsidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname
        
        a999stcp->(dbseek(ayytprsp->prscolcod))
        memvar->aitems[nlastelem,_P_COURSE]     := alltrim(a999stcp->stcdesabr)
        memvar->aitems[nlastelem,_X_COURSE]     := alltrim(a999stcp->stcdesabr)


        if ayytprsp->prstuipdsc  > 0
                    memvar->aitems[nlastelem,_P_PERCENT]    := transform(ayytprsp->prstuipdsc * 100, "@Z 999")
                    cpercent := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
        elseif ayytprsp->prstuipdsc  == 0
                    memvar->aitems[nlastelem,_P_PERCENT]      := " FF"
                    cpercent := " FF"
        endif
           
        

        memvar->aitems[nlastelem,_P_AMOUNT]     := ayytprsp->prstuiadsc

        memvar->ntotalamt += ayytprsp->prstuiadsc
        ++memvar->nctr


        if ! privilege->(dbseek(cpercent+alltrim(a999stcp->stcdesabr)))
                privilege->(dbappend())
                privilege->percent      := cpercent
                privilege->course       := alltrim(a999stcp->stcdesabr)
        endif

        if ! summary->(dbseek(cpercent))
                summary->(dbappend())
                summary->percent        := cpercent
        endif

    elseif memvar->cstud == "B" .and. !ayytprsp->prscolcod $ "PB,TM,GS,ST,HU,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
        a999accp->(dbseek(ayytprsp->prsidno))
        fask(10,"  Processing student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := ayytprsp->prsidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname

        if c999colp->(dbseek(ayytprsp->prscolcod))
                    memvar->aitems[nlastelem,_P_COURSE]     := alltrim(c999colp->coldesabr)+" "+ayytprsp->prsyrlvl
                    memvar->aitems[nlastelem,_X_COURSE]     := alltrim(c999colp->coldesabr)
        else
               a999stcp->(dbseek(ayytprsp->prscolcod))
                    memvar->aitems[nlastelem,_P_COURSE]     := alltrim(a999stcp->stcdesabr)
                    memvar->aitems[nlastelem,_X_COURSE]     := alltrim(a999stcp->stcdesabr)
        endif

        if ayytprsp->prstuipdsc  > 0
                    memvar->aitems[nlastelem,_P_PERCENT]    := transform(ayytprsp->prstuipdsc * 100, "@Z 999")
                    cpercent := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
        elseif ayytprsp->prstuipdsc  == 0
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

        if ! privilege->(dbseek(cpercent+alltrim(a999stcp->stcdesabr)))
                privilege->(dbappend())
                privilege->percent      := cpercent
                privilege->course       := alltrim(a999stcp->stcdesabr)
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


////////////////////////////////////////////////////////////////////////////////////////
static function processpertraining()
local nlastelem,nctr1,cpercent,temppercent, acctnum := 0
memvar->ntotalamt := memvar->nctr := 0

ayytprsp->(sx_setscope(_TOP_SCOPE   ,memvar->colcode))
ayytprsp->(sx_setscope(_BOTTOM_SCOPE,memvar->colcode))

ayytprsp->(dbgotop())
do while ! ayytprsp->(eof())
    
    
    /*if a999accp->(dbseek("1"+cyytenrp->enridno))
        acctnum := a999accp->accidno
    elseif a999accp->(dbseek("2"+cyytenrp->enridno))
        acctnum := a999accp->accidno
    endif*/

   
    
    //if ayytprsp->(dbseek("1"+cyytenrp->enridno+memvar->colcode))

         a999accp->(dbseek(ayytprsp->prsidno))
    //if memvar->cstud == "A"  
    //  memvar->cstud == "U" .and. !cyytenrp->(dbseek(right(ayytprsp->prsidno,8))) .or. ;
    //  memvar->cstud == "B" .and. !ayytprsp->prscolcod $ "PB,TM,GS,ST,HU,K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
        fask(10,"  Processing student no. "+ayytprsp->prsidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        aadd(memvar->aitems,_P_EMPTY)
        nlastelem := len(memvar->aitems)
        memvar->aitems[nlastelem,_P_ACCTNO]     := ayytprsp->prsidno
        memvar->aitems[nlastelem,_P_LNAME ]     := a999accp->acclname
        memvar->aitems[nlastelem,_P_FNAME ]     := a999accp->accfname
        memvar->aitems[nlastelem,_P_MNAME ]     := a999accp->accmname
        if c999colp->(dbseek(memvar->colcode))
                    memvar->aitems[nlastelem,_P_COURSE]     := alltrim(c999colp->coldesabr)+" "+ayytprsp->prsyrlvl
                    memvar->aitems[nlastelem,_X_COURSE]     := alltrim(c999colp->coldesabr)
        elseif  a999stcp->(dbseek(memvar->colcode))
              
                    memvar->aitems[nlastelem,_P_COURSE]     := alltrim(a999stcp->stcdesabr)
                    memvar->aitems[nlastelem,_X_COURSE]     := alltrim(a999stcp->stcdesabr)
        endif

        if ayytprsp->prstuipdsc  > 0
                    memvar->aitems[nlastelem,_X_PRIV] := alltrim(ayytprsp->prscode)
                   
                    memvar->aitems[nlastelem,_P_PERCENT]    := transform(ayytprsp->prstuipdsc * 100, "@Z 999")
                    //temppercent := transform(ayytprsp->prstuipdsc * 100, "@Z 999")
                    cpercent := transform(ayytprsp->prstuipdsc * 100,"@Z 999")
        elseif ayytprsp->prstuipdsc  == 0
                    memvar->aitems[nlastelem,_X_PRIV] := ayytprsp->prscode
                   // cpercent := " FF"//+" "+ayytprsp->prscode
                    memvar->aitems[nlastelem,_P_PERCENT]      := " FF" //+"_"+ayytprsp->prscode
                    //temppercent := " FF"
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

        if ! privilege->(dbseek(cpercent+alltrim(a999stcp->stcdesabr)))
                privilege->(dbappend())
                privilege->percent      := cpercent
                privilege->course       := alltrim(a999stcp->stcdesabr)
        endif

        if ! summary->(dbseek(cpercent))
                summary->(dbappend())
                summary->percent        := cpercent
        endif
    //endif

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


static function pstudperdisc()
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
               
                

                if privilege->percent == memvar->aitems[nctr,_P_PERCENT] .and. ;
                 memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)

                     fask(10," Printing name "+alltrim(memvar->aitems[nctr,_P_LNAME])+", "+alltrim(memvar->aitems[nctr,_P_FNAME])+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                //if memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)
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
dailysummary(npage)
return(nil)

static function studpertraining()
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
               

                if privilege->percent == memvar->aitems[nctr,_P_PERCENT] .and. ;
                 memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)

                     fask(10," Printing name "+alltrim(memvar->aitems[nctr,_P_LNAME])+", "+alltrim(memvar->aitems[nctr,_P_FNAME])+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                //if memvar->aitems[nctr,_X_COURSE] == alltrim(privcourse)
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
                                           memvar->aitems[nctr,_P_PERCENT]+" "+memvar->aitems[nctr,_X_PRIV]+" "+;
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
dailysummary(npage)
return(nil)


static function dailysummary(npage)
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



static function initfilesdaily()
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"P",{{"PERCENT"     ,"C",03,0},;
                                     {"COURSE"      ,"C",08,0},;
                                     {"STUDENT"     ,"N",03,0},;
                                     {"AMOUNT"      ,"N",14,2}},{||cdxpercentdaily()}) .or.;
   ! createdummy(memvar->cdummy+"S",{{"PERCENT"     ,"C",03,0}},{||cdxsummarydaily()})
        dbcloseall()
        return(nil)
endif
memvar->privilege := memvar->cdummy+"P"
memvar->summary   := memvar->cdummy+"S"
return(nil)


static function cdxpercentdaily()
field percent,course
private cdummyfile := alias()
index on percent+course tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)


static function cdxsummarydaily()
field percent
private cdummyfile := alias()
index on percent tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)




