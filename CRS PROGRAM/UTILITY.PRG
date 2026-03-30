* Program       :       UTILITY.PRG - User Utility
* Author        :       Randy F. Santizo and Lorenzo D. Benlot Jr.
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
OutExpr( 12, 31, "Level    : " )
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
                OutExpr( 12, 42,  USER-> U_LEVEL )
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
        cLevel    := USER-> U_LEVEL
SetCursor( 1 ); Set( _SET_CONFIRM, .T. )
@ 09, 42 gGet cFullName Picture "@!"
@ 10, 42 gGet cRights   Picture "@!S25"
@ 12, 42 gGet cLevel    Picture "@!"
Read
SetCursor( nLastCursor ); Set( _SET_CONFIRM, lConfirm )
If LastKey() == K_ENTER
        USER-> U_NAME   := Constring( cFullName, "C", Len( cFullName ) )
        USER-> U_RIGHTS := Constring( cRights  , "C", Len( cRights ) )
        USER-> U_LEVEL  := cLevel
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
#define _SUBJ   1
#define _GRD    2
#define _UNTS   3
#define _EMPTY_ELEMENT {space(13),;
                        space(03),;
                        space(04)}

function globegrade()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, cyytenrp, aprv2setup,;
      cterm,cdesc,cperiod,ccolcode,cyear,cpaper,clname,cfname
private cdummy := "gGlobe"+strzero(memvar->naccess,2),mstfile

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif

cterm    := space(len(term->code))
cperiod  := "F"

do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade for Globe SMS  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term    :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  School Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,23 say "- "+term->name
        cdesc := term->name
        if ! file(alltrim("c"+cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("c"+cterm+"enrp.dbf"))
                fask(10,"  C"+cterm+"ENRP.DBF not available...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "c"+cterm+"stsp"
        cyytskdp := "c"+cterm+"skdp"
        cyytenrp := "c"+cterm+"enrp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                     {,,"c999sm2p",,_DBF_SHARED,,1},;
                                     {,,"c999crsp",,_DBF_SHARED,,1},;
                                     {,,"c999colp",,_DBF_SHARED,,1},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,2},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        aentryscr := savescr(01,00,24,79)
        do while .t.
                restscr(aentryscr)
                commandline("³          F4 - View College File      ³          ESC - Previous               ³")
                setkey(K_F4,{||if(readvar()=="CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,23 say "[M-idterm, F-inal]" color memvar->colorarray[02]
                @ 04,02 say "Grading Period :";
                        color memvar->colorarray[02];
                        get cperiod     pict "@!";
                        valid cperiod $ "FM"
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
        if whereprint({||prnglobe(cperiod,cterm)}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
cfile := (memvar->cdummy+".TXT"); ccdx := (memvar->cdummy+".CDX")
ferase(cfile);ferase(ccdx)
restscr(alastscr)
return(nil)

static function prnglobe(cperiod,cterm)
local afile,nindex:=0,stext:="",nlen,i,nrow,ncol:=0
private ntotunits,ntotequi,lok,ntotgrade,csubject,csubdesc,cgrade,cunit,ncredits,lprint,curidno,;
        nlasti,aitems := {}

fask(13,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"IDNO"        ,"C",08,0},;
                                 {"PERIOD"      ,"C",07,0}},{||cdxgrdcrs()})
        dbcloseall()
        return(nil)
endif
memvar->mstfile := memvar->cdummy
if(afile := openwcheck({{,,(memvar->mstfile+".TXT"),"mstfile",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
mstfile->(__dbzap()); mstfile->(dbreindex())

cyytenrp->(dbsetrelation("c999sm1p",{||cyytenrp->enridno},"cyytenrp->enridno"))
cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing ID# "+alltrim(c999sm1p->sm1idno)+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
        mstfile->(dbappend())
        mstfile->idno   := c999sm1p->sm1idno
        mstfile->period := if(cperiod == "M","MIDTERM","FINAL  ")
        if nextkey() == K_ESC
                exit
        endif
        cyytenrp->(dbskip())
enddo
cyytenrp->(clearscope())
cyytenrp->(dbclearrelation())
cyytenrp->(sx_settagorder(2))

*------------------
*  Printing data  *
*------------------
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
mstfile->(dbgotop())
do while ! mstfile->(eof())
        memvar->ntotunits := memvar->ntotequi := 0
        memvar->ntotgrade := memvar->ncredits := 0
        memvar->lok             := .t.
        memvar->lprint          := .f.
        memvar->csubject        := space(13)
        memvar->csubdesc        := space(39)
        memvar->cgrade          := space(03)
        memvar->cunit           := space(04)
        memvar->nindex := 1
        asize(memvar->aitems,0)
        fask(10,"  Processing student "+alltrim(mstfile->idno)+" ",{" Ok "},memvar->colorarray[06],.f.,nil)
                cyytstsp->(sx_setscope(_TOP_SCOPE   ,mstfile->idno))
                cyytstsp->(sx_setscope(_BOTTOM_SCOPE,mstfile->idno))
                cyytstsp->(dbgotop())
                do while ! cyytstsp->(eof())
                        fask(16,"  Printing code "+alltrim(cyytstsp->stsskdcod)+" subject "+alltrim(cyytskdp->skdsubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
                        memvar->csubject := alltrim(cyytskdp->skdsubcod)+if(cyytskdp->skdsubtyp == "LEC"," "," L")
                        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                                do case
                                        case cperiod == "M"  &&Midterm
                                                memvar->lok := .f.
                                                if val(cyytstsp->stsmidgrd) > 0
                                                        if substr(cyytstsp->stsmidgrd,2,1) == "W"  /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                        else  /* for 30 - 10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                                        endif
                                                        if cyytstsp->stsmidgrd <= "30"
                                                        endif
                                                elseif ! empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := cyytstsp->stsmidgrd+" "
                                                elseif empty(cyytstsp->stsmidgrd)
                                                        memvar->cgrade := " "
                                                endif
                                        case cperiod == "F"   &&Final
                                                if val(cyytstsp->stsfingrd) > 0
                                                        if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                                memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        else /* for 30-10 grade */
                                                                memvar->cgrade := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                                        endif
                                                        if cyytstsp->stsfingrd <= "30"
                                                                memvar->ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                                                memvar->lok := .f.
                                                        endif
                                                elseif ! empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := cyytstsp->stsfingrd+" "
                                                        memvar->lok := .f.
                                                elseif empty(cyytstsp->stsfingrd)
                                                        memvar->cgrade := " "
                                                        memvar->lok := .f.
                                                endif
                                endcase
                                *---------------------------------
                                *  check the paper to be printed *
                                *---------------------------------
                                aadd(memvar->aitems,_EMPTY_ELEMENT)

                                memvar->aitems[memvar->nindex,_SUBJ] := memvar->csubject
                                memvar->aitems[memvar->nindex,_GRD]  := memvar->cgrade
                                memvar->aitems[memvar->nindex,_UNTS] := memvar->cunit
                                memvar->nindex += 1
                        endif
                        if nextkey() == K_ESC
                                exit
                        endif

                        cyytstsp->(dbskip())
                enddo
                cyytstsp->(clearscope())
                if nextkey() == K_ESC
                        exit
                endif

nlen := if(len(memvar->aitems)>17,17,len(memvar->aitems))
nrow := 0
curidno := mstfile->idno
ncol := 12

outexpr(prow(),00,+'"'+mstfile->idno+'";"')

for i = 1 to 25
if i <= len(memvar->aitems)
nlasti := len(memvar->aitems)
curidno := mstfile->idno
    if ncol == 12
        outexpr(prow(),ncol,alltrim(memvar->aitems[i,_SUBJ])+"-"+memvar->aitems[i,_GRD]+(if(i==nlasti,'"',', ')))
        ncol += len(alltrim(memvar->aitems[i,_SUBJ])+"-"+memvar->aitems[i,_GRD]+", ")
    else
        outexpr(prow(),ncol,alltrim(memvar->aitems[i,_SUBJ])+"-"+memvar->aitems[i,_GRD]+(if(i==nlasti,'"',', ')))
        ncol += len(alltrim(memvar->aitems[i,_SUBJ])+"-"+memvar->aitems[i,_GRD]+", ")
    endif
endif
next
        mstfile->(dbskip())
curidno := mstfile->idno
enddo
cyytstsp->(dbclearrelation())
closewcheck(afile)
__eject()
return(nil)

static function cdxgrdcrs()
field idno
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)
*------------------------------------------------------------------------------*

