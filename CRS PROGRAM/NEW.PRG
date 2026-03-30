function acctpaylst()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,aentryscr,cyytskdp,cyytenrr,aprv2setup,;
      cfile,cterm,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,;
      cinstcode,cinstname,cskdcont,ccedpcode,ccsubject,ncunits,;
      clname,cfname,cperiod
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
cterm    := space(len(term->code))
//cedpcode := space(05)
cedpcode := "ALL  "
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Inst. Lst. of Req. Payment Sheet Printing  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
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
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("\crunlib\c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("\crunlib\c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytskdp := "c"+cterm+"skdp"
        cyytenrr := "c"+cterm+"enrr"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"a999accp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytenrr ,"cyytenrr",_DBF_SHARED,,2,"/crunlib"}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        clname := space(len(a999accp->acclname))
        cfname := space(len(a999accp->accfname))
        cperiod := space(1)
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "                   [P-relim, M-idterm, S-emi-Final, F-inal]" color memvar->colorarray[02]
                @ 03,02 say "Exam. Period   :";
                        color memvar->colorarray[02];
                        get cperiod pict "@!";
                        valid cperiod $ "PMSF"
                @ 05,02 say "Students Starting Name to print :" color memvar->colorarray[02]
                @ 06,05 say "Last Name  :";
                        color memvar->colorarray[02];
                        get clname pict "@!"
                @ 07,05 say "First Name :";
                        color memvar->colorarray[02];
                        get cfname pict "@!"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! alltrim(cedpcode) == "ALL"
                        if ! cyytskdp->(dbseek(cedpcode))
                                fask(10,"   Schedule code "+cedpcode+" does not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        if cyytskdp->skdsplcod == "C" /* .and. cyytskdp->skdsubtyp == "LEC" */
                                fask(10,"  Schedule code "+cedpcode+" is continuation code.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                        endif
                        csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                        nunits    := cyytskdp->skdunt
                        c999crsp->(dbseek(cyytskdp->skdintcod))
                        cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                        if t999lst->(dbseek(cyytskdp->skdinscod))
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                        else
                                cinscode := space(06)
                                cinsname := space(30)
                        endif
                        if cyytskdp->skdsplcod == "S"
                                cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                ccedpcode := cyytskdp->skdcod
                                ncunits   := cyytskdp->skdunt
                                ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                        else
                                cskdcont  := " "
                                ccedpcode := " "
                                ncunits   := 0
                                ccsubject := " "
                        endif
                        if whereprint({||pacctpaylst(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,10)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||pallacctpaylst(cdesc,clname,cfname,cperiod)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function pacctpaylst(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,npost)
local nctr := 0, cskdno, npage := 0, nline := 0, namt := nexamf := 0
acctpaylstheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
cyytenrr->(sx_setscope(_TOP_SCOPE   ,cedpcode))
cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cedpcode))
cyytenrr->(dbgotop())

//      fask(10,"  cperiod ==> "+cperiod+"  ",{" Ok "},memvar->colorarray[05],.t.,nil)

do while ! cyytenrr->(eof())
        fask(npost,"  Printing name "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+" "+cyytenrr->enrmname+".  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(cyytenrr->enrcolcod))
        c999sm1p->(dbseek(cyytenrr->enridno))
        a999accp->(dbseek("1"+cyytenrr->enridno))

//---------------------------------------------------------------

        nexamf := a999accp->accduetot / 4

        if cperiod == "P"
                namt   := nexamf - a999accp->accamtpd
        elseif cperiod == "M"
                namt   := (a999accp->accbaltot - (nexamf * 3)) + nexamf
        elseif cperiod == "S"
                namt   := (a999accp->accbaltot - (nexamf * 2)) + nexamf
        elseif cperiod == "F"
                namt   := a999accp->accbaltot
        endif

//---------------------------------------------------------------

        if namt < 0
                namt := 0
        endif
        if namt > 1
                outexpr(prow()+01,00,chr(15)+transform(++nctr,"@Z 999")+"."+space(02)+;
                                     cyytenrr->enridno+space(02)+;
                                     c999sm1p->sm1lstnam+space(03)+;
                                     c999sm1p->sm1fstnam+space(01)+;
                                     c999sm1p->sm1midnam+space(04)+;
                                     if(alltrim(cyytenrr->enrrem) != "WITHDRAWN",;
                                        transform(int(namt),"999,999.99"),"      0.00"))
                if alltrim(cyytenrr->enrrem) == "WITHDRAWN"
                        outexpr(prow()+00,84,"W I T H D R A W N")
                elseif alltrim(cyytenrr->enrrem) == "GRADUATING"
                        outexpr(prow()+00,84,"G R A D U A T I N G")
                endif
                ++nline
                if nextkey() == K_ESC
                        exit
                endif
                outexpr(prow(),83,replicate("_",41)+chr(18))
        endif
        cyytenrr->(dbskip())
        if nline == 40 .and. ! cyytenrr->(eof())
                outexpr(prow()+00,00,chr(18))
                __eject()
                acctpaylstheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,++npage,ccedpcode,ccsubject,ncunits,cperiod)
                nline := 0
        endif
enddo
cyytenrr->(clearscope())
outexpr(55,43,"_____________________________")
outexpr(56,43," SIGNATURE OVER PRINTED NAME")
outexpr(57,43,"    (INSTRUCTOR/PROCTOR)")
outexpr(prow()+00,00,chr(18))
__eject()
return(nil)

static function acctpaylstheader(cinscode,cinsname,cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cskdcont,npage,ccedpcode,ccsubject,ncunits,cperiod)
setprc(00,00)

outexpr(00,40-len("UNIVERSITY OF CEBU - MAMBALING")/2,"UNIVERSITY OF CEBU - MAMBALING")
outexpr(01,40-len("ALUMNOS, MAMBALING, CEBU CITY")/2,"ALUMNOS, MAMBALING, CEBU CITY")
outexpr(02,40-len(alltrim(cdesc))/2,alltrim(cdesc))

outexpr(04,00,"SUBJECT    :"+cedpcode+"  "+csubject+"  "+cschedule+"  "+transform(nunits,"@Z 99.9"))
outexpr(04,129,"Page  "+alltrim(str(npage)))
outexpr(06,00,"INSTRUCTOR :"+cinscode+"  "+cinsname)
outexpr(07,00,chr(15)+replicate("-",124))
outexpr(08,00,"      ID NO.    LASTNAME          FIRSTNAME                 MI  REQ'D PAYMENT      REMARKS")
outexpr(09,00,replicate("-",124) + chr(18))
return(nil)


static function pallacctpaylst(cdesc,clname,cfname,cperiod)
local cinscode:=" ",cinsname:=" ",cedpcode:=" ",csubject:=" ",cschedule:=" ",;
      nunits:=0,cdesctitle:=" ",cskdcont:=" ",npage:=0,ccedpcode,;
      ccsubject:=" ",ncunits:=0,nrec

t999lst->(sx_settagorder(2))
cyytskdp->(sx_settagorder(6))

t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" .and. (alltrim(t999lst->tlname)+alltrim(t999lst->tfname)) >= (alltrim(clname)+alltrim(cfname))
                fask(06,"  Processing name "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        npage := 0
                        fask(12,"  Processing code "+alltrim(cyytskdp->skdcod)+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        if ! cyytskdp->skdsplcod == "C"
                                cedpcode  := cyytskdp->skdcod
                                csubject  := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                cschedule := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                nunits    := cyytskdp->skdunt
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cdesctitle := alltrim(c999crsp->crsdsc1)+" "+alltrim(c999crsp->crsdsc2)
                                cinscode := t999lst->tidno
                                cinsname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"."
                                if cyytskdp->skdsplcod == "S"
                                        nrec := cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        cskdcont  := cyytskdp->skdbegtim+" -"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+cyytskdp->skdrom
                                        ccedpcode := cyytskdp->skdcod
                                        ncunits   := cyytskdp->skdunt
                                        ccsubject := cyytskdp->skdsubcod+" "+cyytskdp->skdsubtyp
                                        cyytskdp->(dbgoto(nrec))
                                        cyytskdp->(sx_settagorder(6))
                                else
                                        cskdcont  := " "
                                        ccedpcode := " "
                                        ncunits   := 0
                                        ccsubject := " "
                                endif
                                **Printing**
                                pacctpaylst(cdesc,cedpcode,csubject,cschedule,nunits,cdesctitle,cinscode,cinsname,cskdcont,ccedpcode,ccsubject,ncunits,cperiod,18)
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                enddo
        endif
        cyytskdp->(clearscope())
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
cyytskdp->(sx_settagorder(1))
return(nil)

