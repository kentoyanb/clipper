* Program       :       UTILITY.PRG - User Utility
* Author        :       Randy F. Santizo
* Updated       :       Jun Benlot Nov. 2007
* Installation  :       UC-METC

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
CommandLine( "³ Ù - Rights  ³  Ins - Add  ³  Del - Delete  ³ F5 - Password ³ ESC - Previous ³" )
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
        cFullName    := Constring( USER-> U_NAME, "A", Len( USER-> U_NAME ) ), ;
        lConfirm     := Set( _SET_CONFIRM ), ;
        nLastCursor  := SetCursor(), sLastScr, cLastColor
If USER->( RecLock() )
        sLastScr   := SaveScr( 09, 00, 24, 79 )
        cLastColor := SetColor( MemVar-> ColorArray[ 11 ] )
        BoxShadow( 09, 13, 15, 65, "ÛßÛÛÛÜÛÛ ", MemVar-> ColorArray[11], "  Change Password  " )
        CommandLine( "³                               ESC - Previous                                 ³" )
        OutExpr( 11, 15, "New Password: ", MemVar-> ColorArray[17] )
        OutExpr( 12, 15, "Full Name   : ", MemVar-> ColorArray[17] )
        CommandLine( "³                               ESC - Previous                                 ³" )
        SetCursor( 1 ); Set( _SET_CONFIRM, .T. )

// ! Empty( cNewPassWord )

        @ 11, 15 Say "New Password:" GGEt cNewPassWord  Picture "@!" Valid ;
                                ! cNewPassWord == Space( Len( USER-> U_PASSWORD ) ) ;
                                PassWord Chr( 1 )
        @ 12, 15 Say "Full Name   :" GGet cFullName     Picture "@!"
       Read
        Set( _SET_CONFIRM, lConfirm ); SetCursor( nLastCursor )
        If LastKey() == K_ENTER
                USER-> U_PASSWORD := Constring( cNewPassWord, "C", Len( cNewPassWord ) )
                USER-> U_NAME     := Constring( cFullName   , "C", Len( cFullName ) )
                DBCommit()
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
function chartentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      ccode,cname,lexist:=.f.,aprvsetup,aentryscr,cprocsts
if(aprvsetup:=openwcheck({{,,"a999chrt",,_DBF_SHARED,,1}}))==nil
        return(nil)
endif
boxshadow(06,19,15,60,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Chart Entry  ")
commandline("³          F4 - View Chart             ³           ESC - Previous              ³")
aentryscr := savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        ccode   := space(len(a999chrt->code))
        cname   := space(len(a999chrt->desc))
        setkey(K_F4,{||viewchart({||__keyboard(chr(K_CTRL_LEFT)+a999chrt->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 08,21 say "Code :";
                color memvar->colorarray[02];
                get ccode pict "@!";
                valid ! empty(ccode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if lexist := a999chrt->(dbseek(ccode))
                a999chrt->(reclock())
                cname := a999chrt->desc
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 10,21 say "Name :";
                color memvar->colorarray[02];
                get cname pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(12,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
        if ! lexist
                a999chrt->(recycle())
        endif
        a999chrt->code          := ccode
        a999chrt->desc          := cname
        a999chrt->rectrail      := dtoc(date())+","+time()+","+memvar->cusername
        a999chrt->(dbcommit())
        a999chrt->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aprvsetup)
return(nil)

*------------------------------------------------------------------------------*

function assessbystud()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,cyytenrp,;
      cterm,cname,cacctno,ayytassp,cyytskdp,lrecord:="Y",cvar:=""
private nfeeunit,nunits,ntuition,nlab,nreg,noth,nmisc,ntotass,cstatus,;
        cfeeyr,clname,cfname,cmname,ccourseyr,ccolcode,cyrlevl,ccls,denr
if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))
do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Create Assessment by Account  ")
        commandline("³        F4 - View Term/College File       ³         ESC - Previous            ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("\crunlib\"+"c"+cterm+"skdp.dbf")
                fask(10,"  C"+cterm+"SKDP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  A"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+cterm+"assp"
        cyytenrp  := "c"+cterm+"enrp"
        cyytskdp  := "c"+cterm+"skdp"
        if(aprv2setup:=openwcheck({{,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,cyytskdp,"cyytskdp",_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999feep",,_DBF_SHARED,,1},;
                                   {,,"a999ctrl",,_DBF_SHARED,,1},;
                                   {,,"a999lbfp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 03,02 say "Account No.  :";
                        color memvar->colorarray[02];
                        get cacctno     pict "@!";
                        valid ! empty(cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if a999accp->(dbseek(cacctno)) .and.;
                   !cyytenrp->(dbseek(right(cacctno,8)))
                        fask(10,"  Student "+alltrim(a999accp->acclname)+", "+alltrim(a999accp->accfname)+" "+a999accp->accmname+". not enrolled this semester.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif !a999accp->(dbseek(cacctno)) .and.;
                       !cyytenrp->(dbseek(right(cacctno,8)))
                                fask(10,"   Student not enrolled this semester.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                commandline("³            F10 - Record              ³           ESC - Previous              ³")
                initvar()
                procsubj(cacctno)
                procassess(cterm,cacctno,cname)
                cvar := " "
                do while .t.
                        setkey(K_F10,{||record(cacctno,cterm)})
                        @ 24,78 get cvar pict "@!"
                       read
                        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F10,nil)
                        if lastkey() == K_ESC
                                exit
                        endif
                enddo
        enddo
        closewcheck(aprv2setup)
enddo
restscr(alastscr)
closewcheck(aprv1setup)
return(nil)

static function procsubj(cacctno)
local nline:=05,nctr:=0,skdno,xunit:=0
draw_box2(02,02,04,33,memvar->colorarray[30],memvar->colorarray[31],,.f.)
@ 03,13 say "SUBJECT" color memvar->colorarray[32]
draw_box1(05,02,23,33,memvar->colorarray[30],memvar->colorarray[31],,.f.)
cyytenrp->(dbseek(right(cacctno,8)))
for nctr := 1 to 16
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                cyytskdp->(dbseek(cyytenrp->&skdno))
                if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
                   ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                        @ ++nline,04 say "[*] "+cyytskdp->skdsubcod+;
                                         " " +cyytskdp->skdsubtyp+;
                                         " - "+transform(cyytskdp->skdunt,"999.9");
                                color memvar->colorarray[32]
                endif
        else
                exit
        endif
next
@ 22,05 say "<< Total Units -> "+transform(cyytenrp->enrunt,"999.9")+" >>" color memvar->colorarray[32]
memvar->nunits  := cyytenrp->enrunt
memvar->ccls    := cyytenrp->enrcls
memvar->cyrlevl := cyytenrp->enryrlevl
memvar->denr    := cyytenrp->enrdte
return(nil)


static function procassess(cterm,cacctno,cname)
local skdno,nctr:=0
a999accp->(dbseek(cacctno))
memvar->clname  := a999accp->acclname
memvar->cfname  := a999accp->accfname
memvar->cmname  := a999accp->accmname
memvar->cfeeyr  := a999accp->accfeeyr
memvar->ccolcode:= a999accp->acccolcod
c999colp->(dbseek(a999accp->acccolcod))
memvar->ccourseyr := alltrim(c999colp->coldesabr)+" "+a999accp->accyrlevl
a999feep->(dbseek(a999accp->accfeeyr+a999accp->acccolcod+right(cterm,1)))
memvar->nfeeunit := a999feep->feeperunit
if ! memvar->nunits == int(memvar->nunits)
        xunit := memvar->nunits - 1.5
else
        xunit := memvar->nunits
endif
memvar->ntuition := xunit * memvar->nfeeunit
memvar->nmisc    := a999feep->feetotmisc
memvar->nreg     := a999feep->feereg
memvar->noth     := a999feep->feeother1+a999feep->feeother2+a999feep->feeother3+a999feep->feeother4+a999feep->feeother5
cyytenrp->(dbseek(right(cacctno,8)))
for nctr := 1 to 16
        skdno := if(nctr < 10,"enrskd"+transform(nctr,"9"),"enrskd"+transform(nctr,"99"))
        if ! cyytenrp->&skdno == "00000"
                cyytskdp->(dbseek(cyytenrp->&skdno))
                if ! cyytskdp->skdunt == 1.5
                        a999lbfp->(dbseek(memvar->cfeeyr+cyytskdp->skdintcod+cyytskdp->skdcolcod)) /*a999accp->acccolcod))*/
                        if right(cterm,1) == "1"
                                memvar->nlab += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                memvar->nlab += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                memvar->nlab += a999lbfp->lbfamt3
                        endif
                else
                        a999lbfp->(dbseek(memvar->cfeeyr+cyytskdp->skdintcod+"**"))
                        if right(cterm,1) == "1"
                                memvar->nlab += a999lbfp->lbfamt1
                        elseif right(cterm,1) == "2"
                                memvar->nlab += a999lbfp->lbfamt2
                        elseif right(cterm,1) == "4"
                                memvar->nlab += a999lbfp->lbfamt3
                        endif
                endif
        else
                exit
        endif
next
memvar->ntotass := memvar->ntuition+memvar->nlab+memvar->nreg+memvar->nmisc
dispass(cacctno,cterm,cname)
return(nil)

static function dispass(cacctno,cterm,cname)
draw_box2(02,35,04,77,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,51 say "ASSESSMENT" color memvar->colorarray[33]
draw_box1(05,35,23,77,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 06,37 say "Sch Term : "+cterm+" - "+cname color memvar->colorarray[33]
@ 08,37 say "Account No.   : "+cacctno color memvar->colorarray[33]
@ 09,37 say "Last Name     : "+memvar->clname color memvar->colorarray[33]
@ 10,37 say "First Name    : "+memvar->cfname color memvar->colorarray[33]
@ 11,37 say "Middle Initial: "+memvar->cmname color memvar->colorarray[33]
@ 12,37 say "Course & Year : "+memvar->ccourseyr color memvar->colorarray[33]
@ 13,37 say "Fee Year      : "+memvar->cfeeyr color memvar->colorarray[33]
@ 15,37 say "Fee Per Unit . . . . . . . : "+transform(memvar->nfeeunit,"999,999.99") color memvar->colorarray[33]
@ 16,37 say "No. of Units . . . . . . . : "+transform(memvar->nunits,"999,999.99") color memvar->colorarray[33]
@ 17,37 say "Tuition  . . . . . . . . . : "+transform(memvar->ntuition,"999,999.99") color memvar->colorarray[33]
@ 18,37 say "Laboratory . . . . . . . . : "+transform(memvar->nlab,"999,999.99") color memvar->colorarray[33]
@ 19,37 say "Registration . . . . . . . : "+transform(memvar->nreg,"999,999.99") color memvar->colorarray[33]
@ 20,37 say "Miscellaneous  . . . . . . : "+transform(memvar->nmisc,"999,999.99") color memvar->colorarray[33]
@ 21,37 say "Total Assessment . . . . . : "+transform(memvar->ntotass,"999,999.99") color memvar->colorarray[33]
@ 22,37 say "Status . . . . . . . . . . : "+if(ayytassp->asstag == "C","Changed","Created") color memvar->colorarray[33]
return(nil)

static function record(cacctno,cterm)
if ! fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        return(.f.)
endif
if ayytassp->(dbseek(cacctno))
        ayytassp->(reclock())
else
        ayytassp->(recycle())
endif
ayytassp->assidno       := cacctno
ayytassp->asscolcod     := memvar->ccolcode
ayytassp->assyrlevl     := memvar->cyrlevl
ayytassp->asscls        := memvar->ccls
ayytassp->asssyt        := cterm
ayytassp->assenrdte     := memvar->denr
ayytassp->assfeeyr      := memvar->cfeeyr
ayytassp->assfeeunt     := memvar->nfeeunit
ayytassp->assunt        := memvar->nunits
ayytassp->asstui        := memvar->ntuition
ayytassp->assreg        := memvar->nreg
ayytassp->asslab        := memvar->nlab
ayytassp->assmisc       := memvar->nmisc
ayytassp->asstotal      := memvar->ntotass
ayytassp->asscrtdte     := date()
ayytassp->asspstdte     := date()
ayytassp->asscusrid     := substr(memvar->cusername,1,10)
ayytassp->asstag        := if(ayytassp->asstag == " ",_POSTED,_CHANGED)
ayytassp->(dbcommit())
ayytassp->(dbunlock())

a999accp->(dbseek(cacctno))
a999accp->(reclock())
a999accp->accfeeunt     := memvar->nfeeunit
a999accp->accsytunt     := memvar->nunits
a999accp->accsyttui     := memvar->ntuition
a999accp->accsytmisc    := memvar->nmisc
a999accp->accsytlab     := memvar->nlab
a999accp->accsytoth     := memvar->nreg
a999accp->accsytass     := memvar->ntotass
a999accp->accsyttot     := memvar->ntotass
a999accp->accduetot     := memvar->ntotass + a999accp->accbalold - a999accp->accadj - a999accp->accsytadsc
a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
a999accp->(dbcommit())
a999accp->(dbunlock())
keyboard(chr(K_ESC))
return(nil)

static function initvar()
memvar->denr            := date()
memvar->nfeeunit        := 0
memvar->nunits          := 0
memvar->ntuition        := 0
memvar->nlab            := 0
memvar->nreg            := 0
memvar->noth            := 0
memvar->nmisc           := 0
memvar->ntotass         := 0
memvar->cstatus         := space(01)
memvar->cfeeyr          := space(02)
memvar->clname          := space(15)
memvar->cfname          := space(24)
memvar->cmname          := space(01)
memvar->ccourseyr       := space(10)
memvar->ccolcode        := space(02)
memvar->cyrlevl         := space(01)
memvar->ccls            := space(01)
return(nil)

*------------------------------------------------------------------------------*

function asstoacct()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,;
      cterm,cname,cacctno,ayytassp,lrecord:="Y",cvar:=""
private nlast,nrec

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))

do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Mirror Assessment File to Account File  ")
        commandline("³           F4 - View Term File        ³           ESC - Previous              ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  C"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+cterm+"assp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        ** begin process **
        showretrieving()
        count to memvar->nlast
        restscr(aentryscr)
        statusbar()
        ayytassp->(dbgotop())
        do while ! ayytassp->(eof())
                showprogress()
                if a999accp->(dbseek(ayytassp->assidno))
                        a999accp->(reclock())
                        a999accp->accsyt        := ayytassp->asssyt+"  "
                        a999accp->accfeeunt     := ayytassp->assfeeunt
                        a999accp->accsytunt     := ayytassp->assunt
                        a999accp->accsyttui     := ayytassp->asstui
                        a999accp->accsytmisc    := ayytassp->assmisc
                        a999accp->accsytlab     := ayytassp->asslab
                        a999accp->accsytoth     := ayytassp->assreg
                        a999accp->accsytass     := ayytassp->asstotal
                        a999accp->accsyttot     := ayytassp->asstotal - a999accp->accsytadsc
                        a999accp->accduetot     := a999accp->accsyttot + a999accp->accbalold + a999accp->accadj
                        a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
                if nextkey() == K_ESC
                        exit
                endif
                ayytassp->(dbskip())
        enddo
        closewcheck(aprv2setup)
        fask(18,"  Processing completed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*

function resetall()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,;
      cterm,cname,cyytenrp,ayytpayp,lrecord:="Y",cvar:="",;
      namtpd,nadjust,noldacct,ndisc
private nlast,nrec

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))

do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Reset Students Account Master File  ")
        commandline("³           F4 - View Term File        ³           ESC - Previous              ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("a"+cterm+"payp.dbf")
                fask(10,"  C"+cterm+"PAYP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytpayp  := "a"+cterm+"payp"
        cyytenrp  := "c"+cterm+"enrp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytpayp,"ayytpayp",_DBF_SHARED,,2},;
                                   {,,cyytenrp,"cyytenrp",_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        ** begin process **
        showretrieving()
        count to memvar->nlast
        restscr(aentryscr)
        statusbar()
        cyytenrp->(dbgotop())
        do while ! cyytenrp->(eof())
                showprogress()
                namtpd := noldacct := nadjust := ndisc := 0
                ayytpayp->(sx_setscope(_TOP_SCOPE   ,"2"+cyytenrp->enridno))
                ayytpayp->(sx_setscope(_BOTTOM_SCOPE,"2"+cyytenrp->enridno))
                ayytpayp->(dbgotop())
                do while ! ayytpayp->(eof())
                        do case
                                case ayytpayp->paytag == _POSTED
                                        namtpd += ayytpayp->payamt
                                case ayytpayp->paytag == _FORWARDED
                                        if ayytpayp->payamt < 0
                                                nadjust += ayytpayp->payamt
                                        elseif ayytpayp->payamt > 0
                                                noldacct += ayytpayp->payamt
                                        endif
                                case ayytpayp->paytag == _DISCOUNT
                                        ndisc += ayytpayp->payamt
                                case ayytpayp->paytag == _ADJUSTMENT
                                        nadjust += ayytpayp->payamt
                                case ayytpayp->paytag == _SHORT_TERM
                                        nadjust += ayytpayp->payamt
                        endcase
                        if nextkey() == K_ESC
                                exit
                        endif
                        ayytpayp->(dbskip())
                enddo
                ayytpayp->(clearscope())

                if nextkey() == K_ESC
                        exit
                endif

                a999accp->(dbseek("2"+cyytenrp->enridno))
                a999accp->(reclock())
                a999accp->accbalold     := noldacct
                a999accp->accadj        := nadjust
                a999accp->accsytadsc    := ndisc
                a999accp->accduetot     := a999accp->accsytass + noldacct + nadjust - ndisc
                a999accp->accamtpd      := namtpd
                a999accp->accbaltot     := a999accp->accduetot - namtpd
                a999accp->(dbcommit())
                a999accp->(dbunlock())

                cyytenrp->(dbskip())
        enddo
        fask(18,"  Processing completed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*

function dissolved()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprv1setup,aprv2setup,cprocsts,lexist:=.f.,aentryscr,;
      cterm,cname,cacctno,ayytassp,lrecord:="Y",cvar:=""
private nlast,nrec

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
cterm:=space(len(term->code))

do while .t.
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Mirror Assessment File to Account File  ")
        commandline("³           F4 - View Term File        ³           ESC - Previous              ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term  :";
                color memvar->colorarray[02];
                get cterm pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(term->name)+" was already closed.   ;"+;
                        "             No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! fask(10,"   Proceed processing ?   ",{" Yes "," No  "},memvar->colorarray[05])==1
                loop
        endif
        @ 02,21 say "- "+term->name
        cname := alltrim(term->name)
        if ! file("a"+cterm+"assp.dbf")
                fask(10,"  C"+cterm+"ASSP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr := savescr(01,00,24,79)
        ayytassp  := "a"+cterm+"assp"
        if(aprv2setup:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,ayytassp,"ayytassp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        ** begin process **
        showretrieving()
        count to memvar->nlast
        restscr(aentryscr)
        statusbar()
        ayytassp->(dbgotop())
        do while ! ayytassp->(eof())
                showprogress()
                if a999accp->(dbseek(ayytassp->assidno))
                        a999accp->(reclock())
                        a999accp->accsyt        := ayytassp->asssyt+"  "
                        a999accp->accfeeunt     := ayytassp->assfeeunt
                        a999accp->accsytunt     := ayytassp->assunt
                        a999accp->accsyttui     := ayytassp->asstui
                        a999accp->accsytmisc    := ayytassp->assmisc
                        a999accp->accsytlab     := ayytassp->asslab
                        a999accp->accsytoth     := ayytassp->assreg
                        a999accp->accsytass     := ayytassp->asstotal
                        a999accp->accsyttot     := ayytassp->asstotal - a999accp->accsytadsc
                        a999accp->accduetot     := a999accp->accsyttot + a999accp->accbalold + a999accp->accadj
                        a999accp->accbaltot     := a999accp->accduetot - a999accp->accamtpd
                        a999accp->(dbcommit())
                        a999accp->(dbunlock())
                endif
                if nextkey() == K_ESC
                        exit
                endif
                ayytassp->(dbskip())
        enddo
        closewcheck(aprv2setup)
        fask(18,"  Processing completed.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*------------------------------------------------------------------------------*
function globeacc()
local getlist := {}, alastscr, nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,cprocsts,ccolcode:="UC",aentryscr

private cdummy := "sterm"+strzero(memvar->naccess,2),sterm

if(aopen1files := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
alastscr := savescr(01,00,24,79)
do while .t.
        restscr(alastscr)
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Print Student Balances by Term  ")
        commandline("³           F4 - View Term             ³           ESC - Previous              ³")
        @ 03,01 say replicate("Ä",78)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file("/crunlib/"+"c"+memvar->cterm+"enrp.dbf")
                fask(10,"  C"+memvar->cterm+"ENRP.DBF not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        memvar->cdesc := term->name
        @ 02,20 say "- "+term->name
        cyytenrp := "c"+memvar->cterm+"enrp"

        if(aopen2files := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                                      {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"}})) == nil
                return(nil)
        endif

        if whereprint({||pglobeacc(ccolcode)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
        closewcheck(aopen2files)

enddo
restscr(alastscr)
closewcheck(aopen1files)
return(nil)

function pglobeacc(ccolcode)
local abtext := {}, ncol, nmaxcol := 80, npage := 0

cyytenrp->(dbgotop())
do while ! cyytenrp->(eof())
        fask(10,"  Processing student "+cyytenrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if a999accp->(dbseek("1"+cyytenrp->enridno))
                if ! alltrim(str(a999accp->accbaltot,11,2)) == "0.00"
                        @ prow()+01,00 say '"'+cyytenrp->enridno+'";"'+;
                        transform(a999accp->accbaltot,"@Z 999,999.99")+'";"  "'
                endif
        endif
        if nextkey() == K_ESC
                exit
        endif

        cyytenrp->(dbskip())
enddo
return(nil)

*------------------------------------------------------------------------------*

