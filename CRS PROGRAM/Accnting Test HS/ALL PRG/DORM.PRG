* Program       :  DORM.PRG
* Author        :  jHUNbENLOT and tOPZfLORENTINO
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function dorm_ent()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,cacctno,namt,;
      clname,cfname,cmname,ccourse,cyear


if(aprvsetup:=openwcheck({{,,"dorm",,_DBF_SHARED,,1},;
                          {,,"a999accp",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
boxshadow(05,19,16,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11]," Dormitory Occupants Entry ")
commandline("³           F4 - View Students            ³          ESC - Previous            ³")
aentryscr:=savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        memvar->cacctno := space(len(a999accp->accidno))
        memvar->namt    := 0
        setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 06,22 say "ID Number :";
                color memvar->colorarray[02];
                get memvar->cacctno pict "@!" valid ! empty(memvar->cacctno)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if! a999accp->(dbseek(memvar->cacctno))
                fask(10,"   Student file not found in master file.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if lexist := dorm->(dbseek(memvar->cacctno))
                if ! dorm->(reclock())
                        loop
                endif
                memvar->namt   := dorm->d_amt
        endif

        if  a999accp->(dbseek(memvar->cacctno))
                clname := a999accp->acclname
                cfname := a999accp->accfname
                cmname := a999accp->accmname
                ccourse:= a999accp->acccolcod
                cyear  := a999accp->accyrlevl
        endif
        commandline("³              F12 - Delete            ³             ESC - Previous            ³")
        setkey(K_F12,{||delstud(memvar->cacctno)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 08,22 say "Last Name :";
                color memvar->colorarray[02]
        @ 08,34 say clname
        @ 09,22 say "First Name:";
                color memvar->colorarray[02]
        @ 09,34 say cfname
        @ 10,22 say "M.I.      :";
                color memvar->colorarray[02]
        @ 10,34 say cmname
        @ 12,22 say "Course    :";
                color memvar->colorarray[02]
        @ 12,34 say ccourse
        @ 13,22 say "Year      :";
                color memvar->colorarray[02]
        @ 13,34 say cyear
        @ 15,22 say "Amount    :";
                color memvar->colorarray[02];
                get memvar->namt pict "9,999,999.99"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(17,"  Are you sure to save entries ?  ",{" Ok "},memvar->colorarray[05])==1
                loop
        endif
        if ! lexist
                dorm->(recycle())
        endif
        dorm->d_idno       := memvar->cacctno
        dorm->d_amt        := memvar->namt
        dorm->rectrail     := dtoc(date())+","+time()+","+memvar->cusername
        dorm->(dbcommit())
        dorm->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

static function delstud(cacctno)
if fask(17,"  Are you sure to delete this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        dorm->d_idno := _DELETE_TAG
        dorm->(dbdelete())
        dorm->(dbcommit())
        dorm->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*------------------------------------------------------------------------------*

function dorm_prn()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,aentryscr,sprint,cprocsts,cidno,clname,cfname,cmname,ccolcod,;
      cyear,namt
private cdummy := "dorm"+strzero(memvar->naccess,2),dormstd
if(aprvsetup:=openwcheck({{,,"dorm",,_DBF_SHARED,,1},;
                          {,,"a999accp",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
aentryscr := savescr(01,00,24,79)
//do while .t.
        clearbuffer()
        boxshadow(01,01,23,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11]," Dormitory Occupants List Printing ")
        commandline("³                                 ESC - Previous                               ³")
     if fask(13,"  Start Printing Dorm Occupants List ?  ",{" Yes "," No  "},memvar->colorarray[05])==1

        if lastkey() == K_ESC
                return
        endif
        commandline("³            ÄÄÙ - Print              ³            ESC - Previous             ³")
        //inkey(0)
        aentryscr := savescr(01,00,24,79)

        if whereprint({||psummary()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
     endif
//enddo
closewcheck(aprvsetup)
restscr(alastscr)
dbunlockall()
return(nil)


static function psummary()
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,;
      afile, lpageject, nline := 0, ntotamt := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"     ,"C",08,0},;
                                 {"LNAME"    ,"C",15,0},;
                                 {"FNAME"    ,"C",24,0},;
                                 {"MNAME"    ,"C",01,0},;
                                 {"COURSE"   ,"C",02,0},;
                                 {"YEAR"     ,"C",01,0},;
                                 {"AMOUNT"   ,"N",12,2}},{||cdxname()})
        dbcloseall()
        return(nil)
endif
memvar->dormstd := memvar->cdummy
if(afile := openwcheck({{,,(memvar->dormstd+".TXT"),"dormstd",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
dormstd->(__dbzap()); dormstd->(dbreindex())
dorm->(dbgotop())
do while ! dorm->(eof())
        fask(10,"  Processing student number "+dorm->d_idno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        a999accp->(dbseek(dorm->d_idno))
        dormstd->(dbappend())
        dormstd->idno   := right(dorm->d_idno,8)
        dormstd->lname  := a999accp->acclname
        dormstd->fname  := a999accp->accfname
        dormstd->mname  := a999accp->accmname
        dormstd->course := a999accp->acccolcod
        dormstd->year   := a999accp->accyrlevl
        dormstd->amount := dorm->d_amt

        if nextkey() == K_ESC
                exit
        endif
        dorm->(dbskip())
enddo

ncol := titlepos("UNIVERSITY OF CEBU",nmaxcol)
aadd(abtext,{||chr(27)+"M"})
aadd(abtext,{||"Date: "+displaydate(date())+space(ncol-16)+"UNIVERSITY OF CEBU"+space(nmaxcol-ncol-len("UNIVERSITY OF CEBU")-08)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("Maritime Education and Training Center",nmaxcol)-14)+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("DORMITORY OCCUPANTS LISTING",nmaxcol))+"DORMITORY OCCUPANTS LISTING"})
aadd(abtext,{||""})
aadd(abtext,{||"       Account#    Last Name          First Name         M  Course    Remarks  "})
aadd(abtext,{||"      --------- --------------- ------------------------ - -------- -----------"})
pageprint(abtext)

dormstd->(dbgotop())
do while ! dormstd->(eof())
        fask(10,"  Printing student "+alltrim(dormstd->lname)+", "+alltrim(dormstd->fname)+" "+dormstd->mname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,transform(++nctr,"99999")+". "+dormstd->idno+" "+dormstd->lname;
                +" "+dormstd->fname+" "+dormstd->mname+".  "+dormstd->course;
                +"-"+dormstd->year+space(3)+"___________")
        ntotamt += dormstd->amount
        if nextkey() == K_ESC
                exit
        endif
        dormstd->(dbskip())
enddo
outexpr(prow()+01,00,chr(18))
__eject()
return(nil)

static function cdxname()
field idno,lname,fname,mname,course,year,amount
private cdummyfile := alias()
index on lname+fname+mname tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

