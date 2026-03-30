*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Printing of New Student Number
* date created.  11-Nov-99 (Bionz)
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
#include "inkey.ch"
public idno:=space(8)       //start-idno
public lc:=5,idv:=0,aidno:={},nt1:=1,aelem:=""
Set Confirm on
Set century on
set epoch to 1960
Set ScoreBoard off
Setkey(K_F3,{|| endpgm()})
cls
fkeys("^F3=Quit")
@ 0,2 say "UNIVERSITY OF CEBU - METC"
@ 1,2 say "Printing of New Students ID-Number."
@ 3,2 say "Enter last ID-Number. . . . . . . .:"
@ 4,2 say "How many ID # to generate . . . . .:"

while .t.
  @ 3,38 get idno pict "@!" valid {|| !empty(idno) .and. rightid()}
  @ 4,38 get idv pict "@Z 9999" valid {|| idv>0}
  read
  aelem:=""
  fkeys("^F3=Quit ^F10=Start Print")
  inkey(0)
  do case
   case lastkey()==K_F10
      printit()
      if len(aidno) > 0
         furtherprint()
         aidno:={}
      endif
   case lastkey()==K_F3
   otherwise
      tone(800,1)
      tone(800.1)
  endcase
enddo
*------------------------------------------------------------------------------
static function printit()
pcount:=1
i:=val(substr(idno,3,5))
while .t.
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
  if nt1 > 8
     aadd(aidno,aelem)
     nt1 := 2
     aelem:=""
     aelem+=newid+" "
     alert(10,"Generated #     "+strzero(i,4),nil)
     alert(14,"Generated ID #  "+newid,nil)
  else
     aelem+=newid+" "
     nt1++
     alert(10,"Generated #     "+strzero(i,4),nil)
     alert(14,"Generated ID #  "+newid,nil)
  endif
     pcount++
  if pcount>idv
     if !alltrim(aelem)==""
        aadd(aidno,aelem)
     endif
     exit
  endif
enddo
*------------------------------------------------------------------------------
static function furtherprint()
local nscr:=savescreen(0,0,24,79)
while ! lastkey() == K_ESC
  achoice(10,1,20,80,aidno)
  if lastkey() == K_ENTER
     go_print(aidno)
  endif
  restscreen(0,0,24,79,nscr)
enddo
return(nil)
*------------------------------------------------------------------------------
static function go_print(s)
local fname:=space(8),nCh:=0
@10,18 clear to 18,50
@10,18 to 18,50
while!(nCh==3)
   @12,20 say "*** THE MAIN SELECTION ***"
   @13,28 prompt "Text File"
   @14,26 prompt "Local Printer"
   @15,28 prompt "Cancel Job"
   menu to nCh
   do case
      case nCh == 1
           @16,20 say "Your file Name:"
           @16,35 get fname pict "@KS8" valid !empty(fname)
           read
           set printer to &fname
           go_fprint(aidno)
      case nCh == 2
           if Isprinter()
            set device to printer
            go_fprint(aidno)
           else
             @24,20 say "Printer not ready!!!"
             inkey(0)
             @24,20 say "                    "
           endif
   endcase
enddo
return(nil)
*------------------------------------------------------------------------------
static function go_fprint(aidno)
local pnum:=1,nlin:=4,i:=0
set console off
set printer on
idhead(pnum)
for i:=1 to len(aidno)
   if nlin > 60
      eject
      nlin:=4
      pnum++
      idhead(pnum)
   else
     ?space(4)+aidno[i]
      nlin++
   endif
next i
set printer off
set console on
return(nil)
*------------------------------------------------------------------------------
static function idhead(pn)
?space(28)+"UNIVERSITY OF CEBU - METC"
?space(23)+"THE NEW GENERATED STUDENT ID NUMBER"
?space(2)+"Page # "+transform(pn,"9999")+space(40)+"Date: "+dtoc(date())
?replicate("=",80)
return
*------------------------------------------------------------------------------
FUNCTION endpgm()
for r:=0 to 39
 for s:=0 to 24
   @ s,r clear to s,r
   @ s,79-r clear to s,79-r
 next s
next r
close all
quit
*------------------------------------------------------------------------------
Function fkeys(s)
local i
local c
@ 23,2 clear to 23,80
@ 23,2 say ""
for i := 1 to len(s)
  c := substr(s,i,1)
  do case
    case (c == "^")
      setcolor("W+")
    case (c == "=")
      setcolor("W")
      ?? c
    otherwise
      ?? c
  endcase
next i
*------------------------------------------------------------------------------
Function rightid(fs)
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
