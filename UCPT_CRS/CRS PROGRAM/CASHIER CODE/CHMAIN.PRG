
# include "ERROR.CH"
# include "ABROWSE.CH"
# include "INKEY.CH"
# include "SETCURS.CH"
# include "ord.ch"
# DEFINE  DEF_HSEP   "ÂÄ"
# DEFINE  DEF_CSEP   "³"
# DEFINE  DEF_FSEP   "ÁÄ"
# DEFINE  COL_COLOR "+W/B, +W/B, W+/BG, W+/BG, W+/G, 15/12, 15/12, N/W, N/W, W+/RB"
# DEFINE  TB_REFRESH_RATE 1


Function chmain()

 // Save old settings
 Local oldscreen := savescreen(0,0,maxrow(),maxcol())
 Local oldcolor  := setcolor()
 Local oldcursor := setcursor()
 Local sch_term  := space(05)
 Local term_stat := {}
 Local getlist   := {}
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

 Do while .t.

  CHMAINSCR()
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

      Browse_paym(sch_term)

   // Flush the array variable and other variables
      Asize(term_stat,0)        // Array of Term Status
      term_desc := space(40)

 Enddo

setcolor(oldcolor)
setcursor(oldcursor)
restscreen(0,0,maxrow(),maxcol(),oldscreen)
Return Nil

//----------------------------------------------------------------------------

 Function Browse_paym(vterm)

 Local items  := {" Set Order "," Set Scope"," Remove Scope "}
 Local items2 := {" refno  "," Sdate "," tname ", " Tidno "}
 Local paym   := "f:\arunlib\a"+substr(vterm,3,3)+"paym.dbf"
 Local paymi  := "f:\arunlib\cdx\a"+substr(vterm,3,3)+"paym.cdx"
 Local pycan  := "f:\arunlib\a999canc.dbf"

 Local pyus      := "F:\arunlib\a999pyus.dbf"
 Local pyusi     := "F:\arunlib\cdx\a999pyus.cdx"


 Local oldcursor := setcursor(SC_NONE)
 Local Browse
 Local Choice
 Local top_scope       := space(20)
 Local bottom_scope    := space(20)
 Local search_key      := ""
 Local B_COL           := 15
 Local Key_Counter     := 1
 Local Nrecno          := 0
 Local key             := 0
 Local file_path       := space(10)
 Local arefno          := space(08)
 Local oldrecno
 Local oldfocus
 Local username        := space(08)

 dbusearea(.T.,"DBFCDX",paym,"paym",.T.,.F.)
 paym->(ordlistadd(paymi))
 //ordsetfocus("refno")

 Browse           := TBrowseDB(06,1,20,78)
 Browse:headsep   := DEF_HSEP
 Browse:colsep    := DEF_CSEP
 Browse:footsep   := DEF_FSEP
 Browse:AddColumn(TBColumnNew("SEQ."         ,{ || transform(paym->(ordkeyno()),"9999.")}))
 Browse:AddColumn(TBColumnNew("REF-NO"       ,{ || paym->payrefno}))
 Browse:AddColumn(TBColumnNew("ID-NO"        ,{ || paym->sm1idno }))
 Browse:AddColumn(TBColumnNew("STUDENT-NAME" ,{ || pad(paym->paynamto,25,' ')}))
 Browse:AddColumn(TBColumnNew("CRS.   "      ,{ || xget_cr(pad(paym->sm1colcod+paym->sm1majcod,3,' '))}))
 Browse:AddColumn(TBColumnNew("YR"           ,{ || paym->sm1yrlvl}))
 Browse:AddColumn(TBColumnNew("AMOUNT"       ,{ || transform(paym->payamt,"999,999.99")}))
 Browse:AddColumn(TBColumnNew("TYPE"         ,{ || IF(paym->paytype == '1',"CASH ","CHECK")}))
 Browse:AddColumn(TBColumnNew("DATE"         ,{ || paym->paydte}))
 Browse:AddColumn(TBColumnNew("CASHIER"      ,{ || paym->payentusr}))
 Browse:Colpos := Browse:freeze
 Browse:Colorspec  := COL_COLOR
 Browse:gotop()


 Do While .T.

    Do While !browse:stabilize() .and. ( key := inkey() ) == 0
    Enddo

      If browse:Stable
         Browse:ColorRect({BROWSE:ROWPOS,1,Browse:ROWPOS,Browse:COLCOUNT},{3,4})
         Browse:RefreshCURRENT()
         Key := inkey(0)
     Endif

  
   DO Case
      Case  key == K_F1
            Re_for(vterm)

      Case  key == K_F3
             Alert("Check printer and press ENTER key",{"Enter"})
             Re_printOR(vterm)
      Case  key == K_F4
        if cpassword({9},@username)
        Choice := Alert("Sure to cancel to this payment?",{"YES","NO"})
          If Choice == 1
              file_path := paym->payfile
              arefno    := paym->payrefno
              oldrecno  := recno()
              oldfocus  := ordsetfocus()

              // Write to cancel File
                dbusearea(.T.,"DBFCDX",pycan,"pycan",.T.,.F.)
              do while !pycan->(dbrlock()) .and. !neterr()
              enddo
              if pycan->(dbrlock())
                append from &paym RECORD oldrecno
                pycan->(dbcommit())
                pycan->(dbunlock())
              Endif

              pycan->(dbclosearea())

              dbselectarea("paym")
              ordsetfocus(oldfocus)
              paym->(dbgoto(oldrecno))

             do while !paym->(dbrlock()) .and. !neterr()
             enddo
             if paym->(dbrlock())
              paym->(dbdelete())
              paym->(dbunlock())
             Endif
              Browse:Forcestable():Configure():invalidate():Refreshall()
              Del_other(Trim(arefno),Trim(file_path))
            Endif
        else
             dbusearea(,"DBFCDX",paym,"paym",.T.,.F.)
             paym->(ordlistadd(paymi))

        endif
      Case  key == K_F10
             Choice := pop_menu(18,55,22,75,items)
                Do Case
                   Case Choice == 1
                        Choice := pop_menu(16,55,21,70,items2)
                          If Choice != 0
                             ordsetfocus(alltrim(items2[Choice]))
                             Browse:Forcestable():Refreshall():gotop()
                           Endif
                   Case Choice == 2
                             scope_box(15,15,20,60,@top_scope,@bottom_scope)
                           If !empty(top_scope) .and. !empty(bottom_scope)
                             set scope to top_scope,bottom_scope
                             top_scope    := space(20)
                             bottom_scope := space(20)
                             Browse:Forcestable():RefreshaLL():gotop()
                           Endif

                   Case Choice == 3
                        set scope to
                        Browse:Forcestable():Refreshall():gotop()
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

      


Function CHMAINSCR()
//----------------------------------------------------------------------------
         //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
@ 01,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 02,0 say '³                    University of Cebu in Lapulapu and Mandaue                ³'
@ 03,0 say '³                       A.C Cortes Avenue, Mandaue City 6014                   ³'
@ 04,0 say '³                      CASHIER MAINTAINANCE FOR PAYMENT ROUTINE                ³'
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
@ 23,0 say '³ ESC-EXIT    F3-Re Print O.R.    F4-Cancel Payment    F10-Additional Function ³'
@ 24,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Return Nil


 Function xget_cr(course_maj)
  Local oldalias := alias()
  Local oldrec   := recno()
  Local oldindex := ordbagname(indexord())
  Local oldfocus := ordsetfocus()
  Local retval

 retval := get_cour_abbr(course_maj)
 dbselectarea(oldalias)
 ordsetfocus(oldfocus)
 Return Retval

 
 Function Del_other(arefno,afile_path)
  Local oldalias     := alias()
  Local oldrec       := recno()
  Local oldindex     := ordbagname(indexord())
  Local oldfocus     := ordsetfocus()
  Local dbf_files
  Local use_index
  Local order_focus  := {"trefnum","trefno",substr(afile_path,1,4)+"pay1","refno","tnum"}
  Local alias_list   := {"payp","payp","payp","payo","trans"}
  Local index        := 0

    Do Case
       Case substr(afile_path,1,1)+substr(afile_path,5,4)  == "EPAYP"
            dbf_files := "F:\ERUNLIB\"+afile_path+".DBF"
            use_index := "F:\ERUNLIB\CDX\"+afile_path+".CDX"
                index := 1
       Case substr(afile_path,5,6) == "PAYP-C"
            dbf_files := "F:\ARUNLIB\"+substr(afile_path,1,8)+".DBF"
            use_index := "F:\ARUNLIB\CDX\"+substr(afile_path,1,8)+".CDX"
                index := 2
       Case substr(afile_path,5,6) == "PAYP-M"
            dbf_files := "F:\METC\ARUNLIB\"+substr(afile_path,1,8)+".DBF"
            use_index := "F:\METC\ARUNLIB\"+substr(afile_path,1,8)+".CDX"
            arefno    := substr(arefno,4,8)
                index := 3
       Case substr(afile_path,5,4) == "PAYO"
            dbf_files := "F:\ARUNLIB\"+afile_path+".DBF"
            use_index := "F:\ARUNLIB\CDX\"+afile_path+".CDX"
                index := 4
       Case substr(afile_path,1,3) == "TRA"
            dbf_files := "F:\CRUNLIB\SHORT\"+afile_path+".DBF"
            use_index := "F:\CRUNLIB\SHORT\CDX\"+afile_path+".CDX"
                index := 5
    Endcase



dbusearea(.T.,"DBFCDX",dbf_files,alias_list[Index],.T.,.F.)
(alias_list[index])->(ordlistadd(use_index))
ordsetfocus(order_focus[index])
(alias_list[index])->(dbgotop())

 If (alias_list[index])->(dbseek(arefno)) == .T.
    do while !(alias_list[index])->(dbrlock()) .and. !neterr()
    enddo
     (alias_list[index])->(dbdelete())
     (alias_list[index])->(dbunlock())
  Else
      Alert("Cannot locate refno from file",{"Cancel"})
 Endif

(alias_list[index])->(dbclosearea())


// Restore old Dbf & Index
 dbselectarea(oldalias)
 dbsetindex(oldindex)
 ordsetfocus(oldfocus)

 Return Nil

//-----------------------------------------------------------------------------

Function Re_printOR(Vterm)
 Local payment_details := {}
 Local oldalias     := alias()
 Local oldrec       := recno()
 Local oldindex     := ordbagname(indexord())
 Local oldfocus     := ordsetfocus()
 asize(payment_details,19)

  payment_details[01] := paym->payrefno
  payment_details[02] := paym->paydte
  payment_details[03] := paym->payentime
  payment_details[04] := paym->paytype
  payment_details[05] := ''
  payment_details[06] := ''
  payment_details[07] := paym->sm1idno
  payment_details[08] := paym->payamt
  payment_details[09] := paym->paychkno
  payment_details[10] := paym->paychknam
  payment_details[11] := paym->paynamto
  payment_details[12] := ''
  payment_details[13] := paym->paytelr
  payment_details[14] := ''
  payment_details[15] := ''
  payment_details[16] := paym->sm1colcod
  payment_details[17] := paym->sm1majcod
  payment_details[18] := paym->sm1yrlvl
  payment_details[19] := paym->procode

  // Get the description

  payment_details[13] := get_tlr(payment_details[13])
  payment_details[19] := get_pcd(payment_details[19])

  printor(vterm,payment_details)
  asize(payment_details,0)

  // Restore old Dbf & Index
     dbselectarea(oldalias)
     dbsetindex(oldindex)
     ordsetfocus(oldfocus)
 Return Nil


 Function re_for(vterm)
 Local payment_details := {}
 Local oldalias     := alias()
 Local oldrec       := recno()
 Local oldindex     := ordbagname(indexord())
 Local oldfocus     := ordsetfocus()
 Local choice
 asize(payment_details,19)

  payment_details[01] := paym->payrefno
  payment_details[02] := paym->paydte
  payment_details[03] := paym->payentime
  payment_details[04] := paym->paytype
  payment_details[05] := ''
  payment_details[06] := ''
  payment_details[07] := paym->sm1idno
  payment_details[08] := paym->payamt
  payment_details[09] := paym->paychkno
  payment_details[10] := paym->paychknam
  payment_details[11] := paym->paynamto
  payment_details[12] := ''
  payment_details[13] := paym->paytelr
  payment_details[14] := ''
  payment_details[15] := ''
  payment_details[16] := paym->sm1colcod
  payment_details[17] := paym->sm1majcod
  payment_details[18] := paym->sm1yrlvl
  payment_details[19] := paym->procode

  // Get the description

  payment_details[13] := get_tlr(payment_details[13])
  payment_details[19] := get_pcd(payment_details[19])

   choice := Alert("Sure to reforward this record?",{"Yes","No"})
  If Choice == 1
   save2payp(vterm,payment_details)
  Endif

  asize(payment_details,0)

  // Restore old Dbf & Index
     dbselectarea(oldalias)
     dbsetindex(oldindex)
     ordsetfocus(oldfocus)

 Return Nil

  
