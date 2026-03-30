* Program      : VIEWTXT.PRG - View binary file
* Author       : Joey P. Papillero     (c) January 10, 1995
* Installation : CENTRAL PHILIPPINES MARKETING CORPORATION

#Include "InKey.Ch"
#Include "SixCdx.Ch"
#Include "grumpr.ch"
#Include "grump.ch"
#Include "grumpm.ch"
#Include "User.Ch"
#Include "FileIO.Ch"

Function ViewTextFile()
Static cFileName
Local GetList := {}, aLastScr, cLastColor, lConfirm, aInputScr, ;
      nLastCursor, nColor1, nColor2, cExitKey
nColor1 := If( MemVar-> lColor, 31, 7 )
nColor2 := If( MemVar-> lColor, 75, 112 )
aLastScr    := SaveScr( 03, 00, 24, 79 )
cLastColor  := SetColor( MemVar-> ColorArray[11] )
lConfirm    := Set( _SET_CONFIRM )
nLastCursor := SetCursor()
BoxShadow( 03, 00, 23, 79, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[11], "  View Binary File  " )
DevPos(04, 03); DevOut( "Name Of File : " )
DevPos(05, 01); DevOut( Replicate( "Ü", 78 ) )
CommandLine( "³               F6 - File                ³           ESC - Previous            ³" )
aInputScr := SaveScr( 03, 00, 24, 79 )
Default cFileName To Space( 100 )
Do While .T.
  RestScr( aInputScr )
  SetKey( K_F6, { || LookFile( { || __KeyBoard( MemVar-> aTextFile[ MemVar-> nIndex ] + Chr( K_ENTER ) ), 6 } ) } )
  Set( _SET_CONFIRM, .T. ); SetCursor( 1 )
  @ 04, 18 gget cFileName  Picture "@!KS20"
  Read
  Set( _SET_CONFIRM, lConfirm ); SetCursor( nLastCursor )
  SetKey( K_F6, Nil )
  If LastKey() == K_ESC
    Exit
  EndIf
  DevPos(04, 18); DevOut( SubStr( AllTrim( cFileName ), 1, 60 ) )
  CommandLine( "³            Ù - Exit & Print           ³           ESC - Previous            ³" )
  SetCursor( 3 )
  If ! Ft_DFSetUp( AllTrim( cFileName ), 06, 01, 22, 78, 1, nColor1, nColor2, ;
       Chr( K_ENTER ), .F., 1, 300,  21 * 300 ) == 0
    FAlert( "   Can't open " + AllTrim( cFileName ) + ".   ", { " Ok " }, MemVar-> ColorArray[05] )
  Else
    cExitKey := Ft_DispFile()
    Ft_DFClose()
    If cExitKey == Chr( K_ENTER )
      PrintLineText( AllTrim( cFileName ) )
    EndIf
  EndIf
EndDo
RestScr( aLastScr )
SetColor( cLastColor ); SetCursor( nLastCursor )
Return ( Nil )

#Define _FILE_NAME    1

#Define ELEMENT       { Space( 12 ) }

Static Function LookFile( bEnter )
Local oFiles, aLastScr := SaveScr( 07, 00, 24, 79 ), ;
      cLastColor  := SetColor( MemVar-> ColorArray[22] ), ;
      nLastCursor := SetCursor( 0 )
Private aTextFile := {}, nIndex := 1
AEval( Directory( "*.*" ), { | aFile | AAdd( MemVar-> aTextFile, aFile[ 1 ] ) } )
ASort( MemVar-> aTextFile )
oFiles := CreateABrowse( MemVarBlock( "ATEXTFILE" ), MemVarBlock( "NINDEX" ), 08, 31, 20, 46, ;
       { | xnMode, xoABrowser, xaxParam | FScanFile( xnMode, xoABrowser, xaxParam ) }, ;
       { { { || "  " + MemVar-> aTextFile[ MemVar-> nIndex ] + "  " }, 16 } },  ;
       { "  Select File   " }, ;
       { "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" }, { "³" }, { "ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ" }, MemVar-> nBrowWait )
BoxShadow( 07, 30, 20, 47, "ÛßÛÛÛÜÛÛ " )
CommandLine( "³             Ù - Select             ³             ESC - Previous             ³" )
BrowseArray( oFiles, { "", bEnter }, { | b | b:GoTop() } )
RestScr( aLastScr ); SetColor( cLastColor ); SetCursor( nLastCursor )
Return ( Nil )

Static Function FScanFile( nMode, oABrowser, axParam )
Do Case
  Case LastKey() == K_ESC
    Return 0
  Case nMode == 0
    Return 1
  Case LastKey() == K_ENTER .And. ! Empty( MemVar-> aTextFile[ MemVar-> nIndex ] )
    Return ( Eval( axParam[ 02 ] ) )
  Case OtherKeys()
    axParam[ 01 ] := axParam[ 01 ] + Upper( Chr( LastKey() ) )
    SearchArray( oABrowser, MemVar-> aTextFile, { | Argument | SubStr( Argument, 1, Len( axParam[ 01 ]) ) == axParam[ 01 ] } )
EndCase
Return 2

Function PrintLineText( cFileName )
Local nHandle
If nHandle := Ft_FUse( cFileName, FO_READ ) == -1
  FAlert( "   Can't open " + cFileName + ".   ", { " Ok " }, MemVar-> ColorArray[05] )
Else
  LocalPrinter( { || EchoToPrinter() } )
  Ft_FUse()
EndIf
Return ( Nil )

Static Function EchoToPrinter()
Ft_FGoTop()
Do While ! Ft_FEof()
  DevPos(PRow() + 1, 00); DevOut( Ft_FReadLn() )
  Ft_FSkip()
EndDo
Return ( Nil )
