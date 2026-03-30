// UCLM library files
// All common routine are store on this area
// Written by    : Edgar J. Esguerra
//               : Leonardo E. Hoyla Jr.
// Primary Usage : UCLM application and program development
// Last Update   : December 15, 2000

# include "INKEY.CH"
# include "DBINFO.CH"
# include "BOX.CH"
# include "SETCURS.CH"

// Function uses to draw the menu selection on the screen
//*------------------------------------------------------------------------*//
// Parameters   : Y = Start Row
//              : X = Start Colum
//              : Menu_Title = Title of the menu
//              : Menulist   = Array of menu selection (items)
//              : Menuopr    = Array of executable routine to the menu
//                             selection
// Return Value : None
//*------------------------------------------------------------------------*//

 Function Menu(y,x,Menu_title,Menulist,Menu_operation)

 Local oldcursor, oldscreen,oldcolor,oldrow,oldcolumn
 Local keyboard_code := 1
 Local focusitem, oldfocusitem
 Local index,oldindex, counter,str_widest
 Local nboxleft     := 0
 Local nboxtop      := 0
 Local nboxright    := 0
 Local nboxbottom   := 0
 Local amenu        := Aclone(Menulist)
 Local left_mar     := 2
 Local right_mar    := 2
 Local in_array     := 0
 Local hotkey       := {}


 Asize(hotkey,len(Menulist))

 For counter := 1 to Len(Menulist)

   // Setup the options of the array structures
      Asize(amenu[counter],4)

   // Initialized the array element to first array amenu[x,1]
      amenu[counter,1] := amenu[counter,1]

   // Get the Hotkey Location within the string
      amenu[counter,2] := AT("@",amenu[counter,1])

   // Store the hotkey to hotkey array
      amenu[counter,3] := substr(amenu[counter,1],amenu[counter,2]+1,1)
      hotkey[counter]  := amenu[counter,3]

   // Remove the hotkey marker
      amenu[counter,1] := stuff(amenu[counter,1],amenu[counter,2],1,"")

  Next

   // Determine the widest string among array elements

      str_widest := 0
      For counter := 1 to Len(Menulist)
          If Len(amenu[counter,1]) > str_widest
             str_widest := Len(amenu[counter,1])
          Endif
      Next

   // Compare the widest string to menu title , whoever is the longest
   // will be used for frame

       If len(Menu_title)  > str_widest
          str_widest := Len(Menu_title)
       Endif

   // Pad all the elements of menu item to make them equally wide

       For counter := 1 to Len(Menulist)
        amenu[counter,1] := PADR(amenu[counter,1],str_widest," ")
       Next

   // Initialize the box frame

      nboxtop    := y
      nboxleft   := x
      nboxbottom := nboxtop       // start row
      nboxbottom += 1             // Menu Title
      nboxbottom += 1             // Menu title and menu elements separator
      nboxbottom += Len(Menulist) // Menu elements
      nboxbottom += 1             // end  row
      nboxright  := (nboxleft+str_widest+left_mar+right_mar)-1

   
  SET(_SET_CURSOR, SC_NONE)

 // Save the Current Screen Settings
   oldcursor  := setcursor()
   oldcolor   := setcolor()
   oldrow     := row()
   oldcolumn  := col()

  // Draw the frame and display the menu elements
     oldscreen := SaveScr(nboxtop,nboxleft,nboxbottom,nboxright,.T.)
//     oldscreen := shadowbox(nboxtop,nboxleft,nboxbottom,nboxright)
     @ nboxtop,nboxleft clear to  nboxbottom,nboxright
     @ nboxtop,nboxleft to nboxbottom,nboxright  color "W/B+"
       nboxtop++
     
     @ nboxtop,nboxleft+1 Say PADC(Menu_title,str_widest+right_mar," ");
     color  "GR+/R"
       nboxtop++
     @ nboxtop,nboxleft say;
     Chr(195)+Replicate(Chr(196),(str_widest+left_mar+right_mar)-2)+chr(180);
     color "W/B+"
       nboxtop++

  // Display the Element and the Hotkey
    For Counter := 1 to Len(Menulist)
    @ nboxtop,nboxleft+1 Say PADC(" ",str_widest+right_mar," ");
    color "W/B+"
    @ nboxtop,nboxleft+left_mar say amenu[counter,1] color  "W/B+"
      amenu[counter,4] := nboxtop

    @ nboxtop,nboxleft+left_mar+amenu[counter,2]-1 say amenu[counter,3] ;
      color "GR+/B+"
      nboxtop++
   Next

   index    := 1
   oldindex := 0

Do while keyboard_code <> 0

  If index != oldindex
   @ amenu[index,4],nboxleft+1 say chr(16)+amenu[index,1]+chr(17) color "W+/BG"
     oldindex := index
  Endif

   If keyboard_code == K_ENTER
      if index != Len(Menulist)
         Eval(Menu_operation[index])
         keyboard_code := 1
         index := index
      else
        exit
      endif
   Endif

// Wait for a keystroke
keyboard_code := wait_key()

Do case

   case keyboard_code == K_ESC
        exit

   case keyboard_code == K_DOWN
   @ amenu[oldindex,4],nboxleft+1 say chr(255)+amenu[oldindex,1]+chr(255) color "W/B+"
   @ amenu[oldindex,4],nboxleft+left_mar+amenu[oldindex,2]-1 say ;
     amenu[oldindex,3] color "GR+/B+"

     index++
      if index > Len(Menulist)
         index := 1
      Endif

   case keyboard_code == K_UP
   @ amenu[oldindex,4],nboxleft+1 say chr(255)+amenu[oldindex,1]+chr(255) color "W/B+"
   @ amenu[oldindex,4],nboxleft+left_mar+amenu[oldindex,2]-1 say ;
     amenu[oldindex,3] color "GR+/B+"

     index--
      if index < 1
         index := Len(Menulist)
      Endif

   case keyboard_code == K_ENTER
      if index != Len(Menulist)
         Eval(Menu_operation[index])
         keyboard_code := 1
         index := index
      else
        exit
      endif

   case Isalpha(chr(keyboard_code))
        in_array := is_hot(chr(keyboard_code),@hotkey)
           If in_array != 0
              index := in_array
                if index != oldindex
                @ amenu[oldindex,4],nboxleft+1 say chr(255)+amenu[oldindex,1]+chr(255) color "W/B+"
                @ amenu[oldindex,4],nboxleft+left_mar+amenu[oldindex,2]-1 say ;
                  amenu[oldindex,3] color "GR+/B+"
                endif
                keyboard_code := K_ENTER
          Endif
Endcase

Enddo


// Return the oldscreen Settings
   @ nboxtop,nboxleft clear to  nboxbottom,nboxright
//   byebyebox(oldscreen)
   RestScr(oldscreen)
   setcursor(oldcursor)
   setcolor(oldcolor)
   devpos(oldrow,oldcolumn)

Return Nil

//-------------------------------------------------------------------------*//
// Function uses to determine either the inputted keys is hotkey or not
//*------------------------------------------------------------------------*//
// Parameters   : key      = input key
//              : arrlist  = array of possible hotkeys
// Return Value : index    = of keys if found otherwise 0
//*------------------------------------------------------------------------*//
  Function is_hot(key,arrlist)
    Local Xfound := .F.
    Local Index  := 0
    Local I      := 1

   Do While (I <= Len(arrlist)) .AND. (!Xfound)
      If Upper(key) == Upper(arrlist[I])
       Index  := I
       Xfound := .T.
      Else
       I++
      Endif

      If !Xfound
         Index := 0
      Endif
   Enddo
  Return Index

//-------------------------------------------------------------------------*//
// Function uses to wait keys with screen saver
//*------------------------------------------------------------------------*//
// Parameters   : None
// Return Value : Last keyboard key that been pressed
//*------------------------------------------------------------------------*//
 Function wait_key()
 Local key
 Do while  .T.
     key := inkey(900)
    if key == 0
//        blankscr(1)
        loop
     else
         exit
    endif
 enddo
 Return Key
//*----------------------------------------------------------------------*//

//-------------------------------------------------------------------------*//
// Function use to browse the database file
//*------------------------------------------------------------------------*//
// Parameters   : Y             - Start Row
//              : X             - Start Column
//              : Y2            - End Row
//              : X2            - End Column
//              : Args          - Arguments Pointer Variable
//              : Header        - Header Name
//              : Field_Nummber - The working fields
//              : Field_Picture - Fields Picture
//              : Return_Field  - Returning Fields


Function GBROW(Y,X,Y2,X2,Args,Header,Field_number,Field_picture,Return_field)
 // Browse Variable

    Local abrowse
    Local bColumn

 // Working Variable

    Local oldcursor
    Local oldcolor
    Local oldscreen
    Local Counter, Key_counter := 1 , c_col := x+16
    Local KEY, Search_key := ""
    Local nrecno

 // Save the old settings

     oldcolor    := setcolor()
     oldcursor   := setcursor()
     oldscreen   := savescreen(y,x,y2+1,x2)

    setcolor("W+/B")
//   oldscreen := shadowbox(y,x,y2+1,x2)
     oldscreen := SaveScr(y,x,y2+1,x2,.T.)
     @ y2-2,x+2 say "SEARCH KEY => " color("GR+/B")
     @ y2-1,x+2 say "[Arrow Up] [Arrow Down] - Navigate  ESC- Previous Enter - Accept"  color("GR+/B")
     @ y2-0,x+2 say "[Page Up] [Page Down] - Scroll Screen                           "  color("GR+/B")
    setcolor(oldcolor)

      abrowse := TBrowseDB(y+1,x+1,y2-3,x2-1)
      abrowse:headsep   := "Ä"
      abrowse:colsep    := "³"
      abrowse:footsep   := "Ä"
      abrowse:colorspec := "W+/B,W+/RB"

     For Counter := 1 to Len(Header)
         bcolumn         := TbcolumnNew()
         bcolumn:Heading := Header[Counter]
         bcolumn:block   := fieldblock(field(field_number[Counter]))
         bcolumn:picture := field_picture[Counter]
         abrowse:addcolumn(bcolumn)
         abrowse:ColorRect({abrowse:rowpos,1,abrowse:rowpos,abrowse:colcount},{"GR+/W,B+/W"})
     Next

     set(_SET_CURSOR, SC_NONE)

    dbgotop()
    Do While .T.

     Do While !abrowse:stabilize() .and. ( key := inkey() ) == 0
     Enddo

        If abrowse:Stable
           Key := wait_key()
        Endif

    DO CASE
      CASE Key == K_ESC
           Exit
      CASE Key == K_ENTER
           Exit
      CASE Key == K_UP

              Search_key   :=  ""
              Key_counter  := 1
              c_col        := x+16
              @ y2-2,c_col say space(x2-c_col)  color("W+/B")

              If abrowse:hittop()
                 tone( 350, 3)
                 abrowse:gobottom()
              Else
                 abrowse:up()
              Endif


      CASE Key == K_DOWN

              Search_key  :=  ""
              Key_counter := 1
              c_col       := x+16
              @ y2-2,c_col say space(x2-c_col)  color("W+/B")

              If abrowse:hitbottom()
                 tone( 350, 3)
                 abrowse:gotop()
              Else
                 abrowse:down()
              Endif

      CASE Key == K_PGUP

                 Search_key  := ""
                 Key_counter := 1
                 c_col       := x+16
                 @ y2-2,c_col say space(x2-c_col) color("W+/B")
                 abrowse:pageup()

      CASE Key == K_PGDN

                 Search_key  := ""
                 Key_counter := 1
                 c_col       := x+16
                 @ y2-2,c_col say space(x2-c_col) color("W+/B")
                 abrowse:pagedown()

      CASE WAS_IN1(CHR(Key))  == .T.


               Search_key := Stuff(Search_key,key_counter,1,chr(Key))
               oldcolor   := setcolor()
               setcolor("W+/B")
               @ y2-2,c_col say Upper(Chr(Key))
                      c_col++
                      Key_counter++
               setcolor(oldcolor)

               seek Upper(Search_key)

                    If Found()
                         nrecno := Recno()
                         Do while !abrowse:stabilize()
                         Enddo

                         If abrowse:stable
                            go nrecno
                            abrowse:RefreshAll()
                         Endif
                    Endif


      CASE Key == K_BS .And. Empty(Search_Key)
                      Key_Counter := 1
                      c_col       := x+16
                      Search_Key  := ""

      CASE Key == K_BS .And. !Empty(Search_key)

                      If Key_Counter < 2
                         Key_Counter := 1
                         c_col       := x+16
                         Search_Key  := ""
                      Else
                         Key_Counter--
                         c_col--
                      Endif

                      Search_key := Stuff(Search_Key,Key_counter,1,'')
                      oldcolor   := setcolor()
                      setcolor("W+/B")
                      @ y2-2,c_col say " "
                      setcolor(oldcolor)

                      seek UPPER(Search_Key)

                      If Found()
                         nrecno := Recno()
                         Do while !abrowse:stabilize()
                         Enddo

                        If abrowse:stable
                           go nrecno
                           abrowse:refreshall()
                        Endif
                      Endif
    ENDCASE
    Enddo

     If Lastkey() == K_ENTER
       // args := Eval(Fieldblock(field(Return_Field)))
        Getactive():Varput(Eval(Fieldblock(field(Return_Field))))
      //keyboard chr(13)
     Endif

 // Return the old settings
     setcolor(oldcolor)
     setcursor(oldcursor)
     RestScr(oldscreen)
 Return Nil


/*----------------------------------------------------------------------------*/
Function _2GBROW(Y,X,Y2,X2,Args,Header,Field_number,Field_picture,Return_field)
 // Browse Variable

    Local abrowse
    Local bColumn

 // Working Variable

    Local oldcursor
    Local oldcolor
    Local oldscreen
    Local Counter, Key_counter := 1 , c_col := x+16
    Local KEY, Search_key := ""
    Local nrecno

 // Save the old settings

     oldcolor    := setcolor()
     oldcursor   := setcursor()
     oldscreen   := savescreen(y,x,y2+1,x2)

    setcolor("W+/B")
//   oldscreen := shadowbox(y,x,y2+1,x2)
     oldscreen := SaveScr(y,x,y2+1,x2,.T.)
     @ y2-2,x+2 say "SEARCH KEY => " color("GR+/B")
     @ y2-1,x+2 say "[Arrow Up] [Arrow Down] - Navigate  ESC- Previous Enter - Accept"  color("GR+/B")
     @ y2-0,x+2 say "[Page Up] [Page Down] - Scroll Screen                           "  color("GR+/B")
    setcolor(oldcolor)

      abrowse := TBrowseDB(y+1,x+1,y2-3,x2-1)
      abrowse:headsep   := "Ä"
      abrowse:colsep    := "³"
      abrowse:footsep   := "Ä"
      abrowse:colorspec := "W+/B,W+/RB"

     For Counter := 1 to Len(Header)
         bcolumn         := TbcolumnNew()
         bcolumn:Heading := Header[Counter]
         bcolumn:block   := fieldblock(field(field_number[Counter]))
         bcolumn:picture := field_picture[Counter]
         abrowse:addcolumn(bcolumn)
         abrowse:ColorRect({abrowse:rowpos,1,abrowse:rowpos,abrowse:colcount},{"GR+/W,B+/W"})
     Next

     set(_SET_CURSOR, SC_NONE)

    dbgotop()
    Do While .T.

     Do While !abrowse:stabilize() .and. ( key := inkey() ) == 0
     Enddo

        If abrowse:Stable
           Key := wait_key()
        Endif

    DO CASE
      CASE Key == K_ESC
           Exit
      CASE Key == K_ENTER
           Exit
      CASE Key == K_UP

              Search_key   :=  ""
              Key_counter  := 1
              c_col        := x+16
              @ y2-2,c_col say space(x2-c_col)  color("W+/B")

              If abrowse:hittop()
                 tone( 350, 3)
                 abrowse:gobottom()
              Else
                 abrowse:up()
              Endif


      CASE Key == K_DOWN

              Search_key  :=  ""
              Key_counter := 1
              c_col       := x+16
              @ y2-2,c_col say space(x2-c_col)  color("W+/B")

              If abrowse:hitbottom()
                 tone( 350, 3)
                 abrowse:gotop()
              Else
                 abrowse:down()
              Endif

      CASE Key == K_PGUP

                 Search_key  := ""
                 Key_counter := 1
                 c_col       := x+16
                 @ y2-2,c_col say space(x2-c_col) color("W+/B")
                 abrowse:pageup()

      CASE Key == K_PGDN

                 Search_key  := ""
                 Key_counter := 1
                 c_col       := x+16
                 @ y2-2,c_col say space(x2-c_col) color("W+/B")
                 abrowse:pagedown()

      CASE WAS_IN1(CHR(Key))  == .T.


               Search_key := Stuff(Search_key,key_counter,1,chr(Key))
               oldcolor   := setcolor()
               setcolor("W+/B")
               @ y2-2,c_col say Upper(Chr(Key))
                      c_col++
                      Key_counter++
               setcolor(oldcolor)

               seek Upper(Search_key)

                    If Found()
                         nrecno := Recno()
                         Do while !abrowse:stabilize()
                         Enddo

                         If abrowse:stable
                            go nrecno
                            abrowse:RefreshAll()
                         Endif
                    Endif


      CASE Key == K_BS .And. Empty(Search_Key)
                      Key_Counter := 1
                      c_col       := x+16
                      Search_Key  := ""

      CASE Key == K_BS .And. !Empty(Search_key)

                      If Key_Counter < 2
                         Key_Counter := 1
                         c_col       := x+16
                         Search_Key  := ""
                      Else
                         Key_Counter--
                         c_col--
                      Endif

                      Search_key := Stuff(Search_Key,Key_counter,1,'')
                      oldcolor   := setcolor()
                      setcolor("W+/B")
                      @ y2-2,c_col say " "
                      setcolor(oldcolor)

                      seek UPPER(Search_Key)

                      If Found()
                         nrecno := Recno()
                         Do while !abrowse:stabilize()
                         Enddo

                        If abrowse:stable
                           go nrecno
                           abrowse:refreshall()
                        Endif
                      Endif
    ENDCASE
    Enddo

     If Lastkey() == K_ENTER
        args := Eval(Fieldblock(field(Return_Field)))
       // Getactive():Varput(Eval(Fieldblock(field(Return_Field))))
      keyboard chr(13)
     Endif

 // Return the old settings
     setcolor(oldcolor)
     setcursor(oldcursor)
     RestScr(oldscreen)
 Return Nil



/*----------------------------------------------------------------------------*/
//** Function WAS_IN1
//** The Function is used to determine either the inputted key is within
//** the range of valid keys in the keyboard

    FUNCTION WAS_IN1 ( KEY )
    LOCAL I    := 32
    LOCAL FLAG := .F.
      DO WHILE I <= 126 .AND.  !FLAG
          IF KEY == CHR(I)
             FLAG := .T.
             EXIT
         ELSE
            I++
         ENDIF
     ENDDO
    RETURN  FLAG
/*-----------------------------------------------------------------------------*/


// Function used to determine either the student number is valid or not
// valid if the number is based on modulus 10 check format.

 Function Valid_id(cidno)
 Local fs, d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd,chd1
 Local flag := .F.

  fs  := left(cidno,7)
  d1  := substr(cidno,1,1)
  d2  := val(substr(cidno,2,1))
  d3  := substr(cidno,3,1)
  d4  := val(substr(cidno,4,1))
  d5  := substr(cidno,5,1)
  d6  := val(substr(cidno,6,1))
  d7  := substr(cidno,7,1)
  s1  := val(d1)*2
  s1  := transform(s1,"99")
  s1  := val(substr(s1,1,1))+val(substr(s1,2,1))
  s2  := val(d3)*2
  s2  := transform(s2,"99")
  s2  := val(substr(s2,1,1))+val(substr(s2,2,1))
  s3  := val(d5)*2
  s3  := transform(s3,"99")
  s3  := val(substr(s3,1,1))+val(substr(s3,2,1))
  s4  := val(d7)*2
  s4  := transform(s4,"99")
  s4  := val(substr(s4,1,1))+val(substr(s4,2,1))

  chd := transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
  chd := int(10-val(chd))

  if chd > 9
     chd := 0
  endif

  chd1 := val(right(cidno,1))

  if chd1 == chd
     Flag := .T.
  else
     Flag := .F.
  endif
 Return Flag
//-----------------------------------------------------------------------------*

// Function HIDE
// Function used to hide the keyboard input that prevent the user to read it
// usually use for password protection
// Written by : Edgar J. Esguerra
// Date       : 01-24-2001

Function Hide(y,x,text_len,args)
Local counter   := 1
Local Key
Local xx        := x
Local l_oldcol  := x
Local oldcol    := col()
Local oldrow    := row()
Local pass      := " "
Local oldcolor
Local oldcursor := setcursor()

   SET(_SET_CURSOR, SC_NONE)
   setpos(y,x)

   oldcolor := setcolor()
   setcolor("W+/B,W+/B,,,GR+/B")
   @ y,x say replicate(" ",text_len)

   Do while Key  != K_ENTER
      Key := wait_key()

      Do Case
         Case Key == K_ESC
              pass :=""
              Exit
         Case Key == K_ENTER
              Exit
         Case Key == K_BS
              If counter < 2
                 counter := 1
                 x := l_oldcol
              Else
                 --counter
                 --x
              Endif

          pass := stuff(pass,counter,1,'')
          setpos(y,x)
          @ y,x say "ÿ"
          loop
      Endcase

          pass := stuff(pass,counter,1,chr(key))
          @ y,x say "*"
          x++
          counter++

          If counter > text_len
             ? chr(7)
             exit
          Endif
   Enddo
   @ y,xx say replicate(' ',text_len)  Color("GR+/B")
   @ y,xx say replicate('*',counter-1) Color("GR+/B")

    args := trim(UPPER(pass))

// Restore  the old setting
   setpos(oldrow,oldcol)
   setcolor(oldcolor)
   setcursor(oldcursor)

Return Nil


//----------------------------------------------------------------------------

// Function Password
// Accepts User name and Password.
// The Routine will verify either the level access of the program will
// match to the level of user who wants to run the program.

Function CPassword(level,username)
Local oldcolor  := setcolor()
Local oldscreen
Local oldcursor := setcursor()
Local oldrow    := row()
Local oldcol    := col()
Local user_nam  := space(24)
Local user_pass := space(01)
Local getlist   := {}
Local Flag      := .F.
Local passname  := ""
Local pyus       := "F:\arunlib\a999pyus.dbf"
Local pyusi      := "F:\arunlib\cdx\a999pyus.cdx"

dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
dbsetindex(pyusi)
set order to tag  password
                          
SET (_SET_CURSOR, SC_NONE)
SET (_SET_CANCEL, .F.)
SET (_SET_SOFTSEEK,.F.)
SET EXACT ON
   setcolor("W+/W,W+/RB,,,GR+/B")
//   oldscreen := shadowbox(10,25,14,50)
   oldscreen := SaveScr(10,25,14,50,.T.)
   @ 11,26 say PADC("PASSWORD PLEASE!",24," ") COLOR "W+/B"
   @ 12,25 say "Û"+replicate("Ü",24)+"Û"
   hide(13,26,len(user_nam),@user_nam)
   setcolor(oldcolor)
   pyus->(dbgotop())

    Do Case
       Case Empty(user_nam)
            Flag := .F.
       Case pyus->(dbseek(upper(user_nam))) == .T.
                  passname := pyus->password

             Do Case
                Case len(upper(trim(user_nam))) != len(upper(trim(passname)))
                     Alert("Invalid Username! ",{"Cancel"})
                     Flag := .F.
                Case Ascan(Level,val(pyus->level),1,Len(Level)) == 0
                     Alert("Your Rights is not sufficient to access this routine! ",{"Cancel"})
                     Flag := .F.
                Otherwise
                     username := pyus->chshrtnam
                     Flag := .T.
             Endcase
        Otherwise
            Alert("Invalid Username! ",{"Cancel"})
            Flag := .F.
    Endcase

   pyus->(dbclosearea())
   passname := ""
// Restore the old settings
   SET EXACT OFF
   SET (_SET_SOFTSEEK,.T.)
   SET (_SET_CANCEL, .T.)
   RestScr(oldscreen)
   setcolor(oldcolor)
   setcursor(oldcursor)
   setpos(oldrow,oldcol)
Return Flag


//Function for cashier password
//

//----------------------------------------------------------------------------

// Function CPassword
// Accepts User name and Password.
// The Routine will verify either the level access of the program will
// match to the level of user who wants to run the program.

//Function CPassword(level,username)
//Local oldcolor  := setcolor()
//Local oldscreen
//Local oldcursor := setcursor()
//Local oldrow    := row()
//Local oldcol    := col()
//Local user_pwd  := space(08)
//Local getlist   := {}
//Local Flag      := .F.

//Local pyus      := "F:\arunlib\a999pyus.dbf"
//Local pyusi     := "F:\arunlib\cdx\a999pyus.cdx"

//dbusearea(.T.,"DBFCDX",pyus,"pyus",.T.,.F.)
//dbsetindex(pyusi)
//set order to tag  password

//SET (_SET_CURSOR, SC_NONE)
//SET (_SET_CANCEL, .F.)
//SET (_SET_SOFTSEEK,.F.)
//   setcolor("W+/W,W+/RB,,,GR+/B")
//   oldscreen := shadowbox(10,25,14,50)
//   oldscreen := SaveScr(10,25,14,50,.T.)
//   @ 11,26 say PADC("PASSWORD PLEASE!",24," ") COLOR "W+/B"
//   @ 12,25 say "Û"+replicate("Ü",24)+"Û"
//   hide(13,26,len(user_pwd),@user_pwd)
//   setcolor(oldcolor)

//  IF Empty(user_pwd)
//     Flag := .F.
//   Else

//     pyus->(dbgotop())

//    If pyus->(dbseek(upper(trim(user_pwd)))) == .T.

//       If Ascan(Level,val(pyus->level),1,Len(Level)) != 0
//          username := pyus->chshrtnam
//          Flag := .T.
//       Else
//          Alert("Your Rights is not sufficient to access this routine! ",{"Cancel"})
//          Flag := .F.
//       Endif
//    Else
//        Alert("Invalid Password Access Denied! ",{"Exit"})
//        Flag := .F.
//    Endif
// Endif

//   pyus->(dbclosearea())
// Restore the old settings
//   SET (_SET_SOFTSEEK,.T.)
//   SET (_SET_CANCEL, .T.)
//   RestScr(oldscreen)
//   setcolor(oldcolor)
//   setcursor(oldcursor)
//   setpos(oldrow,oldcol)
//Return Flag

 Function is_valid_copy()

  Local retval := .f.

          if !file("c:\windows\system\clipsntx.dll")
            Alert("This is illegal copy taken without permission from UCLM EDP",{"Cancel"})
            Alert("PLL required to activate this program",{"Cancel"})
             retval := .f.
          else
             retval := .t.
            getenv("Activate c:\windows\system\clipsntx.dll")
          Endif

 Return Retval
