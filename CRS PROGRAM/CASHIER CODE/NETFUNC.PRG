* Program      : Network Functions
* Author       : jHUN bENLOT & tOPZ fLORETiNO
* Date written :
* Installation :
*------------------------------------------------------------------------------*
#include "sixcdx.ch"
#include "inkey.ch"
#Include "User.Ch"

#Define F_NEW_AREA   1
#Define F_DRIVER     2
#Define F_NAME       3
#Define F_ALIAS      4
#Define F_SHARED     5
#Define F_READ_ONLY  6
#Define F_SET_ORDER  7
#Define F_PATH       8

#Define CF_ALIAS     1
#Define CF_OPEN      2
#Define CF_SET_ORDER 3

*------------------------------------------------------------------------------*
* Function Name : UseFile
* Description   : function for using a file in a network
* Parameters
*                 pcFile - file to use
*                 cMode  - parameter mode( E - Exclusive, S - Shared,
*                                          R - Read Only )
* Return Value  :
*                 .T. - Successful
*                 .F. -Fail
**************************************************************************
Function UseFile( lNewArea, cDriver, cName, cAlias, lShared, lReadOnly, cPath )
Local lSuccess := .T., cCurrPath := CurPath(), ;
      lConsole := Set( _SET_CONSOLE, "on" ), ;
      cDevice := Set( _SET_DEVICE, "SCREEN" ), cColor := ( "gr+/r+" )
If ! cPath == Nil .And. ! ChDir( cPath )
  FAlert( "Can't access path " + AllTrim( Upper( cPath ) ) + ".", { " Ok " }, cColor )
Else
  Default lNewArea To _NEW_AREA, ;
          cDriver  To "SIXCDX"
  Sx_SetTrig( 5, )
  DBUseArea( lNewArea, cDriver, cName, cAlias, lShared, lReadOnly )
  If ( lSuccess := NetErr() )
    FAlert( "Database file " + AllTrim( Upper( cName ) ) + " not available.", { " Ok " }, cColor )
  EndIf
  If( ! cPath == Nil, ChDir( cCurrPath ), )
EndIf
Set( _SET_CONSOLE, lConsole ); Set( _SET_DEVICE, cDevice )
Return ( ! lSuccess )
**************************************************************************
Function OpenWCheck( acFile )
Local nCtr, aCurrSetUp := {}, lSelect, cAlias, ;
      cLastFile := Alias()

If ! Empty( acFile )
  For nCtr = 1 To Len( acFile )
    If Len( acFile[ nCtr ] ) < F_PATH
      ASize( acFile[ nCtr ], F_PATH )
    EndIf

    Default acFile[ nCtr, F_ALIAS ]     To acFile[ nCtr, F_NAME ]
    Default acFile[ nCtr, F_SHARED ]    To Set( _SET_EXCLUSIVE )
    Default acFile[ nCtr, F_SET_ORDER ] To 0

    cAlias := acFile[ nCtr, F_ALIAS ]

    If ! ( lSelect := If( Select( cAlias ) == 0, .F., .T. ) )
      If ! UseFile( acFile[ nCtr, F_NEW_AREA  ], ;
                    acFile[ nCtr, F_DRIVER    ], ;
                    acFile[ nCtr, F_NAME      ], ;
                    acFile[ nCtr, F_ALIAS     ], ;
                    acFile[ nCtr, F_SHARED    ], ;
                    acFile[ nCtr, F_READ_ONLY ], ;
                    acFile[ nCtr, F_PATH      ] )
        CloseWCheck( aCurrSetUp, cLastFile )
        Return ( Nil )
      EndIf
    Else
      Select( cAlias )
      If acFile[ nCtr, F_SHARED ] .And. ! FileLock()
        CloseWCheck( aCurrSetUp, cLastFile )
        Return ( Nil )
      EndIf
    EndIf
    AAdd( aCurrSetUp, { cAlias, lSelect, Sx_TagNo() } )
    Sx_SetTagOrder( acFile[ nCtr, F_SET_ORDER ] )
  Next
  Return ( aCurrSetUp )
EndIf
Return ( Nil )
**************************************************************************
Function CloseWCheck( aSetUp, cLastFile )
Local cAlias
Default aSetUp To {}
If ! Empty( aSetUp )
  AEval( aSetUp, { | aArea | cAlias := aArea[ CF_ALIAS ], ;
      (cAlias)-> ( If( ! aArea[ CF_OPEN ], DBCloseArea(), ;
         Sx_SetTagOrder( aArea[ CF_SET_ORDER ] ) ) ), ;
      (cAlias)-> ( DBUnLock() ) } )
EndIf
PreviousFile( cLastFile )
Return ( Nil )
**************************************************************************
Function PreviousFile( cFile )
If ! cFile == Nil
  If( ! Select( cFile ) == 0, Select( cFile ), )
EndIf
Return ( Nil )
**************************************************************************
* Function Name : RecLock
* Description   : function for record locking
* Parameters
*                 nWaitState - wait state( 0 - endless loop, 1 - can be aborted )
* Return Value  :
*                 .T. - Successful
*                 .F. - Fail
**************************************************************************
Function RecLock( nWaitState )
Local lSuccess := .F., nRow := 10, nCol := 16, lFirstPass := .T., ;
      lProceed := .T., cColor := ( 'gr+/r+' ), cCommLine, cMsg, nAddCol, cFile := Alias(), ;
      cLastScr, cLastColor := SetColor(), lConsole := Set( 17, "on" ), ;
      cDevice := Set( 20, "SCREEN" ), dDate := Date(), cTime := Time()
nWaitState   := If( nWaitState = Nil, 1, nWaitState )
Do While ! lSuccess .And. lProceed
  If Sx_RLock( RecNo() )
    lSuccess := .T.
    DBCommit()
  ElseIf lFirstPass
    cLastScr := SaveScreen( nRow, 00, 24, 79 )
    cMsg := "Accessing record " + AllTrim( Str( RecNo(), 7 ) ) + " of " + AllTrim( Upper( cFile ) ) + ".DBF please wait."
    BoxShadow(nRow, nCol, nRow + 3, nCol + 46, "ÛßÛÛÛÜÛÛ ", cColor)
    DevPos(24, 00); DevOut("³                                 ESC - Abort                                  ³", cCommLine)
    DevPos(nRow + 1, nCol + Int( ( 46 - Len( cMsg ) ) / 2 ) ); DevOut( cMsg, cColor)
    DevPos(nRow + 2, nCol + ( nAddCol := Int( ( 44 - Len( "Time Elapse : 12345678" ) ) / 2 ) ) ); DevOut( "Time Elapse : ", cColor )
    DevPos(nRow + 2, nCol + nAddCol + 14 ); DevOut( Timer( "On" ), cColor )
    lFirstPass := .F.
    Inkey( 5 )
  EndIf
  lProceed := If( ! lSuccess .And. ( Inkey() = K_ESC .Or. ;
                ( ! nWaitState = 0 .And. SecElapsed( dDate, cTime ) >= nWaitState ) ), .F., .T. )
EndDo
Timer( "Off" )
SetColor( cLastColor )
Set( 17, lConsole ); Set( 20, cDevice )
If( ! lFirstPass, RestScreen( nRow, 00, 24, 79, cLastScr ), )
Return ( lSuccess )

Static Function SecElapsed( dDate, cTime )
Local aElapsed := Ft_Elapsed( dDate, Date(), cTime, Time() )
Return ( aElapsed[4, 1] )

**************************************************************************
* Function Name : FileLock
* Description   : function for file locking
* Parameters
*                 nWaitState - wait state( 0 - endless loop, 1 - can be aborted )
* Return Value  :
*                 .T. - Successful
*                 .F. - Fail
**************************************************************************
Function FileLock( nWaitState )
Local lSuccess := .F., nRow := 08, nCol := 17, lFirstPass := .T., ;
      lProceed := .T., cColor, cCommLine, cMsg, nAddCol, cFile := Alias(), ;
      cLastScr, cLastColor := SetColor(), lConsole := Set( 17, "on" ), ;
      cDevice := Set( 20, "SCREEN" ), dDate := Date(), cTime := Time()
nWaitState  := If( nWaitState = Nil, 1, nWaitState )
If IsColor()
  cColor    := "W+/+R"
  cCommLine := "N/BG"
Else
  cColor    := "W/N"
  cCommLine := "N/W"
EndIf
__KeyBoard( Chr( 32 ) )
Do While ! lSuccess .And. lProceed
  If FLock()
    lSuccess := .T.
    DBCommit()
  ElseIf lFirstPass
    cLastScr := SaveScreen( nRow, 00, 24, 79 )
    cMsg := "Can't lock  " + AllTrim( Upper( cFile ) ) + ".DBF."
    BoxShadow(nRow, nCol, nRow + 3, nCol + 44, "ÛßÛÛÛÜÛÛ ", cColor)
    DevPos(24, 00); DevOut("³                                 ESC - Abort                                  ³", cCommLine)
    DevPos(nRow + 1, nCol + Int( ( 44 - Len( cMsg ) ) / 2 ) ); DevOut( cMsg, cColor)
    DevPos(nRow + 2, nCol + ( nAddCol := Int( ( 44 - Len( "Time Elapsed : 12345678" ) ) / 2 ) ) ); DevOut("Time Elapsed : ", cColor)
    DevPos(nRow + 2, nCol + nAddCol + 14 ); DevOut( Timer( "On" ), cColor)
    lFirstPass := .F.
    DevPos(nRow + 2, nCol + 3); DevOut("Time Counting   : "  + Time(), cColor)
  EndIf
  lProceed := If( ! lSuccess .And. ( Inkey() = K_ESC .Or. ;
                ( ! nWaitState = 0 .And. SecElapsed( dDate, cTime ) >= nWaitState ) ), .F., .T. )
EndDo
Timer( "Off" )
SetColor( cLastColor )
Set( 17, lConsole ); Set( 20, cDevice )
If( ! lFirstPass, RestScreen( nRow, 00, 24, 79, cLastScr ), )
Return ( lSuccess )
**************************************************************************
* Function Name : AppendBlank
* Description   : function to add record
* Parameters
*                 nWaitState - wait state( 0 - endless loop, 1 - can be aborted )
* Return Value  :
*                 .T. - Successful
*                 .F. - Fail
**************************************************************************
Function AppBlank( nWaitState )
Local lSuccess := .F., nRow := 08, nCol := 17, lFirstPass := .T., ;
      lProceed := .T., cColor, cCommLine, cMsg, nAddCol, cFile := Alias(), ;
      cLastScr, cLastColor := SetColor(), lConsole := Set( 17, "on" ), ;
      cDevice := Set( 20, "SCREEN" )
nWaitState  := If( nWaitState = Nil, 1, nWaitState )
*__KeyBoard( Chr( 32 ) )
Do While ! lSuccess .And. lProceed
  DBAppend()
  If ! NetErr()
    lSuccess := .T.
    DBCommit()
  ElseIf lFirstPass
    cLastScr := SaveScreen( nRow, 00, 24, 79 )
    cMsg := "Can't append record to " + AllTrim( Upper( cFile ) ) + ".DBF."
    BoxShadow(nRow, nCol, nRow + 3, nCol + 44, "ÛßÛÛÛÜÛÛ ", cColor)
    DevPos(24, 00); DevOut("³                                 ESC - Abort                                  ³", cCommLine)
    DevPos(nRow + 1, nCol + Int( ( 44 - Len( cMsg ) ) / 2 ) ); DevOut( cMsg, cColor)
    DevPos(nRow + 2, nCol + ( nAddCol := Int( ( 44 - Len( "Time Elapse : 12345678" ) ) / 2 ) ) ); DevOut("Time Elapse : ", cColor)
    DevPos(nRow + 2, nCol + nAddCol + 14 ); DevOut( Timer( "On" ), cColor)
    lFirstPass := .F.
    Inkey( 5 )
  EndIf
  lProceed := If( Inkey() = K_ESC .And. ! nWaitState = 0, .F., .T. )
EndDo
Timer( "Off" )
SetColor( cLastColor )
Set( 17, lConsole ); Set( 20, cDevice )
If( ! lFirstPass, RestScreen( nRow, 00, 24, 79, cLastScr ), )
Return ( lSuccess )
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³                              END OF SOURCE                            ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
