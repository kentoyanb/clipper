* Program       : Chgid.PRG
* Author        : Abundio Navarro and Jun Benlot (c) November 1998
* Installation  : UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function chgid()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,oenroll,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, aprv1setup,cyytenrr
private aitems := {},nindex := 1, ntotunits := 0, lpassedit,;
        clname, cfname, cmname, csex, ccourse, nyrlevel,;
        csection, cclass, cterm := space(03), cidno := space(08),;
        lconf := .f.
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Enrollment Entry  ")
        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_EXCLUSIVE,,1},;
                                    {,,"c999sm2p",,_DBF_EXCLUSIVE,,1}})) == nil
                return(nil)
        endif
                commandline("Г        F4 - View Student File         Г           ESC - Previous             Г")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno      pict "@!";
                        valid checkidno(memvar->cidno,cprocsts)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(memvar->cidno)) .and. ;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno))
                        if c999sm1p->(dbseek(memvar->cidno))

                        endif
                        loop
                endif
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)
