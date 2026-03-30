* Program       :  LOAD.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) August 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function load()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,aprv1setup,aentryscr,cyytskdp,;
      cterm,oload

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        cterm := space(len(term->code))
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Instructors Loading Entry  ")
        commandline("³        F4 - View Term File           ³           ESC - Previous              ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
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
        if term->status == "C"
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "   No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        cyytskdp     := alltrim("c"+cterm+"skdp")
        if(aprvsetup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                    {,,"t999lst",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cyytskdp->(dbsetrelation("t999lst",{||cyytskdp->skdinscod},"cyytskdp->skdinscod"))
        oload := cyytskdp->(createbrowse(06,02,23,77,;
                 {|xnmode,xacfields,xobrowser,xaxparam|fload(xnmode,xacfields,xobrowser,xaxparam)},;
                 {"skdcod","skdsubcod+' '+skdsubtyp","skdbegtim+' - '+skdendtim+' '+skdmdn+' '+skdday","skdrom","transform(skdactsiz,'9999')","transform(skdunt,'999.9')","skdinscod","skdcolcod","skdsplskd"},;
                 {"SKDCd", "    Subject     ", "      Schedule       ", "Room", "Size", "Unit ", "InsCod", "CC", "SplCd"},;
                 {"ÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄ","ÂÄÄÄÄÄ"},;
                 {"³","³","³","³","³","³","³","³","³"},;
                 {"ÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄ","ÁÄÄÄÄÄ"}))
                 * 12345    123456789012 123    12345 - 12345 12 1234    1234    1234    123.1    123456    12    12345
        commandline("³  Ù - Edit Instructor Code   ³   F12 - Changed Order   ³    ESC - Previous   ³")
        @ 03,01 say replicate("Ä",78)
        dispbox(05,01,23,78,_SINGLE_LINE)
        connectline(07,01,78)
        cyytskdp->(dbgotop())
        cyytskdp->(browsefile(oload,{""},{|b|b:gotop()}))
        cyytskdp->(dbclearrelation())
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fload(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                @ 06,02 say "SKDCd     Subject            Schedule        Room Size Unit  InsCod CC SplCd" color memvar->colorarray[35]
                return 0
        case nmode == 0
                @ 04,02 say "Search Key => " color memvar->colorarray[02]
                @ 04,15 say space(20)
                @ 04,15 say axparam[01]
                @ 04,35 say "Instructor => " color memvar->colorarray[02]
                @ 04,49 say space(30)
                @ 04,49 say alltrim(t999lst->tfname)+" "+t999lst->tmname+". "+alltrim(t999lst->tlname)
                @ 06,02 say "SKDCd     Subject            Schedule        Room Size Unit  InsCod CC SplCd" color memvar->colorarray[35]
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytskdp->skdcod)
                editload(obrowser)
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ~Code            ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Subject         ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2

static function editload(obrowser)
local getlist := {}, nrow := row(), nlastcursor := setcursor(),cprocsts,;
      clastcolor := setcolor(memvar->colorarrayp11), lconfirm := set(_SET_CONFIRM),;
      alastscr := savescr(nrow,00,24,79),cinstcode := cyytskdp->skdinscod,acmdscr:=savescr(24,00,24,79)
commandline("³         F4 - View Instructor         ³           ESC - Previous              ³")
obrowser:colorrect({obrowser:rowpos,obrowser:leftvisible,obrowser:rowpos,obrowser:rightvisible},{1,2})
setkey(K_F4,{||vinstructor({||__keyboard(chr(K_CTRL_LEFT)+t999lst->tidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
setcursor(1);set(_SET_CONFIRM,.t.)
@ nrow,63 get cinstcode pict "@!"
read
setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil);restscr(acmdscr)
if lastkey() == K_ENTER
        if ! empty(cinstcode)
                if ! t999lst->(dbseek(cinstcode))
                        fask(13,"  Instructor code "+alltrim(cinstcode)+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                else
                        cyytskdp->(reclock())
                        cyytskdp->skdinscod := cinstcode
                        cyytskdp->(dbcommit())
                        cyytskdp->(dbunlock())
                        __keyboard(chr(K_DOWN)+chr(K_ENTER))
                endif
        else
                cyytskdp->(reclock())
                cyytskdp->skdinscod := cinstcode
                cyytskdp->(dbcommit())
                cyytskdp->(dbunlock())
                __keyboard(chr(K_DOWN)+chr(K_ENTER))
        endif
endif
return(nil)


