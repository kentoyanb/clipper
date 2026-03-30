function ptor(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdategrad,cdategrad1,cdateadmit,chonrec,sporderno,seriesno,sporder)
local afile,nline := 0, npage := 01,nctr := 0, nctrunt := 0, cnterm:=space(3),;
      cintcod,cfingrd,ccomgrd,ctrmdesc,ncredit:=0,ccredit:=space(3),;
      bgrad := 0, cint_cod, nunit := 0, addunit := 0, ccors
torfrontpage(cidno,cnceeper,cyrtaken,cexamno,cpurpose,cprepared,cchecked,corno,cdateadmit,chonrec)
torheader()
navtor->(sx_setscope(_TOP_SCOPE   ,cidno))
navtor->(sx_setscope(_BOTTOM_SCOPE,cidno))
navtor->(dbgotop())
do while ! navtor->(eof())
        yrlevel := navtor->toryrlevl
        fask(10,"  Processing school term "+navtor->torschtrm+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        c999colp->(dbseek(navtor->torcolcod))
        cnterm:=substr(navtor->torschtrm,3,3)
        term->(dbseek(cnterm))
        ctrmdesc := alltrim(if(right(navtor->torschtrm,1) == "1","FIRST SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "2","SECOND SEMESTER, "+substr(term->name,14),;
                    if(right(navtor->torschtrm,1) == "4","SUMMER, "+substr(term->name,8),space(1)))))+;
                    if(!empty(alltrim(navtor->torinst))," w/ PERMIT","")
        if (prow() > 46) .or. (empty(navtor->torintcd01) .and. (prow()+6)>50)
                footline()
                tefooter1(++npage,cpurpose,corno)
                torheader()
        endif

        if empty(navtor->torintcd01)
           if bgrad == 0
                if c999colp->colcod $ "MT,MV,ME,MI,MO,MS,PA"
                   @ prow()+01,18 say "APPRENTICE MATE ON BOARD"
                   @ prow()+00,18 say replicate("_",24)
                elseif c999colp->colcod $ "MA,MM,MR,MB,MD,MP"
                   @ prow()+01,18 say "APPRENTICE ENGINEER ON BOARD"
                   @ prow()+00,18 say replicate("_",28)
                elseif c999colp->colcod == "CS"

                   @ prow()+01,18 say "APPRENTICE ON BOARD"
                   @ prow()+00,18 say replicate("_",19)
                endif
                bgrad := 1
           endif
           if alltrim(c999colp->coldesabr)=="CS"
                   @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I",if(navtor->toryrlevl=="2","II","III"))+")"+space(2)+ctrmdesc
                   @ prow()+00,02 say replicate("_",13)+if(navtor->toryrlevl=="3","_","_ ")+space(2)+replicate("_",len(alltrim(ctrmdesc)))
           else
                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(8)+ctrmdesc
                   @ prow()+00,02 say replicate("_",8)+space(8)+replicate("_",len(alltrim(ctrmdesc)))
           endif
           c999torp->(dbseek(cidno+cnterm))
           @ prow()+01,02 say "NAME OF VESSEL     : "+c999torp->torvesname
           @ prow()+01,02 say "PROPRIETOR         : "+c999torp->torvesown
           @ prow()+01,02 say "GROSS TONS         : "+transform(c999torp->torgrston,"9,999,999.99")
           @ prow()+01,02 say "DATE OF EMBARKATION: "+format_date(c999torp->torembark)
           if c999colp->colcod != "CS"
                @ prow()+00,71 say "18"
           endif
        else
           if !empty(navtor->torinst)
                   @ prow()+01,18 say alltrim(navtor->torinst)
                   @ prow()+00,18 say replicate("_",len(alltrim(navtor->torinst)))
           endif

           if alltrim(c999colp->coldesabr)=="CS"
                   @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I ","II")+")"+space(3)+ctrmdesc
                   @ prow()+00,02 say replicate("_",13)+space(3)+replicate("_",len(alltrim(ctrmdesc)))
           else
                   @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(8)+ctrmdesc
                   @ prow()+00,02 say replicate("_",8)+space(8)+replicate("_",len(alltrim(ctrmdesc)))
           endif

        endif
        for nctr := 1 to 25
                nctrunt := 1
                cintcod := "torintcd"+strzero(nctr,2)
                cfingrd := "torfingd"+strzero(nctr,2)
                ccomgrd := "torcomgd"+strzero(nctr,2)
                addunit := 0
                if oldcuraj->(dbseek(navtor->&cintcod))
                        addunit := 1
                        for nctrunt := 1 to 25
                            cint_cod := "torintcd"+strzero(nctrunt,2)
                            if navtor->&cint_cod == oldcuraj->courslcod
                                addunit := 0
                                exit
                            endif
                        next
                endif
                if ! empty(navtor->&cintcod)
                        fask(16,"  Printing subject "+navtor->&cintcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        c999crsp->(dbseek(navtor->&cintcod))
                        nunit := c999crsp->crscreunt
                        if addunit == 1
                           nunit += 1
                        endif
                        if prow() > 45
                                footline()
                                tefooter1(++npage,cpurpose,corno)
                                torheader()
                                if alltrim(c999colp->coldesabr)=="CS"
                                        @ prow()+01,02 say "CS (PHASE "+if(navtor->toryrlevl=="1","I","II")+")"+space(3)+ctrmdesc
                                        @ prow()+00,02 say replicate("_",13)+space(3)+replicate("_",len(alltrim(ctrmdesc)))
                                else
                                        @ prow()+01,02 say c999colp->coldesabr+" "+navtor->toryrlevl+space(8)+ctrmdesc
                                        @ prow()+00,02 say replicate("_",8)+space(8)+replicate("_",len(alltrim(ctrmdesc)))
                                endif
                        endif
                        
                        @ prow()+01,02 say c999crsp->crssubcod+" "+;
                                           if(c999crsp->crssubtyp == "R"," ","L")+"  "+;
                                           c999crsp->crsdsc1
                        if ! empty(c999crsp->crsdsc2)
                                @ prow()+01,18 say c999crsp->crsdsc2+"   "+;
                                                   if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))

                        elseif empty(c999crsp->crsdsc2)
                                @ prow()+00,57 say ;
                                                   if(empty(navtor->&cfingrd),"---",;
                                                   if(val(navtor->&cfingrd) > 0,left(navtor->&cfingrd,1)+"."+right(navtor->&cfingrd,1),navtor->&cfingrd+" "))+space(4)+;
                                                   if(empty(navtor->&ccomgrd),"   ",;
                                                   if(val(navtor->&ccomgrd) > 0,left(navtor->&ccomgrd,1)+"."+right(navtor->&ccomgrd,1),navtor->&ccomgrd+" "))+space(2)+;
                                                   if((val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31") .or. (val(navtor->&ccomgrd) > 0 .and. navtor->&ccomgrd< "31"),;
                                                   if (str(c999crsp->crscreunt,3,1) == "1.5",transform(c999crsp->crscreunt,"@Z 999.9"),transform(nunit,"@Z 999")),transform(0,"999"))
                                                   &&if(val(navtor->&cfingrd) > 0 .and. navtor->&cfingrd < "31",transform(c999crsp->crscreunt,"@Z"),transform(0,"99999"))
                        endif
                else
                        exit
                endif
        next

        if nextkey() == K_ESC
                exit
        endif
        ccors := c999colp->colcod
        navtor->(dbskip())

/* ----------------------------------------------------------------- */

        if (navtor->toryrlevl == "4" .or. c999colp->colcod == "CS") .and. bgrad == 0 .and. empty(navtor->torintcd01)
           if ccors == "AM"
                outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
                outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF ASSOCIATE IN")
                outexpr(prow()+01,02,"MARINE ENGINEERING (A.MAR.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
                outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
           elseif ccors != "CS"
                outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol))
                outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")")
                outexpr(prow()+01,02,"AS OF "+format_date(cdategrad)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
                outexpr(prow()+01,02,"OF SPECIAL ORDER.")
           endif
           if (prow() > 46) .or. (empty(navtor->torintcd01) .and. (prow()+6)>50)
                footline()
                tefooter1(++npage,cpurpose,corno)
                torheader()
           endif
           if c999colp->colcod $ "MT,MV,ME,MI,MO,MS,PA"
                @ prow()+01,18 say "APPRENTICE MATE ON BOARD"
                @ prow()+00,18 say replicate("_",24)
           elseif c999colp->colcod $ "MA,MM,MR,MB,MD,MP,AM"
                @ prow()+01,18 say "APPRENTICE ENGINEER ON BOARD"
                @ prow()+00,18 say replicate("_",28)
           elseif c999colp->colcod == "CS"
                @ prow()+01,18 say "APPRENTICE ON BOARD"
                @ prow()+00,18 say replicate("_",19)
           endif
           bgrad := 1
        endif

/* ----------------------------------------------------------------- */

        if navtor->toryrlevl == "2" .and. c999colp->colcod == "RO" ;
                   .and. bgrad == 0 .and. (empty(navtor->torintcd01))
           outexpr(prow()+01,02,"GRADUATED FROM THE SPECIAL ACADEMIC PROGRAM IN MARINE TRANSPORTATION")
           outexpr(prow()+01,02,"COURSE FOR  MARINE RADIO OPERATORS  WITH THE TITLE OF  ASSOCIATE IN")
           outexpr(prow()+01,02,"MARINE TRANSPORTATION (A.M.T.)  AS OF "+format_date(cdategrad)+". PACUCOA")
           outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
           if (prow() > 46) .or. (empty(navtor->torintcd01) .and. (prow()+6)>50)
                footline()
                tefooter1(++npage,cpurpose,corno)
                torheader()
           endif
           bgrad := 1

        endif

/* ----------------------------------------------------------------- */

enddo
navtor->(clearscope())
if c999colp->colcod == "MB"
        outexpr(prow()+01,02,"COMPLETED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
        outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF CERTIFICATE")
        outexpr(prow()+01,02,"IN MARINE ENGINEERING (C.M.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif sporder==2
        outexpr(prow()+01,02,"GRADUATED FROM THE 2-YEAR COURSE IN MARINE ENGINEERING WITH")
        outexpr(prow()+01,02,"THE TITLE OF ASSOCIATE IN MARINE ENGINEERING (A.MAR.E.) AS OF")
        outexpr(prow()+01,02,format_date(cdategrad)+". PER SPECIAL ORDER (B ) NO. "+alltrim(sporderno)+", S. "+alltrim(seriesno))
        outexpr(prow()+01,02,"DATED "+format_date(cdategrad1)+" ISSUED BY DECS, REGION VII, CEBU CITY.")
elseif c999colp->colcod == "AM"
        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+yrlevel+"-YEAR ACADEMIC COURSE OF THE 4-YEAR LADDERIZED")
        outexpr(prow()+01,02,"PROGRAM IN MARINE ENGINEERING WITH THE TITLE OF ASSOCIATE IN")
        outexpr(prow()+01,02,"MARINE ENGINEERING (A.MAR.E.) AS OF "+format_date(cdategrad)+"."+" PACUCOA")
        outexpr(prow()+01,02,"ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "RO" //.and. yrlevel == "2"
        outexpr(prow()+01,02,"GRADUATED FROM THE SPECIAL ACADEMIC PROGRAM IN MARINE TRANSPORTATION")
        outexpr(prow()+01,02,"COURSE FOR  MARINE RADIO OPERATORS  WITH THE DEGREE OF BACHELOR OF")
        outexpr(prow()+01,02,"SCIENCE IN MARINE TRANSPORTATION (B.S.M.T.)  AS OF "+format_date(cdategrad1)+".")
        outexpr(prow()+01,02,"PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE OF SPECIAL ORDER.")
elseif c999colp->colcod == "CS"
        outexpr(prow()+01,02,"GRADUATED FROM THE ONE YEAR COURSE IN SEAFARER'S CATERING/STEWARDING ")
        outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+".  SPECIAL ORDER APPLIED FOR.")
else
        outexpr(prow()+01,02,"GRADUATED "+if(!empty(chonrec),alltrim(chonrec)+" ","")+"FROM THE "+transform(c999colp->colyrlevl,"9")+"-YEAR COURSE IN "+alltrim(c999colp->colnamcol))
        outexpr(prow()+01,02,"WITH THE "+if (left(c999colp->colnamabr2,3) == "B.S","DEGREE","TITLE")+" OF "+alltrim(c999colp->colnamdeg)+" ("+alltrim(c999colp->colnamabr2)+")")
        outexpr(prow()+01,02,"AS OF "+format_date(cdategrad1)+". PACUCOA ACCREDITED EXEMPTED FROM THE ISSUANCE")
        outexpr(prow()+01,02,"OF SPECIAL ORDER.")
endif
        outexpr(prow()+01,02,replicate("-",74))
        outexpr(prow()+01,07,"(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)")
        tefooter2(++npage,cpurpose,corno)
return(nil)
