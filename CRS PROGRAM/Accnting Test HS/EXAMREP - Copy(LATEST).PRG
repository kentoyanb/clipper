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

//by student for senior high
function permitbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      opentermfile,aopen2files,cprocsts,nctr,aentryscr,cyytenrp,cyytskdp,ayytpayp,;
      cterm,cdesc,cidno,cperiod
private aitems := {},nindex := 1

if(opentermfile := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
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
        //@ 02,22 say term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        ayytpayp  := "a"+cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif
        cidno   := space(len(c999sm1p->sm1idno))
        cperiod := "1"
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
closewcheck(opentermfile)
return(nil)

//print by student sa senior high
static function pexambystudent(cterm,cdesc,cidno,cperiod)
  local nctr := 0,skdno, nlastelem, accntnum ,nline := 0, nover := 0,nmax := 0
  memvar->aitems := {_X_EMPTY}
  memvar->nindex := 1
  cyytenrp->(dbseek(cidno))
  
  if a999accp->(dbseek("1"+cidno))
      accntnum := "1"+cidno
  endif
  if a999accp->(dbseek("2"+cidno))
      accntnum := "2"+cidno
  endif
  
  **printing**
  headerbygradelevel(cidno,cdesc)
  if len(memvar->aitems) > 19
          nmax := 19
  else
          nmax := len(memvar->aitems)
  endif
 
  testresetrecord(accntnum)

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


//permit by sudent for elem and junior high
function ejhpermitbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      opentermfiles2,aopen2files,cprocsts,nctr,aentryscr,cyytenrp,cyytskdp,ayytpayp,;
      cterm,cdesc,cidno,cperiod
private aitems := {},nindex := 1

if(opentermfiles2 := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
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
        //@ 02,22 say "- SCHOOL YEAR "+substr(term->name,13,10)
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        ayytpayp  := "a"+cterm+"payp"
        /*
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)


        */
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
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
                @ 04,02 say "                 [1-Jul,2-Aug,3-Sep,4-Oct,5-Nov,6-Dec,7-Jan,8-Feb,9-Mar]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "123456789"
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
                if whereprint({||ejhprintingbystudent(cterm,cdesc,cidno,cperiod)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(opentermfiles2)
return(nil)

static function ejhprintingbystudent(cterm,cdesc,cidno,cperiod)
  local nctr := 0,skdno, nlastelem, accntnum, nline := 0, nover := 0,nmax := 0
  memvar->aitems := {_X_EMPTY}
  memvar->nindex := 1
  cyytenrp->(dbseek(cidno))

  if a999accp->(dbseek("1"+cidno))
      accntnum := "1"+cidno
  endif
  if a999accp->(dbseek("2"+cidno))
      accntnum := "2"+cidno
  endif
  
  EJHresetrecord(accntnum)

  **printing**
  ejhheader(cidno,cdesc)
  if len(memvar->aitems) > 19
          nmax := 19
  else
          nmax := len(memvar->aitems)
  endif
  
  //@ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
  nover := 0
  if nline < 17
          nctr := nline + 1
          for nline := nctr to 17
                  EJHdispsummary(nline,nover,cperiod)
                  nover := 1
          next
  endif
  ejhfooter(cperiod)
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

static function ejhheader(cidno,cdesc)
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))
//@ prow()+00,00 say "UNIVERSITY OF CEBU (METC)"
@ prow()+08,00 say padc(alltrim(cdesc),80)
@ prow()+01,00 say cidno
@ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam
@ prow()+00,62 say c999colp->coldesabr//+" "+cyytenrp->enryrlevl
@ prow()+01,00 say "                              STATEMENT OF ACCOUNT"
// FOR NIGERIAN@ prow()+01,00 say "SUBJECT         UNITS INST.INIT.   "
return(nil)

/*@ prow()+02,00 say padc(alltrim(cdesc),121) 
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
*/
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

@ prow()+06,00 say padc(alltrim(cdesc),80) 
@ prow()+01,00 say cidno

if a999accp->acccolcod == "GA"
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + "GRADE 10"   
else
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + if(a999accp->accyrlevl == "2","GRADE 12","GRADE 11")
    @ prow()+01,00 say "TRACK - STRAND: "+if(cyytenrp->enrcolcod == "TM","TECHVOC - ","ACADEMICS - ") + alltrim(c999colp->coldesabr)
    @ prow(),36 say "GRANT:  "+ ngrant
endif

@ prow()+01,00 say "                             STUDENT ACCOUNT  DETAILS"
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
@ 21,20 say if(cperiod == "1","DECEMBER",;
            if(cperiod == "2","JANUARY",;
            if(cperiod == "3","FEBRUARY","MARCH")))

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

static function ejhfooter(cperiod)
@ 26,00 say "This serves as your"
@ 26,50 say "Exam PERMIT if validated"
@ 26,20 say if(cperiod == "1","1ST MASTERY",;
            if(cperiod == "2","1ST PERIODICAL",;
            if(cperiod == "3","2ND MASTERY",;
            if(cperiod == "4","2ND PERIODICAL",;
            if(cperiod == "5","3RD MASTERY",;
            if(cperiod == "6","3RD PERIODICAL",;
            if(cperiod == "7","4TH MASTERY",;
            if(cperiod == "8","5TH MASTERY","4TH PERIODICAL"))))))))

//4OFFICIAL RECEIPT5

@ 27,00 say "Date: "
@ 27,07 say dtoc(date())
@ 27,20 say "Acctg. In-Charge:"
@ 27,46 say "UC-METC/SAC.DOC/001/REV.03"
@ 33,00 say space(01) /* to eject */
setprc(00,-1)
//setprc(00,00)
return(nil)


static function bygradelevelfooter(cperiod)
@ 23,00 say "This serves as your"
@ 23,50 say "Exam PERMIT if validated"
@ 23,20 say if(cperiod == "1","DECEMBER",;
            if(cperiod == "2","JANUARY",;
            if(cperiod == "3","FEBRUARY","MARCH")))

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

//PERMIT BY GRADE LEVEL senior high
function permitbycollege()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,ayytpayp,;
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
        cdesc := term->name
      *  @ 02,22 say "- "+term->name
        //cdesc := term->name
        //cdesc := substr(term->name,1,15) + " of SCHOOL YEAR "+substr(term->name,17,25)
        //@ 02,22 say "- SCHOOL YEAR "+substr(term->name,13,10)

        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        ayytpayp  := "a"+cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"section",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
       
        endif
        ccolcode := "PB"
        cperiod  := "1"
*BE        cyrlevel := "1"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        csection := space(len(section->secdesc))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
  

                setcursor(1);set(_SET_CONFIRM,.t.)
                //@ 03,02 say "                   [UC - ALL COURSE]" color memvar->colorarray[02]
                @ 03,02 say "Strand :";
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
               // endif

                        
                @ 05,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 06,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"

                setcursor(1);set(_SET_CONFIRM,.t.)
                
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

//PRINT EXAM BY GRADE LEVEL SENIOR HIGH
static function pexambygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)
local nctr,skdno,nlastelem,nline,nover,nmax,accntnum;
 
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


/*if a999accp->(dbseek("1"+cyytenrp->enridno))
      accntnum := "1"+cyytenrp->enridno
elseif a999accp->(dbseek("2"+cyytenrp->enridno))
      accntnum := "2"+cyytenrp->enridno
endif
testresetrecord(accntnum)*/


if ccolcode != "UC"
        cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
        cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
endif

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        
        //-----ADDED 11092017 TO RECOMPUTE-------------
        if a999accp->(dbseek("1"+cyytenrp->enridno))
            accntnum := "1"+cyytenrp->enridno
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
             accntnum := "2"+cyytenrp->enridno
        endif
        testresetrecord(accntnum)
         //-----ADDED 11092017 TO RECOMPUTE-------------

        c999colp->(dbseek(cyytenrp->enrcolcod))
        if cyytenrp->enrsection == sectcod // TODO DAPAT MN SIGURO USBON CHECKING ANI

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
                

                headerbygradelevel(student->idno,cdesc) //BY SECTION
                
                //for nctr := 1 to nmax
                      /*fask(16,"  Printing subject "+alltrim(memvar->aitems[nctr,_X_SUBJ])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil) 
                        @ prow()+01,00 say memvar->aitems[nctr,_X_SUBJ]+" "+;
                                           memvar->aitems[nctr,_X_TYPE]+" "+;
                                           //"______"
                                          // transform(memvar->aitems[nctr,_X_UNIT],"99.9")+"   "+;
                      */
                         // dispsummary(++nline,0,cperiod)
                
                       
                        nover := 0
                        
                        if nline < 19 //17 //19
                                nctr := nline + 1
                                for nline := nctr to 19 //17 //19
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

//PERMIY BY GRADE LEVEL FOR ELEM AND JUNIOR HIGH
function ejhpgradelevel()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      ejhaopen1files,aopen2files,ccolcode,cperiod,cyrlevel,cterm,cdesc,ayytpayp,t,;
      cfile,ccdx,cprocsts,clname,cfname
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student

if(ejhaopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
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
        cdesc := term->name
      *  @ 02,22 say "- "+term->name
        //cdesc := substr(term->name,1,15) + " of SCHOOL YEAR "+substr(term->name,17,25)
        //@ 02,22 say "- SCHOOL YEAR "+substr(term->name,13,10)
       
        aentryscr := savescr(01,00,24,79)
        cyytenrp := "c"+cterm+"enrp"
        cyytskdp := "c"+cterm+"skdp"
        ayytpayp  := "a"+cterm+"payp"
        if(ejhaopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)

        endif
        ccolcode := "N1"
        cperiod  := "1"
*BE        cyrlevel := "1"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                //@ 03,02 say "                   [UC - ALL COURSE]" color memvar->colorarray[02]
                @ 03,02 say "Grade Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
               /*
                @ 04,02 say "                   " color memvar->colorarray[02]
                @ 04,02 say "Year Level   :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid cyrlevel $ "12348"
               */
                @ 04,02 say "                   [1-Jul,2-Aug,3-Sep,4-Oct,5-Nov,6-Dec,7-Jan,8-Feb,9-Mar]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "123456789"
                @ 05,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 06,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,02 say "    First Name :";
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
                if whereprint({||ejhprntbygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(ejhaopen2files)
enddo
restscr(alastscr)
closewcheck(ejhaopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)

//PERMIT PRINTING BY ELEM AND JUNIOR HIGH
static function ejhprntbygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)
local nctr,skdno,nlastelem,nline,nover,nmax,accntnum;


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
        
        //-----ADDED 11092017 TO RECOMPUTE-------------
        if a999accp->(dbseek("1"+cyytenrp->enridno))
            accntnum := "1"+cyytenrp->enridno
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
             accntnum := "2"+cyytenrp->enridno
        endif
        EJHresetrecord(accntnum)
         //-----ADDED 11092017 TO RECOMPUTE-------------

       
        c999colp->(dbseek(cyytenrp->enrcolcod))
        student->(dbappend())
        student->idno    := cyytenrp->enridno
        student->lname   := a999accp->acclname
        student->fname   := a999accp->accfname
        student->mname   := a999accp->accmname
        student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl

       

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
                               
                ejhheader(student->idno,cdesc) //BY SECTION
                        nover := 0                       
                        if nline < 19 // 19
                                nctr := nline + 1
                                for nline := nctr to 19
                                        EJHdispsummary(nline,nover,cperiod)
                                        nover := 1
                                next
                        endif
        endif
        ejhfooter(cperiod)
        if nextkey() == K_ESC
                exit
        endif
        student->(dbskip())
enddo
cyytenrp->(sx_settagorder(2))
closewcheck(afile)
return(nil)


//DISPLAY SUMMARY FOR ELEM AND JUNIOR HIGH ---------------------------------------------------------------------------------
static function EJHdispsummary(nline,nrow,cperiod)
local namt := 0 , nexamf := 0 , nadj := 0
do case
        /*case nline == 2
                @ prow()+nrow,32 say "PREVIOUS TERM PAYMENTS"
                @ prow()+00,60 say transform(a999accp->accduetot,"999,999.99")
                @ prow()+00,32 say replicate("_",38)
        */
        case nline == 3
                @ prow()+nrow,32 say "FEES:"
        case nline == 4
                @ prow()+nrow,34 say "TUITION"
                @ prow()+00,50 say transform(a999accp->accsyttui,"999,999.99")
        case nline == 5
                @ prow()+nrow,34 say "MISC."
                @ prow()+00,50 say transform(a999accp->accsytmisc,"999,999.99")
        case nline == 6
                @ prow()+nrow,34 say "REGISTRATION" //a999accp->accsytmisc
                @ prow()+00,50 say transform(a999accp->accsytoth,"999,999.99")
        case nline == 7
                @ prow()+nrow,34 say "LAB./AIRCON"
                @ prow()+00,50 say transform(a999accp->accsytlab,"999,999.99")
        /*
        case nline == 8
                @ prow()+nrow,34 say "ADJUSTMENT"
                @ prow()+00,50 say if(a999accp->accadj < 0,transform(a999accp->accadj * -1,"999,999.99"),transform(namt,"999,999.99"))
                //@ prow()+00,50 say transform(a999accp->accadj,"999,999.99")
        */
        case nline == 8
                @ prow()+nrow,32 say "TOTAL DUE"
                //@ prow()+00,60 say transform(a999accp->accbalold + a999accp->accsytass  +;
                //                            + if(a999accp->accadj < 0,a999accp->accadj * -1,0),"999,999.99")
                @ prow()+00,60 say transform(a999accp->accsyttot,"999,999.99")                            
                @ prow()+00,32 say replicate("_",38)
        case nline == 9
                @ prow()+nrow,32 say "TOTAL PAYMENTS"
                @ prow()+00,50 say transform(a999accp->accamtpd + a999accp->accduetot,"999,999.99")
                //@ prow()+00,50 say transform(a999accp->accamtpd,"999,999.99")
        case nline == 10
                /*if a999accp->acccolcod == "N1" .or. a999accp->acccolcod == "K1"
                         @ prow()+nrow,32 say "LESS: DISCOUNT"
                         @ prow()+00,50 say transform(a999accp->accsytadsc,"999,999.99")
                else*/
                         @ prow()+nrow,32 say "LESS: DISCOUNT"
                         @ prow()+00,50 say transform(a999accp->accsytadsc,"999,999.99")
                //endif
        case nline == 11
                /*if a999accp->acccolcod == "N1" .or. a999accp->acccolcod == "K1"
                        @ prow()+nrow,32 say "LESS: ADJUSTMENT"
                        @ prow()+00,50 say if(a999accp->accadj < 0,transform(namt,"999,999.99"),transform(a999accp->accadj,"999,999.99"))
                else*/
                        @ prow()+nrow,32 say "LESS: ADJUSTMENT"
                        @ prow()+00,50 say if(a999accp->accadj < 0,transform(namt,"999,999.99"),transform(a999accp->accadj,"999,999.99"))

                //endif
        case nline == 13
                @ prow()+nrow,32 say "BALANCE"
                @ prow()+00,60 say transform(a999accp->accbalold - (a999accp->accamtpd+a999accp->accsytadsc),"999,999.99")
                @ prow()+00,32 say replicate("_",38)
        case nline == 15

//--new computation for Basic Education
               
                //nexamf := (a999accp->accsytass-500)/9
                //namt   := nexamf
                if cperiod == "1"
                        nexamf := (a999accp->accsytass-500)/9
                        @ prow()+nrow+1,32 say "DUE FOR JULY"
                        if (a999accp->accamtpd + if(a999accp->accadj < 0, a999accp->accadj * -1, 0)) >= nexamf
                             nexamf := 0
                        else
                             nexamf := nexamf + if(a999accp->accadj < 0, a999accp->accadj + 500, 0)
                        endif
                elseif cperiod == "2"
                        nexamf := (a999accp->accsytass-500)/9
                        @ prow()+nrow+1,32 say "DUE FOR AUGUST"
                        if (a999accp->accamtpd+a999accp->accsytadsc) < (nexamf * 2)
                           nexamf := (nexamf * 2)  - (a999accp->accamtpd+a999accp->accsytadsc)
                        elseif (a999accp->accamtpd+a999accp->accsytadsc)  >= (nexamf * 2)
                           nexamf := 0
                        endif
                elseif cperiod == "3"
                        nexamf := (a999accp->accsytass-500)/9
                        @ prow()+nrow+1,32 say "DUE FOR SEPTEMBER"
                        if (a999accp->accamtpd+a999accp->accsytadsc) < (nexamf * 3)
                           nexamf := (nexamf * 3)  - (a999accp->accamtpd+a999accp->accsytadsc)
                        elseif (a999accp->accamtpd+a999accp->accsytadsc) >= (nexamf * 3)
                           nexamf := 0
                        endif

                elseif cperiod == "4"
                        nexamf := (a999accp->accsytass-500)/9
                        @ prow()+nrow+1,32 say "DUE FOR OCTOBER"
                        if (a999accp->accamtpd+a999accp->accsytadsc) < (nexamf * 4)
                           nexamf := (nexamf * 4) - (a999accp->accamtpd+a999accp->accsytadsc)
                        elseif (a999accp->accamtpd+a999accp->accsytadsc) >= (nexamf * 4)
                           nexamf := 0
                        endif
                        
                ///////////////////////////////////////////////////////////////////////////////////////
                //COMPUTATION THAT STARTS HERE ARE REFER TO SECOND TERM               
                elseif cperiod == "5"
                        nexamf := (a999accp->accsytass-500)/9
                        @ prow()+nrow+1,32 say "DUE FOR NOVEMBER"
                        if (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) < (nexamf * 5)
                           nexamf := (nexamf * 5 - (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc))+ 500

                        elseif (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) >= (nexamf * 5)
                           nexamf := 0
                        endif

                elseif cperiod == "6"
                        @ prow()+nrow+1,32 say "DUE FOR DECEMBER"
                        nexamf := (a999accp->accsytass-500)/9
                        if (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) < (nexamf * 6)
                           nexamf := (nexamf * 6 - (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc))+ 500 
                         
                        elseif (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) >= (nexamf * 6)
                           nexamf := 0
                        endif

                elseif cperiod == "7"
                        @ prow()+nrow+1,32 say "DUE FOR JANUARY"
                        nexamf := (a999accp->accsytass-500)/9
                        if (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) < (nexamf * 7)
                           nexamf := (nexamf * 7 - (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc))+ 500 
                         
                        elseif (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) >= (nexamf * 7)
                           nexamf := 0
                        endif
   
                elseif cperiod == "8"
                        @ prow()+nrow+1,32 say "DUE FOR FEBRUARY"
                        nexamf := (a999accp->accsytass-500)/9
                        if (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) < (nexamf * 8)
                           nexamf := (nexamf * 8 - (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc))+ 500 
                         
                        elseif (a999accp->accamtpd + a999accp->accduetot +a999accp->accsytadsc) >= (nexamf * 8)
                           nexamf := 0
                        endif
 
                elseif cperiod == "9"
                        @ prow()+nrow+1,32 say "DUE FOR MARCH"
                        if a999accp->accbaltot <= 0
                           nexamf := 0
                        else
                           nexamf := a999accp->accbalold - (a999accp->accamtpd+a999accp->accsytadsc)
                        endif
                endif
                @ prow()+00,60 say transform(int(nexamf),"999,999.99")

                //murag wa ni gamit sa ubos
                do case
                        case cperiod == "F"
                                if (nexamf + a999accp->accbalold - a999accp->accsytadsc + a999accp->accadj - a999accp->accamtpd) < 0
                                        @ prow()+00,60 say transform(0,"999,999.99")
                                else
                                        @ prow()+00,60 say transform(nexamf + a999accp->accbalold - a999accp->accsytadsc +;
                                                                     a999accp->accadj - a999accp->accamtpd,"999,999.99")
                                endif
                        case cperiod $ "PMS"
                                if nexamf < 0
                                        @ prow()+00,60 say transform(0,"999,999.99")
                                else
                                        @ prow()+00,60 say transform(int(nexamf),"999,999.99")
                                endif
                                //@ prow()+00,60 say transform(int(namt),"999,999.99")
                endcase

               @ prow()+00,32 say replicate("_",38)
endcase
return(nil)
//-----------------------------------------------------------------------------------------------------------------------------


//NEW FORMAT
//DISPLAY SUMMARY FOR SENIOR HIGH
static function dispsummary(nline,nrow,cperiod)
local namt := 0 , nexamf := 0 , nadj := 0 , ndue, namtpd := 0, ngrant, nshare := 0,subsidy :=0, netsub :=0;
//wsub 1= private 0= public

//TODO DAPAT DILI NI CYA MURAG DEFAULT VALUES DAPAT ANG FEE YEAR KY MAG DEPENDE SA KUNG UNSA DPAT GEKAN DB?
if(a999accp->accfeeyr == "16")//FEE YEAR IS 16
    if a999accp->accpbcprv == "1" //public 
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 0
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
             // nshare = 4000
       endif  
       ngrant = "PUBLIC"
       subsidy = 10000

    elseif a999accp->accpbcprv == "2"//private with esc
       
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
             // nshare = 2000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 6000
       endif
       ngrant = "PRIVATE WITH ESC"
       subsidy = 8000
    elseif a999accp->accpbcprv == "3"
       
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 14000
       endif
       
       ngrant = "NONE"
    elseif a999accp->accpbcprv == "4"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
             // nshare = 14000
       endif
       ngrant = "NONE"
    endif
            // nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/5

end if

if(a999accp->accfeeyr == "17")//FEE YEAR IS 17

    if a999accp->accpbcprv == "1" //public
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 5000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 6000
       endif 
       ngrant = "PUBLIC"
       subsidy = 10000
       //20000.00

    elseif a999accp->accpbcprv == "2" //private with esc 
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 7000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 8000
       endif 
       ngrant = "PRIVATE WITH ESC"
       subsidy = 8000
       //16000.00

    elseif a999accp->accpbcprv == "3"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 15000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 16000
       endif 
       ngrant = "NONE"
       
    elseif a999accp->accpbcprv == "4"
       if a999accp->acccolcod == "GS" .or. a999accp->acccolcod == "HU" .or. a999accp->acccolcod == "ST"
              //nshare = 10000
       elseif a999accp->acccolcod == "TM" .or. a999accp->acccolcod == "PB"
              //nshare = 14000
       endif
       ngrant = "NONE"
    endif
end if

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //(NSHARE -(DISCOUNT + ADJUST* -1))/4 
        //TODO!
        //NSHARE = STUDENT SHARE


        //if(a999accp->accbalold > 0)
          //TODO KUNG NAAY BALANCE           
            if((a999accp->accsytass + a999accp->accbalold >= subsidy) .and. (a999accp->accbalold == 0))
                nshare = a999accp->accsytass + a999accp->accbalold - subsidy * 2
                
                //nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4
            elseif(a999accp->accbalold > 0)
                nshare = (a999accp->accsytass + a999accp->accbalold) - subsidy * 2
                
            //else
                //nshare = nshare + a999accp->accbalold    
            endif
            //nexamf = (nshare - (a999accp->accadj* -1))/4
            
            //nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4

        //else
            //nexamf = (nshare - (a999accp->accadj* -1))/4
           // nshare = a999accp->accsytass
            //nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4
       // endif
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
                @ prow()+00,56 say transform(nshare -( a999accp->accsytadsc + (a999accp->accadj* -1) + a999accp->accamtpd),"999,999.99")
                
                /*
                  if(a999accp->accbalold >0)
                          // NSHARE + OLD BALANCE - (DISCOUNT + ADJUSTMENT* -1) + AMOUNT PAID 
                           @ prow()+00,56 say transform((nshare + a999accp->accbalold) -( a999accp->accsytadsc + (a999accp->accadj* -1) + a999accp->accamtpd),"999,999.99")
                  else
                          //NSHARE - (DISCOUNT + ADJUST*-1) + AMOUNT PAID
                           @ prow()+00,56 say transform(nshare -( a999accp->accsytadsc + (a999accp->accadj* -1) + a999accp->accamtpd),"999,999.99")
                           
                  endif
                */

                


        case nline == 9

                        if(a999accp->accbalold >= subsidy)
                            netsub = a999accp->accbalold - subsidy
                        elseif(a999accp->accbalold >= (subsidy * 2))
                            netsub = a999accp->accbalold - subsidy * 2
                        else
                            netsub = a999accp->accbalold
                        endif

                       // nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/4
                      // nexamf = ((a999accp->accsytass - subsidy) + a999accp->accadj) /
                        if cperiod == "1"
                                 ndue = "DECEMBER"
                                 nexamf = ((a999accp->accsytass - subsidy) + a999accp->accadj) / 1
                                 //new trapping 12-05-2017
                                 if((a999accp->accamtpd) <  (nexamf) )
                                      nexamf := (nexamf) - (a999accp->accamtpd)
                                 elseif((a999accp->accamtpd) >=  (nexamf))
                                      nexamf := 0
                                 endif
                        elseif cperiod == "2"
                                 ndue = "JANUARY"
                                 nexamf = (((a999accp->accsytass - subsidy) - (a999accp->accadj* -1)) / 2  + netsub) - a999accp->accamtpd

                                 //nexamf = nexamf - a999accp->accamtpd
                                 //(nexamf * 2) - a999accp->accamtpd
                                 //nexamf = (nexamf * 2) - (a999accp->accamtpd+a999accp->accsytadsc)

                                if(a999accp->accbalold > 0) .and. (a999accp->accbalold != subsidy)

                                     if((a999accp->accamtpd) <  nexamf )
                                          nexamf := nexamf
                                     else
                                          nexamf := 0
                                     endif
                                elseif(a999accp->accbalold == subsidy) .or. (a999accp->accbalold <= 0)
                                   nexamf = (nshare -( a999accp->accsytadsc + (a999accp->accadj* -1)))/2

                                   if((a999accp->accamtpd) <  nexamf )
                                        nexamf := nexamf  - (a999accp->accamtpd)
                                   elseif((a999accp->accamtpd+a999accp->accsytadsc) >=  nexamf * 2)
                                        nexamf := 0
                                   endif
                                endif

                        elseif cperiod == "3"
                                 ndue = "FEBRUARY"
                                 nexamf = ((a999accp->accsytass - subsidy) - (a999accp->accadj* -1)) / 3  + (netsub - a999accp->accamtpd)

                                 //nexamf = nexamf - a999accp->accamtpd
                                // nexamf = (nexamf * 3) - (a999accp->accamtpd)

                                 if((a999accp->accamtpd) <  nexamf )
                                      nexamf := nexamf
                                 else
                                      nexamf := 0
                                 endif
                        elseif cperiod == "4"
                                 ndue = "MARCH"
                                 //nexamf = a999accp->accbaltot
                                 //nexamf = nshare - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj* -1))

                                 if((a999accp->accamtpd) <  (nexamf * 4) )
                                      nexamf := (nexamf * 4) - (a999accp->accamtpd)
                                 elseif((a999accp->accamtpd+a999accp->accsytadsc) >=  (nexamf * 4))
                                      nexamf := 0
                                 endif
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
                         //@ prow()+00,56 say transform(int(namt)+a999accp->accbalold,"999,999.99")
                         @ prow()+00,56 say transform(int(namt),"999,999.99")
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



//THIS WILL RESET THE COMPUTATION for senior high
static function testresetrecord(cacctno)
local noldacct := 0,nadjust := 0,ndisc := 0,ntotdue := 0,;
      namtpd := 0,nbal := 0, acctno
      
//if fask(13,"  Are you sure to Reset/Recompute Account ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1

        ayytpayp->(sx_setscope(_TOP_SCOPE   ,cacctno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,cacctno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
                fask(13,"  Processing Recompute. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[11],.f.,nil)
                do case
                        case ayytpayp->paytag == _POSTED
                                namtpd += ayytpayp->payamt
                        case ayytpayp->paytag == _FORWARDED
                                if ayytpayp->payamt < 0
                                        nadjust += ayytpayp->payamt
                                elseif ayytpayp->payamt > 0
                                        noldacct += ayytpayp->payamt
                                endif
                        case ayytpayp->paytag == _DISCOUNT
                                ndisc += ayytpayp->payamt
                        case ayytpayp->paytag == _ADJUSTMENT
                                nadjust += ayytpayp->payamt
                        case ayytpayp->paytag == _SHORT_TERM
                                nadjust += ayytpayp->payamt
                endcase
                ayytpayp->(dbskip())
        enddo
        ayytpayp->(clearscope())

        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accduetot     := a999accp->accsytass + noldacct + nadjust - ndisc 
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := a999accp->accduetot - namtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())
return(nil)
//END OF RESET RECORDS FUNCTION



//THIS WILL RESET THE COMPUTATION FOR EJH
static function EJHresetrecord(cacctno)
local noldacct := 0,nadjust := 0,ndisc := 0,ntotdue := 0,;
      namtpd := 0,nbal := 0, acctno
      
//if fask(13,"  Are you sure to Reset/Recompute Account ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1

        ayytpayp->(sx_setscope(_TOP_SCOPE   ,cacctno))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,cacctno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
                fask(13,"  Processing Recompute. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[11],.f.,nil)
                do case
                        case ayytpayp->paytag == _POSTED
                                namtpd += ayytpayp->payamt
                        case ayytpayp->paytag == _FORWARDED
                                if ayytpayp->payamt < 0
                                        nadjust += ayytpayp->payamt
                                elseif ayytpayp->payamt > 0
                                        noldacct += ayytpayp->payamt
                                endif
                        case ayytpayp->paytag == _DISCOUNT
                                ndisc += ayytpayp->payamt
                        case ayytpayp->paytag == _ADJUSTMENT
                                nadjust += ayytpayp->payamt
                        case ayytpayp->paytag == _SHORT_TERM
                                nadjust += ayytpayp->payamt
                endcase
                ayytpayp->(dbskip())
        enddo
        ayytpayp->(clearscope())

        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accduetot     := a999accp->accsytass - (noldacct + nadjust) // THIS THE TOTAL PAYMENTS PAID LAST TERM (GE USAB PAG 12-04)
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := a999accp->accduetot - namtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())
return(nil)
//END OF RESET RECORDS FUNCTION FOR EJH



*------------------------------------------------------------------------------*
