// Cashier System User Maintainance
// Feb 18, 2002

# include "INKEY.CH"
# include "GRUMP.CH"
# include "GRUMPR.CH"
# include "GRUMPH.CH"
# include "GRUMPM.CH"
# include "SHADOWB.CH"
# include "DBINFO.CH"
# include "BOX.CH"
# include "SETCURS.CH"

Function ch02()

 Local oldscreen
 Local oldcolor
 Local key
 Local Counter
 Local oldcursor := setcursor()

  // Save the Current Settings
 oldcolor := setcolor()
 setcolor("W+/B")
 oldscreen :=  savescreen(0,0,maxrow(),maxcol())
 @ 00,00 say PADC("ADD/UPDATE/DELETE CASHIERS SYSTEM USERS",80,"") Color("GR+/R")
 setcolor(oldcolor)

 Do while .T.
 oldcolor := setcolor()
 setcolor("W+/B")
 @ 02,01 say replicate('ß',78)
 @ 09,01 say replicate('ß',78)

  For Counter := 03 to 08
  @ Counter,01 say PAD(" ",78," ")
 Next

 For Counter := 09 to 23
  @  Counter,01 say PAD(" ",78," ")
 Next


 @ 03,03 say "SHORT NAME     :                                                           "
 @ 04,03 say "FULL NAME      :                                                           "
 @ 05,03 say "LETTER CONTROL :                                                           "
 @ 06,03 say "PASSWORD       :                                                           "
 @ 07,03 say "RE PASSWORD    :                                                           "
 @ 08,03 say "ACCESS LEVEL   :       7-Cashier Operator  1-Viewer 8-Supervisor           "
 setcolor(oldcolor)
 @ 23,01 say PADR(" ESC - Previous    F1-Add    F2-Update    F3-Delete",78," ") Color("N/W+")

   key := Wait_key()

      Do Case
         Case key == K_ESC
              exit
         Case key == K_F1
              chus_add()
         Case key == K_F2
              chus_mod()
         Case key == K_F3
              chus_del()
      Endcase
   Enddo

 // Restore the old settings
 restscreen(0,0,maxrow(),maxcol(),oldscreen)
 setcursor(oldcursor)
 setcolor(oldcolor)
Return Nil


Function chus_Add()
 
 Local oldcursor := setcursor()
 Local shrtname  := space(10)
 Local fullname  := space(30)
 Local literal   := space(01)
 Local password  := space(08)
 Local repasswo  := space(08)
 Local level     := space(01)
 Local getlist   := {}
 Local oldcolor
 Local Choice
 Local user_header := {"SHORT NAME","FULL NAME ","LITERAL CONTROL"}
 Local user_pic    := {"XXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local user_fields := {1,2,7}

 Local pyus  := "F:\arunlib\a999pyus.dbf"
 Local pyusi := "F:\arunlib\cdx\a999pyus.cdx"

 dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
 dbsetindex(pyusi)
 set order to tag short_name

 SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

   pyus->(dbgotop())
   @ 03,20 get shrtname Pict "@!"
    Read

   shrtname := alltrim(shrtname)

   Do Case
      Case Lastkey() == K_ESC
         Exit
      Case Empty(shrtname)
         set order to tag full_name
         _2GBROW(1,5,22,75,@shrtname,user_header,user_fields,user_pic,1)
         set order to tag short_name
         shrtname := space(10)
         loop
      Case pyus->(dbseek(upper(shrtname))) == .T.
         Alert("Duplicate Cashier short name not allowed! ",{"Retry"})
         shrtname := space(10)
         loop

      Case pyus->(dbseek(upper(shrtname))) == .F.

         @ 04,20 get fullname pict "@!" valid !empty(fullname)
         @ 05,20 get literal  pict "@!"
         Read

         If exist_literal_code(literal) == .T.
           Alert("Duplicate Literal Code Not Allowed !",{"Retry"})
            loop
         Endif


         Hide(06,20,10,@password)
         Hide(07,20,10,@repasswo)

         IF (TRIM(password) != TRIM(repasswo))
           Alert("Password Validation Failed! Please. Re-enter Again",{"Okey"})
           loop
         Endif

         @ 08,20 get level pict "@!" valid level $ "1 2 3 4 5 6 7 8 9" .and. !empty(level)
         read


         
     Choice := Alert("Save the new entries?",{"Save","Cancel"})

      If Choice == 1
         If !neterr()
             pyus->(dbappend())
          If pyus->(dbrlock())
             Replace pyus->chshrtnam   with shrtname
             Replace pyus->chfullnam   with fullname
             Replace pyus->payrefno    with space(08)
             Replace pyus->paycount    with 0
             Replace pyus->last_date   with date()
             Replace pyus->last_time   with time()
             Replace pyus->literal_cnt with literal
             Replace pyus->password    with password
             Replace pyus->level       with level
             pyus->(dbcommit())
             pyus->(dbunlock())
          Endif
        Endif
              Alert("Entry Succesfully Appended!",{"Okey"})
        Endif

       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 setcursor(oldcursor)
 pyus->(dbclosearea())
 Return Nil


 Function chus_del()
 Local oldcursor := setcursor()
 Local getlist   := {}
 Local shrtname  := space(10)
 Local fullname  := space(30)
 Local literal   := space(01)
 Local oldcolor
 Local Choice
 Local user_header := {"SHORT NAME","FULL NAME ","LITERAL CONTROL"}
 Local user_pic    := {"XXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local user_fields := {1,2,7}

 Local pyus  := "F:\arunlib\a999pyus.dbf"
 Local pyusi := "F:\arunlib\cdx\a999pyus.cdx"

 dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
 dbsetindex(pyusi)
 set order to tag short_name

 SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

    pyus->(dbgotop())
  @ 03,20 get shrtname Pict "@!"
    Read

       shrtname := alltrim(shrtname)

   Do Case
      Case Lastkey() == K_ESC
         Exit
      Case Empty(shrtname)
         set order to tag full_name
         _2GBROW(1,5,22,75,@shrtname,user_header,user_fields,user_pic,1)
         set order to tag short_name
         loop
      Case pyus->(dbseek(upper(shrtname))) == .F.
         Alert("Cashier Short Name Not Found! ",{"Retry"})
         shrtname := space(10)
         loop

      Case pyus->(dbseek(upper(shrtname))) == .T.
         @ 04,20 say pyus->chfullnam  pict "@!"  Color("GR+/B")
         @ 05,21 say pyus->literal_cn pict "@!"  Color("GR+/B")

       Choice := Alert("Sure to delete this record?",{"Cancel","Delete"})

        If Choice == 2
           If !neterr()
             If pyus->(dbrlock())
                pyus->(dbdelete())
                pyus->(dbunlock())
           Endif
          Endif
         Alert("Record Succesfully Deleted!",{"Okey"})
        Endif
       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 setcursor(oldcursor)
 pyus->(dbclosearea())
 Return Nil


Function chus_Mod()
 
 Local oldcursor := setcursor()
 Local getlist   := {}
 Local oldcolor
 Local Choice
 Local shrtname  := space(10)
 Local fullname  := space(30)
 Local literal   := space(01)
 Local password  := space(08)
 Local repasswo  := space(08)
 Local level     := space(01)
 Local user_header := {"SHORT NAME","FULL NAME ","LITERAL CONTROL"}
 Local user_pic    := {"XXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local user_fields := {1,2,7}

 Local pyus  := "F:\arunlib\a999pyus.dbf"
 Local pyusi := "F:\arunlib\cdx\a999pyus.cdx"

 dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
 dbsetindex(pyusi)
 set order to tag short_name

 SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

    pyus->(dbgotop())
  @ 03,20 get shrtname Pict "@!"
    Read

     shrtname := Alltrim(shrtname)

   Do Case
      Case Lastkey() == K_ESC
         Exit

      Case Empty(shrtname)
         set order to tag full_name
         _2GBROW(1,5,22,75,@shrtname,user_header,user_fields,user_pic,1)
         set order to tag short_name
         loop

      Case pyus->(dbseek(upper(shrtname))) == .F.
         Alert("Cashier Short Name Not Found Please. retry again! ",{"Retry"})
         shrtname := space(10)
         loop

      Case pyus->(dbseek(upper(shrtname))) == .T.
           fullname := pyus->chfullnam
           literal  := pyus->literal_cn
           password := pyus->password
           level    := pyus->level



         @ 03,20 get shrtname pict "@!" valid !empty(shrtname)
         @ 04,20 get fullname pict "@!" valid !empty(fullname)
         @ 05,20 get literal  pict "@!" valid !empty(literal)
         Read

         If exist_literal_code(literal) == .T.
            Alert("Duplicate Literal Code not Allowed Please try Again! ",{"Retry"})
            loop
         Endif



    Choice := Alert("Do you wish to change your password too?",{"Yes","No"})
        If Choice == 1
          Hide(06,20,10,@password)
          Hide(07,20,10,@repasswo)

         IF (TRIM(password) != TRIM(repasswo))
           Alert("Password Validation Failed! Please. Re-enter Again",{"Okey"})
           loop
         Endif
      Endif

        @ 08,20 get level picture "@!" valid level $ "1 2 3 4 5 6 7 8 9 " .and. !empty(level)
        read
       

     Choice := Alert("Save the modified records?",{"Save","Cancel"})

    If Choice == 1
     If !neterr()
      If pyus->(dbrlock())
         pyus->chshrtnam  := shrtname
         pyus->chfullnam  := fullname
         pyus->literal_cn := literal
         pyus->password   := password
         pyus->level      := level
         pyus->(dbunlock())
      Endif
     Endif
       Alert("Record Succesfully Modified!",{"Okey"})
    Endif
       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 setcursor(oldcursor)
 pyus->(dbclosearea())
 Return Nil


 Function exist_literal_code(literal)
 Local Retval := .F.
 Local oldrecno := recno()
 set order to tag cnt_letter
 pyus->(dbgotop())

 if dbseek(trim(upper(literal)))  == .T.
    Retval := .T.
 Endif

 set order to tag short_name
 pyus->(dbgoto(oldrecno))
 Return Retval


