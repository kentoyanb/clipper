* Program      : MAINT.PRG
* Author       : Joey P. Papillero/Cesidore B. Redido  (c) September 1993/1995
* Installation : KATIPUNAN LUMBER/CENTRAL PHILIPPINES CORP.

#include "Inkey.ch"
#include "SixCdx.ch"
#include "memoedit.ch"
#include "grumpr.ch"
#include "grumpm.ch"
#include "grump.ch"
#include "User.ch"

*******************************************************************************
* Rebuilding/Purging of files(s).                                             *
*******************************************************************************
Function ScanFile( cOperation )
Local aLastScr, cLastColor, oFiles
Private nIndex := 1, acFiles := {}

If ! UseFile( , , "ZZZZZZZZ.FIL", "ZZZZZZZZ", _DBF_SHARED )
        Return ( Nil )
EndIf
If ! File( "ZZZZZZZZ.CDX" )
        Index On ZZZZZZZZ-> Z_FILENAME + ZZZZZZZZ-> Z_INDEX Tag ZZZZZZZZ Of ZZZZZZZZ.CDX
EndIf
Sx_SetTagOrder( 1 )
AEval( Directory( "*.DBF" ), { | aFile | AAdd( MemVar-> acFiles, StringFile( aFile[1] ) ) } )
ASort( MemVar-> acFiles )

aLastScr   := SaveScr( 07, 00, 24, 79 )
cLastColor := SetColor( MemVar-> ColorArray[22] )
BoxShadow( 07, 30, 20, 47, "€ﬂ€€€‹€€ " )
CommandLine( "≥            F5 - All Files            ≥               ESC - Quit              ≥" )
If ! Empty( MemVar-> acFiles )
        oFiles := CreateABrowse( MemVarBlock( "ACFILES" ), MemVarBlock( "NINDEX" ), 08, 31, 20, 46, ;
                { | xnMode, xoABrowser, xaxParam | FScanFile( xnMode, xoABrowser, xaxParam ) }, ;
                { { { || "  " + MemVar-> acFiles[ MemVar-> nIndex ] + "  " }, Nil } },  ;
                { "  Select File   " }, ;
                { "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ" }, { "≥" }, { "‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹" }, MemVar-> nBrowWait )
        MemVar-> nIndex := 1
        ClearBuffer()
        BrowseArray( oFiles, { "", cOperation }, { | b | b:GoTop() } )
EndIf
RestScr( aLastScr ); SetColor( cLastColor )
ZZZZZZZZ-> ( ClearScope() )
ZZZZZZZZ-> ( DBCloseArea() )
Return ( Nil )

Static Function StringFile( cFile )
Local cReturnVal := SubStr( cFile, 1, At( ".", cFile ) - 1 )
Return ( cReturnVal + Space( 8 - Len( cReturnVal ) ) + ".DBF" )

Static Function FScanFile( nMode, oABrowser, axParam )
Do Case
        Case LastKey() == K_ESC
                Return 0
        Case nMode == 0
                Return 1
        Case LastKey() == K_ENTER
                Generate( MemVar-> acFiles[ MemVar-> nIndex ], axParam[ 02 ] )
                ClearBuffer()
        Case LastKey() == K_F5
                AllPurgeReindex( axParam[ 02 ] )
                ClearBuffer()
        Case OtherKeys()
                axParam[ 01 ] := axParam[ 01 ] + Upper( Chr( LastKey() ) )
                SearchArray( oABrowser, MemVar-> acFiles, { | Argument | SubStr( Argument, 1, Len( axParam[ 01 ]) ) == axParam[ 01 ] } )
EndCase
Return 2

Static Function AllPurgeReindex( cOperation )
Local nMax := Len( MemVar-> acFiles ), aLastScr := SaveScr( 10, 00, 24, 79 ), ;
      cLastColor := SetColor( MemVar-> ColorArray[19] )
BoxShadow( 10, 22, 16, 55, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19] )
DevPos(24, 00); DevOut( "≥                              Please Wait ...                                 ≥", If( MemVar-> lColor, "*GR+/+R", "*N/W" ) )
AEval( MemVar-> acFiles,  { | cFile | Generate( cFile, cOperation, "A" ) } )
RestScr( aLastScr ); SetColor( cLastColor )
Return ( Nil )

Static Function Generate( cFile, cOperation, cType )
Local aLastScr, nLastCursor, cTempFile
Private cExpress, cIndex
Default cType To "I"
cFile := RTrim( ( cTempFile := SubStr( cFile, 1, 8 ) ) )
If( ! Select( cFile ) == 0, (cFile)-> ( DBCloseArea() ), )
If cOperation == "R" .And. File( cFile + ".CDX" )
        FErase( cFile + ".CDX" )
EndIf
If ! UseFile( , , cFile, "USEDFILE", _DBF_EXCLUSIVE )
        Return ( Nil )
EndIf
nLastCursor := SetCursor( 0 )
ZZZZZZZZ-> ( Sx_SetScope( _TOP_SCOPE   , cTempFile ) )
ZZZZZZZZ-> ( Sx_SetScope( _BOTTOM_SCOPE, cTempFile ) )
ZZZZZZZZ-> ( DBGoTop() )

If cType == "I" .And. ( cOperation == "P" .Or. ( cOperation =="R" .And. ! ( ZZZZZZZZ-> ( Bof() ) .And. ZZZZZZZZ-> ( Eof() ) ) ) )
        aLastScr := SaveScr( 10, 00, 24, 79 )
        BoxShadow( 10, 22, 16, 55, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19] )
        CentHead( 13, If( cOperation == "R", "Re-Indexing ", "Purging " ) + cFile + ".DBF", 22, 55, MemVar-> ColorArray[19] )
        DevPos(24, 00); DevOut( "≥                              Please Wait ...                                 ≥", If( MemVar-> lColor, "*GR+/+R", "*N/W" ) )
ElseIf cType == "A" .And. ( cOperation == "P" .Or. ( cOperation =="R" .And. ! ( ZZZZZZZZ-> ( Bof() ) .And. ZZZZZZZZ-> ( Eof() ) ) ) )
        Scroll( 11, 23, 15, 54, 1 )
        CentHead( 15, If( cOperation == "R", "Re-Indexing ", "Purging " ) + cFile + ".DBF", 22, 55, MemVar-> ColorArray[19] )
EndIf

If cOperation == "P"
        __DBPack(); Sx_MemoPack()
Else
        Do While ZZZZZZZZ-> ( ! Eof() )
                MemVar-> cExpress := ZZZZZZZZ-> Z_EXPRESS
                MemVar-> cIndex   := ZZZZZZZZ-> Z_INDEX
                Index On &(MemVar-> cExpress) Tag ( MemVar-> cIndex ) Of (ZZZZZZZZ-> Z_FILENAME) Option IndexBar()
                ZZZZZZZZ-> ( DBSkip( 1 ) )
        EndDo
EndIf
SetCursor( nLastCursor )
USEDFILE-> ( DBCloseArea() )
If( ! aLastScr == Nil, RestScr( aLastScr ), )
Return ( Nil )

*******************************************************************************

*******************************************************************************
* File Editing of all files.                                                  *
*******************************************************************************
Function ChoiceFile()
Local oFiles, ;
      aLastScr := SaveScr( 07, 00, 24, 79 ), ;
      cLastColor := SetColor( MemVar-> ColorArray[22] )
Private nIndex, acFiles := {}
AEval( Directory( "*.DBF" ), {|aFile| AAdd( MemVar-> acFiles, StringFile( aFile[1] ) ) } )
ASort( MemVar-> acFiles )
BoxShadow( 07, 30, 20, 47, "€ﬂ€€€‹€€ " )
CommandLine( "≥              Ÿ - Select             ≥               ESC - Quit              ≥" )
MemVar-> nIndex := 1
oFiles := CreateABrowse( MemVarBlock( "ACFILES"), MemVarBlock( "NINDEX" ), 08, 31, 20, 46, ;
       { | xnMode, xoABrowser, xaxParam | FChoiceFile( xnMode, xoABrowser, xaxParam ) }, ;
       { { { || '  ' + MemVar-> acFiles[ MemVar-> nIndex ] + '  ' }, Nil } }, ;
       { "  Select File   " }, ;
       { "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ" }, ;
       { "≥" }, ;
       { "‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹" }, MemVar-> nBrowWait )
If( ! Empty( MemVar-> acFiles ), BrowseArray( oFiles, { "" }, { | b | b:GoTop() } ), )
RestScr( aLastScr ); SetColor( cLastColor )
Return ( Nil )

Static Function FChoiceFile( nMode, oABrowser, axParam )
Do Case
        Case LastKey() = K_ESC
                Return 0
        Case nMode == 0
                Return 1
        Case LastKey() = K_ENTER
                SelectMenu( { { 14, 52, "   ~Exclusive  ",,,, { || FileEdit( MemVar-> acFiles[ MemVar-> nIndex ], _DBF_EXCLUSIVE ) },, }, ;
                              { 15, 52, "   ~Shared     ",,,, { || FileEdit( MemVar-> acFiles[ MemVar-> nIndex ], _DBF_SHARED ) },, } }, ;
                              { || BoxShadow( 13, 51, 16, 52 + 14, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[20] ) }, , ;
                             "≥            Ÿ - to select            ≥            ESC - Previous             ≥", MemVar-> ColorArray[20],,,,, ;
                             GetTrigger( MemVar-> ColorArray[20] ) )
                axParam[01] := ""
        Case OtherKeys()
                axParam[ 01 ] := axParam[ 01 ] + Upper( Chr( LastKey() ) )
                SearchArray( oABrowser, MemVar-> acFiles, { | Argument | SubStr( Argument, 1, Len( axParam[ 01 ]) ) == axParam[ 01 ] } )
EndCase
Return 2

Static Function FileEdit( cFile, lUse )
Local aLastScr, lDeleted, cLastColor, acFields := {}, oFile, ;
      cTempFile, nTagCount, nCtr
Private acSetOrder := {}, nOrderDefault
cFile := RTrim( SubStr( cFile, 1, 8 ) )

If OpenWCheck( { { , , cFile, , lUse } } ) == Nil
        Return ( Nil )
EndIf

Sx_SetTagOrder( 0 )
If ! Empty( MemVar-> acSetOrder := Sx_TagInfo() )
        nTagCount := Len( MemVar-> acSetOrder )
        For nCtr = 1 To nTagCount
                MemVar-> acSetOrder[ nCtr, TAGNAME ] := MemVar-> acSetOrder[ nCtr, TAGNAME ]
                MemVar-> acSetOrder[ nCtr, TAGEXPR ] := SubStr( MemVar-> acSetOrder[ nCtr, TAGEXPR ], 1, 78 )
        Next
EndIf
AAdd( MemVar-> acSetOrder, Nil ); AIns( MemVar-> acSetOrder, 1 )
MemVar-> acSetOrder[1] := { "NONE", "  N O N E  " }
MemVar-> nOrderDefault := 0
AEval( DBStruct( "*.DBF" ), { | aField | AAdd( acFields, aField[1] ) } )
oFile :=  CreateBrowse( 05, 02, 23, 77, ;
            { | xnMode, xacFields, xoBrowser, xaxParam | FFileEdit( xnMode, xacFields, xoBrowser, xaxParam ) }, ;
            acFields, acFields, "ﬂ€ﬂ", " € ", "‹€‹" )
oFile:Autolite := .T.
cLastColor     := SetColor( MemVar-> ColorArray[06] )
lDeleted       := Set( _SET_DELETED, .F. )
aLastScr       := SaveScr( 02, 00, 24, 79 )
BoxShadow( 02, 01, 23, 78, "€ﬂ€€€‹€€ ", , "  Editing " + AllTrim( cFile ) + ".DBF - " + If( lUse == _DBF_EXCLUSIVE, "Exclusive", "Shared" ) + "  " )
CommandLine( "≥        Ÿ - Edit        ≥  F10 - Additional Function  ≥     ESC-Previous     ≥" )
BrowseFile( oFile, { "", .F., "", "" }, { | b | GoTopFile( b ) }, .T. )
Set( _SET_DELETED, lDeleted )
RestScr( aLastScr )
SetColor( cLastColor )
DBCloseArea()
Return ( Nil )

Static Function GoTopFile( b )
b:PanHome()
b:GoTop()
Return ( Nil )

Function FMemo()
Return "<Memo>"

Static Function FFileEdit( nMode, acFields, oBrowser, axParam )
Local GetList := {}, nOrderChoice, cLastScr, bField, cLastColor, cKey, lSeek, ;
     nRecNo, nLastCursor, nLine, nRow, nCol, cTop, cBottom, lConfirm, cEditValue
Do Case
        Case LastKey() == K_ESC
                Return 0
        Case nMode == 0
                DevPos(04, 30); DevOut( If( Deleted(), "<Deleted>", "         " ) )
                DevPos(04, 50); DevOut( "Record # " + Str( RecNo(), 6 ) )
                Return 1
        Case LastKey() = K_ENTER    && Enter - Edit
                Return ( EditRecord( acFields, oBrowser ) )
        Case LastKey() == K_F10
                SelectMenu( { { 09, 33, "   ~Add Record       ",,,, { || Adding( oBrowser ) },, }, ;
                              { 10, 33, "   ~Delete/Recall    ",,,, { || Deleting() },, }, ;
                              { 11, 33, "   ~Search           ",,,, { || CheckTag( { || SearchKey( oBrowser ) } ) },, }, ;
                              { 12, 33, "   ~Goto Record      ",,,, { || GotoRecord( oBrowser ) },, }, ;
                              { 13, 33, "   Set ~Order        ",,,, { || If( ChangeOrder() == 6, axParam[01] := "", ) },, }, ;
                              { 14, 33, "   Set S~cope        ",,,, { || CheckTag( { || SetFileScope( oBrowser  ) } ) },, } }, ;
                { || BoxShadow( 08, 32, 15, 33 + 20, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[22] ) }, .T., ;
                "≥                               ESC - Previous                                 ≥", ;
                MemVar-> ColorArray[22] , , , , , GetTrigger( MemVar-> ColorArray[22] ) )
EndCase
Return 2

Static Function EditRecord( acFields, oBrowser )
Local GetList := {}, ;
      nLastCursor, cEditValue, nRow, nCol, bField, lScope, cTop, cBottom, cKey, cPicture
nRow   := Row(); nCol := Col()
bField := acFields[ oBrowser:ColPos ]
bField := FieldBlock( If( SubStr( bField, 1, 5 ) = "FMemo", ;
                       AllTrim( SubStr( bField, 7, Len( bField ) - 7 ) ), bField ) )
If ! RecLock()
        Return 2
EndIf
If ValType( cEditValue := Eval( bField ) ) == "M"
        EditMemo( bField, cEditValue )
Else
        cTop    := Sx_SetScope( _TOP_SCOPE    )
        cBottom := Sx_SetScope( _BOTTOM_SCOPE )
        lScope  := .F.
        If ! cTop == Nil .Or. ! cBottom == Nil
                lScope := .T.
        EndIf
                cPicture := "@"
                If ValType( cEditValue ) == "C" .And. Len( cEditValue ) > 76
                        cPicture := "@S76"
                EndIf
        nLastCursor := SetCursor( 1 )
        @ nRow, nCol Get cEditValue Pict cPicture
       Read
        SetCursor( nLastCursor )
        If Updated()
                Eval( bField, cEditValue )
                DBCommit()
                cKey := Sx_KeyData()
                If Sx_TagNo() > 0 .And. lScope .And. ( cKey < cTop .Or. cKey > cBottom )
                        oBrowser:GoTop()
                Else
                        EditRefresh( oBrowser )
                EndIf
        EndIf
        DBUnLock(); DBCommit()
EndIf
Return ( 2 )

Static Function CheckTag( bOperation )
If( Empty( MemVar-> acSetOrder ) .Or. Sx_TagNo() <= 0, ;
        Sound( 2000, 6 ), Eval( bOperation ) )
Return ( Nil )

Static Function Adding( oBrowser )
If AppBlank()
        DBUnLock()
        DBCommit()
        EditRefresh( oBrowser )
EndIf
Return ( Nil )

Static Function Deleting()
If RecLock( 5 )
        If( Deleted(), DBRecall(), DBDelete() )
        DBUnLock()
        DBCommit()
EndIf
Return ( Nil )

Static Function ChangeOrder()
Local aLastScr := SaveScr( 04, 00, 24, 79 ), oOrder, nRetVal, ;
      cLastColor := SetColor( MemVar-> ColorArray[09] )
Private nOrderIndex

CommandLine( "≥       Ÿ - Select Index Order        ≥               ESC - Quit              ≥" )
BoxShadow( 06, 00, 08, 79, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19], " Index Expression " )
BoxShadow( 09, 31, 20, 46, "€ﬂ€€€‹€€ " )

oOrder := CreateABrowse( MemVarBlock( "ACSETORDER" ), MemVarBlock( "NORDERINDEX" ), 10, 32, 20, 45, ;
       { | xnMode, xoABrowser, xaxParam | FChangeOrder( xnMode, xoABrowser, xaxParam ) }, ;
       { { { || "  " + If( MemVar-> nOrderDefault == MemVar-> nOrderIndex - 1, Chr( 251 ), " " ) + " " + ;
                MemVar-> acSetOrder[ MemVar-> nOrderIndex, TAGNAME ] + "  " }, 14 } }, ;
       { " Select Order " }, ;
       { "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ" }, { "≥" }, { "‹‹‹‹‹‹‹‹‹‹‹‹‹‹" }, MemVar-> nBrowWait )
MemVar-> nOrderIndex := 1
nRetVal := BrowseArray( oOrder, { "" }, { | b | b:GoTop() } )
ClearBuffer()
RestScr( aLastScr )
SetColor( cLastColor )
Return ( nRetVal )

Static Function FChangeOrder( nMode, oABrowser, axParam )
Do Case
        Case LastKey() == K_ESC
                Return 0
        Case nMode == 0
                DevPos(07, 01); DevOut( Space( 78 ), MemVar-> ColorArray[19] )
                DevPos(07, 01); DevOut( MemVar-> acSetOrder[ MemVar-> nOrderIndex, TAGEXPR ], MemVar-> ColorArray[19] )
                Return 1
        Case LastKey() == K_ENTER
                If ! MemVar-> nOrderDefault == MemVar-> nOrderIndex - 1
                        ClearScope()
                        Sx_SetTagOrder( ( MemVar-> nOrderDefault := MemVar-> nOrderIndex - 1 ) )
                        Return 6
                EndIf
EndCase
Return 2

Static Function SetFileScope( oBrowser )
Static cTop, cBottom
Local GetList := {}, ;
      aLastScr    := SaveScr( 10, 00, 24, 79 ), ;
      nLastCursor := SetCursor( 1 ), ;
      lConfirm    := Set( _SET_CONFIRM, .T. )
Default cTop    To Space( 100 ), ;
        cBottom To Space( 100 )
BoxShadow( 10, 13, 17, 67, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19], " Message " )
DevPos(13, 15); DevOut( "Scope Top Value   :                               ", MemVar-> ColorArray[19] )
DevPos(14, 15); DevOut( "Scope Bottom Value:                               ", MemVar-> ColorArray[19] )
CommandLine( "≥                               ESC - Previous                                 ≥" )
@ 13, 35 Get cTop     Picture "@S30"   Color MemVar-> ColorArray[19]
@ 14, 35 Get cBottom  Picture "@S30"   Color MemVar-> ColorArray[19]
Read
SetCursor( nLastCursor ); Set( _SET_CONFIRM, lConfirm )
If LastKey() == K_ESC
        ClearBuffer()
ElseIf Empty( cTop ) .And. Empty( cBottom )
        Sx_ClrScope( 0 ); Sx_ClrScope( 1 )
        oBrowser:GoTop()
Else
        Sx_SetScope( _TOP_SCOPE, AllTrim( cTop ) ); Sx_SetScope( _BOTTOM_SCOPE, AllTrim( cBottom ) )
        oBrowser:GoTop()
EndIf
RestScr( aLastScr )
Return ( Nil )

Static Function SearchKey( oBrowser )
Static cString, lSeek
Local GetList := {}, ;
      aLastScr    := SaveScr( 10, 00, 24, 79 ), ;
      lConfirm    := Set( _SET_CONFIRM, .T. ), ;
      nLastCursor := SetCursor( 1 )
Default cString To Space( 100 ), ;
        lSeek   To .T.

BoxShadow( 10, 13, 17, 67, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19], " Message " )
DevPos(13, 15); DevOut( "Search Expression:                                ", MemVar-> ColorArray[19] )
DevPos(14, 15); DevOut( "Softseek On/Off  :                                ", MemVar-> ColorArray[19] )
CommandLine( "≥                               ESC - Previous                                 ≥" )
@ 13, 35 Get cString  Picture "@!S30"  Color MemVar-> ColorArray[19]
@ 14, 35 Get lSeek    Picture "@! L"   Color MemVar-> ColorArray[19]
Read
Set( _SET_CONFIRM, lConfirm ); SetCursor( nLastCursor )
If LastKey() == K_ENTER
  oBrowser:GoTop()
  If ! DBSeek( AllTrim( cString ), lSeek )
    FAlert( "Search expression not found.", { " Ok " }, MemVar-> ColorArray[05], Nil, ;
            "≥                          ENTER or ESC - Previous                             ≥" )
    oBrowser:GoBottom()
  EndIf
Else
  ClearBuffer()
EndIf
RestScr( aLastScr )
Return ( Nil )

Static Function GotoRecord( oBrowser )
Static nGotoRec
Local GetList := {}, ;
      aLastScr := SaveScr( 10, 00, 24, 79 ), ;
      lConfirm := Set( _SET_CONFIRM, .T. ), ;
      nLastCursor := SetCursor( 1 ), ;
      cTop    := Sx_SetScope( _TOP_SCOPE    ), ;
      cBottom := Sx_SetScope( _BOTTOM_SCOPE ), ;
      lScope  := .F., cKey
Default nGotoRec To 1
If ! cTop == Nil .Or. ! cBottom == Nil
  lScope := .T.
EndIf
BoxShadow(10, 13, 17, 67, "€ﬂ€€€‹€€ ", MemVar-> ColorArray[19], " Message " )
DevPos(13, 25); DevOut( "Enter Record # : ", MemVar-> ColorArray[19] )
CommandLine( "≥                               ESC - Previous                                 ≥" )
@ 13, 42 Get nGotoRec Pict "9,999,999,999" Color MemVar-> ColorArray[19]
Read
Set( _SET_CONFIRM, lConfirm ); SetCursor( nLastCursor )
If LastKey() = K_ENTER
  DBGoto( nGotoRec )
  If Eof()
    FAlert( "Record # exceeds the existing maximum number of record.", { " Ok " }, MemVar-> ColorArray[05], Nil, ;
            "≥                          ENTER or ESC - Previous                             ≥" )
    DBGoBottom()
  Else
    cKey := Sx_KeyData()
    If Sx_TagNo() > 0 .And. lScope .And. ( cKey < cTop .Or. cKey > cBottom )
      oBrowser:GoTop()
    EndIf
  EndIf
Else
  ClearBuffer()
EndIf
RestScr( aLastScr )
Return ( Nil )

Static Function EditMemo( bField, cEditValue )
Local cLastScr := SaveScreen( 05, 00, 24, 79 ), nLastCursor := SetCursor( 3 ), ;
      lInsert := Set( _SET_INSERT, .T. ), cLastColor := SetColor( MemVar-> ColorArray[09] )
CommandLine( "≥           F2 - Exit with save        ≥       ESC - Exit without saving       ≥" )
BoxShadow( 05, 03, 22, 75, "€ﬂ€€€‹€€ ", , " Edit Memo " )
OutExpr( 22, 03, Space( 73 ), FlipColor( SetColor() ) )
Eval( bField, MemoEdit( cEditValue, 06, 04, 21, 74, .T., "FEditMemo" ) )
SetCursor( nLastCursor ); Set( _SET_INSERT, lInsert )
RestScreen( 05, 00, 24, 79, cLastScr ); SetColor( cLastColor )
Return ( Nil )

Function FEditMemo( nMode, nLine, nColumn )
If nMode = ME_UNKEY .Or. nMode = ME_UNKEYX
  Do Case
    Case Lastkey() = K_ESC
      Return ME_DEFAULT
    Case LastKey() = K_INS
      If( ReadInsert(), SetCursor( 1 ), SetCursor( 3 ) )
      Return K_INS
    Case LastKey() = K_CTRL_W
      Return ME_IGNORE
    Case LastKey() = K_F2
      Return K_CTRL_W
  EndCase
EndIf
OutExpr( 22, 05, "Line " + LTrim( Str( nLine, 3 ) ) + "  Column " + LTrim( Str( nColumn + 1, 3 ) ), FlipColor( SetColor() ) )
Return ME_DEFAULT

******************************************************************************
/*
File indexing

     File Name  Index Expression                        Index Tag
     ---------  ----------------                        ---------
1.)  c999sm1p   sm1idno                                 c999sm11
                sm1lstnam+sm1fstnam+sm1midnam           c999sm12
                sm1colcod+str(sm1yrlevl,2)              c999sm13

2.)  c999sm2p   sm2idno                                 c999sm21

3.)  c999room   roomno                                  c999rom1

4.)  c999prsp   prosyrt+proscolcod                      c999prs1

5.)  c999curp   currevcod+curcolcod+cursubcod+cursubtyp c999cur1
                curintcod                               c999cur2

6.)  c999csp    crsintcod                               c999crs1

7.)  c999colp   colcod                                  c999col1
                colnamcol                               c999col2

8.)  cyytskdp   skdcod                                  cyytskd1
                skdsubcod                               cyytskd2
                skdsec                                  cyytskd3

9.)  cyytsecp   seccolcod+seccod                        cyytsec1

10.) cyytstsp   stsidno                                 cyytsts1
                stsskdcod+stsidno                       cyytsts2
                stsskdcod+stslstnam+stsfstnam+stsmidnam cyytsts3

11.) cyytenrp   enridno                                 cyytenr1
                enrcolcod+enryrlevl                     cyytenr2
                enryrlevl                               cyytenr3

*/
