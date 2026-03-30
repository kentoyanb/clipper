/*----------------------------------------------------------------------------*/
# include "inkey.ch"
# include "getexit.ch"
# include "rddsys.ch"

/*-------Function-header-ends-Here--------------------------------------------*/
// Cashier Routine Library Routine
// Organized August 19, 2002.

/*----------------------------------------------------------------------------*/
// Generate O.R. serial no
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function Gen_payrefno(Cashier_Name)
Local Retval := {}
Local Oldmonth   := space(02)
Local Olddate    := ctod('  /  /  ')
Local Literal    := space(01)
Local Counter    := 0
Local pyus       := "F:\arunlib\a999pyus.dbf"
Local pyusi      := "F:\arunlib\cdx\a999pyus.cdx"
Local oldrec     := 0
Local refcounter := space(11)


 Asize(Retval,3)
 dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
 dbsetindex(pyusi)
 set order to tag short_name
 pyus->(dbgotop())

 Cashier_Name := Alltrim(Upper(Cashier_Name))

   Do Case
      Case pyus->(dbseek(Cashier_Name))  == .F.
         Alert("Cashier Name Not Found ! ",{"Cancel"})
           Retval[1] := Nil
           Retval[2] := Nil
           Retval[3] := Nil

      Case pyus->(dbseek(Cashier_Name)) == .T.

    // Get The Present Value to DBF
       olddate  := pyus->last_date         //Val(substr(pyus->payrefno,2,2))
       oldmonth := str(month(olddate),2) //Substr(pyus->payrefno,1,1)
    

    // Check If Changes in date and Month Occurs

       If oldmonth <>  str(month(date()),2)
          oldmonth := str(month(date()),2)
         Else
         Oldmonth := Oldmonth
        Endif

      If  day(olddate) <> day(date())
           olddate  := date()
           Counter  := pyus->paycount
           Counter  := 0
        Else
           olddate  := olddate
           Counter  := pyus->paycount
       Endif


      Counter++
      Literal  := pyus->literal_cn
      Counter  := PADL(alltrim(STR(Counter)),4,"0")

       oldrec      := recno()
       pyus->(dbgotop())
       refcounter  := pyus->payrefno
       refcounter  := val(refcounter)
       refcounter++
       refcounter  := padl(alltrim(str(refcounter)),11,"0")
       // For top record
       do while !pyus->(dbrlock()) .and. !neterr()
       enddo
        pyus->payrefno := refcounter


       // Return to cashier record
           pyus->(dbgoto(oldrec))
           set order to tag short_name

            Retval[1] := refcounter
            Retval[2] := pyus->chfullnam
            Retval[3] := pyus->literal_cn

          do while !pyus->(dbrlock()) .and. !neterr()
          enddo
            pyus->payrefno  := Retval[1]
            pyus->paycount  := Val(Counter)
            pyus->last_date := date()
            pyus->last_time := time()
            pyus->(dbunlock())
    Endcase
 pyus->(dbclosearea())

Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Function to Validate Term
// Written by Edgar J. Esguerra

Function Term_Pre_Valid(vterm)
Local dbheader      := {"TERM","SEMESTER DESCRIPTION","STATUS"}
Local dbpictur      := {"@!","@!","@!"}
Local dbfields      := {1,2,3}
Local term          := "F:\crunlib\term.dbf"
Local termi         := "F:\crunlib\cdx\term.cdx"

dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
dbsetindex(termi)
SETKEY( K_F4, {|| dbsetorder("tterm"),gbrow(1,5,22,74,@vterm,dbheader,dbfields,dbpictur,1)})
Return .T.
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Obtain the term from term file
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_term(y,x,lenght,vterm,term_desc,term_stat)
Local Retval := .F.
Local choice
Local term    := "F:\crunlib\term.dbf"
Local termi   := "F:\crunlib\cdx\term.cdx"

If !used()
dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
dbsetindex(termi)
set order to tag tterm
Endif

set order to tag tterm
term->(dbgotop())

asize(term_stat,3)

 DO CASE
    CASE term->(dbseek(trim(vterm))) == .F. .OR. Empty(vterm)
              Retval := .F.
              Choice :=  Alert("Semester code does not exist! ",{"Retry"})
               If Choice == 1
                @ y,x say space(lenght)
                vterm := space(05)
               Endif

   CASE term->(dbseek(trim(vterm))) == .T.
        DO CASE
           CASE term->termstatus == "C"
               Retval := .F.
               choice := Alert("Semestral term already closed!",{"Cancel"})
               If Choice == 1
                 @ y,x say space(lenght)
                 vterm := space(05)
               Endif

            CASE term->termstatus == " "
                 Retval := .T.
                 term_stat[1] := term->termcode
                 term_stat[2] := term->termdesc
                 term_stat[3] := term->termstatus
                 term_desc    := term->termdesc
                 @ y,x say term_desc
        ENDCASE
 ENDCASE

 IF Retval == .T.
   term->(dbclosearea())
   SETKEY(K_F4,NIL)
 ENDIF
Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Post Valid and Close the Current Open Dbf
// Written by Edgar Esguerra

  Function Post_Valid_Dbf()
   Local current_alias
      tone(500)
      SETKEY(K_F4,NIL)
      current_alias := Alias()
      (current_alias)->(dbclosearea())
  Return Nil
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Pre Validate Student Number
// Written by Edgar J. Esguerra

Function Idno_Pre_Valid(studno)
 Local sm1p        := "F:\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\crunlib\cdx\c999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Course","Mjr","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","X","9."}
 Local stud_fields := {1,2,3,4,5,8,9,10}

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 SETKEY( K_F4, {|| dbsetorder("last_nam"),gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)})
Return .T.
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Function Get Student Number
// Written by Edgar J. Esguerra

Function get_studno(studno,stud_stat)
 Local Retval := .F.
 Local choice
 Local sm1p   := "F:\crunlib\c999sm1p.dbf"
 Local sm1pi  := "F:\crunlib\cdx\c999sm1p.cdx"

If !used()
 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 set order to tag tidno
Endif

set order to tag tidno
sm1p->(dbgotop())
asize(stud_stat,11)

if ! len(alltrim(studno))==8
   lmsgbox({"Info!","Please check ID # "},{"Ok"})
   Retval := .F.
else
   Do Case
      Case sm1p->(dbseek(trim(studno)))  == .T. .and. sm1p->sm1metc == .T.
           Retval := .F.
           lmsgbox({"Info!","METC Account!"},{"Cancel"})

      Case sm1p->(dbseek(trim(studno)))  == .F.  .OR. Empty(Trim(studno))
           Retval := .F.
           Choice := Alert("Student number not found!",{"Retry"})
           If Choice == 1
              studno := space(08)
           Endif

      Case sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  trim(sm1p->sm1majcod)
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schtrm)
           stud_stat[09] :=  get_term_desc(stud_stat[08])
           stud_stat[10] := get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] := get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,10 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
  Endcase
endif

 IF Retval == .T.
   sm1p->(dbclosearea())
   SETKEY(K_F4,NIL)
 Endif
Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Function to obtain payment code
// written by Edgar J. Esguerra
// Obtain the payment code
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_payc(paycode,pay_clas,paystat)
Local retval   := .F.
Local pycd     := "f:\arunlib\a999pycd.dbf"
Local pycdi    := "f:\arunlib\cdx\a999pycd.cdx"
Local dbheader := {"CODE","DESCRIPTION","TYPE"}
Local dbpictur := {"@!","@!","@!"}
Local dbfields := {1,2,3}
Local payname  := space(10)

asize(paystat,3)
dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
dbsetindex(pycdi)
set order to tag py_code
 

Do While .T.
DO CASE
   CASE LASTKEY() == K_ESC
                 Retval := .F.
                 @ 06,25 say space(30)
                 @ 06,66 say space(10)
                 paystat[1] := NIL
                 paystat[2] := NIL
                 paystat[3] := NIL
                 Exit
   CASE EMPTY(paycode)
               set order to tag py_desc
               gbrow(1,5,22,74,@paycode,dbheader,dbfields,dbpictur,1)
               set order to tag py_code
               loop
   CASE pycd->(dbseek(trim(paycode))) == .F.
                Alert("Payment code does not exist! ",{"Retry"})
                @ 06,25 say space(30)
                @ 06,66 say space(10)
                paycode := space(04)
                loop
   CASE pycd->(dbseek(trim(paycode))) == .T.
                 paystat[1] := pycd->procode
                 paystat[2] := pycd->prodesc
                 paystat[3] := pycd->protype
                 pay_clas   := pycd->protype

                    DO CASE
                       CASE pycd->protype == "A"
                            payname := "STUD.ACCT."
                       CASE pycd->protype == "N"
                            payname := "NON.ST.AC."
                       CASE pycd->protype == "O"
                            payname := "OTHER INC."
                    ENDCASE
                @ 06,25 say pad(pycd->prodesc,30," ")
                @ 06,66 say pad(payname,10," ")
                 Retval := .T.
                 Exit
    ENDCASE
Enddo
pycd->(dbclosearea())
Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Obtain the Full semester description from term File
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function Get_term_desc(tterm)
 Local term_desc := space(40)
 Local term    := "F:\crunlib\term.dbf"
 Local termi   := "F:\crunlib\cdx\term.cdx"
 dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
 dbsetindex(termi)
 set order to tag tterm
 term->(dbgotop())

   If  term->(dbseek(tterm))  == .T.
       term_desc := trim(term->termdesc)
   Else
       term_desc := ""
   Endif
 term->(dbclosearea())
 Return term_desc

/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
 Function MGet_term_desc(tterm)   // METC TERM DESC
 Local term_desc := space(40)
 Local term    := "F:\metc\crunlib\term.dbf"
 Local termi   := "F:\metc\crunlib\term.cdx"
 dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
 dbsetindex(termi)
 set order to tag term1
 term->(dbgotop())

   If  term->(dbseek(val(tterm)))  == .T.
       term_desc := trim(term->name)
   Else
       term_desc := ""
   Endif
 term->(dbclosearea())
 Return term_desc
/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Obtain the Full course description form c999colp file
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

 Function get_cour_desc(cour_maj)
 Local cour_desc   := ""
 Local colp        := "F:\crunlib\c999colp.dbf"
 Local colpi       := "F:\crunlib\cdx\c999colp.cdx"

 dbusearea(.T.,"DBFCDX",colp,"colp",.T.,.F.)
 dbsetindex(colpi)
 set order to tag Tcodmaj
 colp->(dbgotop())

  DO CASE
     CASE  colp->(dbseek(pad(cour_maj,3," "))) == .T.
      cour_desc := trim(colp->course)
     CASE  colp->(dbseek(pad(cour_maj,3," "))) == .F.
      cour_desc := ""
  ENDCASE

colp->(dbclosearea())
Return cour_desc

/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Obtain the Full course abbreviation form c999colp file
// For Cashier Program
// By Edgar J. Esguerra
// Aug 21, 2002

 Function get_cour_abbr(cour_maj)
 Local cour_abbr   := ""
 Local colp        := "F:\crunlib\c999colp.dbf"
 Local colpi       := "F:\crunlib\cdx\c999colp.cdx"


 dbusearea(.T.,"DBFCDX",colp,"colp",.T.,.F.)
 dbsetindex(colpi)
 set order to tag Tcodmaj
 colp->(dbgotop())

  DO CASE
     CASE colp->(dbseek(pad(cour_maj,3," "))) == .T.
      cour_abbr := trim(colp->coldesabr)
     CASE colp->(dbseek(pad(cour_maj,3," "))) == .F.
      cour_abbr := ""
  ENDCASE

 colp->(dbclosearea())

Return cour_abbr

/*-------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Obtain the Full student name (college) from c999sm1p
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_nam(studno)
 Local Retval
 Local sm1p        := "F:\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\crunlib\cdx\c999sm1p.cdx"

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 set order to tag sm1idno
 sm1p->(dbgotop())

      If sm1p->(dbseek(trim(studno)))  == .T.
           retval := trim(sm1p->sm1lstnam)+' '+ trim(sm1p->sm1fstnam)+' '+trim(sm1p->sm1midnam)+'.'
      Endif
           sm1p->(dbclosearea())
Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Obtain the Full course description form c999colp file
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_crs(studno)
 Local retval
 Local sm1p        := "F:\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\crunlib\cdx\c999sm1p.cdx"

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 set order to tag sm1idno
 sm1p->(dbgotop())

      If sm1p->(dbseek(trim(studno)))  == .T.
           retval := alltrim(sm1p->sm1colcod)+alltrim(sm1p->sm1majcod)
      Endif
          sm1p->(dbclosearea())

      retval  := get_cour_desc(retval)

 Return Retval
 /*------Function-header-ends-Here--------------------------------------------*/


/*----------------------------------------------------------------------------*/
// Obtain the full payment code from paycode file
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_pcd(paycode)
Local retval
Local pycd     := "f:\arunlib\a999pycd.dbf"
Local pycdi    := "f:\arunlib\cdx\a999pycd.cdx"

dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
dbsetindex(pycdi)
set order to tag py_code
pycd->(dbgotop())

   If pycd->(dbseek(trim(paycode))) == .T.
      retval :=  pycd->prodesc
   endif

pycd->(dbclosearea())
Return Retval

/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Obtain the full Teller Name from pyus table
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

Function get_tlr(teller_code)
 Local pyus       := "F:\arunlib\a999pyus.dbf"
 Local pyusi      := "F:\arunlib\cdx\a999pyus.cdx"
 Local retval

 dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
 dbsetindex(pyusi)
 set order to tag cnt_letter
 pyus->(dbgotop())

      If pyus->(dbseek(teller_code))  == .T.
          Retval := pyus->chfullnam
      Endif

 pyus->(dbclosearea())

 Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Save payment details to PAYM (Payment Master File)

 Function Save2PAYM(vterm,payment_details)

  Local paym  := "F:\arunlib\a"+substr(alltrim(vterm),3,3)+"paym.dbf"
  Local paymi := "F:\arunlib\cdx\a"+substr(alltrim(vterm),3,3)+"paym.cdx"

  dbusearea(.T.,"DBFCDX",paym,"paym",.T.,.F.)
  dbsetindex(paymi)
  set order to tag refno

    If !neterr()
      paym->(dbappend())
      do while !paym->(dbrlock()) .and. !neterr()
      enddo
         replace paym->payrefno  with payment_details[01]
         replace paym->paydte    with payment_details[02]
         replace paym->payentime with payment_details[03]
         replace paym->paytype   with payment_details[04]
         replace paym->paycate   with payment_details[05]
         replace paym->procode   with payment_details[06]
         replace paym->sm1idno   with payment_details[07]
         replace paym->payamt    with payment_details[08]
         replace paym->paychkno  with payment_details[09]
         replace paym->paychknam with payment_details[10]
         replace paym->paynamto  with payment_details[11]
         replace paym->paytelr   with payment_details[12]
         replace paym->payentusr with payment_details[13]
         replace paym->payentws  with payment_details[14]
         replace paym->payfile   with payment_details[15]
         replace paym->sm1colcod with payment_details[16]
         replace paym->sm1majcod with payment_details[17]
         replace paym->sm1yrlvl  with payment_details[18]
         replace paym->payprncntr with payment_details[20]
         replace paym->payserial with payment_details[21]

      paym->(dbcommit())
      paym->(dbunlock())
    Endif

   paym->(dbclosearea())
   Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/

// Save payment details to PAYP (Payment File UCLM)

 Function Save2PAYP(vterm,payment_details)

  Local payp  := "F:\arunlib\a"+substr(alltrim(vterm),3,3)+"payp.dbf"
  Local paypi := "F:\arunlib\cdx\a"+substr(alltrim(vterm),3,3)+"payp.cdx"

  dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
  dbsetindex(paypi)
  set order to tag trefno

    If !neterr()
      payp->(dbappend())
      do while !payp->(dbrlock()) .and. !neterr()
      enddo
         replace payp->payrefno  with payment_details[01]
         replace payp->paydte    with payment_details[02]
         replace payp->payidno   with payment_details[07]
         replace payp->paytyp    with payment_details[04]
         replace payp->paytelr   with payment_details[12]
         replace payp->payamt    with payment_details[08]
         replace payp->payentdte with payment_details[02]
         replace payp->payenttme with payment_details[03]
         replace payp->payentusr with payment_details[13]
         replace payp->payentws  with payment_details[14]
         replace payp->paytag    with 'P'
         replace payp->payposted with .F.
         replace payp->paychknam with payment_details[10]
         replace payp->paychkno  with payment_details[09]
         replace payp->paycode   with payment_details[06]
      payp->(dbcommit())
      payp->(dbunlock())
    Endif

   payp->(dbclosearea())
   Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Save payment details to PAYP (Payment File UCLM Elementary and High School)

 Function eSave2PAYP(vterm,payment_details)

  Local payp  := "F:\erunlib\e"+substr(alltrim(vterm),3,3)+"payp.dbf"
  Local paypi := "F:\erunlib\cdx\e"+substr(alltrim(vterm),3,3)+"payp.cdx"

  dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
  dbsetindex(paypi)
  set order to tag trefnum

    If !neterr()
      payp->(dbappend())
      do while !payp->(dbrlock()) .and. !neterr()
      enddo
         replace payp->payrefno  with payment_details[01]
         replace payp->paydate   with payment_details[02]
         replace payp->payidno   with payment_details[07]

     Do Case
        Case payment_detail[04] == '1'
         replace payp->paytype  with 'C'
        Case payment_detail[04] == '0'
         replace payp->paytype  with 'K'
     Endcase

         replace payp->paycode     with "PYMT"
         replace payp->payteller   with payment_details[12]
         replace payp->payamt      with payment_details[08]
         replace payp->payentdte   with payment_details[02]
       //  replace payp->payenttme with payment_details[03]
         replace payp->payuser     with payment_details[13]
       //  replace payp->payentws  with payment_details[14]
         replace payp->paytag      with 'P'
         replace payp->payposted   with .F.
         replace payp->paychknam   with payment_details[10]
         replace payp->paychkno    with payment_details[09]
       //replace payp->paycode     with payment_details[06]
      payp->(dbcommit())
      payp->(dbunlock())
    Endif

   payp->(dbclosearea())
   Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
  Function PRINTOR(vterm,payment_details)
    Local Counter := 1
    Local textlenght
    Local choice
    Local ttime
    Local MARGIN := 3

    // Check either payment_details has empty elements

       For Counter := 1 to Len(payment_details)
        IF(EMPTY(payment_details[Counter]),"",payment_details[Counter] := Payment_details[Counter])
       Next
  Do While .T.

   If !isprinter()
        inkey(1)
        Choice := Alert("Printer not ready or offline please check and try again!",{"Retry","Cancel"})
            If Choice == 2
               Exit
            Endif
        Else

             Set Device to printer
             Set Printer On
             PrintStyle("line",2)
             PrintStyle("line",2)
             setprc(0,0)


    Textlenght := Trim(amttochar(payment_details[08]))
    ttime := TRANSFORM(payment_details[03],"99:99:99")
    @ 01,50 say "O.R. NO.:   "+ payment_details[01]
    @ 02,50 say ALLTRIM(left(cmonth(payment_details[2]),3))+' '+ ;
              ALLTRIM(str(day(payment_details[2])))+', '+ALLTRIM(str(year(payment_details[2])))
//  MAR 20, 2010 10:00:00AM

    @ 02,63 say ampm(ttime)

    if payment_details[20]>0
//      @ 03,50 say "Serial#: "+PADR(memvar->cSN,15," ")+ "   " +if(payment_details[20]>0,"EReprint: "+transform(payment_details[20],"999")+"F","")
      @ 03,50 say "Serial#: "+PADR(payment_details[21],15," ")+ "   " +if(payment_details[20]>0,"EReprint: "+transform(payment_details[20],"999")+"F","")
    else
//      @ 03,50 say "Serial#: "+memvar->cSN
      @ 03,50 say "Serial#: "+payment_details[21]
    endif

//    @ 04,00+MARGIN say ""
    @ 05,23 say Get_term_desc(vterm)
    @ 05,23 say Get_term_desc(vterm)
    //@ 05,00+MARGIN say ""
    @ 06,01+MARGIN say " Received from   : "+payment_details[07]+" "+payment_details[11]
    @ 07,01+MARGIN say " Course major/yr : "+get_cour_abbr(payment_details[16]+payment_details[17])+' '+payment_details[18]
    @ 08,01+MARGIN say " Payment mode    : "+IF(ALLTRIM(payment_details[4]) == "1","CASH","CHECK")
    @ 09,01+MARGIN say "   Check number  : "+IF(!Empty(payment_details[09]),TRIM(payment_details[09]),"")
    @ 10,01+MARGIN say "   Check name    : "+IF(!Empty(payment_details[10]),TRIM(payment_details[10]),"")
    @ 11,01+MARGIN say " Payment amount  : "+"Php"+PADL(ALLTRIM(TRANSFORM(payment_details[08],"9,999,999.99")),15,"*")


  If Len(Textlenght) > 50
//    @ 12,01+MARGIN say " Amount in words : "+PADR(Substr(Textlenght,1,50),50,'-')
//    @ 13,01+MARGIN say "                   "+PADR(Substr(Textlenght,51,Len(Textlenght)),Len(Textlenght)-50,'-')
    @ 12,01+MARGIN say " Amount in words : "+PADR(Textlenght,90,'-')+""
//    @ 12,01+MARGIN say " Amount in words : "+padr(1234567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567890"
  Else
    @ 12,01+MARGIN say " Amount in words : "+PADR(Substr(Textlenght,1,50),50,'-')
    @ 13,01+MARGIN say ""
  Endif

    @ 13,01+MARGIN say " Payment purpose : "+IF(!Empty(payment_details[19]),TRIM(payment_details[19]),"")
    @ 14,01+MARGIN say ""
    @ 15,01+MARGIN say " ___________________________________________"
    @ 16,01+MARGIN say " Received by : "+ALLTRIM(payment_details[13])
    @ 17,01+MARGIN say " When payment is made during enrollment period any changes with regards to "
    @ 18,01+MARGIN say " course and year level shall take effect after the enrollment process..... "
    @ 19,01+MARGIN say " THIS SERVE AS YOUR OFFICIAL RECEIPT."
    @ 20,01+MARGIN say ""  // forgot to add this line ... (Aug 25,2010)
    eject
    setprc(0,0)
    PrintStyle("line",66)
   Set Device To Screen
   Set Printer Off
   Exit
 Endif
Enddo

Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
//Elementary and High School  Routine Start Here

Function eTerm_Pre_Valid(vterm)

Local dbheader      := {"TERM","DESCRIPTION","STATUS"}
Local dbpictur      := {"@!","@!","@!"}
Local dbfields      := {1,2,3}
Local term    := "F:\erunlib\e999term.dbf"
Local termi   := "F:\erunlib\cdx\e999term.cdx"

dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
dbsetindex(termi)
SETKEY( K_F4, {|| dbsetorder("TCODE"),gbrow(1,5,22,74,@vterm,dbheader,dbfields,dbpictur,1)})
Return .T.
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Obtain the term from eterm file  (Elementary and High School Term File)
// For Cashier Program
// By Edgar J. Esguerra
// Sept 04, 2002

Function eget_term(y,x,lenght,vterm,term_desc,term_stat)

Local Retval := .F.
Local choice
Local term    := "F:\erunlib\e999term.dbf"
Local termi   := "F:\erunlib\cdx\e999term.cdx"

If !used()
dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
dbsetindex(termi)
set order to tag TCODE
Endif


set order to tag TCODE
term->(dbgotop())

asize(term_stat,3)

 DO CASE

   CASE term->(dbseek(trim(vterm))) == .F. .OR. Empty(vterm)
              Retval := .F.
              Choice :=  Alert("Semester code does not exist! ",{"Retry"})
               If Choice == 1
                @ y,x say space(lenght)
                vterm := space(05)
               Endif

   CASE term->(dbseek(trim(vterm))) == .T.
        DO CASE
           CASE term->termstatus == "C"
               Retval := .F.
               choice := Alert("Semestral term already closed!",{"Cancel"})
               If Choice == 1
                 @ y,x say space(lenght)
                 vterm := space(05)
               Endif

            CASE term->termstatus == " "
                 Retval := .T.
                 term_stat[1] := term->termcode
                 term_stat[2] := term->termdesc
                 term_stat[3] := term->termstatus
                 term_desc    := term->termdesc
                 @ y,x say term_desc
        ENDCASE
 ENDCASE

 IF Retval == .T.
   term->(dbclosearea())
   SETKEY(K_F4,NIL)
 ENDIF

Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/

Function EIdno_Pre_Valid(studno)
 Local sm1p        := "F:\erunlib\e999sm1p.dbf"
 Local sm1pi       := "F:\erunlib\cdx\e999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Level","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","X","9."}
 Local stud_fields := {1,3,2,4,5,7,8}

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 SETKEY( K_F4, {|| dbsetorder("tname1"),gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)})
Return .T.
/*------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
Function eget_studno(studno,stud_stat)
 Local Retval := .F.
 Local choice
 Local sm1p        := "F:\erunlib\e999sm1p.dbf"
 Local sm1pi       := "F:\erunlib\cdx\e999sm1p.cdx"

If !used()
dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
dbsetindex(sm1pi)
set order to tag tidno
Endif

set order to tag tidno
sm1p->(dbgotop())

asize(stud_stat,11)

if ! len(alltrim(studno))==8
   lmsgbox({"Info!","Please check ID # "},{"Ok"})
   Retval := .F.
else
    Do Case
      Case sm1p->(dbseek(trim(studno)))  == .F.  .OR. Empty(Trim(studno))
           Retval := .F.
           Choice := Alert("Student number not found!",{"Retry"})
           If Choice == 1
              studno := space(08)
           Endif

      Case sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1grade)
           stud_stat[06] :=  "" // Suppose to be for major
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schyr)
           stud_stat[09] :=  eget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.

   Endcase
endif

 IF Retval == .T.
   sm1p->(dbclosearea())
   SETKEY(K_F4,NIL)
 Endif

Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Function Get Term Desc For High School & Elementary
// Written By: Edgar J. Esguerra
// Sept 5, 2004

Function eGet_term_desc(tterm)
 Local term_desc := space(40)
 Local term    := "F:\erunlib\e999term.dbf"
 Local termi   := "F:\erunlib\cdx\e999term.cdx"
 dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
 dbsetindex(termi)
 set order to tag tcode
 term->(dbgotop())

   If  term->(dbseek(tterm))  == .T.
       term_desc := trim(term->termdesc)
   Else
       term_desc := ""
   Endif
 term->(dbclosearea())
 Return term_desc
/*------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// METC Routine Start Here

Function MIdno_Pre_Valid(studno)
 Local sm1p        := "F:\metc\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\metc\crunlib\c999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Level","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","9"}
 Local stud_fields := {1,2,3,4,6,12,13}


 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)

 SETKEY( K_F4, {|| dbsetorder("C999SM12"),gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)})

Return .T.
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
Function mget_studno(studno,stud_stat)
 Local Retval := .F.
 Local choice

 Local sm1p   := "F:\metc\crunlib\c999sm1p.dbf"
 Local sm1pi  := "F:\metc\crunlib\c999sm1p.cdx"
 asize(stud_stat,11)

 If !used()
  dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
  dbsetindex(sm1pi)
  set order to tag C999SM11
  sm1p->(dbgotop())
 Endif
 
set order to tag C999SM11
sm1p->(dbgotop())


if ! len(alltrim(studno))==8
   lmsgbox({"Info!","Please check ID # "},{"Ok"})
   Retval := .F.
else
    Do Case
      Case sm1p->(dbseek(trim(studno)))  == .T. .and. sm1p->sm1uclm == .T.
           Retval := .F.
           lmsgbox({"Info!","Account has been transferred to UCLM!"},{"Cancel"})

      Case sm1p->(dbseek(trim(studno)))  == .F.  .OR. Empty(Trim(studno))
           Retval := .F.
           Choice := Alert("Student number not found!",{"Retry"})
           If Choice == 1
              studno := space(08)
           Endif

      Case sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  ""   // Suppose to be Major but METC dont Have
           stud_stat[07] :=  Alltrim(str(sm1p->sm1yrlevl))
           stud_stat[08] :=  transform(str(sm1p->sm1schtrm),"9999")
           stud_stat[09] :=  mget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
   Endcase
endif
   
 IF Retval == .T.
   sm1p->(dbclosearea())
   SETKEY(K_F4,NIL)
 Endif
Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Save payment details to PAYP (Payment File METC)

 Function MSave2PAYP(vterm,payment_details)

  Local payp    := "F:\metc\arunlib\a"+substr(alltrim(vterm),3,3)+"payp.dbf"
  Local paypi   := "F:\metc\arunlib\a"+substr(alltrim(vterm),3,3)+"payp.cdx"
  Local tagname := 'a'+substr(alltrim(vterm),3,3)+'pay1'


  dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
  dbsetindex(paypi)
  set order to tag tagname

    If !neterr()
      payp->(dbappend())
      do while !payp->(dbrlock()) .and. !neterr()
      enddo
         replace payp->payrefno   with substr(payment_details[01],4,8)
         replace payp->payidno    with '1'+alltrim(payment_details[07])
         replace payp->paytyp     with payment_details[04]
         replace payp->paydte     with payment_details[02]
         replace payp->paycolcod  with alltrim(payment_details[16]+payment_details[17])
         replace payp->payyrlevl  with payment_details[18]
         replace payp->paysyt     with substr(alltrim(vterm),3,3)
         replace payp->paytelr    with payment_details[12]
         replace payp->payamt     with payment_details[08]
         replace payp->payentdte  with payment_details[02]
         replace payp->payenttme  with str(payment_details[03])
         replace payp->payentusr  with payment_details[13]
         replace payp->payentws   with payment_details[14]
         replace payp->paytag     with 'P'
      payp->(dbcommit())
      payp->(dbunlock())
    Endif

   payp->(dbclosearea())
   Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Short Courses Routine Start Here

Function SIdno_Pre_Valid(studno)

 Local stmast       := "F:\crunlib\short\stmast.dbf"
 Local stmasti      := "F:\crunlib\short\cdx\stmast.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X."}
 Local stud_fields := {1,2,3,4}

 dbusearea(.T.,"DBFCDX",stmast,"stmast",.T.,.F.)
 dbsetindex(stmasti)

 SETKEY( K_F4, {|| dbsetorder("tlstnam"),gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)})

Return .T.
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
Function Sget_studno(studno,stud_stat)
 Local Retval  := .F.
 Local choice
 Local stmast  := "F:\crunlib\short\stmast.dbf"
 Local stmasti := "F:\crunlib\short\cdx\stmast.cdx"
 asize(stud_stat,11)

 If !used()
  dbusearea(.T.,"DBFCDX",stmast,"stmast",.T.,.F.)
  dbsetindex(stmasti)
  set order to tag tidno
  sm1p->(dbgotop())
 Endif
 
set order to tag tidno
stmast->(dbgotop())

if ! len(alltrim(studno))==8
   lmsgbox({"Info!","Please check ID # "},{"Ok"})
   Retval := .F.
else
   Do Case
      Case stmast->(dbseek(trim(studno)))  == .F.  .OR. Empty(Trim(studno))
           Retval := .F.
           Choice := Alert("Student number not found/or not registered! ",{"Retry"})
           If Choice == 1
              studno := space(08)
           Endif

      Case stmast->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(stmast->stud_num)
           stud_stat[02] :=  trim(stmast->stud_last)
           stud_stat[03] :=  trim(stmast->stud_first)
           stud_stat[04] :=  trim(stmast->stud_mid)+'.'
           stud_stat[05] :=  "ST" // Short Term Code
           stud_stat[06] :=  ""   // Suppose to be Major but Short Term dont Have
           stud_stat[07] :=  ""   // Short Term dont have year level
           stud_stat[08] :=  ""   // Short Term dont have school year level
           stud_stat[09] :=  ""   // No Specific Term Description
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
   Endcase
endif
   
 IF Retval == .T.
   stmast->(dbclosearea())
   SETKEY(K_F4,NIL)
 Endif
Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/

// Save payment details to PAYP (Payment File SHORT TRANS )

 Function Save2TRA(vterm,payment_details)

  Local trans  := "F:\crunlib\short\tra"+vterm+".dbf"
  Local transi := "F:\crunlib\short\cdx\tra"+vterm+".cdx"

  dbusearea(.T.,"DBFCDX",trans,"trans",.T.,.F.)
  dbsetindex(transi)
  set order to tag tnum

    If !neterr()
      trans->(dbappend())
      do while !trans->(dbrlock()) .and. !neterr()
      enddo
         replace trans->stud_num   with payment_details[07]
         replace trans->trans_num  with payment_details[01]
         replace trans->trans_date with payment_details[02]
         replace trans->acc_code   with "0003"
         replace trans->trans_type with "C" //Credit
         replace trans->trans_amt  with payment_details[08]
         replace trans->teller     with payment_details[13]
      trans->(dbcommit())
      trans->(dbunlock())
    Endif

   trans->(dbclosearea())
   Return Nil
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
// Other Income Routine Start Here
Function paycod_Pre_Valid(paycode)
Local pycd        := "F:\arunlib\a999pycd.dbf"
Local pycdi       := "F:\arunlib\cdx\a999pycd.cdx"
Local dbheader := {"CODE","DESCRIPTION"}
Local dbpictur := {"@!","@!"}
Local dbfields := {1,2}

dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
dbsetindex(pycdi)

SETKEY( K_F4, {|| dbsetorder("py_desc"),gbrow(07,5,20,73,@paycode,dbheader,dbfields,dbpictur,1)})

Return .T.

/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/
Function get_paycod(paycod,paydesc)
 Local Retval := .F.
 Local choice
 Local pycd   := "F:\arunlib\a999pycd.dbf"
 Local pycdi  := "F:\arunlib\cdx\a999pycd.cdx"

 If !used()
  dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
  dbsetindex(pycdi)

  set order to tag py_code
  pycd->(dbgotop())
 Endif
 
set order to tag py_code
pycd->(dbgotop())

   Do Case

      Case pycd->(dbseek(trim(paycod)))  == .F.  .OR. Empty(Trim(paycod))
           Retval := .F.
           Choice := Alert("Payment Code Not Found !",{"Retry"})
           If Choice == 1
              paycod := space(04)
              paydesc := space(30)
           Endif

      Case pycd->(dbseek(trim(paycod)))  == .T.
           paydesc := pycd->prodesc
           Retval := .T.

   Endcase
   
 IF Retval == .T.
   pycd->(dbclosearea())
   SETKEY(K_F4,NIL)
 Endif
Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

/*---------------------------------------------------------------------------*/

 
Function is_idno_valid(studno,stud_stat)

 Local Items    := {" UCLM  "," METC  "," SHORT TERM "," ELEM/HIGH "}
 SETKEY( K_F6, {|| forceappend(studno,stud_stat)})
 SETKEY( K_F4, {|x| x:= Pop_menu(10,10,15,30,Items),if(x==1,BROWUC(studno),;
                if(x==2,BROWME(studno),if(x==3,BROWST(studno),BROWEL(studno)))) })
Return .T.
/*------Function-header-ends-Here--------------------------------------------*/



/*---------------------------------------------------------------------------*/
Function all_studno(studno,stud_stat)
 Local Retval  := .F.
 Local choice


   Do Case
      Case trim(studno) == "нннннннн"
            @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
            @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
            @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           Retval := .T.
      Case search_studno(studno,stud_stat) == .F.
           Retval := .F.
           Choice := Alert("Student number not found/or not registered! ",{"Retry"})
            If Choice == 1
               studno := space(08)
           Endif

      Case search_studno(studno,stud_stat) == .T.
           Retval := .T.
   Endcase

   
 IF Retval == .T.
   SETKEY(K_F4,NIL)
   SETKEY(K_F6,NIL)
 Endif
Return Retval
/*------Function-header-ends-Here--------------------------------------------*/

function xampm( ctime )
 if val( ctime ) < 12
    ctime := "AM "+ctime
 elseif val( ctime ) == 12
    ctime := "PM "+ctime
 else
    ctime := "PM "+str(val(ctime) - 12,2) + substr(ctime,3)
 endif
return ctime

function ampm( ctime )
 if val( ctime ) < 12
    ctime := ctime+"AM"
 elseif val( ctime ) == 12
    ctime := ctime+"PM"
 else
    ctime := str(val(ctime) - 12,2) + substr(ctime,3)+"PM"
 endif
return ctime

/*---------------------------------------------------------------------------*/
// Save payment details to PAYO (Payment Other Master File)

 Function Save2PAYO(vterm,payment_details)

  Local payo  := "F:\arunlib\a"+substr(alltrim(vterm),3,3)+"payo.dbf"
  Local payoi := "F:\arunlib\cdx\a"+substr(alltrim(vterm),3,3)+"payo.cdx"

  dbusearea(.T.,"DBFCDX",payo,"payo",.T.,.F.)
  dbsetindex(payoi)
  set order to tag refno

    If !neterr()
      payo->(dbappend())
      do while !payo->(dbrlock()) .and. !neterr()
      enddo
         replace payo->payrefno  with payment_details[01]
         replace payo->paydte    with payment_details[02]
         replace payo->payidno   with payment_details[07]
         replace payo->procode   with payment_details[06]
         replace payo->paytype   with payment_details[04]
         replace payo->paychkno  with payment_details[09]
         replace payo->paychknam with payment_details[10]
         replace payo->payentime with payment_details[03]
         replace payo->payentusr with payment_details[13]
         replace payo->payentws  with payment_details[14]
         replace payo->payamt    with payment_details[08]
         replace payo->paynamto  with payment_details[11]
         replace payo->paytelr   with payment_details[12]
      payo->(dbcommit())
      payo->(dbunlock())
    Endif

   payo->(dbclosearea())
   Return Nil

//------------------------------------------------------------------------

Function cash_Pre_Valid(cashier)
Local dbheader      := {"SHORT NAME","CASHIER"}
Local dbpictur      := {"@!","@!"}
Local dbfields      := {1,2}
Local pyus          := "F:\arunlib\a999pyus.dbf"
Local pyusi         := "F:\arunlib\cdx\a999pyus.cdx"

dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
dbsetindex(pyusi)
SETKEY( K_F4, {|| dbsetorder("short_name"),gbrow(1,5,22,74,@cashier,dbheader,dbfields,dbpictur,1)})
Return .T.
/*-------Function-header-ends-Here--------------------------------------------*/

/*----------------------------------------------------------------------------*/
// Obtain the cashier name  file
// For Cashier Program
// By Edgar J. Esguerra
// April 26, 2002

Function get_cash(y,x,lenght,cashier,csfullnam)
Local Retval := .F.
Local choice
Local pyus    := "F:\arunlib\a999pyus.dbf"
Local pyusi   := "F:\arunlib\cdx\a999pyus.cdx"

If !used()
dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
dbsetindex(pyusi)
set order to tag short_name
Endif

set order to tag short_name
 pyus->(dbgotop())


 DO CASE
    CASE pyus->(dbseek(trim(cashier))) == .F. .OR. Empty(cashier)
              Retval := .F.
              Choice :=  Alert("Cashier name not found! ",{"Retry"})
               If Choice == 1
                @ y,x say space(lenght)
                cashier   := space(10)
                csfullnam := space(30)
               Endif

     CASE pyus->(dbseek(trim(cashier))) == .T.
                 Retval := .T.
                 @ y,x say pyus->chfullnam
                 csfullnam := pyus->chfullnam
ENDCASE

 IF Retval == .T.
   pyus->(dbclosearea())
   SETKEY(K_F4,NIL)
 ENDIF
Return Retval
/*-------Function-header-ends-Here--------------------------------------------*/


