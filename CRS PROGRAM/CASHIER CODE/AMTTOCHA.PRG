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

