*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
*   Program      : Rank.prg
*   Written      : August 1999
*   Written by   : Abundio C. Navarro
*   Installation : UC-METC
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"
*------------------------------------------------------------------------------
function rank()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      nlastcursor := setcursor(), clastcolor := setcolor(memvar->colorarray[11]),;
      aentryscr,aprvsetup,ccode,cname,cstatus,cprocsts,lexist := .f.,;
      aYesNo:={"  Yes  ","  No  "},cnmsg:=space(36)
if(aprvsetup := openwcheck({{,,"c999rank",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(05,20,13,60,"лплллмлл ",memvar->colorarray[11],"  Rank File Entry  ")
commandline("Г         F4 - View Rank File          Г            ESC - Previous             Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        ccode   := space(len(c999rank->r_code))
        cname   := space(len(c999rank->r_desc))
        clearbuffer()
        setkey(K_F4,{||viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 07,22 say "Rank Code  :";
                color memvar->colorarray[02];
                get ccode       pict "@!";
                valid ! empty(ccode)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if lexist := c999rank->(dbseek(ccode))
                if ! c999rank->(reclock())
                        loop
                endif
                cname   := c999rank->r_desc
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 09,22 say "Description:";
                color memvar->colorarray[02];
                get cname       pict "@!S15";
                valid ! empty(cname)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        
        if ! lexist
          cnmsg:="  Are you sure to save entries ?  "
                if ! c999rank->(recycle())
                        loop
                endif
        else
          cnmsg:="  Are you sure to resave entries ?  "
        endif
        if !fask(11,cnmsg,aYesNo,memvar->colorarray[05]) == 1
                loop
        endif
           c999rank->r_code      := ccode
           c999rank->r_desc      := cname
           c999rank->rectrail  := displaydate(date())+";"+time()+";"+memvar->cusername
           c999rank->(dbcommit())
           c999rank->(dbunlock())
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)
