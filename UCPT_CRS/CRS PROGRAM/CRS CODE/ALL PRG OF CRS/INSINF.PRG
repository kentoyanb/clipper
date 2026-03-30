* Program       :  INTINF.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) August 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function insinf()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,cidno,clname,cfname,cmname,lexist := .f.

if(aprvsetup := openwcheck({{,,"t999lst",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cidno := space(len(t999lst->tidno))
boxshadow(05,15,17,63,"лплллмлл ",memvar->colorarray[11],"  Instructor's Registration Entry  ")
commandline("Г         F4 - View Instructor         Г           ESC - Previous              Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        clname  := space(len(t999lst->tlname))
        cfname  := space(len(t999lst->tfname))
        cmname  := space(len(t999lst->tmname))
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
        if lexist := t999lst->(dbseek(cidno))
                if ! t999lst->(reclock())
                        loop
                endif
                clname  := t999lst->tlname
                cfname  := t999lst->tfname
                cmname  := t999lst->tmname
        endif
        commandline("Г                               ESC - Previous                                 Г")
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 09,17 say "Last Name    :";
                color memvar->colorarray[02];
                get clname      pict "@!"
        @ 11,17 say "First Name   :";
                color memvar->colorarray[02];
                get cfname      pict "@!"
        @ 13,17 say "Middle Init. :";
                color memvar->colorarray[02];
                get cmname      pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(15,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        if ! lexist
                if ! t999lst->(recycle())
                        loop
                endif
        endif
        t999lst->tidno          := cidno
        t999lst->tlname         := clname
        t999lst->tfname         := cfname
        t999lst->tmname         := cmname
        t999lst->rectrail       := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
        t999lst->(dbcommit())
        t999lst->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)
