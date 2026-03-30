* a box function for designing and shadowing
* created for METC - July 31, 1998 (RV-SHACK)

#include "box.ch"
#Include "Inkey.Ch"
#Include "Sixcdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
#Include "User.Ch"

* -----------------------------------
* Outside box (single) with SE light
* -----------------------------------
function draw_box1(ntop,nleft,nbottom,nright,color1,color2)
    @ ntop,nleft,nbottom,nright box B_SINGLE+" "  color color1 &&"BG+/BG"
    @ ntop,nleft+1 say replicate(chr(196),nright-1-nleft) color color2 &&"N+/BG"
    @ ntop,nleft say chr(218) color color2  &&"N+/BG"
    for i:=ntop+1 to nbottom-1
        @ i,nleft say chr(179) color color2 &&"N+/BG"
    end
    @ ntop,nright say chr(191) color color1 &&"BG+/BG"
    @ nbottom,nleft say chr(192) color color2 &&"N+/BG"
return(nil)

*-------------------------------------------------------------------------------
FUNCTION draw_box2(TopRow,TopCol,BotRow,BotCol,Color1,Color2,color3,lShadow)
Local cBox
Default lShadow To .T.
cBox := DefineBox1(TopRow,TopCol,BotRow,BotCol,Color1,Color2,color3,lShadow )
Return ( cBox )

Function DefineBox1( ntop, nleft, nbottom, nright, color1, color2,color3,lshadow)
  Local medver, medhor, dom, x, y, ttop, tbottom, tleft, tright, ret_val := {}

//ÄÄÄÄÄ establish defaults if not passed
default ntop to 0
default nleft to 0
default nbottom to maxrow()
default nright to maxcol()
default lshadow to .f.

//ÄÄÄÄÄ construct array containing coordinates & contents of screen
//ÄÄÄÄÄ area underneath this box - this can be used with byebyebox()

if iscolor()                                   // color monitor for full effect
   medver := int(((nbottom - ntop) + 1) / 2)   // determine vertical median
   medhor := int(((nright - nleft) + 1) / 2)   // determine horizontal median
   dom := max(medver, medhor)
   //ÄÄÄÄÄ determine dynamic box coordinates
   ttop := ntop + medver
   tbottom := nbottom - medver
   tleft := nleft + medhor
   tright := nright - medhor

   //ÄÄÄÄÄ main loop -- draw box out from center
   for x = 1 to dom
      DispBox( ttop, tleft, tbottom, tright )
      //ÄÄÄÄÄ test for border and expand if required
      if x < medver
         ttop--
         tbottom++
      endif
      if x < medhor
         tleft--
         tright++
      endif
   next
endif

//ÄÄÄÄÄ draw outer box border
    @ ntop,nleft,nbottom,nright box B_SINGLE+" "  color color2  &&"n+/bg"
    @ ntop,nleft+1 say replicate(chr(196),nright-1-nleft) color color1  &&"bg+/bg"
    for i:=ntop+1 to nbottom-1
    @ i,nleft say chr(179) color color1  &&"bg+/bg"
    end
    @ nbottom,nleft say chr(192) color color1  &&"bg+/bg"
    @ ntop,nleft say chr(218) color color1  &&"bg+/bg"

//ÄÄÄÄÄ draw shadow if called for and coordinates are valid
if lshadow .and. iscolor() .and. nbottom < maxrow() .and. nright < maxcol()-1
   gfattr(ntop + 1, nright + 1, nbottom + 1, nright + 2, 8)
   gfattr(min(nbottom + 1, maxrow()-1), nleft + 1, nbottom + 1, nright + 2, 8)
endif
return ( Ret_Val )

*-------------------------------------------------------------------------------
FUNCTION draw_box3(TopRow,TopCol,BotRow,BotCol,Color1,Color2,color3,lShadow)
Local cBox3
Default lShadow To .T.
cBox3 := DefineBox3(TopRow,TopCol,BotRow,BotCol,Color1,Color2,color3,lShadow )
Return ( cBox3 )

Function DefineBox3( ntop, nleft, nbottom, nright, color1, color2,color3,lshadow)
  Local medver, medhor, dom, x, y, ttop, tbottom, tleft, tright, ret_val := {}

//ÄÄÄÄÄ establish defaults if not passed
default ntop to 0
default nleft to 0
default nbottom to maxrow()
default nright to maxcol()
default lshadow to .f.

//ÄÄÄÄÄ construct array containing coordinates & contents of screen
//ÄÄÄÄÄ area underneath this box - this can be used with byebyebox()

if iscolor()                                   // color monitor for full effect
   medver := int(((nbottom - ntop) + 1) / 2)   // determine vertical median
   medhor := int(((nright - nleft) + 1) / 2)   // determine horizontal median
   dom := max(medver, medhor)
   //ÄÄÄÄÄ determine dynamic box coordinates
   ttop := ntop + medver
   tbottom := nbottom - medver
   tleft := nleft + medhor
   tright := nright - medhor

   //ÄÄÄÄÄ main loop -- draw box out from center
   for x = 1 to dom
      DispBox( ttop, tleft, tbottom, tright )
      //ÄÄÄÄÄ test for border and expand if required
      if x < medver
         ttop--
         tbottom++
      endif
      if x < medhor
         tleft--
         tright++
      endif
   next
endif

//ÄÄÄÄÄ draw outer box border
    @ ntop,nleft,nbottom,nright box B_SINGLE+" "  color color2  &&"n+/bg"
    @ ntop,nleft+1 say replicate(chr(196),nright-1-nleft) color color1  &&"bg+/bg"
    for i:=ntop+1 to nbottom-1
    @ i,nleft say chr(179) color color1  &&"bg+/bg"
    end           

    @ nbottom,nleft say chr(192) color color1  &&"bg+/bg"
    @ ntop,nleft say chr(218) color color1  &&"bg+/bg"
    
    @ ntop,nleft say chr(191) color color1  &&"bg+/bg" //¿
    @ ntop,nright say chr(218) color color2  &&"bg+/bg"    //Ú

//ÄÄÄÄÄ draw shadow if called for and coordinates are valid
if lshadow .and. iscolor() .and. nbottom < maxrow() .and. nright < maxcol()-1
   gfattr(ntop + 1, nright + 1, nbottom + 1, nright + 2, 8)
   gfattr(min(nbottom + 1, maxrow()-1), nleft + 1, nbottom + 1, nright + 2, 8)
endif
return ( Ret_Val )

