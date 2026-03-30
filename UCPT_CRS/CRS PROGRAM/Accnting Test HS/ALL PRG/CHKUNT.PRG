* Program       :  ACCTENT.PRG
* Author        :  Jun Benlot and Tope Florentino (c) June 2002
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"


function updunt()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,ccolcode,nunit:=0,ctime:="",xtime,nctr,ainputscr
private nlast,nrec
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Update Units Taken by Students  ")
        commandline("Г        F4 - View Term/College File       Г         ESC - Previous            Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := "c"+cterm+"enrp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"para",,_DBF_SHARED,,},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        ccolcode := space(len(c999colp->colcod))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vcolcode({||__keyboard(chr(K_CTRL_LEFT)+c999colp->colcod+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "College Code :";
                        color memvar->colorarray[02];
                        get ccolcode    pict "@!";
                        valid ! empty(ccolcode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                ainputscr := savescr(01,00,24,79)
                if ! c999colp->(dbseek(ccolcode))
                        fask(10,"   College code "+ccolcode+" not found.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if a999ctrl->(dbseek(cterm+ccolcode)) .and. a999ctrl->status == _CLOSED
                        fask(10,"  Transaction for "+alltrim(term->name)+" was suspended.  ;"+;
                                "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif

                **Begin Processing**
                showretrieving()
                cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
                cyytenrp->(sx_setscope(_TOP_SCOPE   ,ccolcode))
                cyytenrp->(sx_setscope(_BOTTOM_SCOPE,ccolcode))
                count to memvar->nlast
                restscr(ainputscr)
                statusbar()
                cyytenrp->(dbgotop())
                do while ! cyytenrp->(eof())
                        showprogress()
                        if ! a999accp->(dbseek("1"+cyytenrp->enridno))
                                a999accp->(reclock())
                                //nunit += if(cyytskdp->skdsplcod=="C".and.cyytskdp->skdsubtyp=="LEC",0,cyytskdp->skdunt)
                                a999accp->accidno       := "1"+cyytenrp->enridno
                                a999accp->acclname      := c999sm1p->sm1lstnam
                                a999accp->accfname      := c999sm1p->sm1fstnam
                                a999accp->accmname      := c999sm1p->sm1midnam
                                a999accp->acccolcod     := cyytenrp->enrcolcod
                                a999accp->accyrlevl     := cyytenrp->enryrlevl
                                a999accp->accsyt        := cterm
                                a999accp->accfeeyr      := substr(cyytenrp->enridno,1,2)
                                a999accp->(dbcommit())
                                a999accp->(dbunlock())
                        endif
                        cyytenrp->(dbskip())
                enddo
                cyytenrp->(clearscope())
                cyytenrp->(dbclearrelation())
                fask(18,"   Processing finished.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

