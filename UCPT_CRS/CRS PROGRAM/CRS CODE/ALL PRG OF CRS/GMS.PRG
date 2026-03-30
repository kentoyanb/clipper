*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Program       : RANKRPT.PRG
* Author        : Abundio C. Navarro July 1999
* Installation  : UC-METC
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
#include "Inkey.ch"
#include "Box.ch"
function main()
local lval:=.t.,ascr,h1:="THE GAISANO MAIN STORE",h2:="The Security System",;
      cmsg:="Security Password",nrow:=10,ncol:=8,;
      cinf:="<   > key To enter password...",;
      h3:="Colon St.,Cebu City",nscr,;
      fl1:=.t.,fl2:=.t.,nrow1:=7,ncol1:=4,nrow2:=21,ncol2:=76
local w1:="лллн  ллн  ллн лллн  ллн  лл ллн ллн",;
      w2:="н  н  н н   н  н     н н   лн н  н н",;
      w3:="н мм  ллн   н  лллн  ллн   нлнн  н н",;
      w4:="н  н  н н   н     н  н н   н лн  н н",;
      w5:="лллн лн лн ллн лллн лн лн лл  лн ллн",;
      w6:="ллн ллн  ллн  ллн лл ллн       лллн ллллн ллн ллллн ллллн",;
      w7:=" лн лн   н н   н   лн н        н    н н н н н  н  н  н  н",;
      w8:=" нллнн   ллн   н   нлнн  мммм  лллн   н   н н  лллн  лн  ",;
      w9:=" н н н   н н   н   н лн           н   н   н н  н н   н  н",;
     w10:="ллн ллн лн лн ллн лл  лн       лллн  ллн  ллн лл лн ллллн"
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
@23,66 say "By:Cris Jopia" color "bg+/b"
@5,25 say cinf color "bg+/b"
@5,26 say "Esc" color "g+*/b"
@3,4 say "Time:" color "gr+/b"
@3,10 say clock("on","12 hours","Seconds","r+/b")
@3,62 say "Date: " color "gr+/b"
@3,68 say dtoc(date()) color "r+/b"
nscr:=savescreen(6,0,22,79)
//back_wall()
setcursor(0)
while .t.
    ascr:=savescreen(4,0,24,79)
    do case
       case nrow1 == 7 && 21
            @nrow1,int((80-len(w5))/2) say w5 color "r+/b"
            @nrow2,int((80-len(w6))/2) say w6 color "r+/b"
       case nrow1 == 8 && 20
            @7,int((80-len(w4))/2) say w4 color "br+/b"
            @nrow1,int((80-len(w5))/2) say w5 color "r+/b"
            @nrow2,int((80-len(w6))/2) say w6 color "br+/b"
            @21,int((80-len(w7))/2) say w7 color "r+/b"
       case nrow1 == 9 && 19
            @7,int((80-len(w3))/2) say w3 color "g+/b"
            @8,int((80-len(w4))/2) say w4 color "br+/b"
            @nrow1,int((80-len(w5))/2) say w5 color "r+/b"
            @nrow2,int((80-len(w6))/2) say w6 color "g+/b"
            @20,int((80-len(w7))/2) say w7 color "br+/b"
            @21,int((80-len(w8))/2) say w8 color "r+/b"
       case nrow1 == 10 && 18
            @7,int((80-len(w2))/2) say w2 color "gr+/b"
            @8,int((80-len(w3))/2) say w3 color "g+/b"
            @9,int((80-len(w4))/2) say w4 color "br+/b"
            @nrow1,int((80-len(w5))/2) say w5 color "r+/b"
            @nrow2,int((80-len(w6))/2) say w6 color "gr+/b"
            @19,int((80-len(w7))/2) say w7 color "g+/b"
            @20,int((80-len(w8))/2) say w8 color "br+/b"
            @21,int((80-len(w9))/2) say w9 color "r+/b"
       case nrow1 == 11 && 17
            @9,int((80-len(w1))/2) say w1 color "r+/b"
            @10,int((80-len(w2))/2) say w2 color "g+/b"
            @11,int((80-len(w3))/2) say w3 color "br+/b"
            @12,int((80-len(w4))/2) say w4 color "r+/b"
            @nrow1+2,int((80-len(w5))/2) say w5 color "r+/b"
            @nrow2-2,int((80-len(w6))/2) say w6 color "r+/b"
            //@15,int((80-len(w6))/2) say w6 color "r+/b"
            @16,int((80-len(w7))/2) say w7 color "g+/b"
            @17,int((80-len(w8))/2) say w8 color "br+/b"
            @18,int((80-len(w9))/2) say w9 color "r+/b"
            @19,int((80-len(w10))/2) say w10 color "r+/b"
            inkey(0.5)
            move_leter(int((80-len(w1))/2),int((80-len(w6))/2),;
                       w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,nscr,lval)
    endcase
    nrow1++
    nrow2--
    if nrow1 > 11
       nrow1:=7
       nrow2:=21
       if lval
         lval := .f.
       else
         lval := .t.
       endif
    endif
    check_key()
    restscreen(4,0,24,79,ascr)
enddo
setcursor(1)
setcancel(.t.)
return(nil)
*--------------------------------------------------------------
function check_key()
local npass:=space(8),lscr:=savescreen(4,0,24,79),x:=2,scr
inkey(0.5)
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
static function move_leter(col1,col2,w1,w2,w3,w4,w5,w6,w7,w8,w9,;
                           w10,nscr,flag)
local lscr,i:=col1,j:=77-len(w1)
restscreen(6,0,22,79,nscr)
if flag
col2+=10
for i:=col1 to j
   @11,(len(w1)+i) say "" color "gr+*/b"
   @9, i say w1  color "r+/b"
   @10, i say w2 color "gr+/b"
   @11, i say w3 color "g+/b"
   @12,i say w4 color "br+/b"
   @13,i say w5 color "r+/b"
   @17,col2-1 say "" color "gr+*/b"
   @15,col2 say w6 color "br+/b"
   @16,col2 say w7 color "g+/b"
   @17,col2 say w8 color "gr+/b"
   @18,col2 say w9 color "r+/b"
   @19,col2 say w10 color "br+/b"
   check_key()
   restscreen(6,0,22,79,nscr)
   if col2 > 4
     col2--
   endif
next
else
  col2-=6
  j:=3
  for i:=col1 to j step -1
   @11,i-1 say "" color "gr+*/b"
   @9, i say w1  color "r+/b"
   @10, i say w2 color "gr+/b"
   @11, i say w3 color "g+/b"
   @12,i say w4 color "br+/b"
   @13,i say w5 color "r+/b"

   @17,col2+len(w6) say "" color "gr+*/b"
   @15,col2 say w6 color "br+/b"
   @16,col2 say w7 color "g+/b"
   @17,col2 say w8 color "gr+/b"
   @18,col2 say w9 color "r+/b"
   @19,col2 say w10 color "br+/b"
   check_key()
   restscreen(6,0,22,79,nscr)
   if col2+len(w6) < 77
      col2++
   endif
  next
endif
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
