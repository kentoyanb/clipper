* Program       :  CRS.PRG  //College Registration System
* Author        :  Lorenzo D. Benlot Jr. and Randy F. Santizo (c) July 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"


function mainprog(ccolor)
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
                        crs1()
                *endif
        enddo
endif
capslock(lcapslock); numlock(lnumlock); set(_SET_DELETED, ldeleted)
dbcloseall()
setcolor("w/n")
clrscr(7,5000)
outexpr(20, 00, "Program Terminated...")
setpos(22, 00)
return(nil)


function crs1()
local nmainchoice, ccmdline, cwaitscr, nlastcursor, clastcolor, ;
      bentry, bupdate, breports, butility, bmaintenance, baccessories
scroll()
clastcolor   := setcolor()
cwaitscr     := savescr(00,00,24,79)
nlastcursor  := setcursor(0)
set key K_F2 to popdate

*dispbox(00,00,24,79, if(memvar->lcolor, "²²²²²²²²²", "°°°°°°°°°"), memvar->colorarray[15])
*dispbox(00,00,24,79, space(09), memvar->colorarray[01])        // plain
dispbox(00,00,24,79, REPLICATE(CHR(206),9), memvar->colorarray[50])

dispbox(00,00,01,79, space(09), memvar->colorarray[01])
updatedate()
outexpr(00, 00, "User:", memvar->colorarray[01])
outexpr(00, 06, memvar->cusername, memvar->colorarray[01])
outexpr(00, 24, "Current Date:", memvar->colorarray[01])
outexpr(00, 64, "Time:", memvar->colorarray[01])
outexpr(00, 70, clock("on", "12 hour", "seconds"), memvar->colorarray[01])
&&CommandLine( "³  Use " + Chr(27) + Chr(24) + Chr(25) + Chr(26) + " to navigate   " + "³      Ù - to select      ³     ESC - Previous      ³" )
&&commandline("³  Alt+C - Calculator ³  " + chr(27) + chr(24) + chr(25) + chr(26) + " to Navigate  ³" + "  Ù - to Select  ³ ESC - Previous ³")
commandline("³ F2-Calendar ³ Alt+C-Calculator ³ "+chr(27)+chr(24)+chr(25)+chr(26)+" to Navigate ³ "+"Ù-Select ³ ESC-Previous ³")
dispbox(01,00,01,79, space(9), memvar->colorarray[06])

__keyboard(chr(K_ENTER))
set wrap on
bentry       := optionentry()
breports     := optionreport()
butility     := optionutility()
bmaintenance := optionmaintenance()
baccessories := optionaccessories()
setkey(K_ALT_C,{||actcalculator()})
//setkey(K_F1,{||help()})
do while ! ( nmainchoice := selectmenu ( { { 01, 02, " Entry   ",,,{ || rights( "[1]" ) }, bentry,, }, ;
                                           { 01, 11, " Print   ",,,{ || rights( "[2]" ) }, breports,,}, ;
                                           { 01, 22, " Utility ",,,{ || rights( "[3]" ) }, butility,, }, ;
                                           { 01, 33, " Maintenance ",,,{ || rights( "[4]" ) }, bmaintenance,, }, ;
                                           { 01, 47, " Accessories ",,,{ || rights( "[5]" ) }, baccessories,, } }, ;
                                         { || nil },,, memvar->colorarray[03],,,,, ;
                                         gettrigger( memvar->colorarray[03] ) ) ) == 0
enddo
setkey(K_ALT_C, nil)
//setkey(K_F1, nil)
outexpr(00, 68, clock("off", "12 hour", "seconds"), memvar->colorarray[01])
setcolor(clastcolor); setcursor(nlastcursor)
clrscr(9,5000); restscr(cwaitscr)
return(nil)

static function optionentry()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 02, "  ~Enrollment Entry                ",,, { || rights( "[1,1]" ) }, { || enroll() },, } )
aadd( aelements, { ncurrline++, 02, "  Student ~Directory Entry         ",,, { || rights( "[1,2]" ) }, { || stdinf() },, } )
aadd( aelements, { ncurrline++, 02, "  ~Grade Entry                    ",,, { || rights( "[1,3]" ) },;
        { || SelectMenu( { { 07, 10, "   ~Midterm Grade   ",,, { || rights( "[1,3,1]" ) }, {|| midgrade() },, }, ;
                           { 08, 10, "   ~Final Grade     ",,, { || rights( "[1,3,2]" ) }, {|| fingrade() },,}},;
        { || draw_box2(06,09,09,29,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 02, "  ~Schedule Entry                  ",,, { || rights( "[1,4]" ) }, { || schedule() },, } )
aadd( aelements, { ncurrline++, 02, "  Instructors ~Registration        ",,, { || rights( "[1,6]" ) }, { || insinf() },, } )
aadd( aelements, { ncurrline++, 02, "  Instructors ~Loading             ",,, { || rights( "[1,7]" ) }, { || load() },, } )
aadd( aelements, { ncurrline++, 02, "  School ~Term File                ",,, { || rights( "[1,8]" ) }, { || term() },, } )
aadd( aelements, { ncurrline++, 02, "  ~Curriculum File Entry           ",,, { || rights( "[1,9]" ) }, { || currp() },, } )
aadd( aelements, { ncurrline++, 02, "  D~issolved Schedule Entry        ",,, { || rights( "[1,A]" ) }, { || disolve() },, } )
aadd( aelements, { ncurrline++, 02, "  ~Apprenticeship Data Entry       ",,, { || rights( "[1,B]" ) }, { || apprenticemate() },, } )
aadd( aelements, { ncurrline++, 02, "  Ran~k Code Entry                 ",,, { || rights( "[1,C]" ) }, { || rank() },, } )
aadd( aelements, { ncurrline++, 02, "  Graduates and ~Officers Entry    ",,, { || rights( "[1,D]" ) }, { || rankent() },, } )
return( { || selectmenu( aelements, { || draw_box2(nstartline,01,ncurrline,02+len(aelements[01,03])-1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionreports()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 11, "  ~Students Information        ",,, { || rights( "[2,1]" ) }, ;
        { || SelectMenu( { { 05, 29, "  Study ~Load Printing                 ",,, { || rights( "[2,1,1]" ) }, {|| studyload() },, }, ;
                           { 06, 29, "  Student ~Withdrawn Printing          ",,, { || rights( "[2,1,2]" ) }, {|| withdrawn() },,},;
                           { 07, 29, "  Enrollment ~Statistics (All)         ",,, { || rights( "[2,1,3]" ) }, {|| statistics("A") },,},;
                           { 08, 29, "  Enrollment Statistics (~Confirm)     ",,, { || rights( "[2,1,4]" ) }, {|| statistics("C")},,},;
                           { 09, 29, "  Enr~ollment List Printing            ",,, { || rights( "[2,1,5]" ) }, {|| enrlstprn() },,},;
                           { 10, 29, "  Enrollment List Printing (S~ubject)  ",,, { || rights( "[2,1,6]" ) }, {|| subjlstprn() },,},;
                           { 11, 29, "  Enrollment List Printing (UC ~Main)  ",,, { || rights( "[2,1,7]" ) }, {|| enrlstucmain() },,},;
                           { 12, 29, "  ~Apprenticeship List Printing        ",,, { || rights( "[2,1,8]" ) }, {|| aprenlist() },,},;
                           { 13, 29, "  Officers List ~Printing              ",,, { || rights( "[2,1,9]" ) }, {|| rankrpt() },,},;
                           { 14, 29, "  Officers Individual Lis~t            ",,, { || rights( "[2,1,A]" ) }, {|| ranklist() },,},;
                           { 15, 29, "  ~Graduate List Printing              ",,, { || rights( "[2,1,B]" ) }, {|| nil },,},;
                           { 16, 29, "  ~Board Passers List Printing         ",,, { || rights( "[2,1,C]" ) }, {|| nil },,},;
                           { 17, 29, "  Boa~rd Passers Summary               ",,, { || rights( "[2,1,D]" ) }, {|| nil },,},;
                           { 18, 29, "  ~Enrollment Statistics w/ Comparison ",,, { || rights( "[2,1,E]" ) }, {|| stats_compared("C") },,}},;
        { || draw_box2(04,28,19,67,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, "  S~chedule Information        ",,, { || rights( "[2,2]" ) }, ;
        { || SelectMenu( { { 06, 29, "  ~Subject Schedule Printing                ",,, { || rights( "[2,2,1]" ) }, {|| subjskdprn() },, }, ;
                           { 07, 29, "  ~Consolidated Schedule (by Time w/inst)   ",,, { || rights( "[2,2,2]" ) }, {|| consolidated() },,},;
                           { 08, 29, "  Consolidated Schedule (by S~ubj w/inst)   ",,, { || rights( "[2,2,3]" ) }, {|| winst() },,},;
                           { 09, 29, "  Consolidated Schedule (by Subj w/o ~inst) ",,, { || rights( "[2,2,4]" ) }, {|| woinst() },,},;
                           { 10, 29, "  ~Available Room Schedule                  ",,, { || rights( "[2,2,5]" ) }, {|| roomskdavail() },,},;
                           { 11, 29, "  Shedule Printing with Specified Si~ze     ",,, { || rights( "[2,2,6]" ) }, {|| disolved() },,},;
                           { 12, 29, "  Conso~lidated Schedule for C.S.U.         ",,, { || rights( "[2,2,7]" ) }, {|| skdforcsu() },,},;
                           { 13, 29, "  ~Generated EDP Code Listing               ",,, { || rights( "[2,2,8]" ) }, {|| genedpcode() },,},;
                           { 14, 29, "  Consolidated Schedule by Room / ~Time     ",,, { || rights( "[2,2,9]" ) }, {|| consroomtime() },,}},;
        { || draw_box2(05,28,15,72,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, "  ~Grade Information           ",,, { || rights( "[2,3]" ) }, ;
        { || SelectMenu( { { 07, 29, "  Grade Printing (~Individual)         ",,, { || rights( "[2,3,1]" ) }, {|| grdindividual() },, }, ;
                           { 08, 29, "  Grade Printing (~Course)             ",,, { || rights( "[2,3,2]" ) }, {|| grdcourse() },,},;
                           { 09, 29, "  Grade Printing (~Ranking)            ",,, { || rights( "[2,3,3]" ) }, {|| compgrdave() },,},;
                           { 10, 29, "  Grade Printing (~Graduating)         ",,, { || rights( "[2,3,4]" ) }, {|| gradegrad()},,},;
                           { 11, 29, "  Grade ~Sheet Printing                ",,, { || rights( "[2,3,5]" ) }, {|| grdshtprn() },,},;
                           { 12, 29, "  Form ~XIX Printing                   ",,, { || rights( "[2,3,6]" ) }, {|| form19()},,},;
                           { 13, 29, "  ~T.O.R. Printing (Graduated Already) ",,, { || rights( "[2,3,7]" ) }, {|| tor()},,},;
                           { 14, 29, "  T.O.R. Printing (Not ~Yet Graduated) ",,, { || rights( "[2,3,7]" ) }, {|| foreval()},,},;
                           { 15, 29, "  T.O.R. Printing (~Main)              ",,, { || rights( "[2,3,8]" ) }, {|| tormain()},,},;
                           { 16, 29, "  Grade ~Evaluation Printing           ",,, { || rights( "[2,3,9]" ) }, {|| foreval()},,},;
                           { 17, 29, "  Grade Printing (S~ubject)            ",,, { || rights( "[2,3,A]" ) }, {|| grdsubj()},,},;
                           { 18, 29, "  Grade Ranking (S~pecial)             ",,, { || rights( "[2,3,B]" ) }, {|| grdspecial()},,},;
                           { 19, 29, "  Grade Printing (R~OTC Individual)    ",,, { || rights( "[2,3,C]" ) }, {|| grdrotc()},,},;
                           { 20, 29, "  Grade Pri~nting (ROTC by Course)     ",,, { || rights( "[2,3,D]" ) }, {|| rotccourse()},,},;
                           { 21, 29, "  Students with ~Failing Grade         ",,, { || rights( "[2,3,E]" ) }, {|| failgrade()},,}},;
        { || draw_box2(06,28,22,67,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, "  ~Instructor(s) Information   ",,, { || rights( "[2,4]" ) }, ;
        { || SelectMenu( { { 08, 29, "  Instructor(s) ~Load Printing              ",,, { || rights( "[2,4,1]" ) }, {|| instload() },, }, ;
                           { 09, 29, "  Instructor(s) Load Printing for ~UC-Main  ",,, { || rights( "[2,4,2]" ) }, {|| loaducmain()},,},;
                           { 10, 29, "  Class List ~Printing (by Instructor)      ",,, { || rights( "[2,4,3]" ) }, {|| cllistbyinst()},,},;
                           { 11, 29, "  ~Class List Printing (by Subject)         ",,, { || rights( "[2,4,4]" ) }, {|| classlist() },,},;
                           { 12, 29, "  Instructors List of ~Subject (Received)   ",,, { || rights( "[2,4,5]" ) }, {|| instsubject() },,},;
                           { 13, 29, "  Class and ~Teachers Program Report        ",,, { || rights( "[2,4,6]" ) }, {|| classteacherprog() },,},;
                           { 14, 29, "  Class List Printing (~Graduating)         ",,, { || rights( "[2,4,7]" ) }, {|| gradclasslist() },,},;
                           { 15, 29, "  Class List Printing (~Year Level)         ",,, { || rights( "[2,4,7]" ) }, {|| classbyyear() },,}},;
        { || draw_box2(07,28,16,72,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 10, ncurrline, 11 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionutility()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 22, "  ~Enrollment Update   ",,, { || rights( "[3,1]" ) },   { || enrolup() },, } )
aadd( aelements, { ncurrline++, 22, "  ~View Text/Prn File  ",,, { || rights( "[3,2]" ) },   { || viewtextfile() },, } )
aadd( aElements, { ncurrline++, 22, "  Change ~Password     ",,, { || rights( "[3,3]" ) },   { || changepassword() },, } )
aadd( aelements, { ncurrline++, 22, "  ~User Utility        ",,, { || rights( "[20,20]" ) }, { || userutility() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Moving Pegs         ",,, { || rights( "[3,4]" ) },   { || ft_pegs() },, } )
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


static function optionaccessories()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 40, "  Update ~Actual Size               ",,, { || rights( "[5,1]" ) }, { || updactsize() },, } )
aadd( aelements, { ncurrline++, 40, "  Upload ~STSP File to TORP File    ",,, { || rights( "[5,2]" ) },;
        { || SelectMenu( { { 11, 35, "     ~All            ",,, { || rights( "[5,2,1]" ) }, {|| uploadall() },, }, ;
                           { 12, 35, "     by ~Student     ",,, { || rights( "[5,2,2]" ) }, {|| uploadbystudent()},,}},;
        { || draw_box2(10,34,13,55,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 40, "  ~Create New Student Number        ",,, { || rights( "[5,3]" ) }, { || newidno() },, } )
aadd( aelements, { ncurrline++, 40, "  Clean-Up ~Room File               ",,, { || rights( "[5,4]" ) }, { || clrrom()},, } )
aadd( aelements, { ncurrline++, 40, "  Change R~oom Number               ",,, { || rights( "[5,5]" ) }, { || chgroom()},, } )
aadd( aelements, { ncurrline++, 40, "  Upload ~ENRP File to ENRR File    ",,, { || rights( "[5,6]" ) }, { || upskdlist()},, } )
aadd( aelements, { ncurrline++, 40, "  Forward ~SKDP to STSP by Student  ",,, { || rights( "[5,7]" ) }, { || skdgrdstud()},, } )
aadd( aelements, { ncurrline++, 40, "  Forward ~SKDP to STSP All         ",,, { || rights( "[5,8]" ) }, { || skdgrade()},, } )
aadd( aelements, { ncurrline++, 40, "  Create ~Data Base File            ",,, { || rights( "[5,9]" ) }, { || createdatabase()},, } )
aadd( aelements, { ncurrline++, 40, "  Upload Permanent File to ~METC    ",,, { || rights( "[5,A]" ) }, { || maintometc()},, } )
aadd( aelements, { ncurrline++, 40, "  Schedule Close/~Warning Report    ",,, { || rights( "[5,B]" ) }, { || closewarning()},, } )
aadd( aelements, { ncurrline++, 40, "  Change ~ID Number                 ",,, { || rights( "[5,C]" ) }, { || nil},, } )
aadd( aelements, { ncurrline++, 40, "  ~Upload Appreticeship Data        ",,, { || rights( "[5,D]" ) },;
        { || SelectMenu( { { 11, 35, "     ~All            ",,, { || rights( "[5,C,1]" ) }, {|| apprenall() },, }, ;
                           { 12, 35, "     by ~Student     ",,, { || rights( "[5,C,2]" ) }, {|| apprenstud()},,}},;
        { || draw_box2(10,34,13,55,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
return( { || selectmenu( aelements, { || draw_box2( nstartline, 39, ncurrline, 40 + len( aelements[ 01, 03 ] ) - 1, ;
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
@ 09,20 say "College Registration System Version 2.1" color memvar->colorarray[43]
@ 10,20 say "        Copyright (c) 1998-1999        " color memvar->colorarray[43]
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
       read //TimeOut 20 ExitEvent scrsaver( MemVar-> cUserName, cPassword ) Warning 10
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
Scroll( 00, 00, 24, 79 )
*__run("\PUBLIC\PSYCHO")
*__run("\PUBLIC\BALLS")
*__run("\PUBLIC\igraph")
*__run("\PUBLIC\EXPLODE")
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
*__Run( "\SOFTWARE\CLIP5\RANDY\MISC\BALLS" )
*__Run( "STARS" )
*__Run( "SKY" )
__Run( "EXPLODE" )
RestScr( cLastScr )
If Empty( cName )
        SetPos(06, 18)
Else
        SetPos(07, 18)
EndIf
Return ( Nil )
*/

*------------------------------------------------------------------------------*
/*
function about()
setcursor (.f.)
acode := savescreen(00,00,24,79)
   draw_box2(04,16,18,63,memvar->colorarray[30],memvar->colorarray[31])
   draw_box1(05,18,17,61,memvar->colorarray[30],memvar->colorarray[31])
   @ 06,22 say "University of Cebu" color memvar->colorarray[44]
   @ 07,22 say "Maritime Education and Training Center" color memvar->colorarray[44]
   @ 08,22 say "Alumnos, Mambaling, Cebu City" color memvar->colorarray[44]
   @ 09,22 say "6000 Philippines" color memvar->colorarray[44]
   @ 11,22 say "College Registration System" color memvar->colorarray[45]
   @ 12,22 say "Version 2.1.0" color memvar->colorarray[45]
   @ 14,22 say "(C) Copyright 1998-1999" color memvar->colorarray[44]
   @ 15,22 say "RenzVine Technology, Philippines" color memvar->colorarray[44]
   @ 16,22 say "in association with Shack Unlimitted" color memvar->colorarray[44]
   inkey(0)
restscreen(00,00,24,79,acode)
return nil
*/
*------------------------------------------------------------------------------*
/*
function Smile(nRow,nCol)
        @ 0,0,nRow,nCol BOX REPLICATE(CHR(1),9)
return (nil)
*/
*------------------------------------------------------------------------------*
/*
function help()
setcursor (.f.)
hcode := savescreen(00,00,24,79)
   draw_box2(03,16,20,63,memvar->colorarray[46],memvar->colorarray[47])
   draw_box1(04,18,19,61,memvar->colorarray[46],memvar->colorarray[47])
   @ 05,20 say "Moving Pegs - Game Help" color memvar->colorarray[48]
   @ 06,20 say "(C) 1999 RenzVine Technology" color memvar->colorarray[48]
   @ 08,20 say "Objective:" color memvar->colorarray[48]
   @ 09,20 say " To illiminate all lighted square" color memvar->colorarray[49]
   @ 10,20 say "  except for one to be left." color memvar->colorarray[49]
   @ 11,20 say " And Presto! you win." color memvar->colorarray[49]
   @ 13,20 say "How to do it?" color memvar->colorarray[48]
   @ 14,20 say " Move the Pegs or the lighted square" color memvar->colorarray[49]
   @ 15,20 say "  by simply jumping to the adjacent" color memvar->colorarray[49]
   @ 16,20 say "  unlighted square or empty box." color memvar->colorarray[49]
   @ 17,20 say " Just like the dama move.  OK.." color memvar->colorarray[49]
   @ 18,20 say " Enter the Peg No. of your move below." color memvar->colorarray[49]
   inkey(0)
restscreen(00,00,24,79,hcode)
return nil
*/
