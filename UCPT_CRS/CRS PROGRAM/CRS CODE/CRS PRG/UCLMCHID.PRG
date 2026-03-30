*-----------------------------------------------------------------------------
#include "Inkey.ch"
#include "sixcdx.ch"
#include "grumpr.ch"
#include "grump.ch"
#include "grumpm.ch"

set century on
set epoch to 1960
main()
function main()
local nCh:=0,fidnum:=space(8),sidnum:=space(8),scr,;
      cterm:=space(3),fdir:=space(20)
draw_scr()
scr:=savescreen(0,0,24,79)
while .t.
       restscreen(0,0,24,79,scr)
       fidnum:=get_id(26)
       sidnum:=fidnum
       while alltrim(sidnum)==alltrim(fidnum)
         sidnum:=get_id(63)
       enddo
       @10,20 say "Enter the term:" color "b+/bg"
       @10,35 get cterm pict "@!KS3" valid !empty(cterm) color "b+/bg"
       read
           @10,35 say "MAIN SELECTION"
       while nCh!=3
            @12,37 prompt "C R S"
            @13,37 prompt "A C C T G"
            @14,37 prompt "E X I T"
            menu to nCh
           do case
              case nCh == 1
                   fdir:=get_dir()
                   proc_crs(fdir,fidnum,sidnum,cterm)
              case nCh == 2
                   fdir:=get_dir()
                   proc_acctg(fdir,fidnum,sidnum,cterm)
           endcase
       enddo
enddo
return(nil)
*-----------------------------------------------------------------------------
static function get_dir()
local wsdir:=space(20)
@22,20 say "Your Directory:" color "b+/bg"
@22,35 get wsdir pict "@!K" valid !empty(wsdir) color "b+/bg"
read
return(alltrim(wsdir))
*-----------------------------------------------------------------------------
static function proc_crs(cdir,fid,sid,cterm)
local aprvsetup,cyytenrp:="c"+"+cterm+"enrp",afiles,lid:=sid
if !file("c999sm1p.cdx")
   if fask(10,"     Rebuild C999SM1P.DBF ?     ",{" Yes "," No  "},"r+/bg")  == 1
        afiles := {{,,"C999SM1P",,_DBF_EXCLUSIVE,,}}
        openwcheck(afiles)
        index on SM1IDNO                        tag C999SM11 of C999SM1P option indexbar()
     *   index on SM1LSTNAM+SM1FSTNAM+SM1MIDNAM  tag C999SM12 of C999SM1P option indexbar()
     *   index on SM1COLCOD+STR(SM1YRLEVL,2)     tag C999SM13 of C999SM1P option indexbar()
     *   index on SM1SCHTRM                      tag C999SM14 of C999SM1P option indexbar()
        dbclosearea()
    endif
endif
if !file("c999sm2p.cdx")
   if fask(10,"     Rebuild C999SM2P.DBF ?     ",{" Yes "," No  "},"r+/bg") == 1
        afiles := {{,,"C999SM2P",,_DBF_EXCLUSIVE,,}}
        openwcheck(afiles)
        index on SM2IDNO        tag C999SM21 of C999SM2P option indexbar()
        dbclosearea()
    endif
endif
if !file("cyytenrp.cdx")
  if fask(10,"     Rebuild cyytENRP.DBF ?     ",{" Yes "," No  "},"r+/bg") == 1
        boxshadow(10,20,14,60,"лплллмлл ",memvar->colorarray[11],"   cyytENRP.DBF   ")
        setcursor(nlastcursor);set(_SET_CONFIRM,lconfirm)
        if lastkey() == K_ENTER
                cyytenrp := "C"+cterm+"ENRP"
                ctagname := "C"+cterm+"ENR"
                afiles   := {{,,cyytenrp,,_DBF_EXCLUSIVE,,}}
                openwcheck(afiles)
                cdxenrp(cyytenrp,ctagname)
                dbclosearea()
        endif
    endif
endif
if(apvrsetup:=openwcheck({{,,"c999sm1p",,_DBF_EXCLUSIVE,,1},;
                       {,,"c999sm2p",,_DBF_EXCLUSIVE,,1},;
                       {,,cyytenrp,"cyytenrp",,_DBF_EXCLUSIVE,,1}})) == nil
    return(nil)
endif
fid:=gen_id(fid)
sid:=gen_id(sid)
while !fid == lid
 if c999sm1p->(dbseek(fid))
    c999sm1p->sm1pidno := sid
    c999sm1p->(dbcommit())
 endif
 if c999sm2p->(dbseek(fid))
    c999sm2p->sm2pidno := sid
    c999sm2p->(dbcommit())
 endif
 adj_enrp(fid,sid)
fid:=gen_id(fid)
sid:=gen_id(sid)
enddo
closewcheck(apvrsetup)
return(nil)
*-----------------------------------------------------------------------------
static function adj_enrp(fid,sid)
   cyytenrp->(sx_setscope(_TOP_SCOPE ,fid))
   cyytenrp->(sx_setscope(_BOTTOM_SCOPE ,fid))
   cyytenrp->(dbgotop())
   while !eof()
    cyytenrp->enridno := sid
    cyytenrp->(dbcommit())
    cyytenrp(dbskip())
   enddo
 cyytenrp->(clearscope())
return(nil)
*-----------------------------------------------------------------------------
static function proc_acctg(cdir,fid,sid,cterm)
local aprvsetup,ayytpayp:="a"+"+cterm+"payp",lid:="1"+sid,fsid:="1"+fid,;
      scid:="1"+sid

if(apvrsetup:=openwcheck({{,,"a999accp",,_DBF_EXCLUSIVE,,1},;
                       {,,ayytpayp,"ayytpayp",,_DBF_EXCLUSIVE,,1}})) == nil
    return(nil)
endif
if !file("a999accp.cdx")
   if fask(10,"        Rebuild  A999ACCP ?        ",{" Yes "," No  "},memvar->colorarray[05]) == 1
        afiles := {{,,"a999accp",,_DBF_EXCLUSIVE,,}}
        if file("a999accp.CDX")
                ferase("a999accp.CDX")
        endif
        openwcheck(afiles)
        index on ACCIDNO                                tag A999ACC1 of A999ACCP option indexbar()
      *  index on ACCLNAME+ACCFNAME+ACCMNAME             tag A999ACC2 of A999ACCP option indexbar()
      *  index on ACCCOLCOD+ACCIDNO                      tag A999ACC3 of A999ACCP option indexbar()
      *  index on ACCCOLCOD+ACCLNAME+ACCFNAME+ACCMNAME   tag A999ACC4 of A999ACCP option indexbar()
        dbclosearea()
    endif
endif
if !file("ayytpayp.cdx")
     if ! file(alltrim("a"+cterm+"payp.dbf"))
                        fask(13,"   File A"+cterm+"PAYP.DBF not exists...   ",{" Ok "},memvar->colorarray[05],.t.,nil)
                        loop
                endif
                ayytpayp := "A"+cterm+"PAYP"
                atagname := "A"+cterm+"PAY"
                afiles   := {{,,ayytpayp,,_DBF_EXCLUSIVE,,}}
                if file(ayytpayp+".CDX")
                        ferase(ayytpayp+".CDX")
                endif
                openwcheck(afiles)
                cdxpayp(ayytpayp,atagname)
                dbclosearea()
endif
fsid:=gen_id(fsid)
scid:=gen_id(scid)
while !fsid==lid
   if a999accp->(dbseek(fsid))
      a999accp->accidno := scid
      a999accp->(dbcommit())
 *     adj_payp(fsid,scid)
   endif
 adj_payp(fsid,scid)
 fsid:=gen_id(fsid)
 scid:=gen_id(scid)
enddo
closewcheck(apvrsetup)
return(nil)
*-----------------------------------------------------------------------------
static function adj_payp(fsid,scid)
   ayytpayp->(sx_setscope(_TOP_SCOPE ,fsid))
   ayytpayp->(sx_setscope(_BOTTOM_SCOPE ,fsid))
   ayytpayp->(dbgotop())
   while !eof()
    ayytpayp->payidno := scid
    ayytpayp->(dbcommit())
    ayytpayp(dbskip())
   enddo
  ayytpayp->(clearscope())
return(nil)
*-----------------------------------------------------------------------------
static function get_id(ncol)
local wsid:=space(8),n:=1
   while n==1
       @07,ncol get wsid pict "@!KS8" valid (!empty(wsid)) color "r+/bg"
       read
       if(!rightid(wsid,wsid))
        @22,20 say "Invalid id number..."
        inkey(0.5)
       else
          n:=2
       endif
   enddo
check_key()
return(wsid)
*-----------------------------------------------------------------------------
static Function rightid(fs,idno)
  fs:=left(idno,7)
  d1:=substr(fs,1,1)
  d2:=val(substr(fs,2,1))
  d3:=substr(fs,3,1)
  d4:=val(substr(fs,4,1))
  d5:=substr(fs,5,1)
  d6:=val(substr(fs,6,1))
  d7:=substr(fs,7,1)
  s1:=val(d1)*2
     s1:=transform(s1,"99")
     s1:=val(substr(s1,1,1))+val(substr(s1,2,1))
  s2:=val(d3)*2
      s2:=transform(s2,"99")
      s2:=val(substr(s2,1,1))+val(substr(s2,2,1))
  s3:=val(d5)*2
      s3:=transform(s3,"99")
      s3:=val(substr(s3,1,1))+val(substr(s3,2,1))
  s4:=val(d7)*2
      s4:=transform(s4,"99")
      s4:=val(substr(s4,1,1))+val(substr(s4,2,1))
  chd:=transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
  chd:=int(10-val(chd))
  if chd>9
    chd:=0
  end
  chd1:=VAL(right(idno,1))
if chd1==chd
  return .t.
else
  return .f.
endif
*-----------------------------------------------------------------------------
static function gen_id(idno)
local i:=val(substr(idno,3,5))
  i++
  fs:=left(idno,2)+transform(i,"99999")
  d1:=substr(fs,1,1)
  d2:=val(substr(fs,2,1))
  d3:=substr(fs,3,1)
  d4:=val(substr(fs,4,1))
  d5:=substr(fs,5,1)
  d6:=val(substr(fs,6,1))
  d7:=substr(fs,7,1)
  s1:=val(d1)*2
     s1:=transform(s1,"99")
     s1:=val(substr(s1,1,1))+val(substr(s1,2,1))
  s2:=val(d3)*2
      s2:=transform(s2,"99")
      s2:=val(substr(s2,1,1))+val(substr(s2,2,1))
  s3:=val(d5)*2
      s3:=transform(s3,"99")
      s3:=val(substr(s3,1,1))+val(substr(s3,2,1))
  s4:=val(d7)*2
      s4:=transform(s4,"99")
      s4:=val(substr(s4,1,1))+val(substr(s4,2,1))
  chd:= transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
  chd:=int(10-val(chd))
  if chd==10
      newid:=fs+"0"
  else
      newid:=fs+transform(chd,"9")
  end
return(newid)
*-----------------------------------------------------------------------------
static function check_key()
  if lastkey() == K_ESC
     endpgm()
  endif
return(nil)
*-----------------------------------------------------------------------------
static function draw_scr()
cls
setcolor("b+/bg")
@01,06 clear to 23,75
@01,06 to 23,75
@02,30 say "UNIVERSITY OF CEBU" color "gr+/bg"
@03,22 say "Maritime Education & Training center" color "gr+/bg"
@05,25 say "ADJUSTING ID # UTILITY PROGRAM" color "r+/bg"
@05,08 say "Time:" color "b+/bg"
@05,13 say time() color "gr+/bg"
*@05,13 say clock("on","12 Hour","Second")
@05,60 say "Date:" color "b+/bg"
@05,65 say dtoc(date()) color "gr+/bg"
@07,09 say "First Id Number :" color "b+/bg"
@07,45 say "Second Id Number :" color "b+/bg"
@22,08 say "(C)Copyright 1999 - 2999" color "b+/bg"
@22,57 say "By:BionZ & RvTek" color "b+/bg"
@04,06 say "Ц" color "b+/bg"
@04,75 say "Е" color "b+/bg"
@04,07 say replicate("Э",68) color "b+/bg"
@06,06 say "Ц" color "b+/bg"
@06,75 say "Е" color "b+/bg"
@06,07 say replicate("Э",68) color "b+/bg"
return(nil)
*-----------------------------------------------------------------------------
static FUNCTION endpgm()
set color to
for r:=0 to 39
 for s:=0 to 24
   @ s,r clear to s,r
   @ s,79-r clear to s,79-r
 next s
next r
close all
quit
return(nil)
*-----------------------------------------------------------------------------
function cdxpayp(ayytpayp,atagname)
 *index on PAYREFNO+DTOS(PAYDTE)  tag (atagname+"1") of (ayytpayp) option indexbar()
 *index on PAYIDNO+DTOS(PAYDTE)   tag (atagname+"2") of (ayytpayp) option indexbar()
 *index on PAYCOLCOD+PAYIDNO      tag (atagname+"3") of (ayytpayp) option indexbar()
 index on PAYIDNO         tag (atagname+"4") of (ayytpayp) option indexbar()
* index on PAYIDNO+PAYTAG         tag (atagname+"4") of (ayytpayp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
function cdxenrp(cyytenrp,ctagname)
 index on ENRIDNO                tag (ctagname+"1") of (cyytenrp) option indexbar()
 *index on ENRCOLCOD+ENRYRLEVL    tag (ctagname+"2") of (cyytenrp) option indexbar()
 *index on ENRYRLEVL              tag (ctagname+"3") of (cyytenrp) option indexbar()
return(nil)
*-----------------------------------------------------------------------------
