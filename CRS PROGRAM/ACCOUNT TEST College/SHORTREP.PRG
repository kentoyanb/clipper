* Program       :  SHORTREP.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) February 1999
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------

function certification()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,lexist,cprocsts,;
      ayytpayp,cterm,cdesc,cidno,cstcode

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Certification  ")
        commandline("Г     F4 - View Term/Account/Course File    Г        ESC - Previous            Г")
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
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,19 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        ayytpayp := "a"+cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,3},;
                                      {,,"a999stcp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cstcode := space(len(a999stcp->stccod))
        cidno   := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar()=="CSTCODE",vsplcode({||__keyboard(chr(K_CTRL_LEFT)+a999stcp->stccod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),;
                               if(readvar()=="CIDNO",vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),))})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get cidno pict "@!";
                        valid ! empty(cidno)
                @ 04,02 say "Course Code :";
                        color memvar->colorarray[02];
                        get cstcode pict "@!";
                        valid ! empty(cstcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(cidno))
                        fask(10,"  Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! a999stcp->(dbseek(cstcode))
                        fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
/*
                if ! cstcode == "76" .and. ! ayytpayp->(dbseek(cstcode+cidno))
                        fask(10,"  Student not enrolled this course.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
*/
                if whereprint({||pcertification(cterm,cdesc,cidno,cstcode)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

static function pcertification(cterm,cdesc,cidno,cstcode)
@ 04,21 say "E          UNIVERSITY OF CEBU          "
@ 05,21 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 06,21 say "    Alumnos, Mambaling, Cebu City     "
@ 07,21 say "            Tel# 261-9963             "
@ 10,05 say cmonth(date())+str(day(date()))+","+str(year(date()))
@ 13,05 say "ETO WHOM IT MAY CONCERN :"
@ 16,10 say "This is to certify that Mr./Ms. E"+alltrim(a999accp->acclname)+","+alltrim(a999accp->accfname)+" "+alltrim(a999accp->accmname)+"."
@ 17,05 say "took the UPGRADING COURSES:E"
@ 19,05 say a999stcp->stcdesful
@ 19,05 say "___________________________________________________________"
@ 21,10 say "This is to certify that he/she has fully paid his accounts"
@ 22,05 say "as of this date."
@ 24,10 say "This certification is issued for "+"EVERIFICATION PURPOSES only."
@ 28,50 say "ENena T. Duran"
@ 29,50 say "Head - SAS Dept."
@ 33,05 say "UC-METC/SAC.DOC./009/REV.01"
*__eject()
@ 41,01 say space(01)
setprc(06,19)
return(nil)

*------------------------------------------------------------------------------*

function staccount()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      cidno,cterm,cdesc,cyytenrp,cto,cnotedby:=cdesgn := space(35)

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Statement of Accounts  ")
        commandline("Г      F4 - View Term/Account File     Г           ESC - Previous              Г")
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
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,19 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        ayytpayp := "a"+cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                      {,,"a999stcp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
//        cnotedby := "MR. BARTOLOME T. POZON            "
//        cdesgn   := "Campus Administrative Director    "
        cidno   := space(len(a999accp->accidno))
        cto     := space(30)
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get cidno pict "@!";
                        valid ! empty(cidno)
                @ 04,02 say "       T o  :";
                        color memvar->colorarray[02];
                        get cto pict "@!"
                @ 05,02 say "  Noted by  :";
                        color memvar->colorarray[02];
                        get cnotedby pict "@!"
                @ 06,02 say "Designation :";
                        color memvar->colorarray[02];
                        get cdesgn pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(cidno))
                        fask(10,"  Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if whereprint({||pstaccount(cterm,cdesc,cidno,cto,cnotedby,cdesgn)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

static function pstaccount(cterm,cdesc,cidno,cto,cnotedby,cdesgn)
local ntotaldue := 0, nline := 22, cp := "P"
header(cterm,cdesc,cidno,cto)
ayytpayp->(sx_setscope(_TOP_SCOPE   ,cidno))
ayytpayp->(sx_setscope(_BOTTOM_SCOPE,cidno))
ayytpayp->(dbgotop())
do while ! ayytpayp->(eof())
        fask(10,"  Processing document no. "+alltrim(ayytpayp->payrefno)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ayytpayp->paytag == "T"
                a999stcp->(dbseek(ayytpayp->paycolcod))
                @ ++nline,10 say alltrim(a999stcp->stcdesabr)+" - "+;
                    alltrim(a999stcp->stcdesful)+" .... "
                @   nline,60 say cp+" "+transform(ayytpayp->payamt,"999,999.99")
                //@   nline,10 say replicate("_",39)

                ntotaldue += ayytpayp->payamt
                cp := " "
        endif
        ayytpayp->(dbskip())
enddo
ayytpayp->(clearscope())
@ 31,05 say "ETOTAL SCHOOL OBLIGATION . . . . . . . . . . . . .: P "+transform(ntotaldue,"999,999.99")
@ 32,56 say "============"
footer(cnotedby,cdesgn)
return(nil)

static function header(cterm,cdesc,cidno,cto)
*local cname := alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+space(50)
//@ 01,20 say "E          UNIVERSITY OF CEBU        "
//@ 02,20 say "MARITIME EDUCATION AND TRAINING CENTER"
//@ 03,20 say "     Alumnos, Mambaling, Cebu City    "
//@ 04,20 say "        Telephone No.: 261-9963       "
//@ 05,20 say "        TIN 600-000-551-709-VAT       "

@ 07,20 say "E         STATEMENT OF ACCOUNTS        "
@ 08,20 say "           UPGRADING COURSE           F"

@ 11,05 say "Date: "+cmonth(date())+str(day(date()))+","+str(year(date()))
@ 11,05 say "      "+replicate("_",30)

@ 13,05 say "To  : "+cto
@ 13,05 say "      "+replicate("_",30)

@ 15,05 say "ETo Whom It May Concern:"

@ 17,05 say "This is to certify that "+a999accp->acclname+", "+a999accp->accfname+" "+a999accp->accmname
@ 17,05 say "                        "+replicate("_",43)+" is"
@ 18,05 say "enrolled  in  this institution for this  "+if(right(cterm,1)=="4",substr(cdesc,1,6),substr(cdesc,1,12))
@ 18,05 say "                                        "+replicate("_",14)+"  of school year"
@ 19,05 say if(right(cterm,1)=="4",substr(cdesc,8,4),substr(cdesc,14,9))
@ 19,05 say replicate("_",9)+" as regular student of the Maritime Training Center."

@ 21,05 say "Below is his/her ESTATEMENT OF ACCOUNTS to wit:"
return(nil)


static function footer(cnotedby,cdesgn)
@ 35,05 say "Please facilitate your payments thru:"
@ 37,05 say "University of Cebu"
@ 38,05 say "Banco De Oro"
@ 39,05 say "Elizabeth Mall Branch"
@ 40,05 say "Cebu City"
@ 41,05 say "Peso   SA # 1850000024"
@ 42,05 say "Dollar SA # 1850000032"

@ 50,05 say "Note: Please fax your deposit slip at 262-0555 for verification and"
@ 51,05 say "      posting of payment."

@ 54,05 say "Prepared by:"

@ 56,05 say "ENena T. Duran"
@ 57,05 say "Head - SAS Dept."

@ 58,05 say "UC-METC/SAC.DOC./011/REV.04"
__eject()
return(nil)

*------------------------------------------------------------------------------*

function certselection()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,lexist,cprocsts,;
      ayytpayp,cterm,cdesc,cidno,cstcode1,cstcode2,cstcode3,cstcode4,cstcode5,;
      cstcodesc1,cstcodesc2,cstcodesc3,cstcodesc4,cstcodesc5

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Print Certification  ")
        commandline("Г     F4 - View Term/Account/Course File    Г        ESC - Previous            Г")
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
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("a"+cterm+"payp.dbf"))
                fask(10,"  A"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,19 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        ayytpayp := "a"+cterm+"payp"
        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,3},;
                                      {,,"a999stcp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cidno      := space(len(a999accp->accidno))
        cstcode1   := space(len(a999stcp->stccod))
        cstcode2   := space(len(a999stcp->stccod))
        cstcode3   := space(len(a999stcp->stccod))
        cstcode4   := space(len(a999stcp->stccod))
        cstcode5   := space(len(a999stcp->stccod))
        cstcodesc1 := space(len(a999stcp->stcdesful))
        cstcodesc2 := space(len(a999stcp->stcdesful))
        cstcodesc3 := space(len(a999stcp->stcdesful))
        cstcodesc4 := space(len(a999stcp->stcdesful))
        cstcodesc5 := space(len(a999stcp->stcdesful))
        ncntr   := 1
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||if(readvar() $ "CSTCODE1,CSTCODE2,CSTCODE3,CSTCODE4,CSTCODE5",vsplcode({||__keyboard(chr(K_CTRL_LEFT)+a999stcp->stccod+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),;
                               if(readvar()=="CIDNO",vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10]),))})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get cidno pict "@!";
                        valid ! empty(cidno)
                @ 04,02 say "1st Course Code :";
                        color memvar->colorarray[02];
                        get cstcode1 pict "@!"
                @ 05,02 say "2nd Course Code :";
                        color memvar->colorarray[02];
                        get cstcode2 pict "@!"
                @ 06,02 say "3rd Course Code :";
                        color memvar->colorarray[02];
                        get cstcode3 pict "@!"
                @ 07,02 say "4th Course Code :";
                        color memvar->colorarray[02];
                        get cstcode4 pict "@!"
                @ 08,02 say "5th Course Code :";
                        color memvar->colorarray[02];
                        get cstcode5 pict "@!"
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! a999accp->(dbseek(cidno))
                        fask(10,"  Student number not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! empty(cstcode1)
                        if ! a999stcp->(dbseek(cstcode1))
                                fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                     cstcodesc1 := a999stcp->stcdesful
                endif
                if ! empty(cstcode2)
                        if ! a999stcp->(dbseek(cstcode2))
                                fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                     cstcodesc2 := a999stcp->stcdesful
                endif
                if ! empty(cstcode3)
                        if ! a999stcp->(dbseek(cstcode3))
                                fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                     cstcodesc3 := a999stcp->stcdesful
                endif
                if ! empty(cstcode4)
                        if ! a999stcp->(dbseek(cstcode4))
                                fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                     cstcodesc4 := a999stcp->stcdesful
                endif
                if ! empty(cstcode5)
                        if ! a999stcp->(dbseek(cstcode5))
                                fask(10,"  College code not found in master file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                     cstcodesc5 := a999stcp->stcdesful
                endif
/*              if ! cstcode == "76" .and. ! ayytpayp->(dbseek(cstcode+cidno))
                        fask(10,"  Student not enrolled this course.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
*/
                if whereprint({||pcertselection(cterm,cdesc,cidno,cstcodesc1,cstcodesc2,cstcodesc3,cstcodesc4,cstcodesc5)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aopen2files)
enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

static function pcertselection(cterm,cdesc,cidno,cstcodesc1,cstcodesc2,cstcodesc3,cstcodesc4,cstcodesc5)
@ 04,21 say "E          UNIVERSITY OF CEBU          "
@ 05,21 say "MARITIME EDUCATION AND TRAINING CENTER"
@ 06,21 say "    Alumnos, Mambaling, Cebu City     "
@ 07,21 say "            Tel# 261-9963             "
@ 10,05 say cmonth(date())+str(day(date()))+","+str(year(date()))
@ 13,05 say "ETO WHOM IT MAY CONCERN :"
@ 16,10 say "This is to certify that Mr./Ms. E"+alltrim(a999accp->acclname)+","+alltrim(a999accp->accfname)+" "+alltrim(a999accp->accmname)+"."
@ 17,05 say "took the following UPGRADING COURSES:E"
if ! empty(cstcodesc1)
        @ 19,10 say "______________________________________________________"
endif
@ 19,10 say cstcodesc1

if ! empty(cstcodesc2)
        @ 20,10 say "______________________________________________________"
endif
@ 20,10 say cstcodesc2

if ! empty(cstcodesc3)
        @ 21,10 say "______________________________________________________"
endif
@ 21,10 say cstcodesc3

if ! empty(cstcodesc4)
        @ 22,10 say "______________________________________________________"
endif
@ 22,10 say cstcodesc4

if ! empty(cstcodesc5)
        @ 23,10 say "______________________________________________________"
endif
@ 23,10 say cstcodesc5
@ 25,10 say "This is to certify that he/she has fully paid his accounts"
@ 26,05 say "as of this date."
@ 28,10 say "This certification is issued for "+"EVERIFICATION PURPOSES only."
@ 33,50 say "ENena T. Duran"
@ 34,50 say "Head - SAS Dept."
@ 40,05 say "UC-METC/SAC.DOC./009/REV.00"
*__eject()
@ 41,01 say space(01)
setprc(06,19)
return(nil)

*------------------------------------------------------------------------------*

