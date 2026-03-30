#include "Inkey.ch"
#include "Box.ch"
function main()
local lval1:=.t.,nt1:=int(20/2),nr1:=40,nl1:=40,nb1:=int(20/2),;
      nt2:=19,nr2:=38,nl2:=38,nb2:=19,lflag1:=.t.,ascr,;
      lflag2:=.t.,h1:="* * * COMPUTER CENTER * * *",h2:="The Security System",;
      cmsg:="Security Password",nrow:=10,ncol:=8,lval2:=.t.,;
      cinf:="<   > key To enter password...",;
      h3:="Sanciangko St.,Cebu City"
set scoreboard off
cls
setcolor("b/b")
setcancel(.f.)
set century on
@0,0 clear to 24,79
draw_box(1,1,24,79,"n/b","b+/b",,.f.)
draw_box(6,3,22,77,"b+/b","n/b",,.f.)
@2,int((80-len(h1))/2) say h1 color "bg+/b"
@3,int((80-len(h3))/2) say h3 color "gr+/b"
@4,int((80-len(h2))/2) say h2 color "br+/b"
@23,4 say "Copyright (c) 1999 - 2099" color "bg+/b"
@23,68 say "By:Derick" color "bg+/b"
@5,25 say cinf color "bg+/b"
@5,26 say "Esc" color "g+*/b"
@3,4 say "Time:" color "gr+/b"
@3,10 say clock("on","12 hours","Seconds","r+/b")
@3,62 say "Date: " color "gr+/b"
@3,68 say dtoc(date()) color "r+/b"
back_wall()
setcursor(0)
while .t.
    if lflag1
       nt1++
       nt2--
       nb1++
       nb2--
    else
       nt1--
       nt2++
       nb1--
       nb2++
    endif
       if nt1 < 8
         lflag1:=.t.
       else
         if nt1 > 20
            lflag1:=.f.
         endif
       endif
     if lflag2
        nl1--
        nl2++
        nr1--
        nr2++
     else
        nl1++
        nl2--
        nr1++
        nr2--
     endif
        if nr1 < 6
           lflag2:=.f.
        else
           if nl1 > 75
              lflag2:=.t.
           endif
        endif
        if nr2 < 6
           nr2++
           nl2++
        else
           if nl2 > 75
              nl2--
              nr2--
           endif
        endif

     if lval1
        nrow++
     else
        nrow--
     endif
     if nrow > 20
        lval1:=.f.
     else
        if nrow < 8
           lval1:=.t.
        endif
     endif

     if lval2
        ncol++
     else
        ncol--
     endif
     if ncol+len(cmsg) > 74
        lval2:=.f.
     else
        if ncol < 6
           lval2:=.t.
        endif
     endif
    ascr:=savescreen(4,0,24,79)
    @nt1,nr1,nb1,nl1 box "" color "r+/b"
    @nt2,nr2,nb2,nl2 box "" color "r+/b"
    @nrow,ncol say cmsg color "gr+/b"
    check_key()
    restscreen(4,0,24,79,ascr)
enddo
setcursor(1)
setcancel(.t.)
return(nil)
*--------------------------------------------------------------
function check_key()
local npass:=space(8),lscr:=savescreen(4,0,24,79),x:=2,scr
inkey(0.1)
if lastkey() == K_ESC
   npass:=your_pass()
   scr:=savescreen(8,0,24,79)
   if alltrim(npass) == "BONZ"
      set color to
      cls
      quit
   else
      for x:=12 to 50
         restscreen(8,0,24,79,scr)
         @13,x say "Invalid password..." color "gr+/bg"
         inkey(0.1)
      next
      restscreen(8,0,24,79,scr)
      tone(300,18)
   endif
endif
restscreen(4,0,24,79,lscr)
return(nil)
*--------------------------------------------------------------
function your_pass()
local xpass:=space(8),xtime:=1,xmsg:="CONFIRM PASSWORD",xcol:=34,;
      xch:=space(1),i:=0,pmsg:="Type your password..."
setcolor("br+/bg")
@10,10 clear to 16,70
draw_box(10,10,16,70,"n/bg","bg+/bg",,.f.)
draw_box(13,12,15,68,"bg+/bg","n/bg",,.f.)
make_shadow(11,17,12,71,"лл")
@12,((80-len(xmsg))/2) say xmsg color "r+/bg"
@14,14 say "Your Password:      XXXXXXXX"
set cursor off
@5,25 say space(34) color "bg+/b"
@5,int((80-len(pmsg))/2) say pmsg color "bg+/b"
while .t.
 @14,xcol get xch pict "@!" color "bg/bg"
 read
  if !xch==space(1) .and. !lastkey()== K_ENTER
    @14,xcol say "X" color "r+/bg"
    xcol++
    xpass+=upper(xch)
    i++
  endif
  if i > 8 .or. lastkey() == K_ENTER
     exit
  endif
enddo
return(xpass)
*--------------------------------------------------------------
function draw_box(ntop,nleft,nbottom,nright,color1,color2,msg)
    local cbcol:="r+",x:=0,cch:=space(1)
    @ ntop,nleft,nbottom,nright box B_SINGLE+" "  color color1 &&"BG+/BG"
    @ ntop,nleft+1 say replicate(chr(196),nright-1-nleft) color color2 &&"N+/BG"
    @ ntop,nleft+1 say replicate(chr(196),nright-1-nleft) color color2 &&"N+/BG"
    @ ntop,nleft say chr(218) color color2  &&"N+/BG"
    for i:=ntop+1 to nbottom-1
        @ i,nleft say chr(179) color color2 &&"N+/BG"
    end
    @ ntop,nright say chr(191) color color1 &&"BG+/BG"
    @ nbottom,nleft say chr(192) color color2 &&"N+/BG"
    for x:=1 to len(color2)
       cch:=substr(color2,x,1)
       if cch == '/'
          cbcol+=substr(color1,x+1,3)
          x:=len(color2)
       endif
    next
    if !empty(msg)
       @ntop+1,nleft+3 say alltrim(msg) color cbcol
    endif
return(nil)
*--------------------------------------------------------------
static function back_wall()
local w1:="лллн ллн ллн ллн лллн ллнллн ллллн ллллн ллллн",;
      w2:="н  н н н  лн лн   н н  н  н  н н н  н  н  н  н",;
      w3:="н    н н  нллнн   ллн  н  н    н    лн    лллн",;
      w4:="н  н н н  н н н   н    н  н    н    н  н  н н ",;
      w5:="лллн ллн ллн ллн ллн   лллн   ллн  ллллн лл лн",;
      w6:="лллн ллн ллн ллн лллн ллн  ллллн лл л ллн ллн лл ллн",;
      w7:="н  н н н  лн лн   н н  н    н  н  н н  н  н н  лн н ",;
      w8:="н    н н  нллнн   ллн  н    лн     л   н  н н  нлнн ",;
      w9:="н  н н н  н н н   н    н н  н  н  н н  н  н н  н лн ",;
     w10:="лллн ллн ллн ллн ллн  лллн ллллн лл л ллн ллн лл  лн"
@9,int((80-len(w1))/2) say w1 color "r+/b"
@10,int((80-len(w2))/2) say w2 color "gr+/b"
@11,int((80-len(w3))/2) say w3 color "g+/b"
@12,int((80-len(w4))/2) say w4 color "br+/b"
@13,int((80-len(w5))/2) say w5 color "r+/b"
@16,int((80-len(w6))/2) say w6 color "br+/b"
@17,int((80-len(w7))/2) say w7 color "g+/b"
@18,int((80-len(w8))/2) say w8 color "gr+/b"
@19,int((80-len(w9))/2) say w9 color "r+/b"
@20,int((80-len(w10))/2) say w10 color "br+/b"
return(nil)
*--------------------------------------------------------------
static function make_shadow(r1,r2,c1,c2,cshad)
local i:=0
  for i:=r1 to r2
     @i,c2 say cshad color "n"
  next i
  for i:=c1 to c2
     @r2,i say cshad color "n"
  next i
return(nil)
