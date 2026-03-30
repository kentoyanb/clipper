*-------------------------------------------------------------------------------
* Generic Browser - Accounting
* April 16, 2001
* Leonardo E. Hoyla Jr.
*-------------------------------------------------------------------------------
# Include "setcurs.ch"
# Include "inkey.ch"
# Include "Tbrowse.ch"
# Include "Abrowse.ch"
# Include "dbinfo.ch"
# Include "box1.ch"
# Include "achoice.ch"
# INCLUDE "ac_ch.ch"
# DEFINE DEF_HSEP   "ÂÄ"
# DEFINE DEF_CSEP   "³"
# DEFINE DEF_FSEP   "ÁÄ"
# DEFINE  COLOR01 "+W/RB, +W/RB, N/BG, N/W, W+/G, B+/G, R+/N, W+/R, RB+/N, W+/RB"
# DEFINE  COLOR02 "W+/B, W+/B, N/W, N/W, W+/G, B+/G, R+/N, W+/R, RB+/N, W+/RB"
# DEFINE  APP_MODE_ON(b)     (b:cargo := .t.)
# DEFINE  APP_MODE_OFF(b)    (b:cargo := .f.)
# DEFINE  APP_MODE_ACTIVE(b) (b:cargo)
*-------------------------------------------------------------------------------
*  coord_   = array of coordinates
*  heads_   = header name ex. ID NO.
*  cols_    = dbf column  ex. sm1idno
*  als      = alias
*  ordfield = order name
*  rfield_  = return field
*  spec_keys = an array of special keys that performs special actions
*-------------------------------------------------------------------------------

Function acBrow( coord_, heads_, cols_, als, ordfield, rfield_,spec_keys)
   LOCAL exit_requested := .F., nKey:=0, buff, b, inscod, lrec := 0, i,as
   LOCAL oldcursor := SETCURSOR(), oldcolor := SETCOLOR(), vsKey := "", rf := ""
   LOCAL nTop:=coord_[1], nLeft:=coord_[2], nBot:=coord_[3], nRight:=coord_[4]

   DBSELECTAREA(als)
   ORDSETFOCUS(ordfield)

   SET(_SET_CURSOR,SC_NONE)
   buff := SaveScr(nTop, nLeft, nBot, nRight, .T.)
   lBox(nTop,nLeft,nBot,nRight,"W+/RB")

   b := TBrowseDB(nTop + 1, nLeft + 1, nBot - 2, nRight - 1)

   FOR i := 1 TO LEN(cols_)
       if valtype(cols_[i]) == "C"
            b:AddColumn(TBColumnNew(heads_[i],FieldBlock(cols_[i])))
       else
            b:AddColumn(TBColumnNew(heads_[i],{|| (als)->(ordkeyval()) }))
       endif
   NEXT

   b:headsep := DEF_HSEP
   b:colsep  := DEF_CSEP
   b:footsep := DEF_FSEP

   exit_requested = .F.

   SET(_SET_SOFTSEEK,.T.)
   @ nBot-1,nLeft+2 SAY "Search key :" COLOR "15/5"
   lrec := RECNO()
   b:ColorSpec := COLOR01
   (als)->(DBGOTOP())

   DO WHILE !exit_requested
      @ nBot-1,nLeft+16 SAY vsKey+" " COLOR "15/5"

      DO WHILE NEXTKEY() == 0 .AND. !b:stabilize()
      ENDDO

      b:COLORRECT({b:ROWPOS, b:COLPOS,b:ROWPOS, b:COLCOUNT},{3,4})
      b:RefreshCurrent()

      nKey := INKEY(0)

      if valtype(spec_keys) == "A"

         as := ascan ( spec_keys,{|x| x[1] == nKey} )

         if as <> 0
            eval ( spec_keys[as,2] )
            DBSELECTAREA(als)
            ORDSETFOCUS(ordfield)
            b:refreshall()
            nKey := 0
            loop
         endif

      endif

      IF !tbMethods(b,nKey)
          DO CASE
              CASE Was_In(nkey) == .T.
                   vsKey := vsKey + Upper(Chr(nkey))
                   DBGOTOP()
                   (als)->(DBSeek(vskey))
                   IF !FOUND()
                      TONE(500)
                      vsKey := STUFF(vsKey,LEN(vsKey),1,"")
                      DBGOTO(lrec)
                   ELSE
                      lrec := RECNO()
                      DBGOTO(lrec)
                   ENDIF
                   b:Refreshall()
              CASE nKey == K_BS
                   vsKey := Stuff(vsKey,Len(vsKey),1,"")
                   (als)->(DBSeek(vskey))
                   IF vsKey == ""
                      TONE(500)
                      DBGOTOP()
                   ENDIF
                   b:Refreshall()
                   lrec := RECNO()
              CASE nKey == K_RETURN
                   FOR i := 1 TO LEN(rfield_)
                      rf += FieldGet(rfield_[i])  // return field
                   NEXT
                   if GetActive() <> NIL
                      GetActive():Varput(rf)
                      exit_requested := .T.
                   endif
              CASE nKey == K_ESC
                   exit_requested := .T.
          ENDCASE
      ELSE
          b:ForceStable()
          @ nBot-1,nLeft+16 SAY SPACE(LEN(vsKey)) COLOR "15/5"
          vsKey := ""
      ENDIF // meth_no != 0
   ENDDO // WHILE !exit_requested
   SETCOLOR(oldcolor)
   SETCURSOR(oldcursor)
   SET(_SET_SOFTSEEK,.F.)
   RestScr(buff)
RETURN NIL

*-------------------------------------------------------------------------------
*  coord_   = array of coordinates
*  heads_   = header name ex. ID NO.
*  cols_    = dbf column  ex. sm1idno
*  als      = alias
*  ordfield = order name
*  rfield_  = return field
*  spec_keys = an array of special keys that performs special actions
*-------------------------------------------------------------------------------

Function acBrow1( coord_, heads_, cols_, als, ordfield, rfield_,spec_keys)
   LOCAL exit_requested := .F., nKey:=0, buff, b, inscod, lrec := 0, i,as
   LOCAL oldcursor := SETCURSOR(), oldcolor := SETCOLOR(), vsKey := "", rf := ""
   LOCAL nTop:=coord_[1], nLeft:=coord_[2], nBot:=coord_[3], nRight:=coord_[4]

   DBSELECTAREA(als)
   ORDSETFOCUS(ordfield)

   SET(_SET_CURSOR,SC_NONE)
   buff := SaveScr(nTop, nLeft, nBot, nRight, .T.)
   lBox(nTop,nLeft,nBot,nRight,"W+/RB")

   b := TBrowseDB(nTop + 1, nLeft + 1, nBot - 2, nRight - 1)

   FOR i := 1 TO LEN(cols_)
       b:AddColumn(TBColumnNew(heads_[i],cols_[i]))
   NEXT

   APP_MODE_OFF(b)

   b:headsep := DEF_HSEP
   b:colsep  := DEF_CSEP
   b:footsep := DEF_FSEP

   exit_requested = .F.

   SET(_SET_SOFTSEEK,.T.)
   @ nBot-1,nLeft+2 SAY "Search key :" COLOR "15/5"
   lrec := RECNO()
   b:ColorSpec := COLOR01
   (als)->(DBGOTOP())
   DO WHILE !exit_requested
      @ nBot-1,nLeft+16 SAY vsKey+" " COLOR "15/5"

      DO WHILE NEXTKEY() == 0 .AND. !b:stabilize()
      ENDDO

      b:COLORRECT({b:ROWPOS, b:COLPOS,b:ROWPOS, b:COLCOUNT},{3,4})
      b:RefreshCurrent()
      nKey := INKEY(0)

      if valtype(spec_keys) == "A"

         as := ascan ( spec_keys,{|x| x[1] == nKey} )

         if as <> 0
            eval ( spec_keys[as,2] )
            DBSELECTAREA(als)
            ORDSETFOCUS(ordfield)
            b:refreshall()
            nKey := 0
            loop
         endif

      endif

      IF !tbMethods(b,nKey)
          DO CASE
              CASE Was_In(nkey) == .T.
                   vsKey := vsKey + Upper(Chr(nkey))
                   DBGOTOP()
                   (als)->(DBSeek(vskey))
                   IF !FOUND()
                      TONE(500)
                      vsKey := STUFF(vsKey,LEN(vsKey),1,"")
                      DBGOTO(lrec)
                   ELSE
                      lrec := RECNO()
                      DBGOTO(lrec)
                   ENDIF
                   b:Refreshall()
              CASE nKey == K_BS
                   vsKey := Stuff(vsKey,Len(vsKey),1,"")
                   (als)->(DBSeek(vskey))
                   IF vsKey == ""
                      TONE(500)
                      DBGOTOP()
                   ENDIF
                   b:Refreshall()
                   lrec := RECNO()
              CASE nKey == K_RETURN
                   FOR i := 1 TO LEN(rfield_)
                      rf += FieldGet(rfield_[i])  // return field
                   NEXT
                   if GetActive() <> NIL
                      GetActive():Varput(rf)
                      exit_requested := .T.
                   endif
              CASE nKey == K_ESC
                   exit_requested := .T.
          ENDCASE
      ELSE
          b:forcestable()
          @ nBot-1,nLeft+16 SAY SPACE(LEN(vsKey)) COLOR "15/5"
          vsKey := ""
      ENDIF // meth_no != 0
   ENDDO // WHILE !exit_requested
   SETCOLOR(oldcolor)
   SETCURSOR(oldcursor)
   SET(_SET_SOFTSEEK,.F.)
   RestScr(buff)
RETURN NIL

*-------------------------------------------------------------------------------

FUNCTION ArrayGB( nTop, nLeft, nBot, nRight, ;
                  ar, nElem, aHeadings, aBlocks, bGetFunc)
   * ANYTYPE[]   ar        - Array to browse
   * NUMERIC     nElem     - Element In Array
   * CHARACTER[] aHeadings - Array of Headings for each column
   * BLOCK[]     aBlocks   - Array containing code block for each column.
   * CODE BLOCK  bGetFunc  - Code Block For Special Get Processing
   *  NOTE: When evaluated a code block is passed the array element to
   *          be edited
   LOCAL exit_requested := .F., nKey, meth_no, ;
         cSaveWin, i, b, column, oldcolor := SETCOLOR(), oldcursor := SETCURSOR()
   LOCAL nDim, nWorkRow, cType, cVal

   SET(_SET_CURSOR,SC_NONE)
   cSaveWin := SaveScr(nTop, nLeft, nBot, nRight, .T.)
//   lBox(nTop,nLeft,nBot,nRight,"W+/B")
   b := TBrowseDB(nTop+1 , nLeft + 1, nBot , nRight - 1)
   FOR i = 1 TO LEN(aBlocks)
       column := TBColumnNew(aHeadings[i], aBlocks[i] )
       b:addcolumn(column)
   NEXT

   b:headsep := DEF_HSEP
   b:colsep  := DEF_CSEP
   b:footsep := DEF_FSEP

   * skipblock originally coded by Robert DiFalco
   b:SkipBlock     := {|nSkip, nStart| nStart := nElem,;
      nElem := MAX( 1, MIN( LEN(ar[1]), nElem + nSkip ) ),;
      nElem - nStart }
   b:gotopblock    := {|| nElem := 1}
   b:gobottomblock := {|| nElem := LEN(ar[1])}

   b:ColorSpec := COLOR02
   exit_requested = .F.
   DO WHILE !exit_requested

      DO WHILE NEXTKEY() == 0 .AND. !b:stabilize()
      ENDDO
      b:COLORRECT({b:ROWPOS, b:COLPOS,b:ROWPOS, b:COLCOUNT},{3,4})
      b:RefreshCurrent()
      nKey := INKEY(0)

      IF !tbMethods(b,nKey)
         DO CASE
            CASE nKey == K_F7
                 FOR nDim = 1 TO LEN(ar)
                     ADEL(ar[nDim], nElem)
                     ASIZE(ar[nDim], LEN(ar[nDim]) - 1)
                 NEXT
                 b:refreshAll()
            CASE nKey == K_F8
                 FOR nDim = 1 TO LEN(ar)
                     * check valtype of current element before AINS()
                     cType := VALTYPE(ar[nDim, nElem])
                     cVal  := ar[nDim, nElem]
                     ASIZE(ar[nDim], LEN(ar[nDim]) + 1)
                     AINS(ar[nDim], nElem)
                     IF cType == "C"
                        ar[nDim, nElem] := SPACE(LEN(cVal))
                     ELSEIF cType == "N"
                        ar[nDim, nElem] := 0
                     ELSEIF cType == "L"
                        ar[nDim, nElem] := .f.
                     ELSEIF cType == "D"
                        ar[nDim, nElem] := CTOD("  /  /  ")
                     ENDIF
                 NEXT
                 b:refreshAll()

            CASE nKey == K_ESC
                 exit_requested := .T.
            * Other exception handling ...
/*
            CASE VALTYPE(bGetFunc) == "B"
                 IF nKey <> K_ENTER
                    * want last key to be part of GET edit so KEYBOARD it
                    KEYBOARD CHR(LASTKEY())
                 ENDIF
                 EVAL(bGetFunc, b, ar, b:colPos, nElem )
                 * after get move to next field
                 KEYBOARD IF(b:colPos < b:colCount, ;
                              CHR(K_RIGHT), CHR(K_HOME) + CHR(K_DOWN) )

              * Placing K_ENTER here below Edit Block (i.e. bGetFunc)
              * defaults K_ENTER to Edit when bGetFunc Is Present
              * BUT if no bGetFunc, then K_ENTER selects element to return
*/
            CASE nKey == K_ENTER
                 exit_requested := .T.
           ENDCASE
      ENDIF // meth_no != 0
   ENDDO // WHILE !exit_requested
   SETCOLOR(oldcolor)
   SETCURSOR(oldcursor)
   RestScr(cSaveWin)
   * if no bGetFunc then ESC returns 0, otherwise return value of last element
RETURN IF( VALTYPE(bGetFunc) == NIL .AND. nKey == K_ESC, ;
           0, ar[b:colPos, nElem] )
* EOFcn FT_ArEdit()
*-------------------------------------------------------------------------------
FUNCTION arGet( b, ar, nDim, nElem)
   LOCAL GetList   := {}
   LOCAL nRow      := ROW()
   LOCAL nCol      := COL()
   LOCAL cSaveScrn := SAVESCREEN(21, 0, 22, MaxCol())
   LOCAL cOldColor := SetColor( "W/N")

   @ 21, 0 CLEAR TO 22, MaxCol()
   @ 21,29 SAY "Editing Array Element"
   SetColor(cOldColor)
   WAIT
   DO CASE
      CASE nDim == 1
           @ nRow, nCol GET ar[1, nElem] PICTURE "99"
           READ
           b:refreshAll()
      CASE nDim == 2
           @ nRow, nCol GET ar[2, nElem] PICTURE "!"
           READ
           b:refreshAll()
      CASE nDim == 3
           @ nRow, nCol GET ar[3, nElem] PICTURE "!"
           READ
           b:refreshAll()
   ENDCASE
   RESTSCREEN(21, 0, 22, MaxCol(), cSaveScrn)
   @ nRow, nCol SAY ""
RETURN(.t.)
