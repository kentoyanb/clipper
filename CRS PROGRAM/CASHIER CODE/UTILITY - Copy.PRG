* Program       :       UTILITY.PRG - User Utility
* Author        :       jHUN bENLOT & tOPZ fLORENTiNO
* Installation  :       UNIVERSITY OF CEBU - METC

#Include "Inkey.Ch"
#Include "SixCdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

*------------------------------------------------------------------------------*

Function UserUtility()
Static  oUser := Nil
Local   sLastScr := SaveScr( 04, 00, 24, 79 ), nUserRec := USER->( RecNo() ), ;
        cLastColor := SetColor( MemVar-> ColorArray[11] ), ;
        cUser := Constring( USER-> U_LOGNAME, "A", Len( USER-> U_LOGNAME ) )
Default oUser To USER->( CreateBrowse( 06, 11, 19, 27, ;
                { | xnMode, xacFields, xoBrowser, xaxParam | FUserUtility( xnMode, xacFields, xoBrowser, xaxParam ) }, ;
                { "' ' + Constring( U_LOGNAME, 'A', Len( U_LOGNAME ) ) + ' '" }, ;
                { "    User Name    " }, ;
                { "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" }, { "³" }, ;
                { "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" } ) )
BoxShadow( 04, 08, 20, 69, "ÛßÛÛÛÜÛÛ ", , " User Utility " )
DispBox( 05, 10, 19, 28, _SINGLE_LINE ); ConnectLine( 07, 10, 28 )
OutExpr( 09, 31, "Full Name: " )
OutExpr( 10, 31, "Rights   : " )
DispBox( 07, 29, 19, 68, _SINGLE_LINE )
//CommandLine( "³ Ù - Rights  ³  Ins - Add  ³  Del - Delete  ³ F5 - Password ³ ESC - Previous ³" )
CommandLine( "³   Ù - Rights     ³    Ins - Add     ³   Del - Delete   ³   ESC - Previous   ³" )
USER->( BrowseFile( oUser, { "", cUser }, { | b | b:Gotop() } ) )
USER->( DBGoto( nUserRec ) )
SetColor( cLastColor ); RestScr( sLastScr )
Return( Nil )

Static Function FUserUtility( nMode, acFields, oBrowser, axParam )
Do Case
        Case LastKey() == K_ESC
                Return 0
        Case nMode == 0
                OutExpr( 09, 42, Constring( USER-> U_NAME, "A", Len( USER-> U_NAME ) ) )
                OutExpr( 10, 42, SubStr( Constring( USER-> U_RIGHTS, "A", Len( USER-> U_RIGHTS ) ), 1, 25 ) )
                Return 1
        Case LastKey() == K_ENTER .And. ;
                ! Alltrim( Constring( USER-> U_LOGNAME, "A", Len( USER-> U_LOGNAME ) ) ) == "SUPERVISOR" .And. ;
                RecLock()
                        EditRights()
                        Sx_UnLock()
        Case LastKey() == K_INS
                AddUser( oBrowser )
        Case LastKey() == K_DEL .And. ;
                ! Alltrim( Constring( USER-> U_LOGNAME, "A", Len( USER-> U_LOGNAME ) ) ) == "SUPERVISOR" .And. ;
                ! Constring( USER-> U_LOGNAME, "A", Len( USER-> U_LOGNAME ) ) == axParam[ 02 ] .And. ;
                Falert( "  Are you sure to delete this user ?  ", { " Yes ", " No  " }, MemVar-> ColorArray[ 5 ] ) == 1 .And. ;
                RecLock()
                        USER-> U_LOGNAME := _DELETE_TAG
                        DBDelete()
                        Sx_UnLock()
        Case LastKey() == K_F5 .And. ;
                ( ! Alltrim( Constring( USER-> U_LOGNAME, "A", Len( USER-> U_LOGNAME ) ) ) == "SUPERVISOR" .Or. ;
                    Alltrim( axParam[ 02 ] ) == "SUPERVISOR" ) .And. ;
                    RecLock()
                        EditPassWord( axParam[ 02 ] )
                        Sx_UnLock()
EndCase
Return 2

Static Function EditRights()
Local   GetList := {}, lConfirm := Set( _SET_CONFIRM ), nLastCursor := SetCursor(), ;
        cFullName := Constring( USER-> U_NAME, "A", Len( USER-> U_NAME ) ), ;
        cRights   := Constring( USER-> U_RIGHTS, "A", Len( USER-> U_RIGHTS ) )
SetCursor( 1 ); Set( _SET_CONFIRM, .T. )
@ 09, 42 gGet cFullName Picture "@!"
@ 10, 42 gGet cRights   Picture "@!S25"
Read
SetCursor( nLastCursor ); Set( _SET_CONFIRM, lConfirm )
If LastKey() == K_ENTER
        USER-> U_NAME   := Constring( cFullName, "C", Len( cFullName ) )
        USER-> U_RIGHTS := Constring( cRights  , "C", Len( cRights ) )
        DBCommit()
EndIf
Return( Nil )

Static Function AddUser( oBrowser )
Local   GetList := {}, lConfirm := Set( _SET_CONFIRM ), nLastCursor := SetCursor(), ;
        cUser := Space( Len( USER-> U_LOGNAME ) ), ;
        sLastScr := SaveScr( 04, 00, 24, 79 )
CommandLine( "³                               ESC - Previous                                 ³" )
SetCursor( 1 ); Set( _SET_CONFIRM, .T. )
@ 08, 31 Say "User Name:" gGet cUser Picture "@!" Valid ! Alltrim( cUser ) == "SUPERVISOR"
Read
SetCursor( nLastCursor ); Set( _SET_CONFIRM, lConfirm )
If LastKey() == K_ENTER
        ReCycle()
        USER-> U_LOGNAME        := Constring( cUser, "C", Len( cUser ) )
        USER-> U_PASSWORD       := Constring( Space( Len( USER-> U_PASSWORD ) ), "C", Len( USER-> U_PASSWORD ) )
        USER-> U_NAME           := Constring( Space( Len( USER-> U_NAME ) ), "C", Len( USER-> U_NAME ) )
        USER-> U_RIGHTS         := "[20,20]"
        USER-> U_RIGHTS         := Constring( USER-> U_RIGHTS, "C", Len( USER-> U_RIGHTS ) )
        Sx_UnLock()
        oBrowser:Gotop()
EndIf
RestScr( sLastScr )
Return( Nil )

Static Function EditPassWord( cUser )
Local   GetList := {}, cNewPassWord := Constring( USER-> U_PASSWORD, "A", Len( USER-> U_PASSWORD ) ), ;
        lConfirm    := Set( _SET_CONFIRM ), ;
        nLastCursor := SetCursor(), ;
        sLastScr    := SaveScr( 04, 00, 24, 79 )
CommandLine( "³                               ESC - Previous                                 ³" )
SetCursor( 1 ); Set( _SET_CONFIRM, .T. )
@ 13, 31 Say "New Password:" GGet cNewPassWord Picture "@!" Valid ! Empty( cNewPassWord )
Read
SetCursor( nLastCursor ); Set( _SET_CONFIRM, lConfirm )
If LastKey() == K_ENTER
        USER-> U_PASSWORD := Constring( cNewPassWord, "C", Len( cNewPassWord ) )
        DBCommit()
EndIf
RestScr( sLastScr )
Return( Nil )

Static Function TestOld( cCurrPassWord, cOldPassWord )
If ! cCurrPassWord == Constring( cOldPassWord, "C" )
        Falert( "   Invalid Password.   ", { " Ok " }, MemVar-> ColorArray[ 5 ] )
        Return( .F. )
EndIf
Return( .T. )

Function ChangePassWord()
Local   GetList := {}, ;
        cNewPassWord := Space( Len( USER-> U_PASSWORD ) ), ;
        cConfirmPass := Space( Len( USER-> U_PASSWORD ) ), ;
        cFullName    := Constring( USER-> U_NAME, "A", Len( USER-> U_NAME ) ), ;
        lConfirm     := Set( _SET_CONFIRM ), ;
        nLastCursor  := SetCursor(), sLastScr, cLastColor
If USER->( RecLock() )
        sLastScr   := SaveScr( 09, 00, 24, 79 )
        cLastColor := SetColor( MemVar-> ColorArray[ 11 ] )
        BoxShadow( 09, 13, 15, 65, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[11], "  Change Password  " )
        CommandLine( "³                               ESC - Previous                                 ³" )
        OutExpr( 11, 15, "New Password    : ", MemVar-> ColorArray[17] )
        OutExpr( 12, 15, "Confirm Password: ", MemVar-> ColorArray[17] )
        OutExpr( 13, 15, "Full Name       : ", MemVar-> ColorArray[17] )
        CommandLine( "³                               ESC - Previous                                 ³" )
        SetCursor( 1 ); Set( _SET_CONFIRM, .T. )
        @ 11, 33 GGEt cNewPassWord  Picture "@!" Valid ! Empty( cNewPassWord ) .And. ;
                                ! cNewPassWord == Space( Len( USER-> U_PASSWORD ) ) ;
                                PassWord Chr( 1 )
        @ 12, 33 GGEt cConfirmPass  Picture "@!" Valid ! Empty( cConfirmPass ) .And. ;
                                ! cConfirmPass == Space( Len( USER-> U_PASSWORD ) ) ;
                                PassWord Chr( 1 )
        @ 13, 33 GGet cFullName     Picture "@!"
       Read
        Set( _SET_CONFIRM, lConfirm ); SetCursor( nLastCursor )
        If LastKey() == K_ENTER
           if alltrim(cNewPassWord) == alltrim(cConfirmPass)
                USER-> U_PASSWORD := Constring( cNewPassWord, "C", Len( cNewPassWord ) )
                USER-> U_NAME     := Constring( cFullName   , "C", Len( cFullName ) )
                DBCommit()
           else
                fask(10,"  Password not Changed...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                fask(10,"  Please try again...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
           endif
        EndIf
        RestScr( sLastScr ); SetColor( cLastColor )
EndIf
USER->( DBUnLock() )
Return( Nil )

Function Rights( cRight, lEcho )
Local   lRetVal
Default lEcho To .F.
lRetVal := ( cRight $ MemVar-> cUserRights )
If lRetVal .And. lEcho
        Fask( 13, "   Sorry, you have no rights ...   ", { " Ok " }, MemVar-> ColorArray[ 5 ] )
EndIf
Return( ! lRetVal )

*------------------------------------------------------------------------------*

