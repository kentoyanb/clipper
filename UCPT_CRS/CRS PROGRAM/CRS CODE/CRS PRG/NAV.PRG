#include "Inkey.ch"
#include "Box.ch"
function main()
local lval:=.f.
set scoreboard off
setkey(K_F1,{ || check_key()})
while .t.
scroll()
//@1,60 say clock('on','12 hours','second','br+/n')
asaver := savescreen(00,00,24,79)
setcursor(.f.)
** display u **

        for ncol := 1 to 80
                @ 08,ncol say "ллллл   ллллл" color "gr+/n"
                @ 09,ncol say " ллл     ллл " color "gr+/n"
                @ 10,ncol say " ллл     ллл " color "gr+/n"
                @ 11,ncol say " ллл     ллл " color "gr+/n"
                @ 12,ncol say " ллл     ллл " color "gr+/n"
                @ 13,ncol say " ллл     ллл " color "gr+/n"
                @ 14,ncol say " лллл   лллл " color "gr+/n"
                @ 15,ncol say " плллллллллп " color "gr+/n"

                for nctr := 1 to 10000
                next
               restscreen(08,ncol,15,ncol,asaver)
               check_key()
        next


        for ncol := 80 to 1 step -1
                @ 08,ncol say "ллллл   ллллл                                       " color "gr+/n"
                @ 09,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 10,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 11,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 12,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 13,ncol say " ллл     ллл лпл л л л лп лпм лпп л плп л л   лпл лп" color "gr+/n"
                @ 14,ncol say " лллл   лллл л л л л л лп лмп ппл л  л   л    л л лп" color "gr+/n"
                @ 15,ncol say " плллллллллп л л л плп лм л л ммл л  л   л    лмл л " color "gr+/n"

               for nctr := 1 to 10000
               next
                restscreen(08,ncol-1,15,ncol+80,asaver)
                check_key()
        next

** end of letter u **

** display letter c **

        for ncol := 1 to 80
                @ 08,ncol say "млллллллллм" color "bg+/n"
                @ 09,ncol say "ллл      лл" color "bg+/n"
                @ 10,ncol say "ллл        " color "bg+/n"
                @ 11,ncol say "ллл        " color "bg+/n"
                @ 12,ncol say "ллл        " color "bg+/n"
                @ 13,ncol say "ллл        " color "bg+/n"
                @ 14,ncol say "ллл      лл" color "bg+/n"
                @ 15,ncol say "плллллллллп" color "bg+/n"

                for nctr := 1 to 10000
                next
                restscreen(08,ncol,15,ncol,asaver)
                check_key()
        next

        for ncol := 80 to 1 step -1
                @ 08,ncol say "млллллллллм           " color "bg+/n"
                @ 09,ncol say "ллл      лл           " color "bg+/n"
                @ 10,ncol say "ллл                   " color "bg+/n"
                @ 11,ncol say "ллл                   " color "bg+/n"
                @ 12,ncol say "ллл                   " color "bg+/n"
                @ 13,ncol say "ллл         лп лпм л л" color "bg+/n"
                @ 14,ncol say "ллл      лл лп лпм л л" color "bg+/n"
                @ 15,ncol say "плллллллллп лм лмп лмл" color "bg+/n"

                for nctr := 1 to 10000
                next
                restscreen(08,ncol-1,15,ncol+80,asaver)
                check_key()
        next


** end of letter c **
** display letter m **

        for ncol := 1 to 80
                @ 08,ncol say "лллллл    лллллл" color "r+/n"
                @ 09,ncol say " лллллн  оллллл " color "r+/n"
                @ 10,ncol say " лллпллноллпллл " color "r+/n"
                @ 11,ncol say " ллл  пллп  ллл " color "r+/n"
                @ 12,ncol say " ллл        ллл " color "r+/n"
                @ 13,ncol say " ллл        ллл " color "r+/n"
                @ 14,ncol say " ллл        ллл " color "r+/n"
                @ 15,ncol say "ллллл      ллллл" color "r+/n"

                for nctr := 1 to 10000
                next
                restscreen(08,ncol,15,ncol,asaver)
                check_key()
        next

** end of letter m **
** begin letter e **

        for ncol := 80 to 1 step -1
                @ 08,ncol say "ллллллллллл" color "b/n"
                @ 09,ncol say " ллл      п" color "b/n"
                @ 10,ncol say " ллл       " color "b/n"
                @ 11,ncol say " ллллллл   " color "b/n"
                @ 12,ncol say " ллл       " color "b/n"
                @ 13,ncol say " ллл       " color "b/n"
                @ 14,ncol say " ллл      м" color "b/n"
                @ 15,ncol say "ллллллллллл" color "b/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol-1,15,ncol+80,asaver)
                check_key()
        next

** end of letter e **

** begin letter t **

        for ncol := 1 to 80
                @ 08,ncol say "ллллллллллллл" color "g/n"
                @ 09,ncol say "п    ллл    п" color "g/n"
                @ 10,ncol say "     ллл     " color "g/n"
                @ 11,ncol say "     ллл     " color "g/n"
                @ 12,ncol say "     ллл     " color "g/n"
                @ 13,ncol say "     ллл     " color "g/n"
                @ 14,ncol say "     ллл     " color "g/n"
                @ 15,ncol say "    ллллл    " color "g/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
                check_key()
        next

** end of letter t **
** begin letter c **

        for ncol := 80 to 1 step -1
                @ 08,ncol say "лллллллллллл" color "rb/n"
                @ 09,ncol say " ллл      лл" color "rb/n"
                @ 10,ncol say " ллл        " color "rb/n"
                @ 11,ncol say " ллл        " color "rb/n"
                @ 12,ncol say " ллл        " color "rb/n"
                @ 13,ncol say " ллл        " color "rb/n"
                @ 14,ncol say " ллл      лл" color "rb/n"
                @ 15,ncol say "лллллллллллл" color "rb/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol-1,15,ncol+80,asaver)
                check_key()
        next
** end of letter c **
enddo
setkey(K_F1,NIL)
set scoreboard on
return(nil)
*--------------------------------------------------------------
function check_key()
local npass:=space(8),lscr:=savescreen(0,0,24,79),x:=2,scr
inkey(0.1)
if lastkey() == K_ESC
   npass:=your_pass()
   scr:=savescreen(0,0,24,79)
   if alltrim(npass) == "BONZ"
      quit
   else
      for x:=2 to 80
         @13,x say "Invalid password..." color "gr+/n"
         inkey(0.1)
         @13,x say "                   " color "n"
         restscreen(0,0,24,79,scr)
      next
      tone(300,18)
   endif
endif
restscreen(0,0,24,79,lscr)
return(nil)
*--------------------------------------------------------------
function your_pass()
local xpass:=space(8),xtime:=1,xmsg:="CONFIRM PASSWORD",xcol:=34,;
      xch:=space(1),i:=1
setcolor("br+/bg")
@10,10 clear to 16,70
draw_box(10,10,16,70,"n+/bg","bg+/bg",,.f.)
draw_box(13,12,15,68,"bg+/bg","n+/bg",,.f.)
@12,((80-len(xmsg))/2) say xmsg color "r+/bg"
@14,14 say "Your Password:      XXXXXXXX"
set cursor off
while .t.
 @14,xcol get xch pict "@!" color "bg/bg"
 read
 @14,xcol say "X" color "r+/bg"
 xcol++
  if !xch==space(1) .and. !lastkey()== K_ENTER
    xpass+=upper(xch)
  endif
  if i > 8 .or. lastkey() == K_ENTER
     exit
  endif
  i++
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
