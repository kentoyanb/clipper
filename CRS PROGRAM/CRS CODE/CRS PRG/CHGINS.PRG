* Program       :  CHGINS.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) August 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function chgins()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,cidno,cnewidno,nrec

if(aprvsetup := openwcheck({{,,"t999lst",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(05,15,18,63,"лплллмлл ",memvar->colorarray[11],"  Change Instructor's ID No.  ")
commandline("Г         F4 - View Instructor         Г           ESC - Previous              Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        cidno := cnewidno := space(len(t999lst->tidno))
        clearbuffer()
        setkey(K_F4,{||vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 07,17 say "ID Number    :";
                color memvar->colorarray[02];
                get cidno       pict "@!";
                valid ! empty(cidno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! t999lst->(dbseek(cidno))
                fask(10,"  Instructor no. "+cidno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 09,17 say "             : "+t999lst->tlname
        @ 09,17 say "Last Name    : " color memvar->colorarray[02]
        @ 11,17 say "             : "+t999lst->tfname
        @ 11,17 say "First Name   : " color memvar->colorarray[02]
        @ 13,17 say "             : "+t999lst->tmname
        @ 13,17 say "Middle Init. : " color memvar->colorarray[02]
        nrec := t999lst->(recno())
        do while .t.
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 15,17 say "New ID Number :";
                        color memvar->colorarray[02];
                        get cnewidno    pict "@!";
                        valid ! empty(cnewidno)
               read
                if lastkey() == K_ESC
                        exit
                endif
                if t999lst->(dbseek(cnewidno))
                        fask(17,"  Instructors id no "+cnewidno+" already existing.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(17,"  Change ID number ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        loop
                endif
                t999lst->(dbgoto(nrec))
                t999lst->(reclock())
                t999lst->tidno    := cnewidno
                t999lst->rectrail := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
                t999lst->(dbcommit())
                t999lst->(dbunlock())
                exit
        enddo
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)
