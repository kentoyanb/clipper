// Generate Pay Referrence Number (Payrefno) (Gen_refno function)
// For Cashier Program
// By Edgar J. Esguerra
// Feb 19, 2002

// Payment Routine
// For Cashier Program
// By. Edgar J. Esguerra
// March 07, 2002



# include "INKEY.CH"
# include "GRUMP.CH"
# include "GRUMPR.CH"
# include "GRUMPH.CH"
# include "GRUMPM.CH"
# include "SHADOWB.CH"
# include "DBINFO.CH"
# include "BOX.CH"
# include "SETCURS.CH"
# include "ac_ch.ch"
# include "dbstruct.ch"

Function ch03()
Static sch_term
Local arefno  := {}
Local getlist := {}

Local oldscreen := savescreen(0,0,maxrow(),maxcol())
Local oldcolor  := setcolor()
Local Counter
Local oldcursor := setcursor()
Local pay_idno  := space(08)
Local pay_name  := space(50)
Local pay_cour  := space(03)
Local pay_refn  := space(08)
Local pay_date  := ctod('  /  /  ')
Local pay_type  := "1"
Local pay_chko  := space(20)
Local pay_chkn  := space(20)
Local pay_code  := space(04)
Local pay_amtn  := 0
Local choice
Local term_stat := {} // Array of Term Status


Local term_desc := space(40)
Local pay_clas  := space(01)
Local oget
default sch_term to space(05)

 SET( _SET_DECIMALS, 2)
 SET( _SET_CURSOR, SC_SPECIAL1)
 SET( _SET_DATEFORMAT, "MM-DD-YYYY")
 SET( _SET_ESCAPE, .T. )
setcolor("W+/B,W+/RB,,,GR+/B")
@ 01,01 say PADC("SUMMARY OF STUDENTS BY ZIP AREA ",78," ")
For Counter := 02 to 23
@ Counter,01 say PAD(" ",78," ")
Next
 @ 02,02 say "PAYMENT DETAILS-------------------------------------------------------------"
 @ 03,02 say "SCHOOL TERM    :                                                            "
 @ 04,02 say "ZIP AREA       :                                                            "
 @ 05,02 say "PAYMENT TYPE   :     1 - Cash  0 - Check                                    "
 @ 06,02 say "PAYMENT CODE   :     -                                Type -                "
 @ 07,02 say "CHECK NUMBER   :                      Check name  :                         "
 @ 08,02 say "TENDER AMOUNT  :                                                            "
 @ 09,02 say "O.R. NUMBER    :                                                            "
 @ 10,02 say "--------------------------------------------------------------------------  "
 @ 11,02 say "CREDIT TO (STUDENT ACCOUNT / PAYOR)                                         "
 @ 12,02 say "ID.NO.         :                                                            "
 @ 13,02 say "NAME           :                                                            "
 @ 14,02 say "COURSE /YEAR   :                                                            "
 @ 15,02 say "LAST TERM ATTD.:                                                            "
 @ 16,02 say "--------------------------------------------------------------------------- "
 @ 23,01 say PADR(" ESC - Previous    F4-prompt ",78," ") Color("N/W+")


 Do While .t.

 @ 03,18 get sch_term picture "99999" valid get_term(03,25,40,@sch_term,@term_desc,term_stat)
 @ 04,18 get pay_date picture "@!"    valid !empty(pay_date)
 @ 05,18 get pay_type picture "@!"    valid pay_type $ "0 1"
 @ 06,18 get pay_code picture "@!"    valid get_payc(@pay_code,@pay_clas,payc_stat) == .T.
 @ 07,18 get pay_chko picture "@!"    when pay_type == "0" valid !empty(pay_chko)
 @ 07,53 get pay_chkn picture "@!"    when pay_type == "0" valid !empty(pay_chkn)
 @ 08,18 get pay_amtn picture "9,999,999.99" valid !empty(pay_amtn)
 @ 12,18 get pay_idno picture "@!"    when pay_clas == "A" .OR. pay_clas == "N" valid get_studno(@pay_idno,stud_stat) == .T.
 @ 13,18 get pay_name picture "@!"    when pay_clas == "O"
 Read

     IF   Lastkey() == K_ESC
          oldcursor := setcursor()
          set(_SET_CURSOR ,SC_NONE)
          choice :=  Alert("Sure to exit the payment entry?",{"Yes","No"})
            If Choice == 1
               Exit
             Endif
          setcursor(oldcursor)

     Endif



     IF  pay_clas == "A" .or. pay_clas == "N"

      // Display Student Details if account related to student

          @ 13,18 say stud_stat[02]+' '+stud_stat[03]+' '+stud_stat[04]
          @ 14,18 say stud_stat[05]+stud_stat[06]+' '+stud_stat[07]+'.'+' - '+substr(stud_stat[10],1,48)
          @ 15,18 say stud_stat[08]+' -  '+stud_stat[09]
     Endif


      // Get O.R. No and Display it
          Asize(refno,2)

          refno := Gen_payrefno(Cashier_name)
          @ 09,18 say refno[1]
        //@ 09,30 say refno[2]

        Asize(payi_stat,12)
          payi_stat[01] := sch_term     // TERM
          payi_stat[02] := pay_clas     // payclass  A- Account N - Non Student Account O - Other
          payi_stat[03] := refno[1]     // payrefno
          payi_stat[04] := pay_date     // paydate
          payi_stat[05] := pay_idno     // payidno
          payi_stat[06] := pay_type     // Paytype  C - Cash A - Check
          payi_stat[07] := pay_amtn     // Payamnt
          payi_stat[08] := Cashier_name // User
          payi_stat[09] := pay_chko     // Check Number
          payi_stat[10] := pay_chkn     // Check Name
          payi_stat[11] := pay_name     // paynamto
          payi_stat[12] := pay_code     // payment Code


      Save_payment(payi_stat)

      Print_or(trim(pay_clas),trim(payi_stat[03]),trim(payi_stat[01]))

   // Flush the array variable and other variables
     pay_idno  := space(08)
     pay_name  := space(50)
     pay_cour  := space(03)
     pay_refn  := space(08)
     pay_chko  := space(20)
     pay_chkn  := space(20)
     pay_amtn  := 0
     pay_code  := space(04)

   Asize(term_stat,0)  // Array of Term Status
   Asize(payc_stat,0)  // Array of Payment code status
   Asize(stud_stat,0)  // Array of Student Status
   Asize(refno,0)      // Array of Refno Status
   Asize(payi_stat,0)  // Array of Payment Information


   //Clear the get area
   @ 06,18 say space(04)  //Clear payment code
   @ 06,25 say space(30)  //Clear payment code field
   @ 06,65 say space(11)  //Clear the payment type description
   @ 07,18 say space(20)  //Clear Check number
   @ 07,53 say space(20)  //Clear Check Name
   @ 08,18 say space(20)  //Clear Amount
   @ 09,18 say space(20)  //Clear O.R.
   @ 12,18 say space(20)  //Clear ID.NO.
   @ 13,18 say space(20)  //Clear Name
   @ 14,18 say space(57)  //Course/yr
   @ 15,18 say space(45)  //Last Term Attended

 Enddo



// Restore the old settings
restscreen(0,0,maxrow(),maxcol(),oldscreen)
setcursor(oldcursor)
setcolor(oldcolor)
Return Nil


//----------------------------------------------------------------------------

Function Gen_payrefno(Cashier_Name)

Local Retval := {}
Local Month_Char := {'A','B','C','D','E','F','G','H','I','J','K','L'}
Local Oldmonth   := space(01)
Local Olddate    := 0
Local Literal    := space(01)
Local Counter    := 0
Local pyus       := "F:\arunlib\a999pyus.dbf"
Local pyusi      := "F:\arunlib\cdx\a999pyus.cdx"

 Asize(Retval,2)
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

      Case pyus->(dbseek(Cashier_Name)) == .T.

    // Get The Present Value to DBF
       oldmonth := Substr(pyus->payrefno,1,1)
       olddate  := Val(Substr(pyus->payrefno,2,2))
    

    // Check If Changes in date and Month Occurs

       If oldmonth <> Month_Char[month(date())]
          oldmonth := Month_Char[Month(date())]
        Else
          Oldmonth := Oldmonth
       Endif

       If olddate  <> day(date())
          olddate  := day(date())
          olddate  := PADL(alltrim(str(olddate)),2,"0")
          Counter  := pyus->paycount
          Counter  := 0
        Else
          olddate  := olddate
          olddate  := PADL(alltrim(str(olddate)),2,"0")
          Counter  := pyus->paycount
       Endif


      Counter++
      Literal  := pyus->literal_cn
      Counter  := PADL(alltrim(STR(Counter)),4,"0")


      Retval[1] := oldmonth+olddate+literal+counter
      Retval[2] := pyus->chfullnam

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


/*----------------------------------------------------------------------------*/

Function get_term(y,x,lenght,vterm,term_desc,term_stat)
Local retval  := .F.
Local term    := "F:\crunlib\term.dbf"
Local termi   := "F:\crunlib\cdx\term.cdx"
Local dbheader      := {"TERM","SEMESTER DESCRIPTION","STATUS"}
Local dbpictur      := {"@!","@!","@!"}
Local dbfields      := {1,2,3}

asize(term_stat,3)
 dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
 dbsetindex(termi)
 set order to tag tterm
 term->(dbgotop())
 

Do While .T.
DO CASE
   CASE LASTKEY() == K_ESC
                 Retval := .F.
                 @ y,x say space(lenght)
                 term_stat[1] := NIL
                 term_stat[2] := NIL
                 term_stat[3] := NIL
                 Exit
   CASE EMPTY(vterm)
               gbrow(1,5,22,74,@vterm,dbheader,dbfields,dbpictur,1)
               loop
   CASE term->(dbseek(trim(vterm))) == .F.
                Alert("Semester code does not exist! ",{"Retry"})
                @ y,x say space(lenght)
                vterm := space(05)
                loop
   CASE term->(dbseek(trim(vterm))) == .T.
        DO CASE
           CASE term->termstatus == "C"
                 Alert("Semestral term already closed!",{"Cancel"})
                 @ y,x say space(lenght)
                 vterm := space(05)
                 Loop
           CASE term->termstatus == " "
                 term_stat[1] := term->termcode
                 term_stat[2] := term->termdesc
                 term_stat[3] := term->termstatus
                 term_desc    := term->termdesc
                 @ y,x say term_desc
                 Retval := .T.
                 Exit
        ENDCASE
ENDCASE
Enddo
term->(dbclosearea())
Return Retval



//----------------------------------------------------------------------------
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

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
Function get_studno(studno,stud_stat)
 Local Retval := .F.
 Local sm1p        := "F:\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\crunlib\cdx\c999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Course","Mjr","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","X","9."}
 Local stud_fields := {1,2,3,4,5,8,9,10}

 asize(stud_stat,10)

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 set order to tag sm1idno
 sm1p->(dbgotop())

 do while .t.
   Do Case
      Case Lastkey() == K_ESC
           stud_stat[01] := nil
           stud_stat[02] := nil
           stud_stat[03] := nil
           stud_stat[04] := nil
           stud_stat[05] := nil
           stud_stat[06] := nil
           stud_stat[07] := nil
           stud_stat[08] := nil
           stud_stat[09] := nil
           stud_stat[10] := nil
           Retval := .F.
           exit
      Case Empty(trim(studno))
           set order to tag last_nam
           gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)
           set order to tag sm1idno
           loop
      Case sm1p->(dbseek(trim(studno)))  == .F.
           Alert("Student number not found!",{"Retry"})
           loop
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
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           Retval := .T.
           exit
   Endcase
 Enddo
 sm1p->(dbclosearea())
Return Retval

//---------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------
 Function get_cour_desc(cour_maj)
 Local cour_desc   := space(60)
 Local colp        := "F:\crunlib\c999colp.dbf"
 Local colpi       := "F:\crunlib\cdx\c999colp.cdx"

 dbusearea(.T.,"DBFCDX",colp,"colp",.T.,.F.)
 dbsetindex(colpi)
 set order to tag colcod
 colp->(dbgotop())

  If colp->(dbseek(alltrim(cour_maj))) == .T.
      cour_desc := trim(colp->course)
  else
      cour_desc := ""
  Endif

colp->(dbclosearea())
Return cour_desc

//-----------------------------------------------------------------------------



//------------------------------------------------------------------------------
 Function Save_Payment(payi_stat)

 Local  payp  := "F:\arunlib\a"+substr(alltrim(payi_stat[01]),3,3)+"payp.dbf"
 Local  payi  := "F:\arunlib\cdx\a"+substr(alltrim(payi_stat[01]),3,3)+"payp.cdx"
 Local  payo  := "F:\arunlib\a"+substr(alltrim(payi_stat[01]),3,3)+"payo.dbf"
 Local  payoi := "F:\arunlib\cdx\a"+substr(alltrim(payi_stat[01]),3,3)+"payo.cdx"

   DO CASE

      CASE  Alltrim(payi_stat[02]) == "A"   // Student Account
            dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
            dbsetindex(payi)
            set order to tag trefno

            If !neterr()
                payp->(dbappend())
                do while !payp->(dbrlock()) .and. !neterr()
                enddo
                 replace payp->payrefno  with payi_stat[03]
                 replace payp->paydte    with payi_stat[04]
                 replace payp->payidno   with payi_stat[05]
                 replace payp->paytyp    with payi_stat[06]
                 replace payp->paytelr   with substr(payi_stat[03],4,1)
                 replace payp->payamt    with payi_stat[07]
                 replace payp->payentdte with payi_stat[04]
                 replace payp->payenttme with Val(strtran(time(),':','',1,len(time())))
                 replace payp->payentusr with payi_stat[08]
                 replace payp->paytag    with "P"
                 replace payp->payposted with .F.
                 replace payp->paychkno  with payi_stat[09]
                 replace payp->paychknam with payi_stat[10]
                 replace payp->paycode   with payi_stat[12]
                payp->(dbcommit())
                payp->(dbunlock())
           Endif

           
            payp->(dbclosearea())

      CASE ( (Alltrim(payi_stat[02]) == "N") .OR.  (Alltrim(payi_stat[02]) == "O" ) )

            dbusearea(.T.,"DBFCDX",payo,"payo",.T.,.F.)
            dbsetindex(payoi)
            set order to tag refno
             If !neterr()
                payo->(dbappend())
                do while !payo->(dbrlock()) .and. !neterr()
                enddo
                 replace payo->payrefno  with payi_stat[03]
                 replace payo->paydte    with payi_stat[04]
                 replace payo->payidno   with payi_stat[05]
                 replace payo->procode   with payi_stat[12]
                 replace payo->paytype   with payi_stat[06]
                 replace payo->paychkno  with payi_stat[09]
                 replace payo->paychknam with payi_stat[10]
                 replace payo->payentime with Val(strtran(time(),':','',1,len(time())))
                 replace payo->payentusr with payi_stat[08]
                 replace payo->payamt    with payi_stat[07]
                 replace payo->paynamto  with payi_stat[11]
                 replace payo->paytelr   with substr(payi_stat[03],4,1)
                payo->(dbcommit())
                payo->(dbunlock())
           Endif
            payo->(dbclosearea())
   ENDCASE

 // ?     payi_stat[01] // sch_term     // TERM
 // ?     payi_stat[02] // pay_clas     // payclass  A- Account N - Non Student Account O - Other
 // ?     payi_stat[03] // refno[1]     // payrefno
 // ?     payi_stat[04] // pay_date     // paydate
 // ?     payi_stat[05] // pay_idno     // payidno
 // ?     payi_stat[06] // pay_type     // Paytype  C - Cash A - Check
 // ?     payi_stat[07] // pay_amtn     // Payamnt
 // ?     payi_stat[08] // Cashier_name // User
 // ?     payi_stat[09] // paychko      // Check Number
 // ?     payi_stat[10] // paychkn      // Check Name
 // ?     payi_stat[11] // paynam       // paynamto
 // ?     payi_stat[12] // paycode      // paycode
 //       inkey(0)

 Return Nil

 //----------------------------------------------------------------------------

 Function Print_or(Account_type,or_no,vterm)

 Local  payp  := "F:\arunlib\a"+substr(vterm,3,3)+"payp.dbf"
 Local  payi  := "F:\arunlib\cdx\a"+substr(vterm,3,3)+"payp.cdx"
 Local  payo  := "F:\arunlib\a"+substr(vterm,3,3)+"payo.dbf"
 Local  payoi := "F:\arunlib\cdx\a"+substr(vterm,3,3)+"payo.cdx"

 Local term    := "F:\crunlib\term.dbf"
 Local termi   := "F:\crunlib\cdx\term.cdx"
 Local prn_dtl := {}

 dbusearea(.T.,"DBFCDX",term,"term",.T.,.F.)
 dbsetindex(termi)
 set order to tag tterm
 term->(dbgotop())

  Asize(prn_dtl,15)
  Afill(prn_dtl,"",1,len(prn_dtl))

  // 1. Or No.
  // 2. Or Date.
  // 3. Name
  // 4. Term - Term Desc
  // 5. payclass
  // 6. Course / Yr
  // 7. Id no
  // 8. Paycode / Paydesc
  // 9. Amount
  // 10. Amount in words
  // 11.Check No
  // 12. Check name
  // 13. teller name
  // 14. time printed
  // 15. cash / check
  Do Case
      Case term->(dbseek(vterm)) == .T. .and. term->termstatus == "C"
        Alert("Semestral Term Already Closed!",{"Cancel"})
        term->(dbclosearea())
      Case term->(dbseek(vterm)) == .F.
        Alert("Semestral Not Found!",{"Cancel"})
        term->(dbclosearea())
      Case term->(dbseek(vterm)) == .T. .and. term->termstatus != "C"
           prn_dtl[4] := vterm+' '+term->termdesc
           term->(dbclosearea())
  Endcase


         Do Case
            Case Account_type == "A"
             dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
             dbsetindex(payi)
             set order to tag trefno
             payp->(dbgotop())

              If payp->(dbseek(alltrim(or_no))) == .T.
                 prn_dtl[01] := payp->payrefno
                 prn_dtl[02] := payp->paydte
                // prn_dtl[03]  // Full name
                // prn_dtl[04]  // Term
                 prn_dtl[05] := "STUDENT ACCOUNT INCOME"
                // prn_dtl[06]  // Course / Yr
                 prn_dtl[07] := payp->payidno
                 prn_dtl[08] := payp->paycode
                 prn_dtl[09] := payp->payamt
                // prn_dtl[10]  // amount in words
                 prn_dtl[11] := payp->paychkno
                 prn_dtl[12] := payp->paychknam
                 prn_dtl[13] := payp->paytelr
                 prn_dtl[14] := time()
                 prn_dtl[15] := if(alltrim(payp->paytyp) == "1","CASH PAYMENT","CHECK PAYMENT")
             payp->(dbclosearea())

                 prn_dtl[03] := get_nam(alltrim(prn_dtl[07]))
                 prn_dtl[06] := get_crs(alltrim(prn_dtl[07]))
                 prn_dtl[10] := amttochar(prn_dtl[09])
                 prn_dtl[08] := get_pcd(alltrim(prn_dtl[08]))
                 prn_dtl[13] := get_tlr(substr(alltrim(prn_dtl[01]),4,1))

              Endif

            Case Account_type == "N"
              dbusearea(.T.,"DBFCDX",payo,"payo",.T.,.F.)
              dbsetindex(payoi)
              set order to tag refno
              payo->(dbgotop())

                 If payo->(dbseek(alltrim(or_no))) == .T.
                 prn_dtl[01] := payo->payrefno
                 prn_dtl[02] := payo->paydte
                // prn_dtl[03]  // Full name
                // prn_dtl[04]  // Term
                 prn_dtl[05] := "NON STUDENT ACCOUNT INCOME"
                // prn_dtl[06]  // Course / Yr
                 prn_dtl[07] := payo->payidno
                 prn_dtl[08] := payo->procode
                 prn_dtl[09] := payo->payamt
                // prn_dtl[10]  // amount in words
                 prn_dtl[11] := payo->paychkno
                 prn_dtl[12] := payo->paychknam
                 prn_dtl[13] := payo->paytelr
                 prn_dtl[14] := time()
                 prn_dtl[15] := if(alltrim(payo->paytype) == "1","CASH PAYMENT","CHECK PAYMENT")
             payo->(dbclosearea())

                 prn_dtl[03] := get_nam(alltrim(prn_dtl[07]))
                 prn_dtl[06] := get_crs(alltrim(prn_dtl[07]))
                 prn_dtl[10] := amttochar(prn_dtl[09])
                 prn_dtl[08] := get_pcd(alltrim(prn_dtl[08]))
                 prn_dtl[13] := get_tlr(substr(alltrim(prn_dtl[01]),4,1))

              Endif


            Case Account_type == "O"
              dbusearea(.T.,"DBFCDX",payo,"payo",.T.,.F.)
              dbsetindex(payoi)
              set order to tag refno
              payo->(dbgotop())
              If payo->(dbseek(alltrim(or_no))) == .T.
                 prn_dtl[01] := payo->payrefno
                 prn_dtl[02] := payo->paydte
                 prn_dtl[03] := payo->paynamto
                // prn_dtl[04]  // Term
                 prn_dtl[05] := "OTHER INCOME"
                 prn_dtl[06] := "********************"
                 prn_dtl[07] := "********"
                 prn_dtl[08] := payo->procode
                 prn_dtl[09] := payo->payamt
                // prn_dtl[10]  // amount in words
                 prn_dtl[11] := payo->paychkno
                 prn_dtl[12] := payo->paychknam
                 prn_dtl[13] := payo->paytelr
                 prn_dtl[14] := time()
                 prn_dtl[15] := if(alltrim(payo->paytype) == "1","CASH PAYMENT","CHECK PAYMENT")
               payo->(dbclosearea())
                 prn_dtl[10] := amttochar(prn_dtl[09])
                 prn_dtl[08] := get_pcd(alltrim(prn_dtl[08]))
                 prn_dtl[13] := get_tlr(substr(alltrim(prn_dtl[01]),4,1))
              Endif
         Endcase


         cls

         ? prn_dtl[1]
         ? prn_dtl[2]
         ? prn_dtl[3]
         ? prn_dtl[4]
         ? prn_dtl[5]
         ? prn_dtl[6]
         ? prn_dtl[7]
         ? prn_dtl[8]
         ? prn_dtl[9]
         ? prn_dtl[10]
         ? prn_dtl[11]
         ? prn_dtl[12]
         ? prn_dtl[13]
         ? prn_dtl[14]
         ? prn_dtl[15]
         inkey(0)
      asize(prn_dtl,0)



 Return Nil

//-----------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------

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

//-----------------------------------------------------------------------------

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

//-----------------------------------------------------------------------------

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


