* Program       :  IDNOCON.PRG
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

function mainprog(ccolor)
local aprvsetup, ldeleted, lcapslock := capslock(), lnumlock := numlock(), ;
      alastscr := savescr(01,00,24,79)
private colorarray := "", lcolor, ;
        nbrowwait := 10, cspooltxt := "REPORT", cusername, ccompanyname, ;
                        csysname, cpassword, nrec, clevel, naccess

//        cspooltxt := "REPORT" + strzero(n_stanum(), 2), ;

capslock(.t.); numlock(.t.)
ldeleted := set(_SET_DELETED, .t.)
sx_autoshare(0)
set scoreboard off
setcancel(.f.)
set talk off
set epoch to 1960
set century on

if fask(10,"     Rebuild IDNOCON ?     ",{" Yes "," No  "},"W/N") == 1
        afiles := {{,,"IDNOCONX",,_DBF_EXCLUSIVE,,}}
        if file("IDNOCONX.CDX")
                ferase("IDNOCONX.CDX")
        endif
        openwcheck(afiles)
        index on IDNUMBER   tag IDNOCON1 of IDNOCON option indexbar()
        dbclosearea()
endif
restscr(alastscr)
return(nil)


