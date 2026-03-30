
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


