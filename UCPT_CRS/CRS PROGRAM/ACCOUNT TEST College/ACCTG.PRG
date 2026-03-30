* Program       :  ACCTG.PRG  //Student Accounting System MAIN
* Author        :  Randy F. Santizo and Jun Benlot (c) July 1998
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
        cspooltxt := "REPORT", cusername, ccompanyname, csysname, cpassword, nrec, clevel, naccess

//        cspooltxt := "REPORT" + strzero(n_stanum(), 2), ;

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
cspooltxt += str(para->access)
cspooltxt := strtran(cspooltxt," ","0")
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
                        acctg()
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


function acctg()
local nmainchoice, ccmdline, cwaitscr, nlastcursor, clastcolor, ;
      bentry, bupdate, breports, butility, bmaintenance
scroll()
clastcolor   := setcolor()
cwaitscr     := savescr(00,00,24,79)
nlastcursor  := setcursor(0)
dispbox(00,00,24,79, if(memvar->lcolor, "²²²²²²²²²", "°°°°°°°°°"), memvar->colorarray[15])
draw_box2(03,11,22,68,memvar->colorarray[28],memvar->colorarray[29],,.f.)

draw_box2(04,14,09,22,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 05,16 say "ÛÛßßÛ" color memvar->colorarray[38]
@ 06,16 say "ÛÛÜÜÜ" color memvar->colorarray[38]
@ 07,16 say "   ÛÛ" color memvar->colorarray[38]
@ 08,16 say "ÛÜÜÛÛ" color memvar->colorarray[38]

draw_box1(05,24,09,58,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 06,27 say "ßÛß Û Û ÛßÜ Ûß ÛßÛ ßÛß ÜÛ Ûßß" color memvar->colorarray[37]
@ 07,27 say " Û  Û Û Û Û Ûß Û Û  Û     ßßÛ" color memvar->colorarray[37]
@ 08,27 say " Û  ÛÜÛ ÛÜß ÛÜ Û Û  Û     ÛÜÛ" color memvar->colorarray[37]

draw_box2(10,14,15,22,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 11,16 say "ÛÛßÛÛ" color memvar->colorarray[38]
@ 12,16 say "ÛÛ ÛÛ" color memvar->colorarray[38]
@ 13,16 say "ÛÛßÛÛ" color memvar->colorarray[38]
@ 14,16 say "ÛÛ ÛÛ" color memvar->colorarray[38]

draw_box1(11,24,15,63,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 12,27 say "ÛßÛ ÛßÛ ÛßÛ Û Û ÛßÛ ßÛß Û ÛßÛ ÛßÛ" color memvar->colorarray[37]
@ 13,27 say "Û   Û   Û Û Û Û Û Û  Û  Û Û Û ÛÜÜ" color memvar->colorarray[37]
@ 14,27 say "ÛÜÛ ÛÜÛ ÛÜÛ ÛÜÛ Û Û  Û  Û Û Û ÛÜÛ" color memvar->colorarray[37]

draw_box2(16,14,21,22,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 17,16 say "ÛÛßßÛ" color memvar->colorarray[38]
@ 18,16 say "ÛÛÜÜÜ" color memvar->colorarray[38]
@ 19,16 say "   ÛÛ" color memvar->colorarray[38]
@ 20,16 say "ÛÜÜÛÛ" color memvar->colorarray[38]

draw_box1(17,24,21,48,memvar->colorarray[28],memvar->colorarray[29],,.f.)
@ 18,27 say "Û Û Ûßß ßÛß Ûß ÛÝÞÛ" color memvar->colorarray[37]
@ 19,27 say "ßÛß ßßÛ  Û  Ûß ÛÞÝÛ" color memvar->colorarray[37]
@ 20,27 say " Û  ÛÜÛ  Û  ÛÜ Û  Û" color memvar->colorarray[37]

@ 04,25 say "University of Cebu" color memvar->colorarray[36]
@ 10,25 say "Maritime Education" color memvar->colorarray[36]
@ 16,25 say "And Training Center" color memvar->colorarray[36]

dispbox(00,00,01,79, space(09), memvar->colorarray[01])
updatedate()
outexpr(00, 00, "User:", memvar->colorarray[01])
outexpr(00, 06, memvar->cusername, memvar->colorarray[01])
outexpr(00, 24, "Current Date:", memvar->colorarray[01])
outexpr(00, 64, "Time:", memvar->colorarray[01])
outexpr(00, 70, clock("on", "12 hour", "seconds"), memvar->colorarray[01])
&&CommandLine( "³  Use " + Chr(27) + Chr(24) + Chr(25) + Chr(26) + " to navigate   " + "³      Ù - to select      ³     ESC - Previous      ³" )
&&commandline("³  Alt+C - Calculator ³  " + chr(27) + chr(24) + chr(25) + chr(26) + " to Navigate  ³" + "  Ù - to Select  ³ ESC - Previous ³")
&&commandline("³ F1-About ³ Alt+C-Calculator ³ "+chr(27)+chr(24)+chr(25)+chr(26)+" to Navigate ³ "+"Ù-to Select ³ ESC-Previous ³")
commandline("³ Alt+A-About ³ Alt+C-Calculator ³ "+chr(27)+chr(24)+chr(25)+chr(26)+" to Navigate ³ "+"Ù-Select ³ ESC-Previous ³")
dispbox(01,00,01,79, space(9), memvar->colorarray[06])

__keyboard(chr(K_ENTER))
set wrap on
bentry       := optionentry()
breports     := optionreport()
butility     := optionutility()
bmaintenance := optionmaintenance()
setkey(K_ALT_C,{||actcalculator()})
setkey(K_ALT_A,{||about()})
setkey(K_F1,{||help()})
do while ! ( nmainchoice := selectmenu ( { { 01, 02, " Entry   ",,,{ || rights( "[1]" ) }, bentry,, }, ;
                                           { 01, 11, " Report  ",,,{ || rights( "[2]" ) }, breports,,}, ;
                                           { 01, 22, " Utility ",,,{ || rights( "[3]" ) }, butility,, }, ;
                                           { 01, 33, " Maintenance ",,,{ || rights( "[4]" ) }, bmaintenance,, } }, ;
                                         { || nil },,, memvar->colorarray[03],,,,, ;
                                         gettrigger( memvar->colorarray[03] ) ) ) == 0
enddo
setkey(K_ALT_C, nil)
setkey(K_ALT_A, nil)
setkey(K_F1, nil)
outexpr(00, 68, clock("off", "12 hour", "seconds"), memvar->colorarray[01])
setcolor(clastcolor); setcursor(nlastcursor)
clrscr(9,5000); restscr(cwaitscr)
return(nil)
//{ 08, 15, " Adjustment for ~Special Schedule ",,, { || rights( "[1,2,3]" ) }, {|| nil },,},;
//{ 08, 15, " ~Update Payment Records          ",,, { || rights( "[1,2,4]" ) }, {|| payupdate()},,},;
static function optionentry()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 02, " ~Accounts Information for College          ",,, { || rights( "[1,1]" ) },;
        { || SelectMenu( { { 05, 15, " ~Create New Accounts                 ",,, { || rights( "[1,1,1]" ) }, {|| newaccts()},,}, ;
                           { 06, 15, " Forward Account Balances by Code     ",,, { || rights( "[1,1,2]" ) }, {|| fwdbalcol()},,},;
                           { 07, 15, " Forward Account Balances by ~Account ",,, { || rights( "[1,1,3]" ) }, {|| fwdbalacct()},,},;
                           { 08, 15, " ~Reset/Recompute Accounts Records    ",,, { || rights( "[1,1,4]" ) }, {|| resetacct()},,},;
                           { 09, 15, " ~Reset/Recompute Accounts Records by Code  ",,, { || rights( "[1,1,4]" ) }, {|| resetcol()},,}},;
        { || draw_box2(04,14,09,52,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 02, " ~Payment and Adjustment for College        ",,, { || rights( "[1,2]" ) },;
        { || SelectMenu( { { 06, 15, " ~Payment Entry                   ",,, { || rights( "[1,2,1]" ) }, {|| payentry()},, }, ;
                           { 07, 15, " ~Adjustment Entry                ",,, { || rights( "[1,2,2]" ) }, {|| adjentry()},,},; 
                           { 08, 15, " ~Update Payment Records          ",,, { || rights( "[1,2,4]" ) }, {|| payupdate()},,},;
                           { 09, 15, " ~Update Payment Records v2       ",,, { || rights( "[1,2,4]" ) }, {|| or_view()},,},;
                           { 10, 15, " P~ost Payment Records            ",,, { || rights( "[1,2,5]" ) }, {|| postpay()},,}},;
        { || draw_box2(05,14,11,48,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 02, " ~Students Assessments for College          ",,, { || rights( "[1,3]" ) },;
        { || SelectMenu( { { 07, 15, " Create Assessment Record by ~Account ",,, { || rights( "[1,3,1]" ) }, {|| assbystud()},, }, ;
                           { 08, 15, " Create Assessment Record by ~College ",,, { || rights( "[1,3,2]" ) }, {|| assbycol()},,},;
                           { 09, 15, " P~ost Assessment by College          ",,, { || rights( "[1,3,3]" ) }, {|| postass()},,}},;
        { || draw_box2(06,14,10,52,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 02, " School ~Fees, Fee Rates & Charges          ",,, { || rights( "[1,4]" ) },;
        { || SelectMenu( { { 08, 15, " Work with ~Fees            ",,, { || rights( "[1,4,1]" ) }, {|| feesentry()},, }, ;
                           { 09, 15, " Work with ~Laboratory Fees ",,, { || rights( "[1,4,2]" ) }, {|| labfeeentry()},,},;
                           { 10, 15, " Work with Fee ~Year        ",,, { || rights( "[1,4,3]" ) }, {|| feeyear()},,}},;
        { || draw_box2(07,14,11,42,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 02, " Scholarships and Pri~veleges for College   ",,, { || rights( "[1,5]" ) },;
        { || SelectMenu( { { 09, 15, " ~Scholarships and Priveleges Entry     ",,, { || rights( "[1,5,1]" ) }, {|| privmst()},, }, ;
                           { 10, 15, " ~Work with Scholarships and Priveleges ",,, { || rights( "[1,5,2]" ) }, {|| privent()},,}},;
        { || draw_box2(08,14,11,54,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )

//{ 11, 15, " ~Forward Special Course Account Balances ",,, { || rights( "[1,6,2]" ) }, {|| forsplbal() },,},;
aadd( aelements, { ncurrline++, 02, " Special ~Courses for College               ",,, { || rights( "[1,6]" ) },;
        { || SelectMenu( { { 10, 15, " Add Special Course ~Account              ",,, { || rights( "[1,6,1]" ) }, {|| splacctent()},, }, ;
                           { 11, 15, " ~Update Special Course Account           ",,, { || rights( "[1,6,3]" ) }, {|| updsplacct() },,},;
                           { 12, 15, " ~Discounts and Priveleges                ",,, { || rights( "[1,6,4]" ) }, {|| tcpriv() },,}},;
        { || draw_box2(09,14,14,56,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )

aadd( aelements, { ncurrline++, 02, " ~General System Tasks for College          ",,, { || rights( "[1,7]" ) },;
        { || SelectMenu( { { 11, 15, " ~Update Student Information     ",,, { || rights( "[1,7,1]" ) }, {|| changedname()},, }, ;
                           { 12, 15, " Change Students ~Balances       ",,, { || rights( "[1,7,2]" ) }, {|| chgstudbal()},,},;
                           { 13, 15, " Assign New ~College Student No. ",,, { || rights( "[1,7,3]" ) }, {|| newidno() },,},;
                           { 14, 15, " Create New Student Manually from Online",,, { || rights(  "[4]"    ) }, {|| idnocreate() },,}},;
        { || draw_box2(10,14,14,47,memvar->colorarray[30],memvar->colorarray[31])},,,memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
        
return( { || selectmenu( aelements, { || draw_box2(nstartline,01,ncurrline,02+len(aelements[01,03])-1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionreports()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 11, " ~Accounts Information Report       ",,, { || rights( "[2,1]" ) }, ;
        { || SelectMenu( { { 05, 25, " Display ~Statement of Accounts    ",,, { || rights( "[2,1,1]" ) }, {|| acctinfo() },, }, ;
                           { 06, 25, " Display ~Enrollment Record        ",,, { || rights( "[2,1,2]" ) }, {|| dispenrol()},,},;
                           { 07, 25, " Display ~Account Summary          ",,, { || rights( "[2,1,3]" ) }, {|| acctsummary()},,},;
                           { 08, 25, " Print Students Balances *~College ",,, { || rights( "[2,1,4]" ) }, {|| studbalance() },,},;
                           { 09, 25, " Print Statements of Acc~ounts     ",,, { || rights( "[2,1,5]" ) }, {|| studacct()},,},;
                           { 10, 25, " Print Students Balances (~Term)   ",,, { || rights( "[2,1,6]" ) }, {|| studterm()},,},;
                           { 11, 25, " Print Student Balances w/ A~mount ",,, { || rights( "[2,1,7]" ) }, {|| studbalbyterm()},,},;
                           { 12, 25, " Daily Postings Report          ",,, { || rights( "[2,1,8]" ) },;
                                { || SelectMenu( { { 14, 44, "  Per Discount  ",,, { || rights( "[2,1,8,1]" ) }, {|| daily_discount_report() },, }, ;
                                                   { 15, 44, "  Per Training  ",,, { || rights( "[2,1,8,2]" ) }, {|| daily_training_report() },, }, ;
                                                   { 16, 44, "  Per Adjustment  ",,, { || rights( "[2,1,8,3]" ) }, {|| daily_adjustment_report() },, }, ;
                                                   { 17, 44, "  From Cashier Payments  ",,, { || rights( "[2,1,8,4]" ) }, {|| daily_cashier_report()},,}},;
                                { || draw_box2(13,43,17,63,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
                                gettrigger( memvar->colorarray[32] ) ) },,}},;
        { || draw_box2(04,24,16,59,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
/*       
aadd( aelements, { ncurrline++, 11, " ~Payments and Adjustments Report   ",,, { || rights( "[2,2]" ) }, ;
        { || SelectMenu( { { 06, 25, " BPI Payments *~Summary  ",,, { || rights( "[2,2,1]" ) }, {|| nil },,}, ;
                           { 07, 25, " BPI Payments *~Detailed ",,, { || rights( "[2,2,2]" ) }, {|| nil },,}},;
        { || draw_box2(05,24,08,49,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
*/

aadd( aelements, { ncurrline++, 11, " ~Students Assessment Report        ",,, { || rights( "[2,3]" ) }, ;
        { || SelectMenu( { { 07, 25, " Display Students ~Assessments       ",,, { || rights( "[2,3,1]" ) }, {|| displayassessment()},,}, ;
                           { 08, 25, " Print Assessment ~Notice by College ",,, { || rights( "[2,3,2]" ) }, {|| assessnotice()},,}},;
        { || draw_box2(06,24,09,61,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, " School ~Fees, Fee Rates & Charges  ",,, { || rights( "[2,4]" ) }, ;
        { || SelectMenu( { { 08, 25, " Summary of ~School Fees Income     ",,, { || rights( "[2,4,1]" ) }, {|| feesincome()},, }, ;
                           { 09, 25, " Summary of ~Miscellaneous Fees     ",,, { || rights( "[2,4,2]" ) }, {|| miscfees() },,},;
                           { 10, 25, " Summary of ~Laboratory Fees        ",,, { || rights( "[2,4,3]" ) }, {|| laboratoryfees()},,},;
                           { 11, 25, " Summary of ~Tuition and Collections ",,, { || rights( "[2,4,3]" ) }, {|| collegecollections()},,},;
                           { 12, 25, " Summary of ~Special Courses Collections ",,, { || rights( "[2,4,3]" ) }, {|| trainingollections()},,},;
                           { 13, 25, " Summary of S~pecial Courses Income ",,, { || rights( "[2,4,4]" ) }, {|| specialincome()},,}},;
        { || draw_box2(07,24,12,60,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, " Scholarships & Pri~vileges Report  ",,, { || rights( "[2,5]" ) }, ;
        { || SelectMenu( { { 09, 25, " Display Students ~Receiving Privileges  ",,, { || rights( "[2,5,1]" ) }, {|| studprivilege()},, }, ;
                           { 10, 25, " Display Students Privileges by ~College Code",,, { || rights( "[2,5,1]" ) }, {|| privilegebystudentcolcod()},, }, ;
                           { 11, 25, " Print Students Privilege by (~Type)     ",,, { || rights( "[2,5,2]" ) }, {|| privbytype()},,},;
                           { 12, 25, " Print Privileges ~Summary               ",,, { || rights( "[2,5,3]" ) }, {|| privsummary()},,},;
                           { 13, 25, " Print Bills by ~Privilege Code          ",,, { || rights( "[2,5,4]" ) }, {|| billsbycode()},,},;
                           { 14, 25, " Print Privileges by ~Nature             ",,, { || rights( "[2,5,5]" ) }, {|| privnature()},,}},;
        { || draw_box2(08,24,14,65,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
aadd( aelements, { ncurrline++, 11, " ~Examinations Permits Report       ",,, { || rights( "[2,6]" ) }, ;
        { || SelectMenu( { { 10, 25, " Print Examination Permit by ~Student    ",,, { || rights( "[2,6,1]" ) }, {|| permitbystudent()},,}, ;
                           { 11, 25, " Print Examination Permit by ~College    ",,, { || rights( "[2,6,2]" ) }, {|| permitbycollege()},,},;
                           { 12, 25, " Examination Permit ~Monitoring         ",,, { || rights( "[2,6,3]" ) },;
                                { || SelectMenu( { { 14, 44, "  For ~Accounting  ",,, { || rights( "[2,6,3,1]" ) }, {|| acctpaylst() },, }, ;
                                                   { 15, 44, "  For ~Deans Copy  ",,, { || rights( "[2,6,3,1]" ) }, {|| paylst4deans() },, }, ;
                                                   { 16, 44, "  For ~Instructor  ",,, { || rights( "[2,6,3,2]" ) }, {|| instpaysheet()},,}},;
                                { || draw_box2(13,43,17,63,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
                                gettrigger( memvar->colorarray[32] ) ) },,}},;
        { || draw_box2(09,24,13,65,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )

aadd( aelements, { ncurrline++, 11, " Special ~Courses Report            ",,, { || rights( "[2,7]" ) }, ;
        { || SelectMenu( { { 11, 25, " Print ~Certification            ",,, { || rights( "[2,7,1]" ) }, {|| certification() },, },;
                           { 12, 25, " Print Certification (~Multiple) ",,, { || rights( "[2,7,2]" ) }, {|| certselection() },, },;
                           { 13, 25, " Print Statement of ~Accounts    ",,, { || rights( "[2,7,3]" ) }, {|| staccount()},, }},;
        { || draw_box2(10,24,14,57,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )

/*aadd( aelements, { ncurrline++, 11, " Print ~Dormitory Occupants          ",,, { || rights( "[2,8" ) }, {|| dorm_prn()},, } )*/


/*aadd( aelements, { ncurrline++, 11, " Daily Postings Report             ",,, { || rights( "[2,7]" ) }, ;
        { || SelectMenu( { { 09, 31, " Per Discount ",,, { || rights( "[2,7,1]" ) }, {|| feesincome() },, },;
                           { 10, 31, " Per Training ",,, { || rights( "[2,7,2]" ) }, {|| feesincome()},, }},;
                           { 11, 31, " Per Adjustment ",,, { || rights( "[2,7,3]" ) }, {|| feesincome() },, },;
                           { 12, 31, " From Cashier Payments ",,, { || rights( "[2,7,4]" ) }, {|| feesincome() },, },;
        { || draw_box2(10,24,14,65,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )*/


aadd( aelements, { ncurrline++, 11, " Inst. Req'd Payment List(s)        ",,, { || rights( "[2,9" ) }, {|| a2instpaysheet()},, } )

/*(aadd( aelements, { ncurrline++, 11, " Account Receivable                ",,, { || rights( "[2,A]" ) }, ;
        { || SelectMenu( { { 14, 31, " Projected ",,, { || rights( "[2,A,1]" ) }, {|| acct_recbl_by_col(1) },, },;
                           { 15, 31, " Actual    ",,, { || rights( "[2,A,2]" ) }, {|| acct_recbl_by_col(2)},, }},;
        { || draw_box2(13,30,16,43,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )*/


/*aadd( aelements, { ncurrline++, 11, " Daily Postings Report             ",,, { || rights( "[2,10]" ) }, ;
        { || SelectMenu( { { 15, 31, " Per Discount ",,, { || rights( "[2,10,1]" ) }, {|| daily_discount() },, },;
                           { 16, 31, " Per Training ",,, { || rights( "[2,10,2]" ) }, {|| daily_discount()},, }},;
                           { 17, 31, " Per Adjustment ",,, { || rights( "[2,10,3]" ) }, {|| daily_discount() },, },;
                           { 18, 31, " From Cashier Payments ",,, { || rights( "[2,10,4]" ) }, {|| daily_discount() },, },;
        { || draw_box2(13,30,16,43,memvar->colorarray[30],memvar->colorarray[31])},,, memvar->colorarray[32] , , , , , ;
        gettrigger( memvar->colorarray[32] ) ) },, } )
*/

return( { || selectmenu( aelements, { || draw_box2( nstartline, 10, ncurrline, 11 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionutility()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 22, "  ~View Text/Prn File                 ",,, { || rights( "[3,1]" ) },  { || viewtextfile() },, } )
aadd( aElements, { ncurrline++, 22, "  Change ~Password                    ",,, { || rights( "[3,2]" ) },  { || changepassword() },, } )
aadd( aelements, { ncurrline++, 22, "  ~User Utility                       ",,, { || rights( "[20,20]" ) },{ || userutility() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Adjustment Chart Entry             ",,, { || rights( "[3,3]" ) },  { || chartentry() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Create Data Base File              ",,, { || rights( "[3,4]" ) },  { || createdatabase() },, } )
aadd( aelements, { ncurrline++, 22, "  ~QE Prn/Txt Editor                  ",,, { || rights( "[3,8]" ) },  { || qeue() },, } )
aadd( aelements, { ncurrline++, 22, "  View ~Grades                        ",,, { || rights( "[3,9]" ) },  { || grd() },, } )

/* REMOVED 5312018
aadd( aelements, { ncurrline++, 22, "  A~ssessment by Student              ",,, { || rights( "[3,5]" ) },  { || assessbystud() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Mirror Assessment to Account File  ",,, { || rights( "[3,6]" ) },  { || asstoacct() },, } )
aadd( aelements, { ncurrline++, 22, "  ~Reset/Recompute All Account File   ",,, { || rights( "[3,7]" ) },  { || resetall() },, } )
aadd( aelements, { ncurrline++, 22, "  ~QE Prn/Txt Editor                  ",,, { || rights( "[3,8]" ) },  { || qeue() },, } )
aadd( aelements, { ncurrline++, 22, "  View ~Grades                        ",,, { || rights( "[3,9]" ) },  { || grd() },, } )
aadd( aelements, { ncurrline++, 22, "  Download Accounts for ~Globe SMS    ",,, { || rights( "[3,A]" ) },  { || globeacc() },, } )
*/

return( { || selectmenu( aelements, { || draw_box2( nstartline, 21, ncurrline, 22 + len( aelements[ 01, 03 ] ) - 1, ;
             memvar->colorarray[25],memvar->colorarray[26],memvar->colorarray[33] ) },,, memvar->colorarray[33] , , , , , ;
             gettrigger( memvar->colorarray[34] ), ;
             chr( K_ESC ) + chr( K_LEFT ) + chr( K_ENTER ), chr( K_ESC ) + chr( K_RIGHT ) + chr( K_ENTER ) ) } )

static function optionmaintenance()
local aelements := {}, nstartline := 02, ncurrline
ncurrline := nstartline + 1
aadd( aelements, { ncurrline++, 33, "  ~File Maintenance ",,, { || rights( "[4,1]" ) }, { || choicefile() },, } )
aadd( aelements, { ncurrline++, 33, "  ~Rebuild Files    ",,, { || rights( "[4,2]" ) }, { || buildfile() },, } )

/*REMOVED ON 5312018
aadd( aelements, { ncurrline++, 33, "  ~Fix Term         ",,, { || rights( "[4,3]" ) }, { || fixterm() },, } ) 
aadd( aelements, { ncurrline++, 33, "  Remove ~Assmnt    ",,, { || rights( "[4,4]" ) }, { || remassmnt() },, } ) 
*/

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
@ 03,36 say "ÜÛßßßÛ" color memvar->colorarray[42]
@ 04,36 say "ÛÛÜÜÜÜ" color memvar->colorarray[42]
@ 05,36 say "ÛÛ   " color memvar->colorarray[42]
@ 06,36 say "ÛÛ   " color memvar->colorarray[42]

draw_box2(02,45,07,53,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 03,47 say "ÛßÛÛßÛ" color memvar->colorarray[42]
@ 04,47 say "  ÛÛ  " color memvar->colorarray[42]
@ 05,47 say "  ÛÛ  " color memvar->colorarray[42]
@ 06,47 say "  ÛÛ  " color memvar->colorarray[42]

/*
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
*/

draw_box1(08,17,12,61,memvar->colorarray[25],memvar->colorarray[26],,.f.)
@ 09,20 say "Student's Accounting System Version 2.1" color memvar->colorarray[43]
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
        read /*TimeOut 15 ExitEvent scrsaver( MemVar-> cUserName, cPassword ) Warning 10*/
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
__run("\GAMES\PROJECTX\PSYCHO")
*__run("\PUBLIC\BALLS")
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
   @ 11,22 say "Student Accounting System" color memvar->colorarray[45]
   @ 12,22 say "Version 1.1.0" color memvar->colorarray[45]
   @ 14,22 say "(C) Copyright 1998-1999" color memvar->colorarray[44]
   @ 15,22 say "RenzVine Technology, Philippines" color memvar->colorarray[44]
   @ 16,22 say "in association with Shack Unlimitted" color memvar->colorarray[44]
   inkey(0)
restscreen(00,00,24,79,acode)
return nil

*-----------------------------------------------------------------------------*

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

function fixterm()
local alastscr:=savescr(01,00,24,79), counter := 0
        if(aprv2setup:=openwcheck({{,,"c172enrp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"}})) == nil
                return(nil)
        endif

c172enrp->(dbgotop())
do while ! c172enrp->(eof())
   fask(10,"  Processing ID Number : " + c172enrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if ! a999accp->(dbseek("1"+c172enrp->enridno))
        fask(10,"  ID Number : " + c172enrp->enridno+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
   else
        a999accp->(reclock())
        a999accp->accsyt := "172"
        a999accp->acccolcod := c172enrp->enrcolcod
        a999accp->(dbcommit())
        a999accp->(dbunlock())
        counter += 1
   endif
   c172enrp->(dbskip())
enddo
fask(10,"  "+transform(counter,"999,999")+" Records changed...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
closewcheck(aprv2setup)
restscr(alastscr)
return(nil)

//*****PARA MA ZERO ANG PREVIOUS ASSESSMENT******
function remassmnt()
local alastscr:=savescr(01,00,24,79), counter := 0
        if(aprv2setup:=openwcheck({{,,"c172enrp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"}})) == nil
                return(nil)
        endif

a999accp->(dbgotop())
do while ! a999accp->(eof())
   fask(10,"  Processing ID Number : " + a999accp->accidno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
 if a999accp->accsytass > 0
 //  if ! c172enrp->(dbseek(right(a999accp->accidno,8)))

        a999accp->(reclock())
        a999accp->accsytass := 0
        a999accp->(dbcommit())
        a999accp->(dbunlock())
        counter += 1
 //  endif
 endif
   a999accp->(dbskip())
enddo
fask(10,"  "+transform(counter,"999,999")+" Records changed...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
closewcheck(aprv2setup)
restscr(alastscr)
return(nil)
/*
//***** 2nd semester forwarding OA for Elementary reset to ZERO******
function changetofa()
local alastscr:=savescr(01,00,24,79), counter := 0
        if(aprv2setup:=openwcheck({{,,"c171enrp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,,"a172payp",,_DBF_SHARED,,1,"/arunlib"},;
                                   {,,"a999accp",,_DBF_SHARED,,1,"/arunlib"}})) == nil
                return(nil)
        endif

c171enrp->(dbgotop())
do while ! c171enrp->(eof())
   fask(10,"  Processing ID Number : " + c171enrp->enridno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
 if c171enrp->enrcolcod == "G1"
        if  a172payp->(dbseek("1"+c171enrp->enridno))
            if a172pay->payadjcod == "OA"
                a172payp->(reclock())
                a172payp->payadjcod := "FA"
                a172payp->(dbcommit())
                a172payp->(dbunlock())
            endif
        elseif  a172payp->(dbseek("2"+c171enrp->enridno))
            if a172pay->payadjcod == "OA"
                a172payp->(reclock())
                a172payp->payadjcod := "FA"
                a172payp->(dbcommit())
                a172payp->(dbunlock())


            endif

        endif
        counter += 1

 endif
   c171enrp->(dbskip())
enddo
fask(10,"  "+transform(counter,"999,999")+" Records changed...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
closewcheck(aprv2setup)
restscr(alastscr)
return(nil)
*/

function qeue()
setcursor (.f.)
acode := savescreen(00,00,24,79)
__run("Z:\PUBLIC\QE.EXE")
restscreen(00,00,24,79,acode)
return nil

*------------------------------------------------------------------------------*
#define _SUBJECT        1
#define _DESC           2
#define _GRADE          3
#define _UNITS          4
#define _SKDNO          5
#define _EMPTY_ELEM     {space(14),;
                         space(39),;
                         space(03),;
                         space(04),;
                         space(05)}

function grd()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprv1setup,cprocsts,ogrdind,bindex,bitems,aentryscr,;
      cyytskdp, cyytstsp, cyytcrsp, aprv2setup
private aitems := {},nindex,ntotunits,ntotequi,cgrade,lok,;
        cidno,clname,cfname,cmname,ccolcode,cyear,cterm,cdesc,ccoldesc

bindex  := memvarblock("NINDEX")
bitems  := memvarblock("AITEMS")
ogrdind := createabrowse(bitems,bindex,07,03,21,76,;
                        {|xnmode,xoabrowser,xaxparam|fgrdind(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_SUBJECT]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_DESC]+" "},nil},;
                         {{||"  "+memvar->aitems[memvar->nindex,_GRADE]+"  "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_UNITS]+"  "},nil}},;
                        {"     Subject    ", "              Description                ", " Grade ", " Units "},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ"})
*                         x123456789012x1x    x123456789012345678901234567890123456789x    xx1.1xx    x12.1xx

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
memvar->cterm  := space(len(term->code))
memvar->cgrade := "F"
do while .t.
        clearbuffer()
        boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Grade Printing Individual  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 03,01 say replicate("Ä",78)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)
        @ 02,57say "Period:";
                color memvar->colorarray[02];
                get memvar->cgrade      pict "@!";
                valid cgrade $ "MF"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->cdesc := term->name
        @ 02,67 say if(cgrade == "M","- Midterm","- Final  ")
        if ! file(alltrim("/CRUNLIB/c"+memvar->cterm+"stsp.dbf"))
                fask(10,"  C"+cterm+"STSP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! file(alltrim("/CRUNLIB/c"+memvar->cterm+"skdp.dbf"))
                fask(10,"  C"+cterm+"SKDP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        cyytstsp := "/CRUNLIB/c"+memvar->cterm+"stsp"
        cyytskdp := "/CRUNLIB/c"+memvar->cterm+"skdp"
        if(aprv2setup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,,"t999lst",,_DBF_SHARED,,1,"/crunlib"},;
                                     {,, cyytskdp ,"cyytskdp",_DBF_SHARED,,1},;
                                     {,, cyytstsp ,"cyytstsp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        memvar->cidno := space(len(c999sm1p->sm1idno))
        aentryscr := savescr(01,00,24,79)
        do while .t.
                memvar->clname          := space(len(c999sm1p->sm1lstnam))
                memvar->cfname          := space(len(c999sm1p->sm1fstnam))
                memvar->cmname          := space(len(c999sm1p->sm1midname))
                memvar->ccolcode        := space(len(c999sm1p->sm1colcod))
                memvar->cyear           := space(01)
                memvar->aitems          := {_EMPTY_ELEM}
                memvar->nindex          := 1
                memvar->ntotunits       := 0
                memvar->ntotequi        := 0
                memvar->lok             := .t.
                restscr(aentryscr)
                commandline("³        F4 - View Student File         ³           ESC - Previous             ³")
                setkey(K_F4,{||vstudent(space(len(c999sm1p->sm1idno)),cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 04,02 say "Student No. :";
                        color memvar->colorarray[02];
                        get memvar->cidno       pict "@!";
                        valid ! empty(memvar->cidno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! c999sm1p->(dbseek(memvar->cidno)) .and.;
                   ! valid_id(memvar->cidno)
                        fask(10,"  "+alltrim(memvar->cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                elseif c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytstsp->(dbseek(memvar->cidno))
                                fask(10," Student "+alltrim(c999sm1p->sm1lstnam)+", "+alltrim(c999sm1p->sm1fstnam)+" "+c999sm1p->sm1midnam+". not enrolled. ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                elseif !c999sm1p->(dbseek(memvar->cidno)) .and.;
                      !cyytstsp->(dbseek(memvar->cidno))
                                fask(10,"   Student not enrolled.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                                loop
                endif
                memvar->clname          := c999sm1p->sm1lstnam
                memvar->cfname          := c999sm1p->sm1fstnam
                memvar->cmname          := c999sm1p->sm1midname
                memvar->ccolcode        := c999sm1p->sm1colcod
                memvar->cyear           := transform(cyytstsp->stsyrlevel,"9")  //gipa ilisan ni Wena
                *memvar->cyear           := transform(c999sm1p->sm1yrlevl,"9")  //mao ni ang original
                c999colp->(dbseek(memvar->ccolcode))
                memvar->ccoldesc        := c999colp->coldesabr
                process()
                @ 04,25 say "- "+alltrim(memvar->clname)+" , "+alltrim(memvar->cfname)+"  "+memvar->cmname+"."
                @ 05,02 say "              "+memvar->ccolcode+" - "+memvar->ccoldesc
                @ 05,02 say "Course/Major: " color memvar->colorarray[02]
                @ 05,34 say "            "+memvar->cyear+;
                        if(memvar->cyear == "1", " - First Year ",;
                        if(memvar->cyear == "2", " - Second Year",;
                        if(memvar->cyear == "3", " - Third Year ",;
                        if(memvar->cyear == "4", " - Fourth Year",;
                                                 " - Fifth Year "))))
                @ 05,34 say "Year Level: " color memvar->colorarray[02]
                @ 22,02 say "      "+displaydate(date())
                @ 22,02 say "Date: " color memvar->colorarray[02]
                @ 22,63 say if(lok,transform(memvar->ntotequi/memvar->ntotunits,"@Z 99.99"),"     ")
                @ 22,71 say transform(memvar->ntotunits,"@Z 99.9")
                dispbox(06,02,21,77,_SINGLE_LINE)
                connectline(08,02,77)
                commandline("³ F8 - Print in blank form ³ F10 - Print in printed form ³   ESC - Previous    ³")
                stabilize(ogrdind,.t.)
                browsearray(ogrdind,{""},{|b|b:gotop()})
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function fgrdind(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                @ 07,03 say "     Subject                   Description                  Grade   Units " color memvar->colorarray[35]
                return 1
        case lastkey() == K_F4
                cyytskdp->(dbseek(right(memvar->aitems[nindex,_SKDNO],5)))
                if ! empty(cyytskdp->skdinscod)
                     t999lst->(dbseek(cyytskdp->skdinscod))
                     fask(13,"  "+alltrim(cyytskdp->skdsubcod)+" ==> "+alltrim(t999lst->tlname)+", "+alltrim(t999lst->tfname)+" "+alltrim(t999lst->tmname)+"  ",{" Ok "},memvar->colorarray[06])
                else
                     fask(13,alltrim(cyytskdp->skdsubcod)+";  Not assigned to Instructor  ",{" Ok "},memvar->colorarray[05])
                endif
        case lastkey() == K_F8
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pgrdblankform()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_F10
                __keyboard(replicate(chr(K_DOWN),1))
                if whereprint({||pgrdprintedform()}) == 1
                        __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                        viewtextfile()
                endif
        case lastkey() == K_DOWN .or. lastkey() == K_UP
                oabrowser:refreshall()
                stabilize(oabrowser)
endcase
return 2


static function process()
local nlastelem
private ncount
cyytstsp->(dbsetrelation("c999crsp",{||cyytstsp->stsintcod},"cyytstsp->stsintcod"))
cyytstsp->(dbsetrelation("cyytskdp",{||cyytstsp->stsskdcod},"cyytstsp->stsskdcod"))
cyytstsp->(sx_setscope(_TOP_SCOPE   ,memvar->cidno))
cyytstsp->(sx_setscope(_BOTTOM_SCOPE,memvar->cidno))
lok := .t.
count to ncount
cyytstsp->(dbgotop())
do while ! cyytstsp->(eof())
   if (ncount <= 13) .or. ((ncount > 13) .and. (cyytskdp->skdsplcod != "C"))
        fask(13,"  Processing code "+cyytstsp->stsskdcod+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdsubtyp == "LEC") .and.;
           ! (cyytskdp->skdsplcod == "C" .and. cyytskdp->skdunt == 0)
                aadd(memvar->aitems,_EMPTY_ELEM)
                nlastelem := len(memvar->aitems)
                memvar->aitems[nlastelem,_SKDNO]     := cyytstsp->stsskdcod
                memvar->aitems[nlastelem,_SUBJECT]   := c999crsp->crssubcod+" "+if(c999crsp->crssubtyp == "R"," ","L")
                memvar->aitems[nlastelem,_DESC]      := alltrim(c999crsp->crsdsc1)+if(!empty(c999crsp->crsdsc2),"...","   ")+;
                                                        space(36-len(alltrim(c999crsp->crsdsc1)))
                do case
                        case memvar->cgrade == "M"  &&Midterm
                                if val(cyytstsp->stsmidgrd) > 0
                                        if substr(cyytstsp->stsmidgrd,2,1) == "W"  /*  for 3W  */
                                                memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsmidgrd+" "
                                        else  /* for 30-10 */
                                                memvar->aitems[nlastelem,_GRADE] := substr(cyytstsp->stsmidgrd,1,1)+"."+substr(cyytstsp->stsmidgrd,2,1)
                                        endif
                                        if cyytstsp->stsmidgrd <= "30"
                                                filterunits(nlastelem)
                                                ntotequi += ((val(cyytstsp->stsmidgrd)/10) * cyytskdp->skdunt)
                                        else
                                                memvar->aitems[nlastelem,_UNITS] := "  0 "
                                                lok := .f.
                                        endif
                                elseif ! empty(cyytstsp->stsmidgrd)
                                        memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsmidgrd+" "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                elseif empty(cyytstsp->stsmidgrd)
                                        memvar->aitems[nlastelem,_GRADE] := " - "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                endif
                        case memvar->cgrade == "F"   &&Final
                                if val(cyytstsp->stsfingrd) > 0
                                        if substr(cyytstsp->stsfingrd,2,1) == "W" /* for 3W grade */
                                                memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsfingrd+" "
                                        else /* for 30 - 10 grade */
                                                memvar->aitems[nlastelem,_GRADE] := substr(cyytstsp->stsfingrd,1,1)+"."+substr(cyytstsp->stsfingrd,2,1)
                                        endif
                                        if cyytstsp->stsfingrd <= "30"
                                                filterunits(nlastelem)
                                                ntotequi += ((val(cyytstsp->stsfingrd)/10) * cyytskdp->skdunt)
                                        else
                                                memvar->aitems[nlastelem,_UNITS] := "  0 "
                                                lok := .f.
                                        endif
                                elseif ! empty(cyytstsp->stsfingrd)
                                        memvar->aitems[nlastelem,_GRADE] := cyytstsp->stsfingrd+" "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                elseif empty(cyytstsp->stsfingrd)
                                        memvar->aitems[nlastelem,_GRADE] := " - "
                                        memvar->aitems[nlastelem,_UNITS] := "  0 "
                                        lok := .f.
                                endif
                endcase
        endif
   endif
   cyytstsp->(dbskip())
enddo
cyytstsp->(clearscope())
cyytstsp->(dbclearrelation())
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_SUBJECT])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)


static function filterunits(nlastelem)
private nunits

memvar->ntotunits += cyytskdp->skdunt

nunits := cyytskdp->skdunt

if (ncount > 13) .and. (cyytskdp->skdsplcod=="S")
        cyytskdp->(dbseek(cyytstsp->stsskdcod))
        cyytskdp->(dbseek(cyytskdp->skdsplskd))
        if cyytskdp->skdsubtyp=="LAB"
                nunits += cyytskdp->skdunt
                memvar->ntotunits += cyytskdp->skdunt
        endif
endif
/*
memvar->aitems[nlastelem,_UNITS] := if(substr(str(cyytskdp->skdunt,5,1),5,1) == "0",;
                                       substr(str(cyytskdp->skdunt,5,1),1,3)+" ",;
                                       substr(str(cyytskdp->skdunt,5,1),2,4))
*/
memvar->aitems[nlastelem,_UNITS] := if(substr(str(nunits,5,1),5,1) == "0",;
                                       substr(str(nunits,5,1),1,3)+" ",;
                                       substr(str(nunits,5,1),2,4))

return(nil)


static function pgrdblankform()
local nctr := 0
header()
for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing subject "+alltrim(memvar->aitems[nctr,_DESC])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,memvar->aitems[nctr,_SUBJECT]+space(02)+;
                             memvar->aitems[nctr,_DESC]+space(04)+;
                             memvar->aitems[nctr,_GRADE]+space(03)+;
                             memvar->aitems[nctr,_UNITS])
next
outexpr(prow()+01,00,replicate("-",70))
outexpr(prow()+01,58,transform(memvar->ntotequi/memvar->ntotunits,"99.999"))
outexpr(prow(),66,transform(memvar->ntotunits,"99.9"))
//outexpr(prow()+01,00,displaydate(date())+space(57)+transform(memvar->ntotunits,"99.9"))
//outexpr(prow()+00,58,if(memvar->cgrade == "F" .and. memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"99.99"),"    "))
//outexpr(prow()+00,58,transform(memvar->ntotequi/memvar->ntotunits,"99.99"))
outexpr(19,00,"UC-METC/REG.Doc/009/Rev.01")
@ 22,00 say space(01)  /* to eject */
setprc(00,00)
return(nil)


static function header()
*setprc(00,00)
//outexpr(00,00,substr(memvar->ccompanyname,1,28)+space(01)+substr(memvar->cdesc,1,22)+space(06)+if(memvar->cgrade == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(00,00,substr(memvar->ccompanyname,1,32)+space(01)+substr(memvar->cdesc,1,22)+space(02)+if(memvar->cgrade == "M","MIDTERM GRADE","  FINAL GRADE"))
outexpr(01,00,replicate("-",70))
//outexpr(02,00,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->cfname+space(01)+memvar->cmname+space(07)+memvar->ccoldesc+space(04)+memvar->cyear)
outexpr(02,00,memvar->cidno+space(02)+alltrim(memvar->clname)+","+space(01)+alltrim(memvar->cfname)+space(02)+alltrim(memvar->cmname))
outexpr(02,60,memvar->ccoldesc+space(02)+memvar->cyear)
outexpr(03,00,replicate("-",70))
outexpr(04,00,"SUBJECT         DESCRIPTION                               GRADE  UNITS")
return(nil)


static function pgrdprintedform()
local nctr := 0
outexpr(00,30,substr(memvar->cdesc,1,22))
//outexpr(02,01,memvar->cidno+space(02)+memvar->clname+space(01)+memvar->cfname+space(01)+memvar->cmname+space(02)+memvar->ccoldesc+space(01)+memvar->cyear+space(02)+if(memvar->cgrade == "M","MIDTERM","FINAL"))
outexpr(02,01,memvar->cidno+space(02)+alltrim(memvar->clname)+","+space(01)+alltrim(memvar->cfname)+space(02)+alltrim(memvar->cmname))
//outexpr(02,61,memvar->ccoldesc+space(01)+memvar->cyear+space(02)+if(memvar->cgrade == "M","MIDTERM","FINAL"))
outexpr(02,55,memvar->ccoldesc+space(01)+memvar->cyear+space(03)+if(memvar->cgrade == "M","MIDTERM"," FINAL "))
outexpr(03,00,space(01))
for nctr := 1 to len(memvar->aitems)
        fask(13,"  Printing subject "+alltrim(memvar->aitems[nctr,_DESC])+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        outexpr(prow()+01,00,memvar->aitems[nctr,_SUBJECT]+space(01)+;
                             memvar->aitems[nctr,_DESC]+space(08)+;
                             memvar->aitems[nctr,_GRADE]+space(02)+;
                             memvar->aitems[nctr,_UNITS])
next
outexpr(18,02,dtoc(date()))
//outexpr(18,60,if(memvar->cgrade == "F" .and. memvar->lok,transform(memvar->ntotequi/memvar->ntotunits,"99.99"),"    "))
outexpr(18,60,transform(memvar->ntotequi/memvar->ntotunits,"99.999"))
outexpr(18,67,transform(memvar->ntotunits,"99.9"))
outexpr(19,00,"UC-METC/REG.Doc/009/Rev.01")
outexpr(22,00,space(01)) /* to eject */
setprc(00,00)
return(nil)

*------------------------------------------------------------------------------*

