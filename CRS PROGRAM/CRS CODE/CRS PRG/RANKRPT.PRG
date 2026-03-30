*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Program       : RANKRPT.PRG
* Author        : Abundio C. Navarro and Jun Benlot (c) August 1999
* Installation  : UC-METC
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
#include "inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"
#include "user.ch"
function rankrpt()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist:=.t.,cprocsts,oenroll,bindex,bitems,aentryscr,nterm:=0,;
      cyytenrp, aprv1setup,cnmsg:=space(36),nrec:=0,cdesc:=space(15)
private aitems := {},nindex := 1, lpassedit,cname,;
        clname, cfname, cmname,cterm := space(03), cidno := space(08),;
        lconf := .f.,chaddr,ccaddr,crank:=space(4),ddboard:=ctod('  \  \  '),;
        nlastorder1,nctr:=0,rankrep:="rank"+strzero(memvar->naccess,2),rkpfile,arkfile
if(aprv1setup := openwcheck({{,,"term",,_DBF_SHARED,,1}})) == nil
        return(nil)
endif
make_file()
memvar->rkpfile:=memvar->rankrep
openwcheck({{,,(memvar->rkpfile+".TXT"),"rkpfile",_DBF_EXCLUSIVE,,1}})
do while .t.
        rkpfile->(__dbzap());rkpfile->(dbreindex())
        clearbuffer()
        boxshadow(01,00,23,79,"лплллмлл ",memvar->colorarray[54],"  Graduates/Officers Printing  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||viewterm({||__keyboard(chr(K_CTRL_LEFT)+term->code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        draw_box2(02,05,04,19,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        draw_box1(02,21,04,28,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        @ 03,07 say "School Term ";
                color memvar->colorarray[55]
        @ 03,23 get memvar->cterm pict "@!";
                valid ! empty(memvar->cterm) color memvar->colorarray[54]
        read
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        setkey(K_F4,nil)
        if lastkey() == K_ESC
                exit
        endif
        if ! term->(dbseek(memvar->cterm))
                fask(17,"  Term "+memvar->cterm+" not found...  ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        @ 03,30 say "- "+term->name color memvar->colorarray[54]
        if ! file(alltrim("c"+memvar->cterm+"enrp.dbf"))
                fask(17,"  C"+cterm+"ENRP.DBF not found...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                loop
        endif
        aentryscr       := savescr(01,00,24,79)
        cyytenrp        := alltrim("c"+memvar->cterm+"enrp")
        if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                                    {,,"c999sm2p",,_DBF_SHARED,,1},;
                                    {,,"c999offr",,_DBF_SHARED,,2},;
                                    {,,"c999rank",,_DBF_SHARED,,1},;
                                    {,, cyytenrp ,"cyytenrp",_DBF_SHARED,,1}})) == nil
                return(nil)
        endif
        do while .t.
                restscr(aentryscr)
                setcursor(1);set(_SET_CONFIRM,.t.)
                commandline("Г        F4 - View Rank File         Г           ESC - Previous             Г")
                setkey(K_F4,{||viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
                memvar->crank:=space(4)
                draw_box2(05,05,07,19,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                draw_box1(05,21,07,28,memvar->colorarray[28],memvar->colorarray[29],,.F.)
                @ 06,07 say "Rank Code   " color memvar->colorarray[55]
                @ 06,30 say "[A-All Rank / GR-All Grad]" color memvar->colorarray[55]
                @ 06,23 get memvar->crank pict "@!" valid check_rank(memvar->crank,cprocsts);
                                color memvar->colorarray[54]
                read
                if lastkey() == K_ESC
                        exit
                endif
                if c999rank->(dbseek(alltrim(memvar->crank)))
                   memvar->cname:=c999rank->r_desc
                @ 06,30 say space(35) color memvar->colorarray[55]
                @ 06,30 say "- "+memvar->cname color memvar->colorarray[55]
                endif
                if alltrim(memvar->crank) == "A"
                    lexist:=.t.
                else
                    lexist:=.f.
                endif
                  //nterm:=val(memvar->cterm)
                  c999offr->(sx_setscope(_TOP_SCOPE ,memvar->cterm))
                  c999offr->(sx_setscope(_BOTTOM_SCOPE ,memvar->cterm))
                  c999offr->(dbgotop())
               if lexist
                while .t.
                    memvar->cidno       := c999offr->r_idno
                    memvar->ddboard     := c999offr->r_datb
                    memvar->crank       := c999offr->r_code
                    memvar->clname      := alltrim(c999offr->r_lname)
                    memvar->cfname      := alltrim(c999offr->r_fname)
                    memvar->cmname      := alltrim(c999offr->r_mname)
                    memvar->chaddr      := alltrim(c999offr->r_haddr)
                    memvar->ccaddr      := alltrim(c999offr->r_caddr)

                 if c999rank->(dbseek(memvar->crank))
                    memvar->cdesc:=c999rank->r_desc
                 else
                    memvar->cdesc:=len(alltrim(c999rank->r_desc))
                 endif

                  fask(17,"  Processing student number "+memvar->cidno+" in student master file...",{" ok "},memvar->colorarray[35],.f.,nil)
                  rkpfile->(dbappend())
                  rkpfile->n_idno    :=memvar->cidno
                  rkpfile->n_term    :=det_rank(memvar->cterm)
                  rkpfile->n_code    :=memvar->crank
                  rkpfile->n_lname   :=memvar->clname
                  rkpfile->n_fname   :=memvar->cfname
                  rkpfile->n_mname   :=memvar->cmname
                  rkpfile->n_citaddr :=memvar->ccaddr
                  rkpfile->n_proaddr :=memvar->chaddr
                  rkpfile->n_desc    :=memvar->cdesc
                  rkpfile->n_date    :=memvar->ddboard
                  rkpfile->n_prio    :=det_prio(memvar->crank)
                  rkpfile->(dbcommit())

                  c999offr->(dbskip())
                  if c999offr->(eof())
                     exit
                  endif
               enddo
              else
              while .t.
               if c999offr->r_code == memvar->crank
                    memvar->cidno   := c999offr->r_idno
                    memvar->ddboard := c999offr->r_datb
                    memvar->clname  := alltrim(c999offr->r_lname)
                    memvar->cfname  := alltrim(c999offr->r_fname)
                    memvar->cmname  := alltrim(c999offr->r_mname)
                    memvar->chaddr  := alltrim(c999offr->r_haddr)
                    memvar->ccaddr  := alltrim(c999offr->r_caddr)

                 if c999rank->(dbseek(memvar->crank))
                    memvar->cdesc:=c999rank->r_desc
                 else
                    memvar->cdesc:=space(len(alltrim(c999rank->r_desc)))
                 endif

                fask(17,"  Processing student number "+memvar->cidno+" in student master file...",{ " ok " },memvar->colorarray[35],.f.,nil)
                  rkpfile->(dbappend())
                  rkpfile->n_idno    :=memvar->cidno
                  rkpfile->n_term    :=det_rank(memvar->cterm)
                  rkpfile->n_code    :=memvar->crank
                  rkpfile->n_lname   :=memvar->clname
                  rkpfile->n_fname   :=memvar->cfname
                  rkpfile->n_mname   :=memvar->cmname
                  rkpfile->n_citaddr :=memvar->ccaddr
                  rkpfile->n_proaddr :=memvar->chaddr
                  rkpfile->n_desc    :=memvar->cdesc
                  rkpfile->n_date    :=memvar->ddboard
                  rkpfile->n_prio    :=det_prio(memvar->crank)
                  rkpfile->(dbcommit())
                 endif
                  c999offr->(dbskip())
                     if c999offr->(eof())
                        exit
                     endif
               enddo
              endif
              if rkpfile->(reccount() > 0)
                 navprint()
              else
                fask(17,"  No record found on "+memvar->cterm+" Term & this rank code "+memvar->crank+" ... ",{" Ok "},memvar->colorarray[05],.t.,nil)
              endif
                   c999offr->(dbunlock())
                        setkey(K_F4,nil)
                        if lastkey() == K_ESC
                                dbunlockall()
                                exit
                        endif
        enddo
        c999offr->(clearscope())
        closewcheck(aprvsetup)
enddo
rkpfile->(dbclosearea())
ferase((rkpfile+".TXT"))
ferase((rkpfile+".CDX"))
closewcheck(aprv1setup)
restscr(alastscr)
return(nil)
*------------------------------------------------------------------------------
static function det_rank(cterm)
local term := space(5)
if alltrim(cterm) == "001" .or. alltrim(cterm) == "002" && good for first and
      term:='20'+alltrim(cterm)                         && second semester for
else                                                    && this school year
      term:='19'+alltrim(cterm)                         && 1999 - 2000 ...
endif
return(term)
*------------------------------------------------------------------------------
static function navprint()
local ccode:=space(4),ccterm:=space(4),nrow:=8,npage:=1,;
      cpmsg:=spac(30),ldet:=.t.,nopt:=0,lscr:=savescreen(10,0,24,79),;
      cfilename:="off"+substr(dtoc(date()),1,2)+;
                       substr(dtoc(date()),4,2),;
      acmenu:={"     Text File","    Local Printer " ,"     Cancel Job"}
rkpfile->(sx_settagorder(4))
rkpfile->(dbgotop())
setcolor(memvar->colorarray[03])
draw_box2(10,26,20,56,memvar->colorarray[25],memvar->colorarray[26],,.t.)
draw_box1(12,30,16,52,memvar->colorarray[25],memvar->colorarray[26],,.F.)
@11,34 say "Selection Menu" color memvar->colorarray[41]
 while (nopt == 0)
     nopt := achoice(13,32,16,50,acmenu)
 do case
 case nopt == 1
    draw_box1(17,43,19,54,memvar->colorarray[25],memvar->colorarray[26],,.F.)
    @18,29 say "Output file :" color memvar->colorarray[41]
    @18,44 get cfilename pict "@!S8" color memvar->colorarray[03]
    read
    ldet:=.f.
    cpmsg:="Creating "+ALLTRIM(cfilename)+".PRN"
    set printer to &cfilename
 case nopt == 2
    cpmsg:="Printing To Local Printer"
  if !Isprinter()
    fask(17," ERROR Printer not ready....",{" Ok "},memvar->colorarray[05],.t.,nil)
    nopt:=0
  else
     fask(17,cpmsg,{" Ok "},memvar->colorarray[35],.f.,nil)
     inkey(1.5)
     ldet:=.t.
  endif
 case nopt == 3
      restscreen(10,0,24,79,lscr)
      return(1) && go back to calling routine
endcase
enddo
restscreen(10,0,24,79,lscr)
set console off
set printer on
ccode:=alltrim(rkpfile->n_code)
ccterm:=substr(rkpfile->n_term,3,3)
head1(ccterm)
head2()
  while .t.
    if !ccode == alltrim(rkpfile->n_code)
        ccode :=alltrim(rkpfile->n_code)
        ccterm:=substr(rkpfile->n_term,3,3)
        if nrow > 54
           make_line()
           print_page(nrow,npage)
           eject
           head1(ccterm)
           head2()
           nrow:=8
           npage++
        else
           ?
           nrow++
        endif
    endif
    fask(17," Printing student number "+rkpfile->n_idno+" - "+alltrim(rkpfile->n_lname)+", "+alltrim(rkpfile->n_fname),{" Ok "},memvar->colorarray[35],.f.,nil)
    ?space(2)+alltrim(rkpfile->n_idno)+space(2)+rkpfile->n_lname+", "+;
     alltrim(rkpfile->n_fname)+space(15-len(alltrim(rkpfile->n_fname)))+;
     rkpfile->n_mname+space(2)+rkpfile->n_desc+space(1)+dtoc(rkpfile->n_date)
     rkpfile->(dbskip())
     nrow++
     if nrow > 54
       make_line()
       print_page(nrow,npage)
       nrow:=8
       npage++
       eject
       ccode:=alltrim(rkpfile->n_code)
       ccterm:=substr(rkpfile->n_term,3,3)
       head1(ccterm)
       head2()
     endif
    if rkpfile->(eof())
        exit
     endif
enddo
if (nrow > 8 )
   make_line()
   print_page(nrow,npage)
   eject
endif
set console on
set printer off
if !ldet
   fask(17,cpmsg,{" Ok "},memvar->colorarray[35],.f.,nil)
   inkey(1.5)
   memvar->cspooltxt:=cfilename
   __keyboard(alltrim(memvar->cspooltxt)+".PRN"+chr(K_ENTER))
   viewtextfile()
endif
restscreen(10,0,24,79,lscr)
return(nil)
*------------------------------------------------------------------------------
static function print_page(nrow,npage)
local nor:=0
if nrow < 55
  for nor:=nrow to 54
      ?
  next
endif
?"  Page #: "+strzero(npage,3)
return(nil)
*------------------------------------------------------------------------------
static function det_prio(crank)
local crk:=space(2),wsrank:=alltrim(crank)
 do case
    case wsrank == "MM"
           crk:="A1"
    case wsrank == "CM"
           crk:="A2"
    case wsrank == "2M"
           crk:="A3"
    case wsrank == "3M"
           crk:="A4"
    case wsrank == "MJ"
           crk:="A5"
    case wsrank == "MI"
           crk:="A6"
    case wsrank == "CE"
           crk:="B1"
    case wsrank == "2E"
           crk:="B2"
    case wsrank == "3E"
           crk:="B3"
    case wsrank == "4E"
           crk:="B4"
    otherwise
           crk:="C1"
  endcase
return(crk)
*------------------------------------------------------------------------------
static function head1(ccterm)
local h1:="UNIVERSITY OF CEBU",h5:="Date Printed:"+dtoc(date()),;
      h2:="Maritime Education Training Center",;
      h3:="Alumnos, Mambaling Cebu City",h4:=space(15)
if term->(dbseek(ccterm))
   h4:=alltrim(term->name)
else
   h4:="Walay Semester!!!"
endif
?
?space(int((80-len(h1))/2))+chr(27)+'G'+chr(27)+"-1"+h1+chr(27)+"-0"+chr(27)+'H'
?space(int((80-len(h2))/2))+h2
?space(int((80-len(h3))/2))+h3
?space(int((80-len(h4))/2))+chr(27)+'G'+chr(27)+"-1"+h4+chr(27)+"-0"+chr(27)+'H'
?space(int((80-len(h5))/2))+h5
?
return(nil)
*------------------------------------------------------------------------------
static function head2()
?"                       ALUMNI (GRADUATES/OFFICERS) LIST                  "
?"                                                                         "
?"  ID NO.            STUDENT NAME                RANK           DATE TAKEN"
make_line()
return(nil)
*------------------------------------------------------------------------------
static function make_line()
// ?"  ========  ===============  ============== =  ==============  =========="
?"  -----------------------------------------------------------------------"
return(nil)
*------------------------------------------------------------------------------
static function make_file()
local navdbf:={}
 fask(10,"Initializing file(s)...",,,.f.,nil)
  aadd(navdbf,{"n_term","c",5,0})
  aadd(navdbf,{"n_code","c",4,0})
  aadd(navdbf,{"n_idno","c",8,0})
  aadd(navdbf,{"n_lname","c",15,0})
  aadd(navdbf,{"n_fname","c",15,0})
  aadd(navdbf,{"n_mname","c",1,0})
  aadd(navdbf,{"n_citaddr","c",30,0})
  aadd(navdbf,{"n_proaddr","c",30,0})
  aadd(navdbf,{"n_desc","c",15,0})
  aadd(navdbf,{"n_date","d",8,0})
  aadd(navdbf,{"n_prio","c",2,0})
  if !createdummy(memvar->rankrep,navdbf,{||cdxrank()}) == nil
       dbclosearea()
       return(nil)
  endif
return(nil)
*------------------------------------------------------------------------------
static function cdxrank()
field n_term,n_idno,n_code,n_prio,n_lname
private crkpfile := alias()
 index on n_term          tag (crkpfile+"1") of (memvar->crkpfile)
 index on n_idno          tag (crkpfile+"2") of (memvar->crkpfile)
 index on n_code          tag (crkpfile+"3") of (memvar->crkpfile)
 index on n_prio+n_lname  tag (crkpfile+"4") of (memvar->crkpfile)
return(nil)
*------------------------------------------------------------------------------
static function check_rank(crank,cprocsts)
if !empty(crank)
   if alltrim(crank) == "A"
      return(.t.)
   else
    if !c999rank->(dbseek(crank))
         viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
         return(.f.)
    endif
   endif
else
   viewrank({||__keyboard(chr(K_CTRL_LEFT)+c999rank->r_code+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
   return(.f.)
endif
return(.t.)
