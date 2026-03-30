function cllistbysubj()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup, aprv2setup, cyytenrr, cyytskdp,;
      bprint, cprocsts, cterm := space(03), cdesc,;
      ccode,lprint:=.f.

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Class List Report by Instructor  ")
        commandline("Г           F4 - View Term             Г              ESC - Previous           Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term     :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School term not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrr.dbf"))
                fask(10,"  C"+cterm+"ENRR.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cdesc := term->name
        @ 02,24 say "- "+term->name
        aentryscr := savescr(01,00,24,79)
        cyytenrr  := alltrim("c"+cterm+"enrr")
        cyytskdp  := alltrim("c"+cterm+"skdp")
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,,"t999lst" ,,_DBF_SHARED,,1},;
                                     {,,cyytenrr,"cyytenrr",_DBF_SHARED,,2},;
                                     {,,cyytskdp,"cyytskdp",_DBF_SHARED,,6}})) == nil
                return(nil)
        endif
        ccode := "ALL   " &&space(len(t999lst->tidno))
        do while .t.
                restscr(aentryscr)
                commandline("Г          F4 - View Instructor        Г           ESC - Previous              Г")
                setkey(K_F4,{||vinstructor(space(len(t999lst->tidno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Instructor Code :";
                        color memvar->colorarray[02];
                        get ccode    pict "@!";
                        valid ! empty(ccode)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! t999lst->(dbseek(ccode)) .and. ! alltrim(ccode) == "ALL"
                        fask(10,"   Instructor Code "+alltrim(ccode)+" not registered.   ",{" Ok "},memvar->colorarrayu[05],.t.,nil)
                        loop
                endif
                if ! ccode == "ALL   "
                        @ 04,27 say "- "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+" "+alltrim(t999lst->tlname)
                endif
                if alltrim(ccode) == "0"
                        if whereprint({||pdisbysubj(ccode,cdesc)}) == 1
                                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                                viewtextfile()
                        endif
                else
                        if whereprint({||pcllistbyinst(ccode,cdesc)}) == 1
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

static function pcllistbysubj(ccode,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

if ! ccode == "ALL   "
        t999lst->(sx_setscope(_TOP_SCOPE   ,ccode))
        t999lst->(sx_setscope(_BOTTOM_SCOPE,ccode))
else
        t999lst->(sx_settagorder(2))
endif
t999lst->(dbgotop())
do while ! t999lst->(eof())
        if ! alltrim(t999lst->tidno) == "0" &&Disolved
                fask(10,"   Processing instructor "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytskdp->(sx_setscope(_TOP_SCOPE   ,t999lst->tidno))
                cyytskdp->(sx_setscope(_BOTTOM_SCOPE,t999lst->tidno))
                cyytskdp->(dbgotop())
                do while ! cyytskdp->(eof())
                        lprint := .f.
                        *fask(16,"   Processing code "+cyytskdp->skdcod+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        /* if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC")) */
                        if ! cyytskdp->skdsplcod == "C"
                                cecode := cyytskdp->skdcod
                                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                c999crsp->(dbseek(cyytskdp->skdintcod))
                                cesubj := alltrim(c999crsp->crsdsc1)
                                if cyytskdp->skdsplcod == "S"
                                        nrecno:=cyytskdp->(recno())
                                        cyytskdp->(sx_settagorder(1))
                                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                                        ccecode := cyytskdp->skdcod
                                        cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                        cyytskdp->(sx_settagorder(6))
                                        cyytskdp->(dbgoto(nrecno))
                                else
                                        ccecode := " "
                                        cceskd  := " "
                                endif
                                lprint := .t.
                                nctr := npage := 0
                                ccode := t999lst->tidno
                                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                                pageprint(abtext)
                                cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                                cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                                cyytenrr->(dbgotop())
                                do while ! cyytenrr->(eof())
                                        fask(16,"   Printing skdno "+cyytskdp->skdcod+" student "+alltrim(cyytenrr->enrlname)+", "+alltrim(cyytenrr->enrfname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                                lprint := .f.
                                        endif
                                        c999colp->(dbseek(cyytenrr->enrcolcod))
                                        c999sm1p->(dbseek(cyytenrr->enridno))
                                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                                             cyytenrr->enridno+space(01)+;
                                                             c999sm1p->sm1lstnam+space(01)+;
                                                             c999sm1p->sm1fstnam+space(01)+;
                                                             c999sm1p->sm1midnam+space(01)+;
                                                             c999colp->coldesabr+space(02)+;
                                                             cyytenrr->enryrlevl+space(01)+;
                                                             "__________")
                                        if ! empty(cyytenrr->enrrem)
                                                outexpr(prow()+00,67,cyytenrr->enrrem)
                                        endif
                                        lprint := .t.
                                        if nextkey() == K_ESC
                                                exit
                                        endif
                                        cyytenrr->(dbskip())
                                enddo
                                cyytenrr->(clearscope())
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytskdp->(dbskip())
                        if lprint
                                outexpr(prow()+00,00,chr(18))
                                __eject()
                        endif
                enddo
                cyytskdp->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        t999lst->(dbskip())
enddo
t999lst->(sx_settagorder(1))
t999lst->(clearscope())
return(nil)

static function pdisbysubj(ccode,cdesc)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0,nrecno:=0,;
      afile,lpageject,nline:=0,cecode:=" ",ceskd:=" ",cesubj:=" ",cskdno,;
      ccecode:=" ",cceskd:= " ",ntrec:=0,nprec:=0,nrrec:=0,nspro:=0,ccont:=space(01),;
      cname
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"P"+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos(alltrim(cdesc),nmaxcol)-14)+alltrim(cdesc)})
aadd(abtext,{||space(titlepos("CLASS LIST REPORT",nmaxcol))+"CLASS LIST REPORT"})
aadd(abtext,{||""})
aadd(abtext,{||"Instructor: "+ccode+" - "+cname})
aadd(abtext,{||"Schedule  : "+cecode+"  - "+ceskd})
aadd(abtext,{||"          : "+ccecode+"  - "+cceskd})
aadd(abtext,{||"          : "+cesubj})
aadd(abtext,{||""})
aadd(abtext,{||"      ID No.     Last Name          First Name         M Course Yr  Remarks  "})
aadd(abtext,{||"     -------- --------------- ------------------------ - ------ -- ----------"})

cyytskdp->(sx_setscope(_TOP_SCOPE   ,ccode))
cyytskdp->(sx_setscope(_BOTTOM_SCOPE,ccode))
cyytskdp->(dbgotop())
do while ! cyytskdp->(eof())
        lprint := .f.
        fask(10,"   Processing inscode "+ccode+" skdcode "+cyytskdp->skdcod+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! ((cyytskdp->skdsplcod=="C").and.(cyytskdp->skdsubtyp=="LEC"))
                cecode := cyytskdp->skdcod
                ceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                c999crsp->(dbseek(cyytskdp->skdintcod))
                cesubj := alltrim(c999crsp->crsdsc1)
                if cyytskdp->skdsplcod == "S"
                        nrecno:=cyytskdp->(recno())
                        cyytskdp->(sx_settagorder(1))
                        cyytskdp->(dbseek(cyytskdp->skdsplskd))
                        if ! cyytskdp->skdsubtyp == "LAB"
                                ccecode := cyytskdp->skdcod
                                cceskd  := alltrim(cyytskdp->skdsubcod)+"  "+cyytskdp->skdsubtyp+" "+cyytskdp->skdbegtim+"-"+cyytskdp->skdendtim+" "+cyytskdp->skdmdn+" "+cyytskdp->skdday+" "+cyytskdp->skdrom+" "+transform(cyytskdp->skdunt,"999.9")
                                ccont   := "C"
                        endif
                        cyytskdp->(sx_settagorder(6))
                        cyytskdp->(dbgoto(nrecno))
                endif
                lprint := .t.
                nctr := npage := 0
                ccode := t999lst->tidno
                cname := alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+t999lst->tmname
                pageprint(abtext)
                cyytenrr->(sx_setscope(_TOP_SCOPE   ,cyytskdp->skdcod))
                cyytenrr->(sx_setscope(_BOTTOM_SCOPE,cyytskdp->skdcod))
                cyytenrr->(dbgotop())
                do while ! cyytenrr->(eof())
                        fask(10,"   Printing inscode "+t999lst->tidno+" name "+alltrim(cyytenrr->enrlname)+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999colp->(dbseek(cyytenrr->enrcolcod))
                        c999sm1p->(dbseek(cyytenrr->enridno))
                        outexpr(prow()+01,00,transform(++nctr,"@Z 999")+"."+space(01)+;
                                             cyytenrr->enridno+space(01)+;
                                             c999sm1p->sm1lstnam+space(01)+;
                                             c999sm1p->sm1fstnam+space(01)+;
                                             c999sm1p->sm1midnam+space(01)+;
                                             c999colp->coldesabr+space(02)+;
                                             cyytenrr->enryrlevl+space(01)+;
                                             "__________")
                        if ! empty(cyytenrr->enrrem)
                                outexpr(prow()+00,67,cyytenrr->enrrem)
                        endif
                        if(pageeject(if(npage == 0, _PAGE_FIRST, _PAGE_CONTINUE), ;
                                    abtext, prow() + 1, _MAX_LINE, {||__eject()}))
                                lprint := .f.
                        else
                                lprint := .t.
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif
                        cyytenrr->(dbskip())
                enddo
                cyytenrr->(clearscope())
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytskdp->(dbskip())
        if lprint
                outexpr(prow()+00,00,chr(18))
                __eject()
        endif
enddo
cyytskdp->(clearscope())
return(nil)

