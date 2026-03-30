* Program       :  FEEENT.PRG
* Author        :  Randy F. Santizo and Jun Benlot (c) October 1998
* Installation  :  UC-METC

#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"

*-------------------------------------------------------------------------------
function feesentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate
private cfeeyr,ccolcode,cterm,nfeeperunit,nfeereg,nfeelib,nfeemed,nfeeden,nfeeath,;
        nfeegui,nfeetes,nfeeaud,nfeestu,nfeepri,nfeestw,nfeemod,nfeeres,;
        nfeeoth1,nfeeoth2,nfeeoth3,nfeeoth4,nfeeoth5,;
        nfeecol1,nfeecol2,nfeecol3,nfeecol4,nmisc,nlab,feegrdlvl,total

if(aprvsetup := openwcheck({{,,"a999feep",,_DBF_SHARED,,2},;
                            {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  BasicEd Fees Master File Entry  ")
commandline("³         F4 - View College File       ³            ESC - Previous             ³")
aentryscr:=savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        memvar->cfeeyr          := space(len(a999feep->feeschyr))
        memvar->ccolcode        := space(len(a999feep->feecolcod))
        memvar->cterm           := space(len(a999feep->feetrm))
        memvar->feegrdlvl       := space(len(a999feep->feegrdlvl))
        memvar->nfeeperunit     := 0
        memvar->nfeereg         := 0
        memvar->nlab            := 0
        memvar->nmisc           := 0
        memvar->nfeeoth2        := 0
        memvar->total           := 0

        memvar->nfeelib         := 0
        memvar->nfeemed         := 0
        memvar->nfeeden         := 0
        memvar->nfeeath         := 0
        memvar->nfeegui         := 0
        memvar->nfeetes         := 0
        memvar->nfeeaud         := 0
        memvar->nfeestu         := 0
        memvar->nfeepri         := 0
        memvar->nfeestw         := 0
        memvar->nfeemod         := 0
        memvar->nfeeres         := 0
        memvar->nfeeoth1        := 0
        
        memvar->nfeeoth3        := 0
        memvar->nfeeoth4        := 0
        memvar->nfeeoth5        := 0
        memvar->nfeecol1        := 0
        memvar->nfeecol2        := 0
        memvar->nfeecol3        := 0
        memvar->nfeecol4        := 0
        clearbuffer()
        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Fee Year . . . . . . . . . . . . :";
                color memvar->colorarray[02];
                get memvar->cfeeyr      pict "@!";
                valid ! empty(memvar->cfeeyr)
        @ 03,02 say "Grade Level or Strand  . . . . . :";
                color memvar->colorarray[02];
                get memvar->ccolcode    pict "@!";
                valid ! empty(memvar->ccolcode)
        @ 04,02 say "Level [01,02,03,04,05,06,07,08,09,10,11,12]:";
                color memvar->colorarray[02];
                get memvar->feegrdlvl    pict "@!";
                valid ! empty(memvar->ccolcode)
        @ 05,40 say "[1  2  4]" color memvar->colorarray[02]
        @ 05,02 say "Term or High School Session  . . :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid memvar->cterm $ "124"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999colp->(dbseek(memvar->ccolcode))
                fask(10," Grade or Strand Code "+alltrim(memvar->ccolcode)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! memvar->ccolcode $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AM,GS,AG,ST,HU,OO,IC" 
                        fask(10,"Fee Entry of College ("+memvar->ccolcode+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
        endif

        ddate := ctod("01/01/"+memvar->cfeeyr)
        @ 02,40 say "- "+substr(dtos(ddate),1,4)
        @ 03,40 say "- "+c999colp->coldesabr
        if lexist := a999feep->(dbseek(memvar->cfeeyr+memvar->ccolcode+memvar->feegrdlvl+memvar->cterm))
                if ! a999feep->(reclock())
                        loop
                endif

                //display 

                memvar->nfeeperunit     := a999feep->feeperunit // AS TUITION FEE
                memvar->nfeereg         := a999feep->feereg //AS REGISTRATION FEE
                memvar->nmisc           := a999feep->feetotmisc //total miscelleneous nani
                memvar->nlab            := a999feep->feestudwel //AS LABORATORY/AIRCON FEE / LMS Fee
               
                /*
                memvar->nfeelib         := a999feep->feelibr
                memvar->nfeemed         := a999feep->feemed 
                memvar->nfeeden         := a999feep->feeden
                memvar->nfeeath         := a999feep->feeath
                memvar->nfeegui         := a999feep->feeguid
                memvar->nfeetes         := a999feep->feetest
      //x 2015    memvar->nfeeaud         := a999feep->feeaudvis
      //x 2015    memvar->nfeestu         := a999feep->feestuddev
                memvar->nfeepri         := a999feep->feeprisaa
      //x         memvar->nfeecul         := a999feep->feeculturl              
      //x 2015    memvar->nfeemod         := a999feep->feeupgrade
                memvar->nfeeres         := a999feep->feeresdevt
                memvar->nfeeoth1        := a999feep->feeother1
                memvar->nfeeoth2        := a999feep->feeother2
                memvar->nfeeoth3        := a999feep->feeother3
                memvar->nfeeoth4        := a999feep->feeother4
                memvar->nfeeoth5        := a999feep->feeother5
                memvar->nfeecol1        := a999feep->feecolfee1
                memvar->nfeecol2        := a999feep->feecolfee2
                memvar->nfeecol3        := a999feep->feecolfee3
                memvar->nfeecol4        := a999feep->feecolfee4
                */
                disptotmisc()
        endif
        do while .t.
                commandline("³             F10 - Record             ³           ESC - Previous              ³")
                setkey(K_F10,{||savefee(lexist)})
                setcursor(1);set(_SET_CONFIRM,.t.)
      
                @ 08,02 say "Tuition. . . . . . . . . . . . . . .  :";
                    color memvar->colorarray[02];
                    get memvar->nfeeperunit     pict "999,999.99" 

                @ 10,02 say "Registration Fee. . . . . . . . . . . :"; 
                    color memvar->colorarray[02];
                    get memvar->nfeereg     pict "999,999.99";
                    valid disptotmisc() 

                @ 11,02 say "Miscellaneous . . . . . . . . . . . . :";
                    color memvar->colorarray[02];
                    get memvar->nmisc     pict "999,999.99"; 
                    valid disptotmisc()

                @ 12,02 say "Laboratory / Aircon / EBook / LMS . . :";
                    color memvar->colorarray[02];
                    get memvar->nlab     pict "999,999.99";

                @ 13,02 say "Total . . . . . . . . . . . . . :" color memvar->colorarray[02]
               read
                disptotmisc()
                if lastkey() == K_ESC
                        exit
                endif
        enddo
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F10,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)




static function disptotmisc()

//tuition + registration fee + miscellenous + lab (Laboratory/Aircon/EBook/LMS)
memvar->total := memvar->nfeeperunit + memvar->nfeereg + memvar->nmisc + memvar->nlab 
@ 13,35 say transform( memvar->total,"@Z 999,999.99")
return(.t.)

//SAVE ENTRIES
static function savefee(lexist)
if fask(18,"  Are you sure to save this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        if ! lexist
                a999feep->(recycle())
        endif
        a999feep->feeschyr      := memvar->cfeeyr
        a999feep->feecolcod     := memvar->ccolcode
        a999feep->feetrm        := memvar->cterm
        a999feep->feegrdlvl     := memvar->feegrdlvl
        

        //MISCELLANEOUS COMPUTATION
        /* orig
        a999feep->feetotmisc    := memvar->nfeelib+memvar->nfeemed+memvar->nfeeden+memvar->nfeeath+;
                                   memvar->nfeegui+memvar->nfeetes+memvar->nfeeaud+memvar->nfeestu+;
                                   memvar->nfeepri+memvar->nfeestw+memvar->nfeemod+memvar->nfeeres+memvar->nfeeoth1+;
                                   memvar->nfeeoth2+memvar->nfeeoth3+memvar->nfeeoth4+memvar->nfeeoth5
        */
        /*
        a999feep->feetotmisc    := memvar->nfeemed+memvar->nfeeden+memvar->nfeeath+;
                                   memvar->nfeegui+memvar->nfeetes+memvar->nfeeaud+memvar->nfeestu+;
                                   memvar->nfeepri+memvar->nfeestw+memvar->nfeemod+memvar->nfeeres+memvar->nfeeoth1+;
                                   memvar->nfeeoth2+memvar->nfeeoth3+memvar->nfeeoth4+memvar->nfeeoth5
                                   */
        
        //10122017
        a999feep->feeperunit    := memvar->nfeeperunit //TUITION
        a999feep->feereg        := memvar->nfeereg      //REGISTRATION FEE
       
        a999feep->feetotmisc    := memvar->nmisc  //MISC
        a999feep->feestudwel    := memvar->nlab //Laboratory / Aircon / EBook / LMS  
        //a999feep->feeother2     := memvar->nfeeoth2 //LMS FEE
        

        
        /*
        a999feep->feelibr       := memvar->nfeelib
        a999feep->feemed        := memvar->nfeemed 
        a999feep->feeden        := memvar->nfeeden
        a999feep->feeath        := memvar->nfeeath
        a999feep->feeguid       := memvar->nfeegui
        a999feep->feetest       := memvar->nfeetes
        a999feep->feeaudvis     := memvar->nfeeaud
        a999feep->feestuddev    := memvar->nfeestu
        a999feep->feeprisaa     := memvar->nfeepri
     //   a999feep->feeculturl    := memvar->nfeecul
        
        a999feep->feeupgrade    := memvar->nfeemod
        a999feep->feeresdevt    := memvar->nfeeres
        a999feep->feeother1     := memvar->nfeeoth1
        
        a999feep->feeother3     := memvar->nfeeoth3
        a999feep->feeother4     := memvar->nfeeoth4
        a999feep->feeother5     := memvar->nfeeoth5
        a999feep->feecolfee1    := memvar->nfeecol1
        a999feep->feecolfee2    := memvar->nfeecol2
        a999feep->feecolfee3    := memvar->nfeecol3
        a999feep->feecolfee4    := memvar->nfeecol4
        */
        a999feep->(dbcommit())
        a999feep->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*-------------------------------------------------------------------------------
#define _ICODE          1
#define _SUBJ           2
#define _TYPE           3
#define _UNITS          4
#define _SEM1           5
#define _SEM2           6
#define _SUMMER         7
#define _EMPTY          {space(06),space(12),space(03),0,0,0,0}

function labfeeentry()
local getlist:={},alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      clastcolor:=setcolor(memvar->colorarray[11]),lconfirm:=set(_SET_CONFIRM),;
      aprvsetup,aentryscr,lexist,cprocsts,olab,bindex,bitems,ddate
private aitems:={},nindex,cfeeyr,cversion,ccolcode

if(aprvsetup:=openwcheck({{,,"a999lbfp",,_DBF_SHARED,,1},;
                          {,,"c999crsp",,_DBF_SHARED,,1,"/crunlib"},;
                          {,,"c999curp",,_DBF_SHARED,,1,"/crunlib"},;
                          {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Laboratory Fees Entry  ")
commandline("³         F4 - View College            ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
memvar->cfeeyr    := space(02)
memvar->cversion  := space(01)
memvar->ccolcode  := space(02)
bindex    := memvarblock("NINDEX")
bitems    := memvarblock("AITEMS")
olab      := createabrowse(bitems,bindex,07,02,23,77,;
                        {|xnmode,xoabrowser,xaxparam|flab(xnmode,xoabrowser,xaxparam)},;
                        {{{||" "+memvar->aitems[memvar->nindex,_ICODE]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_SUBJ ]+" "},nil},;
                         {{||" "+memvar->aitems[memvar->nindex,_TYPE ]+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_UNITS ],"999.9")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_SEM1],"999,999.99")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_SEM2],"999,999.99")+" "},nil},;
                         {{||" "+transform(memvar->aitems[memvar->nindex,_SUMMER],"999,999.99")+" "},nil}},;
                        {"INT-Code", "    Subject   ", " Type", " Units ", "  1st Sem.  ", "  2nd Sem.  ", "   Summer   "},;
                        {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄ","ÂÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄ"},;
                        {"³","³","³","³","³","³","³"},;
                        {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄ","ÁÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄ"})
                       *  x123456x    x123456789012x    x123x    x123.1x    x123,123.12x    x123,123.12x    x123,123.12x
do while .t.
        restscr(aentryscr)
        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Fee Year  . . . . . :";
                color memvar->colorarray[02];
                get memvar->cfeeyr      pict "@!";
                valid ! empty(memvar->cfeeyr)
        @ 03,02 say "Curriculum:" colo memvar->colorarray[02]
        @ 04,02 say "  Version . . . . . :";
                color memvar->colorarray[02];
                get memvar->cversion    pict "@!";
                valid ! empty(memvar->cversion)
        @ 05,02 say "  College . . . . . :";
                color memvar->colorarray[02];
                get memvar->ccolcode    pict "@!";
                valid ! empty(memvar->ccolcode)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999colp->(dbseek(memvar->ccolcode))
                fask(13,"   College code "+alltrim(memvar->ccolcode)+" not exist.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if ! c999curp->(dbseek(memvar->cversion+memvar->ccolcode))
                fask(13,"   Curriculum File not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        ddate := ctod("01/01/"+memvar->cfeeyr)
        @ 02,27 say "- "+substr(dtos(ddate),1,4)
        @ 05,27 say "- "+c999colp->coldesabr
        memvar->aitems := {_EMPTY}
        memvar->nindex := 1
        processlab()
        dispbox(06,01,23,78,_SINGLE_LINE)
        connectline(08,01,78)
        stabilize(olab,.t.)
        commandline("³      Ù - Add/Edit      ³       F10 - Save       ³       ESC - Previous      ³")
        browsearray(olab,{""},{|b|b:gotop()})
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)

static function flab(nmode,oabrowser,axparam)
local nexit
do case
        case lastkey() == K_ESC
                return 0
        case nmode == 0
                return 1
        case lastkey() == K_ENTER
                editlab(oabrowser)
        case lastkey() == K_F10
                if len(memvar->aitems) <= 1
                        return(recordlab())
//                        fask(13,"  Can't save.  No items entered.  ",{" Ok "},memvar->colorarray[05])
                elseif fask(13,"  Do you want to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        return(recordlab())
                endif
                clearbuffer()
endcase
return 2


static function editlab(oabrowser)
local getlist:={},nrec,acmdline:=savescr(24,00,24,79),acmddetail,;
      nlastcursor:=setcursor(),lconfirm:=set(_SET_CONFIRM),;
      nlastrec:=len(memvar->aitems),nrow:=row(),;
      nsem1,nsem2,nsummer
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{1,2})
commandline("³                               ESC - Previous                                 ³")
acmddetail      := savescr(24,00,24,79)
nsem1           := memvar->aitems[memvar->nindex,_SEM1]
nsem2           := memvar->aitems[memvar->nindex,_SEM2]
nsummer         := memvar->aitems[memvar->nindex,_SUMMER]
do while .t.
        restscr(acmddetail)
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ nrow,41 get nsem1     pict "999,999.99"
        @ nrow,54 get nsem2     pict "999,999.99"
        @ nrow,67 get nsummer   pict "999,999.99"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                clearbuffer()
                exit
        endif
        if lastkey() == K_ENTER
                memvar->aitems[memvar->nindex,_SEM1]   := nsem1
                memvar->aitems[memvar->nindex,_SEM2]   := nsem2
                memvar->aitems[memvar->nindex,_SUMMER] := nsummer
                __keyboard(chr(K_DOWN))
                exit
        endif
enddo
oabrowser:colorrect({oabrowser:rowpos,oabrowser:leftvisible,oabrowser:rowpos,oabrowser:rightvisible},{2,2})
restscr(acmdline)
return(nil)

static function processlab()
local nlastelem,nctr
c999curp->(dbsetrelation("c999crsp",{||c999curp->curintcod},"c999curp->curintcod"))
c999curp->(sx_setscope(_TOP_SCOPE   ,memvar->cversion+memvar->ccolcode))
c999curp->(sx_setscope(_BOTTOM_SCOPE,memvar->cversion+memvar->ccolcode))
c999curp->(dbgotop())
do while ! c999curp->(eof())
        fask(13,"  Processing Internal Code "+alltrim(c999curp->curintcod)+" Subject "+alltrim(c999curp->cursubcod)+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if ! empty(c999curp->curintcod)
                if a999lbfp->(dbseek(memvar->cfeeyr+c999curp->curintcod+c999curp->curcolcod))
                        nlastelem:=len(memvar->aitems)
                        memvar->aitems[nlastelem,_ICODE ]       := a999lbfp->lbfintcod
                        memvar->aitems[nlastelem,_SUBJ  ]       := a999lbfp->lbfsubcod
                        memvar->aitems[nlastelem,_TYPE  ]       := if(a999lbfp->lbfsubtyp=="L","LAB","   ")
                        memvar->aitems[nlastelem,_UNITS ]       := a999lbfp->lbfunt
                        memvar->aitems[nlastelem,_SEM1  ]       := a999lbfp->lbfamt1
                        memvar->aitems[nlastelem,_SEM2  ]       := a999lbfp->lbfamt2
                        memvar->aitems[nlastelem,_SUMMER]       := a999lbfp->lbfamt3
                        aadd(memvar->aitems,_EMPTY)
                else
                        nlastelem:=len(memvar->aitems)
                        memvar->aitems[nlastelem,_ICODE ]       := c999curp->curintcod
                        memvar->aitems[nlastelem,_SUBJ  ]       := c999curp->cursubcod
                        memvar->aitems[nlastelem,_TYPE  ]       := if(c999curp->cursubtyp=="L","LAB","   ")
                        memvar->aitems[nlastelem,_UNITS ]       := c999crsp->crscreunt
                        memvar->aitems[nlastelem,_SEM1  ]       := 0
                        memvar->aitems[nlastelem,_SEM2  ]       := 0
                        memvar->aitems[nlastelem,_SUMMER]       := 0
                        aadd(memvar->aitems,_EMPTY)
                endif
        endif
        c999curp->(dbskip())
enddo
c999curp->(clearscope())
c999curp->(dbclearrelation())
if len(memvar->aitems) > 1
        for nctr := 1 to len(memvar->aitems)
                if empty(memvar->aitems[nctr,_ICODE])
                        adel(memvar->aitems,nctr)
                        asize(memvar->aitems,len(memvar->aitems)-1)
                endif
        next
endif
return(nil)


static function recordlab()
local alastscr:=savescr(01,00,24,79),nctr,nmax
nmax := len(memvar->aitems)
nctr := 0
for nctr := 1 to nmax
        fask(13,"   Saving Internal Code "+alltrim(memvar->aitems[nctr,_ICODE])+" Subject "+alltrim(memvar->aitems[nctr,_SUBJ])+"   ",{" Ok "},memvar->colorarray[06],.f.,nil)
        if a999lbfp->(dbseek(memvar->cfeeyr+memvar->aitems[nctr,_ICODE]+memvar->ccolcode))
                a999lbfp->(reclock())
                a999lbfp->lbfamt1       := memvar->aitems[nctr,_SEM1]
                a999lbfp->lbfamt2       := memvar->aitems[nctr,_SEM2]
                a999lbfp->lbfamt3       := memvar->aitems[nctr,_SUMMER]
        else
                a999lbfp->(recycle())
                a999lbfp->lbfschyr      := memvar->cfeeyr
                a999lbfp->lbfintcod     := memvar->aitems[nctr,_ICODE]
                a999lbfp->lbfcolcod     := memvar->ccolcode
                a999lbfp->lbfsubcod     := memvar->aitems[nctr,_SUBJ]
                a999lbfp->lbfsubtyp     := substr(memvar->aitems[nctr,_TYPE],1,1)
                a999lbfp->lbfunt        := memvar->aitems[nctr,_UNITS]
                a999lbfp->lbfamt1       := memvar->aitems[nctr,_SEM1]
                a999lbfp->lbfamt2       := memvar->aitems[nctr,_SEM2]
                a999lbfp->lbfamt3       := memvar->aitems[nctr,_SUMMER]
        endif
        a999lbfp->(dbcommit())
        a999lbfp->(dbunlock())
next
restscr(alastscr)
return(0)

*-------------------------------------------------------------------------------

function feeyear()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      clastcolor:=setcolor(memvar->colorarray[11]),nlastcursor:=setcursor(),;
      aprv1setup,aprv2setup,aentryscr,cyytenrp,cprocsts,;
      cterm,cdesc,cacctno,cfeeyr

if(aprv1setup:=openwcheck({{,,"term",,_DBF_SHARED,,1,"/crunlib"}}))==nil
        return(nil)
endif
do while .t.
        cterm   := space(len(term->code))
        boxshadow(04,16,21,63,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  BasicEd Fee Year Entry  ")
        commandline("³        F4 - View Term File           ³            ESC - Previous             ³")
        @ 06,17 say replicate("Ä",46)
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 05,18 say "School Term :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(cterm))
                fask(10,"  Term "+cterm+" not yet created...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        if term->status == _CLOSED
                fask(10,"   Transaction of "+alltrim(name)+" was already closed.   ;"+;
                        "            No further information available.",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 05,36 say "- "+substr(term->name,1,25)
        if ! file("\crunlib\"+"c"+cterm+"enrp.dbf")
                fask(10,"  C"+cterm+"ENRP.DBF not yet created...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr    := savescr(01,00,24,79)
        cyytenrp     := "c"+cterm+"enrp"
        if(aprv2setup:=openwcheck({{,,"a999feep",,_DBF_SHARED,,1},;
                                   {,,"a999accp",,_DBF_SHARED,,1},;
                                   {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"},;
                                   {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1,"/crunlib"}}))==nil
                return(nil)
        endif
        cacctno := space(len(a999accp->accidno))
        do while .t.
                restscr(aentryscr)
                cfeeyr  := space(02)
                commandline("³          F4 - View Student           ³           ESC - Previous              ³")
                setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 07,18 say "Account No. :";
                        color memvar->colorarray[02];
                        get cacctno     pict "@!";
                        valid ! empty(cacctno)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
                if lastkey() == K_ESC
                        exit
                endif
                if ! cyytenrp->(dbseek(substr(cacctno,2)))
                        fask(10,"   Student does not enrolled this semester.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                if ! a999accp->(dbseek(cacctno))
                        fask(10,"   Student accounts not yet created.   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                else
                        cfeeyear := a999accp->accfeeyr
                endif

                a999accp->(dbseek(cacctno))

                if ! a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AM,GS,AG,ST,HU,OO,IC" 
                        fask(10,"Fee Year Entry of College ("+a999accp->acccolcod+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                if a999accp->acccolcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA" .and. alltrim(substr(cterm,3,1)) != "1"
                        fask(10,"Fee Year Entry of Elem/JH ("+a999accp->acccolcod+") is ALLOWED during;"+;
                        "1ST SEMESTERS ONLY. Please Enter Fee Year in 1st Semester.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif

                c999colp->(dbseek(a999accp->acccolcod))
                @ 09,18 say "              "+a999accp->acclname
                @ 09,18 say "Last Name   : " color memvar->colorarray[02]
                @ 11,18 say "              "+a999accp->accfname
                @ 11,18 say "First Name  : " color memvar->colorarray[02]
                @ 13,18 say "              "+a999accp->accmname
                @ 13,18 say "Middle Name : " color memvar->colorarray[02]
                @ 15,18 say "              "+a999accp->acccolcod+" - "+c999colp->coldesabr
                @ 15,18 say "Course      : " color memvar->colorarray[02]
                @ 17,18 say "              "+a999accp->accyrlevl
                @ 17,18 say "Year        : " color memvar->colorarray[02]
                setcursor(1);set(_SET_CONFIRM,.t.)
                @ 19,18 say "Fee Year    :";
                        color memvar->colorarray[02];
                        get cfeeyear    pict "@!";
                        valid ! empty(cfeeyear)
               read
                setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
                if lastkey() == K_ESC
                        loop
                endif
                if ! fask(20,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
                        loop
                endif
                a999accp->(reclock())
                a999accp->accfeeyr := cfeeyear
                a999accp->(dbcommit())
                a999accp->(dbunlock())
        enddo
        closewcheck(aprv2setup)
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
//GOVT SUBSIDY FEE ENTRY
function subsidyentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate
private cstrndyr,cstrndbcod,cterm,cstrndsbsid,cstrndamount

if(aprvsetup := openwcheck({{,,"a999stra",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  BasicEd Subsidy Fees Master File Entry  ")
commandline("³         F4 - View College File       ³            ESC - Previous             ³")
aentryscr:=savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        memvar->cstrndyr        := space(len(a999stra->strndyr))
        memvar->cstrndbcod      := space(len(a999stra->strndbcod))
        memvar->cterm           := space(len(a999stra->strndtrm))
        memvar->cstrndsbsid     := space(len(a999stra->strndsbsid))

        memvar->cstrndamount    := 0
            
        clearbuffer()
        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Fee Year . . . . . . . . . . . . :";
                color memvar->colorarray[02];
                get memvar->cstrndyr      pict "@!";
                valid ! empty(memvar->cstrndyr)

        @ 03,02 say "Grade Level or Strand  . . . . . :";
                color memvar->colorarray[02];
                get memvar->cstrndbcod    pict "@!";
                valid ! empty(memvar->cstrndbcod)

        //@ 04,40 say "[1  2  4]" color memvar->colorarray[02]
        @ 04,02 say "Term or High School Session  . . :";
                color memvar->colorarray[02];
                get memvar->cterm       pict "@!";
                valid ! empty(memvar->cterm)

        @ 05,40 say "[1]|[2]|[3][4] " color memvar->colorarray[02]
        @ 05,02 say "Pub|PrE|PrwE|UCESC: . . . :";
                color memvar->colorarray[02];
                get memvar->cstrndsbsid       pict "@!";
                valid memvar->cstrndsbsid $ "1234"

       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999colp->(dbseek(memvar->cstrndbcod))
                fask(10," Grade or Strand Code "+alltrim(memvar->cstrndbcod)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif

        if ! memvar->cstrndbcod $ "K1,K2,N1,G1,G2,G3,G4,G5,G6,G7,G8,G9,GA,AM,GS,AG,ST,HU,OO,IC" 
                        fask(10,"Fee Entry of College ("+memvar->cstrndbcod+") is not ALLOWED ;"+;
                        "in BasicEd Accounting Program.",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
        endif

        ddate := ctod("01/01/"+memvar->cstrndyr)
        @ 02,40 say "- "+substr(dtos(ddate),1,4)
        @ 03,40 say "- "+c999colp->coldesabr
        if lexist := a999stra->(dbseek(memvar->cstrndyr+memvar->cstrndbcod+memvar->cterm+memvar->cstrndsbsid))
                if ! a999stra->(reclock())
                        loop
                endif
                //display 
                memvar->cstrndamount    := a999stra->strndamoun
        endif
        do while .t.
                commandline("³             F10 - Record             ³           ESC - Previous              ³")
                setkey(K_F10,{||savesubsidy(lexist)})
                setcursor(1);set(_SET_CONFIRM,.t.)
      
                @ 08,02 say "Subsidy Amount . . . . . . . . . . . . :";
                    color memvar->colorarray[02];
                    get memvar->cstrndamount     pict "999,999.99" 

               read
                
                if lastkey() == K_ESC
                        exit
                endif
        enddo
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F10,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)


//SAVE ENTRIES
static function savesubsidy(lexist)
if fask(18,"  Are you sure to save this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        if ! lexist
                a999stra->(recycle())
        endif
        a999stra->strndyr       := memvar->cstrndyr
        a999stra->strndbcod     := memvar->cstrndbcod
        a999stra->strndtrm      := memvar->cterm
        a999stra->strndsbsid    := memvar->cstrndsbsid
        a999stra->strndamoun    := memvar->cstrndamount

        a999stra->(dbcommit())
        a999stra->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)

*-------------------------------------------------------------------------------
//PROMOTIONAL DISCOUNT
function promotionalentry()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      aprvsetup,cprocsts,lexist:=.f.,aentryscr,ddate
private promoyr,promostrnd,promoterm,promoyrlvl,promoamnt

if(aprvsetup := openwcheck({{,,"a999prm",,_DBF_SHARED,,1},;
                            {,,"c999colp",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  BasicEd Promotional Discount Master File Entry  ")
commandline("³         F4 - View College File       ³            ESC - Previous             ³")
aentryscr:=savescr(01,00,24,79)
do while .t.
        restscr(aentryscr)
        memvar->promoyr         := space(len(a999prm->promoyr))
        memvar->promostrnd      := space(len(a999prm->promostrnd))
        memvar->promoterm       := space(len(a999prm->promoterm))
        memvar->promoyrlvl      := space(len(a999prm->promoyrlvl))
        memvar->promoamnt       := 0
            
        clearbuffer()
        setkey(K_F4,{||if(readvar()=="MEMVAR->CCOLCODE",vcolcode(space(len(c999colp->colcod)),cprocsts,memvar->colorarray[10]),)})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Fee Year . . . . . . . :";
                color memvar->colorarray[02];
                get memvar->promoyr      pict "@!";
                valid ! empty(memvar->promoyr)

        @ 03,02 say "Strand  Code . . . . . :";
                color memvar->colorarray[02];
                get memvar->promostrnd    pict "@!";
                valid ! empty(memvar->promostrnd)

        
        @ 04,02 say "Term . . . . . . . . . :";
                color memvar->colorarray[02];
                get memvar->promoterm       pict "@!";
                valid ! empty(memvar->promoterm)

        //@ 05,40 say "[1]|[2]|[3][4] " color memvar->colorarray[02]
        @ 05,02 say "Grade Level (11 or 12) :";
                color memvar->colorarray[02];
                get memvar->promoyrlvl       pict "@!";
                valid ! empty(memvar->promoyrlvl)

       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! c999colp->(dbseek(memvar->promostrnd))
                fask(10,"Strand Code "+alltrim(memvar->promostrnd)+" not found.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
       
        if ! memvar->promostrnd $ "GS,AG,ST,HU,OO,IC" 
                        fask(10,"Promotional Discount Entry ("+memvar->promostrnd+") is not ALLOWED ;"+;
                        "if not Senior High",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
        endif

        ddate := ctod("01/01/"+memvar->promoyr)
        @ 02,40 say "- "+substr(dtos(ddate),1,4)
        @ 03,40 say "- "+c999colp->coldesabr
        if lexist := a999prm->(dbseek(memvar->promoyr+memvar->promostrnd+memvar->promoterm+memvar->promoyrlvl))
                if ! a999prm->(reclock())
                        loop
                endif

                //display 
                memvar->promoamnt    := a999prm->promoamnt
        endif
        do while .t.
                commandline("³             F10 - Record             ³           ESC - Previous              ³")
                setkey(K_F10,{||savepromotionaldiscount(lexist)})
                setcursor(1);set(_SET_CONFIRM,.t.)
      
                @ 08,02 say "Promotional Discount . . . . . . . . . . . . :";
                    color memvar->colorarray[02];
                    get memvar->promoamnt     pict "999,999.99" 

               read
                
                if lastkey() == K_ESC
                        exit
                endif
        enddo
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F10,nil)
enddo
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)


//SAVE ENTRIES
static function savepromotionaldiscount(lexist)
if fask(18,"  Are you sure to save this record ?  ",{" Yes "," No  "},memvar->colorarray[05])==1
        if ! lexist
                a999prm->(recycle())
        endif
        a999prm->promoyr        := memvar->promoyr
        a999prm->promostrnd     := memvar->promostrnd
        a999prm->promoterm      := memvar->promoterm
        a999prm->promoyrlvl     := memvar->promoyrlvl
        a999prm->promoamnt      := memvar->promoamnt

        a999prm->(dbcommit())
        a999prm->(dbunlock())
        __keyboard(chr(K_ESC))
endif
return(nil)