* Printing of New Student Number
* file overridden (rscheckd)
* date updated.  20-Apr-99 (RV)

#include "inkey.ch"
public idno:=space(8)       //start-idno
public lc:=5
public idv:=0
Set Confirm on
Set ScoreBoard off
Setkey(K_F3,{|| endpgm()})

cls
/*if gete("USER")<>"SUPERVISOR"
     tone(920,2)
     tone(810,2)
     tone(950,1)
     ALERT("UNAUTHORIZED ACCESS.....Security Reason")
     endpgm()
  end*/

fkeys("^F3=Quit")
@ 0,2 say "UNIVERSITY OF CEBU - METC"
@ 1,2 say "Printing of New Students ID-Number."
@ 3,2 say "Enter last ID-Number. . . . . . . .:"
@ 4,2 say "There are 55 New ID's per Page.     "
@ 5,2 say "Enter number of page(s) to generate:"

while .t.
  @ 3,38 get idno pict "@!" valid {|| !empty(idno) .and. rightid()}
  @ 5,38 get idv pict "@Z 9999" valid {|| idv>0}
  read
  fkeys("^F3=Quit ^F10=Start Print")
  inkey(0)
  do case
   case lastkey()==K_F10
      printit()
   case lastkey()==K_F3
      quit
   otherwise
      tone(800,1)
      tone(800.1)
  end
end

function printit()
set device to printer
idhead()
pcount:=1
i:=val(substr(idno,3,5))
while .t.
  i++
//fs:=left(idno,2)+transform(i,"09999")
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
  @ lc,2 say( newid     +"     ___________________   _____________________   __   ____")
  lc +=1
//  lc +=2
  if lc>59
     pcount++
     eject
     lc:=5
     if pcount<idv+1
       idhead()
     end
  end
  if pcount>idv
     exit
  end
end // while

function idhead()
@ 0,19 say "       UNIVERSITY OF CEBU - METC"
@ 1,19 say "  NEW STUDENTS REGISTRATION MASTER FILE"
@ 3,1 say ("ID NUMBER     LAST NAME             FIRST NAME              MI   YEAR")
return

FUNCTION endpgm()
for r:=0 to 39
 for s:=0 to 24
   @ s,r clear to s,r
   @ s,79-r clear to s,79-r
 end
end
close all
quit

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
  end
next

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
  chd:= transform(int((s1+s2+s3+s4+d2+d4+d6) % 10),"9")
  chd:=int(10-val(chd))
  if chd>9
    chd:=0
  end
  chd1:=VAL(right(idno,1))
if chd1==chd
  return .t.
else
  return .f.
end

