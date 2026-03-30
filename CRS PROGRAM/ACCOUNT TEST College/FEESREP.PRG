* Program       :  FEESREP.PRG
* Author        :  Randy F. Santizo (rb) February 1999
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*------------------------------------------------------------------------------*
//SCHOOL FEES INCOME
function feesincome()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytassp,ayytpayp,cfile,ccdx,cyytenrp,idno
private cterm,cdesc,;
        cdummy := "fees"+strzero(memvar->naccess,2),fees

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Summary of School Fees Income  ")
        commandline("Г        F4 - View Term File           Г           ESC - Previous              Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"assp.dbf")
                fask(10,"  A"+memvar->cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+memvar->cterm+"assp"
        ayytpayp  := "a"+memvar->cterm+"payp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,10},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        if whereprint({||pfeesincome()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pfeesincome()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile,ntotstud := 0, ntottui := 0, ntotreg := 0, ntotmisc := 0,;
      ntotlab := 0, ntotdisc := 0, ndiscount := 0, ntotpayment := 0, ntotadj :=0, ntotoa := 0, totalpayable := 0, totalpaid := 0, ntotalpayable :=0, ntotalpaid :=0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"COLCODE"     ,"C",02,0},;
                                 {"COLDESC"     ,"C",06,0},;
                                 {"STUDENT"     ,"N",07,0},;
                                 {"PAYMENT"     ,"N",12,2},;
                                 {"TUIFEE"      ,"N",12,2},;
                                 {"REGFEE"      ,"N",12,2},;
                                 {"MISCFEE"     ,"N",12,2},;
                                 {"LABFEE"      ,"N",12,2},;
                                 {"ADJSMENT"    ,"N",12,2},;
                                 {"OA"          ,"N",12,2},;
                                 {"DISCNT"      ,"N",12,2}},{||cdxcode()})
        dbcloseall()
        return(nil)
endif
memvar->fees := memvar->cdummy
if(afile := openwcheck({{,,(memvar->fees+".TXT"),"fees",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
fees->(__dbzap()); fees->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SUMMARY OF SCHOOL FEES INCOME",nmaxcol))+"SUMMARY OF SCHOOL FEES INCOME"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""+chr(15)})




aadd(abtext,{||" Course    #Student    Tuition Fees    Registration     Misc. Fees      Lab. Fees       Total Fees      Old Accounts      Discounts     Adjustments     Payments Made     Account Rcvbls"})
aadd(abtext,{||"---------  --------  --------------    --------------  --------------  --------------  --------------  --------------  --------------  --------------  --------------  --------------"})

/*aadd(abtext,{||" Course    #Student    Tuition Fees    Registration     Misc. Fees      Lab. Fees       Total Fees      Discounts     Payments Made     Account Rcvbls"})
aadd(abtext,{||"---------  --------  --------------    --------------  --------------  --------------  --------------  --------------  --------------  --------------"})*/

/* WAY LABOT ----------------------------------------------------------------------------------------------------------------------
 Course    #Student   Tuition Fees    Registration     Misc. Fees      Lab. Fees       Total Fees      Discounts     Account Rcvbls
---------  --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
12-123456  1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
           --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
TOTALS     1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
WAY LABOT -----------------------------------------------------------------------------------------------------------------------------------
*/

**filtering data**
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        
        //cyytenrp->(dbseek(right(ayytassp->assidno,8))) 
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! cyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" .and. cyytenrp->enrenrst == "C"


          if ayytassp->(dbseek("1"+cyytenrp->enridno))
              idno = "1"+cyytenrp->enridno
          elseif ayytassp->(dbseek("2"+cyytenrp->enridno))
              idno = "2"+cyytenrp->enridno
          elseif ayytassp->(dbseek("3"+cyytenrp->enridno))
               idno = "3"+cyytenrp->enridno
          endif

          ayytassp->(dbseek(idno))
          ayytpayp->(dbseek(idno+"OA"))
          a999accp->(dbseek(idno))

                      if cyytenrp->enrcolcod $ "HNMVSNMITL" //CHECK ALL COLCODE FOR MARINE TRANSPORTATION
                            if ! fees->(dbseek("MV"))
                                 c999colp->(dbseek("MV"))
                                  fees->(dbappend())
                                  fees->colcode   := "MV"
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := ayytassp->asstui
                                  fees->regfee    := ayytassp->assreg
                                  fees->miscfee   := ayytassp->assmisc
                                  fees->labfee    := ayytassp->asslab
                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd
                                  fees->adjsment  := a999accp->accadj
                                  fees->oa        := ayytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MV"))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := fees->tuifee  + ayytassp->asstui
                                  fees->regfee    := fees->regfee  + ayytassp->assreg
                                  fees->miscfee   := fees->miscfee + ayytassp->assmisc
                                  fees->labfee    := fees->labfee  + ayytassp->asslab
                                  fees->discnt    := fees->discnt  + a999accp->accsytadsc
                                  fees->payment   := fees->payment + a999accp->accamtpd
                                  fees->adjsment  := fees->adjsment + a999accp->accadj
                                  fees->oa        := fees->oa + ayytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif           
                          
                      elseif cyytenrp->enrcolcod $ "HMMLMMMRSM" //CHECK ALL COLCODE FOR MARINE ENG
                            if ! fees->(dbseek("MM"))
                                 c999colp->(dbseek("MM"))
                                  fees->(dbappend())
                                  fees->colcode   := "MM"
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := ayytassp->asstui
                                  fees->regfee    := ayytassp->assreg
                                  fees->miscfee   := ayytassp->assmisc
                                  fees->labfee    := ayytassp->asslab
                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd
                                  fees->adjsment  := a999accp->accadj
                                  fees->oa        := ayytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MM"))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := fees->tuifee  + ayytassp->asstui
                                  fees->regfee    := fees->regfee  + ayytassp->assreg
                                  fees->miscfee   := fees->miscfee + ayytassp->assmisc
                                  fees->labfee    := fees->labfee  + ayytassp->asslab
                                  fees->discnt    := fees->discnt  + a999accp->accsytadsc
                                  fees->payment   := fees->payment + a999accp->accamtpd
                                  fees->adjsment  := fees->adjsment + a999accp->accadj
                                  fees->oa        := fees->oa + ayytpayp->payamt
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif

                      elseif cyytenrp->enrcolcod $ "MNNS" // CHECK ALL COLCODE FOR NAME
                            if ! fees->(dbseek("MN"))
                                  c999colp->(dbseek("MN"))
                                  fees->(dbappend())
                                  fees->colcode   := "MN"
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := ayytassp->asstui
                                  fees->regfee    := ayytassp->assreg
                                  fees->miscfee   := ayytassp->assmisc
                                  fees->labfee    := ayytassp->asslab
                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd
                                  fees->adjsment  := a999accp->accadj
                                  fees->oa        := ayytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MN"))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := fees->tuifee  + ayytassp->asstui
                                  fees->regfee    := fees->regfee  + ayytassp->assreg
                                  fees->miscfee   := fees->miscfee + ayytassp->assmisc
                                  fees->labfee    := fees->labfee  + ayytassp->asslab
                                  fees->discnt    := fees->discnt  + a999accp->accsytadsc
                                  fees->payment   := fees->payment + a999accp->accamtpd
                                  fees->adjsment  := fees->adjsment + a999accp->accadj
                                  fees->oa        := fees->oa + ayytpayp->payamt
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif

                      else
                            if ! fees->(dbseek(cyytenrp->enrcolcod))
                                 c999colp->(dbseek(cyytenrp->enrcolcod))
                                  fees->(dbappend())
                                  fees->colcode   := cyytenrp->enrcolcod
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->tuifee    := ayytassp->asstui
                                  fees->regfee    := ayytassp->assreg
                                  fees->miscfee   := ayytassp->assmisc
                                  fees->labfee    := ayytassp->asslab
                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd
                                  fees->adjsment  := a999accp->accadj
                                  fees->oa        := ayytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek(cyytenrp->enrcolcod))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  
                                  fees->tuifee    := fees->tuifee  + ayytassp->asstui
                                  fees->regfee    := fees->regfee  + ayytassp->assreg
                                  fees->miscfee   := fees->miscfee + ayytassp->assmisc
                                  fees->labfee    := fees->labfee  + ayytassp->asslab
                                  fees->discnt    := fees->discnt  + a999accp->accsytadsc
                                  fees->payment   := fees->payment + a999accp->accamtpd
                                  fees->adjsment  := fees->adjsment + a999accp->accadj
                                  fees->oa        := fees->oa + ayytpayp->payamt
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            
                            endif
                            

                      endif         
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo


**printing data**
pageprint(abtext)
fees->(dbgotop())
do while ! fees->(eof())
        
        totalpayable = fees->tuifee  + fees->regfee + fees->miscfee + fees->labfee + fees->oa
        totalpaid = fees->discnt + fees->payment + (fees->adjsment)

        fask(10,"  Printing college "+fees->colcode+"-"+alltrim(fees->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say fees->colcode+"-"+fees->coldesc+"  "+;
                          transform(fees->student,"9999,999")+"  "+; 
                          transform(fees->tuifee,"999,999,999.99")+"  "+;
                          transform(fees->regfee,"999,999,999.99")+"  "+;
                          transform(fees->miscfee,"999,999,999.99")+"  "+;
                          transform(fees->labfee,"999,999,999.99")+"  "+;
                          transform(fees->tuifee  + fees->regfee +;
                                     fees->miscfee + fees->labfee,"999,999,999.99")+"  "+;
                          transform(fees->oa,"999,999,999.99")+"  "+;
                          transform(fees->discnt,"999,999,999.99")+"  "+;
                          transform(fees->adjsment,"999,999,999.99")+"  "+;
                          transform(fees->payment,"999,999,999.99")+"  "+;
                          transform(totalpayable - totalpaid ,"999,999,999.99") //account receivables


                          /*
                          transform(totalpayable,"999,999,999.99")+"  "+;
                          transform(totalpaid,"999,999,999.99")+"  "+;
                          transform((fees->tuifee  + fees->regfee +;
                                     fees->miscfee + fees->labfee + fees->oa) - (if(fees->adjsment < 0, fees->adjsment*-1, fees->adjsment) + fees->discnt + fees->payment),"999,999,999.99")+"  "+;*/


        ntotstud += fees->student
        ntottui  += fees->tuifee
        ntotreg  += fees->regfee
        ntotmisc += fees->miscfee
        ntotlab  += fees->labfee
        ntotdisc += fees->discnt
        ntotadj  += fees->adjsment
        ntotpayment += fees->payment
        ntotoa += fees->oa

  
        if nextkey() == K_ESC
                exit
        endif
        fees->(dbskip())
      
enddo
@ prow()+01,00 say "           --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------  --------------  --------------    --------------  "

ntotalpayable = ntottui + ntotreg + ntotmisc + ntotlab +  ntotoa
ntotalpaid    = ntotdisc + ntotpayment + (ntotadj)

@ prow()+01,00 say "ETOTALS  "+transform(ntotstud,"9999,999")+"  "+; 
                                 transform(ntottui ,"999,999,999.99")+"  "+;
                                 transform(ntotreg ,"999,999,999.99")+"  "+;
                                 transform(ntotmisc,"999,999,999.99")+"  "+;
                                 transform(ntotlab ,"999,999,999.99")+"  "+;
                                 transform(ntottui + ntotreg + ntotmisc +;
                                           ntotlab,"999,999,999.99")+"  "+;
                                 transform(ntotoa ,"999,999,999.99")+"  "+;
                                 transform(ntotdisc ,"999,999,999.99")+"  "+;
                                 transform(ntotadj ,"999,999,999.99")+"  "+;
                                 transform(ntotpayment ,"999,999,999.99")+"  "+;
                                 transform(ntotalpayable - ntotalpaid  ,"999,999,999.99") //account receivables

                                 /*
                                 transform(ntottui + ntotreg + ntotmisc + ntotlab + ntotoa - if(ntotadj<0,ntotadj*-1,ntotadj ) - ntotdisc - ntotpayment,"999,999,999.99")
                                 */
                                                   

@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function cdxcode()
field colcode
private cdummyfile := alias()
index on colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

function miscfees()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      cyytenrp,cfile,ccdx
private cterm,cdesc

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Summary of Miscellaneous Fees  ")
        commandline("Г        F4 - View Term File           Г           ESC - Previous              Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999feep",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        if whereprint({||pmiscfees()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pmiscfees()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      nlibrary := 0, nmedical := 0, nathletics := 0, nstudwel :=0,; //ncultural := 0,;
      nguidance := 0, naudio := 0, nstudevtfee := 0, nmodern := 0,;
      nregfee := 0, nothfee := 0

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SUMMARY OF MISCELLANEOUS FEES",nmaxcol))+"SUMMARY OF MISCELLANEOUS FEES"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||"                    MISCELLANEOUS                     AMOUNT    "})
aadd(abtext,{||"          -----------------------------------     --------------"})

/*
                   MISCELLANEOUS                     AMOUNT
         -----------------------------------     --------------
         12345678901234567890123456789012345     123,123,123.12
                                                 --------------
                     T O T A L                   123,123,123.12
*/

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        a999accp->(dbseek("1"+cyytenrp->enridno))
        a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+right(memvar->cterm,1)))

        nlibrary        := nlibrary + a999feep->feelibr
        nmedical        := nmedical + a999feep->feemed + a999feep->feeden
        nathletics      := nathletics + a999feep->feeath + a999feep->feeprisaa
      //  ncultural       := ncultural + a999feep->feeculturl
        nstudwel        := nstudwel + a999feep->feestudwel
        nguidance       := nguidance + a999feep->feeguid
        naudio          := naudio + a999feep->feeaudvis
        nstudevtfee     := nstudevtfee + a999feep->feestuddev
        nmodern         := nmodern + a999feep->feeupgrade
        nregfee         := nregfee + a999feep->feereg
        nothfee         := nothfee + a999feep->feetest + a999feep->feeother1 + a999feep->feeother2 + a999feep->feeother3 + a999feep->feeother4 + a999feep->feeother5 +;
                           a999feep->feecolfee1 + a999feep->feecolfee2 + a999feep->feecolfee3 + a999feep->feecolfee4

        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo

**printing**
pageprint(abtext)
@ prow()+01,10 say "Library"
@ prow()+00,50 say transform(nlibrary,"999,999,999.99")

@ prow()+01,10 say "Medical / Dental"
@ prow()+00,50 say transform(nmedical,"999,999,999.99")

@ prow()+01,10 say "Athletics"
@ prow()+00,50 say transform(nathletics,"999,999,999.99")

//@ prow()+01,10 say "Cultural"
//@ prow()+00,50 say transform(ncultural,"999,999,999.99")
@ prow()+01,10 say "Student Welfare"
@ prow()+00,50 say transform(nstudwel,"999,999,999.99")

@ prow()+01,10 say "Guidance"
@ prow()+00,50 say transform(nguidance,"999,999,999.99")

@ prow()+01,10 say "Audio / Visual"
@ prow()+00,50 say transform(naudio,"999,999,999.99")

@ prow()+01,10 say "Student Development Fee"
@ prow()+00,50 say transform(nstudevtfee,"999,999,999.99")

@ prow()+01,10 say "Modernization / Upgrading"
@ prow()+00,50 say transform(nmodern,"999,999,999.99")

@ prow()+01,10 say "Registration Fee"
@ prow()+00,50 say transform(nregfee,"999,999,999.99")

@ prow()+01,10 say "Other Misc Fees"
@ prow()+00,50 say transform(nothfee,"999,999,999.99")

@ prow()+01,50 say "=============="
@ prow()+01,17 say "ET O T A L"
@ prow()+00,50 say transform(nlibrary + nmedical + nathletics + nstudwel +;
                             nguidance + naudio + nstudevtfee + nmodern +;
                             nregfee + nothfee,"999,999,999.99")
@ prow()+00,00 say chr(18)
__eject()
return(nil)

*------------------------------------------------------------------------------*

function laboratoryfees()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      cyytenrp,cyytskdp,cfile,ccdx
private cterm,cdesc,;
        cdummy := "lab"+strzero(memvar->naccess,2),laboratory

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Summary of Laboratory Fees  ")
        commandline("Г        F4 - View Term File           Г           ESC - Previous              Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("/crunlib/c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+memvar->cterm+"skdp.dbf")
                fask(10,"  C"+memvar->cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        cyytskdp  := "c"+memvar->cterm+"skdp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,"a999lbfp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        if whereprint({||plaboratoryfees()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function plaboratoryfees()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile, ntotstud := 0, ntotamt := 0, skdno

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"SUBJECT"     ,"C",12,0},;
                                 {"STUDENT"     ,"N",07,0},;
                                 {"AMOUNT"      ,"N",12,2}},{||cdxsubj()})
        dbcloseall()
        return(nil)
endif
memvar->laboratory := memvar->cdummy
if(afile := openwcheck({{,,(memvar->laboratory+".TXT"),"laboratory",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
laboratory->(__dbzap()); laboratory->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SUMMARY OF LABORATORY FEES",nmaxcol))+"SUMMARY OF LABORATORY FEES"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||"            Subject         #Student           Amount    "})
aadd(abtext,{||"         ------------       --------       --------------"})

/*
            Subject         #Student           Amount
         ------------       --------       --------------
         123456789012       1234,123       123,123,123.12
                            --------       --------------
            T O T A L       1234,123       123,123,123.12
*/

**filtering data**
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student no. "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! cyytenrp->enrenrst $ "WV"
                for nctr := 1 to 16
                        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
                        if ! cyytenrp->&skdno == "00000"

                                cyytskdp->(dbseek(cyytenrp->&skdno))
                                a999accp->(dbseek("1"+cyytenrp->enridno))
                                a999lbfp->(dbseek(a999accp->accfeeyr+cyytskdp->skdintcod+a999accp->acccolcod))
                                fask(16,"  Processing subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                                do case
                                        case right(memvar->cterm,1) == "1"
                                                if a999lbfp->lbfamt1 > 0
                                                        if laboratory->(dbseek(cyytskdp->skdsubcod))
                                                                laboratory->(reclock())
                                                        else
                                                                laboratory->(dbappend())
                                                        endif
                                                        laboratory->subject := cyytskdp->skdsubcod
                                                        laboratory->student += 1
                                                        laboratory->amount  += a999lbfp->lbfamt1
                                                        laboratory->(dbcommit())
                                                        laboratory->(dbunlock())
                                                endif
                                        case right(memvar->cterm,1) == "2"
                                                if a999lbfp->lbfamt2 > 0
                                                        if laboratory->(dbseek(cyytskdp->skdsubcod))
                                                                laboratory->(reclock())
                                                        else
                                                                laboratory->(dbappend())
                                                        endif
                                                        laboratory->subject := cyytskdp->skdsubcod
                                                        laboratory->student += 1
                                                        laboratory->amount  += a999lbfp->lbfamt2
                                                        laboratory->(dbcommit())
                                                        laboratory->(dbunlock())
                                                endif
                                        case right(memvar->cterm,1) == "4"
                                                if a999lbfp->lbfamt3 > 0
                                                        if laboratory->(dbseek(cyytskdp->skdsubcod))
                                                                laboratory->(reclock())
                                                        else
                                                                laboratory->(dbappend())
                                                        endif
                                                        laboratory->subject := cyytskdp->skdsubcod
                                                        laboratory->student += 1
                                                        laboratory->amount  += a999lbfp->lbfamt3
                                                        laboratory->(dbcommit())
                                                        laboratory->(dbunlock())
                                                endif
                                endcase
                        else
                                exit
                        endif
                next
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo

**printing**
pageprint(abtext)
laboratory->(dbgotop())
do while ! laboratory->(eof())
        fask(16,"  Printing subject "+alltrim(laboratory->subject)+"  ",{" OK "},memvar->colorarray[06],.f.,nil)
        if prow() > 55
                __eject()
                pageprint(abtext)
        endif
        @ prow()+01,09 say laboratory->subject+space(7)+;
                           transform(laboratory->student,"9999,999")+space(7)+;
                           transform(laboratory->amount,"999,999,999.99")

        ntotstud += laboratory->student
        ntotamt  += laboratory->amount

        if nextkey() == K_ESC
                exit
        endif
        laboratory->(dbskip())
enddo
closewcheck(afile)
@ prow()+01,28 say "--------       --------------"
@ prow()+01,12 say "T O T A L"
@ prow()+00,28 say transform(ntotstud,"9999,999")+space(7)+transform(ntotamt,"999,999,999.99")
__eject()
return(nil)

static function cdxsubj()
field subject
private cdummyfile := alias()
index on subject tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
//TTUITION FEE AND COLLECTIONS COLLEGE
function collegecollections()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytassp,ayytpayp,cfile,ccdx,cyytenrp,ayytepc,idno
private cterm,cdesc,period,;
        cdummy := "fees"+strzero(memvar->naccess,2),fees

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
memvar->period := space(1)
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  COLLEGE TUITION FEE AND COLLECTIONS  ")
        commandline("Г        F4 - View Term File           Г           ESC - Previous              Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)

        @ 04,02 say "Exam Period :";
                color memvar->colorarray[02];
                get memvar->period pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"assp.dbf")
                fask(10,"  A"+memvar->cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+memvar->cterm+"assp"
        ayytpayp  := "a"+memvar->cterm+"payp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        ayytepc   := "a"+memvar->cterm+"epc"
        if(aopen2files := openwcheck({{,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,10},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,ayytepc,"ayytepc",_DBF_SHARED,,1},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        

        if whereprint({||pcollegecollections()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function pcollegecollections()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile,ntotstud := 0, ntotoa := 0, ntotass := 0, ntotasstotal := 0,ntotpasstotal := 0,;
      ntotlab := 0, ntotdisc := 0, ndiscount := 0, ntotpayment := 0, exam_periods := ""


if (memvar->period == "P")
              exam_periods := "Prelim"
        elseif (memvar->period == "M")
              exam_periods := "Midterm"
        else
              exam_periods := "Final"
endif


fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"COLCODE"     ,"C",02,0},;
                                 {"COLDESC"     ,"C",06,0},;
                                 {"STUDENT"     ,"N",07,0},;
                                 {"PAYMENT"     ,"N",12,2},; //collection
                                 {"OLDACCOUNT"  ,"N",12,2},; //old accounts
                                 {"ASSESSMENT"  ,"N",12,2},; // total asssessments
                                 {"PASSESSMENT"  ,"N",12,2},; // periodic asssessments
                                 {"DISCNT"      ,"N",12,2}},{||cdxcode1()})
        dbcloseall()
        return(nil)
endif
memvar->fees := memvar->cdummy
if(afile := openwcheck({{,,(memvar->fees+".TXT"),"fees",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
fees->(__dbzap()); fees->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SCHEDULE OF TUITION FEE AND COLLECTIONS",nmaxcol))+"SCHEDULE OF TUITION FEE AND COLLECTIONS"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""+chr(15)})
//aadd(abtext,{||" Course    #Student    Old Accounts     Assessment     Total Assessments      Collections       Discounts        Balance   "})
//aadd(abtext,{||"---------  --------   --------------   --------------  -----------------     --------------   --------------  -------------- "})
aadd(abtext,{||" Course    #Student    Old Accounts     Assessment     Total Assessments     "+exam_periods+" Assessment      Collections       Discounts        Balance   "})
aadd(abtext,{||"---------  --------   --------------   --------------  -----------------     --------------   --------------   --------------  -------------- "})
/* WAY LABOT ----------------------------------------------------------------------------------------------------------------------
 Course    #Student   Tuition Fees    Registration     Misc. Fees      Lab. Fees       Total Fees      Discounts     Account Rcvbls
---------  --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
12-123456  1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
           --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
TOTALS     1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
WAY LABOT -----------------------------------------------------------------------------------------------------------------------------------
*/

**filtering data**
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        
        //cyytenrp->(dbseek(right(ayytassp->assidno,8))) 
       
        if ! cyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" .and. cyytenrp->enrenrst == "C"


          if ayytassp->(dbseek("1"+cyytenrp->enridno))
              idno = "1"+cyytenrp->enridno
          elseif ayytassp->(dbseek("2"+cyytenrp->enridno))
              idno = "2"+cyytenrp->enridno
          elseif ayytassp->(dbseek("3"+cyytenrp->enridno))
               idno = "3"+cyytenrp->enridno
          endif

          ayytassp->(dbseek(idno))
          ayytpayp->(dbseek(idno+"OA"))
          a999accp->(dbseek(idno))
          ayytepc->(dbseek(cyytenrp->enridno))

          fask(10,"  Processing student no. "+ayytpayp->payidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)

                      if cyytenrp->enrcolcod $ "HN,MV,SN,MI,TL" //CHECK ALL COLCODE FOR MARINE TRANSPORTATION
                            if ! fees->(dbseek("MV"))
                                 c999colp->(dbseek("MV"))
                                  fees->(dbappend())
                                  fees->colcode   := "MV"
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->oldaccount := ayytpayp->payamt
                                  fees->assessment  := ayytassp->asstotal

                                  fees->passessment  := ayytepc->epexamdue

                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MV"))
                                  fees->(reclock())
                        
                                  fees->student    := fees->student + 1
                                  fees->oldaccount := fees->oldaccount + ayytpayp->payamt
                                  fees->assessment := fees->assessment + ayytassp->asstotal

                                  fees->passessment := fees->passessment + ayytepc->epexamdue

                                  fees->discnt     := fees->discnt  + a999accp->accsytadsc
                                  fees->payment    := fees->payment + a999accp->accamtpd

                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif           
                          
                      elseif cyytenrp->enrcolcod $ "HM,ML,MM,MR,SM" //CHECK ALL COLCODE FOR MARINE ENG
                            if ! fees->(dbseek("MM"))
                                 c999colp->(dbseek("MM"))
                                  fees->(dbappend())
                                  fees->colcode     := "MM"
                                  fees->coldesc     := c999colp->coldesabr
                                  fees->student     := fees->student + 1
                                  fees->oldaccount  := ayytpayp->payamt
                                  fees->assessment  := ayytassp->asstotal

                                  fees->passessment  := ayytepc->epexamdue

                                  fees->discnt      := a999accp->accsytadsc
                                  fees->payment     := a999accp->accamtpd

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MM"))
                                  fees->(reclock())
                        
                                  fees->student     := fees->student + 1
                                  fees->oldaccount  := fees->oldaccount + ayytpayp->payamt
                                  fees->assessment  := fees->assessment + ayytassp->asstotal

                                  fees->passessment := fees->passessment + ayytepc->epexamdue

                                  fees->discnt      := fees->discnt  + a999accp->accsytadsc
                                  fees->payment     := fees->payment + a999accp->accamtpd
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif

                      elseif cyytenrp->enrcolcod $ "MN,NS" // CHECK ALL COLCODE FOR NAME
                            if ! fees->(dbseek("MN"))
                                 c999colp->(dbseek("MN"))
                                  fees->(dbappend())
                                  fees->colcode   := "MN"
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student
                                  fees->oldaccount := ayytpayp->payamt
                                  fees->assessment  := ayytassp->asstotal

                                  fees->passessment  := ayytepc->epexamdue

                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek("MN"))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  fees->oldaccount  := fees->oldaccount + ayytpayp->payamt
                                  fees->assessment  := fees->assessment + ayytassp->asstotal

                                  fees->passessment := fees->passessment + ayytepc->epexamdue

                                  fees->discnt      := fees->discnt  + a999accp->accsytadsc
                                  fees->payment     := fees->payment + a999accp->accamtpd
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif

                      else
                            if ! fees->(dbseek(cyytenrp->enrcolcod))
                                 c999colp->(dbseek(cyytenrp->enrcolcod))
                                  fees->(dbappend())
                                  fees->colcode   := cyytenrp->enrcolcod
                                  fees->coldesc   := c999colp->coldesabr
                                  fees->student   := fees->student + 1
                                  fees->oldaccount := ayytpayp->payamt
                                  fees->assessment  := ayytassp->asstotal

                                  fees->passessment  := ayytepc->epexamdue

                                  fees->discnt    := a999accp->accsytadsc
                                  fees->payment   := a999accp->accamtpd

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek(cyytenrp->enrcolcod))
                                  fees->(reclock())
                        
                                  fees->student     := fees->student + 1
                                  fees->oldaccount  := fees->oldaccount + ayytpayp->payamt
                                  fees->assessment  := fees->assessment + ayytassp->asstotal

                                  fees->passessment := fees->passessment + ayytepc->epexamdue

                                  fees->discnt      := fees->discnt  + a999accp->accsytadsc
                                  fees->payment     := fees->payment + a999accp->accamtpd
                                  
                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif

                      endif         
        endif
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo


**printing data**
pageprint(abtext)
fees->(dbgotop())
do while ! fees->(eof())
        fask(10,"  Printing college "+fees->colcode+"-"+alltrim(fees->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say fees->colcode+"-"+fees->coldesc+"  "+;
                           transform(fees->student,"9999,999")+"  "+; 
                           transform(fees->oldaccount,"999,999,999.99")+"  "+;
                           transform(fees->assessment,"999,999,999.99")+"    "+;
                           transform(fees->assessment + fees->oldaccount ,"999,999,999.99")+"       "+;
                           transform(fees->passessment  ,"999,999,999.99")+"       "+;
                           transform(fees->payment,"999,999,999.99")+"  "+;
                           transform(fees->discnt,"999,999,999.99")+"    "+;
                           transform(fees->assessment  + fees->oldaccount -;
                                     fees->discnt - fees->payment,"999,999,999.99"+"  ")

       
        ntotstud += fees->student
        ntotoa  += fees->oldaccount
        ntotass  += fees->assessment
        ntotasstotal += fees->assessment + fees->oldaccount
        ntotpasstotal += fees->passessment
        ntotdisc += fees->discnt
        ntotpayment += fees->payment
        if nextkey() == K_ESC
                exit
        endif
        fees->(dbskip())
      
enddo
@ prow()+01,00 say "           --------  --------------  --------------    ---------------       ---------------    --------------    --------------   --------------"
@ prow()+01,00 say "ETOTALS  "+transform(ntotstud,"9999,999")+"   "+; 
                                 transform(ntotoa ,"999,999,999.99")+"   "+;
                                 transform(ntotass ,"999,999,999.99")+"    "+;
                                 transform(ntotasstotal,"999,999,999.99")+"      "+;
                                 transform(ntotpasstotal,"999,999,999.99")+"      "+;
                                 transform(ntotpayment ,"999,999,999.99")+"   "+;
                                 transform(ntotdisc ,"999,999,999.99")+"     "+;
                                 transform(ntotoa + ntotass -;
                                           ntotdisc - ntotpayment,"999,999,999.99")
                                                   

@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function cdxcode1()
field colcode
private cdummyfile := alias()
index on colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*




*------------------------------------------------------------------------------*
//TTUITION FEE AND COLLECTIONS TRAINING
function trainingollections()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aopen1files,aopen2files,aentryscr,cprocsts,;
      ayytassp,ayytpayp,zyytpayp,xyytpayp,ayytprsp,cfile,ccdx,cyytenrp,idno
private cterm,cdesc,;
        cdummy := "fees"+strzero(memvar->naccess,2),fees

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  TRAINING TUITION FEE AND COLLECTIONS  ")
        commandline("Г        F4 - View Term File           Г           ESC - Previous              Г")
        @ 03,01 say replicate("Ф",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        if ! file("a"+memvar->cterm+"assp.dbf")
                fask(10,"  A"+memvar->cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! file("a"+memvar->cterm+"payp.dbf")
                fask(10,"  A"+memvar->cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+memvar->cterm+"assp"
        ayytpayp  := "a"+memvar->cterm+"payp"
        zyytpayp  := "a"+memvar->cterm+"payp"
        xyytpayp  := "a"+memvar->cterm+"payp"
        ayytprsp  := "a"+memvar->cterm+"prsp"
        cyytenrp  := "c"+memvar->cterm+"enrp"
        if(aopen2files := openwcheck({{,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                      {,,ayytpayp,"ayytpayp",_DBF_SHARED,,3},;
                                      {,,zyytpayp,"zyytpayp",_DBF_SHARED,,10},;
                                      {,,xyytpayp,"xyytpayp",_DBF_SHARED,,4},;
                                      {,,ayytprsp,"ayytprsp",_DBF_SHARED,,1},;
                                      {,,"a999stcp",,_DBF_SHARED,,1},;
                                      {,,"a999accp",,_DBF_SHARED,,1},;
                                      {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                      {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        if whereprint({||ptrainingollections()}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif

        closewcheck(aopen2files)
        cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
        ferase(cfile);ferase(ccdx)
enddo
closewcheck(aopen1files)
restscr(alastscr)
return(nil)

static function ptrainingollections()
local abtext := {}, ncol, nmaxcol := 80, npage := 0, nctr := 0,;
      afile,ntotstud := 0, ntotoa := 0, ntotass := 0, ntotasstotal := 0,;
      ntotlab := 0, ntotdisc := 0, ndiscount := 0, ntotpayment := 0

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"COLCODE"     ,"C",02,0},;
                                 {"COLDESC"     ,"C",06,0},;
                                 {"STUDENT"     ,"N",07,0},;
                                 {"PAYMENT"     ,"N",12,2},; //collection
                                 {"OLDACCOUNT"  ,"N",12,2},; //old accounts
                                 {"ASSESSMENT"  ,"N",12,2},; // total asssessments
                                 {"DISCNT"      ,"N",12,2}},{||cdxcode1()})
        dbcloseall()
        return(nil)
endif
memvar->fees := memvar->cdummy
if(afile := openwcheck({{,,(memvar->fees+".TXT"),"fees",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
fees->(__dbzap()); fees->(dbreindex())

ncol := titlepos("UNIVERSITY OF CEBY",nmaxcol)
aadd(abtext,{||space(titlepos("UNIVERSITY OF CEBU",nmaxcol))+"UNIVERSITY OF CEBU"})
aadd(abtext,{||space(titlepos("Maritime Education and Training Center",nmaxcol))+"Maritime Education and Training Center"})
aadd(abtext,{||space(titlepos("Alumnos, Mambaling, Cebu City",nmaxcol))+"Alumnos, Mambaling, Cebu City"})
aadd(abtext,{||space(titlepos("Telephone Number: 261-9963",nmaxcol))+"Telephone Number: 261-9963"})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||space(titlepos("SCHEDULE OF TUITION FEE AND COLLECTIONS",nmaxcol))+"SCHEDULE OF TUITION FEE AND COLLECTIONS"})
aadd(abtext,{||space(titlepos(alltrim(memvar->cdesc),nmaxcol))+alltrim(memvar->cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||""})
aadd(abtext,{||""+chr(15)})
aadd(abtext,{||" Course    #Student    Old Accounts     Assessment     Total Assessments      Collections       Discounts        Balance   "})
aadd(abtext,{||"---------  --------   --------------   --------------  -----------------     --------------   --------------  -------------- "})

/* WAY LABOT ----------------------------------------------------------------------------------------------------------------------
 Course    #Student   Tuition Fees    Registration     Misc. Fees      Lab. Fees       Total Fees      Discounts     Account Rcvbls
---------  --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
12-123456  1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
           --------  --------------  --------------  --------------  --------------  --------------  --------------  --------------
TOTALS     1234,123  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12  123,123,123.12
WAY LABOT -----------------------------------------------------------------------------------------------------------------------------------
*/

**filtering data**
a999stcp->(dbgotop())
do while ! (a999stcp->(eof()))
        
        //cyytenrp->(dbseek(right(ayytassp->assidno,8))) 
        fask(10,"  Processing Training Code. "+alltrim(a999stcp->stccod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        //if ! cyytenrp->enrcolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,TM,GS,PB,ST,HU" .and. cyytenrp->enrenrst == "C"


          /*if ayytassp->(dbseek("1"+cyytenrp->enridno))
              idno = "1"+cyytenrp->enridno
          elseif ayytassp->(dbseek("2"+cyytenrp->enridno))
              idno = "2"+cyytenrp->enridno
          elseif ayytassp->(dbseek("3"+cyytenrp->enridno))
               idno = "3"+cyytenrp->enridno
          endif*/
          ayytpayp->(sx_setscope(_TOP_SCOPE   ,a999stcp->stccod))
          ayytpayp->(sx_setscope(_BOTTOM_SCOPE,a999stcp->stccod))
          ayytpayp->(dbgotop())
          while !(ayytpayp->(eof()))
              if alltrim(ayytpayp->paymach) == "1" && .and. ayytpayp->payamt > 0.00
                fask(10,"  Processing ID Number. "+ayytpayp->payidno+"  " ,{" Ok "},memvar->colorarray[06],.f.,nil)
                    ayytassp->(dbseek(ayytpayp->payidno))
                    a999accp->(dbseek(ayytpayp->payidno))
                    zyytpayp->(dbseek(ayytpayp->payidno+"OA"))
                    xyytpayp->(dbseek(ayytpayp->payidno+"U"))//upgrading payment
                    ayytprsp->(dbseek(ayytpayp->payidno+ayytpayp->paycolcod))//discount

                     
                            if ! fees->(dbseek(a999stcp->stccod))
                                 //c999colp->(dbseek("MV"))
                                  fees->(dbappend())
                                  fees->colcode   := a999stcp->stccod
                                  fees->coldesc   := a999stcp->stcdesabr
                                  fees->student   := fees->student + 1
                                  fees->oldaccount  := zyytpayp->payamt
                                  fees->assessment  := ayytpayp->payamt
                                  //fees->discnt      := a999accp->accsytadsc
                                  fees->discnt      := ayytprsp->prstuiadsc
                                  //fees->payment     := a999accp->accamtpd
                                  fees->payment     := xyytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())

                            elseif fees->(dbseek(a999stcp->stccod))
                                  fees->(reclock())
                        
                                  fees->student   := fees->student + 1
                                  fees->oldaccount  := fees->oldaccount + zyytpayp->payamt
                                  fees->assessment  := fees->assessment + ayytpayp->payamt
                                  //fees->discnt      := fees->discnt  + a999accp->accsytadsc
                                  fees->discnt      := fees->discnt + ayytprsp->prstuiadsc
                                  //fees->payment     := fees->payment + a999accp->accamtpd
                                  fees->payment     := fees->payment + xyytpayp->payamt

                                  fees->(dbcommit())
                                  fees->(dbunlock())
                            endif
                endif
                ayytpayp->(dbskip())
          enddo
          clearscope()
        
        if nextkey() == K_ESC
                exit
        endif
       a999stcp->(dbskip())
enddo


**printing data**
pageprint(abtext)
fees->(dbgotop())
do while ! fees->(eof())
        fask(10,"  Printing college "+fees->colcode+"-"+alltrim(fees->coldesc)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        @ prow()+01,00 say fees->colcode+"-"+fees->coldesc+"  "+;
                           transform(fees->student,"9999,999")+"  "+; 
                           transform(fees->oldaccount,"999,999,999.99")+"  "+;
                           transform(fees->assessment,"999,999,999.99")+"    "+;
                           transform(fees->assessment + fees->oldaccount ,"999,999,999.99")+"       "+;
                           transform(fees->payment,"999,999,999.99")+"  "+;
                           transform(fees->discnt,"999,999,999.99")+"    "+;
                           transform(fees->assessment  + fees->oldaccount -;
                                     fees->discnt - fees->payment,"999,999,999.99"+"  ")

       
        ntotstud += fees->student
        ntotoa  += fees->oldaccount
        ntotass  += fees->assessment
        ntotasstotal += fees->assessment + fees->oldaccount
        ntotdisc += fees->discnt
        ntotpayment += fees->payment
        if nextkey() == K_ESC
                exit
        endif
        fees->(dbskip())
      
enddo
@ prow()+01,00 say "           --------  --------------  --------------    ---------------       ---------------    --------------   --------------"
@ prow()+01,00 say "ETOTALS  "+transform(ntotstud,"9999,999")+"   "+; 
                                 transform(ntotoa ,"999,999,999.99")+"   "+;
                                 transform(ntotass ,"999,999,999.99")+"    "+;
                                 transform(ntotasstotal,"999,999,999.99")+"      "+;
                                 transform(ntotpayment ,"999,999,999.99")+"   "+;
                                 transform(ntotdisc ,"999,999,999.99")+"     "+;
                                 transform(ntotoa + ntotass -;
                                           ntotdisc - ntotpayment,"999,999,999.99")
                                                   

@ prow()+00,00 say chr(18)
__eject()
closewcheck(afile)
return(nil)


static function cdxcode2()
field colcode
private cdummyfile := alias()
index on colcode tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)

*------------------------------------------------------------------------------*