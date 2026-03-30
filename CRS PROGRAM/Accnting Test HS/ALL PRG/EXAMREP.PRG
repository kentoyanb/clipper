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
        @ 02,22 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
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
                @ 04,02 say "                 [1-st,2-nd,3-rd,4-th]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "1234"
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
  if a999accp->(dbseek("1"+cidno))
  elseif a999accp->(dbseek("2"+cidno))
  endif
  /*for nctr := 1 to 19
          skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
          if ! cyytenrp->&skdno == "00000"
                  if cyytskdp->(dbseek(cyytenrp->&skdno)) .and.;
                     ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                     ! (cyytskdp->skdsubtyp == "LAB" )
                   //  ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
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
  endif*/
  **printing**
  header(cidno,cdesc)
  if len(memvar->aitems) > 19
          nmax := 19
  else
          nmax := len(memvar->aitems)
  endif
  /*for nctr := 1 to nmax
          @ prow()+01,00 say memvar->aitems[nctr,_X_SUBJ]+" "+;
                             memvar->aitems[nctr,_X_TYPE]+" "+;
                             "______"
   //                        transform(memvar->aitems[nctr,_X_UNIT],"99.9")+"   "+;
  //                         "______"
          dispsummary(++nline,0,cperiod)
  next*/

  //@ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
  nover := 0
  if nline < 17
          nctr := nline + 1
          for nline := nctr to 17
                  dispsummary(nline,nover,cperiod)
                  nover := 1
          next
  endif
  bystudentfooter(cperiod)
  *__eject()
return(nil)


static function header(cidno,cdesc)
local ngrant
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))

if a999accp->(dbseek("1"+cidno))
elseif a999accp->(dbseek("2"+cidno))
endif

if a999accp->accpbcprv == "1"
   ngrant = "PUBLIC"
elseif a999accp->accpbcprv == "2"
   ngrant = "PRIVATE WITH ESC"
else
   ngrant = "NONE"
endif

@ prow()+02,00 say padc(alltrim(cdesc),121) // TODO
@ prow()+01,00 say cidno

if a999accp->acccolcod == "GA"
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + "GRADE 10"   
else
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + if(a999accp->accyrlevl == "2","GRADE 12","GRADE 11")
    @ prow()+01,00 say "TRACK - STRAND: "+if(cyytenrp->enrcolcod == "TM","TECHVOC - ","ACADEMICS - ") + alltrim(c999colp->coldesabr)
    @ prow(),36 say "GRANT:  "+ ngrant
endif

@ prow()+01,00 say "                                    STUDENT ACCOUNT  DETAILS"
@ prow()+01,00 say " "
return(nil)

static function headerbygradelevel(cidno,cdesc)
local ngrant
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))

if a999accp->(dbseek("1"+cidno))
elseif a999accp->(dbseek("2"+cidno))
endif

if a999accp->accpbcprv == "1"
   ngrant = "PUBLIC"
elseif a999accp->accpbcprv == "2"
   ngrant = "PRIVATE WITH ESC"
else
   ngrant = "NONE"
endif

@ prow()+06,00 say padc(alltrim(cdesc),121) // TODO
@ prow()+01,00 say cidno

if a999accp->acccolcod == "GA"
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + "GRADE 10"   
else
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + if(a999accp->accyrlevl == "2","GRADE 12","GRADE 11")
    @ prow()+01,00 say "TRACK - STRAND: "+if(cyytenrp->enrcolcod == "TM","TECHVOC - ","ACADEMICS - ") + alltrim(c999colp->coldesabr)
    @ prow(),36 say "GRANT:  "+ ngrant
endif

@ prow()+01,00 say "                                    STUDENT ACCOUNT  DETAILS"
@ prow()+01,00 say " "
return(nil)

static function footer(cperiod)
@ 26,00 say "This serves as your"
@ 26,50 say "Exam PERMIT if validated"
@ 26,20 say if(cperiod == "1","JULY",;
            if(cperiod == "2","AUGUST",;
            if(cperiod == "3","SEPTEMBER","OCTOBER")))

//4OFFICIAL RECEIPT5

@ 27,00 say "Date: "
@ 27,07 say dtoc(date())
@ 27,20 say "Acctg. In-Charge:"
@ 27,46 say "UC-METC/SAC.DOC/001/REV.03"
@ 33,00 say space(01) /* to eject */
setprc(00,-1)
//setprc(00,00)
return(nil)

static function bystudentfooter(cperiod)
@ 21,00 say "This serves as your"
@ 21,50 say "Exam PERMIT if validated"
@ 21,20 say if(cperiod == "1","JULY",;
            if(cperiod == "2","AUGUST",;
            if(cperiod == "3","SEPTEMBER","OCTOBER")))

//4OFFICIAL RECEIPT5

@ 22,00 say "Date: "
@ 22,07 say dtoc(date())
@ 22,20 say "Acctg. In-Charge:"
@ 22,46 say "UC-METC/SAC.DOC/001/REV.03"
@ 26,00 say ""
@ 26,46 say ""
@ 26,20 say " "
@ 27,00 say ""
@ 27,07 say ""
@ 27,20 say ""
@ 27,46 say ""
@ 33,00 say space(01) /* to eject */
//@ 30,00 say space(01) /* to eject */
setprc(00,-1)
//setprc(00,00)
return(nil)


static function bygradelevelfooter(cperiod)
@ 23,00 say "This serves as your"
@ 23,50 say "Exam PERMIT if validated"
@ 23,20 say if(cperiod == "1","JULY",;
            if(cperiod == "2","AUGUST",;
            if(cperiod == "3","SEPTEMBER","OCTOBER")))

//4OFFICIAL RECEIPT5

@ 24,00 say "Date: "
@ 24,07 say dtoc(date())
@ 24,20 say "Acctg. In-Charge:"
@ 24,46 say "UC-METC/SAC.DOC/001/REV.03"
@ 26,00 say ""
@ 26,46 say ""
@ 26,20 say " "
@ 27,00 say ""
@ 27,07 say ""
@ 27,20 say ""
@ 27,46 say ""
@ 33,00 say space(01) /* to eject */
//@ 30,00 say space(01) /* to eject */
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

//PERMIT BY GRADE LEVEL
function permitbycollege()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,;
      cfile,ccdx,cprocsts,clname,cfname,csection, sectf, sectcod
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"Print Examination Permit by Grade\Level")
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
      *  cdesc := term->name
      *  @ 02,22 say "- "+term->name
        cdesc := term->name
        @ 03,22 say term->name

        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"section",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := "N1"
        cperiod  := "1"
*BE        cyrlevel := "1"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        csection := space(len(section->secdesc))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})

                //todo test
                setkey(K_F5,{||if(readvar()=="CSECTION",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+section->seccode+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})

                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [UC - ALL COURSE]" color memvar->colorarray[02]
                @ 03,02 say "BasicEd Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
               //Todo e test pani
                /*@ 04,02 say "                   " color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "12348"
                */
                @ 04,02 say "                   [1-ST,2-ND,3-RD,4-TH,5-TH]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "12345"
                @ 05,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 06,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
                
                @ 08,02 say "    Section    :";
                        color memvar->colorarray[02];
                        get csection pict "@!";
                        valid ! empty(csection)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999colp->(dbseek(ccolcode)) .and. !(ccolcode=="UC")
                        fask(10,"  College code not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                sectf = "0"
                sectcod = ""
                section->(dbgotop())
                do while ! section->(eof())
                        if alltrim(section->secdesc) == alltrim(csection)
                           sectcod = section->seccode
                           sectf = "1"
                        endif
                        section->(dbskip())
                enddo
                section->(clearscope())
                if  sectf == "0"
                        fask(10,"  SECTION not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pexambygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)}) == 1
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

//PRINT EXAM BY GRADE LEVEL
static function pexambygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)
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
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if a999accp->(dbseek("1"+cyytenrp->enridno))
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
        endif
        c999colp->(dbseek(cyytenrp->enrcolcod))
        if cyytenrp->enrsection == sectcod

                student->(dbappend())
                student->idno    := cyytenrp->enridno
                student->lname   := a999accp->acclname
                student->fname   := a999accp->accfname
                student->mname   := a999accp->accmname
                student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl 
        endif
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
                if a999accp->(dbseek("1"+student->idno))
                elseif a999accp->(dbseek("2"+student->idno))
                endif
                /* WAY LABOT-------------------------------------------------------
                for nctr := 1 to 25
                        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                        if ! cyytenrp->&skdno == "00000"
                                if cyytskdp->(dbseek(cyytenrp->&skdno)) .and.;
                                    (cyytskdp->skdsubtyp == "LEC") //cyytskdp->skdsplcod == "S" .and. 
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
                WAY LABOT -------------------------------------------------------
                */

                headerbygradelevel(student->idno,cdesc) //BY SECTION
                /*
                if len(memvar->aitems) > 19
                        nmax := 19
                else
                        nmax := len(memvar->aitems)
                endif
                */
                //for nctr := 1 to nmax
                      /*fask(16,"  Printing subject "+alltrim(memvar->aitems[nctr,_X_SUBJ])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil) 
                        @ prow()+01,00 say memvar->aitems[nctr,_X_SUBJ]+" "+;
                                           memvar->aitems[nctr,_X_TYPE]+" "+;
                                           //"______"
                                          // transform(memvar->aitems[nctr,_X_UNIT],"99.9")+"   "+;
                      */
                         // dispsummary(++nline,0,cperiod)
                
                       
                        nover := 0
                        
                        if nline < 19
                                nctr := nline + 1
                                for nline := nctr to 19
                                        dispsummary(nline,nover,cperiod)
                                        nover := 1
                                next
                        endif
				        //next
                //footer(cperiod)       
        endif
		    bygradelevelfooter(cperiod)
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
enddo
cyytenrp->(sx_settagorder(2))
closewcheck(afile)
return(nil)


//NEW FORMAT
static function dispsummary(nline,nrow,cperiod)
local namt := 0 , nexamf := 0 , nadj := 0 , ndue, namtpd := 0, ngrant, nshare := 0

if(a999accp->accfeeyr == "16")

    if a999accp->accpbcprv == "1"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 0
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 4000
       endif
     
       ngrant = "PUBLIC"
    elseif a999accp->accpbcprv == "2"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 2000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 6000
       endif
       ngrant = "PRIVATE WITH ESC"
    elseif a999accp->accpbcprv == "3"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 14000
       endif
       ngrant = "NONE"
    elseif a999accp->accpbcprv == "4"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 14000
       endif
       ngrant = "NONE"
    endif
            // nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/5

end if
if(a999accp->accfeeyr == "17")

    if a999accp->accpbcprv == "1"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 5000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 6000
       endif
       ngrant = "PUBLIC"
    elseif a999accp->accpbcprv == "2"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 7000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 8000
       endif
       ngrant = "PRIVATE WITH ESC"
    elseif a999accp->accpbcprv == "3"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 15000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 16000
       endif
       ngrant = "NONE"
    elseif a999accp->accpbcprv == "4"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              nshare = 14000
       endif
       ngrant = "NONE"
    endif

end if
         nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4
do case
        case nline == 1
                @ prow()+nrow,29 say "OLD ACCOUNT......"
                @ prow()+00,47 say transform(a999accp->accbalold,"999,999.99")
        case nline == 2
                //@ prow()+01,29 say " "
                @ prow()+nrow,29 say "ASSESSMENT ......"
                @ prow()+00,47 say transform(a999accp->accsytass,"999,999.99")
        case nline == 3
                @ prow()+nrow,29 say "TOTAL ..........."
                @ prow()+00,47 say transform(a999accp->accsytass+a999accp->accbalold,"999,999.99")
        case nline == 4
                @ prow()+nrow,29 say "STUDENT SHARE.............."
                @ prow()+00,56 say transform(nshare,"999,999.99")
        case nline == 5
                @ prow()+nrow,29 say "LESS: PAYMENT"
                @ prow()+00,47 say transform(a999accp->accamtpd,"999,999.99")
        case nline == 6
                @ prow()+nrow,29 say "LESS: DISCOUNT...."
                @ prow()+00,47 say transform(a999accp->accsytadsc,"999,999.99")
        case nline == 7
                @ prow()+nrow,29 say "LESS: ADJUSTMENT."
                @ prow()+00,47 say if(a999accp->accadj < 0,transform(a999accp->accadj,"999,999.99"),transform(namt,"999,999.99"))
        case nline == 8
                @ prow()+nrow,29 say "BALANCE................"
                if(a999accp->accbalold >0)
                         @ prow()+00,56 say transform((nshare+a999accp->accbalold) -( a999accp->accsytadsc + (a999accp->accadj* -1) + a999accp->accamtpd),"999,999.99")
                else
                         @ prow()+00,56 say transform(nshare -( a999accp->accsytadsc + (a999accp->accadj* -1) + a999accp->accamtpd),"999,999.99")
                endif
        case nline == 9

                        if cperiod == "1"
                                 ndue = "JULY"
                        elseif cperiod == "2"
                                 ndue = "AUGUST"
                                 nexamf = (nexamf * 2) - a999accp->accamtpd
                        elseif cperiod == "3"
                                 ndue = "SEPTEMBER"
                                 nexamf = (nexamf * 3) - a999accp->accamtpd
                        elseif cperiod == "4"
                                 ndue = "OCTOBER"

                                 nexamf = a999accp->accbaltot
                        endif
                 if nexamf < 0
                         namt := 0
                 else
                         namt := nexamf
                 endif
                 @ prow()+01,28 say " "
                 @ prow()+00,29 say "DUE FOR " + ndue + "...."

                 //@ prow()+00, 28 say 
                 if(a999accp->accbalold>0)
                         @ prow()+00,56 say transform(int(namt)+a999accp->accbalold,"999,999.99")

                 else
                         @ prow()+00,56 say transform(int(namt),"999,999.99")
                 endif
        case nline == 10
                 @ prow()+nrow,29 say "GRANT: " + ngrant
        case nline == 12
               if  a999prcp->(dbseek(a999accp->acccode))
                 @ prow()+nrow,29 say "TYPE OF SCHOLARSHIP: " + a999prcp->prcdescr
               else
                 @ prow()+nrow,29 say "TYPE OF SCHOLARSHIP: "
               endif
        case nline == 14
                 @ prow()+nrow,29 say "LAST SCHOOL ATTENDED: "

endcase
return(nil)


static function cdxname()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*
