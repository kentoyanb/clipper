* Program       :  CASH.PRG  //OnLine Cashiering System
* Author        :  jHUN bENLOT and tOPE fLORENTINO (c) Dec 2001
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function mainprog(ccolor,cunit)
local aprvsetup, ldeleted, lcapslock := capslock(), lnumlock := numlock()
private colorarray := "", lcolor, ;
        nbrowwait := 10, ;
        cspooltxt := "REPORT" + strzero(n_stanum(), 2), ;
        cusername, ccompanyname, csysname, cpassword, nrec, clevel, naccess

if ( aprvsetup := openwcheck( { { , , "para" , , _DBF_SHARED, , } } ) ) == nil
        return(nil)
endif
para->(dbgotop())
para->(reclock())
memvar->ccompanyname := para->company
memvar->csysname     := para->sysname
memvar->naccess      := para->access
if para->access == 99
        para->access := 0
else
        para->access := para->access + 1
endif
para->(dbcommit())
para->(dbunlock())
closewcheck(aprvsetup)

capslock(.t.); numlock(.t.)
ldeleted := set(_SET_DELETED, .t.)
sx_autoshare(0)
set scoreboard off
setcancel(.f.)
set talk off
set epoch to 1960
set century on
set deleted on
if cunit!=nil
        cunit := upper(cunit)
if usefile( , , "user.fil", "user", _DBF_SHARED, , )
        if ! file("user.cdx")
                index on user->u_logname + user->u_password tag user1 of user.cdx
        endif
        if fillcolorarray(memvar->lcolor := if(ccolor == nil, testcolor(), if(upper(substr(ccolor,1,4)) == "MONO", .f., .t.)))
        endif
        user->(sx_settagorder(1))
        do while validuser()
                memvar->cuserrights := constring(user->u_rights, "A", len(user->u_rights))
                *if fillcolorarray(memvar->lcolor := if(ccolor == nil, testcolor(), if(upper(substr(ccolor,1,4)) == "MONO", .f., .t.)))
                        capslock(.t.); numlock(.t.)
                        cash(cunit)
                *endif
        enddo
endif
endif
capslock(lcapslock); numlock(lnumlock); set(_SET_DELETED, ldeleted)
dbcloseall()
setcolor("w/n")
clrscr(7,5000)
outexpr(20, 00, "Program Terminated...")
setpos(22, 00)
return(nil)


function cash(cunit)
local nmainchoice, ccmdline, cwaitscr, nlastcursor, clastcolor, ;
      bentry, breports, butility, bmaintenance
scroll()
clastcolor   := setcolor()
cwaitscr     := savescr(00,00,24,79)
nlastcursor  := setcursor(0)
dispbox(00,00,24,79, space(09), memvar->colorarray[01])        // plain

@ 03,14 say "  ÜÛÛÛÜ                ßÛÛ   ÜÜ                     " color memvar->colorarray[51]
@ 04,14 say " ÛÛİ ŞÛÛ                ÛÛ   ßß                     " color memvar->colorarray[51]
@ 05,14 say "ÛÛÛ   ÛÛÛ  ßÛÛ ÜÛÛÜ     ÛÛ  ßÛÛ  ßÛÛ ÜÛÛÜ     ÜÛÛÛÛÜ" color memvar->colorarray[51]
@ 06,14 say "ÛÛÛ   ÛÛÛ   ÛÛÛß ÛÛÛ    ÛÛ   ÛÛ   ÛÛÛß ÛÛÛ   ÛÛÛ  ÛÛ" color memvar->colorarray[51]
@ 07,14 say "ßßß   ßßß   ßß   ßßß    ßß   ßß   ßß   ßßß   ßßßßßßß" color memvar->colorarray[51]
@ 08,14 say " ßß   ßß    ßß   ßßß    ßß   ßß   ßß   ßßß   ßßß    " color memvar->colorarray[51]
@ 09,14 say "   ßßß     ßßß   ßßßß  ßßß  ßßß  ßßß   ßßßß    ßßßßß" color memvar->colorarray[51]

draw_box1(10,10,16,70,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 11,15 say "ÛÛßß ÛÛßÛÛ ÛÛßß ÛÛ ÛÛ ÛÛ ÛÛßß ÛÛßÛÛ ÛÛ ÛÜßÛÛ ÛÛßÛÛ" color memvar->colorarray[37]
@ 12,15 say "ÛÛ   ÛÛ ÛÛ ÛÛ   ÛÛ ÛÛ    ÛÛ   ÛÛ ÛÛ    ÛÛ ÛÛ ÛÛ   " color memvar->colorarray[37]
@ 13,15 say "ÛÛ   ÛÛßÛÛ ßßÛÛ ÛÛßÛÛ ÛÛ ÛÛßß ÛÛßÛß ÛÛ ÛÛ ÛÛ ÛÛ ßÛ" color memvar->colorarray[37]
@ 14,15 say "ÛÛ   ÛÛ ÛÛ   ÛÛ ÛÛ ÛÛ ÛÛ ÛÛ   ÛÛ Û  ÛÛ ÛÛ ÛÛ ÛÛ  Û" color memvar->colorarray[37]
@ 15,15 say "ÛÛÜÜ ÛÛ ÛÛ ÜÜÛÛ ÛÛ ÛÛ ÛÛ ÛÛÜÜ ÛÛ ÛÛ ÛÛ ÛÛ ÛÛ ÛÛÜÜÛ" color memvar->colorarray[37]

@ 17,18 say "ÜÜÜÜÜ  ÜÜ  Ü  ÜÜÜÜÜ  ÜÜÜÜÜ  ÜÜÜÜÜ  ÜÜÜ   ÜÜÜ" color memvar->colorarray[36]
@ 18,18 say "ÜÜ  Ü  ÜÜ  Ü  ÜÜ  Ü    ÜÜ   ÜÜ     ÜÜ Ü Ü ÜÜ" color memvar->colorarray[36]
@ 19,18 say "ÜÜ     ÜÜ  Ü  ÜÜ       ÜÜ   ÜÜ     ÜÜ  Ü  ÜÜ" color memvar->colorarray[36]
@ 20,18 say "ÜÜÜÜÜ  ÜÜÜÜÜ  ÜÜÜÜÜ    ÜÜ   ÜÜÜÜÜ  ÜÜ  Ü  ÜÜ" color memvar->colorarray[36]
@ 21,18 say "   ÛÛ    ÛÛ      ÛÛ    ÛÛ   ÛÛ     ÛÛ  Û  ÛÛ" color memvar->colorarray[36]
@ 22,18 say "ÜÜÜÛÛ    ÛÛ   ÜÜÜÛÛ    ÛÛ   ÛÛÜÜÜ  ÛÛ     ÛÛ" color memvar->colorarray[36]

dispbox(00,00,01,79, space(09), memvar->colorarray[01])
updatedate()
outexpr(00, 00, "User:", memvar->colorarray[01])
outexpr(00, 06, memvar->cusername, memvar->colorarray[01])
outexpr(00, 24, "Current Date:", memvar->colorarray[01])
outexpr(00, 64, "Time:", memvar->colorarray[01])
outexpr(00, 70, clock("on", "12 hour", "seconds"), memvar->colorarray[01])
commandline("³ Alt+A-About ³ Alt+C-Calculator ³ "+chr(27)+chr(24)+chr(25)+chr(26)+" to Navigate ³ "+"Ù-Select ³ ESC-Previous ³")
dispbox(01,00,01,79, space(9), memvar->colorarray[06])

__keyboard(chr(K_ENTER))
set wrap on
bentry       := optionentry(cunit,memvar->cusername)
breports     := optionreport(cunit,memvar->cusername)
butility     := optionutility()
bmaintenance := optionmaintenance()
setkey(K_ALT_C,{||actcalculator()})
setkey(K_ALT_A,{||about()})
do while ! ( nmainchoice := selectmenu ( { { 01, 02, " Entry   ",,,{ || rights( "[1]" ) }, bentry,, }, ;
                                           { 01, 11, " Report  ",,,{ || rights( "[2]" ) }, breports,,}, ;
                                           { 01, 22, " Utility ",,,{ || rights( "[3]" ) }, butility,, }, ;
                                           { 01, 33, " Maintenance ",,,{ || rights( "[4]" ) }, bmaintenance,, } }, ;
                                         { || nil },,, memvar->colorarray[03],,,,, ;
                                         gettrigger( memvar->colorarray[03] ) ) ) == 0
enddo
setkey(K_ALT_C, nil)
setkey(K_ALT_A, nil)
outexpr(00, 68, clock("off", "12 hour", "seconds"), memvar->colorarray[01])
setcolor(clastcolor); setcursor(nlastcursor)
clrscr(9,5000); restscr(cwaitscr)
return(nil)

static function optionentry(cunit,cuser)
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 02, "  ~Payment Entry     ",,, { || rights( "[1,1]" ) },  { || payent(cunit) },, } )
aadd( aelements, { ncurrline++, 02, "  ~Chart Entry       ",,, { || rights( "[1,2]" ) },  { || chartent() },, } )
aadd( aelements, { ncurrline++, 02, "  ~Update Payment Records   ",,, { || rights( "[1,3]" ) },  { || payupdate() },, } )
aadd( aelements, { ncurrline++, 02, "  ~Accounting Payment Entry   ",,, { || rights( "[1,4]" ) },  { || payentry() },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 01, ncurrline, 04 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionreports(cunit,cuser)
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1

//NEW ADD ON MENUSTRIP 2-13-2018

aadd( aelements, { ncurrline++, 11, "  ~Media Report                     ",,, { || rights( "[2,1]" ) },  { || mediaprnt(cunit,cuser) },, } )
aadd( aelements, { ncurrline++, 11, "  Media ~Report [Selective]         ",,, { || rights( "[2,2]" ) },  { || media_sel(cunit,cuser) },, } )
aadd( aelements, { ncurrline++, 11, "  ~Departmental Report              ",,, { || rights( "[2,3]" ) },  { || deptprnt(cunit,cuser) },, } )
aadd( aelements, { ncurrline++, 11, "  Departmental Report [~Selective]  ",,, { || rights( "[2,4]" ) },  { || dept_sel(cunit,cuser) },, } )

aadd( aelements, { ncurrline++, 11, "  Official Receipt ~Viewer by OR #",,, { || rights( "[2,5]" ) },  { || or_view(cunit,cuser) },, } )

aadd( aelements, { ncurrline++, 11, "  Official Receipt Viewer by ~ID #",,, { || rights( "[2,6]" ) },  { || byidnum_or_view(cunit,cuser) },, } )

aadd( aelements, { ncurrline++, 11, "  Re-~Print Official Receipt  ",,, { || rights( "[2,7]" ) },  { || re_printOR(cunit,cuser) },, } )

aadd( aelements, { ncurrline++, 11, "  ~School Income  ",,, { || rights( "[2,8]" ) },  { || feesincome() },, } )
aadd( aelements, { ncurrline++, 11, "  Report by ~Chart Code  ",,, { || rights( "[2,9]" ) },  { || chartcodeincome() },, } )
aadd( aelements, { ncurrline++, 11, "  ~Account Information  ",,, { || rights( "[2,10]" ) },  { || acctinfo() },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 10, ncurrline, 13 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionutility()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 22, "  Cas~h Counting            ",,, { || rights( "[3,1]" ) },  { || cashcount() },, } )
aadd( aelements, { ncurrline++, 22, "  ~View Text/Prn File       ",,, { || rights( "[3,2]" ) },  { || viewtextfile() },, } )
aadd( aElements, { ncurrline++, 22, "  Change ~Password          ",,, { || rights( "[3,3]" ) },  { || changepassword() },, } )
aadd( aelements, { ncurrline++, 22, "  ~User Utility             ",,, { || rights( "[20,20]" ) },{ || userutility() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Create Data Base File    ",,, { || rights( "[3,4]" ) },  { || createdatabase() },, } )
aadd( aelements, { ncurrline++, 22, "  Movin~g Pegs              ",,, { || rights( "[3,5]" ) },  { || ft_pegs() },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 21, ncurrline, 22 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionmaintenance()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 33, "  ~File Editing   ",,, { || rights( "[4,1]" ) }, { || choicefile() },, } )
aadd( aelements, { ncurrline++, 33, "  ~Rebuild Files  ",,, { || rights( "[4,2]" ) }, { || buildfile() },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 32, ncurrline, 33 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26], memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function validuser()
local getlist := {}, ascrpassword, nctr := 0, lconfirm, lintensity, nlastcursor
scroll()

boxshadow(00,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[25])

draw_box2(01,04,08,75,memvar->colorarray[25],memvar->colorarray[26],,.f.)
draw_box3(08,13,13,65,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 08,14 say replicate(" ",51) color memvar->colorarray[25]

draw_box2(02,07,07,16,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,09 say "ÛÛ  ÛÛ" color memvar->colorarray[41]
@ 04,09 say "ÛÛ  ÛÛ" color memvar->colorarray[41]
@ 05,09 say "ÛÛ  ÛÛ" color memvar->colorarray[41]
@ 06,09 say "ßÛÜÜÛß" color memvar->colorarray[41]

draw_box2(02,17,07,26,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,19 say "ÜÛßßßÛ" color memvar->colorarray[41]
@ 04,19 say "ÛÛ   " color memvar->colorarray[41]
@ 05,19 say "ÛÛ   " color memvar->colorarray[41]
@ 06,19 say "ßÛÜÜÜÛ" color memvar->colorarray[41]

draw_box1(03,28,06,32,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 04,29 say "ÜßÜ" color memvar->colorarray[43]
@ 05,29 say "ßÜß" color memvar->colorarray[43]

draw_box2(02,34,07,44,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,36 say "ÛÛÜ ÜÛÛ" color memvar->colorarray[42]
@ 04,36 say "ÛÛŞÛİÛÛ" color memvar->colorarray[42]
@ 05,36 say "ÛÛ Û ÛÛ" color memvar->colorarray[42]
@ 06,36 say "ÛÛ   ÛÛ" color memvar->colorarray[42]

draw_box2(02,45,07,53,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,47 say "ÛÛßßÛ" color memvar->colorarray[42]
@ 04,47 say "ÛÛÜÜ " color memvar->colorarray[42]
@ 05,47 say "ÛÛ   " color memvar->colorarray[42]
@ 06,47 say "ÛÛÜÜÛ" color memvar->colorarray[42]

draw_box2(02,54,07,63,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,56 say "ÛßÛÛßÛ" color memvar->colorarray[42]
@ 04,56 say "  ÛÛ  " color memvar->colorarray[42]
@ 05,56 say "  ÛÛ  " color memvar->colorarray[42]
@ 06,56 say "  ÛÛ  " color memvar->colorarray[42]

draw_box2(02,64,07,72,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,66 say "ÜÛßßÛ" color memvar->colorarray[42]
@ 04,66 say "ÛÛ   " color memvar->colorarray[42]
@ 05,66 say "ÛÛ   " color memvar->colorarray[42]
@ 06,66 say "ßÛÜÜÛ" color memvar->colorarray[42]

draw_box1(08,17,12,61,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 09,20 say "Online Cashiering System - Version 1.00"color memvar->colorarray[43]
@ 10,20 say "          Copyright (C)  2001          " color memvar->colorarray[43]
@ 11,20 say "          All Rights Reserved          " color memvar->colorarray[43]

draw_box2(15,17,22,62,memvar->colorarray[25],memvar->colorarray[26],,.f.)
draw_box2(16,21,18,40,memvar->colorarray[25],memvar->colorarray[26],,.f.)
outexpr(17,23,"Enter User Name:",memvar->colorarray[41])
draw_box2(19,21,21,40,memvar->colorarray[25],memvar->colorarray[26],,.f.)
outexpr(20,23,"Enter Password :",memvar->colorarray[41])
draw_box1(16,42,18,58,memvar->colorarray[25],memvar->colorarray[26],,.f.)
draw_box1(19,42,21,58,memvar->colorarray[25],memvar->colorarray[26],,.f.)

ascrpassword      := savescr()
lconfirm          := set(_SET_CONFIRM)
lintensity        := set(_SET_INTENSITY)
nlastcursor       := setcursor()
memvar->cusername := space(len(user->u_logname))
do while .t.
        restscr(ascrpassword)
        memvar->cpassword := space(len(user->u_password))
        set(_SET_CONFIRM, .t.); set(_SET_INTENSITY, .f.); setcursor(1)
        @ 17, 43 gget memvar->cusername picture "@!" color memvar->colorarray[43]
        @ 20, 43 gget memvar->cpassword picture "@!" password chr(1) color memvar->colorarray[43]
        read /*TimeOut 15 ExitEvent scrsaver( MemVar-> cUserName, cPassword ) Warning 10 */
        setcursor(nlastcursor); set(_SET_CONFIRM, lconfirm); set(_SET_INTENSITY, lintensity)
        if lastkey() == K_ESC
                return(.f.)
        endif
        if user->(dbseek(constring(memvar->cusername, "C", len(memvar->cusername)) + ;
                         constring(memvar->cpassword, "C", len(memvar->cpassword))))
                memvar->clevel  := user->u_level
                return(.t.)
        endif
        tone(2000,2)
        if nctr >= 3
                outexpr(14, 22, "...Beware of unauthorized users !!! ...", "*r/bg")
                inkey(5)
                return(.f.)
        endif
        outexpr(14, 24, "...Invalid User/Password !!! ...", "*r/bg")
        inkey(2)
        outexpr(14, 24, "                                ", "bg/bg")
        ++nctr
enddo
return(.f.)

function scrsaver(cname,cpasswrd)
Local cLastScr := SaveScr( 00, 00, 24, 79 )
//Scroll( 00, 00, 24, 79 )
//blankscr3(15)
//__run("\PUBLIC\BALLS")
//__run("\PUBLIC\EXPLODE")
RestScr( cLastScr )
If Empty( cName )
        SetPos(06, 18)
Else
        SetPos(07, 18)
EndIf
return(nil)

/*
Read TimeOut 15 ExitEvent BlankScr3(-3) Warning 10  /* BallScreen( MemVar-> cUserName, cPassword ) BlankScr3(-3) Warning 10 UBlank() */
Function BallScreen( cName, cPassWrd )
Local cLastScr := SaveScr( 00, 00, 24, 79 )
Scroll( 00, 00, 24, 79 )
*__Run( "STARS" )
*__Run( "SKY" )
RestScr( cLastScr )
If Empty( cName )
        SetPos(06, 18)
Else
        SetPos(07, 18)
EndIf
Return ( Nil )
*/

*------------------------------------------------------------------------------*

function about()
setcursor (.f.)
acode := savescreen(00,00,24,79)
   draw_box2(04,16,18,63,memvar->colorarray[30],memvar->colorarray[31])
   draw_box1(05,18,17,61,memvar->colorarray[30],memvar->colorarray[31])
   @ 06,22 say "University of Cebu" color memvar->colorarray[44]
   @ 07,22 say "Maritime Education and Training Center" color memvar->colorarray[44]
   @ 08,22 say "Alumnos, Mambaling, Cebu City" color memvar->colorarray[44]
   @ 09,22 say "6000 Philippines" color memvar->colorarray[44]
   @ 11,22 say "Cashiering System" color memvar->colorarray[45]
   @ 12,22 say "Version 3.00" color memvar->colorarray[45]
   @ 14,22 say "(C) Copyright 2001" color memvar->colorarray[44]
   inkey(0)
restscreen(00,00,24,79,acode)
return nil

*-----------------------------------------------------------------------------*
