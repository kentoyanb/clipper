// General informative reports of collection with department breakdown
# include "ERROR.CH"
# include "TBROWSE.CH"
# include "INKEY.CH"
# include "SETCURS.CH"
# include "ord.ch"
# DEFINE  DEF_HSEP   "ÂÄ"
# DEFINE  DEF_CSEP   "³"
# DEFINE  DEF_FSEP   "ÁÄ"
# DEFINE  COL_COLOR "+W/B, +W/B, W+/BG, W+/BG, W+/G, 15/12, 15/12, N/W, N/W, W+/RB"
# DEFINE  TB_REFRESH_RATE 1


Function chrep03()

 // Save old settings
 Local oldscreen := savescreen(0,0,maxrow(),maxcol())
 Local oldcolor  := setcolor()
 Local oldcursor := setcursor()
 Local sch_term  := space(05)
 Local term_stat := {}
 Local getlist   := {}
 Local from_d    := ctod('  /  /  ')
 Local to_d      := ctod('  /  /  ')
 Local fname     := space(07)
 Local term_desc := space(40)
 Local choice    := space(01)
 Local key


// Set environment settings
SET( _SET_CURSOR, SC_SPECIAL1)
SET( _SET_DATEFORMAT, "MM-DD-YYYY")
SET( _SET_ESCAPE, .T. )
SET( _SET_CONFIRM, .T.)
SET( _SET_COLOR ,"W+/B,W+/RB,,,GR+/B")
savescreen(0,0,maxrow(),maxcol())

 Do while .T.

  REP02SCR()

  fname  := ideal_file()
  from_d := date()
  to_d   := date()


  @ 06,08 get sch_term   picture "99999" when term_pre_valid(@sch_term)   == .T. valid get_term(06,31,40,@sch_term,@term_desc,term_stat) == .T.
  @ 07,08 get from_d     picture "@D"
  @ 08,08 get to_d       picture "@D"
  @ 09,08 get fname      picture "@!"   valid !empty(fname) .and. check_file(fname) == .T.
  read

     If Lastkey() == K_ESC
        Post_Valid_Dbf()
        Choice :=  Alert("Are you sure you want to exit?",{"Exit","Cancel"})
        If Choice == 1
            Exit
         Else
            loop
          Endif
    Endif


     Gather_Report(from_d,to_d, sch_term,fname,term_desc)

   // Flush the array variable and other variables
      Asize(term_stat,0)        // Array of Term Status
      term_desc := space(40)
      fname     := space(07)
      from_d    := ctod('  /  /  ')
      to_d      := ctod('  /  /  ')
 Enddo

setcolor(oldcolor)
setcursor(oldcursor)
restscreen(0,0,maxrow(),maxcol(),oldscreen)
Return Nil

//----------------------------------------------------------------------------

      


Function REP02SCR()
//----------------------------------------------------------------------------
         //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
@ 01,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 02,0 say '³                    University of Cebu in Lapulapu and Mandaue                ³'
@ 03,0 say '³                       A.C Cortes Avenue, Mandaue City 6014                   ³'
@ 04,0 say '³                          GENERAL SUMMARY OF COLLECTION                       ³'
@ 05,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 06,0 say '³ Term:                                                                        ³'
@ 07,0 say '³ From:                                                                        ³'
@ 08,0 say '³ To  :                                                                        ³'
@ 09,0 say '³ Name:                                                                        ³'
@ 10,0 say '³                                                                              ³'
@ 11,0 say '³                                                                              ³'
@ 12,0 say '³                                                                              ³'
@ 13,0 say '³                                                                              ³'
@ 14,0 say '³                                                                              ³'
@ 15,0 say '³                                                                              ³'
@ 16,0 say '³                                                                              ³'
@ 17,0 say '³                                                                              ³'
@ 18,0 say '³                                                                              ³'
@ 19,0 say '³                                                                              ³'
@ 20,0 say '³                                                                              ³'
@ 21,0 say '³                                                                              ³'
@ 22,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 23,0 say '³ ESC-EXIT                                                                     ³'
@ 24,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Return Nil

Function Gather_Report(from_d, to_d, vterm,fname,term_desc)
 Local paym    := "f:\arunlib\a"+substr(vterm,3,3)+"paym.dbf"
 Local paymi   := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"paym.cdx"
 Local newdbf
 Local newcdx
 Local newstr
 Local Line         := 9
 Local page         := 1
 Local lin_total    := 0  // total created lines
 Local rec_total    := 0  // total record counted per course
 local cou_total    := 0  // total collection for year level
 local acc_total    := 0  // total account level collection
 local gra_total    := 0  // overall grand total
 Local oldcourse
 Local oldmajor
 Local oldyear
 Local oldrecno
 Local oldprocode   := "XXXX"
 Local l_output
 Local f_str
 Local items       := {" Printer "," Screen "}
 Local choice


 l_output := pop_menu(11,20,14,35,items)



 dbusearea(.T.,"DBFCDX",paym,"paym",.T.,.F.)
 paym->(ordlistadd(paymi))
 ordsetfocus("Sdate")
 set scope to transform(from_d,"99-99-9999"),transform(to_d,"99-99-9999")

 // Create and copy to a new file
    Copy Structure to "F:\arunlib\temp\"+fname+".dbf"
    Copy to "F:\arunlib\temp\"+fname+".dbf"
    set scope to
    paym->(ordlistclear())
    paym->(dbclosearea())

//  Use now the new created file
    newdbf := "F:\arunlib\temp\"+fname+".dbf"
    newcdx := "F:\arunlib\temp\"+fname+".cdx"
    newstr := "F:\arunlib\temp\"+fname+".txt"

   dbusearea(.T.,"DBFCDX",newdbf,"newdbf",.T.,.F.)
   detcourse()
// Create new index file
    Index on newdbf->procode+newdbf->sm1colcod+newdbf->sm1majcod+newdbf->sm1yrlvl tag tlist to &newcdx;
    Eval(GaugeDisp(newcdx,"tlist")) Every 50  USECURRENT
    newdbf->(dbclosearea())

 // Use as refresh
   dbusearea(.T.,"DBFCDX",newdbf,"newdbf",.T.,.F.)
   newdbf->(ordlistadd(newcdx))
   ordsetfocus("tlist")
   newdbf->(dbgotop())

    Set Device to printer
    If l_output == 2
     Set print to &newstr
    Endif

    Set Printer On
    PrintStyle("line",2)
    PrintStyle("line",2)



//          IF !isprinter()
//                inkey(1)
//                Choice := Alert("Printer not ready or offline please check and try again!",{"Retry","Cancel"})
//                If Choice == 2
//                   Exit
//                Else
//                  loop
//                Endif
//           Endif

   header(from_d,to_d,page,term_desc)


   Do While !newdbf->(eof())

             IF ((oldprocode != newdbf->procode) .and. (newdbf->(!eof())))
                    oldrecno := recno()
                    @ Line,1 say " Account Category : "+newdbf->procode+ ' '+Get_Acctg(newdbf->procode)
                      if need_eject(from_d,to_d,@line,@page,term_desc) == .F.
                        Line++
                      Endif

                      dbselectarea("newdbf")
                      newdbf->(ordlistadd(newcdx))
                      ordsetfocus("tlist")
                      newdbf->(dbgoto(oldrecno))
     
                      oldprocode := newdbf->procode
             Endif

  DO WHILE ((oldprocode == newdbf->procode) .and. (!newdbf->(eof()) ) )

          oldcourse := alltrim(newdbf->sm1colcod)
          oldmajor  := alltrim(newdbf->sm1majcod)
          oldyear   := alltrim(newdbf->sm1yrlvl)

    Do While oldcourse == alltrim(newdbf->sm1colcod) .and. oldmajor == alltrim(newdbf->sm1majcod) .and. oldyear == alltrim(newdbf->sm1yrlvl) .and. !newdbf->(eof())

              If oldprocode == newdbf->procode
                 rec_total++
                 cou_total += newdbf->payamt
                 newdbf->(dbskip())
               Else
                 Exit
              Endif
      Enddo
            // Summary per course and year level
               lin_total++
                 @ Line,01 say Transform(lin_total,"9999")+'.'
             IF !empty(oldcourse) .or. !empty(oldmajor)
                   oldrecno := recno()
                 @ Line,09 say  cr_get(oldcourse+oldmajor)
                 @ Line,19 say  oldyear
                   dbselectarea("newdbf")
                   newdbf->(ordlistadd(newcdx))
                   ordsetfocus("tlist")
                   newdbf->(dbgoto(oldrecno))
              ELSE
               @ Line,09 say "NEW"
               @ Line,19 say "*"
             ENDIF
                 @ Line,21 say "..............."
                 @ Line,40 say  transform(rec_total,"9999.")
                 @ Line,50 say  transform(cou_total,"999,999,999.99")

                 if need_eject(from_d,to_d,@line,@Page,term_desc) == .F.
                   Line++
                 Endif

                   acc_total += cou_total
                   gra_total += cou_total
                   cou_total := 0
                   rec_total := 0
                   oldcourse := ""
                   oldmajor  := ""
                   oldyear   := ""

              if newdbf->procode != oldprocode
               //Display total account total
                 @ Line,51 say "------------------------"
                   if need_eject(from_d,to_d,@line,@page,term_desc) == .F.
                      line++
                   Endif

                 @ line,50 say transform(acc_total,"999,999,999.99")
                  if need_eject(from_d,to_d,@line,@page,term_desc) == .F.
                    Line++
                    Line++
                   Endif
                   acc_total  := 0
                   lin_total  := 0
                   oldprocode := ""
                   exit
              Endif
   Enddo
 Enddo

          
          //   display grand total
                  @ line,1 say"---------------------------------------------------------------------------"
                  if need_eject(from_d,to_d,@line,@page,term_desc) == .F.
                    line++
                  Endif
                  @ line,51 say "========================"
                  if need_eject(from_d,to_d,@line,@page,term_desc) == .F.
                    Line++
                  Endif
                  @ line,30 say "GRAND TOTAL: "
                  @ line,50 say transform(gra_total,"999,999,999.99")

  setprc(0,0)
  PrintStyle("line",66)
  Set Device To Screen
  If l_output == 2
   Set print to
  Endif
   Set Printer Off

 
 If l_output == 2
  f_str := memoread(newstr)
  memoedit(f_str,6,2,21,78,.F.,,86)
Endif

// Close and destroy created file
 newdbf->(dbclosearea())
If l_output == 2
  FERASE(newstr)
Endif
  FERASE(newdbf)
  FERASE(newcdx)

Return Nil


Function Get_acctg(paycode)
 Local Retval := space(10)
 Local pycd   := "f:\arunlib\a999pycd.dbf"
 Local pycdi  := "f:\arunlib\cdx\a999pycd.cdx"

 dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
 dbsetindex(pycdi)
 set order to tag py_code
    pycd->(dbgotop())


      If pycd->(dbseek(upper(paycode))) == .T.
         Retval := pycd->prodesc
      Endif

dbclosearea("pycd")

Return Retval


Function cr_get(coursemaj)
Local Retval := space(08)

Local colp   := "f:\crunlib\c999colp.dbf"
Local colpi  := "f:\crunlib\cdx\c999colp.cdx"

 dbusearea(.T.,"DBFCDX",colp,"colp",.T.,.F.)
 dbsetindex(colpi)
 set order to tag colcod
    colp->(dbgotop())

      If colp->(dbseek(coursemaj)) == .T.
         Retval := padr(colp->coldesabr,6," ")+' '+colp->colmajcod
      Endif

dbclosearea("colp")
Return Retval


 Function Header(from_d,to_d,page,term_desc)
  Local Header1 := "University of Cebu Lapulapu & Mandaue "
  Local Header2 := "A.C. Cortes Avenue Mandaue City"
  Local Header3 := "Summary of Collection Distributed by Account "
  Local Header4 := term_desc
  Local Header5 := "For the period of: "+Transform(from_d,"99-99-9999")+" TO "+Transform(to_d,"99-99-9999")+"        Page : "+Transform(Page,"999.")
  setprc(0,0)
  @ 1, 40-len(Header1)/2 say Header1
  @ 2, 40-len(Header2)/2 say Header2
  @ 3, 40-len(Header3)/2 say Header3
  @ 4, 40-len(header4)/2 say Header4
  @ 5, 01 say Header5
  @ 6, 01 say replicate("-",70)
  @ 7, 01 say"Seq.   Crs/Maj   Yr.                   Occurance   Total Per Level"
  @ 8, 01 say replicate("-",70)
 Return Nil


 Function detcourse()
     Local stud_details  := {}
     Local oldrecno
     Local course
     Local major
     Local yr
     Local oldscreen

     oldscreen := savescreen(05,05,15,50)
     @ 05,05 clear to 15,50
     @ 5,05 to 15,50 double
     @ 7,07 say "Checking student course & yr. level update."
     @ 8,07 say "This may take a few minutes"
     @ 9,07 say "Please wait!"


     newdbf->(dbgotop())

     Do While !newdbf->(eof())
       @ 11,07 say "Processing Id No. "+newdbf->sm1idno

       asize(stud_details,11)
       oldrecno := recno()
       xsearch_studno(newdbf->sm1idno,stud_details)
         course := if(Valtype(stud_details[5]) != "U",stud_details[5]," ")
         major  := if(Valtype(stud_details[6]) != "U",stud_details[6]," ")
         yr     := if(Valtype(stud_details[7]) != "U",stud_details[7]," ")

       dbselectarea("newdbf")
       newdbf->(dbgoto(oldrecno))


      do while !newdbf->(dbrlock()) .and. !neterr()
      enddo
       newdbf->sm1colcod := course
       newdbf->sm1majcod := major
       newdbf->sm1yrlvl  := yr
       newdbf->(dbcommit())
       newdbf->(dbunlock())

       oldrecno := 0
       asize(stud_details,0)
      newdbf->(dbskip())
  Enddo

  restscreen(05,05,15,50,oldscreen)

 Return Nil


 Function need_eject(from_d,to_d,Line,page,term_desc)
  Local retval := .F.

     If Line > 54
        Line++
      @ Line,1 say"Countinuing next page ... "
        Line++
        Page++
      @ Line,1 say replicate("-",70)
        eject
        Header(from_d,to_d,page,term_desc)
      Line = 9
        Retval := .t.
    Endif


 Return Retval



                             
