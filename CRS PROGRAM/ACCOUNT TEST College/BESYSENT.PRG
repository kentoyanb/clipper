* Program       :       SYSENT.PRG - General System Entry
* Author        :       Randy F. Santizo (c) January 1999
* Installation  :       UC-METC

#Include "Inkey.Ch"
#Include "SixCdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

*-------------------------------------------------------------------------------
function newidno()
static ostudent, nlastorder
local alastscr := savescr(01,00,24,79), nlastcursor := setcursor(0), ;
      clastcolor := setcolor(),aprvsetup,cprocsts

if(aprvsetup := openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                            {,,"c999sm1p",,_DBF_SHARED,,2,"/crunlib"},;
                            {,,"idnocon",,_DBF_SHARED,,,"/crunlib"}})) == nil
        return(nil)
endif

ostudent  := c999sm1p->(createbrowse(07,06,20,73,;
                {|xnmode,xacfields,xobrowser,xaxparam|fstd(xnmode,xacfields,xobrowser,xaxparam)},;
                {"sm1idno","sm1lstnam+', '+sm1fstnam+' '+sm1midnam","' '+sm1sex+' '","'  '+sm1colcod+'  '","' '+transform(sm1yrlevl,'@Z 9')+'  '"},;
                {" ID No. ", "        S t u d e n t   N a m e            ", "Sex", "C-Code", "Year"},;
                {"ÄÄÄÄÄÄÄÄ","ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÂÄÄÄ","ÂÄÄÄÄÄÄ","ÂÄÄÄÄ"},;
                {"³","³","³","³","³"},;
                {"ÄÄÄÄÄÄÄÄ","ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","ÁÄÄÄ","ÁÄÄÄÄÄÄ","ÁÄÄÄÄ"}))
                * 12345678    123456789012345, 123456789012345678901234 1    x1x    xx11xx    x1xx
setcolor(memvar->colorarray[10])
boxshadow(04,04,22,75,"ÛßÛÛÛÜÛÛ ",nil,"  Viewing Student File  ")
outexpr(05,06,"Search Key =>")
dispbox(06,05,20,74,_SINGLE_LINE)
outexpr(08,05,"Ã"); outexpr(08,74,"´")
commandline("³  F6 - Create New ID No. ³  F10 - ReFresh  ³  F12 - Order  ³  ESC - Previous  ³")
clearbuffer()
c999sm1p->(dbgotop())
c999sm1p->(browsefile(ostudent,{"","",cprocsts},{|b|b:gotop()}))
restscr(alastscr); setcolor(clastcolor); setcursor(nlastcursor)
closewcheck(aprvsetup)
return(nil)

function fstd(nmode,acfields,obrowser,axparam)
do case
        case lastkey() == K_ESC
                return 0
        case nmode = 0
                @ 05, 20 say space(40)
                @ 05, 20 say axparam[01]
                @ 21, 06 say "Home Address: "+space(30)
                @ 21, 06 say "Home Address: "+c999sm1p->sm1homadr
                return 1
        case lastkey() == K_F6
                createidno()
        case lastkey() == K_F10
                axparam[01] := ""
        case lastkey() == K_F12
                selectmenu( { { 13, 24, "   " + checkorder(1) + " Order by ID ~Number       ",,,, { || changeorder( obrowser, sx_tagno(), 1 ) },, }, ;
                              { 14, 24, "   " + checkorder(2) + " Order by ~Student Name    ",,,, { || changeorder( obrowser, sx_tagno(), 2 ) },, } }, ;
                            { || boxshadow( 12, 23, 15, 54, "ÛßÛÛÛÜÛÛ ", memvar->colorarray[05] ) }, .t., ;
                            "³          Ù - to Select              ³              ESC - Previous           ³", memvar->colorarray[05],,,,, ;
                            gettrigger(memvar->colorarray[05]))
        case lastkey() >= 32 .and. lastkey() <= 255
                dynamicsearch((axparam[01] := axparam[01] + chr(lastkey())), obrowser)
endcase
return 2


static function createidno()
local getlist:={},cidno,clname,cfname,cmname,csex,ccourse,;
      alastscr:=savescr(01,00,24,79),nlastcursor:=setcursor(),;
      lconfirm:=set(_SET_CONFIRM),clastcolor := setcolor(memvar->colorarray[11]),;
      i,fs,d1,d2,d3,d4,d5,d6,d7,s1,s2,s3,s4,chd


boxshadow(08,17,20,70,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Create New Id Number  ")
commandline("³                               ESC - Previous                                 ³")
/* @ 10,19 say "                     "+cidno
   @ 10,19 say "Student ID Number -> " color memvar->colorarray[02]*/
do while .t.
        clname  := space(len(c999sm1p->sm1lstnam))
        cfname  := space(len(c999sm1p->sm1fstnam))
        cmname  := space(len(c999sm1p->sm1midnam))
        csex    := space(len(c999sm1p->sm1sex))
        ccourse := space(len(c999sm1p->sm1colcod))
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 10,19 say "Last Name         ->";
                color memvar->colorarray[02];
                get clname      pict "@!"
        @ 12,19 say "First Name        ->";
                color memvar->colorarray[02];
                get cfname      pict "@!"
        @ 14,19 say "Middle Initial    ->";
                color memvar->colorarray[02];
                get cmname      pict "@!"
        @ 16,19 say "S e x [M/F]       ->";
                color memvar->colorarray[02];
                get csex        pict "@!";
                valid csex $ "MF"
        @ 18,19 say "Course            ->";
                color memvar->colorarray[02];
                get ccourse      pict "@!";

       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                exit
        endif
        if ! fask(20,"   Save entries ?   ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                exit
        endif
/*----------------------------------------------------------------------*/
        idnocon->(dbgotop())
        i  := val(substr(idnocon->idnumber,3,5))
        i++
        fs := right(dtoc(date()),2)+transform(i,"99999")
        d1 := substr(fs,1,1)
        d2 := val(substr(fs,2,1))
        d3 := substr(fs,3,1)
        d4 := val(substr(fs,4,1))
        d5 := substr(fs,5,1)
        d6 := val(substr(fs,6,1))
        d7 := substr(fs,7,1)
        s1 := val(d1)*2
           s1 := transform(s1,"99")
           s1 := val(substr(s1,1,1))+val(substr(s1,2,1))
        s2 := val(d3)*2
            s2 := transform(s2,"99")
            s2 := val(substr(s2,1,1))+val(substr(s2,2,1))
        s3 := val(d5)*2
            s3 := transform(s3,"99")
            s3 := val(substr(s3,1,1))+val(substr(s3,2,1))
        s4 := val(d7)*2
            s4 := transform(s4,"99")
            s4 := val(substr(s4,1,1))+val(substr(s4,2,1))
        chd := transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
        chd := int(10-val(chd))
        if chd == 10
            cidno := fs+"0"
        else
            cidno := fs+transform(chd,"9")
        end
        cidno := strtran(cidno," ","0")
/*----------------------------------------------------------------------*/
        idnocon->(reclock())
        idnocon->idnumber       := cidno
        idnocon->rectrail       := dtoc(date())+";"+time()+";"+memvar->cusername
        idnocon->(dbcommit())
        idnocon->(dbunlock())

        c999sm1p->(recycle())
        c999sm1p->sm1idno       := cidno
        c999sm1p->sm1lstnam     := clname
        c999sm1p->sm1fstnam     := cfname
        c999sm1p->sm1midnam     := cmname
        c999sm1p->sm1sex        := csex
        c999sm1p->sm1colcod     := ccourse
        c999sm1p->(dbcommit())
        c999sm1p->(dbunlock())

        a999accp->(recycle())
        a999accp->accidno       := "2"+cidno
        a999accp->acclname      := clname
        a999accp->accfname      := cfname
        a999accp->accmname      := cmname
        a999accp->acccolcod     := ccourse
        a999accp->(dbcommit())
        a999accp->(dbunlock())

        exit
enddo
restscr(alastscr)
c999sm1p->(sx_settagorder(2))
return(nil)

*-------------------------------------------------------------------------------

function changedname()
local getlist:={},alastscr:=savescr(01,00,24,79),lconfirm:=set(_SET_CONFIRM),;
      nlastcursor:=setcursor(),clastcolor:=setcolor(memvar->colorarray[11]),;
      openfile,cprocsts,aentryscr,;
      cidno,clname,cfname,cmname,ccolcod

if(openfile:=openwcheck({{,,"a999accp",,_DBF_SHARED,,1},;
                         {,,"c999sm1p",,_DBF_SHARED,,1,"/crunlib"}})) == nil
        return(nil)
endif
boxshadow(08,17,20,65,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Changed Student Name  ")
commandline("³         F4 - View Student File       ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
cidno := space(len(a999accp->accidno))
do while .t.
        restscr(aentryscr)
        clname  := space(len(c999sm1p->sm1lstnam))
        cfname  := space(len(c999sm1p->sm1fstnam))
        cmname  := space(len(c999sm1p->sm1midnam))
        ccolcod := space(len(c999sm1p->sm1colcod))
        clearbuffer()
        setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 10,19 say "Student Id Number :";
                color memvar->colorarray[02];
                get cidno pict "@!";
                valid ! empty(cidno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
/*
        if ! valid_id(cidno)
                fask(10,"  "+alltrim(cidno)+" does not follow modulus 10 check.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
*/


        if ! a999accp->(dbseek(cidno))
                fask(18,"  Student not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                if fask(13,"  Create Student?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                        clname := space(len(a999accp->acclname))
                        cfname := space(len(a999accp->accfname))
                        cmname := space(len(a999accp->accmname))
                        ccolcod:= space(len(a999accp->acccolcod))
                else
                        loop
                endif
        else
                        clname := a999accp->acclname
                        cfname := a999accp->accfname
                        cmname := a999accp->accmname
                        ccolcod:= a999accp->acccolcod
        endif
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 12,19 say "Last Name         :";
                color memvar->colorarray[02];
                get clname      pict "@!"
        @ 14,19 say "First Name        :";
                color memvar->colorarray[02];
                get cfname      pict "@!"
        @ 16,19 say "Middle Initial    :";
                color memvar->colorarray[02];
                get cmname      pict "@!"
        @ 18,19 say "Course            :";
                color memvar->colorarray[02];
                get ccolcod     pict "@!"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(18,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif

        if ! a999accp->(dbseek(cidno))
                a999accp->(recycle())
                a999accp->accidno := cidno
        else
                a999accp->(reclock())
        endif
        a999accp->acclname := clname
        a999accp->accfname := cfname
        a999accp->accmname := cmname
        a999accp->acccolcod:= ccolcod
        a999accp->(dbcommit())
        a999accp->(dbunlock())

        if left(cidno,1)=="1"
                if c999sm1p->(dbseek(right(cidno,8)))
                        c999sm1p->(reclock())
                else
                        c999sm1p->(recycle())
                        c999sm1p->sm1idno   := right(cidno,8)
                endif
                c999sm1p->sm1lstnam := clname
                c999sm1p->sm1fstnam := cfname
                c999sm1p->sm1midnam := cmname
                c999sm1p->(dbcommit())
                c999sm1p->(dbunlock())
        endif
enddo
restscr(alastscr)
closewcheck(openfile)
return(nil)

*------------------------------------------------------------------------------*

function chgstudbal()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aopenfiles,cprocsts,cacctno,ccolcode,cyrlevl,csytstart,csytenrol,;
      castatus,cscholar,npdisc,nadisc,cfeeyr,nfeeunit,nunits,;
      ntuifee,nmisfee,nlabfee,nothfee,nassfee,ntotfee,noldacct,nadj,;
      ntotdue,namtpd,ntotbal

if(aopenfiles := openwcheck({{,,"a999accp",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
boxshadow(01,00,24,79,"ÛßÛÛÛÜÛÛ ",memvar->colorarray[11],"  Edit Account Master File  ")
commandline("³         F4 - View Account File       ³            ESC - Previous             ³")
aentryscr := savescr(01,00,24,79)
cacctno := space(len(a999accp->accidno))
do while .t.
        restscr(aentryscr)
        ccolcode        := space(len(a999accp->acccolcod))
        cyrlevl         := space(len(a999accp->accyrlevl))
        csytstart       := space(len(a999accp->accsytstr))
        csytenrol       := space(len(a999accp->accsyt))
        castatus        := space(len(a999accp->accst))
        cscholar        := space(len(a999accp->acccode))
        npdisc          := 0
        nadisc          := 0
        cfeeyr          := space(len(a999accp->accfeeyr))
        nfeeunit        := 0
        nunits          := 0
        ntuifee         := 0
        nmisfee         := 0
        nlabfee         := 0
        nothfee         := 0
        nassfee         := 0
        ntotfee         := 0
        noldacct        := 0
        nadj            := 0
        ntotdue         := 0
        namtpd          := 0
        ntotbal         := 0
        clearbuffer()
        setkey(K_F4,{||vacctname({||__keyboard(chr(K_CTRL_LEFT)+a999accp->accidno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 02,02 say "Account Number :";
                color memvar->colorarray[02];
                get cacctno pict "@!";
                valid ! empty(cacctno)
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm);setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! a999accp->(dbseek(cacctno))
                fask(10,"  Account number not found in file.  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 03,02 say "                 "+a999accp->acclname
        @ 03,02 say "Last Name      : " color memvar->colorarray[02]
        @ 04,02 say "                 "+a999accp->accfname
        @ 04,02 say "First Name     : " color memvar->colorarray[02]
        @ 05,02 say "                 "+a999accp->accmname
        @ 05,02 say "Middle Initial : " color memvar->colorarray[02]
        ccolcode        := a999accp->acccolcod
        cyrlevl         := a999accp->accyrlevl
        csytstart       := a999accp->accsytstr
        csytenrol       := a999accp->accsyt
        castatus        := a999accp->accst
        cscholar        := a999accp->acccode
        npdisc          := a999accp->accsytpdsc
        nadisc          := a999accp->accsytadsc
        cfeeyr          := a999accp->accfeeyr
        nfeeunit        := a999accp->accfeeunt
        nunits          := a999accp->accsytunt
        ntuifee         := a999accp->accsyttui
        nmisfee         := a999accp->accsytmisc
        nlabfee         := a999accp->accsytlab
        nothfee         := a999accp->accsytoth
        nassfee         := a999accp->accsytass
        ntotfee         := a999accp->accsyttot
        noldacct        := a999accp->accbalold
        nadj            := a999accp->accadj
        ntotdue         := a999accp->accduetot
        namtpd          := a999accp->accamtpd
        ntotbal         := a999accp->accbaltot
        setcursor(1);set(_SET_CONFIRM,.t.)
        @ 07,02 say "College Code      :";
                color memvar->colorarray[02];
                get ccolcode pict "@!"
        @ 08,02 say "Year Level        :";
                color memvar->colorarray[02];
                get cyrlevl pict "@!"
        @ 09,02 say "SYT Started       :";
                color memvar->colorarray[02];
                get csytstart pict "@!"
        @ 10,02 say "SYT Last Enrolled :";
                color memvar->colorarray[02];
                get csytenrol pict "@!"
        @ 11,02 say "Account Status    :";
                color memvar->colorarray[02];
                get castatus pict "@!"
        @ 12,02 say "Scholarship       :";
                color memvar->colorarray[02];
                get cscholar pict "@!"
        @ 13,02 say "Percent Discount  :";
                color memvar->colorarray[02];
                get npdisc pict "999"
        @ 14,02 say "Amount Discounted :";
                color memvar->colorarray[02];
                get nadisc pict "999,999.99"
        @ 15,02 say "Fee Year Applied  :";
                color memvar->colorarray[02];
                get cfeeyr pict "@!"
        @ 16,02 say "Fee Per Unit      :";
                color memvar->colorarray[02];
                get nfeeunit pict "999,999.99"
        @ 17,02 say "Units Enrolled    :";
                color memvar->colorarray[02];
                get nunits pict "99.9"
        @ 07,41 say "Tuition Fee       :";
                color memvar->colorarray[02];
                get ntuifee pict "999,999.99"
        @ 08,41 say "Miscellaneous Fee :";
                color memvar->colorarray[02];
                get nmisfee pict "999,999.99"
        @ 09,41 say "Laboratory Fee    :";
                color memvar->colorarray[02];
                get nlabfee pict "999,999.99"
        @ 10,41 say "Other Fee         :";
                color memvar->colorarray[02];
                get nothfee pict "999,999.99"
        @ 11,41 say "Assessment Fee    :";
                color memvar->colorarray[02];
                get nassfee pict "999,999.99"
        @ 12,41 say "Total Fee         :";
                color memvar->colorarray[02];
                get ntotfee pict "999,999.99"
        @ 13,41 say "Old Account       :";
                color memvar->colorarray[02];
                get noldacct pict "999,999.99"
        @ 14,41 say "Adjustments       :";
                color memvar->colorarray[02];
                get nadj pict "999,999.99"
        @ 15,41 say "Total Due         :";
                color memvar->colorarray[02];
                get ntotdue pict "999,999.99"
        @ 16,41 say "Total Amount Paid :";
                color memvar->colorarray[02];
                get namtpd pict "999,999.99"
        @ 17,41 say "Total Balance     :";
                color memvar->colorarray[02];
                get ntotbal pict "999,999.99"
       read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ESC
                loop
        endif
        if ! fask(18,"  Are you sure to save entries ?  ",{" Yes "," No  "},memvar->colorarray[05]) == 1
                loop
        endif
        a999accp->(dbseek(cacctno))
        a999accp->(reclock())
        a999accp->acccolcod     := ccolcode
        a999accp->accyrlevl     := cyrlevl
        a999accp->accsytstr     := csytstart
        a999accp->accsyt        := csytenrol
        a999accp->accst         := castatus
        a999accp->acccode       := cscholar
        a999accp->accsytpdsc    := npdisc
        a999accp->accsytadsc    := nadisc
        a999accp->accfeeyr      := cfeeyr
        a999accp->accfeeunt     := nfeeunit
        a999accp->accsytunt     := nunits
        a999accp->accsyttui     := ntuifee
        a999accp->accsytmisc    := nmisfee
        a999accp->accsytlab     := nlabfee
        a999accp->accsytoth     := nothfee
        a999accp->accsytass     := nassfee
        a999accp->accsyttot     := ntotfee
        a999accp->accbalold     := noldacct
        a999accp->accadj        := nadj
        a999accp->accduetot     := ntotdue
        a999accp->accamtpd      := namtpd
        a999accp->accbaltot     := ntotbal
        a999accp->(dbcommit())
        a999accp->(dbunlock())
enddo
restscr(alastscr)
closewcheck(aopenfiles)
return(nil)

*------------------------------------------------------------------------------*
