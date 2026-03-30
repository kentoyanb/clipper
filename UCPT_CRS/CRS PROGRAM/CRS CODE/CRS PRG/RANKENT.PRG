*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Program       : RANKENT.PRG
* Author        : Abundio C. Navarro and Jun Benlot (c) August 1999
* Installation  : UC-METC
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"
function rankent()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist:=.f.,cprocsts,oenroll,bindex,bitems,aentryscr,ls:=.f.,;
      cyytenrp, aprv1setup,aYesNo:={"  Yes  ","  No  "},cnmsg:=space(36),ls1:=.f.
private aitems := {},nindex := 1, lpassedit,cname,;
        clname, cfname, cmname,cterm := space(03), cidno := space(08),;
        lconf := .f.,chaddr,ccaddr,crank:=space(4),ddboard:=ctod('  \  \  '),;
        caddple:=space(30)
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[54],"  Graduates and Officers Entry  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
/*        draw_box2(02,60,10,74,memvar->colorarray[25],memvar->colorarray[26],,.t.)
        @03,63 say "ллн  лллн " color memvar->colorarray[43]
        @04,63 say "н н   н н " color memvar->colorarray[43]
        @05,63 say "н н   нн  " color memvar->colorarray[43]
        @06,63 say "н н   лн  " color memvar->colorarray[43]
        @07,63 say "н н   нн  " color memvar->colorarray[43]
        @08,63 say "н н   н н " color memvar->colorarray[43]
        @09,63 say "ллнм лллнм" color memvar->colorarray[43]  */
        draw_box2(02,03,04,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        draw_box1(02,21,04,26,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        @ 03,05 say "School Term   ";
                color memvar->colorarray[55]
        @ 03,22 get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm);
                color memvar->colorarray[55]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 03,28 say "- "+term->name color memvar->colorarray[55]

        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                    {,,"c999sm2p",,_DBF_SHARED,,1},;
                                    {,,"c999offr",,_DBF_SHARED,,1},;
                                    {,,"c999rank",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        aentryscr       := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                commandline("Г        F4 - View Student File         Г           ESC - Previous             Г")
                commandline("Г        Accept All Information      Г           ESC - Previous             Г")
                //setkey(K_F4,{||vrank(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10],)})
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10],)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                draw_box1(05,21,07,31,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                draw_box2(05,03,07,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                draw_box1(05,21,07,31,memvar->colorarray[28],memvar->colorarray[29],,.F.)

                @ 06,05 say "Student Number "  color memvar->colorarray[55]
                @ 06,22 get memvar->cidno      pict "@!" valid ! empty(memvar->cidno)
                       // valid check_std(memvar->cidno) color memvar->colorarray[55]
                read
                if lastkey() == K_ESC
                       exit
                endif

                if c999sm1p->(dbseek(memvar->cidno))
                  // ls:=.f.
                  memvar->clname          := alltrim(c999sm1p->sm1lstnam)
                  memvar->cfname          := alltrim(c999sm1p->sm1fstnam)
                  memvar->cmname          := alltrim(c999sm1p->sm1midnam)
                  memvar->chaddr          := alltrim(c999sm1p->sm1homadr)
                else
                  memvar->clname          := space(15)
                  memvar->cfname          := space(24)
                  memvar->cmname          := space(01)
                  memvar->chaddr          := space(30)
                  // ls:=.t.
                endif

                if c999sm2p->(dbseek(memvar->cidno))
                  memvar->ccaddr          := alltrim(c999sm2p->sm2citadr)
                  // ls1:=.t.
                else
                  memvar->ccaddr        := space(30)
                  // ls1:=.f.
                endif

                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                commandline("Г        F4 - View Rank File         Г           ESC - Previous             Г")
                setkey(K_F4,{||viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                        setcursor(1);set(_SET_CONFIRM,.t.)
                        draw_box2(08,03,12,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box1(08,21,12,48,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        @ 09,05 say "Last Name      " color memvar->colorarray[55]
                        @ 10,05 say "First Name     " color memvar->colorarray[55]
                        @ 11,05 say "Middle Initial " color memvar->colorarray[55]
                        @ 09,22 get memvar->clname pict "@!" valid !empty(memvar->clname) color memvar->colorarray[55]
                        @ 10,22 get memvar->cfname pict "@!" valid !empty(memvar->cfname) color memvar->colorarray[55]
                        @ 11,22 get memvar->cmname pict "@!" color memvar->colorarray[55]
                        read
                        draw_box2(13,03,16,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box1(13,21,16,62,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        @ 14,05 say "City address   " color memvar->colorarray[55]
                        @ 15,05 say "Home address   " color memvar->colorarray[55]
                        @ 14,22 get memvar->ccaddr pict "@!" color memvar->colorarray[55]
                        @ 15,22 get memvar->chaddr pict "@!" color memvar->colorarray[55]
                        read
                        if lexist := c999offr->(dbseek(alltrim(memvar->cidno)+alltrim(memvar->cterm)))
                           if ! c999offr->(reclock())
                               loop
                           endif
                           memvar->crank   := c999offr->r_code
                           memvar->ddboard := c999offr->r_datb
                           memvar->caddple := c999offr->r_eplace
                        else
                           memvar->crank   := space(4)
                           memvar->ddboard := ctod('  \  \  ')
                           memvar->caddple := space(len(c999offr->r_eplace))
                        endif

                        draw_box2(17,03,19,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box1(17,21,19,26,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box1(17,63,19,75,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box2(20,03,22,20,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box1(20,21,22,62,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                        draw_box2(17,45,19,62,memvar->colorarray[28],memvar->colorarray[29],,.F.)

                        @ 21,05 say "Place of Exam." color memvar->colorarray[55]
                        @ 18,05 say "Officer's Rank ";
                                color memvar->colorarray[55]
                        @ 18,46 say "Board Exam Taken";
                                color memvar->colorarray[55]
                        @ 18,22 get memvar->crank  pict "@!";
                                valid checkrank(memvar->crank) color memvar->colorarray[55]
                        read
                        setkey(K_F4,NIL)
                  if !lastkey() == K_ESC
                        if c999rank->(dbseek(alltrim(memvar->crank)))
                           memvar->cname   := c999rank->r_desc
                           @ 18,27 say "- "+memvar->cname  color memvar->colorarray[55]
                        else
                          loop
                        endif
                        @ 18,64 get memvar->ddboard  && date of board
                        @ 21,22 get memvar->caddple pict "@!S30" color memvar->colorarray[55] //valid !empty(memvar->caddple)
                        read
                         if lastkey() == K_ESC
                             loop
                         endif
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                    if ! lexist
                       cnmsg:="  Are you sure to save entries ?  "
                       if ! c999offr->(recycle())
                            loop
                       endif
                    else
                       cnmsg:="  Are you sure to resave entries ?  "
                    endif
                   if fask(12,cnmsg,aYesNo,memvar->colorarray[05]) == 1
                     c999offr->r_idno      := memvar->cidno
                     c999offr->r_term      := memvar->cterm
                     c999offr->r_lname     := memvar->clname
                     c999offr->r_fname     := memvar->cfname
                     c999offr->r_mname     := memvar->cmname
                     c999offr->r_caddr     := memvar->ccaddr
                     c999offr->r_haddr     := memvar->chaddr
                     c999offr->r_code      := memvar->crank
                     c999offr->r_datb      := memvar->ddboard
                     c999offr->r_eplace    := memvar->caddple
                     c999offr->rectrail    := displaydate(date())+";"+time()+";"+memvar->cusername
                     c999offr->(dbcommit())
                     // check_master(ls,ls1)
                   else
                      loop
                   endif
                 endif
                   c999offr->(dbunlock())
                        setkey(K_F4,nil)
                        if lastkey() == K_ESC
                                dbunlockall()
                              loop
                        endif
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)
*------------------------------------------------------------------------------
static function check_std(cidno,cprocsts)
if ! c999sm1p->(dbseek(cidno))
        vstudent({||__keyboard(chr(K_CTRL_LEFT)+c999sm1p->sm1idno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
return(.t.)
*------------------------------------------------------------------------------
/*
static function check_master(ls,ls1)
if !ls
   //if c999sm1p->(reclock())
      c999sm1p->(recycle())
      c999sm1p->sm1idno   := memvar->cidno
      c999sm1p->sm1lstnam := memvar->clname
      c999sm1p->sm1fstnam := memvar->cfname
      c999sm1p->sm1midnam := memvar->cmname
      c999sm1p->sm1homadr := memvar->chaddr
      c999sm1p->sm1sex    := "M" //Automatic male
      c999sm1p->(dbcommit())
      //c999sm1p->(dbunlock())
   //endif
endif
 if !ls1
        //if c999sm2p->(reclock())
           c999sm2p->(recycle())
           c999sm2p->sm2idno   := memvar->cidno
           c999sm2p->sm2citadr := memvar->ccaddr
           c999sm2p->(dbcommit())
           //c999sm2p->(dbunlock())
       //endif
 endif
return(nil)
*/
*------------------------------------------------------------------------------
static function checkrank(crank,cprocsts)
if ! c999rank->(dbseek(crank))
        viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
return(.t.)
