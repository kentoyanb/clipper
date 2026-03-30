// Payment Routine For " Other Income "
// For Cashier Program
// By. Edgar J. Esguerra
// Sept 17, 2002

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
# include "Getexit.ch"



 Function ch03e(Cashier_name)

//Save old settings

   Local oldscreen := savescreen(0,0,maxrow(),maxcol())
   Local oldcolor  := setcolor()
   Local oldcursor := setcursor()
//-----------------------------------------------------------------------------

//Local variables
   Local sch_term  := space(05)
   Local term_desc := space(40)
   Local pay_idno  := space(08)
   Local pay_date  := date() // ctod('  /  /  ')
   Local pay_type
   Local pay_chko  := space(20)
   Local pay_chkn  := space(20)
   Local pay_reci  := 0
   Local pay_amnt  := 0
   Local pay_code  := space(04)
   Local choice
   Local want
   Local counter := 0
//-----------------------------------------------------------------------------

//Array variables

Local getlist         := {}  // getlist Array
Local term_stat       := {}  // Term Array
Local stud_stat       := {}  // Student Info Array
Local refno           := {}  // Refno Array
Local payment_details := {}  // Payment Information stat
Local pay_desc        := space(30)

//Set  environment settings
 SET( _SET_DECIMALS, 2)
 SET( _SET_CURSOR, SC_SPECIAL1)
 SET( _SET_DATEFORMAT, "MM-DD-YYYY")
 SET( _SET_ESCAPE, .T. )
 SET( _SET_CONFIRM, .T.)
 SET( _SET_COLOR ,"W+/B,W+/RB,,,GR+/B")
 //----------------------------------------------------------------------------


 //Initialized default working variables

//   if seconds() >= 57600.00
//      pay_date := date()+1
//   else
      pay_date := date()
//   endif

   pay_type := '1'

Do While .t.

    asize(stud_stat,11)
    ScrE()

 @ 06,08 get sch_term picture "99999" when term_pre_valid(@sch_term)   == .T. valid get_term(06,31,40,@sch_term,@term_desc,term_stat) == .T.
 @ 08,08 get pay_date picture "@!"    valid !empty(pay_date)
 @ 08,24 get pay_code picture "@!"    when paycod_pre_valid(@pay_code) == .T. valid get_paycod(@pay_code,@pay_desc) == .T.
 @ 10,27 get pay_type picture "@!"    valid pay_type $ "0 1"
 @ 08,45 get pay_chko picture "@!"    when pay_type == "0" valid !empty(pay_chko)
 @ 10,45 get pay_chkn picture "@!"    when pay_type == "0" valid !empty(pay_chkn)
 @ 12,19 get pay_idno picture "@!"    when is_idno_valid(@pay_idno,stud_stat) == .T. valid all_studno(@pay_idno,stud_stat)
 @ 14,58 get pay_reci picture "9,999,999.99" valid !empty(pay_reci)
 @ 15,58 get pay_amnt picture "9,999,999.99" valid !empty(pay_amnt)
 Read


    If Lastkey() == K_ESC
         Post_Valid_Dbf()
         Choice :=  Alert("Are you sure you want to exit?",{"Exit","Cancel"})
          If Choice == 1
             Choice := ""
             Exit
          Else
             Choice := ""
             loop
          Endif
    Endif


   @ 16,58 say Transform(pay_reci - pay_amnt,"9,999,999.99") Color ("GR+/B")
   @ 20,48 say pay_desc
        want := Alert("Save & print official receipt?",{"Save","Cancel"})

        If want == 1


      // Get O.R. No and Display it
         Asize(refno,3)
         refno := Gen_payrefno(Cashier_name)
         @ 18,58 say refno[1]
         @ 20,40 say refno[2]

         Asize(payment_details,21)

        //Assign Value to Payment Details

          payment_details[01] := refno[1]
          payment_details[02] := pay_date
          payment_details[03] := Val(strtran(time(),':','',1,len(time())))
          payment_details[04] := pay_type
          payment_details[05] := "OTHER"
          payment_details[06] := pay_code
          payment_details[07] := pay_idno
          payment_details[08] := pay_amnt
          payment_details[09] := pay_chkn
          payment_details[10] := pay_chko
          payment_details[11] := trim(stud_stat[02])+' '+trim(stud_stat[03])+' '+trim(stud_stat[04])
          payment_details[12] := refno[3]
          payment_details[13] := refno[2]
          payment_details[14] := netname()
          payment_details[15] := 'A'+substr(sch_term,3,3)+'PAYO'
          payment_details[16] := stud_stat[5]
          payment_details[17] := stud_stat[6]
          payment_details[18] := stud_stat[7]
          payment_details[19] := get_pcd(pay_code)
          payment_details[20] := 0
          payment_details[21] := memvar->cSN


       // Save to File
        // upgrading courses
        if ((pay_code == "0387") .or. (pay_code == "0388") .or. ;
            (pay_code == "0389") .or. (pay_code == "0390") .or. ;
            (pay_code == "0391"))
                payment_details[05] := "UCLM"
                payment_details[15] := 'A'+substr(sch_term,3,3)+'PAYP'
                SAVE2PAYM(sch_term,payment_details)
                SAVE2PAYP(sch_term,payment_details)
        else
                SAVE2PAYM(sch_term,payment_details)
                SAVE2PAYO(sch_term,payment_details)
        endif
        PRINTOR  (sch_term,payment_details)

     Endif


   // Flush the array variable and other variables
      Asize(term_stat,0)        // Array of Term Status
      Asize(stud_stat,0)        // Array of Student Status
      Asize(refno,0)            // Array of Refno Status
      Asize(payment_details,0)  // Array of Payment Information

        term_desc := space(40)
        pay_idno  := space(08)
        pay_type  := '1'

//        if seconds() >= 57600.00
//           pay_date  := date()+1
//           else
           pay_date := date()
//        endif

        pay_chko  := space(20)
        pay_chkn  := space(20)
        pay_reci  := 0
        pay_amnt  := 0
        pay_code  := space(04)
        pay_desc  := space(30)
        choice    := ""
        want      := ""
 Enddo

 // Destroy all variables
      Asize(term_stat,0)        // Array of Term Status
      Asize(stud_stat,0)        // Array of Student Status
      Asize(refno,0)            // Array of Refno Status
      Asize(payment_details,0)  // Array of Payment Information

        term_desc := space(40)
        pay_idno  := space(08)
        pay_type  := ''
        pay_date  := space(08)
        pay_chko  := space(20)
        pay_chkn  := space(20)
        pay_reci  := 0
        pay_amnt  := 0
        pay_code  := space(04)
        pay_desc  := space(30)
        choice    := ""
        want      := ""


// Restore the old settings
restscreen(0,0,maxrow(),maxcol(),oldscreen)
SETCURSOR(oldcursor)
SETCOLOR(oldcolor)
Return Nil

//----------------------------------------------------------------------------

Function ScrE()
//----------------------------------------------------------------------------
         //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
@ 01,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 02,0 say '³                    University of Cebu in Lapulapu and Mandaue                ³'
@ 03,0 say '³                       A.C Cortes Avenue, Mandaue City 6014                   ³'
@ 04,0 say '³                    PAYMENT ENTRIES MISCELLANOUS AND OTHER INCOME             ³'
@ 05,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 06,0 say '³ Term:                      ³                                                 ³'
@ 07,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 08,0 say '³ Date:            Code:     ³  Check Name :                                   ³'
@ 09,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 10,0 say '³ Pay.Type 1-Cash 0-Check:   ³  Check No.  :                                   ³'
@ 11,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 12,0 say '³ Student Number :                   ³       Payment Entries                   ³'
@ 13,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 14,0 say '³ Name :                             ³  Amount Recieved :                      ³'
@ 15,0 say '³                                    ³  Payment Amount  :                      ³'
@ 16,0 say '³                                    ³  Change          :                      ³'
@ 17,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 18,0 say '³ Course:            Major:          ³  O.R. NO.        :                      ³'
@ 19,0 say '³ Year:                              ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 20,0 say '³ Last Term Attended:                ³ Purpose:                                ³'
@ 21,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 22,0 say '³ ESC - Exit  F4 - Prompt            ³                                         ³'
@ 23,0 say '³ F6  - Inclusion Entry              ³                                         ³'
@ 24,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Return Nil




