
# include "INKEY.CH"
# include "GRUMP.CH"
# include "GRUMPR.CH"
# include "GRUMPH.CH"
# include "GRUMPM.CH"
# include "SHADOWB.CH"
# include "DBINFO.CH"
# include "BOX.CH"
# include "SETCURS.CH"

Function ch01()
 Local oldcursor
 Local oldscreen
 Local oldcolor
 Local key
 Local Counter

 oldcursor := setcursor()
 oldscreen :=  savescreen(0,0,maxrow(),maxcol())
 // Save the Current Settings
 oldcolor := setcolor()
 setcolor("W+/B")
 @ 00,00 say PADC("ADD/UPDATE/DELETE PAYMENT CODE",80,"") Color("GR+/R")
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

 @ 03,03 say "PAYMENT CODE  :                                                             "
 @ 04,03 say "DESCRIPTION   :                                                             "
 @ 05,03 say "CLASSIFICATION:   A -Student Account O -Non Student Account/Other Income    "
 setcolor(oldcolor)
 @ 23,01 say PADR(" ESC - Previous    F1-Add    F2-Update    F3-Delete",78," ") Color("N/W+")

   key := Wait_key()

      Do Case
         Case key == K_ESC
         exit
         Case key == K_F1
              paycode_add()
         Case key == K_F2
              paycode_mod()
         Case key == K_F3
              paycode_del()
      Endcase
   Enddo

 // Restore the old settings
 restscreen(0,0,maxrow(),maxcol(),oldscreen)
 setcursor(oldcursor)
 setcolor(oldcolor)
Return Nil


Function Paycode_Add()
 
 Local oldcursor    := setcursor()
 Local paycode      := space(04)
 Local typ          := space(01)
 Local description  := space(30)
 Local getlist   := {}
 Local oldcolor
 Local Choice
 Local paycode_header := {"CODE","DESCRIPTION","TYPE"}
 Local paycode_pic    := {"XXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local paycode_fields := {1,2,3}

 Local pycd  := "f:\arunlib\a999pycd.dbf"
 Local pycdi := "f:\arunlib\cdx\a999pycd.cdx"

 dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
 dbsetindex(pycdi)
 set order to tag py_code
 SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

    pycd->(dbgotop())

  @ 03,19 get paycode  Pict "@!"
    Read

   Do Case
      Case Lastkey() == K_ESC
         Exit
      Case Empty(paycode)
         set order to tag py_desc
         _2GBROW(1,5,22,75,@paycode,paycode_header,paycode_fields,paycode_pic,1)
         set order to tag py_code
         loop

      Case pycd->(dbseek(upper(paycode))) == .T.
         Alert("Duplicate Payment Code Not Allowed! ",{"Retry"})
         paycode := space(04)
         loop

      Case pycd->(dbseek(upper(paycode))) == .F.

         SET(_SET_ESCAPE,.F.)
         @ 04,19 get description pict "@!" valid !empty(description)
         @ 05,19 get typ         pict "@!" valid typ $ "A O" .and. !empty(typ)
         Read
         SET(_SET_ESCAPE,.T.)
         setcursor(oldcursor)

     Choice := Alert("Save the new entries?",{"Save","Cancel"})

    If Choice == 1
     If !neterr()
         pycd->(dbappend())
      If pycd->(dbrlock())
         Replace pycd->procode with paycode
         Replace pycd->prodesc with description
         Replace pycd->protype with typ
      Endif
     Endif
       Alert("Entry Succesfully Appended!",{"Okey"})
    Endif

       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 pycd->(dbclosearea())
 Return Nil



 Function Paycode_del()
 
 Local oldcursor   := setcursor()
 Local paycode     := space(04)
 Local description := space(30)
 Local getlist   := {}
 Local oldcolor
 Local Choice

 Local paycode_header := {"CODE","DESCRIPTION","TYPE"}
 Local paycode_pic    := {"XXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local paycode_fields := {1,2,3}

 Local pycd  := "f:\arunlib\a999pycd.dbf"
 Local pycdi := "f:\arunlib\cdx\a999pycd.cdx"


 dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
 dbsetindex(pycdi)
 set order to tag py_code
 SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

  pycd->(dbgotop())

  @ 03,19 get paycode Pict "@!"
    Read

   Do Case
      Case Lastkey() == K_ESC
         Exit
      Case Empty(paycode)
         set order to tag py_desc
         _2GBROW(1,5,22,75,@paycode,paycode_header,paycode_fields,paycode_pic,1)
         set order to tag py_code
         loop
      Case pycd->(dbseek(upper(paycode))) == .F.
         Alert("Payment Code Not Found! ",{"Retry"})
         paycode := space(04)
         loop

      Case pycd->(dbseek(upper(paycode))) == .T.
         @ 03,19 say pycd->procode pict "@!"          Color("GR+/B")
         @ 04,19 say pycd->prodesc pict "@!"          Color("GR+/B")
         @ 05,19 say pycd->protype pict "@!"          Color("GR+/B")
         setcursor(oldcursor)
       Choice := Alert("Sure to delete?",{"Cancel","Delete"})

        If Choice == 2
           If !neterr()
             If pycd->(dbrlock())
                pycd->(dbdelete())
                pycd->(dbunlock())
           Endif
          Endif
         Alert("Record Succesfully Deleted!",{"Okey"})
        Endif
       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 pycd->(dbclosearea())
 Return Nil

Function Paycode_Mod()
 
 Local oldcursor    := setcursor()
 Local paycode      := space(04)
 Local description  := space(30)
 Local typ          := space(01)
 Local getlist      := {}
 Local oldcolor
 Local Choice

 Local paycode_header := {" CODE","DESCRIPTION","TYPE"}
 Local paycode_pic    := {"XXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X"}
 Local paycode_fields := {1,2,3}

 Local pycd     := "F:\arunlib\a999pycd.dbf"
 Local pycdi    := "F:\arunlib\cdx\a999pycd.cdx"

 dbusearea(.T.,"DBFCDX",pycd,"pycd",.T.,.F.)
 dbsetindex(pycdi)
 set order to tag py_code

  SET(_SET_CURSOR,SC_SPECIAL1)

 oldcolor := setcolor()
 setcolor("BG/BG,W+/RB,,,GR+/B")
 Do While .T.

  @ 23,01 say PADR(" ESC - Previous    Blank Entry - Prompt ",78,"") Color("N/W+")

    pycd->(dbgotop())
  @ 03,19 get paycode Pict "@!"
    Read

   Do Case
      Case Lastkey() == K_ESC
         Exit
      Case Empty(paycode)
         set order to tag py_desc
         _2GBROW(1,5,22,75,@paycode,paycode_header,paycode_fields,paycode_pic,1)
         set order to tag py_code
         loop
      Case pycd->(dbseek(upper(paycode))) == .F.
         Alert("Payment Code  Not Found Pls. Retry Again! ",{"Retry"})
         paycode := space(04)
         loop

      Case pycd->(dbseek(upper(paycode))) == .T.
         paycode     := pycd->procode
         description := pycd->prodesc
         typ         := pycd->protype

         SET(_SET_ESCAPE,.F.)
         @ 03,19 get paycode     pict "@!" valid !empty(paycode)
         @ 04,19 get description pict "@!" valid !empty(description)
         @ 05,19 get typ         pict "@!" valid typ $ "A O" .and. !empty(typ)
         Read
         SET(_SET_ESCAPE,.T.)

         setcursor(oldcursor)

     Choice := Alert("Save the modified records?",{"Save","Cancel"})

    If Choice == 1
     If !neterr()
      If pycd->(dbrlock())
         pycd->procode  := paycode
         pycd->prodesc  := description
         pycd->protype  := typ
         pycd->(dbunlock())
      Endif
     Endif
       Alert("Record Succesfully Modified!",{"Okey"})
    Endif
       Exit
   Endcase
 Enddo

 setcolor(oldcolor)
 @ 03,03 Clear to 08,78
 pycd->(dbclosearea())
 Return Nil


                                                       
