* Program       :  BLKLST.PRG
* Author        :  KC4EDP
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function blklst()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,cidno,clname,cfname,cmname,crson,lexist := .f.

if(aprvsetup := openwcheck({{,,"blocklst",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
cidno := space(len(blocklst->blkidno))
boxshadow(05,15,17,75,"лплллмлл ",memvar->colorarray[11],"  Block List Entry  ")
commandline("Г         F4 - View Student         Г           ESC - Previous              Г")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        cidno   := space(len(c999sm1p->sm1idno))
        clname  := space(len(c999sm1p->sm1lstnam))
        cfname  := space(len(c999sm1p->sm1fstnam))
        cmname  := space(len(c999sm1p->sm1midnam))
        crson  := space(len(blocklst->blkreason))
        clearbuffer()

        setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})

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
        if lexist := c999sm1p->(dbseek(cidno))
               clname  := c999sm1p->sm1lstnam
               cfname  := c999sm1p->sm1fstnam
               cmname  := c999sm1p->sm1midnam
     
        endif
        if lexist := blocklst->(dbseek(cidno))
                if ! blocklst->(reclock())
                        loop
                endif

                crson   := blocklst->blkreason
        endif
        commandline("Г          ESC - Previous           |          F12 - Delete Blocklist          Г")
        if blocklst->(dbseek(cidno))
              setkey(K_F12,{||delblk(cidno)})
        endif

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
        @ 15,17 say "Reason       :";
                color memvar->colorarray[02];
                get crson       pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(15,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        if ! lexist
                if ! blocklst->(recycle())
                        loop
                endif
        endif
        blocklst->blkidno        := cidno
        blocklst->blklstnam      := clname
        blocklst->blkfstnam      := cfname
        blocklst->blkmidnam      := cmname
        blocklst->blkreason      := crson
//        t999lst->rectrail       := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
        blocklst->(dbcommit())
        blocklst->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

static function delblk(cidno)
if fask(20," Are you sure to delete this record ? ",{" Yes "," No "},memvar->colorarray[05])==1
        **blocklist file**
        blocklst->blkidno := _DELETE_TAG
        blocklst->(dbdelete())
        blocklst->(dbcommit())
        blocklst->(dbunlock())
        __keyboard(chr(K_ESC))

endif
return(nil)

