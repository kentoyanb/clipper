* Program       :  MIDGRADE.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
* Updated       :  August 2001 - L2WarTime
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function midgrade()
local getlist := {}, alastscr := savescr(01,00,24,79), lconfirm := set(_SET_CONFIRM),;
      clastcolor := setcolor(memvar->colorarray[11]), nlastcursor := setcursor(),;
      aprvsetup,cprocsts,nctr,aprv1setup,aentryscr,cyytstsp,cyytstsl,cyytskdp,;
      cterm,cedpcode,ograde,nrec,ccedpcode
                                                     
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        cterm := space(len(term->code))
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Midterm Grade Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
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
        @ 02,24 say "- "+term->name
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"stsl.dbf"))
                fask(10,"  C"+cterm+"STSL.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytstsp        := alltrim("c"+cterm+"stsp")
        cyytstsl        := alltrim("c"+cterm+"stsl")
        cyytskdp        := alltrim("c"+cterm+"skdp")
        if(aprvsetup    := openwcheck({{,,"t999lst",,_DBF_SHARED,,1},;
                                       {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                       {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,3},;
                                       {,, cyytstsl ,"cyytstsl",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cedpcode := space(len(cyytskdp->skdcod))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vschedule(space(len(cyytskdp->skdcod)),cprocsts,memvar->colorarray[10])})
                commandline("³        F4 - View Schedule File        ³           ESC - Previous             ³")
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "EDP Code     :";
                        color memvar->colorarray[02];
                        get cedpcode    pict "@!";
                        valid ! empty(cedpcode)
                read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! cyytskdp->(dbseek(cedpcode))
                        fask(10,"  EDP Code "+cedpcode+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                cyytskdp->(dbsetrelation("t999lst",{||cyytskdp->skdinscod},"cyytskdp->skdinscod"))
                if cyytskdp->skdsplcod = "S"
                        ccedpcode := cyytskdp->skdsplskd
                endif
                @ 03,24 say "- "+cyytskdp->skdsubcod
                @ 03,40 say "Instructor: " color memvar->colorarray[02]
                @ 03,52 say alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                ograde := cyytstsp->(createbrowse(07,02,23,77,;
                          {|xnmode,xacfields,xobrowser,xaxparam|fgrade(xnmode,xacfields,xobrowser,xaxparam)},;
                          {"' '+stsidno+' '","' '+stslstnam","' '+stsfstnam","' '+stsmidnam+' '","' '+stscourse+' '","' '+stsyrlevel+' '","stsmidgrd","stsfingrd"},;
                          {"  ID No.  ", "   Last Name    ", "       First Name        ", " M ", " Course ", "Yr ", "MG", "FG"},;
                          {"ÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄ","ÂÄÄ"},;
                          {"³","³","³","³","³","³","³","³"},;
                          {"ÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄ","ÁÄÄ"}))
*                           x12345678x    x123456789012345    x123456789012345678901234    x1x    x123456x    x1x    12    12
                commandline("³          Ù - Edit Grade             ³          ESC - Previous               ³")
                @ 04,01 say replicate("Ä",78)
                dispbox(06,01,23,78,_SINGLE_LINE)
                connectline(08,01,78)
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,cedpcode))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,cedpcode))

                nrec := 0
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        ++nrec
                        cyytstsp->(dbskip())
                enddo

//                count to nrec
                @ 05,57 say "                 "+ltrim(transform(nrec,"999"))
                @ 05,57 say "Total Students : " color memvar->colorarray[02]
                cyytstsp->(dbgotop())
                cyytstsp->(browsefile(ograde,{"",cedpcode},{|b|b:gotop()}))
                clearscope()
        enddo
        closewcheck(aprvsetup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fgrade(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 05,02 say space(30)
                @ 05,02 say "Search Key =>" color memvar->colorarray[02]
                @ 05,16 say axparam[01]
                @ 07,02 say "  ID No.      Last Name            First Name          M   Course  Yr  MG FG" color memvar->colorarray[35]
                return 1
        case lastkey() == K_ENTER .and. ! empty(cyytstsp->stsidno)
                cidno := cyytstsp->stsidno
                cname := cyytstsp->stslstnam+cyytstsp->stsfstnam+cyytstsp->stsmidnam
                editgrade(obrowser)
                dynamicsearch((axparam[02]+cname)+chr(lastkey()),obrowser)
        case lastkey() >= 32 .and. lastkey() <= 255
                axparam[01]:=axparam[01]+chr(lastkey())
                dynamicseacrh(axparam[02]+axparam[01],obrowser)
                *dynamicsearch((axparam[01]:=axparam[01]+chr(lastkey())),obrowser)
endcase
return 2

static function editgrade(obrowser)
local getlist := {}, nrow := row(), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarrayp11), lconfirm := set(_SET_CONFIRM),;
      alastscr := savescr(nrow,00,24,79),cmidgrade := cyytstsp->stsmidgrd,;
      ccedpcode := cyytskdp->skdsplskd

setcursor(1);set(_SET_CONFIRM,.t.)
obrowser:colorrect({obrowser:rowpos,obrowser:leftvisible,obrowser:rowpos,obrowser:rightvisible},{1,2})
@ nrow,73 get cmidgrade    pict "@!" valid checkmgrade(cmidgrade)
read
setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
if lastkey() == K_ENTER
        if ! empty(cyytstsp->stsmidgrd) .or. ! empty(cyytstsp->stsfingrd) .or. ;
           ! empty(cyytstsp->stscomgrd)
                cyytstsl->(dbappend())
                cyytstsl->stsidno    := cyytstsp->stsidno
                cyytstsl->stsskdcod  := cyytstsp->stsskdcod
                cyytstsl->stsintcod  := cyytstsp->stsintcod
                cyytstsl->stslstnam  := cyytstsp->stslstnam
                cyytstsl->stsfstnam  := cyytstsp->stsfstnam
                cyytstsl->stsmidnam  := cyytstsp->stsmidnam
                cyytstsl->stsmidgrd  := cyytstsp->stsmidgrd
                cyytstsl->stsfingrd  := cyytstsp->stsfingrd
                cyytstsl->stscomgrd  := cyytstsp->stscomgrd
                cyytstsl->stscourse  := cyytstsp->stscourse
                cyytstsl->stsyrlevel := cyytstsp->stsyrlevel
                cyytstsl->rectrail   := cyytstsp->rectrail
                cyytstsl->(dbcommit())
                cyytstsl->(dbunlock())
        endif
        cyytstsp->(reclock())
        cyytstsp->stsmidgrd := cmidgrade
        cyytstsp->rectrail  := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)

        // Writing grade on the Split //
           cyytstsp->(sx_settagorder(2))
           if cyytstsp->(dbseek(ccedpcode+cidno))
                if ! empty(cyytstsp->stsmidgrd) .or. ! empty(cyytstsp->stsfingrd) .or. ;
                   ! empty(cyytstsp->stscomgrd)
                        cyytstsl->(dbappend())
                        cyytstsl->stsidno    := cyytstsp->stsidno
                        cyytstsl->stsskdcod  := cyytstsp->stsskdcod
                        cyytstsl->stsintcod  := cyytstsp->stsintcod
                        cyytstsl->stslstnam  := cyytstsp->stslstnam
                        cyytstsl->stsfstnam  := cyytstsp->stsfstnam
                        cyytstsl->stsmidnam  := cyytstsp->stsmidnam
                        cyytstsl->stsmidgrd  := cyytstsp->stsmidgrd
                        cyytstsl->stsfingrd  := cyytstsp->stsfingrd
                        cyytstsl->stscomgrd  := cyytstsp->stscomgrd
                        cyytstsl->stscourse  := cyytstsp->stscourse
                        cyytstsl->stsyrlevel := cyytstsp->stsyrlevel
                        cyytstsl->rectrail   := cyytstsp->rectrail
                        cyytstsl->(dbcommit())
                        cyytstsl->(dbunlock())
                endif
                cyytstsp->(reclock())
                cyytstsp->stsmidgrd := cmidgrade
                cyytstsp->rectrail  := displaydate(date())+";"+time()+";"+alltrim(memvar->cusername)
           endif

        cyytstsp->(dbcommit())
        cyytstsp->(dbunlock())
        cyytstsp->(sx_settagorder(3))
        __keyboard(chr(K_DOWN)+chr(K_ENTER))
endif
return(nil)

static function checkmgrade(cmidgrade)
if substr(cmidgrade,1) == "3W"
      return(.t.)
end if
if val(cmidgrade) > 0
        if substr(cmidgrade,2,1) $ " ."
                fask(17,"   Invalid Midterm Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
        /* if (cmidgrade < "10" .or. cmidgrade > "50") */
        if (val(cmidgrade) < 10 .or. val(cmidgrade) > 50)
                fask(17,"   Invalid Midterm Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif
else
        if ! cmidgrade $ "NC,NG,DR,NA,W ,  "
                fask(17,"   Invalid Midterm Grade !   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                return(.f.)
        endif

endif
return(.t.)
