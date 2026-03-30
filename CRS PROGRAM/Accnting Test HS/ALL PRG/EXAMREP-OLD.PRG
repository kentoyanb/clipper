* Program       :  EXAMREP.PRG
* Author        :  Jhun Benlot and Randy F. Santizo (rb) February 1999
* Installation  :  UC-METC
* Updated       :  Rainy Season of 2003


#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*

#define _X_SUBJ         1
#define _X_TYPE         2
#define _X_UNIT         3
#define _X_EMPTY        {space(12),space(03),0}

function permitbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,cprocsts,nctr,aentryscr,cyytenrp,cyytskdp,;
      cterm,cdesc,cidno,cperiod
private aitems := {},nindex := 1

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Examination Permit by Student  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
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
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,22 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        cidno   := space(len(c999sm1p->sm1idno))
        cperiod := " "
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Student File       Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CIDNO",vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No.  :";
                        color memvar->colorarray[02];
                        get cidno pict "@!"
                @ 04,02 say "                 [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(cidno))
                        fask(10,"  Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! cyytenrp->(dbseek(cidno))
                        fask(10,"  Student not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pexambystudent(cterm,cdesc,cidno,cperiod)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

static function pexambystudent(cterm,cdesc,cidno,cperiod)
local nctr := 0,skdno, nlastelem, nline := 0, nover := 0,nmax := 0
memvar->aitems := {_X_EMPTY}
memvar->nindex := 1
cyytenrp->(dbseek(cidno))
a999accp->(dbseek("1"+cidno))
for nctr := 1 to 25
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                if cyytskdp->(dbseek(cyytenrp->&skdno)) .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. (cyytskdp->skdsubtyp == "LEC" .or. cyytskdp->skdsubtyp == "LAB")) .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        fask(10,"  Processing subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        aadd(memvar->aitems,_X_EMPTY)
                        nlastelem := len(memvar->aitems)
                        memvar->aitems[nlastelem,_X_SUBJ ]    := cyytskdp->skdsubcod
                        memvar->aitems[nlastelem,_X_TYPE ]    := cyytskdp->skdsubtyp
                        memvar->aitems[nlastelem,_X_UNIT ]    := cyytskdp->skdunt
                endif
        endif
next
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_X_SUBJ])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
**printing**
header(cidno,cdesc)
if len(memvar->aitems) > 19
        nmax := 19
else
        nmax := len(memvar->aitems)
endif
for nctr := 1 to nmax
        @ prow()+01,00 say memvar->aitems[nctr,_X_SUBJ]+" "+;
                           memvar->aitems[nctr,_X_TYPE]+" "+;
                           transform(memvar->aitems[nctr,_X_UNIT],"99.9")+"   "+;
                           "______"
        dispsummary(++nline,0,cperiod)
next
@ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
nover := 0
if nline < 19
        nctr := nline + 1
        for nline := nctr to 19
                dispsummary(nline,nover,cperiod)
                nover := 1
        next
endif
footer(cperiod)
*__eject()
return(nil)


static function dispsummary(nline,nrow,cperiod)
local namt := 0 , nexamf := 0

do case
        case nline == 1
                @ prow()+nrow,32 say "OLD ACCOUNT"
                @ prow()+00,60 say transform(a999accp->accbalold,"999,999.99")
                @ prow()+00,32 say replicate("_",38)
        case nline == 2
                @ prow()+nrow,32 say "FEES:"
        case nline == 3
                @ prow()+nrow,34 say "TUITION"
                @ prow()+00,50 say transform(a999accp->accsyttui,"999,999.99")
        case nline == 4
                @ prow()+nrow,34 say "REGISTRATION"
                @ prow()+00,50 say transform(a999accp->accsytoth,"999,999.99")
        case nline == 5
                @ prow()+nrow,34 say "MISCELLANEOUS"
                @ prow()+00,50 say transform(a999accp->accsytmisc,"999,999.99")
        case nline == 6
                @ prow()+nrow,34 say "LABORATORY"
                @ prow()+00,50 say transform(a999accp->accsytlab,"999,999.99")
        case nline == 7
                @ prow()+nrow,34 say "ADJUSTMENT"
                @ prow()+00,50 say if(a999accp->accadj > 0,transform(a999accp->accadj,"999,999.99"),transform(namt,"999,999.99"))
        case nline == 8
                @ prow()+nrow,32 say "TOTAL DUE"
                @ prow()+00,60 say transform(a999accp->accbalold + a999accp->accsyttui  +;
                                             a999accp->accsytoth + a999accp->accsytmisc +;
                                             a999accp->accsytlab + if(a999accp->accadj > 0,a999accp->accadj,0),"999,999.99")
                @ prow()+00,32 say replicate("_",38)
        case nline == 9
                @ prow()+nrow,32 say "LESS: PAYMENT"
                @ prow()+00,50 say transform(a999accp->accamtpd,"999,999.99")
        case nline == 10
                @ prow()+nrow,32 say "LESS: DISCOUNT"
                @ prow()+00,50 say transform(a999accp->accsytadsc,"999,999.99")
        case nline == 11
                @ prow()+nrow,32 say "LESS: ADJUSTMENT"
                @ prow()+00,50 say if(a999accp->accadj < 0,transform(a999accp->accadj,"999,999.99"),transform(namt,"999,999.99"))
        case nline == 12
                @ prow()+nrow,32 say "BALANCE"
                @ prow()+00,60 say transform(a999accp->accbalold + a999accp->accsyttui  +;
                                             a999accp->accsytoth + a999accp->accsytmisc +;
                                             a999accp->accsytlab + a999accp->accadj     -;
                                             a999accp->accamtpd  - a999accp->accsytadsc,"999,999.99")
                @ prow()+00,32 say replicate("_",38)

        case nline == 13

//--new computation
                if cperiod == "P"
                        @ prow()+nrow,32 say "DUE FOR PRELIM"

                        if a999accp->accbalold <= 0
                                if (a999accp->accamtpd) >= (a999accp->accsytass/2)
                                   nexamf := 0
                                else
                                   nexamf := ((a999accp->accsytass+a999accp->accadj)/4)-a999accp->accamtpd
                                end if
                        else
                            nexamf := (((a999accp->accsytass)/4)+(a999accp->accbalold))-a999accp->accamtpd

//                          nexamf := ((((a999accp->accbalold-a999accp->accadj)-a999accp->accamtpd)+a999accp->accsytass)/4)
//commented by Kenn         nexamf := (((((a999accp->accsytass-a999accp->accadj)/4)+a999accp->accbalold)-a999accp->accamtpd)-a999accp->accsytadsc)
                        end if
                        namt   := nexamf


                elseif cperiod == "M"
                        @ prow()+nrow,32 say "DUE FOR MIDTERM"
                        if a999accp->accbalold == 0

                               nexamf := (((((a999accp->accsytass+a999accp->accadj)/2)+a999accp->accbalold)-a999accp->accamtpd)-a999accp->accsytadsc)
                        elseif a999accp->accbalold == 8000 .or. a999accp->accbalold == 10000
                               nexamf := (a999accp->accsytass+a999accp->accadj)/2

                        else
                               nexamf := ((((a999accp->accsytass/2)+a999accp->accbalold)-a999accp->accamtpd)-a999accp->accsytadsc)

                        endif
                        namt   := nexamf

                elseif cperiod == "S"
                        @ prow()+nrow,32 say "DUE FOR SEMI-FINAL"
                        if a999accp->accadj < 0
                                nexamf := (a999accp->accbaltot-((a999accp->accsytass-500)/4))
                                namt   := nexamf
                        else
                                nexamf := (a999accp->accbaltot-((a999accp->accsytass+a999accp->accadj)/4))
                                namt   := nexamf
                        endif
                elseif cperiod == "F"
                        @ prow()+nrow,32 say "DUE FOR FINAL"
                        namt   := a999accp->accsytass
                endif

                do case
                        case cperiod == "F"
                                if (namt + a999accp->accbalold - a999accp->accsytadsc + a999accp->accadj - a999accp->accamtpd) < 0
                                        @ prow()+00,60 say transform(0,"999,999.99")

                                else
                                        @ prow()+00,60 say transform(namt + a999accp->accbalold - a999accp->accsytadsc +;
                                                                     a999accp->accadj - a999accp->accamtpd,"999,999.99")
                                endif
                        case cperiod $ "PMS"
                                if namt < 0
                                        @ prow()+00,60 say transform(0,"999,999.99")
                                else
                                        @ prow()+00,60 say transform(int(namt),"999,999.99")
                                endif
                                //@ prow()+00,60 say transform(int(namt),"999,999.99")
                endcase

                @ prow()+00,32 say replicate("_",38)
endcase
return(nil)


static function header(cidno,cdesc)
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))
//@ prow()+00,00 say "UNIVERSITY OF CEBU (METC)"
@ prow()+08,00 say padc(alltrim(cdesc),80)
@ prow()+01,00 say cidno
@ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam
@ prow()+00,62 say c999colp->coldesabr+" "+cyytenrp->enryrlevl
@ prow()+01,00 say "SUBJECT         UNITS INST.INIT.         STATEMENT OF ACCOUNT"
// FOR NIGERIAN@ prow()+01,00 say "SUBJECT         UNITS INST.INIT.   "
return(nil)

static function footer(cperiod)
@ 26,00 say "This serves as your"
@ 26,46 say "Examination PERMIT if validated"
@ 26,20 say if(cperiod == "P","PRELIM ",;
            if(cperiod == "M","MIDTERM ",;
            if(cperiod == "S","SEMI-FINAL ","FINAL ")))

//4OFFICIAL RECEIPT5

@ 27,00 say "Date: "
@ 27,07 say dtoc(date())
@ 27,20 say "Acctg. In-Charge:"
@ 27,46 say "UC-METC/SAC.DOC/001/REV.03"
@ 33,00 say space(01) /* to eject */
setprc(00,-1)
//setprc(00,00)
return(nil)

/*    O  L  D    F  O  O  T  E  R    */
static function footer_old(cperiod)
@ 16,00 say "THIS SERVES AS YOUR "+if(cperiod == "P","PRELIM ",;
                                   if(cperiod == "M","MIDTERM ",;
                                   if(cperiod == "S","SEMI-FINAL ","FINAL "))) +;
            "EXAMINATION PERMIT IF VALIDATED."
@ 17,00 say "DATE: "+dtoc(date())
@ 17,24 say "ACCTG IN-CHARGE:"
@ 18,00 say "UC-METC/SAC.DOC./001/REV.01"
//@ 21,00 say space(01) /* to eject */
@ 22,00 say space(01) /* to eject */
setprc(00,-1)
//setprc(00,00)
return(nil)

*------------------------------------------------------------------------------*

function permitbycollege()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,;
      cfile,ccdx,cprocsts,clname,cfname
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Examination Permit by College  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
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
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,22 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := "UC"
        cperiod  := "P"
        cyrlevel := "1"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [UC - ALL COURSE]" color memvar->colorarray[02]
                @ 03,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
                @ 04,02 say "                   [1 2 3 4 5  8-ALL]" color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "123458"
                @ 05,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 05,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 06,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 07,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 08,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode)) .and. !(ccolcode=="UC")
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pexambycollege(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)}) == 1
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

static function pexambycollege(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)
local nctr,skdno,nlastelem,nline,nover,nmax,;
      afile
fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"LNAME"       ,"C",15,0},;
                                 {"FNAME"       ,"C",24,0},;
                                 {"MNAME"       ,"C",01,0},;
                                 {"COURSE"      ,"C",08,0}},{||cdxname()})
        dbcloseall()
        return(nil)
endif
memvar->student := memvar->cdummy
if(afile := openwcheck({{,,(memvar->student+".TXT"),"student",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
student->(__dbzap());student->(dbreindex())

if ccolcode != "UC"
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode+if(cyrlevel=="8","",cyrlevel)))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode+if(cyrlevel=="8","",cyrlevel)))
endif

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        a999accp->(dbseek("1"+cyytenrp->enridno))
        c999colp->(dbseek(cyytenrp->enrcolcod))
        student->(dbappend())
        student->idno    := cyytenrp->enridno
        student->lname   := a999accp->acclname
        student->fname   := a999accp->accfname
        student->mname   := a999accp->accmname
        student->course  := c999colp->coldesabr+" "+cyytenrp->enryrlevl
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())

**printing**
cyytenrp->(sx_settagorder(1))
student->(dbgotop())
do while ! student->(eof())
        fask(10,"  Processing student "+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(student->lname)+alltrim(student->fname))
                memvar->aitems := {_X_EMPTY}
                memvar->nindex := 1
                nline := 0
                cyytenrp->(dbseek(student->idno))
                a999accp->(dbseek("1"+student->idno))
                for nctr := 1 to 25
                        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                        if ! cyytenrp->&skdno == "00000"
                                if cyytskdp->(dbseek(cyytenrp->&skdno)) .and.;
                                   ! (cyytskdp->skdsplcod == "C" .and. (cyytskdp->skdsubtyp == "LEC" .or. cyytskdp->skdsubtyp == "LAB")) .and.;
                                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                        fask(16,"  Pocessing subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        aadd(memvar->aitems,_X_EMPTY)
                                        nlastelem := len(memvar->aitems)
                                        memvar->aitems[nlastelem,_X_SUBJ ]    := cyytskdp->skdsubcod
                                        memvar->aitems[nlastelem,_X_TYPE ]    := cyytskdp->skdsubtyp
                                        memvar->aitems[nlastelem,_X_UNIT ]    := cyytskdp->skdunt
                                endif
                        endif
                next
                if len(memvar->aitems) > 1
                        for nctr := 1 to len(memvar->aitems)
                                if empty(memvar->aitems[nctr,_X_SUBJ])
                                        adel(memvar->aitems,nctr)
                                        asize(memvar->aitems,len(memvar->aitems)-1)
                                endif
                        next
                endif
                header(student->idno,cdesc)
                if len(memvar->aitems) > 19
                        nmax := 19
                else
                        nmax := len(memvar->aitems)
                endif
                for nctr := 1 to nmax
                        fask(16,"  Printing subject "+alltrim(memvar->aitems[nctr,_X_SUBJ])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        @ prow()+01,00 say memvar->aitems[nctr,_X_SUBJ]+" "+;
                                           memvar->aitems[nctr,_X_TYPE]+" "+;
                                           transform(memvar->aitems[nctr,_X_UNIT],"99.9")+"   "+;
                                           "______"
                          dispsummary(++nline,0,cperiod)
                next
                @ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
                nover := 0
                if nline < 19
                        nctr := nline + 1
                        for nline := nctr to 19
                                dispsummary(nline,nover,cperiod)
                                nover := 1
                        next
                endif
                footer(cperiod)
        endif
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
enddo
cyytenrp->(sx_settagorder(2))
closewcheck(afile)
return(nil)

static function cdxname()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
