// June 21, 2005

//Summary of collection by Cashier
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


Function chrep06()

 // Save old settings
 Local oldscreen := savescreen(0,0,maxrow(),maxcol())
 Local oldcolor  := setcolor()
 Local oldcursor := setcursor()
 Local sch_term  := space(05)
 Local term_stat := {}
 Local getlist   := {}
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

  REP06SCR()

  fname  := ideal_file()

  @ 06,08 get sch_term   picture "99999" when term_pre_valid(@sch_term)   == .T. valid get_term(06,31,40,@sch_term,@term_desc,term_stat) == .T.
  @ 07,08 get fname      picture "@!"   valid !empty(fname) .and. check_file(fname) == .T.
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


      Browse_06rep(sch_term,term_desc,fname)

   // Flush the array variable and other variables
      Asize(term_stat,0)        // Array of Term Status
      term_desc := space(40)
      fname     := space(07)
 Enddo

setcolor(oldcolor)
setcursor(oldcursor)
restscreen(0,0,maxrow(),maxcol(),oldscreen)
Return Nil

//----------------------------------------------------------------------------

 Function Browse_06rep(vterm,term_desc,fname)

 Local paym  := "f:\arunlib\a"+substr(vterm,3,3)+"paym.dbf"
 Local paymi := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"paym.cdx"
 Local newdbf
 Local newcdx
 Local oldcursor := setcursor(SC_NONE)
 Local Browse
 Local search_key      := ""
 Local B_COL           := 15
 Local Key_Counter     := 1
 Local Nrecno          := 0
 Local key             := 0
 Local Choice
 Local oldrecpos
 Local i               := 1


 REQUEST DBFCDX
 RDDSETDEFAULT("DBFCDX")
 dbusearea(.T.,"DBFCDX",paym,"paym",.T.,.F.)
 paym->(ordlistadd(paymi))
 ordsetfocus("paylist")


 Browse           := TBrowseDB(06,1,20,78)
 Browse:headsep   := DEF_HSEP
 Browse:colsep    := DEF_CSEP
 Browse:footsep   := DEF_FSEP

 Browse:AddColumn(TBColumnNew("SEQ."         ,{ || transform(paym->(ordkeyno()),"9999.")}))
 Browse:AddColumn(TBColumnNew("CODE"         ,{ || paym->procode}))
 Browse:AddColumn(TBColumnNew("REF-NO"       ,{ || paym->payrefno}))
 Browse:AddColumn(TBColumnNew("ID-NO"        ,{ || paym->sm1idno }))
 Browse:AddColumn(TBColumnNew("STUDENT-NAME" ,{ || pad(paym->paynamto,25,' ')}))
// Browse:AddColumn(TBColumnNew("CRS.   "      ,{ || xget_cr(pad(paym->sm1colcod+paym->sm1majcod,3,' ')) }))
 Browse:AddColumn(TBColumnNew("CRS.   "      ,{ || paym->sm1colcod+paym->sm1majcod }))
 Browse:AddColumn(TBColumnNew("YR"           ,{ || paym->sm1yrlvl}))
 Browse:AddColumn(TBColumnNew("AMOUNT"       ,{ || transform(paym->payamt,"999,999.99")}))
 Browse:AddColumn(TBColumnNew("TYPE"         ,{ || IF(paym->paytype == '1',"CASH ","CHECK")}))
 Browse:AddColumn(TBColumnNew("DATE"         ,{ || paym->paydte}))
 Browse:AddColumn(TBColumnNew("CASHIER"      ,{ || paym->payentusr}))
 Browse:Colpos := Browse:freeze
 Browse:Colorspec  := COL_COLOR


 Do While .T.

    Do While !browse:stabilize() .and. ( key := inkey() ) == 0
    Enddo

      If browse:Stable
         Browse:ColorRect({BROWSE:ROWPOS,1,Browse:ROWPOS,Browse:COLCOUNT},{3,4})
         Browse:Configure():RefreshAll()
         Key := inkey(0)
     Endif

  
   DO Case
      Case  key == K_F3
                   oldrecpos := recno()
                   ch06print(term_desc)
                   paym->(dbgoto(oldrecpos))
                   Browse:Forcestable():Refreshall()
      Case  Key == K_ESC
             paym->(dbclosearea())
             EXIT
      Case Key == K_DOWN
           Browse:down()
      Case Key == K_UP
           Browse:up()
      Case Key == K_PGDN
           Browse:pageDown()
      Case Key == K_PGUP
           Browse:pageUp()
      Case Key == K_CTRL_PGDN
           Browse:goBottom()
      Case Key == K_CTRL_PGUP
           Browse:goTop()
      Case Key == K_HOME
           Browse:home()
      Case Key == K_END
           Browse:end()
      Case Key == K_LEFT
           Browse:PanLeft()
      Case Key == K_RIGHT
           Browse:Panright()
      Case WAS_IN1(CHR(Key))  == .T.
             Search_key := Stuff(Search_key,key_counter,1,chr(Key))
               @ 21,B_COL say Upper(Chr(Key))
                 B_COL++
                 Key_counter++

               If paym->(dbseek(Upper(Search_key))) == .T.
                  nrecno := Recno()
                  Do while !browse:stabilize()
                  Enddo
                   If browse:stable
                      paym->(dbgoto(nrecno))
                      browse:Refreshall()
                   Endif
               Endif


      CASE Key == K_BS .And. Empty(Search_Key)
                     Key_Counter := 1
                     B_COL       := 15
                     Search_Key  := ""

      CASE Key == K_BS .And. !Empty(Search_key)

                     If Key_Counter <= 1
                         Key_Counter := 1
                         B_COL       := 15
                         Search_Key  := ""
                      Else
                        Key_Counter--
                        B_COL--
                     Endif

                    Search_key := Stuff(Search_Key,Key_counter,1,'')
                      @ 21,B_COL say " "

                   If paym->(dbseek(UPPER(Search_Key))) == .T.

                       nrecno := Recno()
                       Do while !browse:stabilize()
                       Enddo

                       If browse:stable
                          paym->(dbgoto(nrecno))
                          browse:refreshall()
                       Endif
                   Endif

  ENDCASE


// Reset B_COL, Search_key,Key_counter

    If Key == K_END  .or. key == K_HOME .or. key == K_UP .or. key == K_DOWN  .or.;
       Key == K_PGDN .or. key == K_PGUP .or. key == K_CTRL_PGUP .or. key == K_CTRL_PGDN

         B_COL          := 15
         @ 21,B_COL SAY SPACE(50)
         Search_key     := ""
         Key            := ""
         Key_counter    := 1
    Endif

 ENDDO

 setcursor(oldcursor)
 Return Nil

      


Function REP06SCR()
//----------------------------------------------------------------------------
         //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
@ 01,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 02,0 say '³                    University of Cebu in Lapulapu and Mandaue                ³'
@ 03,0 say '³                       A.C Cortes Avenue, Mandaue City 6014                   ³'
@ 04,0 say '³                      SUMMARY OF PAYMENT FOR SCHOOL ACCOUNT                   ³'
@ 05,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 06,0 say '³ Term:                                                                        ³'
@ 07,0 say '³ File:                                                                        ³'
@ 08,0 say '³                                                                              ³'
@ 09,0 say '³                                                                              ³'
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
@ 20,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 21,0 say '³ Search Key :                                                                 ³'
@ 22,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 23,0 say '³ ESC-EXIT    F3- Print Summary                                                ³'
@ 24,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Return Nil



Function ch06print(term_desc)
Local Header1 := "University of Cebu in Lapulapu and Mandaue"
Local Header2 := "Cashier Department"
Local Header3 := "SUMMARY OF ALL PAYMENTS FOR SCHOOL ACCOUNT'S ONLY"
Local Page    := 1
Local Margin  := 5
Local oldpage := 0
Local counter := 1
Local line    := 8
Local choice
Local g_total := 0

  Do While .T.

   If !isprinter()
        inkey(1)
        Choice := Alert("Printer not ready or offline please check and try again!",{"Retry","Cancel"})
            If Choice == 2
               Exit
            Endif
   Endif

           Set Device to printer
           Set Printer On
           PrintStyle("line",2)
           PrintStyle("line",2)

  newdbf->(dbgotop())
  Do While !newdbf->(eof())

     If oldpage != page
        setprc(0,0)
         @ 01,100/2-len(Header1)/2 say Header1
         @ 02,100/2-len(Header2)/2 say Header2
         @ 03,100/2-len(Header3)/2 say Header3
         @ 04,01  say "Page # "+transform(page,"9999.")+"          "+term_desc+space(15)+"Date & Time Generated: "+DtoC(Date())+" : "+ampm(time())
         @ 05,01  say "-------------------------------------------------------------------------------------------------------"
         @ 06,01  say " SEQ. IDNO     STUDENT(S) NAME                  COURSE/YR        REFNO     PAY-DATE       PAY-AMOUNT   "
         @ 07,01  say "-------------------------------------------------------------------------------------------------------"
         //            9999. 9999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAA AAAAAAAAAAA 99-99-9999   9,999,999.99
         //            12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
        oldpage := page
     Endif

         @ Line,03  say Ltrim(Transform(Counter,"9999."))
         @ Line,07  say paym->sm1idno
         @ Line,16  say PAD(paym->paynamto,30," ")
    //     @ Line,49  say display_course(paym->sm1idno,paym->sm1colcod,paym->sm1majcod,paym->sm1yrlvl)
         @ Line,49  say paym->sm1colcod+paym->sm1majcod+'-'+paym->sm1yrlvl
         @ Line,64  say paym->payrefno
         @ Line,76  say Transform(paym->paydte,"99-99-9999")
         @ Line,86  say Transform(paym->payamt,"9,999,999.99")
           Line++
           Counter++
           g_total += newdbf->payamt
        

        If Line > 62
           @ Line,01  say "--------------------Continuing-Page--------------------Continuing-Page--------------------Continuing-Page----"
           Eject
           Line := 8
           Page++
           Eject
        Endif

     skip+1
     loop
   Enddo

      IF  newdbf->(eof())
                  @ Line,01  say "--------------------Final-Page-Nothing--Follows------------------------------------------------------"
                    Line++
                    Line++
                  @ Line,79  say "================================================="
                    Line++
                  @ Line,79  say "Grand Total "
                  @ Line,86  say transform(g_total,"99,999,999.99")
                    Line++
                  @ Line,79  say "================================================="
              Eject
           Endif



   setprc(0,0)
   PrintStyle("line",66)
   Set Device To Screen
   Set Printer Off
   Exit
Enddo

Return Nil





