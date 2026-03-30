//Tranfer of payment to other account file
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


Function chtran()

 // Save old settings
 Local oldscreen := savescreen(0,0,maxrow(),maxcol())
 Local oldcolor  := setcolor()
 Local oldcursor := setcursor()
 Local sch_term  := space(05)
 Local term_stat := {}
 Local getlist   := {}
 Local term_desc := space(40)
 Local choice    := space(01)

// Set environment settings
SET( _SET_CURSOR, SC_SPECIAL1)
SET( _SET_DATEFORMAT, "MM-DD-YYYY")
SET( _SET_ESCAPE, .T. )
SET( _SET_CONFIRM, .T.)
SET( _SET_COLOR ,"W+/B,W+/RB,,,GR+/B")
savescreen(0,0,maxrow(),maxcol())

 Do while .T.

  transcr()


  @ 06,08 get sch_term   picture "99999" when term_pre_valid(@sch_term)   == .T. valid get_term(06,31,40,@sch_term,@term_desc,term_stat) == .T.
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

      tran_or(sch_term)

   // Flush the array variable and other variables
      Asize(term_stat,0)        // Array of Term Status
      term_desc := space(40)
 Enddo

setcolor(oldcolor)
setcursor(oldcursor)
restscreen(0,0,maxrow(),maxcol(),oldscreen)
Return Nil

//----------------------------------------------------------------------------

 Function tran_or(vterm)

 Local items  := {" Refno"," Paydate"," Lastname+Firstname+Middle"," Idno"," None"}
 Local paym  := "f:\arunlib\a"+substr(vterm,3,3)+"paym.dbf"
 Local paymi := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"paym.cdx"
 Local oldcursor := setcursor(SC_NONE)
 Local Browse
 Local search_key      := ""
 Local B_COL           := 15
 Local Key_Counter     := 1
 Local Nrecno          := 0
 Local key             := 0
 Local Choice
 Local oldrecpos
 Local lowerscope := space(20)
 Local upperscope := space(20)
 Local paydetails := {}
 Local counter    := 0
 Local oldfocus
 Local payfile    := space(15)
 Local paycode    := space(04)
 Local paycate    := space(04)


 dbusearea(.T.,"DBFCDX",paym,"paym",.T.,.F.)
 paym->(ordlistadd(paymi))



 Browse           := TBrowseDB(06,1,20,78)
 Browse:headsep   := DEF_HSEP
 Browse:colsep    := DEF_CSEP
 Browse:footsep   := DEF_FSEP
 Browse:AddColumn(TBColumnNew("SEQ."         ,{ || transform(paym->(ordkeyno()),"9999.")}))
 Browse:AddColumn(TBColumnNew("REF-NO"       ,{ || paym->payrefno}))
 Browse:AddColumn(TBColumnNew("ID-NO"        ,{ || paym->sm1idno }))
 Browse:AddColumn(TBColumnNew("STUDENT-NAME" ,{ || pad(paym->paynamto,25,' ')}))
// Browse:AddColumn(TBColumnNew("CRS.   "    ,{ || xget_cr(pad(paym->sm1colcod+paym->sm1majcod,3,' ')) }))
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
                   Browse:Forcestable()
                   oldrecpos := recno()
                   oldfocus  := ordsetfocus()
                   asize(paydetails,FCOUNT())
                   For Counter := 1 to FCOUNT()
                       paydetails[counter] := fieldget(counter)
                   Next

                   payfile := paydetails[15]
                   paycode := paydetails[06]
                   paycate := paydetails[05]

                   tran_rec(vterm,paydetails,@payfile,@paycode,@paycate)
                   dbselectarea("paym")
                   paym->(dbsetindex(paymi))
                   ordsetfocus(oldfocus)
                   paym->(dbgoto(oldrecpos))
                     // Change the payfile signature
                      If alltrim(payfile) !=  alltrim(paydetails[15])
                         If !neterr()
                           do while !paym->(dbrlock()) .and. !neterr()
                           enddo
                          paym->payfile := payfile
                          paym->procode := paycode
                          paym->paycate := paycate
                          paym->(dbunlock())
                         Endif
                     Endif
                   asize(paydetails,0)
                   payfile := space(15)
                   Browse:Forcestable():Refreshall()


      Case  key == K_F10
             Choice := pop_menu(17,40,22,70,items)

               Do Case
                  Case Choice == 1
                       Browse:Forcestable()
                         ordsetfocus("refno")
                         get_scope(@lowerscope,@upperscope)
                         set scope to lowerscope,upperscope
                         Browse:Forcestable():gotop():Refreshall()
                  Case Choice == 2
                       Browse:Forcestable()
                         ordsetfocus("Sdate")
                         get_scope(@lowerscope,@upperscope)
                         set scope to transform(lowerscope,"99-99-9999"),transform(upperscope,"99-99-9999")
                         Browse:Forcestable():gotop():Refreshall()
                  Case Choice == 3
                       Browse:Forcestable()
                         ordsetfocus("tname")
                         get_scope(@lowerscope,@upperscope)
                         set scope to lowerscope,upperscope
                         Browse:Forcestable():gotop():Refreshall()

                  Case Choice == 4
                      Browse:Forcestable()
                         ordsetfocus("tidno")
                         get_scope(@lowerscope,@upperscope)
                         set scope to lowerscope,upperscope
                         Browse:Forcestable():gotop():Refreshall()

                   Case Choice == 5
                      Browse:Forcestable()
                         set scope to
                         Browse:Forcestable():gotop():Refreshall()
               Endcase



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

      


Function TRANSCR()
//----------------------------------------------------------------------------
         //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
@ 01,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 02,0 say '³                    University of Cebu in Lapulapu and Mandaue                ³'
@ 03,0 say '³                       A.C Cortes Avenue, Mandaue City 6014                   ³'
@ 04,0 say '³                            SUMMARY OF COLLECTION                             ³'
@ 05,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ 06,0 say '³ Term:                                                                        ³'
@ 07,0 say '³                                                                              ³'
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
@ 23,0 say '³ ESC-EXIT    F3- Move to Term & Target file  F10 Change View Order            ³'
@ 24,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Return Nil


  Function tran_rec(vterm,paydetails,payfile,paycode,paycate)

     Local oldscr    := savescreen(05,05,12,75)
     Local oldcursor := setcursor()
     Local getlist   := {}
     Local counter   := 0
     Local sch_term  := space(05)
     Local term_stat := {}
     Local term_desc := space(40)
     Local choice
     Local payp
     Local paypi
     Local Flag      := .F.
     Local focus
     Local trans
     Local transi
     Local payo
     Local payoi
     Local target_file := space(01)
     Local dbf_desc    := space(30)
     Local cdx_desc    := space(30)

     @ 05,05 clear to 12, 75
     @ 05,05 to 12,75 double
     SET( _SET_CURSOR, SC_SPECIAL1)

      @ 07,06 Say "Move O.R. Number "+paydetails[1]
      @ 08,06 Say "To what term? : "
      @ 09,06 Say "To what file? :     U-CLM  M-ETC  E-LEM/HIGH  S-HORT O-OTHER INCOME"
      @ 10,06 Say "F4 - Prompt term "

      @ 08,22 get sch_term    picture "99999" when term_pre_valid(@sch_term)   == .T. valid get_term(08,35,40,@sch_term,@term_desc,term_stat) == .T.
      @ 09,22 get target_file picture "@!" Valid target_file $ "U M E S O "
  read
      Post_Valid_Dbf()


        Do Case
           Case target_file == "U"
                dbf_desc := "f:\arunlib\a"+substr(sch_term,3,3)+"payp.dbf"
                cdx_desc := "f:\arunlib\cdx\a"+substr(sch_term,3,3)+"payp.cdx"
           Case target_file == "M"
                dbf_desc := "f:\metc\arunlib\a"+substr(sch_term,3,3)+"payp.dbf"
                cdx_desc := "f:\metc\arunlib\a"+substr(sch_term,3,3)+"payp.cdx"
           Case target_file == "E"
                dbf_desc := "f:\erunlib\e"+substr(sch_term,3,3)+"payp.dbf"
                cdx_desc := "f:\erunlib\cdx\e"+substr(sch_term,3,3)+"payp.cdx"
           Case target_file == "S"
                dbf_desc := "f:\crunlib\short\tra"+sch_term+".dbf"
                cdx_desc := "f:\crunlib\short\cdx\tra"+sch_term+".cdx"
           Case target_file == "O"
                dbf_desc := "f:\arunlib\a"+substr(sch_term,3,3)+"payo.dbf"
                cdx_desc := "f:\arunlib\cdx\a"+substr(sch_term,3,3)+"payo.cdx"
        Endcase

             
        If !file(dbf_desc) .or. !file(cdx_desc)
           Alert("Target file does not exist!",{"Cancel"})
        Endif



     if file(dbf_desc) .and.  file(cdx_desc)

            //Check if O.R. previously moved to other term
            //then use that term

             Do Case
                Case Substr(Upper(paydetails[15]),1,1) == 'A' .OR.  Substr(Upper(paydetails[15]),1,1) == 'E'
                      If substr(paydetails[15],2,3) != substr(vterm,3,3)
                         vterm := "20"+substr(paydetails[15],2,3)
                      Endif
                Case Substr(Upper(paydetails[15]),1,1) == "T"
                     If  substr(paydetails[15],6,3) != substr(vterm,3,3)
                        vterm := "20"+substr(paydetails[15],6,3)
                     Endif
                Otherwise
                     vterm := vterm
             Endcase



      Do Case
         Case left(alltrim(UPPER(paydetails[15])),1) == "A" .and. substr(alltrim(UPPER(paydetails[15])),10,1) == "C"
            // UCLM FILES
            // Read Source dbf

               payp  := "f:\arunlib\a"+substr(vterm,3,3)+"payp.dbf"
               paypi := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"payp.cdx"

               dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
               payp->(ordlistadd(paypi))
               ordsetfocus("trefno")
               payp->(dbgotop())

               // Seek and get payment details
             If payp->(dbseek(alltrim(paydetails[1]))) == .T.
                      If payp->payposted == .T.
                         Alert("Posted Payment cannot be move!",{"Cancel"})
                         Flag := .F.
                       Else
                         do while !payp->(dbrlock()) .and. !neterr()
                         enddo
                         payp->(dbdelete())
                         payp->(dbunlock())
                         Flag := .T.
                     Endif
             Endif

                payp->(dbclosearea())

                If Flag == .T.
                     writeto(target_file,sch_term,paydetails,@payfile,@paycode,@paycate)
                     Flag := .F.
                Endif

         
         Case left(alltrim(UPPER(paydetails[15])),1) == "A" .and. substr(alltrim(UPPER(paydetails[15])),10,1) == "M"
              // METC FILES
              // Read Source dbf

               payp  := "f:\metc\arunlib\a"+substr(vterm,3,3)+"payp.dbf"
               paypi := "f:\metc\arunlib\a"+substr(vterm,3,3)+"payp.cdx"
               focus := "a"+substr(vterm,3,3)+"pay1"

               dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
               ordlistadd(paypi)
               ordsetfocus(focus)
               payp->(dbgotop())

                   // Seek and get payment details

             If payp->(dbseek(alltrim(substr(paydetails[1],4,8)+dtos(paydetails[2])))) == .T.
                         do while !payp->(dbrlock()) .and. !neterr()
                         enddo
                         payp->(dbdelete())
                         payp->(dbunlock())
                         Flag := .T.
             Endif

               payp->(dbclosearea())

               If Flag == .T.
                  writeto(target_file,sch_term,paydetails,@payfile,@paycode,@paycate)
                  flag := .f.
               Endif




         Case left(alltrim(UPPER(paydetails[15])),1) == "E"
              // ELEMENTARY & HIGH SCHOOL FILES
              // Read Source dbf

               payp  := "f:\erunlib\e"+substr(vterm,3,3)+"payp.dbf"
               paypi := "f:\erunlib\cdx\e"+substr(vterm,3,3)+"payp.cdx"

               dbusearea(.T.,"DBFCDX",payp,"payp",.T.,.F.)
               payp->(ordlistadd(paypi))
               ordsetfocus("trefno")
               payp->(dbgotop())

               // Seek and get payment details
             If payp->(dbseek(alltrim(paydetails[1]))) == .T.
                      If payp->payposted == .T.
                          Flag := .F.
                          Alert("Posted Payment cannot be move!",{"Cancel"})
                       Else
                         Flag := .T.
                         do while !payp->(dbrlock()) .and. !neterr()
                         enddo
                         payp->(dbdelete())
                         payp->(dbunlock())
                     Endif
             Endif
                         
              payp->(dbclosearea())

              If Flag == .T.
                 writeto(target_file,sch_term,paydetails,@payfile,@paycode,@paycate)
                 flag := .f.
              Endif


     
         // SHORT TERM FILE
         Case substr(alltrim(UPPER(paydetails[15])),1,1) == "T"

              // Read Source dbf

               trans  := "f:\crunlib\short\tra"+vterm+".dbf"
               transi := "f:\crunlib\short\cdx\tra"+vterm+".cdx"

               dbusearea(.T.,"DBFCDX",trans,"trans",.T.,.F.)
               trans->(ordlistadd(transi))
               ordsetfocus("tnum")
               trans->(dbgotop())

             If trans->(dbseek(alltrim(paydetails[1]))) == .T.
                  Flag := .T.
                  do while !trans->(dbrlock()) .and. !neterr()
                  enddo
                  trans->(dbdelete())
                  trans->(dbunlock())
              Endif
                         
               trans->(dbclosearea())

               If Flag == .T.
                 writeto(target_file,sch_term,paydetails,@payfile,@paycode,@paycate)
                 flag := .f.
              Endif

         Case left(alltrim(UPPER(paydetails[15])),1) == "A" .and. substr(alltrim(UPPER(paydetails[15])),8,1) == "O"
            // OTHER INCOME FILES
            // Read Source dbf

               payo  := "f:\arunlib\a"+substr(vterm,3,3)+"payo.dbf"
               payoi := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"payo.cdx"

               dbusearea(.T.,"DBFCDX",payo,"payo",.T.,.F.)
               payo->(ordlistadd(payoi))
               ordsetfocus("refno")
               payo->(dbgotop())

             If payo->(dbseek(alltrim(paydetails[1]))) == .T.
                         Flag := .T.
                         do while !payo->(dbrlock()) .and. !neterr()
                         enddo
                         payo->(dbdelete())
                         payo->(dbunlock())
             Endif

                payo->(dbclosearea())

                  If Flag == .T.
                     writeto(target_file,sch_term,paydetails,@payfile,@paycode,@paycate)
                     Flag := .F.
                  Endif

      Endcase
Endif

 setcursor(oldcursor)
 restscreen(05,05,12,75,oldscr)
  Return Nil



  Function writeto(target_file,vterm,payment_details,new_term,paycode,paycate)

  Local getlist   := {}
  Local pay_cod   := space(04)
  Local pay_desc  := {}
  Local oldscreen := savescreen(10,5,15,40)
  Local oldcursor := setcursor()

          Do Case
             Case target_file == "U"
                  payment_details[6] := "0001"
                  Save2PAYP(vterm,payment_details)
                  new_term := "a"+substr(vterm,3,3)+"payp-c"
                  paycode  := payment_details[6]
                  paycate  := "UCLM"
                  
             Case target_file == "M"
                  payment_details[6] := "0001"
                  MSave2PAYP(vterm,payment_details)
                  new_term := "a"+substr(vterm,3,3)+"payp-m"
                  paycode  := payment_details[6]
                  paycate  := "METC"

             Case target_file == "E"
                  payment_details[6] := "0001"
                  eSave2PAYP(vterm,payment_details)
                  new_term := "e"+substr(vterm,3,3)+"payp"
                  paycode  := payment_details[6]
                  paycate  := "ELEM"

             Case target_file == "S"
                  payment_details[6] := "0001"
                  Save2TRA(vterm,payment_details)
                  new_term := "tra"+vterm
                  paycode  := payment_details[6]
                  paycate  := "SHOR"

             Case target_file == "O"


                  @ 10,5 clear to 15,40
                  @ 10,5 to 15,40 Double
                  SET( _SET_CURSOR, SC_SPECIAL1)
                  @ 12,7 say "Enter Payment Code : "
                  @ 14,7 say "F4 - Prompt Code     "
                  @ 12,29 get pay_cod picture "@!"   when paycod_pre_valid(@pay_cod) == .T. valid get_paycod(@pay_cod,@pay_desc) == .T.
                  read

                  Post_Valid_Dbf()

                  payment_details[6] := alltrim(pay_cod)
                  Save2PAYO(vterm,payment_details)
                  new_term := "a"+substr(vterm,3,3)+"payo"
                  paycode  := payment_details[6]
                  paycate  := "OTHE"

          Endcase
                Alert("Record succesfully moved to target file.. ",{"OK"})




         restscreen(10,5,15,40,oldscreen)
         setcursor(oldcursor)

    Return Nil






