* Program      : LIBRARY.PRG - Library
* Author       : Randy F. Santizo (c) August 1996

#Include "Inkey.Ch"
#Include "Sixcdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

#Define TBMethods  { { K_DOWN,       { | b | b:Down()     } }, ;
                     { K_UP,         { | b | b:Up()       } }, ;
                     { K_PGDN,       { | b | b:PageDown() } }, ;
                     { K_PGUP,       { | b | b:PageUp()   } }, ;
                     { K_CTRL_PGUP,  { | b | b:GoTop()    } }, ;
                     { K_CTRL_PGDN,  { | b | b:GoBottom() } }, ;
                     { K_RIGHT,      { | b | b:Right()    } }, ;
                     { K_LEFT,       { | b | b:Left()     } }, ;
                     { K_HOME,       { | b | b:Home()     } }, ;
                     { K_END,        { | b | b:End()      } }, ;
                     { K_CTRL_LEFT,  { | b | b:PanLeft()  } }, ;
                     { K_CTRL_RIGHT, { | b | b:PanRight() } }, ;
                     { K_CTRL_HOME,  { | b | b:PanHome()  } }, ;
                     { K_CTRL_END,   { | b | b:PanEnd()   } }, ;
                     { K_ALT_C,      { || ActCalculator() } } }

Function ValidPass( cPassword )
Return USER->( DBSeek( Constring( cPassword, "C" ) ) )

/*

Value of cMode
    "C" - from text to encript
not "C" - from encript to text

*/

Function ConString( cString, cMode, nLen )
Local cEncript, nCtr, cAscii, nMulti1, nMulti2
Default nLen To Len( USER-> U_PASSWORD )
nMulti1 := If( cMode == "C", 01, -1 )
nMulti2 := If( cMode == "C", -1, 01 )
cEncript := ""
For nCtr = 1 To nLen
  cAscii := 0
  cAscii := Asc( SubStr( cString, nCtr, 1 ) ) + ( nMulti1 * 124 )
  If ( cAscii > 255 .And. cMode = "C" ) .Or. ;
     ( cAscii <   0 .And. ! cMode = "C" )
    cAscii := cAscii + ( nMulti2 * 255 )
  EndIf
  cEncript := cEncript + Chr( cAscii )
Next
Return ( cEncript )

*------------------------------------------------------------------------------*

Function CommandLine( cMsg, cColor )
Default cColor To If( ValType( MemVar-> ColorArray ) == "A", ;
                      MemVar-> ColorArray[04], SetColor() )
SetPos(24, 00); DispOut( cMsg, cColor )
Return ( Nil )

*-------------------------------------------------------------------------------

Function WherePrint( bPrint )
Local nRetVal := 0
/*
SelectMenu( { { 13, 29, "   Text File       ",,,, { || iif( txtfile( bprint, 17, 28 ), nretval := 1, ) },, }, ;
              { 14, 29, "   Local Printer   ",,,, { || iif( localprinter(bprint), nretval := 2,      ) },, }, ;
              { 15, 29, "   Console Printer ",,,, { || iif( consoleprinter(bPrint), nretval := 3,    ) },, } }, ;
            { || boxshadow( 12, 28, 16, 29 + 19, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[ 03 ] ) }, .T., ;
            "³            Ù - to select            ³            ESC - Previous             ³", MemVar-> ColorArray[ 03 ],,,,, ;
            GetTrigger( MemVar-> ColorArray[ 03 ] ) )
Return ( nRetVal )
*/

SelectMenu( { { 13, 29, "   Text File       ",,,, { || iif( txtfile( bprint, 17, 28 ), nretval := 1, ) },, }, ;
              { 14, 29, "   Local Printer   ",,,, { || iif( localprinter(bprint), nretval := 2,      ) },, } }, ;
            { || boxshadow( 12, 28, 15, 29 + 19, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[ 03 ] ) }, .T., ;
            "³            Ù - to select            ³            ESC - Previous             ³", MemVar-> ColorArray[ 03 ],,,,, ;
            GetTrigger( MemVar-> ColorArray[ 03 ] ) )
Return ( nRetVal )

Function TxtFile( bProcedure, nRow, nCol )
Local   GetList := {}, aLastScr := SaveScr( nRow, 00, 24, 79 ), nLastCursor := SetCursor( 1 ), ;
        lConfirm := Set( _SET_CONFIRM, .T. )
CommandLine( "³                               ESC - Previous                                 ³" )
BoxShadow( nRow, nCol, nRow + 02, nCol + 26, "ÛßÛÛÛÜÛÛ " )
DevPos(nRow + 01, nCol + 02); DevOut( " Output File :          " )
@ nRow + 01, nCol + 17 gGet MemVar->cSpoolTxt   Picture "@!S8" Valid ! Empty( MemVar->cSpoolTxt )
Read
SetCursor( nLastCursor )
Set( _SET_CONFIRM, lConfirm )
If LastKey() = K_ENTER
        Set Printer To ( Alltrim( MemVar-> cSpoolTxt ) )
        ProcPrinting( bProcedure, 1 )
        Set Printer To
        RestScr( aLastScr )
        Return ( .T. )
EndIf
RestScr( aLastScr )
Return ( .F. )

Function LocalPrinter( bProcedure )
Do While ! IsPrinter()
        If Fask( 10, "Local Printer not ready.", { " Retry ", " Cancel " }, MemVar-> ColorArray[05], Nil, ;
                "³                               ESC - Previous                                 ³" ) == 1
                Loop
        EndIf
        Return ( .F. )
EndDo
ProcPrinting( bProcedure, 2 )
Return ( .T. )

Function ConsolePrinter( bProcedure )
Local cpServer, cpQueue
cpServer := "UC_METC"
cpQueue  := "UC_METC"
n_splsrv(cpserver); n_splque(cpqueue)
n_banner( "" )
n_class( 1 )
n_spltmo( 1 )
n_splnoff( .T. )
n_spool( .T. )
do while ! isprinter()
        if fask( 10, "Console Printer not ready.", { " Retry ", " Cancel " }, memvar->colorarray[05], nil, ;
                "³                               ESC - Previous                                 ³" ) == 2
                loop
        endif
        n_spool( .f. )
        return ( .f. )
enddo
procprinting( bprocedure, 3 )
n_spool( .f. )
return ( .t. )

Function ProcPrinting( bProcedure, nDirection )
Local aLastScreen := SaveScr( 13, 00, 24, 79 ), nLastCursor := SetCursor( 0 ), bHandler
*BoxShadow( 13, 23, 17, 56, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[18] )
*DevPos(15, 24); DevOut( "Printing Reports, please wait...", "+*" + MemVar-> ColorArray[18] )
If nDirection = 2
        bHandler := ErrorBlock()
        ErrorBlock( { | e | PrintError( e, bHandler ) } )
        Begin Sequence
          Set Device To Printer
          SetPrc(00, 00)
          Eval( bProcedure )
        End Sequence
        ErrorBlock( bHandler )
Else
        Set Device To Printer
        SetPrc(00, 00)
        Eval( bProcedure )
EndIf
Set Device To Screen
RestScr( aLastScreen )
SetCursor( nLastCursor )
Return ( Nil )

Function PrintError( Err, bHandler )
#Include "ERROR.CH"
If Err:genCode == EG_PRINT
  Set Device To Screen
  Tone( 2000, 3 )
  Do While FAlert( "Printer error occur. Please check your printer.", { " Retry ", " Abort " }, MemVar-> ColorArray[ 5 ] ) = 1
    If IsPrinter()
      Set Device To Printer
      Return ( .T. )
    EndIf
    Tone( 2000, 3 )
  EndDo
  Break
Else
  Return ( Eval( bHandler, Err ) )
EndIf
Return ( Nil )

*-------------------------------------------------------------------------------
/*

nTop, nLeft, nBottom, nRight - Coordinates
acFields         - Array of file fields
acColHeader      - Array of column header
cHeadSep         - Head Separator
cColSep          - Column Separator
cFootSep         - Footing Separator
nKey             - Inkey value

*/

Function CreateBrowse( nTop, nLeft, nBottom, nRight, bFunction, acFields, ;
                       acColHeader, acHeadSep, acColSep, acFootSep, nKey )
Local oBrowser, nCtr, cVar, oColumn, nLastCursor := SetCursor( 0 )
Default nTop        To  0, ;
        nLeft       To  0, ;
        nBottom     To 24, ;
        nRight      To 79, ;
        bFunction   To { || Nil }, ;
        acHeadSep   To "ÄÂÄ", ;
        acColSep    To " ³ ", ;
        acFootSep   To "ÄÁÄ", ;
        nKey        To  0, ;
        acFields    To {}, ;
        acColHeader To {}
UpdateDate()
oBrowser = TBrowseDB( nTop, nLeft, nBottom, nRight )
oBrowser:HeadSep := acHeadSep
oBrowser:ColSep  := acColSep
oBrowser:FootSep := acFootSep
If( Empty( acFields ), AEval( DBStruct(), { |aFld|  AAdd( acFields,  aFld[1] ) } ), Nil )
For nCtr = 1 To Len( acFields )
  cVar := acFields[ nCtr ]
  oColumn := TBColumnNew( If( Empty( acColHeader), Nil, acColHeader[nctr] ), &( "{ || " + cVar + " } " ) )
  If ValType( acHeadSep ) == "A"
    oColumn:HeadSep := acHeadSep[nCtr]
    oColumn:ColSep  := acColSep[nCtr]
    oColumn:FootSep := acFootSep[nCtr]
  EndIf
  oBrowser:AddColumn( oColumn )
Next
oBrowser:AutoLite := .F.
oBrowser:Cargo    := { acFields, nKey, bFunction }
UpdateDate(); SetCursor( nLastCursor )
Return ( oBrowser )

Static Function Bound()
Return ( Sx_KeyData() >= Sx_SetScope( _TOP_SCOPE ) .And. Sx_KeyData() <= Sx_SetScope( _BOTTOM_SCOPE ) )

Function BrowseFile( oBrowser, axParam, bAddFunc, lEdit )
Local cFile := Alias(), bFunction, nFuncReturn, nKeyPressed, nRow, nCol, ;
      nMethodNo, bColor, bSetKey
Default bAddFunc To { || Nil }, ;
        lEdit    To .F.
bFunction          := oBrowser:Cargo[3]
nFuncReturn        := 1
oBrowser:ColorSpec := SetColor()
bColor = If( ! lEdit, { | aRect, aColor | oBrowser:ColorRect( aRect, aColor ) }, { || Nil } )
Eval( bAddFunc, oBrowser )
oBrowser:RefreshAll()
While nFuncReturn > 0 .And. nFuncReturn < 6
   While ! oBrowser:Stabilize()
   EndDo
   nRow := Row(); nCol := Col()
   BrowFunction( bFunction, oBrowser:Cargo[1], oBrowser, "N", axParam )
   Eval( bColor, { oBrowser:RowPos, 1, oBrowser:RowPos, oBrowser:RightVisible }, { 2, 2 } )
   UpdateDate()
   DevPos( nRow, nCol )
   nKeyPressed := Inkey( oBrowser:Cargo[2] )
   If ! ( nMethodNo := AScan( TBMethods, { | Elem | nKeyPressed = Elem[1] } ) ) == 0
     axParam[01] := ""
     If Eof() .And. Bof() .And. ! nMethodNo == 15
       oBrowser:GoTop()
       Loop
     EndIf
     If( ! nMethodNo == 15, Eval( bColor, { oBrowser:RowPos, 1, oBrowser:RowPos, oBrowser:RightVisible }, { 1, 2 } ), )
     oBrowser:RefreshCurrent()
     Eval( TBMethods[ nMethodNo, 2 ], oBrowser )
   ElseIf nKeyPressed == 0
     oBrowser:RefreshAll()
     axParam[01] := ""
   Else
     nFuncReturn := BrowFunction( bFunction, oBrowser:Cargo[1], oBrowser, "E", axParam )
     If nFuncReturn == 2
       oBrowser:RefreshAll()
     ElseIf nFuncReturn == 5
       oBrowser:RefreshCurrent()
     EndIf
     Select( cFile )
   EndIf
EndDo
UpdateDate()
Return ( nFuncReturn )

Static Function BrowFunction( bFunction, acFields, oBrowser, cExempt, acParam )
Local nFuncReturn := 1, nIndex
If ! bFunction = Nil
  nIndex := oBrowser:ColPos
  nFuncReturn := EVal( bFunction, FileMode( oBrowser, cExempt ), acFields, oBrowser, acParam )
ElseIf LastKey() = K_ESC
  nFuncReturn := 0
EndIf
Return ( nFuncReturn )

Static Function FileMode( oBrowser, cExempt )
Return ( If( LastRec() = 0     , 3, ;
         If( oBrowser:HitTop   , 1, ;
         If( oBrowser:HitBottom, 2, ;
         If( cExempt = "E"     , 4, 0 ) ) ) ) )

Function EditRefresh( oBrowser )
Local nRecNo := RecNo()
oBrowser:RefreshAll()
Do While ! oBrowser:Stabilize(); EndDo
Do While RecNo() <> nRecNo .And. ! Bof()
  oBrowser:Up()
  Do While ! oBrowser:Stabilize(); EndDo
EndDo
Return ( Nil )

Function BrowseBottom( b )
b:GoTop()
If( Bof() .And. Eof(), , b:GoBottom() )
Return ( Nil )

*-------------------------------------------------------------------------------
Function CentHead( nRow, cString, nCol1, nCol2, cColor )
Local nRetVal
Default nRow   To 0, ;
        nCol1  To 0, ;
        nCol2  To MaxCol(), ;
        cColor To SetColor()
setpos( nRow, nCol1 + ( nRetVal := TitlePos( cString, nCol2 - nCol1 ) ) ); dispout( cString, cColor )
Return ( nRetVal )

*-------------------------------------------------------------------------------
FUNCTION BoxShadow( TopRow, TopCol, BotRow, BotCol, xBox, cColor, cMessage, lShadow )
Local cLastColor := SetColor( If( cColor = Nil, SetColor(), cColor ) ), cBox
Default lShadow To .T.
cBox := DefineBox( TopRow, TopCol, BotRow, BotCol, 0, xBox, lShadow )
If ! Empty( cMessage )
   CentHead( TopRow, cMessage, TopCol, BotCol, FlipColor( SetColor() ) )
EndIf
SetColor( cLastColor )
Return ( cBox )

Function DefineBox( ntop, nleft, nbottom, nright, ndelay, cboxstring, ;
                    lshadow, ctitle, lcrossbar, cfooter )
  Local medver, medhor, dom, x, y, ttop, tbottom, tleft, tright, ret_val := {}

//ÄÄÄÄÄ establish defaults if not passed
default ntop to 0
default nleft to 0
default nbottom to maxrow()
default nright to maxcol()
default lshadow to .f.
default ctitle to []
default cboxstring to 1

lcrossbar := (lcrossbar != NIL)

//ÄÄÄÄÄ construct array containing coordinates & contents of screen
//ÄÄÄÄÄ area underneath this box - this can be used with byebyebox()

/*
ret_val := { ntop, nleft, nbottom + if(lshadow, 1, 0), ;
             nright + if(lshadow, 2, 0), savescreen(ntop, nleft, ;
             nbottom + if(lshadow, 1, 0), nright + if(lshadow, 2, 0)) }
*/

if iscolor() .and. ndelay > 0         // color monitor for full effect
   medver := int(((nbottom - ntop) + 1) / 2)   // determine vertical median
   medhor := int(((nright - nleft) + 1) / 2)   // determine horizontal median
   dom := max(medver, medhor)
   //ÄÄÄÄÄ determine dynamic box coordinates
   ttop := ntop + medver
   tbottom := nbottom - medver
   tleft := nleft + medhor
   tright := nright - medhor

*   AAdd( Ret_Val, SaveScr( nTop, nLeft, nBottom, nRight ) )

   //ÄÄÄÄÄ main loop -- draw box out from center
   for x = 1 to dom
*      AAdd( Ret_Val, SaveScr( ttop, tleft, tbottom, tright ) )
      DispBox( ttop, tleft, tbottom, tright, cboxstring )
      for y = 1 to ndelay              // slow down explosion as desired
      next

      //ÄÄÄÄÄ test for border and expand if required
      if x < medver
         ttop--
         tbottom++
      endif
      if x < medhor
         tleft--
         tright++
      endif
   next
endif

//ÄÄÄÄÄ draw outer box border
*AAdd( Ret_Val, SaveScr( nTop, nLeft, nBottom, nRight ) )
DispBox( ntop, nleft, nbottom, nright, cboxstring )

//ÄÄÄÄÄ draw shadow if called for and coordinates are valid
if lshadow .and. iscolor() .and. nbottom < maxrow() .and. nright < maxcol()-1
*   AAdd( Ret_Val, SaveScr( 00, nleft, nbottom + 1, nright + 2 ) )
   gfattr(ntop + 1, nright + 1, nbottom + 1, nright + 2, 8)
   gfattr(min(nbottom + 1, maxrow()-1), nleft + 1, nbottom + 1, nright + 2, 8)
endif

//ÄÄÄÄÄ draw title if requested
if len(ctitle) > 0
   box_title( ntop, nleft, nright, ctitle, cboxstring, lcrossbar )
endif

//ÄÄÄÄÄ draw footer if requested
if cfooter != NIL
   box_title( nbottom, nleft, nright, cfooter, cboxstring, .f. )
endif

return ( Ret_Val )

*-------------------------------------------------------------------------------
Function DynamicSearch( cSeekValue, oBrowser )
oBrowser:GoTop()
DBSeek( cSeekValue, .T. )
DevPos(Row(), Col() + 1)
If( Eof(), oBrowser:GoBottom(), )
Return ( Nil )

*-------------------------------------------------------------------------------
function falert( cMessage, acChoice, cColor, lAsk, cCmdLine )
Local MenuList := {}, aLastScr := SaveScr( 01, 00, 24, 79 ), cLastColor, ;
      acMessage := {}, nPos, nAdder := 0, nChoice, nCurrCol, ;
      nTop, nLeft, nBottom, nRight, nNoLine, nNoCol, nWidth
Default acChoice To { " Ok " }, ;
        cColor   To SetColor(), ;
        lAsk     To .T., ;
        cCmdLine To "³                               ESC - Previous                                 ³"
cLastColor := SetColor( cColor )
CommandLine( cCmdLine )
if(lask,Sound( 3000, 3 ),)
Do While ! ( nPos := AT( ";", cMessage ) ) = 0
        AAdd( acMessage, SubStr( cMessage, 1, nPos - 1 ) )
        cMessage := SubStr( cMessage, nPos + 1, Len( cMessage ) - nPos )
EndDo
AAdd( acMessage, cMessage )
nNoLine   := Len( acMessage )
nNoCol    := Len( acMessage[ HighLen( acMessage ) ] )
If ( nWidth := CountWidth( acChoice ) + ( Len( acChoice ) * 2 ) ) > nNoCol
     nAdder := Int ( ( nWidth - nNoCol ) / 2 )
     nNoCol := nWidth
EndIf
nTop      := StringCenter( nNoLine, 24 ) - 1
nLeft     := StringCenter( nNoCol,  80 ) - 2
nBottom   := nTop  + nNoLine + 3
nRight    := nLeft + nNoCol  + 3
BoxShadow( nTop + If( lAsk, 0, - 1 ), nLeft, nBottom + If( lAsk, 0, -1 ), nRight, "ÛßÛÛÛÜÛÛ ", cColor )
For nPos = 1 To Len( acMessage )
        setpos( nTop + nPos, nLeft + nAdder + 02 ); dispout( acMessage[ nPos ], cColor )
Next
nCurrCol := StringCenter( nWidth, nRight - nLeft ) + 2
If lAsk
        For nPos = 1 To Len( acChoice )
                @ nBottom - 1, nLeft + nCurrCol Prompt acChoice[nPos]
                nCurrCol := nCurrCol + Len( acChoice[nPos] ) + 2
        Next
        Menu To nChoice TriggerColor GetTrigger( cColor )
        SetColor( cLastColor )
        RestScr( aLastScr )
EndIf
Return ( nChoice )

Static Function HighLen( cArray )
Local nHighElement := 1, nCtr
For nCtr = 1 To Len( cArray )
  nHighElement := If( Len( cArray[nCtr] ) > Len( cArray[nHighElement] ), nCtr, nHighElement )
Next
Return ( nHighElement )

Static Function StringCenter( nNoLine, nMaxLine )
Return ( Int( ( nMaxLine - nNoLine ) / 2 ) )

Static Function CountWidth( acChoice )
Local nWidth := 0
AEval( acChoice, { | cPrompt | nWidth += Len( cPrompt ) } )
Return ( nWidth )

*-------------------------------------------------------------------------------
Function fask( nstartrow, cmessage, acchoice, ccolor, lask, ccmdline )
local   menulist := {}, alastscr := savescr( 01, 00, 24, 79 ), clastcolor, ;
        acmessage := {}, npos, nadder := 0, nchoice, ncurrcol, ;
        ntop, nleft, nbottom, nright, nnoline, nnocol, nwidth
default acchoice to { " Ok " }, ;
        ccolor   to setcolor(), ;
        lask     to .t., ;
        nstartrow to 0,;
        ccmdline to "³                               ESC - Previous                                 ³"
clastcolor := setcolor(ccolor)
commandline( ccmdline )
iif(lask,sound( 3000, 3 ),)
do while ! ( npos := at( ";", cmessage ) ) = 0
        aadd( acmessage, substr(cmessage, 1, nPos-1))
        cmessage := substr(cmessage, nPos+1, len(cmessage)-nPos)
enddo
aadd(acmessage,cmessage)
nnoline   := len(acmessage)
nnocol    := len(acmessage[highlen(acmessage)])
if (nwidth := countwidth(acchoice)+(len(acchoice)*2)) > nnocol
        nadder    := int((nwidth-nnocol)/2)
        nnocol    := nwidth
endif
ntop      := nstartrow
nleft     := stringcenter(nnocol,80)-2
nbottom   := ntop  + nnoline + 3
nright    := nleft + nnocol  + 3
boxshadow(ntop+iif( lAsk, 0, - 1 ), nleft, nbottom+iif(lask, 0, -1), nright, "ÛßÛÛÛÜÛÛ ", ccolor )
for npos = 1 to len(acmessage)
        setpos(ntop+npos, nleft+nadder+02); dispout(acmessage[npos], ccolor)
next
ncurrcol := stringcenter(nwidth, nright-nleft) + 2
if lask
        for npos = 1 to len(acchoice)
                @ nbottom-1, nleft+ncurrcol prompt acchoice[npos]
                ncurrcol += len(acchoice[npos]) + 2
        next
        menu to nchoice triggercolor gettrigger(ccolor)
        restscr(alastscr)
endif
setcolor( clastcolor )
return ( nchoice )

*-------------------------------------------------------------------------------
Function PagePrint( abText )
AEval( abText, { | bText | DevPos( PRow() + 1, 00 ), DevOut( Eval( bText ) ) } )
Return ( Nil )

*-------------------------------------------------------------------------------
Function DayDate( dDate )
Return ( CDow( dDate ) + Space( 9 - Len( CDow( dDate ) ) ) )

*-------------------------------------------------------------------------------
Function DisplayDate( dDate )
Return ( If( Empty( dDate ), Space( Len( Dtoc( dDate ) ) ), Dtoc( dDate ) ) )

*-------------------------------------------------------------------------------
Function MoveField( cSource, cTarget, acFSource, acFTarget )
Local nCtr
If acFSource = Nil .Or. Empty( acFSource )
  acFSource := {}
  AEval( (cSource)-> ( DBStruct() ), {|aField| AAdd( acFSource, aField[1] ) } )
EndIf
If acFTarget = Nil .Or. Empty( acFTarget )
  acFTarget := acFSource
EndIf
If ! Empty( acFSource ) .And. Len( acFSource ) = Len( acFTarget )
  For nCtr = 1 To Len( acFSource )
    (cTarget)-> ( Eval( FieldBlock( acFTarget[nCtr] ), (cSource)-> ( Eval( FieldBlock( acFSource[nCtr] ) ) ) ) )
  Next
  Return ( .T. )
EndIf
Return ( .F. )

*-------------------------------------------------------------------------------
Function ReCycle( nWaitState, cChar )
Local lRetVal := .F., nLastOrder := Sx_TagNo(), lDeleted := Set( _SET_DELETED, .F. )
Default nWaitState To 1, ;
        cChar      To "þ"
Sx_SetTagOrder( 1 )
DBSeek( cChar, .T. )
Do While ! Eof() .And. ( Deleted() .Or. SubStr( Sx_KeyData(), 1, Len( cChar ) ) = cChar )
  If ( lRetVal := Sx_RLock() )
    If( Deleted(), DBRecall(), )
    MoveInitial()
    Exit
  EndIf
  DBSkip( 1 )
EndDo
Set( _SET_DELETED, .T. )
If( ! lRetVal, ( lRetVal := AppBlank( nWaitState ) ), )
Sx_SetTagOrder( nLastOrder )
Return ( lRetVal )

Static Function MoveInitial()
Local aFields := {}, nCtr, xAnyType
AEval( DBStruct(), { | aField | AAdd( aFields, aField[1] ) } )
For nCtr = 1 To Len( aFields )
  xAnyType := Eval( FieldBlock( aFields[nCtr] ) )
  Do Case
    Case ValType( xAnyType ) = "C"
      Eval( FieldBlock( aFields[nCtr] ), " " )
    Case ValType( xAnyType ) = "D"
      Eval( FieldBlock( aFields[nCtr] ), Ctod( "  /  /  " ) )
    Case ValType( xAnyType ) = "L"
      Eval( FieldBlock( aFields[nCtr] ), .F. )
    Case ValType( xAnyType ) = "N"
      Eval( FieldBlock( aFields[nCtr] ), 0 )
  EndCase
Next
Return ( Nil )

*-------------------------------------------------------------------------------
Function CheckOrder( nOrder )
Return ( If( Sx_TagNo() = nOrder, "û", " " ) )

*-------------------------------------------------------------------------------
Function ChangeOrder( oBrowser, nLastOrder, nOrder )
Default nLastOrder To Sx_TagNo()
If ! nLastOrder = nOrder
  Sx_SetTagOrder( nOrder )
  ClearScope()
  oBrowser:GoTop()
EndIf
Return ( Nil )

*-------------------------------------------------------------------------------
Function ActCalculator()
Local cSetKeys := PushKeys(), aScr := SaveScr( 24, 00, 24, 79 ), ;
      nRow := Row(), nCol := Col(), abFunction := SaveKey( { K_F11, K_F12 } )
Private GFCALCCOL
MemVar-> GFCALCCOL := If( IsColor(), "+W/G", "+W/N" )
Commandline( "³    Ctrl+P - Paste    ³ Arrow Keys - Move Calculator ³     ESC - Previous     ³" )
ZapKeys()
Set Key K_CTRL_P to paste
PopCalc()
Set Key K_CTRL_P to
PopKeys( cSetKeys )
RestoreKey( abFunction )
RestScr( aScr )
DevPos( nRow, nCol )
Return ( Nil )

*-------------------------------------------------------------------------------
Function SaveKey( aKey )
Local nCtr, abFunction := {}, bSetKey
For nCtr = 1 To Len( aKey )
  If ! ( bSetKey := SetKey( aKey[nCtr] ) ) = Nil
    AAdd( abFunction, { aKey[nCtr], bSetKey } )
    SetKey( aKey[nCtr], Nil )
  EndIf
Next
Return ( abFunction )

*-------------------------------------------------------------------------------
Function RestoreKey( abFunction )
Local nCtr
For nCtr = 1 To Len( abFunction )
  SetKey( abFunction[nCtr][01], abFunction[nCtr][02] )
Next
Return ( Nil )

*-------------------------------------------------------------------------------
Function UpdateDate()
Local cColor := If( MemVar-> lColor, "W/+B,GR+/R+,,,W/+B", "N/W" ), ;
      nLastCursor := SetCursor( 0 )
OutExpr( 00, 38, DisplayDate( Date() ), cColor )
OutExpr( 00, 50, CDow( Date() ), cColor )
SetCursor( nLastCursor )
Return ( Nil )

*-------------------------------------------------------------------------------
Function TestColor()
Return ( IsColor() )

*-------------------------------------------------------------------------------
Function FillColorArray( lColor )
Local aPrvSetUp, bColorVar, cLastFile := Alias()
If ( aPrvSetUp := OpenWCheck( { { , , "COLOR", , _DBF_SHARED } } ) ) == Nil
  Return ( .F. )
EndIf
MemVar-> ColorArray := {}
bColorVar := If( lColor, { || COLOR-> CGA_CODE }, { || COLOR-> MONO_CODE } )
COLOR-> ( DBGoTop() )
COLOR-> ( DBEval( { || AAdd( MemVar-> ColorArray, Eval( bColorVar ) ) } ) )
CloseWCheck( aPrvSetUp, cLastFile )
Return ( .T. )

*-------------------------------------------------------------------------------
/*
axChoices     : Contains the row, column, prompt, messages, etc.
      axChoices[ eROW       ] : Row
      axChoices[ eCOL       ] : Column
      axChoices[ ePROMPT    ] : Prompt
      axChoices[ eMSG       ] : Message
      axChoices[ eMSGCOLOR  ] : Message color
      axChoices[ eWHEN      ] : When Block
      axChoices[ eACTION    ] : Action Block
      axChoices[ eTRIGCOLOR ] : Trigger color
      axChoices[ eDISPLAY   ] : Display
bExec         : Code block to execute before the menu starts.
lExit         : Menu exit after executing the specific code block if this
                value is true.
cCmdLine      : Command Message
cColor        : See Grumpfish Library
nInitial      : See Grumpfish Library
bEvent        : See Grumpfish Library
nTimeOut      : See Grumpfish Library
bExitEvent    : See Grumpfish Library
cTriggerColor : See Grumpfish Library
cLeft         : See Grumpfish Library
cRight        : See Grumpfish Library
lCenterMsg    : See Grumpfish Library
lClearMsg     : See Grumpfish Library
nMsgRow       : See Grumpfish Library
nMsgCol       : See Grumpfish Library

*/

#Define eROW         1
#Define eCOL         2
#Define ePROMPT      3
#Define eMSG         4
#Define eMSGCOLOR    5
#Define eWHEN        6
#Define eACTION      7
#Define eTRIGCOLOR   8
#Define eDISPLAY     9

Function SelectMenu( axChoices, bExec, lExit, cCmdLine, ;
                     cColor, nInitial, bEvent, nTimeOut, bExitEvent, ;
                     cTriggerColor, cLeft, cRight, lCenterMsg, lClearMsg, ;
                     nMsgRow, nMsgCol )
Local MenuList, aLastScr, nMenuChoice, nMaxPrompt := Len( axChoices ), nCtr, nEnd, ;
      cLastColor, aLastCmdLine := Nil, cLastMessage

Default bExec      To { || Nil }, ;
        lExit      To .F.
Default cColor     To SetColor(), ;
        nInitial   To 1, ;
        lCenterMsg To .T., ;
        lClearMsg  To .F.

cLastColor   := SetColor( cColor )
aLastScr     := SaveScr( axChoices[ 1, eROW ] - 1, ;
                         axChoices[ 1, eCOL ] - 1, ;
                         axChoices[ 1, eROW ] + nMaxPrompt + 2, ;
                         axChoices[ 1, eCOL ] + Len( axChoices[ 1, ePROMPT ] ) + 2 )
If ! cCmdLine == Nil
  aLastCmdLine := SaveScr( 24, 00, 24, 79 )
  CommandLine( cCmdLine )
EndIf

Eval( bExec )
nMenuChoice  := nInitial
Do While .T.
  UpdateDate()
  nMenuChoice := Lite_Menu2( axChoices, cColor, nMenuChoice, "nMenuChoice", ;
                        bEvent, nTimeOut, bExitEvent,  ;
                        cTriggerColor, cLeft, cRight,  ;
                        ! lCenterMsg, ! lClearMsg, nMsgRow, nMsgCol )
  If nMenuChoice == 0 .Or. ( ! nMenuChoice == 0 .And. lExit )
    Exit
  EndIf
EndDo
RestScr( aLastScr )
If( ! cCmdLine == Nil, RestScr( aLastCmdLine ), )
SetColor( cLastColor ); UpdateDate()
Return ( nMenuChoice )

*-------------------------------------------------------------------------------
Function RefreshScope( oBrowser, cFilter )
Default cFilter To Nil
If ! cFilter == Nil
  Sx_SetScope( _TOP_SCOPE, cFilter ); Sx_SetScope( _BOTTOM_SCOPE, cFilter )
EndIf
DBGoTop()
oBrowser:GoTop()
oBrowser:RefreshAll()
Do While ! oBrowser:Stabilize(); EndDo
Return ( Nil )

*-------------------------------------------------------------------------------
Function CreateABrowse( bData, bIndex, nTop, nLeft, nBottom, nRight, bFunction, aBlocks, ;
                       aHeadings, aHeadSep, aColSep, aFootSep, nKey )
Local nCtr, oABrowser, oColumn
Default nTop        To  0, ;
        nLeft       To  0, ;
        nBottom     To 24, ;
        nRight      To 79, ;
        bFunction   To { || Nil }, ;
        aHeadSep    To "ÄÂÄ", ;
        aColSep     To " ³ ", ;
        aFootSep    To "ÄÁÄ", ;
        nKey        To  0, ;
        aHeadings   To {}, ;
        bIndex      To MemVarBlock( "NINDEX" )
UpdateDate()
oABrowser := TBrowseNew( nTop, nLeft, nBottom, nRight )
oABrowser:HeadSep := aHeadSep
oABrowser:ColSep  := aColSep
oABrowser:FootSep := aFootSep
For nCtr = 1 To Len( aBlocks )
  oColumn := TBColumnNew( aHeadings[ nCtr ], aBlocks[ nCtr, 1 ] )
  If( ! aBlocks[ nCtr, 2 ] == Nil, oColumn:Width := aBlocks[ nCtr, 2 ], )
  If ValType( aHeadSep ) == "A"
    oColumn:HeadSep := aHeadSep[ nCtr ]
    oColumn:ColSep  := aColSep[ nCtr ]
    oColumn:FootSep := aFootSep[ nCtr ]
  EndIf
  oABrowser:AddColumn( oColumn )
Next
oABrowser:GoBottomBlock := { || Eval( bIndex, Len( Eval( bData ) ) ) }
oABrowser:GoTopBlock    := { || Eval( bIndex, 1 ) }
ArSkipper( oABrowser, bIndex, bData )
oABrowser:Cargo   := { nKey, bFunction, bIndex }
UpdateDate()
Return ( oABrowser )

Function BrowseArray( oABrowser, axParam, bAddFunc, lEdit, nContinue )
Local nKeypressed, nMethodNo, bColor, bFunction, nRow, nCol, bIndex
Default bAddFunc  To { || Nil }, ;
        lEdit     To .F., ;
        nContinue To 1
bFunction := oABrowser:Cargo[ 02 ]
bIndex    := oABrowser:Cargo[ 03 ]
oABrowser:ColorSpec := SetColor()
bColor = { | aRect, aColor | oABrowser:ColorRect( aRect, aColor ) }
Eval( bAddFunc, oABrowser )
Do While nContinue > 0 .And. nContinue < 6
  Do While ! oABrowser:Stabilize()
  EndDo
  nRow := Row(); nCol := Col()
  ABrowFunction( bFunction, oABrowser, "N", axParam, Eval( bIndex ) )
  Eval( bColor, { oABrowser:RowPos, oABrowser:LeftVisible, oABrowser:RowPos, oABrowser:RightVisible }, { 2, 2 } )
  UpdateDate()
  DevPos( nRow, nCol )
  nKeypressed := Inkey( oABrowser:Cargo[ 1 ] )
  If ! ( nMethodNo := AScan( TBMethods, { | Elem | nKeypressed = Elem[ 1 ] } ) ) == 0
    axParam[01] := ""
    If( ! nMethodNo == 15, Eval( bColor, { oABrowser:RowPos, oABrowser:LeftVisible, oABrowser:RowPos, oABrowser:RightVisible }, { 1, 2 } ), )
    oABrowser:RefreshCurrent()
    Eval( TBMethods[ nMethodNo, 2 ], oABrowser )
  ElseIf nKeypressed == 0
    oABrowser:RefreshAll()
    axParam[ 01 ] := ""
  Else
    nContinue := ABrowFunction( bFunction, oABrowser, "E", axParam, Eval( bIndex ) )
    If nContinue == 2
      oABrowser:RefreshAll()
    ElseIf nContinue == 0
      Eval( bIndex, nContinue )
    EndIf
  Endif
EndDo
UpdateDate()
Return ( nContinue )

Function ABrowFunction( bFunction, oABrowser, cExempt, axParam, nIndex )
If ! bFunction == Nil
  Return ( EVal( bFunction, ArrayMode( oABrowser, cExempt, nIndex ), oABrowser, axParam ) )
ElseIf LastKey() == K_ESC
  Return ( 0 )
EndIf
Return ( 2 )

Function ArrayMode( oABrowser, cExempt, nIndex )
Return ( If( nIndex == 0,                 3, ;     && Empty
         If( oABrowser:HitTop,            1, ;
         If( oABrowser:HitBottom,         2, ;
         If( cExempt == "E",              4, 0 ) ) ) ) )

Function OtherKeys()
Return ( LastKey() >= 32 .And. LastKey() <= 255 )

Function SearchArray( oABrowser, aArray, xExpBlock, nStart, nEnd, bIndex )
Local nPosition := AScan( aArray, xExpBlock, nStart, nEnd )
Default bIndex To MemVarBlock( "NINDEX" )
If ! nPosition == 0
  oABrowser:GoTop()
  Eval( bIndex, nPosition )
EndIf
Return ( Nil )

*-------------------------------------------------------------------------------
Function ClearBuffer()
__KeyBoard( "!" ); Inkey( 0 )
Return ( Nil )

Function KeyWait( nKey, cKeyBoard )
Default nKey      To 0, ;
        cKeyBoard To "!"
__KeyBoard( cKeyBoard ); Inkey( 0 )
Return ( InKey( nKey ) )

*-------------------------------------------------------------------------------
Function ClearScope()
Sx_ClrScope( _TOP_SCOPE ); Sx_ClrScope( _BOTTOM_SCOPE )
Return ( Nil )

*-------------------------------------------------------------------------------
Function ConnectLine( nRow, nLCol, nRCol, cLChar, cRChar, cColor )
Default cLChar To "Ã", ;
        cRChar To "´", ;
        cColor To SetColor()
If( nRow < 0 .Or. nRow > 24, nRow := 0, )
If( nLCol <  0, nLCol :=  0, )
If( nRCol > 79, nRCol := 79, )
OutExpr( nRow, nLCol, cLChar, cColor )
OutExpr( nRow, nRCol, cRChar, cColor )
Return ( Nil )

*-------------------------------------------------------------------------------
Function LockFiles( aFiles )
Local nCtr, lLock := .T., aLockFiles := {}, cLastFile := Alias(), ;
      cFile
For nCtr = 1 To Len( aFiles )
  cFile := aFiles[ nCtr, 01 ]
  If (cFile)-> ( FileLock() )
    (cFile)-> ( AAdd( aLockFiles, { aFiles[ nCtr, 01 ], Sx_TagNo() } ) )
    (cFile)-> ( Sx_SetTagOrder( aFiles[ nCtr, 02 ] ) )
  Else
    UnLockFiles( aLockFiles )
    Return ( Nil )
  EndIf
Next
Return ( If( Empty( aLockFiles ), Nil, aLockFiles ) )

*-------------------------------------------------------------------------------
Function UnLockFiles( aFiles )
Local nCtr, cFile
If ! Empty( aFiles )
  For nCtr = 1 To Len( aFiles )
    cFile := aFiles[ nCtr, 01 ]
    (cFile)-> ( Sx_UnLock() )
    (cFile)-> ( Sx_SetTagOrder( aFiles[ nCtr, 02 ] ) )
  Next
EndIf
Return ( Nil )

*-------------------------------------------------------------------------------
Function GetTrigger( cColor )
Default cColor To SetColor()
Return ( SubStr( cColor, Rat( ",", cColor ) + 1, Len( cColor ) - Rat( ",", cColor ) ) )

*-------------------------------------------------------------------------------
function civiltime(ctime)
ctime := iif(empty(ctime) .or. ctime == "0000", space(08), ft_mil2civ( ctime ) ) + ' '
ctime := substr(ctime,1,5)+substr(ctime,7,2)
return (ctime)


*-------------------------------------------------------------------------------
Function SaveScr( nLeft, nTop, nBottom, nRight )
Default nLeft   To 0, ;
        nTop    To 0, ;
        nBottom To MaxRow(), ;
        nRight  To MaxCol()
Return ( { nLeft, nTop, nBottom, nRight, SaveScreen( nLeft, nTop, nBottom, nRight ) } )

*-------------------------------------------------------------------------------
Function RestScr( aScreen )
Return ( RestScreen( aScreen[ 01 ], aScreen[ 02 ], ;
                     aScreen[ 03 ], aScreen[ 04 ], aScreen[ 05 ] ) )

*-------------------------------------------------------------------------------
#define BOXTOP   8
#define BOXLEFT 10
Function IndexBar()
Static aScrn, cSaveColor, nLast
Local nRecs := Sx_KeysIncluded() , cStd := MemVar-> ColorArray[ 24 ]
// BOF() is TRUE on first call to OPTION UDF.  Use this for setup.
IF Bof()
  nLast := LastRec()
  cSaveColor := SetColor( cStd )   && SetColor( "GR+/B,R+/W" )
  aScrn := SaveScr( BOXTOP, BOXLEFT, BOXTOP + 12, BOXLEFT + 62 )
  BoxShadow( BOXTOP, BOXLEFT, BOXTOP + 11, BOXLEFT + 60 , "ÛßÛÛÛÜÛÛ " )

  Scroll( BOXTOP + 1, BOXLEFT + 1, BOXTOP + 10, BOXLEFT + 59 )
  SetPos( BOXTOP + 2, BOXLEFT + 5)
  DevOut( "Creating Index      :               ")
  SetPos( BOXTOP + 3, BOXLEFT + 5)
  DevOut( "Tag name            :               ")
  SetPos( BOXTOP + 4, BOXLEFT + 5)
  DevOut( "Total Records       :               ")
  SetPos( BOXTOP + 5, BOXLEFT + 5)
  DevOut( "Current Record      :               ")
  SetPos( BOXTOP + 6, BOXLEFT + 5)
//DevOut( "Percentage complete :               ")
  SetPos( BOXTOP + 7, BOXLEFT + 5)
//DevOut( "0%                     50%                    100%" )
  DevOut( "Percentage Complete                              %" )
  DispBox( BOXTOP + 8, BOXLEFT + 4, BOXTOP + 10, BOXLEFT + 55 )

  // Clear the area, create the guage
  Scroll(BOXTOP + 2, BOXLEFT  + 27, BOXTOP + 11 - 5, BOXLEFT + 60 - 1, 0 )
  SetPos( BOXTOP + 2, BOXLEFT  + 28)
  DevOut( Sx_I_IndexName())
  SetPos( BOXTOP + 3, BOXLEFT  + 28)
  DevOut( Sx_I_TagName()  )
  SetPos( BOXTOP + 4, BOXLEFT  + 28)
  DevOut( LTrim( Transform( nLast,"999,999,999")) )
  aReplicate( BOXTOP + 9, BOXLEFT + 5, chr(219), 50, "N/N" )

ELSEIF Eof()
  SetColor( cSaveColor )
  RestScr( aScrn )

ELSE
  // Show how many keys have been included so far
  SetPos( BOXTOP + 5, BOXLEFT + 28)
  DevOut( LTrim( Transform( nRecs ,  "999,999,999")), cStd )
  //SetPos( BOXTOP + 6, BOXLEFT + 28)
  SetPos( BOXTOP + 7, BOXLEFT + 52)
  DevOut( LTrim( Transform( ( nRecs / nLast) * 100 ,  "999")),cStd )

  // Show how far we have got
  aReplicate( BOXTOP + 9, BOXLEFT + 5, chr(219),;
              int(( nRecs / nLast) * 50 ), cStd )
ENDIF
Return ( Nil )

Function aReplicate( nR, nC, cSt, nLen, cColor )
SetPos( nR, nC )
DevOut( Replicate( cSt, nLen ), cColor )
Return(NIL)

function jselect(cfile,norder)
select(cfile)
if .not. norder == nil
        setorder(norder)
endif
return (nil)

function jdbseek(norder,cexpr,lsoftseek)
if .not. norder == nil .and. norder > 0
        setorder(norder)
endif
return (dbseek(cexpr,lsoftseek))

function setorder(norder)
return (Sx_SetTagOrder(norder))

Function CurrOrder()
Return ( Sx_TagNo())

Function PageEject( cPage, abText, nRow, nMaxLine, bFooter )
Default bFooter  To { || Nil }, ;
        nMaxLine To _MAX_LINE

If cPage == _PAGE_FIRST
        PagePrint( abText )
ElseIf nRow > nMaxLine
        Eval( bFooter )
        PagePrint( abText )
        Return ( .T. )
EndIf
Return( .F. )

*------------------------------------------------------------------------------*
Function SysVar( cExpr )
If Len( Alltrim( cExpr ) ) > 150
        Return SubStr( cExpr, -150 )
EndIf
Return ( cExpr )

*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
Function AmtToChar( nAmount, currency )
Local   GetList := {}, nStrAmt, nChrAmt, nDecPlace := 1 

nStrAmt := Str( nAmount, 15, 2 )
nChrAmt := ""
//currency := ""



If nAmount <= 0.00
        Return( nChrAmt )
EndIf
Do While .T.
        If ! SubStr( nStrAmt, nDecPlace, 1 ) == " "
                Do Case
                        Case nDecPlace == 1
                                nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "HUNDRED "
                        Case nDecPlace == 2
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        If Val( SubStr( nStrAmt, nDecPlace, 2 ) ) > 19
                                                nChrAmt := nChrAmt + TwentyToNinety( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) )
                                        Else
                                                nChrAmt := nChrAmt + TenToNineteen( Val( SubStr( nStrAmt, nDecPlace, 2 ) ) ) + "BILLION "
                                                ++nDecPlace
                                        EndIf
                                Else
                                        ++nDecPlace
                                        If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                                nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "BILLION "
                                        Else
                                                nChrAmt := nChrAmt + "BILLION "
                                        EndIf
                                EndIf
                        Case nDecPlace == 3
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "BILLION "
                                Else
                                        nChrAmt := nChrAmt + "BILLION "
                                EndIf
                        Case nDecPlace == 4
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "HUNDRED "
                                EndIf
                        Case nDecPlace == 5
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        If Val( SubStr( nStrAmt, nDecPlace, 2 ) ) > 19
                                                nChrAmt := nChrAmt + TwentyToNinety( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) )
                                        Else
                                                nChrAmt := nChrAmt + TenToNineteen( Val( SubStr( nStrAmt, nDecPlace, 2 ) ) ) + "MILLION "
                                                ++nDecPlace
                                        EndIf
                                Else
                                        ++nDecPlace
                                        If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                                nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "MILLION "
                                        Else
                                                nChrAmt := nChrAmt + "MILLION "
                                        EndIf
                                EndIf
                        Case nDecPlace == 6
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "MILLION "
                                Else
                                        nChrAmt := nChrAmt + "MILLION "
                                EndIf
                        Case nDecPlace == 7
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "HUNDRED "
                                EndIf
                        Case nDecPlace == 8
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        If Val( SubStr( nStrAmt, nDecPlace, 2 ) ) > 19
                                                nChrAmt := nChrAmt + TwentyToNinety( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) )
                                        Else
                                                nChrAmt := nChrAmt + TenToNineteen( Val( SubStr( nStrAmt, nDecPlace, 2 ) ) ) + "THOUSAND "
                                                ++nDecPlace
                                        EndIf
                                Else
                                        ++nDecPlace
                                        If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                                nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "THOUSAND "
                                        Else
                                                nChrAmt := nChrAmt + "THOUSAND "
                                        EndIf
                                EndIf
                        Case nDecPlace == 9
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "THOUSAND "
                                Else
                                        nChrAmt := nChrAmt + "THOUSAND "
                                EndIf
                        Case nDecPlace == 10
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + "HUNDRED "
                                EndIf
                        Case nDecPlace == 11
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        If Val( SubStr( nStrAmt, nDecPlace, 2 ) ) > 19
                                                nChrAmt := nChrAmt + TwentyToNinety( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) )
                                        Else
                                                nChrAmt := nChrAmt + TenToNineteen( Val( SubStr( nStrAmt, nDecPlace, 2 ) ) ) + currency
                                                ++nDecPlace
                                        EndIf
                                Else
                                        ++nDecPlace
                                        If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                                nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + currency
                                        Else
                                                nChrAmt := nChrAmt + currency
                                        EndIf
                                EndIf
                        Case nDecPlace == 12
                                If ! Val( SubStr( nStrAmt, nDecPlace, 1 ) ) == 0
                                        nChrAmt := nChrAmt + OneToNine( Val( SubStr( nStrAmt, nDecPlace, 1 ) ) ) + currency
                                ElseIf ! Int( nAmount ) == 0
                                        nChrAmt := nChrAmt + currency
                                EndIf
                EndCase
        EndIf
        ++nDecPlace
        If nDecPlace > 12
                Exit
        EndIf
EndDo
nChrAmt := nChrAmt + "& " + SubStr( nStrAmt, 14, 2 ) + "/100 ONLY."
Return( nChrAmt )

Function OneToNine( nAmt )
Do Case
        Case nAmt == 1
                Return( "ONE " )
        Case nAmt == 2
                Return( "TWO " )
        Case nAmt == 3
                Return( "THREE " )
        Case nAmt == 4
                Return( "FOUR " )
        Case nAmt == 5
                Return( "FIVE " )
        Case nAmt == 6
                Return( "SIX " )
        Case nAmt == 7
                Return( "SEVEN " )
        Case nAmt == 8
                Return( "EIGHT " )
        Case nAmt == 9
                Return( "NINE " )
EndCase
return( nil )

Function TenToNineteen( nAmt )
Do Case
        Case nAmt == 10
                Return( "TEN " )
        Case nAmt == 11
                Return( "ELEVEN " )
        Case nAmt == 12
                Return( "TWELVE " )
        Case nAmt == 13
                Return( "THIRTEEN " )
        Case nAmt == 14
                Return( "FOURTEEN " )
        Case nAmt == 15
                Return( "FIFTEEN " )
        Case nAmt == 16
                Return( "SIXTEEN " )
        Case nAmt == 17
                Return( "SEVENTEEN " )
        Case nAmt == 18
                Return( "EIGHTEEN " )
        Case nAmt == 19
                Return( "NINETEEN " )
EndCase
return( nil )

Function TwentyToNinety( nAmt )
Do Case
        Case nAmt == 2
                Return( "TWENTY " )
        Case nAmt == 3
                Return( "THIRTY " )
        Case nAmt == 4
                Return( "FORTY " )
        Case nAmt == 5
                Return( "FIFTY " )
        Case nAmt == 6
                Return( "SIXTY " )
        Case nAmt == 7
                Return( "SEVENTY " )
        Case nAmt == 8
                Return( "EIGHTY " )
        Case nAmt == 9
                Return( "NINETY " )
EndCase
return( nil )



*------------------------------------------------------------------------------*
Function CreateDummy( cDumFile, aStruct, bBlock )
If ( File( cDumFile + ".TXT" ) .And. ! FErase( cDumFile + ".TXT" ) = 0 ) .Or. ;
   ( File( cDumFile + ".TXT" ) .And. ! FErase( cDumFile + ".CDX" ) = 0 )
        Fask( 13, "  Can't delete dummy files.  ", { " Ok " }, MemVar-> ColorArray[ 5 ] )
        Return( .F. )
EndIf
DBCreate( cDumFile + ".TXT", aStruct )
If ! File( cDumFile + ".TXT" )
        Fask( 13, "  Can't create dummy files.  ", { " Ok " }, MemVar-> ColorArray[ 5 ] )
        Return( .F. )
EndIf
If ! UseFile( , , cDumFile + ".TXT", , _DBF_EXCLUSIVE, , )
        Return( .F. )
EndIf
__DBZap()
Eval( bBlock )
DBCloseArea()
Return( .T. )

*------------------------------------------------------------------------------*
Function DelLockRecord( bField )
Local   aLocks := Sx_GetLocks()
If ! Empty ( aLocks )
        AEval( aLocks, { | nRec | DBGoto( nRec ), Eval( bField, _DELETE_TAG ), DBDelete() } )
        Sx_UnLock()
        DBCommit()
EndIf
Return( Nil )

*------------------------------------------------------------------------------*
Function Stabilize( oBrowser, lColor )
Default lColor to .F.
oBrowser:RefreshAll()
Do While ! oBrowser:Stabilize(); EndDo
If ( lColor, oBrowser:ColorRect( { oBrowser:RowPos, oBrowser:LeftVisible, oBrowser:RowPos, oBrowser:RightVisible }, { 1, 2 } ), )
Return( Nil )

********************************************************************************

function checkdate(ddate,nrow,ncol)
@ nrow, ncol say space(30)
@ nrow, ncol say cdow(ddate)+", "+cmonth(ddate)+str(day(ddate))+","+str(year(ddate))
return(.t.)

********************************************************************************

function termdesc(cterm)
local xterm
if substr(cterm,3,1) == "1"
        xterm := val(substr(cterm,1,2)) - 1
        memvar->ctermdesc := "1ST SEMESTER 19"+str(xterm,2)+"-19"+substr(cterm,1,2)
elseif substr(cterm,3,1) == "2"
        xterm := val(substr(cterm,1,2)) - 1
        memvar->ctermdesc := "2ND SEMESTER 19"+str(xterm,2)+"-19"+substr(cterm,1,2)
elseif substr(memvar->cterm,3,1) == "4"
        memvar->ctermdesc := "SUMMER 19"+substr(cterm,1,2)
endif
return(nil)

*-------------------------------------------------------------------------------

function valid_id(cidno)
local fs,d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd,chd1
fs := left(cidno,7)
d1 := substr(cidno,1,1)
d2 := val(substr(cidno,2,1))
d3 := substr(cidno,3,1)
d4 := val(substr(cidno,4,1))
d5 := substr(cidno,5,1)
d6 := val(substr(cidno,6,1))
d7 := substr(cidno,7,1)
s1 := val(d1) * 2
s1 := transform(s1,"99")
s1 := val(substr(s1,1,1))+val(substr(s1,2,1))
s2 := val(d3)*2
s2 := transform(s2,"99")
s2 := val(substr(s2,1,1))+val(substr(s2,2,1))
s3 := val(d5)*2
s3 := transform(s3,"99")
s3 := val(substr(s3,1,1))+val(substr(s3,2,1))
s4 := val(d7)*2
s4 := transform(s4,"99")
s4 := val(substr(s4,1,1))+val(substr(s4,2,1))
chd:= transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
chd:= int(10-val(chd))
if chd > 9
    chd := 0
end
chd1 := val(right(cidno,1))
if chd1 == chd
        return .t.
else
        return .f.
end

*------------------------------------------------------------------------------*

function statusbar()
memvar->nrec  := 1
draw_box2(07,11,18,68,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box2(08,20,10,42,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box2(11,20,13,42,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box1(08,44,10,59,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box1(11,44,13,59,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 09,23 say "Total Records    :" color memvar->colorarray[36]
@ 09,49 say ltrim(transform(memvar->nlast,"999,999,999")) color memvar->colorarray[36]
@ 12,23 say "Current Records  :" color memvar->colorarray[36]
@ 14,15 say "Progress" color memvar->colorarray[36]
draw_box1(15,14,17,65,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 16,15 say replicate("Û",50) color memvar->colorarray[39]

return(nil)

*------------------------------------------------------------------------------*

function showprogress()
@ 12,49 say ltrim(transform(memvar->nrec,"999,999,999")) color memvar->colorarray[36]
@ 14,62 say ltrim(transform((memvar->nrec / memvar->nlast) * 100,"999"))+"%" color memvar->colorarray[36]
areplicate(16,15,chr(219),int((memvar->nrec / memvar->nlast) * 50), memvar->colorarray[40])
++memvar->nrec
return(nil)

*------------------------------------------------------------------------------*

function showretrieving()
draw_box2(06,07,19,73,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box1(07,10,13,70,memvar->colorarray[28],memvar->colorarray[29],,.f.)
draw_box2(14,20,18,60,memvar->colorarray[28],memvar->colorarray[29],,.f.)

@ 08,12 say "ÛÛßÛÛ ÛÛßßß ßßÛÛßß ÛÛßÛÛ ÛÛ ÛÛßßß ÛÛ  ÛÛ ÛÛ ÛÛÛ ÞÛ ÜÛßßÛÛ" color memvar->colorarray[36]
@ 09,12 say "ÛÛ ÛÛ ÛÛ      ÛÛ   ÛÛ ÛÛ ÛÛ ÛÛ    ÛÛ  ÛÛ ÛÛ ÛÛÛÝÞÛ ÛÛ    " color memvar->colorarray[36]
@ 10,12 say "ÛÛÜÛß ÛÛßßß   ÛÛ   ÛÛÜÛß ÛÛ ÛÛßßß ÛÛ  ÛÛ ÛÛ ÛÝÛÛÞÛ ÛÛ ßÛÛ" color memvar->colorarray[36]
@ 11,12 say "ÛÛ ÛÝ ÛÛ      ÛÛ   ÛÛ ÛÝ ÛÛ ÛÛ    ÛÛÜÜÛÛ ÛÛ ÛÝÞÛÛÛ ÛÛ  ÛÛ" color memvar->colorarray[36]
@ 12,12 say "ÛÛ ÛÛ ÛÛÜÜÜ   ÛÛ   ÛÛ ÛÛ ÛÛ ÛÛÜÜÜ  ßÛÛß  ÛÛ ÛÝ ÛÛÛ ßÛÜÜÛÛ" color memvar->colorarray[36]

@ 15,23 say "ÛßÛ Û   Ûßß    Û   Û ÛßÛ Û ßÛß" color memvar->colorarray[37]
@ 16,23 say "ÛÜÛ Û   ÛÜÜ    Û Ü Û ÛÜÛ Û  Û " color memvar->colorarray[37]
@ 17,23 say "Û   ÛÜÜ ÜÜÛ Ü  ÛÜÛÜÛ Û Û Û  Û " color memvar->colorarray[37]

@ 17,53 say "Ü Ü Ü" color memvar->colorarray[37] + "*"
return(nil)

*------------------------------------------------------------------------------*

