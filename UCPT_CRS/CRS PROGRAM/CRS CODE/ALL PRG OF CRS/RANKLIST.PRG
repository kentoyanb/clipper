*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Program       : RANKLIST.PRG
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
function ranklist()
local getlist := {}, alastscr := savescr(01,00,24,79), nlastcursor := setcursor(),;
      clastcolor := setcolor(memvar->colorarray[11]), lconfirm := set(_SET_CONFIRM),;
      aprvsetup,lexist:=.t.,cprocsts,oenroll,bindex,bitems,aentryscr,nterm:=0,;
      cyytenrp,aYesNo:={"  Yes  ","  No  "},cnmsg:=space(36),nrec:=0,;
      cdesc:=space(15)
private adetails:={},cname,clname,cfname,cmname, cidno := space(08),;
        lconf := .f.,caddr,ddboard:=ctod('  \  \  '),;
        rankfile:="rnklst"+strzero(memvar->naccess,2),arlfile,navlist
if(aprvsetup := openwcheck({{,,"c999sm1p",,_DBF_SHARED,,1},;
                            {,,"c999offr",,_DBF_SHARED,,4},;
                            {,,"c999rank",,_DBF_SHARED,,1}})) == nil
              return(nil)
endif
make_lst()
  memvar->navlist:=memvar->rankfile
openwcheck({{,,(memvar->navlist+".TXT"),"navlist",_DBF_EXCLUSIVE,,1}})
do while .t.
        clearbuffer()
        navlist->(__dbzap());navlist->(dbreindex())
//        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[11],"  Officers Individual printing  ")
        boxshadow(01,00,24,79,"лплллмлл ",memvar->colorarray[54],"  Officers Individual printing  ")
        commandline("Г        F4 - View Term File           Г            ESC - Previous             Г")
        setkey(K_F4,{||vstudent({||__keyboard(chr(K_CTRL_LEFT)+c999sm1p->sm1idno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])})
        setcursor(1);set(_SET_CONFIRM,.t.)
        draw_box2(02,05,04,23,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        draw_box1(02,24,04,35,memvar->colorarray[28],memvar->colorarray[29],,.F.)
        aentryscr := savescr(01,00,24,79)
        @03,07 say "Student Number " color memvar->colorarray[55]
        @03,26 get memvar->cidno color memvar->colorarray[55];
                   valid check_idno(memvar->cidno)
        read
        if lastkey() == K_ESC
               exit
        endif
        setkey(K_F4,NIL)
        if !c999offr->(dbseek(alltrim(memvar->cidno)))
             memvar->clname := space(len(c999offr->r_lname))
             memvar->cfname := space(len(c999offr->r_fname))
             memvar->cmname := space(len(c999offr->r_mname))
            fask(17,"  Student number "+memvar->cidno+" not found in master file...",{" ok "},memvar->colorarray[05],.f.,nil)
           loop
        else
           memvar->clname := alltrim(c999offr->r_lname)
           memvar->cfname := alltrim(c999offr->r_fname)
           memvar->cmname := alltrim(c999offr->r_mname)
        endif
          draw_box2(05,05,07,23,memvar->colorarray[28],memvar->colorarray[29],,.F.)
          draw_box1(05,24,07,75,memvar->colorarray[28],memvar->colorarray[29],,.F.)
          @06,07 say "Student Name" color memvar->colorarray[55]
          @06,26 say memvar->clname+", "+memvar->cfname+"  "+memvar->cmname;
                     color memvar->colorarray[55]
          draw_box2(08,05,23,75,memvar->colorarray[28],memvar->colorarray[29],,.F.)
          draw_box1(12,07,22,73,memvar->colorarray[28],memvar->colorarray[29],,.F.)
          @10,10 say "Date" color memvar->colorarray[55]
          @10,22 say "Rank" color memvar->colorarray[55]
          @10,39 say "Place of Examination" color memvar->colorarray[55]
          c999offr->(sx_setscope(_TOP_SCOPE ,memvar->cidno))
          c999offr->(sx_setscope(_BOTTOM_SCOPE ,memvar->cidno))
          c999offr->(dbgotop())
          adetails:={}
        while .t.
            if c999offr->(eof())
               exit
            endif
            if c999rank->(dbseek(c999offr->r_code))
               memvar->cname:=c999rank->r_desc
            else
               memvar->cname:=space(len(c999rank->r_desc))
            fask(17,"  Error "+memvar->cidno+" not found in officers master file...",{" ok "},memvar->colorarray[05],.t.,nil)
              exit
            endif
             navlist->(dbappend())
             navlist->d_date   := c999offr->r_datb
             navlist->d_rank   := memvar->cname
             navlist->d_eplace := c999offr->r_eplace
             navlist->(dbcommit())
            aadd(adetails,dtoc(c999offr->r_datb)+space(2)+;
                          memvar->cname+space(2)+c999offr->r_eplace)
            c999offr->(dbskip())
        enddo
        c999offr->(clearscope())
        if !len(adetails) > 0
           fask(17,"No record found for this Student Number "+memvar->cidno+"...",{" ok "},memvar->colorarray[05],.t.,nil)
           loop
        endif
        bb_rowse(adetails)
        //navlist->(__dbzap());navlist->(dbreindex())
        dbunlockall()
enddo
navlist->(dbclosearea())
ferase((memvar->navlist+".TXT"))
ferase((memvar->navlist+".CDX"))
closewcheck(aprvsetup)
restscr(alastscr)
return(nil)
*------------------------------------------------------------------------------
static function bb_rowse(adetails)
commandline("Г       Фй to Print               Г            ESC - Previous             Г")
 while .t.
   achoice(13,10,21,70,adetails)
   do case
      case lastkey() == K_ESC
           exit
      case lastkey() == K_ENTER
            rankprint()
   endcase
 enddo
return(nil)
*------------------------------------------------------------------------------
static function check_idno(cidno,cprocsts)
if ! c999sm1p->(dbseek(cidno))
        vstudent({||__keyboard(chr(K_CTRL_LEFT)+c999sm1p->sm1idno+chr(K_ENTER))},cprocsts,memvar->colorarray[10])
        return(.f.)
endif
return(.t.)
*------------------------------------------------------------------------------
static function rankprint()
local ccode:=space(4),ccterm:=space(4),nrow:=8,npage:=1,;
      cpmsg:=spac(30),ldet:=.t.,nopt:=0,lscr:=savescreen(10,0,24,79),;
      cfilename:="OLT"+substr(dtoc(date()),1,2)+;
                       substr(dtoc(date()),4,2),;
      acmenu:={"     Text File","    Local Printer " ,"     Cancel Job"}
navlist->(sx_settagorder(1))
navlist->(dbgotop())
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
    cpmsg:="Pritning to Local Printer"
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
head1()
  while .t.
        if nrow > 54
           make_line()
           print_page(nrow,npage)
           eject
           head1()
           nrow:=8
           npage++
        else
           nrow++
        endif
    fask(17," Printing student number "+navlist->d_rank,{" Ok "},memvar->colorarray[35],.f.,nil)
    ?space(2)+memvar->cname+space(2)+dtoc(navlist->d_date)+space(2)+;
     alltrim(navlist->d_eplace)
     navlist->(dbskip())
     nrow++
     if nrow > 54
       make_line()
       print_page(nrow,npage)
       nrow:=8
       npage++
       eject
       head1()
     endif
    if navlist->(eof())
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
static function head1()
? space(2)+memvar->cidno+space(2)+memvar->clname+", "+memvar->cfname+space(1)+;
       memvar->cmname
?
?"  Rank             Date        Place of Examination"
//?"    RANK            DATE           PLACE OF EXAMINATION"
make_line()
return(nil)
*------------------------------------------------------------------------------
static function make_line()
?"  ---------------  ----------  -----------------------------"
return(nil)
*------------------------------------------------------------------------------
static function make_lst()
local navdbf:={}
fask(10,"Initializing file(s)....",,,.f.,nil)
  aadd(navdbf,{"d_date","d",8,0})
  aadd(navdbf,{"d_rank","c",15,0})
  aadd(navdbf,{"d_eplace","c",30,0})
  if !createdummy(memvar->rankfile,navdbf,{||cdxrlst()})==nil
      dbclosearea()
      return(nil)
  endif
return(nil)
*------------------------------------------------------------------------------
static function cdxrlst()
field d_date
private cnavlist := alias()
 index on d_date            tag (memvar->cnavlist+"1") of (memvar->cnavlist)
return(nil)
