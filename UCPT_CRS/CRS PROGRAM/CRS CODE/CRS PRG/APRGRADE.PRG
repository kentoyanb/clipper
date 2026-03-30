* Program      : APRGRADE.PRG - Apprenticeship Grade Entry
* Author       : Lorenzo D. Benlot Jr. (c) Feb 2008
* Installation : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function aprgrade()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprv1setup,cprocsts,nctr,aprv2setup,aentryscr,cyytappp,;
      oapprengrade,nrec
private cterm,nmos

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Apprenticeship Grade Entry  ")
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

        oapp_grade := c999appp->(createbrowse(06,01,20,78,;
                  {|xnmode,xacfields,xobrowser,xaxparam|fapp_grade(xnmode,xacfields,xobrowser,xaxparam)},;
                  {"' '+appidno+' '","' '+applname+', '+appfname+' '+appmname+' '","' '+appcourse+' '+appyrlevel+' '","'  '+appgrade+' '"},;
                  {"ID Number ", "         S t u d e n t s   N a m e           ", "Course", " Grade"},;
                  {"ÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄÄ"},;
                  {"³","³","³","³"},;
                  {"ÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄÄ"}))
*                   x12345678x    x123456789012345, 123456789012345678901234 1x    x12x1x    x12x
                commandline("³          Ù - Edit Grade             ³          ESC - Previous               ³")

                @ 05,01 say replicate("Ä",78)
                c999appp->(sx_setscope(_TOP_SCOPE   ,memvar->cterm))
                c999appp->(sx_setscope(_BOTTOM_SCOPE,memvar->cterm))
                count to nrec
                @ 04,56 say "                "+ltrim(transform(nrec,"9999"))
                @ 04,56 say "Total Students: " color memvar->colorarray[02]
                memvar->nmos := 0
                c999appp->(dbgotop())
                c999appp->(browsefile(oapp_grade,{"",memvar->cterm},{|b|b:gotop()}))
                clearscope()

           closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)


function fapp_grade(nmode,acfields,obrowser,axparam)
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
//        case lastkey() == K_ENTER .and. ! empty(c999appp->appidno) .and. ! c999appp->appstatus == "W"
        case lastkey() == K_ENTER .and. ! empty(c999appp->appidno)
                cidno := c999appp->appidno
                cname := c999appp->applname+c999appp->appfname+c999appp->appmname
                editapp_grade(obrowser)
                dynamicsearch((axparam[02]+cname)+chr(lastkey()),obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                axparam[01]:=axparam[01]+chr(lastkey())
                dynamicseacrh(axparam[02]+axparam[01],obrowser)
endcase
return 2

function editapp_grade(obrowser)
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[11]),;
      aentryscr,cprocsts, nrow := row(), cappgrade := c999appp->appgrade,;
      dprocess,cidno,clname,cfname,cmname,ccourse,cyrlevel,;
      ccityadd,cprovadd,cbkno,dvalid,cbkscore,csex,lexist := .f.

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
memvar->csex            := c999appp->appsex

setcursor(1);set(_SET_CONFIRM,.t.)
obrowser:colorrect({obrowser:rowpos,obrowser:leftvisible,obrowser:rowpos,obrowser:rightvisible},{1,2})
@ nrow,71 get cappgrade    pict "@!" valid checkgrade(cappgrade)
read
setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)

if lastkey() == K_ENTER
        c999appp->(reclock())
        c999appp->appgrade := cappgrade
        c999appp->apptrail  := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
        c999appp->(dbcommit())
        c999appp->(dbunlock())
        c999appp->(sx_settagorder(2))

        cyytappp->(reclock())
        cyytappp->appgrade := cappgrade
        cyytappp->apptrail  := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
        cyytappp->(dbcommit())
        cyytappp->(dbunlock())
        cyytappp->(sx_settagorder(2))

        __keyboard(chr(K_DOWN)+chr(K_ENTER))
endif
return(nil)

static function checkgrade(cappgrade)
if val(cappgrade) > 0
        if substr(cappgrade,2,1) $ " ."
                fask(17,"   Invalid Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
        if (cappgrade < "10" .or. cappgrade > "30") .and. ! cappgrade == "50"
                fask(17,"   Invalid Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
else
        if ! cappgrade $ "F ,P ,NC,NG,DR,NA,W ,  "
                fask(17,"   Invalid Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
endif
return(.t.)


restscr(alastscr);setcolor(memvar->colorarray[11])
*c999appp->(sx_settagorder(2))
return(nil)


