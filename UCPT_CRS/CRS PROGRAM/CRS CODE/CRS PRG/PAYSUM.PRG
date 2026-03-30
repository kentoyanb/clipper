*-------------------------------------------------------------------------------
function paysummary()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup
private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,cterm,payday := space(01)

if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
memvar->cterm := space(len(term->code))
do while .t.
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[11],"  Study Load Printing  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "School Term :";
                color memvar->colorarray[02];
                get cterm       pict "@!";
                valid ! empty(cterm)
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(10,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 02,20 say "- "+term->name
        memvar->ctdesc := term->name
        @ 03,02 say "Pay Day        : ";
                color memvar->colorarray[02];
                get payday      pict "@!";
                valid ! empty(payday)
        @ 03,23 say "[1-15th, 2-30th ]" color memvar->colorarray[01]
        @ 03,24 say "1" color memvar->colorarray[02]
        @ 03,32 say "2" color memvar->colorarray[02]
        read
        if lastkey() == K_ESC
                exit
        endif

        if whereprint({||ppayslip(cterm,payday)}) == 1
                __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
                viewtextfile()
        endif
enddo
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)

static function ppaysummary(cterm,payday)
local getlist := {}, entryscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist,cprocsts,ostudy,bindex,bitems,aentryscr,;
      cyytenrp, cyytskdp, cyytflag, aprv1setup, i:=j:=0

private aitems := {},nindex := 1,;
        tidno,tlname,tfname,tmname,pstring := space(39),;
        cdummy := "psumlst"+strzero(memvar->naccess,2), psumfil,;
        deductables := .f.

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy,{{"PAYDAY"     ,"D",08,0},;
                                 {"PAY01"      ,"N",09,2},;
                                 {"PAY02"      ,"N",09,2},;
                                 {"PAY03"      ,"N",09,2},;
                                 {"PAY04"      ,"N",09,2},;
                                 {"PAY05"      ,"N",09,2},;
                                 {"PAY06"      ,"N",09,2},;
                                 {"PAY07"      ,"N",09,2},;
                                 {"PAY08"      ,"N",09,2},;
                                 {"PAY09"      ,"N",09,2},;
                                 {"PAY10"      ,"N",09,2},;
                                 {"PAY01"      ,"N",09,2},;
                                 {"PAY12"      ,"N",09,2},;
                                 {"PAY13"      ,"N",09,2},;
                                 {"PAY14"      ,"N",09,2},;
                                 {"PAY15"      ,"N",09,2},;
                                 {"PAY16"      ,"N",09,2},;
                                 {"PAY17"      ,"N",09,2},;
                                 {"PAY18"      ,"N",09,2},;
                                 {"PAY19"      ,"N",09,2},;
                                 {"PAY20"      ,"N",09,2},;
                                 {"PAY21"      ,"N",09,2},;
                                 {"PAY22"      ,"N",09,2},;
                                 {"PAY23"      ,"N",09,2},;
                                 {"PAY24"      ,"N",09,2},;
                                 {"PAY25"      ,"N",09,2}},{||cdxpsum()})
        dbcloseall()
        return(nil)
endif
memvar->psumfil := memvar->cdummy
if(afile := openwcheck({{,,(memvar->psumfil+".TXT"),"psumfil",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
        aentryscr       := savescr(01,00,24,79)
        cyytskdp     := alltrim("c"+cterm+"skdp")
        if(aprvsetup := openwcheck({{,,cyytskdp,"cyytskdp",_DBF_SHARED,,2},;
                                    {,,"t999lst" ,,_DBF_SHARED,,2},;
                                    {,,"chart"   ,,_DBF_SHARED,,1},;
                                    {,,"accnt_no",,_DBF_SHARED,,1},;
                                    {,,"c021pslp",,_DBF_SHARED,,1}})) == nil
                return(nil)
        endif

        c021pslp->(dbgotop())
        do while ! c021pslp->(eof())

        enddo
        closewcheck(aprvsetup)
return

/*static function cdxpslip()
field idno
private cdummyfile := alias()
index on idno tag (memvar->cdummyfile+"1") of (memvar->cdummyfile)
return(nil)
  */
