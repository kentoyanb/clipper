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
      opentermfile,aopen2files,aprv2setup,cprocsts,nctr,aentryscr,cyytenrp,cyytskdp,ayytpayp,ayytepb,;
      cterm,cdesc,cidno,cperiod
private aitems := {},nindex := 1

if(opentermfile := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Examination Permit by Student (Senior High)  ")
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
        ayytassp  := "a"+cterm+"assp"
        ayytepb   := "a"+cterm+"epb"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999stra",,_DBF_SHARED,,1},;
                                      {,,"a999prm",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        if(aprv2setup:=openwcheck({{,,ayytepb,"ayytepb",_DBF_SHARED,,1}})) == nil
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
                @ 04,02 say "                 [1-st,2-nd,3-rd,4-th] [SUMMER: M F]" color memvar->colorarray[02]
                @ 04,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "1234MF"
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
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(opentermfile)
return(nil)

//print by student sa senior high
static function pexambystudent(cterm,cdesc,cidno,cperiod)
  local nctr := 0,skdno, nlastelem, accntnum ,nline := 0, nover := 0,nmax := 0 , yrlvl
  memvar->aitems := {_X_EMPTY}
  memvar->nindex := 1

  cyytenrp->(dbseek(cidno))
  
  if a999accp->(dbseek("1"+cidno))
      accntnum := "1"+cidno
  elseif a999accp->(dbseek("2"+cidno))
      accntnum := "2"+cidno
  endif
  
  //check if ang student ky grade 11 or 12 sa enrp ( g11 = GB , g12 = GC)
  if(cyytenrp->enrcolcod2 == "GB")
            yrlvl = "11"
  elseif(cyytenrp->enrcolcod2 == "GC")
            yrlvl = "12"
  endif
  a999prm->(dbseek(a999accp->accfeeyr+cyytenrp->enrcolcod+cterm+yrlvl))  //search sa iyang promotional discount amount

  **printing**
  headerbygradelevel(cidno,cdesc)
  
  /*if len(memvar->aitems) > 19
          nmax := 19
  else
          nmax := len(memvar->aitems)
  endif*/
  
  testresetrecord(accntnum)

  //@ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
  nover := 0
  if nline <= 19
          nctr := nline + 1
          for nline := nctr to 19
                  dispsummary(nline,nover,cperiod, accntnum,cterm)
                  nover := 1
          next
  endif

bygradelevelfooter(cperiod,cterm)
  *__eject()
return(nil)


//permit by sudent for elem and junior high
function ejhpermitbystudent()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      opentermfiles2,aopen2files,aprv2setup,cprocsts,nctr,aentryscr,cyytenrp,cyytskdp,ayytpayp,ayytepb,;
      cterm,cdesc,cidno,cperiod
private aitems := {},nindex := 1

if(opentermfiles2 := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Examination Permit by Student (Elementary/Junior High)  ")
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

        if alltrim(substr(cterm,3,1)) == "2"
                       fask(10,"Exam Permit is NOT AVAILABLE for Elementary/ ;"+;
                        "Junior High during 2nd SEMESTER. ",{" Ok "},memvar->colorarray[05],.t.,nil)
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
        ayytassp := "a"+cterm+"assp"
        ayytepb   := "a"+cterm+"epb"
        /*
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"a999stra",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)


        */
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999stra",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        if(aprv2setup:=openwcheck({{,,ayytepb,"ayytepb",_DBF_SHARED,,1}})) == nil
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
                @ 04,02 say "                 [1-Sept,2-Oct,3-Nov,4-Dec,5-Jan,6-Feb,7-Mar,8-Apr,9-May]" color memvar->colorarray[02]
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
        closewcheck(aprv2setup)
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
  elseif a999accp->(dbseek("2"+cidno))
      accntnum := "2"+cidno
  endif
  
  EJHresetrecord(accntnum)

  **printing**
  ejhheaderbystudent(cidno,cdesc)
  if len(memvar->aitems) > 19
          nmax := 19
  else
          nmax := len(memvar->aitems)
  endif
  
  //@ prow()+01,18 say transform(cyytenrp->enrunt,"99.9")
  nover := 0
  if nline < 19
          nctr := nline + 1
          for nline := nctr to 19
                  EJHdispsummary(nline,nover,cperiod,cterm)
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

//ejh header by grade level printing
static function ejhheader(cidno,cdesc)
a999accp->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))
//@ prow()+00,00 say "UNIVERSITY OF CEBU (METC)"
@ prow()+08,00 say padc(alltrim(cdesc),80)
@ prow()+01,00 say right(a999accp->accidno,8)
@ prow()+00,10 say alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname
@ prow()+00,62 say c999colp->coldesabr//+" "+cyytenrp->enryrlevl
@ prow()+01,00 say "                              STATEMENT OF ACCOUNT"

return(nil)

//ejh header by student printing
static function ejhheaderbystudent(cidno,cdesc)
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))
//@ prow()+00,00 say "UNIVERSITY OF CEBU (METC)"
@ prow()+08,00 say padc(alltrim(cdesc),80)
@ prow()+01,00 say cidno
@ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam
@ prow()+00,62 say c999colp->coldesabr//+" "+cyytenrp->enryrlevl
@ prow()+01,00 say "                              STATEMENT OF ACCOUNT"

return(nil)


static function headerbygradelevel(cidno,cdesc)
local ngrant
c999sm1p->(dbseek(cidno))
c999colp->(dbseek(cyytenrp->enrcolcod))

if a999accp->(dbseek("1"+cidno))
    cidno := a999accp->accidno
elseif a999accp->(dbseek("2"+cidno))
    cidno := a999accp->accidno
endif

if a999accp->accpbcprv == "1"
   ngrant = "PUBLIC"
elseif a999accp->accpbcprv == "2"
   ngrant = "PRIVATE WITH ESC"
else
   ngrant = "NONE"
endif

@ prow()+04,00 say padc(alltrim(cdesc),80) 
@ prow()+01,00 say right(cidno,8)

if a999accp->acccolcod == "GA"
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + "GRADE 10"   
else
    @ prow()+00,10 say alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam +"    " + if(a999accp->accyrlevl == "2","GRADE 12","GRADE 11")
    @ prow()+01,00 say "TRACK - STRAND: "+if(cyytenrp->enrcolcod == "TM","TECHVOC - ","ACADEMICS - ") + alltrim(c999colp->coldesabr)
    @ prow(),36 say "GRANT:  "+ ngrant
endif

@ prow()+01,00 say "                             STATEMENT OF ACCOUNT"
@ prow()+01,00 say " "
return(nil)


//senior high footers
static function bystudentfooter(cperiod,cterm)
@ 20,00 say "This serves as your"
@ 20,50 say "Exam PERMIT if validated"

if alltrim(substr(cterm,3,1)) == "1"
    @ 21,20 say if(cperiod == "1","JULY",;
                if(cperiod == "2","AUGUST",;
                if(cperiod == "M","SUMMER",;
                if(cperiod == "F","SUMMER",;
                if(cperiod == "3","SEPTEMBER","OCTOBER")))))
else
    @ 21,20 say if(cperiod == "1","DECEMBER",;
                if(cperiod == "2","JANUARY",;
                if(cperiod == "M","SUMMER",;
                if(cperiod == "F","SUMMER",;
                if(cperiod == "3","FEBRUARY","MARCH")))))
endif
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

//senior high footers
static function bygradelevelfooter(cperiod,cterm)
@ 26,00 say " This serves as your"
@ 26,50 say "Exam PERMIT if validated"

if alltrim(substr(cterm,3,1)) == "1"
    @ 26,20 say if(cperiod == "1","JULY",;
                    if(cperiod == "2","AUGUST",;
                    if(cperiod == "M","SUMMER",;
                    if(cperiod == "F","SUMMER",;
                    if(cperiod == "3","SEPTEMBER","OCTOBER")))))
else
    @ 26,20 say if(cperiod == "1","DECEMBER",;
                if(cperiod == "2","JANUARY",;
                if(cperiod == "M","SUMMER",;
                if(cperiod == "F","SUMMER",;
                if(cperiod == "3","FEBRUARY","MARCH")))))
endif

@ 27,00 say "Date: "
@ 27,07 say dtoc(date())
@ 27,20 say "Acctg. In-Charge:"
@ 27,46 say "UC-METC/SAC.DOC/001/REV.03"

/*@ 26,00 say ""
@ 26,46 say ""
@ 26,20 say " "
@ 27,00 say ""
@ 27,07 say ""
@ 27,20 say ""
@ 27,46 say ""*/

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
      aopen1files,aopen2files,aprv2setup,ccolcode,cperiod,cyrlevel,cterm,cdesc,ayytpayp,ayytepb,;
      cfile,ccdx,cprocsts,clname,cfname,csection, sectf, sectcod,colcod2
private aitems := {}, nindex := 1,;
        cdummy := "perm"+strzero(naccess,2),student

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"Print Examination Permit by Senior High Strand")
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
        ayytassp  := "a"+cterm+"assp"
        ayytepb := "a"+cterm+"epb"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999prcp",,_DBF_SHARED,,1},;
                                      {,,"a999stra",,_DBF_SHARED,,1},;
                                      {,,"a999prm",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"section",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
        endif

        if(aprv2setup:=openwcheck({{,,ayytepb,"ayytepb",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        
        ccolcode := "UC"
        cperiod  := "1"
        cyrlevel := "GB"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        csection := space(len(section->secdesc))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
  

                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [UC - ALL STRAND]" color memvar->colorarray[02]
                @ 03,02 say "Strand :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
               
               
                @ 04,02 say "                   " color memvar->colorarray[02]
                @ 04,02 say "Year Level (GB-11, GC-12) :";
                        color memvar->colorarray[02];
                        get cyrlevel pict "@!";
                        valid ! empty(cyrlevel)

                @ 05,02 say "                 [1-st,2-nd,3-rd,4-th] [SUMMER: M F]" color memvar->colorarray[02]
                @ 05,02 say "Exam. Period :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "1234MF"
               

                /*
                @ 05,02 say "                   [1-ST,2-ND,3-RD,4-TH,5-TH]" color memvar->colorarray[02]
                @ 05,02 say "Exam. Period :";
                    color memvar->colorarray[02];
                    get cperiod pict "@!";
                    valid cperiod $ "12345"
                */
       
                @ 06,02 say "Last Student Printed:" color memvar->colorarray[02]
                @ 07,02 say "    Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 08,02 say "    First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"

                setcursor(1);set(_SET_CONFIRM,.t.)
                
                @ 09,02 say "    Section    :";
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

               
                if ! ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU,UC"
                        fask(10,"Viewing of College ("+ccolcode+") is NOT ALLOWED in  ;"+;
                        "BasicEd Accounting Program",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
                        fask(10,"Generate the Elem & Junior High ("+ccolcode+") Permit in  ;"+;
                        "** Exam Permit (Elem & Junior High) Menu** ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if !section->(dbseek(csection))
                        fask(10,"  SECTION not found in file.  "+left(section->secdesc, 1)+"2",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                section->(dbseek(csection))
                //sectcod = section->secdesc
                sectcod = section->seccode

                if whereprint({||pexambygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aopen1files)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
return(nil)

//PRINT EXAM BY GRADE LEVEL SENIOR HIGH
static function pexambygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname,sectcod)
local nctr,skdno,nlastelem,nline,nover,nmax,accntnum, yrlvl;
 
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
            accntnum := a999accp->accidno//"1"+cyytenrp->enridno
           // fask(10,"  Processing student no 1. "+accntnum+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
             accntnum := a999accp->accidno//"2"+cyytenrp->enridno
          //   fask(10,"  Processing student no 2. "+accntnum+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        endif
        testresetrecord(accntnum)
         //-----ADDED 11092017 TO RECOMPUTE-------------

       
        if ccolcode != "UC"
            
            
            if alltrim(cyytenrp->enrsection) == alltrim(sectcod) .and. alltrim(cyytenrp->enrcolcod2) == alltrim(cyrlevel)
              fask(10,"  Processing student no. "+accntnum+"  "+sectcod,{" Ok "},memvar->colorarray[06],.f.,nil)
                      student->(dbappend())
                      student->idno    := cyytenrp->enridno
                      student->lname   := a999accp->acclname
                      student->fname   := a999accp->accfname
                      student->mname   := a999accp->accmname
                      student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl
            endif
        elseif ccolcode == "UC"
              if cyytenrp->enrcolcod $ "TM,GS,PB,ST,HU"
                if alltrim(cyytenrp->enrsection) == alltrim(sectcod) .and. alltrim(cyytenrp->enrcolcod2) == alltrim(cyrlevel)
                  fask(10,"  Processing student no. "+accntnum+"  "+cyytenrp->enrcolcod,{" Ok "},memvar->colorarray[06],.f.,nil)
                          student->(dbappend())
                          student->idno    := cyytenrp->enridno
                          student->lname   := a999accp->acclname
                          student->fname   := a999accp->accfname
                          student->mname   := a999accp->accmname
                          student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl
                endif
              endif
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
        //fask(10,"  Processing student "+alltrim(student->lname)+", "+alltrim(student->fname)+" "+student->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if (alltrim(clname)+alltrim(cfname)) < (alltrim(student->lname)+alltrim(student->fname))
                memvar->aitems := {_X_EMPTY}
                memvar->nindex := 1
                nline := 0
                cyytenrp->(dbseek(student->idno))
                if a999accp->(dbseek("1"+student->idno))
                    accntnum = "1"+student->idno
                    //fask(10,"  Processing student no. "+accntnum+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                elseif a999accp->(dbseek("2"+student->idno))
                    accntnum = "2"+student->idno
                    //fask(10,"  Processing student no. "+accntnum+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                endif
                
                //check if ang student ky grade 11 or 12 sa enrp ( g11 = GB , g12 = GC)
                if(cyytenrp->enrcolcod2 == "GB")
                    yrlvl = "11"
                elseif(cyytenrp->enrcolcod2 == "GC")
                    yrlvl = "12"
                endif

                a999prm->(dbseek(a999accp->accfeeyr+cyytenrp->enrcolcod+cterm+yrlvl))  //search sa iyang promotional discount amount

                headerbygradelevel(student->idno,cdesc) //BY SECTION

                        nover := 0 
                        if nline <= 19 //17 //19
                                nctr := nline + 1
                                for nline := nctr to 19 //17 //19
                                        dispsummary(nline,nover,cperiod,accntnum,cterm)
                                        nover := 1
                                next
                        endif       
        endif
		    bygradelevelfooter(cperiod,cterm)
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
      ejhaopen1files,aopen2files,ejhaprv2setup,ccolcode,cperiod,cyrlevel,cterm,cdesc,ayytpayp,t,ayytepb,;
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
        
        if alltrim(substr(cterm,3,1)) == "2"
                       fask(10,"Exam Permit is NOT AVAILABLE for Elementary/ ;"+;
                        "Junior High during 2nd SEMESTER. ",{" Ok "},memvar->colorarray[05],.t.,nil)
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
        ayytassp := "a"+cterm+"assp"
        ayytepb := "a"+cterm+"epb"

        if(ejhaopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999stra",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)

        endif

        if(ejhaprv2setup:=openwcheck({{,,ayytepb,"ayytepb",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        ccolcode := "UC"
        cperiod  := "1"
*BE        cyrlevel := "1"
        clname   := space(len(a999accp->acclname))
        cfname   := space(len(a999accp->accfname))
        do while .t.
                restscr(aentryscr)
                commandline("Г         F4 - View Collge File        Г           ESC - Previous              Г")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [UC - ALL GRADES(N1-10)]" color memvar->colorarray[02]
                @ 03,02 say "Grade Code :";
                        color memvar->colorarray[02];
                        get ccolcode pict "@!";
                        valid ! empty(ccolcode)
               
                @ 04,02 say "                   [1-Sept,2-Oct,3-Nov,4-Dec,5-Jan,6-Feb,7-Mar,8-Apr,9-May]" color memvar->colorarray[02]
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

                if ! ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU,UC"
                        fask(10,"Viewing of College ("+ccolcode+") is NOT ALLOWED in  ;"+;
                        "BasicEd Accounting Program",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if ccolcode $ "TM,GS,PB,ST,HU"
                        fask(10,"Generate the Senior High ("+ccolcode+") Permit in  ;"+;
                        "** Exam Permit (Senior High) Menu** ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if whereprint({||ejhprntbygradelevel(cterm,cdesc,ccolcode,cyrlevel,cperiod,clname,cfname)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(ejhaopen2files)
        closewcheck(ejhaprv2setup)
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
        elseif a999accp->(dbseek("2"+cyytenrp->enridno))
             accntnum := "3"+cyytenrp->enridno
        endif
        EJHresetrecord(accntnum)
         //-----ADDED 11092017 TO RECOMPUTE-------------

        if ccolcode != "UC"
            c999colp->(dbseek(cyytenrp->enrcolcod))
            student->(dbappend())
            student->idno    := cyytenrp->enridno
            student->lname   := a999accp->acclname
            student->fname   := a999accp->accfname
            student->mname   := a999accp->accmname
            student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl
        elseif ccolcode == "UC"
            if cyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA"
                c999colp->(dbseek(cyytenrp->enrcolcod))
                student->(dbappend())
                student->idno    := cyytenrp->enridno
                student->lname   := a999accp->acclname
                student->fname   := a999accp->accfname
                student->mname   := a999accp->accmname
                student->course  := c999colp->coldesabr //+" "+cyytenrp->enryrlevl
            endif
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
                    student->idno := a999accp->accidno 
                elseif a999accp->(dbseek("2"+student->idno))
                    student->idno := a999accp->accidno 
                endif
                               
                ejhheader(student->idno,cdesc) //BY SECTION
                        nover := 0                       
                        if nline < 19 // 19
                                nctr := nline + 1
                                for nline := nctr to 19
                                        EJHdispsummary(nline,nover,cperiod,cterm)
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
static function EJHdispsummary(nline,nrow,cperiod,cterm)
local namt := 0 , nexamf := 0 , nadj := 0, balance := 0, jhdiscount := 0 , subsidy := 0, ssflag := 0 ,adjplus := 0 , adjless := 0, duetot := 0



if(a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")

    ayytpayp->(sx_setscope(_TOP_SCOPE   ,a999accp->accidno))
    ayytpayp->(sx_setscope(_BOTTOM_SCOPE,a999accp->accidno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
              if(ayytpayp->payadjcod == "SS") //kung naay subsidy
                subsidy = ayytpayp->payamt
                ssflag = 1
              endif

          ayytpayp->(dbskip())
        enddo
   ayytpayp->(clearscope())

  if subsidy == 0
      a999stra->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+cterm+a999accp->accpbcprv))
      subsidy = a999stra->strndamoun
      //ssflag = 0
  endif

end if


///////////////////////////////////////////

if ssflag == 1
    balance = a999accp->accbalold + a999accp->accsyttui + a999accp->accsytoth + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accadj - (a999accp->accamtpd - subsidy ) - a999accp->accsytadsc
else
    balance = a999accp->accbalold + a999accp->accsyttui + a999accp->accsytoth + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accadj - a999accp->accamtpd - a999accp->accsytadsc
endif
balance = balance - subsidy

if a999accp->accbalold > 0
    duetot = a999accp->accsyttui  + a999accp->accbalold+ a999accp->accsytoth + a999accp->accsytmisc + a999accp->accsytlab + if(a999accp->accadj > 0,a999accp->accadj,0) 
else
    duetot = a999accp->accsyttui + a999accp->accsytoth + a999accp->accsytmisc + a999accp->accsytlab + if(a999accp->accadj > 0,a999accp->accadj,0)
endif


do case
        
        case nline == 3
                @ prow()+nrow,32 say "FEES:"
        case nline == 4
                @ prow()+nrow,34 say "OLD ACCOUNT"
                @ prow()+00,52 say transform(a999accp->accbalold,"999,999.99")
        case nline == 5
                @ prow()+nrow,34 say "TUITION"
                @ prow()+00,52 say transform(a999accp->accsyttui,"999,999.99")
        case nline == 6
                @ prow()+nrow,34 say "MISC."
                @ prow()+00,52 say transform(a999accp->accsytmisc,"999,999.99")
        case nline == 7
                @ prow()+nrow,34 say "REGISTRATION" //a999accp->accsytmisc
                @ prow()+00,52 say transform(a999accp->accsytoth,"999,999.99")
        case nline == 8
                @ prow()+nrow,34 say "LAB./ AIRCON / LMS"
                @ prow()+00,52 say transform(a999accp->accsytlab,"999,999.99")
        
        case nline == 9
                @ prow()+nrow,34 say "ADJUSTMENT"
                @ prow()+00,52 say if(a999accp->accadj > 0,transform(a999accp->accadj,"999,999.99"),transform(0,"999,999.99"))

        case nline == 10
                @ prow()+nrow,32 say "TOTAL DUE"
                //@ prow()+00,60 say transform(a999accp->accbalold + a999accp->accsytass  + if(a999accp->accadj < 0,a999accp->accadj * -1,0),"999,999.99")
                //@ prow()+00,60 say transform(a999accp->accsyttot,"999,999.99")
                @ prow()+00,60 say transform(duetot,"999,999.99")

                
                    /*@ prow()+00,60 say transform(a999accp->accsyttui  + a999accp->accbalold+;
                                                 a999accp->accsytoth + a999accp->accsytmisc +;
                                                 a999accp->accsytlab + if(a999accp->accadj > 0,a999accp->accadj,0),"999,999.99") */
              
                    /*@ prow()+00,60 say transform(a999accp->accsyttui  +;
                                                 a999accp->accsytoth + a999accp->accsytmisc +;
                                                 a999accp->accsytlab + if(a999accp->accadj > 0,a999accp->accadj,0),"999,999.99") */

                @ prow()+00,32 say replicate("_",38)

        case nline == 11
                if(a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                  @ prow()+nrow,32 say "LESS: SUBSIDY"
                  @ prow()+00,50 say transform(subsidy,"999,999.99")
                endif           
        case nline == 12
                @ prow()+nrow,32 say "LESS: PAYMENTS"
                if ssflag == 1
                    @ prow()+00,50 say transform(a999accp->accamtpd - subsidy,"999,999.99")
                else
                    @ prow()+00,50 say transform(a999accp->accamtpd,"999,999.99")
                endif
                //@ prow()+00,50 say transform(a999accp->accamtpd + a999accp->accduetot,"999,999.99")


                //@ prow()+00,50 say transform(a999accp->accamtpd,"999,999.99")
        case nline == 13
                         @ prow()+nrow,32 say "LESS: DISCOUNT"
                         @ prow()+00,50 say transform(a999accp->accsytadsc,"999,999.99")
                         
                
        case nline == 14
                /*if a999accp->acccolcod == "N1" .or. a999accp->acccolcod == "K1"
                        @ prow()+nrow,32 say "LESS: ADJUSTMENT"
                        @ prow()+00,50 say if(a999accp->accadj < 0,transform(namt,"999,999.99"),transform(a999accp->accadj,"999,999.99"))
                else*/
                        @ prow()+nrow,32 say "LESS: ADJUSTMENT"
                        @ prow()+00,50 say if(a999accp->accadj < 0,transform(a999accp->accadj * -1,"999,999.99"),transform(namt,"999,999.99"))

                //endif

       

        case nline == 15
                @ prow()+nrow,32 say "BALANCE"

                //balance = a999accp->accbalold + a999accp->accadj - (a999accp->accamtpd-a999accp->accsytadsc)
               // balance = a999accp->accbalold + a999accp->accsyttui + a999accp->accsytoth + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accadj - a999accp->accamtpd - a999accp->accsytadsc

                //if(a999accp->accadj > 0,transform(a999accp->accadj,"999,999.99"),transform(namt,"999,999.99"))

               // balance = balance - subsidy

                /*if(a999accp->accadj > 0 )
                    //balance = a999accp->accbalold + a999accp->accadj - (a999accp->accamtpd+a999accp->accsytadsc)
                    balance = a999accp->accbalold + a999accp->accadj - (a999accp->accamtpd-a999accp->accsytadsc)
                else
                    balance = a999accp->accbalold  - (a999accp->accamtpd+a999accp->accsytadsc+ (a999accp->accadj*-1))
                endif*/

                //@ prow()+00,60 say transform(a999accp->accbalold - (a999accp->accamtpd+a999accp->accsytadsc),"999,999.99")
                @ prow()+00,60 say transform(balance,"999,999.99")
                @ prow()+00,32 say replicate("_",38)
        case nline == 17

//--new computation for Basic Education

               if a999accp->accadj > 0
                    adjplus += a999accp->accadj
              elseif a999accp->accadj < 0
                    adjless -= a999accp->accadj
              endif
            

                if cperiod == "1"
                      @ prow()+nrow+1,32 say "DUE FOR SEPTEMBER"
                      if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                            namt = (duetot - subsidy) / 9
                        else
                            //namt = (duetot - 500) / 9
                            namt = duetot / 9
                        endif
                        //( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt
                                          nexamf := 0
                                else
                                      nexamf = namt  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else

                                if (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt 
                                      nexamf := 0
                                else
                                      nexamf = namt  - (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= namt  + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = namt  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd   + a999accp->accsytadsc ) >= namt  + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = namt  - (a999accp->accamtpd   + a999accp->accsytadsc )
                                endif
                            endif

                        endif

                        /* 10272021

                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            nexamf = (balance / 9)//(((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                        else
                            nexamf = (balance / 9)//((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                        endif

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments (a999accp->accadj*-1 - 500)
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc +  (a999accp->accadj*-1)) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy + a999accp->accsytadsc) >= nexamf + a999accp->accadj)
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if ((a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj)
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */

                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf 
                                          nexamf := 0
                                else
                                      nexamf = (nexamf) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      nexamf = (nexamf) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = nexamf - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = nexamf - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif      */

                     
                elseif cperiod == "2"
                        @ prow()+nrow+1,32 say "DUE FOR OCTOBER"

                        /*if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                           nexamf = (balance / 8)//(a999accp->accduetot  - subsidy) / 9
                        else
                            nexamf = (balance / 8 )
                        endif 
                        10272021

                        
                        
                        
                        //TODO
                        if a999accp->accadj < 0 
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 2 // nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 2 //nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt *2)+ a999accp->accadj // nexamf
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 2) + a999accp->accadj // nexamf
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                              namt = (duetot - subsidy) / 9
                        else
                              //namt = (duetot - 500) / 9
                              namt = duetot / 9
                        endif
                        //( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 2
                                          nexamf := 0
                                else
                                      nexamf = (namt * 2) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else

                                if (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 2
                                      nexamf := 0
                                else
                                      nexamf = (namt * 2) - (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 2) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 2)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd   + a999accp->accsytadsc ) >= (namt * 2) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 2) - (a999accp->accamtpd   + a999accp->accsytadsc )
                                endif
                            endif

                        endif      

                elseif cperiod == "3"
                        @ prow()+nrow+1,32 say "DUE FOR NOVEMBER"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                              namt = (duetot - subsidy) / 9
                        else
                            namt =  duetot  / 9
                        endif

                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 3
                                          nexamf := 0
                                else
                                      nexamf = (namt * 3) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 3
                                      nexamf := 0
                                else
                                      nexamf = (namt * 3) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 3) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 3)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 3) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 3) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif
                        endif

                        /*
                        10272021
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 7) //(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 7 )
                        endif


                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */

                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 3
                                          nexamf := 0
                                else
                                      nexamf = (nexamf * 3) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 3
                                      nexamf := 0
                                else
                                      nexamf = (nexamf * 3) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 3) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 3) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (nexamf * 3) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf * 3) + a999accp->accadj
                                      nexamf := 0
                                else
                                     // nexamf = (nexamf * 3) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                     nexamf = (nexamf * 3)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif   */   
                       
                elseif cperiod == "4"
                        @ prow()+nrow+1,32 say "DUE FOR DECEMBER"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                          namt = (duetot - subsidy) / 9
                        else
                            namt = duetot / 9
                        endif

                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 4
                                          nexamf := 0
                                else
                                      nexamf = (namt * 4) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 4
                                      nexamf := 0
                                else
                                      nexamf = (namt * 4) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 4) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 4)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 4) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 4) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif
                        endif

                        /*
                         10272021
                         if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 6)//(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 6 )
                        endif

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */


                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 4
                                          nexamf := 0
                                else
                                      nexamf = (nexamf * 4) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 4
                                      nexamf := 0
                                else
                                      nexamf = (nexamf * 4) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 4) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 4) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (nexamf * 4) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf * 4) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 4) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (nexamf * 4)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif*/
                        
               
                elseif cperiod == "5"
                        @ prow()+nrow+1,32 say "DUE FOR JANUARY"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                            namt = (duetot - subsidy) / 9
                        else
                            //namt = (duetot - 500) / 9
                            namt = duetot  / 9
                        endif
                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 5
                                          nexamf := 0
                                else
                                      nexamf = (namt * 5) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 5
                                      nexamf := 0
                                else
                                      nexamf = (namt * 5) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 5) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 5)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 5) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 5) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif
                        endif

                        /* 10272021

                         if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 5 ) //(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 5 )
                        endif

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */

                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 5
                                          nexamf := 0
                                else
                                      nexamf = (nexamf * 5) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 5
                                      nexamf := 0
                                else
                                      nexamf = (nexamf * 5) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 5) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 5) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (nexamf * 5)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf * 5) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 5) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (nexamf * 5)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif
                        */

                elseif cperiod == "6"
                        @ prow()+nrow+1,32 say "DUE FOR FEBRUARY"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                            namt = (duetot - subsidy) / 9
                        else
                            namt = duetot  / 9
                        endif
                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 6
                                          nexamf := 0
                                else
                                      nexamf = (namt * 6) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1))//(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 6
                                      nexamf := 0
                                else
                                      nexamf = (namt * 6) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 6) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 6)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 6) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 6) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif
                        endif

                        /* 10272021

                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 4 )//(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 4 )
                        endif


                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */

                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 6
                                          nexamf := 0
                                else
                                      nexamf = (nexamf * 6) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 6
                                      nexamf := 0
                                else
                                      nexamf = (nexamf * 6) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 6) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 6) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (nexamf * 6)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf * 6) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = ((nexamf * 6) + a999accp->accadj) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf =  (balance / 4 )//((nexamf * 6) + a999accp->accadj ) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif
                       */

                elseif cperiod == "7"
                        @ prow()+nrow+1,32 say "DUE FOR MARCH"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                            namt = (duetot - subsidy) / 9
                        else
                            namt = duetot / 9
                        endif
                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 7
                                          nexamf := 0
                                else
                                      nexamf = (namt * 7) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 7
                                      nexamf := 0
                                else
                                      nexamf = (namt * 7) - (a999accp->accamtpd + a999accp->accsytadsc +  (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 7) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 7)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 7) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 7) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif
                        endif

                        /* 10272021
                       
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 3 ) //(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 3 )
                        endif


                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif 10272021 */

                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 7
                                          nexamf := 0
                                else
                                      nexamf = (nexamf * 7) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 7
                                      nexamf := 0
                                else
                                      nexamf = (nexamf * 7) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 7) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 7) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (nexamf * 7)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (nexamf * 7) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = ((nexamf * 7) + a999accp->accadj) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (nexamf * 7)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                endif
                            endif

                        endif*/
   
                elseif cperiod == "8"
                        @ prow()+nrow+1,32 say "DUE FOR APRIL"
                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //namt = ((duetot - 500) - subsidy) / 9
                             namt = (duetot - subsidy) / 9
                        else
                            namt = duetot / 9
                        endif
                        //namt = (duetot - 500) / 9//( (a999accp->accsytass - 500) / 9)

                        if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= namt * 8
                                          nexamf := 0
                                else
                                      nexamf = (namt * 8) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            else
                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1)) >= namt * 8
                                      nexamf := 0
                                else
                                      nexamf = (namt * 8) - (a999accp->accamtpd + a999accp->accsytadsc +  (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (namt * 8) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                    nexamf = (namt * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= (namt * 8) + a999accp->accadj
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                    nexamf = (namt * 8) - (a999accp->accamtpd  + a999accp->accsytadsc)
                                endif
                            endif
                        endif

                        /* 10272021

                        if (a999accp->acccolcod == "G7" .or. a999accp->acccolcod == "G8" .or. a999accp->acccolcod == "G9" .or. a999accp->acccolcod == "GA")
                            //nexamf = (((a999accp->accsyttot + a999accp->accbalold) - subsidy) - 500)/ 9
                             nexamf = (balance / 2 ) //(a999accp->accduetot  - subsidy) / 9
                        else
                            //nexamf = ((a999accp->accsyttot + a999accp->accbalold) - 500) / 9
                             nexamf = (balance / 2 )
                        endif 10272021 */


                        /*if a999accp->accadj < 0
                            if ssflag == 1 //if nanay ni sud nga subsidy payments
                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                          nexamf := 0
                                else
                                      nexamf := nexamf
                                endif
                            else

                                if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                      nexamf := 0
                                else
                                      //nexamf = (nexamf * 8) - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      nexamf := nexamf
                                endif
                            endif

                        else //if adjustment ky positive - meaning naay dungag bayad

                            if ssflag == 1 //if nanay ni sud nga subsidy payments

                                if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                     nexamf := nexamf
                                endif

                            else
                                if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf + a999accp->accadj
                                      nexamf := 0
                                else
                                      
                                    //nexamf = (nexamf * 8)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      nexamf := nexamf
                                endif
                            endif

                        endif*/

                elseif cperiod == "9"
                        @ prow()+nrow+1,32 say "DUE FOR MAY" 
                        if balance <= 0 
                            nexamf := 0
                        else
                            nexamf := balance
                        endif
                endif

                if nexamf < 0
                  @ prow()+00,60 say transform(0,"999,999.99")
                else
                   @ prow()+00,60 say transform(int(nexamf),"999,999.99")
                   //@ prow()+00,60 say transform(int(((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) )),"999,999.99")
                   // @ prow()+00,60 say transform(int((a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))),"999,999.99")
                  // @ prow()+00,60 say transform(int(nexamf * 8),"999,999.99")

              endif

              
              
              insertExamDue(cyytenrp->enridno, a999accp->acclname, a999accp->accfname, a999accp->accmname, cyytenrp->enrcolcod, cyytenrp->enrcolcod2, a999accp->accbalold, a999accp->accsyttui, a999accp->accsytoth, a999accp->accsytmisc, a999accp->accsytlab, adjplus, a999accp->accduetot, a999accp->accamtpd, a999accp->accsytadsc, adjless, balance, nexamf, cperiod, 0, subsidy, 0)

                //murag wa ni gamit sa ubos
                /*do case
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
                endcase*/

               @ prow()+00,32 say replicate("_",38)
endcase
return(nil)
//-----------------------------------------------------------------------------------------------------------------------------


//NEW FORMAT
//DISPLAY SUMMARY FOR SENIOR HIGH
static function dispsummary(nline,nrow,cperiod,cacctno,cterm)
local namt := 0 , nexamf := 0 , nadj := 0 , ndue, namtpd := 0, ngrant, nshare := 0,subsidy :=0, subsidy1 :=0,netsub :=0, balance := 0, private :=0 ,total :=0, public:=0 , ssflag := 0, scholar, adjless := 0, adjplus := 0
//wsub 1= 


//NEW ADD ON
// nadj -> the adjustment variable
//nshare -> means student share
// balance -> the balance variable (nshare -( discount + (adjust* -1) + amount paid)


ayytpayp->(sx_setscope(_TOP_SCOPE   ,cacctno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,cacctno))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
              if(ayytpayp->payadjcod == "SS") //kung naay subsidy
                //nadj = 0
                subsidy = ayytpayp->payamt
                ssflag = 1
              endif

          ayytpayp->(dbskip())
        enddo
ayytpayp->(clearscope())

if subsidy == 0 // if wala pay ge entry nga payment subsidy, gamiton ang ge entry sa subsidy master file
    a999stra->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+cterm+a999accp->accpbcprv))
    subsidy = a999stra->strndamoun
endif



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//NEW ADDED 1-08-2018
if ssflag == 1
    if(a999accp->accadj > 0) //KUNG NAAY ADJUSTMENT LIKE TUITION ADD ANG BAYRONON

      nshare =  (a999accp->accsytass+a999accp->accbalold+a999accp->accadj) - subsidy //THE STUDENT SHARE
      balance = nshare -( a999accp->accsytadsc + (a999accp->accamtpd -subsidy )) //THE BALANCE (STUDENT SHARE - (DISCOUNT + ADJUSTMENT + AMOUNT PAID))
    else
      nshare =  (a999accp->accsytass+a999accp->accbalold) - subsidy ////THE STUDENT SHARE
      balance = nshare  -( a999accp->accsytadsc + (a999accp->accadj*-1) + (a999accp->accamtpd -subsidy )) //THE BALANCE (STUDENT SHARE - (DISCOUNT + ADJUSTMENT + AMOUNT PAID))
    endif
else
    if(a999accp->accadj > 0) //KUNG NAAY ADJUSTMENT LIKE TUITION ADD ANG BAYRONON

      nshare =  (a999accp->accsytass+a999accp->accbalold+a999accp->accadj) - subsidy //THE STUDENT SHARE
      balance = nshare -( a999accp->accsytadsc + a999accp->accamtpd) //THE BALANCE (STUDENT SHARE - (DISCOUNT + ADJUSTMENT + AMOUNT PAID))
    else
      nshare =  (a999accp->accsytass+a999accp->accbalold) - subsidy ////THE STUDENT SHARE
      balance = nshare  -( a999accp->accsytadsc + (a999accp->accadj*-1) +a999accp->accamtpd) //THE BALANCE (STUDENT SHARE - (DISCOUNT + ADJUSTMENT + AMOUNT PAID))
    endif
endif

do case

        case nline == 1
                @ prow()+nrow,29 say "OLD ACCOUNT"
                @ prow()+00,56 say transform(a999accp->accbalold,"999,999.99")
        case nline == 2
                @ prow()+nrow,29 say "FEES:"
                @ prow()+nrow,31 say "TUITION"
                @ prow()+00,49 say transform(a999accp->accsyttui,"999,999.99")
        case nline == 3
                @ prow()+nrow,31 say "MISCELLANEOUS"
                @ prow()+00,49 say transform(a999accp->accsytmisc,"999,999.99")
        case nline == 4
                @ prow()+nrow,31 say "E-BOOK / LMS"
                @ prow()+00,49 say transform(a999accp->accsytlab,"999,999.99")
        case nline == 5
                @ prow()+nrow,31 say "REGISTRATION"
                @ prow()+00,49 say transform(a999accp->accsytoth,"999,999.99")
        case nline == 6
                @ prow()+nrow,31 say "ADJUSTMENT"
                @ prow()+00,49 say if(a999accp->accadj > 0,transform(a999accp->accadj,"999,999.99"),transform(namt,"999,999.99"))
        case nline == 7
                @ prow()+nrow,29 say "ASSESSMENT"
                //@ prow()+00,56 say transform(a999accp->accsytass,"999,999.99")

                if(a999accp->accadj > 0) //KUNG NAAY ADJUSTMENT LIKE TUITION ADD ANG BAYRONON

                    @ prow()+00,56 say transform(a999accp->accsyttui + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accsytoth + a999accp->accadj,"999,999.99")

                else

                    @ prow()+00,56 say transform(a999accp->accsyttui + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accsytoth,"999,999.99")

                endif

        case nline == 8
                @ prow()+nrow,29 say "TOTAL"
                if(a999accp->accadj > 0) //KUNG NAAY ADJUSTMENT LIKE TUITION ADD ANG BAYRONON

                    total = a999accp->accsyttui + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accsytoth + a999accp->accbalold + a999accp->accadj

                else
                
                    total = a999accp->accsyttui + a999accp->accsytmisc + a999accp->accsytlab + a999accp->accsytoth + a999accp->accbalold

                endif
                @ prow()+00,56 say transform(total,"999,999.99")
        case nline == 9
                @ prow()+nrow,31 say "LESS:PROMOTIONAL DISC"
                @ prow()+00,52 say transform(a999prm->promoamnt,"999,999.99")
        case nline == 10
                @ prow()+nrow,31 say "LESS: SUBSIDY"  
                @ prow()+00,52 say transform(subsidy,"999,999.99")        
        case nline == 11
                @ prow()+nrow,29 say "STUDENT SHARE"
                @ prow()+00,56 say transform(nshare,"999,999.99")        
        case nline == 12
                @ prow()+nrow,31 say "LESS: PAYMENT"
                if ssflag == 1
                    @ prow()+00,47 say transform(a999accp->accamtpd - subsidy,"999,999.99")
                else
                     @ prow()+00,47 say transform(a999accp->accamtpd,"999,999.99")
                endif
        case nline == 13
                @ prow()+nrow,31 say "LESS: DISCOUNT"
                @ prow()+00,47 say transform(a999accp->accsytadsc,"999,999.99")
        case nline == 14
                @ prow()+nrow,31 say "LESS: ADJUSTMENT"
               
                 @ prow()+00,47 say if(a999accp->accadj < 0 ,transform(a999accp->accadj * -1,"999,999.99"),transform(0,"999,999.99"))

        case nline == 15
                @ prow()+nrow,29 say "BALANCE"
                @ prow()+00,56 say transform(balance,"999,999.99")  

        case nline == 16
                        if cperiod == "1" 
                                if alltrim(substr(cterm,3,1)) == "1"
                                     ndue = "SEPTEMBER"
                                else
                                    ndue = "FEBRUARY"
                                endif

                                //nexamf =  ((nshare - 500) / 4)
                                nexamf =  (nshare / 4)

                                //nexamf = (balance/ 3) //((nshare - 500) / 4)
                                //nexamf = (nshare / 4)
                               
                                if a999accp->accadj < 0
                                      if ssflag == 1 //if nanay ni sud nga subsidy payments
                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= nexamf
                                                    nexamf := 0
                                          else
                                                nexamf = nexamf  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      else

                                          if (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) >= nexamf
                                                nexamf := 0
                                          else
                                                nexamf = nexamf  - (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      endif

                                else //if adjustment ky positive - meaning naay dungag bayad

                                      if ssflag == 1 //if nanay ni sud nga subsidy payments

                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf  + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                              nexamf = nexamf   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          endif

                                      else
                                          if (a999accp->accamtpd   + a999accp->accsytadsc ) >= nexamf  + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                              nexamf = nexamf  - (a999accp->accamtpd   + a999accp->accsytadsc )
                                          endif
                                      endif
                                endif

                                //nexamf = (balance/ 4)
 
                            /*if a999accp->accadj < 0
                                  if ssflag == 1 //if nanay ni sud nga subsidy payments
                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf
                                                nexamf := 0
                                      else
                                            nexamf = nexamf  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  else

                                      if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf
                                            nexamf := 0
                                      else
                                            nexamf = nexamf  - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  endif

                            else //if adjustment ky positive - meaning naay dungag bayad

                                  if ssflag == 1 //if nanay ni sud nga subsidy payments

                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= nexamf  + a999accp->accadj
                                            nexamf := 0
                                      else
                                            nexamf = nexamf  + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                      endif

                                  else
                                      if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf  + a999accp->accadj
                                            nexamf := 0
                                      else
                                            nexamf = nexamf  + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      endif
                                  endif
                            endif*/


                        elseif cperiod == "2"

                                if alltrim(substr(cterm,3,1)) == "1"
                                     ndue = "OCTOBER"
                                else
                                    ndue = "MARCH"
                                endif

                                //nexamf =  ((nshare - 500) / 4)
                                nexamf =  (nshare / 4)

                                //nexamf = (balance/ 3) //((nshare - 500) / 4)
                                //nexamf = (nshare / 4)
                               
                                if a999accp->accadj < 0
                                      if ssflag == 1 //if nanay ni sud nga subsidy payments
                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= nexamf * 2
                                                    nexamf := 0
                                          else
                                                nexamf = (nexamf * 2) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      else

                                          if (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) >= nexamf * 2
                                                nexamf := 0
                                          else
                                                nexamf = (nexamf * 2) - (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      endif

                                else //if adjustment ky positive - meaning naay dungag bayad

                                      if ssflag == 1 //if nanay ni sud nga subsidy payments

                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 2) + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                              nexamf = (nexamf * 2)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          endif

                                      else
                                          if (a999accp->accamtpd   + a999accp->accsytadsc ) >= (nexamf * 2) + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                              nexamf = (nexamf * 2) - (a999accp->accamtpd   + a999accp->accsytadsc )
                                          endif
                                      endif
                                endif

                            /*if a999accp->accadj < 0
                                  if ssflag == 1 //if nanay ni sud nga subsidy payments
                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 2
                                                nexamf := 0
                                      else
                                            nexamf = nexamf * 2  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  else

                                      if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 2
                                            nexamf := 0
                                      else
                                            nexamf = nexamf * 2  - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  endif
                            else //if adjustment ky positive - meaning naay dungag bayad

                                  if ssflag == 1 //if nanay ni sud nga subsidy payments

                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 2) + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf * 2)  + a999accp->accadj) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          nexamf = (nexamf * 2)   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                      endif

                                  else
                                      if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf * 2  + a999accp->accadj
                                            nexamf := 0
                                      else
                                            nexamf = (nexamf * 2)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      endif
                                  endif
                            endif*/


                        elseif cperiod == "3"

                                if alltrim(substr(cterm,3,1)) == "1"
                                     ndue = "NOVEMBER"
                                else
                                    ndue = "APRIL"
                                endif

                                //nexamf =  ((nshare - 500) / 4)
                                nexamf =  (nshare / 4)

                                //nexamf = (balance/ 3) //((nshare - 500) / 4)
                                //nexamf = (nshare / 4)
                               
                                if a999accp->accadj < 0
                                      if ssflag == 1 //if nanay ni sud nga subsidy payments
                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1) ) >= nexamf * 3
                                                    nexamf := 0
                                          else
                                                nexamf = (nexamf * 3) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      else

                                          if (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) >= nexamf * 3
                                                nexamf := 0
                                          else
                                                nexamf = (nexamf * 3) - (a999accp->accamtpd  + a999accp->accsytadsc + (a999accp->accadj*-1)) //(if(a999accp->accadj*-1 == 500, 0, a999accp->accadj*-1)))
                                          endif
                                      endif

                                else //if adjustment ky positive - meaning naay dungag bayad

                                      if ssflag == 1 //if nanay ni sud nga subsidy payments

                                          if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 3) + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                              nexamf = (nexamf * 3)  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          endif

                                      else
                                          if (a999accp->accamtpd   + a999accp->accsytadsc ) >= (nexamf * 3) + a999accp->accadj
                                                nexamf := 0
                                          else
                                                //nexamf = (nexamf * 2) + a999accp->accadj - (a999accp->accamtpd  + a999accp->accsytadsc )
                                              nexamf = (nexamf * 3) - (a999accp->accamtpd   + a999accp->accsytadsc )
                                          endif
                                      endif
                                endif


                                //nexamf = (balance/ 2)//((nshare - 500) / 4)

                               /*if a999accp->accadj < 0
                                  if ssflag == 1 //if nanay ni sud nga subsidy payments
                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 3
                                                nexamf := 0
                                      else
                                            nexamf = nexamf * 3  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  else

                                      if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 3
                                            nexamf := 0
                                      else
                                            nexamf = nexamf * 3  - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  endif
                            else //if adjustment ky positive - meaning naay dungag bayad

                                  if ssflag == 1 //if nanay ni sud nga subsidy payments

                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 3) + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf * 3)  + a999accp->accadj) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          nexamf = (nexamf * 3)   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                      endif

                                  else
                                      if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf * 3  + a999accp->accadj
                                            nexamf := 0
                                      else
                                           // nexamf = ((nexamf * 3)  + a999accp->accadj) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                          nexamf = (nexamf * 3)   - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      endif
                                  endif
                            endif*/

                        elseif cperiod == "4"

                                if alltrim(substr(cterm,3,1)) == "1"
                                     ndue = "DECEMBER"
                                else
                                    ndue = "MAY"
                                endif


                                if balance <= 0 
                                    nexamf := 0
                                else
                                    nexamf := balance
                                endif

                      elseif cperiod == "M" //MIDTERM FOR SUMMER
                                ndue = "SUMMER"

                                nexamf = (balance / 2)

                              /* if a999accp->accadj < 0
                                  if ssflag == 1 //if nanay ni sud nga subsidy payments
                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf 
                                                nexamf := 0
                                      else
                                            nexamf = nexamf   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  else

                                      if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf 
                                            nexamf := 0
                                      else
                                            nexamf = nexamf   - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  endif
                            else //if adjustment ky positive - meaning naay dungag bayad

                                  if ssflag == 1 //if nanay ni sud nga subsidy payments

                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf ) + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf)  + a999accp->accadj) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                          nexamf = (nexamf)   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                      endif

                                  else
                                      if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf   + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf )  + a999accp->accadj) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                           nexamf = (nexamf ) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      endif
                                  endif
                            endif*/


                       elseif cperiod == "F" //FINALS FOR SUMMER
                                ndue = "SUMMER"

                               nexamf = balance

                               /*if a999accp->accadj < 0
                                  if ssflag == 1 //if nanay ni sud nga subsidy payments
                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500) ) >= nexamf * 2
                                                nexamf := 0
                                      else
                                            nexamf = nexamf * 2  - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  else

                                      if (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500)) >= nexamf * 2
                                            nexamf := 0
                                      else
                                            nexamf = nexamf * 2  - (a999accp->accamtpd + a999accp->accsytadsc + (a999accp->accadj*-1 - 500))
                                      endif
                                  endif
                            else //if adjustment ky positive - meaning naay dungag bayad

                                  if ssflag == 1 //if nanay ni sud nga subsidy payments

                                      if ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc) >= (nexamf * 2) + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf * 2)  + a999accp->accadj) - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                            nexamf = (nexamf * 2)   - ((a999accp->accamtpd - subsidy) + a999accp->accsytadsc )
                                      endif

                                  else
                                      if (a999accp->accamtpd  + a999accp->accsytadsc ) >= nexamf * 2  + a999accp->accadj
                                            nexamf := 0
                                      else
                                            //nexamf = ((nexamf * 2)  + a999accp->accadj) - (a999accp->accamtpd  + a999accp->accsytadsc )
                                          nexamf = (nexamf * 2)  - (a999accp->accamtpd  + a999accp->accsytadsc )
                                      endif
                                  endif
                            endif*/

                      endif

                 if nexamf < 0
                      namt := 0
                 else
                      namt := nexamf
                 endif

                 @ prow()+01,28 say " "
                 @ prow()+00,29 say "DUE FOR " + ndue + "...."

                 @ prow()+00,56 say transform(int(namt),"999,999.99")

                /*if a999accp->accpbcprv == "1" //public
                        ngrant = "PUBLIC"
                       
                  elseif a999accp->accpbcprv == "2" //private with esc 
                        ngrant = "PRIVATE WITH ESC"

                  elseif a999accp->accpbcprv == "3" .OR. a999accp->accpbcprv == "4"
                         ngrant = "NONE"    
                endif

                if  a999prcp->(dbseek(a999accp->acccode))
                  scholar = a999prcp->prcdescr  
                else
                  scholar = ""
                endif

                @ prow()+nrow,29 say "GRANT: "
                @ prow()+00,56 say ngrant
                @ prow()+nrow,29 say "TYPE OF SCHOLARSHIP: "
                @ prow()+00,56 say scholar*/
        if a999accp->accadj > 0
                      adjplus += a999accp->accadj
                elseif a999accp->accadj < 0
                      adjless -= a999accp->accadj
        endif

      //insertExamDue(cyytenrp->enridno, a999accp->acclname, a999accp->accfname, a999accp->accmname, cyytenrp->enrcolcod, cyytenrp->enrcolcod2, a999accp->accbalold, a999accp->accsyttui, a999accp->accsytoth, a999accp->accsytmisc, a999accp->accsytlab, adjplus, a999accp->accduetot, a999accp->accamtpd, a999accp->accsytadsc, adjless, balance, namt, cperiod, a999prm->promoamnt, subsidy, nshare)
        insertExamDue(cyytenrp->enridno, a999accp->acclname, a999accp->accfname, a999accp->accmname,cyytenrp->enrcolcod, cyytenrp->enrcolcod2, a999accp->accbalold, a999accp->accsyttui, a999accp->accsytoth, a999accp->accsytmisc, a999accp->accsytlab, adjplus, a999accp->accduetot, a999accp->accamtpd, a999accp->accsytadsc, adjless, balance, namt, cperiod, a999prm->promoamnt, subsidy, nshare)
               
                 
        case nline == 17
                  if a999accp->accpbcprv == "1" //public
                        ngrant = "PUBLIC"
                       
                  elseif a999accp->accpbcprv == "2" //private with esc 
                        ngrant = "PRIVATE WITH ESC"

                  elseif a999accp->accpbcprv == "3" .OR. a999accp->accpbcprv == "4"
                         ngrant = "NONE"    
                  endif
                 @ prow()+nrow,29 say "GRANT: "
                 @ prow()+00,56 say ngrant
              
        case nline == 18
              if  a999prcp->(dbseek(a999accp->acccode))
                  scholar = a999prcp->prcdescr  
                else
                  scholar = ""
              endif
              @ prow()+nrow,29 say "TYPE OF SCHOLARSHIP: "
              @ prow()+00,56 say scholar


endcase

        //@ prow()+00,56 say  nline        
return(nil)

static function cdxname()
field lname,fname,mname
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)



//THIS WILL RESET THE COMPUTATION for senior high
static function testresetrecord(accntnum)
local noldacct := 0,nadjust := 0,ndisc := 0,ntotdue := 0,;
      namtpd := 0,nbal := 0, acctno
      
//if fask(13,"  Are you sure to Reset/Recompute Account ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1

        ayytpayp->(sx_setscope(_TOP_SCOPE   ,accntnum))
        ayytpayp->(sx_setscope(_BOTTOM_SCOPE,accntnum))
        ayytpayp->(dbgotop())
        do while ! ayytpayp->(eof())
                //fask(13,"  Processing Recompute. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[11],.f.,nil)
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

        ayytassp->(dbseek(accntnum))
        a999accp->(dbseek(accntnum))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accsytass     := ayytassp->asstotal
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
                //fask(13,"  Processing Recompute. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[11],.f.,nil)
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
        ayytassp->(dbseek(cacctno))
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadjust
        a999accp->accsytadsc    := ndisc
        a999accp->accsytass     := ayytassp->asstotal
        a999accp->accduetot     := a999accp->accsytass + noldacct + nadjust - ndisc 
       
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := a999accp->accduetot - namtpd
        a999accp->(dbcommit())
        a999accp->(dbunlock())
return(nil)
//END OF RESET RECORDS FUNCTION FOR EJH


//INSERT DATA TO EXAMPERMIT FOR basiced
static function insertExamDue(bepidno, beplname, bepfname, bepmname, bepstrand, bepgrdlvl, bepbalold, beptui, bepreg, bepmisc, beplab, bepadj, bepdue, bepamntpd, bepadsc, bepadjless, bepbal, bepexamdue, bepperiod,bepprmdisc, bepsubsidy, bepshare)


        if ayytepb->(dbseek(bepidno))
            ayytepb->(reclock()) //update
        else
            ayytepb->(recycle()) //insert

        endif

        ayytepb->bepidno := bepidno
        ayytepb->beplname := beplname
        ayytepb->bepfname := bepfname
        ayytepb->bepmname := bepmname
        ayytepb->bepstrand := bepstrand
        ayytepb->bepgrdlvl := bepgrdlvl
        ayytepb->bepbalold := bepbalold
        ayytepb->beptui := beptui
        ayytepb->bepreg := bepreg
        ayytepb->bepmisc := bepmisc
        ayytepb->beplab := beplab
        ayytepb->bepadj := bepadj
        ayytepb->bepdue := bepdue
        ayytepb->bepamntpd := bepamntpd
        ayytepb->bepadsc := bepadsc
        ayytepb->bepadjless := bepadjless
        ayytepb->bepbal := bepbal
        ayytepb->bepexamdue := bepexamdue
        ayytepb->bepperiod := bepperiod
        ayytepb->bepprmdisc := bepprmdisc //PROMOTIONAL DISCOUNT
        ayytepb->bepsubsidy := bepsubsidy //SUBSIDY
        ayytepb->bepshare := bepshare //STUDENT SHARE

        ayytepb->(dbcommit())
        ayytepb->(dbunlock())

return(nil)

*------------------------------------------------------------------------------*
