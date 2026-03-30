* Program      : APPREN.PRG - Apprentice Data Entry
* Author       : Randy F. Santizo (c) May 1999
* Installation : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function apprenticemate()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,cyytappp,;
      oappren,nrec
private cterm,nmos

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Apprenticeship Data Entry  ")
commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
memvar->cterm := space(len(term->code))

do while .t.
        restscr(aentryscr)
        clearbuffer()
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!" valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,22 say term->name
        if ! file(alltrim("c"+memvar->cterm+"appp.dbf"))
                fask(10,"  C"+memvar->cterm+"APPP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytappp        := "c"+memvar->cterm+"appp"
        if(aprv2setup    := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                        {,,"para"    ,,_DBF_SHARED,, },;
                                        {,, cyytappp ,"cyytappp",_DBF_SHARED,,2},;
                                        {,,"c999appp",,_DBF_SHARED,,2}})) == nil
                return(nil)
        endif

        oappren := c999appp->(createbrowse(06,01,20,78,;
                  {|xnmode,xacfields,xobrowser,xaxparam|fapprenticemate(xnmode,xacfields,xobrowser,xaxparam)},;
                  {"' '+appidno+' '","' '+applname+', '+appfname+' '+appmname+' '","' '+appcourse+' '+appyrlevel+' '","dtoc(appdate)","' '+appstatus+' '"},;
                  {"ID Number ", "         S t u d e n t s   N a m e           ", "Course", " D-Enroll ", "Sts"},;
                  {"ÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ"},;
                  {"³","³","³","³","³"},;
                  {"ÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ"}))
*                   x12345678x    x123456789012345, 123456789012345678901234 1x    x12x1x    11/11/1111    x1x

                commandline("³INS-New  Ù-Edit³F5-Withdraw³F7-View Vessel³F9-Recover³F12-Cancel³ESC-Previous³")

                @ 05,01 say replicate("Ä",78)
                c999appp->(sx_setscope(_TOP_SCOPE   ,memvar->cterm))
                c999appp->(sx_setscope(_BOTTOM_SCOPE,memvar->cterm))
                count to nrec
                @ 04,56 say "                "+ltrim(transform(nrec,"9999"))
                @ 04,56 say "Total Students: " color memvar->colorarray[02]
                memvar->nmos := 0
                c999appp->(dbgotop())
                c999appp->(browsefile(oappren,{"",memvar->cterm},{|b|b:gotop()}))
                clearscope()

           closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)



function fapprenticemate(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 04,02 say space(30)
                @ 04,02 say "Search Key =>" color memvar->colorarray[02]
                @ 04,16 say axparam[01]
                @ 21,02 say "               "+c999appp->appcityadd
                @ 21,02 say "City Address :" color memvar->colorarray[02]
                @ 22,02 say "             : "+c999appp->appprovadd
                @ 22,02 say "Prov Address :" color memvar->colorarray[02]
                @ 21,49 say "            "+c999appp->appbkno
                @ 23,02 say "               "+if(c999appp->appstatus=="W","Withdrawn","Enrolled ")
                @ 23,02 say "Stud. Status :" color memvar->colorarray[02]
                @ 21,49 say "Book No   :" color memvar->colorarray[02]
                @ 22,49 say "            "+dtoc(c999appp->appbkvalid)
                @ 22,49 say "Date Valid:" color memvar->colorarray[02]
                @ 23,49 say "            "+c999appp->appbkscore
                @ 23,49 say "Score     :" color memvar->colorarray[02]
                return 1
        case lastkey() == K_INS
                newapprenticemaster(obrowser)
        case lastkey() == K_ENTER .and. ! empty(c999appp->appidno) .and. ! c999appp->appstatus == "W"
                editapprenticemaster(obrowser)
        case lastkey() == K_F7 .and. ! empty(c999appp->appidno)
                viewvessel(obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                axparam[01]:=axparam[01]+chr(lastkey())
                dynamicseacrh(axparam[02]+axparam[01],obrowser)
                *dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
        case lastkey() == K_F5 .and. ! c999appp->appstatus == "W"
                if fask(20,"  Withdraw Student's Apprenticeship ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        c999appp->(reclock())
                        c999appp->appdate   := date()
                        c999appp->appstatus := "W"
                        c999appp->(dbcommit())
                        c999appp->(dbunlock())
                endif
        case lastkey() == K_F9 .and. c999appp->appstatus == "W"
                if fask(20,"  Recover Student's Apprenticeship ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        c999appp->(reclock())
                        c999appp->appdate   := date()
                        c999appp->appstatus := "E"
                        c999appp->(dbcommit())
                        c999appp->(dbunlock())
                endif
        case lastkey() == K_F12 .and. ! empty(c999appp->appidno)
                cancelrecord()

endcase
return 2

function newapprenticemaster(obrowser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[10]),;
      aentryscr,cprocsts
private dprocess,cidno,clname,cfname,cmname,ccourse,cyrlevel,;
        ccityadd,cprovadd,cbkno,dvalid,drecog,cbkscore,csex,lexist := .f.

c999appp->(sx_settagorder(1))
boxshadow(03,03,22,75,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[10],"  New Apprentice Master File  ")
commandline("³        F4 - View Student             ³           ESC - Previous              ³")
aentryscr := savescr(01,00,24,79)

do while .t.
        restscr(aentryscr)
        memvar->cidno           := space(len(c999appp->appidno))
        memvar->clname          := space(len(c999appp->applname))
        memvar->cfname          := space(len(c999appp->appfname))
        memvar->cmname          := space(len(c999appp->appmname))
        memvar->ddate           := date()
        memvar->ccourse         := space(len(c999appp->appcourse))
        memvar->cyrlevel        := space(len(c999appp->appyrlevel))
        memvar->ccityadd        := space(len(c999appp->appcityadd))
        memvar->cprovadd        := space(len(c999appp->appprovadd))
        memvar->cbkno           := space(len(c999appp->appbkno))
        memvar->cbkscore        := space(len(c999appp->appbkscore))
        memvar->dvalid          := date()
        memvar->drecog          := date()
        memvar->csex            := space(len(c999appp->appsex))
        clearbuffer()
        setkey(K_F4,{||vstudent({||__keyboard(chr(K_CTRL_LEFT)+c999sm1p->sm1idno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,05 say "Id Number  :" ;
                get memvar->cidno pict "@!" valid ! empty(memvar->cidno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif

        if c999appp->(dbseek(memvar->cterm+memvar->cidno))
                memvar->clname          := c999appp->applname
                memvar->cfname          := c999appp->appfname
                memvar->cmname          := c999appp->appmname
                memvar->ddate           := c999appp->appdate
                memvar->ccourse         := c999appp->appcourse
                memvar->cyrlevel        := c999appp->appyrlevel
                memvar->ccityadd        := c999appp->appcityadd
                memvar->cprovadd        := c999appp->appprovadd
                memvar->cbkno           := c999appp->appbkno
                memvar->cbkscore        := c999appp->appbkscore
                memvar->dvalid          := c999appp->appbkvalid
                memvar->drecog          := c999appp->appdrecog
                memvar->csex            := c999appp->appsex
        elseif c999sm1p->(dbseek(memvar->cidno))
                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midnam
                memvar->ccourse         := c999sm1p->sm1colcod
                memvar->cyrlevel        := alltrim(str(c999sm1p->sm1yrlevl))
                memvar->cprovadd        := c999sm1p->sm1homadr
                memvar->csex            := c999sm1p->sm1sex
        endif

        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,41 say "Date Processed  :";
                get memvar->ddate valid ! empty(memvar->ddate)
        @ 07,05 say "Last Name       :";
                get memvar->clname pict "@!"
        @ 08,05 say "First Name      :";
                get memvar->cfname pict "@!"
        @ 09,05 say "Middle Initial  :";
                get memvar->cmname pict "@!"
        @ 10,05 say "City Address    :";
                get memvar->ccityadd pict "@!"
        @ 11,05 say "Prov Address    :";
                get memvar->cprovadd pict "@!"
        @ 12,05 say "S e x  [M,F]    :";
                get memvar->csex pict "@!" valid memvar->csex $ "FM"
        @ 14,05 say "College Code    :";
                get memvar->ccourse pict "@!"
        @ 15,05 say "Year Level      :";
                get memvar->cyrlevel pict "@!"
        @ 17,05 say "Book Number     :";
                get memvar->cbkno pict "@!"
        @ 18,05 say "Book Score      :";
                get memvar->cbkscore pict "@!"
        @ 19,05 say "Book Validated  :";
                get memvar->dvalid
        @ 20,05 say "Recognition Date:";
                get memvar->drecog
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif

        if fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                if c999appp->(dbseek(memvar->cterm+memvar->cidno))
                        c999appp->(reclock())
                else
                        c999appp->(recycle())
                endif
                replace c999appp->appterm       with memvar->cterm,;
                        c999appp->appidno       with memvar->cidno,;
                        c999appp->applname      with memvar->clname,;
                        c999appp->appfname      with memvar->cfname,;
                        c999appp->appmname      with memvar->cmname,;
                        c999appp->appdate       with memvar->ddate,;
                        c999appp->appcourse     with memvar->ccourse,;
                        c999appp->appyrlevel    with memvar->cyrlevel,;
                        c999appp->appcityadd    with memvar->ccityadd,;
                        c999appp->appprovadd    with memvar->cprovadd,;
                        c999appp->appsex        with memvar->csex,;
                        c999appp->appbkno       with memvar->cbkno,;
                        c999appp->appbkscore    with memvar->cbkscore,;
                        c999appp->appbkvalid    with memvar->dvalid,;
                        c999appp->appdrecog     with memvar->drecog,;
                        c999appp->appstatus     with "E",;
                        c999appp->apptrail      with dtoc(date())+","+time()+","+memvar->cusername

                c999appp->(dbcommit())
                c999appp->(dbunlock())
        endif
enddo
restscr(alastscr);setcolor(memvar->colorarray[11])
c999appp->(sx_settagorder(2))
return(nil)

function cancelrecord()
if fask(20,"  Cancel Student's Apprenticeship ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        cyytappp->(sx_setscope(_TOP_SCOPE   ,c999appp->appidno))
        cyytappp->(sx_setscope(_BOTTOM_SCOPE,c999appp->appidno))
        cyytappp->(dbgotop())
        do while ! cyytappp->(eof())
                cyytappp->(reclock())
                cyytappp->appno := _DELETE_TAG
                cyytappp->(dbdelete())
                cyytappp->(dbcommit())
                cyytappp->(dbunlock())
                cyytappp->(dbgotop())
        enddo
        cyytappp->(clearscope())

        c999appp->(reclock())
        c999appp->appidno := _DELETE_TAG
        c999appp->(dbdelete())
        c999appp->(dbcommit())
        c999appp->(dbunlock())
endif
return(nil)

function editapprenticemaster(obrowser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[10]),;
      aentryscr,cprocsts
private dprocess,cidno,clname,cfname,cmname,ccourse,cyrlevel,;
        ccityadd,cprovadd,cbkno,dvalid,drecog,cbkscore,csex,lexist := .f.

*c999appp->(sx_settagorder(1))
boxshadow(03,03,22,75,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[10],"  Edit Apprentice Master File  ")
commandline("³        F4 - View Student             ³           ESC - Previous              ³")
aentryscr := savescr(01,00,24,79)

memvar->clname          := c999appp->applname
memvar->cmname          := c999appp->appmname
memvar->cfname          := c999appp->appfname
memvar->ddate           := c999appp->appdate
memvar->ccourse         := c999appp->appcourse
memvar->cyrlevel        := c999appp->appyrlevel
memvar->ccityadd        := c999appp->appcityadd
memvar->cprovadd        := c999appp->appprovadd
memvar->cbkno           := c999appp->appbkno
memvar->cbkscore        := c999appp->appbkscore
memvar->dvalid          := c999appp->appbkvalid
memvar->drecog          := c999appp->appdrecog
memvar->csex            := c999appp->appsex

do while .t.
        restscr(aentryscr)
        clearbuffer()
        @ 05,05 say "Id Number  : "+c999appp->appidno
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,41 say "Date Processed  :";
                get memvar->ddate valid ! empty(memvar->ddate)
        @ 07,05 say "Last Name       :";
                get memvar->clname pict "@!"
        @ 08,05 say "First Name      :";
                get memvar->cfname pict "@!"
        @ 09,05 say "Middle Initial  :";
                get memvar->cmname pict "@!"
        @ 10,05 say "City Address    :";
                get memvar->ccityadd pict "@!"
        @ 11,05 say "Prov Address    :";
                get memvar->cprovadd pict "@!"
        @ 12,05 say "S e x  [M,F]    :";
                get memvar->csex pict "@!" valid memvar->csex $ "FM"
        @ 14,05 say "College Code    :";
                get memvar->ccourse pict "@!"
        @ 15,05 say "Year Level      :";
                get memvar->cyrlevel pict "@!"
        @ 17,05 say "Book Number     :";
                get memvar->cbkno pict "@!"
        @ 18,05 say "Book Score      :";
                get memvar->cbkscore pict "@!"
        @ 19,05 say "Book Validated  :";
                get memvar->dvalid
        @ 20,05 say "Recognition Date:";
                get memvar->drecog
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif

        if fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                c999appp->(reclock())
                replace c999appp->appterm       with memvar->cterm,;
                        c999appp->applname      with memvar->clname,;
                        c999appp->appfname      with memvar->cfname,;
                        c999appp->appmname      with memvar->cmname,;
                        c999appp->appdate       with memvar->ddate,;
                        c999appp->appcourse     with memvar->ccourse,;
                        c999appp->appyrlevel    with memvar->cyrlevel,;
                        c999appp->appcityadd    with memvar->ccityadd,;
                        c999appp->appprovadd    with memvar->cprovadd,;
                        c999appp->appsex        with memvar->csex,;
                        c999appp->appbkno       with memvar->cbkno,;
                        c999appp->appbkscore    with memvar->cbkscore,;
                        c999appp->appbkvalid    with memvar->dvalid,;
                        c999appp->appdrecog     with memvar->drecog,;
                        c999appp->apptrail      with dtoc(date())+","+time()+","+memvar->cusername
                c999appp->(dbcommit())
                c999appp->(dbunlock())
                exit
        endif
enddo
restscr(alastscr);setcolor(memvar->colorarray[11])
*c999appp->(sx_settagorder(2))
return(nil)


function viewvessel(obrowser)
static ovessel := nil
local alastscr := savescr(01,00,24,79),;
      clastcolor := setcolor(memvar->colorarray[10])
ovessel := cyytappp->(createbrowse(08,03,16,75,;
                {|xnmode,xacfields,xobrowser,xaxparam|fvessel(xnmode,xacfields,xobrowser,xaxparam)},;
                {"' '+appvesname+' '","' '+checktype(appvestype)+' '","transform(appgrston,'@Z 999,999.99')+' '","transform(appnetton,'@Z 999,999.99')+' '","' '+transform(appnomos,'99')+' '"},;
                {"          Vessel Name           ", "   Type    ", " Gross Ton ", "  Net Ton  ", "#Mos"},;
                {"ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄ"}))
              *   x123456789012345678901234567890x    x123456789x    123,123.12x    123,123.12x    x12x

commandline("³  Enter - Edit Vessel  ³ + - Add New Vessel ³ Del - Delete ³  ESC - Previous  ³")
boxshadow(03,02,22,76,"ÛßÛÛÛÜÛÛ ",,"  View Vessel Information  ")
@ 07,03 say replicate("Ä",73)
@ 04,04 say "Student Number : "+c999appp->appidno
@ 05,04 say "Student Name   : "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname
@ 06,04 say "Course & Year  : "+c999appp->appcourse+" "+c999appp->appyrlevel
cyytappp->(sx_setscope(_TOP_SCOPE   ,c999appp->appidno))
cyytappp->(sx_setscope(_BOTTOM_SCOPE,c999appp->appidno))
cyytappp->(dbgotop())
do while ! cyytappp->(eof())
        memvar->nmos += cyytappp->appnomos
        cyytappp->(dbskip())
enddo
cyytappp->(browsefile(ovessel,{""},{|b|b:gotop()}))
cyytappp->(clearscope());setcolor(clastcolor);restscr(alastscr)
return(nil)

function fvessel(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 17,04 say "Vessel Owner : "+substr(cyytappp->appvesown,1,30)
                @ 18,04 say "Owner Address: "+substr(cyytappp->appownadd,1,30)
                @ 19,04 say "Registration : "+cyytappp->appvesreg
                @ 20,04 say "Position     : "+cyytappp->appprogrss
                @ 17,53 say "Embark   : "+dtoc(cyytappp->appembark)
                @ 18,53 say "DisEmbark: "+dtoc(cyytappp->appdembark)
                @ 20,53 say "Total Mos: "+transform(c999appp->apptotmos,"999")
                return 1
        case lastkey() == 43 .and. ! empty(c999appp->appidno) .and. ! c999appp->appstatus == "W"
                newvessel(obrowser)
        case lastkey() == K_ENTER .and. ! empty(cyytappp->appno) .and. ! c999appp->appstatus == "W"
                editvessel(obrowser)
        case lastkey() == K_DEL
                delvessel()
endcase
return 2


function checktype(ctype)
return(if(ctype == "F","Foreign  ",;
       if(ctype == "C","CoastWise",space(9))))


function delvessel()
if fask(20,"  Are you sure to delete record ? ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        c999appp->(reclock())
        c999appp->apptotmos -= cyytappp->appnomos
        c999appp->(dbcommit())
        c999appp->(dbunlock())

        cyytappp->(reclock())
        cyytappp->appno := _DELETE_TAG
        cyytappp->(dbdelete())
        cyytappp->(dbcommit())
        cyytappp->(dbunlock())

endif
return(nil)

function newvessel(obrowser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[05]),;
      aentryscr,cprocsts
private ccontrolno,cvessname,cvesstype,cvessreg,ngrosston,nnetton,;
        cvessowner,cownadd,dembark,ddisembark,cengine,nmos,cprogress,d_month,d_chng

boxshadow(04,04,21,74,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[52],"  Add New Vessel File  ")
commandline("³                               ESC - Previous                                 ³")

@ 05,06 say "                 "+c999appp->appidno color memvar->colorarray[52]
@ 05,06 say "Student Id No. : " color memvar->colorarray[53]
@ 06,06 say "                 "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname color memvar->colorarray[52]
@ 06,06 say "Student Name   : " color memvar->colorarray[53]
aentryscr := savescr(01,00,24,79)

do while .t.
        restscr(aentryscr)
        memvar->cvessname       := space(len(cyytappp->appvesname))
        memvar->cvesstype       := space(len(cyytappp->appvestype))
        memvar->cvessreg        := space(len(cyytappp->appvesreg))
        memvar->ngrosston       := 0
        memvar->nnetton         := 0
        memvar->cengine         := space(len(cyytappp->appengine))
        memvar->nmos            := 0
        memvar->cprogress       := space(len(cyytappp->appprogrss))
        memvar->cvessowner      := space(len(cyytappp->appvesown))
        memvar->cownadd         := space(len(cyytappp->appownadd))
        memvar->dembark         := date()
        memvar->ddisembark      := date()
        clearbuffer()
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 08,06 say "Vessel Name   :";
                color memvar->colorarray[53];
                get memvar->cvessname pict "@!";
                color memvar->colorarray[52]
        @ 09,06 say "                  [F-oreign, C-oastwise]" color memvar->colorarray[53]
        @ 09,06 say "Vessel Type   :";
                color memvar->colorarray[53];
                get memvar->cvesstype pict "@!" valid memvar->cvesstype $ "CF";
                color memvar->colorarray[52]
        @ 10,06 say "Vessel Reg.   :";
                color memvar->colorarray[53];
                get memvar->cvessreg pict "@!";
                color memvar->colorarray[52]
        @ 11,06 say "Gross Tonnage :";
                color memvar->colorarray[53];
                get memvar->ngrosston pict "999,999.99";
                color memvar->colorarray[52]
        @ 12,06 say "Net Tonnage   :";
                color memvar->colorarray[53];
                get memvar->nnetton pict "999,999.99";
                color memvar->colorarray[52]
        @ 13,06 say "Main Engine/HP:";
                color memvar->colorarray[53];
                get memvar->cengine pict "@!";
                color memvar->colorarray[52]
        @ 14,06 say "Vessel Owner  :";
                color memvar->colorarray[53];
                get memvar->cvessowner pict "@!";
                color memvar->colorarray[52]
        @ 15,06 say "Owner Address :";
                color memvar->colorarray[53];
                get memvar->cownadd pict "@!";
                color memvar->colorarray[52]
        @ 16,06 say "Embarkation   :";
                color memvar->colorarray[53];
                get memvar->dembark;
                color memvar->colorarray[52]

        read
        d_month := month(memvar->dembark) + 6
        d_chng  := dtoc(memvar->dembark)
        memvar->ddisembark := ctod((substr(d_chng,1,2))+"/"+(substr(d_chng,4,2))+"/"+(substr(d_chng,6,2)))

        @ 17,06 say "DisEmbarkation:";
                color memvar->colorarray[53];
                get memvar->ddisembark pict "@D";
                color memvar->colorarray[52]
        @ 18,06 say "No. of Months :";
                color memvar->colorarray[53];
                get memvar->nmos pict "99";
                color memvar->colorarray[52]
        @ 19,06 say "Position      :";
                color memvar->colorarray[53];
                get cprogress pict "@!";
                color memvar->colorarray[52]
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif

        if fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                cyytappp->(recycle())
                para->(dbgoto(1))
                cyytappp->appno := str(para->vesselcode,10)
                para->(reclock())
                para->vesselcode += 1
                para->(dbcommit())
                para->(dbunlock())

                replace cyytappp->appidno       with c999appp->appidno,;
                        cyytappp->appvesname    with memvar->cvessname,;
                        cyytappp->appvestype    with memvar->cvesstype,;
                        cyytappp->appvesown     with memvar->cvessowner,;
                        cyytappp->appownadd     with memvar->cownadd,;
                        cyytappp->appgrston     with memvar->ngrosston,;
                        cyytappp->appnetton     with memvar->nnetton,;
                        cyytappp->appengine     with memvar->cengine,;
                        cyytappp->appvesreg     with memvar->cvessreg,;
                        cyytappp->appembark     with memvar->dembark,;
                        cyytappp->appdembark    with memvar->ddisembark,;
                        cyytappp->appnomos      with memvar->nmos,;
                        cyytappp->appprogrss    with memvar->cprogress,;
                        cyytappp->apptrail      with dtoc(date())+","+time()+","+memvar->cusername

                cyytappp->(dbcommit())
                cyytappp->(dbunlock())

                c999appp->(reclock())
                c999appp->apptotmos += memvar->nmos
                c999appp->(dbcommit())
                c999appp->(dbunlock())

                exit
        endif
enddo
restscr(alastscr);setcolor(memvar->colorarray[10])
return(nil)


function editvessel(obrowser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[05]),;
      aentryscr,cprocsts
private ccontrolno,cvessname,cvesstype,cvessreg,ngrosston,nnetton,;
        cvessowner,cownadd,dembark,ddisembark,cengine,nmos,cprogress,xmos

//boxshadow(04,04,21,74,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[52],"  Edit Vessel File  ")
boxshadow(04,04,21,74,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[52],"  Edit Vessel File  ")
commandline("³                               ESC - Previous                                 ³")

@ 05,06 say "                 "+c999appp->appidno color memvar->colorarray[52]
@ 05,06 say "Student Id No. : " color memvar->colorarray[53]
@ 06,06 say "                 "+alltrim(c999appp->applname)+", "+alltrim(c999appp->appfname)+" "+c999appp->appmname color memvar->colorarray[52]
@ 06,06 say "Student Name   : " color memvar->colorarray[53]
aentryscr := savescr(01,00,24,79)

memvar->cvessname       := cyytappp->appvesname
memvar->cvesstype       := cyytappp->appvestype
memvar->cvessreg        := cyytappp->appvesreg
memvar->ngrosston       := cyytappp->appgrston
memvar->nnetton         := cyytappp->appnetton
memvar->cengine         := cyytappp->appengine
memvar->nmos            := cyytappp->appnomos
memvar->xmos            := cyytappp->appnomos
memvar->cprogress       := cyytappp->appprogrss
memvar->cvessowner      := cyytappp->appvesown
memvar->cownadd         := cyytappp->appownadd
memvar->dembark         := cyytappp->appembark
memvar->ddisembark      := cyytappp->appdembark

do while .t.
        restscr(aentryscr)
        clearbuffer()
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 08,06 say "Vessel Name   :";
                color memvar->colorarray[53];
                get memvar->cvessname pict "@!";
                color memvar->colorarray[52]
        @ 09,06 say "                  [F-oreign, C-oastwise]" color memvar->colorarray[53]
        @ 09,06 say "Vessel Type   :";
                color memvar->colorarray[53];
                get memvar->cvesstype pict "@!" valid memvar->cvesstype $ "CF";
                color memvar->colorarray[52]
        @ 10,06 say "Vessel Reg.   :";
                color memvar->colorarray[53];
                get memvar->cvessreg pict "@!";
                color memvar->colorarray[52]
        @ 11,06 say "Gross Tonnage :";
                color memvar->colorarray[53];
                get memvar->ngrosston pict "999,999.99";
                color memvar->colorarray[52]
        @ 12,06 say "Net Tonnage   :";
                color memvar->colorarray[53];
                get memvar->nnetton pict "999,999.99";
                color memvar->colorarray[52]
        @ 13,06 say "Main Engine/HP:";
                color memvar->colorarray[53];
                get memvar->cengine pict "@!";
                color memvar->colorarray[52]
        @ 14,06 say "Vessel Owner  :";
                color memvar->colorarray[53];
                get memvar->cvessowner pict "@!";
                color memvar->colorarray[52]
        @ 15,06 say "Owner Address :";
                color memvar->colorarray[53];
                get memvar->cownadd pict "@!";
                color memvar->colorarray[52]
        @ 16,06 say "Embarkation   :";
                color memvar->colorarray[53];
                get memvar->dembark;
                color memvar->colorarray[52]

        @ 17,06 say "DisEmbarkation:";
                color memvar->colorarray[53];
                get memvar->ddisembark pict "@D";
                color memvar->colorarray[52]
        @ 18,06 say "No. of Months :";
                color memvar->colorarray[53];
                get memvar->nmos pict "99";
                color memvar->colorarray[52]
        @ 19,06 say "Position      :";
                color memvar->colorarray[53];
                get cprogress pict "@!";
                color memvar->colorarray[52]

       read

/*
        @ 17,06 say "DisEmbarkation:";
                color memvar->colorarray[53];
                get memvar->ddisembark;
                color memvar->colorarray[52]
        @ 18,06 say "No. of Months :";
                color memvar->colorarray[53];
                get memvar->nmos pict "99";
                color memvar->colorarray[52]
        @ 19,06 say "Progress      :";
                color memvar->colorarray[53];
                get cprogress pict "@!";
                color memvar->colorarray[52]

*/
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif

        if fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                cyytappp->(reclock())

                replace cyytappp->appidno       with c999appp->appidno,;
                        cyytappp->appvesname    with memvar->cvessname,;
                        cyytappp->appvestype    with memvar->cvesstype,;
                        cyytappp->appvesown     with memvar->cvessowner,;
                        cyytappp->appownadd     with memvar->cownadd,;
                        cyytappp->appgrston     with memvar->ngrosston,;
                        cyytappp->appnetton     with memvar->nnetton,;
                        cyytappp->appengine     with memvar->cengine,;
                        cyytappp->appvesreg     with memvar->cvessreg,;
                        cyytappp->appembark     with memvar->dembark,;
                        cyytappp->appdembark    with memvar->ddisembark,;
                        cyytappp->appnomos      with memvar->nmos,;
                        cyytappp->appprogrss    with memvar->cprogress,;
                        cyytappp->apptrail      with dtoc(date())+","+time()+","+memvar->cusername

                cyytappp->(dbcommit())
                cyytappp->(dbunlock())


                c999appp->(reclock())
                c999appp->apptotmos -= memvar->xmos
                c999appp->apptotmos += memvar->nmos
                c999appp->(dbcommit())
                c999appp->(dbunlock())

                exit
        endif
enddo
restscr(alastscr);setcolor(memvar->colorarray[10])
return(nil)
