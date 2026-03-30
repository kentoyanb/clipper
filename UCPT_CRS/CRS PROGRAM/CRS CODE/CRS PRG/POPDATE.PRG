/*
   Program: POPDATE.PRG
   System: GRUMPFISH LIBRARY
   Author: Greg Lief
   Copyright (c) 1988-93, Greg Lief
   CA-Clipper 5.x version
   Compile instructions: clipper popdate /n /w
   Special thanks to Tom Walden and Bob Summers for their
   invaluable contributions to this piece of code

   Procs & Fncts: VIEWAPPTS()
                : LOCK_APPT()
                : APPT_MAINT()
                : APPT_RECUR()
                : APPT_NOTES()
                : GETDATE()
                : APPT_CDATE()
                : APPT_SHOW()
                : GRAB_DATES()
                : APPT_DAY()
                : APPT_WEEK()
                : NOCONFLICT()
                : APPTPRINTW()
                : APPT_HEADW()
                : APPTPRINTD()
                : APPT_HEADD()
                : APPT_MEET()
                : APPT_DOM()

           Calls: CALENDBOX()    (function in CALENDAR.PRG)
                : NEXTMONTH()    (function in CALENDAR.PRG)

            Uses: APPT.DBF

                 1  USERID       Character     8
                 2  DATE         Date          8
                 3  TIME         Character     5
                 4  ENDTIME      Character     5
                 5  BRIEF        Character    50
                 6  COMMENTS     Memo         10

        Indexes: APPTUSER.NTX (key: USERID + DTOS(DATE) + TIME)
                 APPTDATE.NTX (key: DTOS(DATE) + USERID + TIME)
*/

#define GRUMP_CALENDAR   // see GRUMP.CH
#include "grump.ch"
#include "inkey.ch"

static winbuff            // buffer under appointment window
static tdate              // current highlighted date

#define STARTDATE       aDates[1]
#define ENDDATE         aDates[2]
#define CURRENTYEAR     substr(dtos(mdate), 1, 4)
#define CURRENTDAY      substr(dtos(mdate), 7)


function popdate(gfproc, gfline, gfvar)

local hotkey := 0
local bOldblock
local maincolor := ColorSet(C_CALENDAR, .T.)
local mdate
local mtop := 0
local mleft := 7
local nWorkArea := select()
local olddelete
local oldscore
local mfile
local datecoords[10]
local getlist := {}
local aFinds := {}
local redraw
local keypress
local newrow
local newcol
local tempdate
local buffer
local xx
local mstring
local nType
local aDates
local numappts
local lHad2Open := .f.
local lOpenHolidays := .f.
local lHolidays := .f.
#ifdef MOUSE
local nMRow
local nMCol
local aHotSpots := { {  1, 41, 41, K_LEFT  }, ;
                     {  1, 42, 42, K_RIGHT }, ;
                     {  1, 58, 58, K_UP    }, ;
                     {  1, 59, 59, K_DOWN  }, ;
                     {  2, 41, 44, K_PGUP  }, ;
                     {  2, 46, 49, K_PGDN  }, ;
                     {  3, 41, 44, K_HOME  }, ;
                     {  3, 46, 48, K_END   }, ;
                     {  4, 41, 42, K_ENTER }, ;
                     {  4, 58, 60, K_ESC   }, ;
                     {  5, 41, 41, 83      }, ;
                     {  6, 41, 41, 80      }, ;
                     {  7, 41, 41, 68      }, ;
                     {  8, 41, 41, 84      }, ;
                     {  9, 41, 41, 87      }, ;
                     { 10, 41, 41, 67      }, ;
                     { 11, 41, 41, 74      }, ;
                     { 12, 41, 41, 77      } }
#endif

memvar apptdir // global that may have been declared in calling program
GFSaveEnv(.t., 0)

//ÄÄÄÄÄ determine whether this was called via hot-key; if so, disable it
if (gfproc <> NIL)
   bOldblock := setkey(hotkey := lastkey(), NIL)
endif

//ÄÄÄÄÄ if monochrome monitor, clear the entire screen for clarity
if ! iscolor()
   scroll()
endif
winbuff := savescreen(15, 02, maxrow(), 79)   // buffer underneath appt window
mdate := date()

//ÄÄÄÄÄ open appt.dbf... first determine path, then confirm existence of file
mfile := if(type('apptdir') = 'U', '', apptdir + '\') + 'appt'
if ! file(mfile + ".dbf")
   waiton('initializing appointment database... please wait')
   dbcreate(mfile + ".dbf", { {"USERID",  "C",  8, 0} , ;
                              {"DATE",    "D",  8, 0} , ;
                              {"TIME",    "C",  5, 0} , ;
                              {"ENDTIME", "C",  5, 0} , ;
                              {"BRIEF",   "C", 50, 0} , ;
                              {"COMMENTS","M", 10, 0} } )
   waitoff()
endif
if ! file(mfile + 'user' + indexext()) .or. ! file(mfile + 'date' + indexext())
   use (mfile) new exclusive
   index on appt->userid + dtos(appt->date) + appt->time to (mfile + 'user')
   index on dtos(appt->date) + appt->userid + appt->time to (mfile + 'date')
   use
endif

//ÄÄÄÄÄ only open HOLIDAYS.DBF if it is not already open!
if select("holidays") == 0
   if ! file("holidays.dbf")
      dbcreate("holidays.dbf", { { "DATE", "D", 8, 0 } } )
      use holidays new exclusive
      index on holidays->date to holidays
      dbclosearea()
      lHolidays := .f.
   elseif ! file('holidays' + indexext()) .and. (lHolidays := net_use('holidays', .t.))
      index on holidays->date to holidays
      dbclosearea()
      lHolidays := lOpenHolidays := net_use('holidays', .f., 'holidays')
   else
      lHolidays := lOpenHolidays := net_use('holidays', .f., 'holidays')
   endif
else
   lHolidays := .t.
endif

//ÄÄÄÄÄ only open APPT.DBF if it is not already open!
if select("appt") == 0
   if ! net_use(mfile, .f., { mfile + 'date', mfile + 'user' } )
      GFRestEnv()
      return nil
   else
      lHad2Open := .t.
   endif
else
   //ÄÄÄÄÄ make sure the appropriate indeces have already been opened
   if appt->(indexkey(1)) <> "dtos(appt->date) + appt->userid + appt->time" .or. ;
      appt->(indexkey(2)) <> "appt->userid + dtos(appt->date) + appt->time"
      err_msg({ "Missing indexes, aborting (POPDATE)" } )
      GFRestEnv()
      return nil
   else
      select appt
   endif
endif

olddelete := set(_SET_DELETED, .T.)
oldscore := set(_SET_SCOREBOARD, .F.)

//ÄÄÄÄÄ initial screen setup
ColorSet(C_CALENDAR)
ShadowBox(0, 39, 13, 72, 4)

//ÄÄÄÄÄ draw menu options box
@ 1,       45 ssay 'move by day'
@ 1,       61 ssay 'by week'
@ row()+1, 51 ssay 'move by month'
@ row()+1, 51 ssay 'first/last day'
@ row()+1, 45 ssay 'add/edit'
@ row(),   62 ssay 'exit'
@ row()+1, 45 ssay 'search for text'
@ row()+1, 45 ssay 'print appointments'
@ row()+1, 45 ssay 'delete appointments'
@ row()+1, 45 ssay 'daily time blocks'
@ row()+1, 45 ssay 'weekly appt summary'
@ row()+1, 45 ssay 'current date: ' + dtoc(mdate)
@ row()+1, 45 ssay 'jump to date'
@ row()+1, 45 ssay 'schedule meeting'
@ 0,46 ssay ' Calendar Options ' color '+' + setcolor()
setcolor('I')
@ 1,       41 ssay chr(27) + chr(26)
@ row(),   58 ssay chr(24) + chr(25)
@ row()+1, 41 ssay 'PgUp/PgDn'
@ row()+1, 41 ssay 'Home/End'
@ row()+1, 41 ssay chr(17) + chr(217)
@ row(),   58 ssay 'Esc'
@ row()+1, 41 ssay 'S'
@ row()+1, 41 ssay 'P'
@ row()+1, 41 ssay 'D'
@ row()+1, 41 ssay 'T'
@ row()+1, 41 ssay 'W'
@ row()+1, 41 ssay 'C'
@ row()+1, 41 ssay 'J'
@ row()+1, 41 ssay 'M'

calendbox(.t., mtop, mleft, date(), maincolor, .t., datecoords)

//ÄÄÄÄÄ commence main keypress loop
do while .t.
   redraw := .f.
   tdate := mdate                  // store highlighted date
   Appt_Show(CURRENTAPPTS)
   keypress := ginkey(0)
   newrow := CURRENTDAY_ROW
   newcol := CURRENTDAY_COL

   #ifdef MOUSE
   if keypress == K_LEFT_DBLCLICK
      nMRow := LastRow()
      nMCol := __FixMCol( mleft )

      if nMRow == CURRENTDAY_ROW .and. nMCol == CURRENTDAY_COL
         keypress := K_ENTER
      else
         keypress := K_LEFT_DOWN
      endif
   endif

   do case
   case keypress == K_RIGHT_DOWN
      keypress := K_ESC

   case keypress == K_LEFT_DOWN
      nMRow := LastRow()
      nMCol := __FixMCol( mleft )

      //ÄÄÄÄÄ if there are appointments for current date and mouse was
      //ÄÄÄÄÄ clicked inside the view box, treat that as an Enter so
      //ÄÄÄÄÄ that they can view/edit the appointments
      if CURRENTAPPTS .and. nMRow >= 15 .and. nMCol >= 2 .and. nMCol < 77
         keypress := K_ENTER
      elseif ( nMRow >= mtop + 5  .and. nMRow <= mtop + 11 ) .and. ;
               nMCol == mleft +  1 .or. nMCol == mleft +  4 .or. ;
               nMCol == mleft +  7 .or. nMCol == mleft + 10 .or. ;
               nMCol == mleft + 13 .or. nMCol == mleft + 16 .or. ;
               nMCol == mleft + 19

         mdate  += ( ( ( nMRow - CURRENTDAY_ROW ) * 7 ) + ;
                     ( ( nMCol - CURRENTDAY_COL ) / 3 ) )
         newrow := nMRow
         newcol := nMCol
      else
         aeval( aHotSpots, {| a | iif( nMRow == a[ 1 ] .and. ;
                                       nMCol >= a[ 2 ] .and. ;
                                       nMCol <= a[ 3 ],      ;
                                       keypress := a[ 4 ], )} )
      endif
   endcase
   #endif

   do case
   #ifdef MOUSE
   case keypress == K_LEFT_DOWN
   #endif

   case keypress == K_DOWN         // forward one week
      mdate += 7
      newrow++

   case keypress == K_UP           // backward one week
      mdate -= 7
      newrow--

   case keypress == K_LEFT         // go back one day
      mdate--
      //ÄÄÄÄÄ did we just go from sunday to saturday??
      newrow := if(dow(mdate) == 7, CURRENTDAY_ROW - 1, CURRENTDAY_ROW)
      newcol := if(dow(mdate) == 7, mleft + 19, CURRENTDAY_COL - 3)

   case keypress == K_RIGHT       // go forward one day
      mdate++
      //ÄÄÄÄÄ did we just go from saturday to sunday??
      newrow := if(dow(mdate) == 1, CURRENTDAY_ROW + 1, CURRENTDAY_ROW)
      newcol := if(dow(mdate) == 1, mleft + 1, CURRENTDAY_COL + 3)

   case keypress == K_PGUP        // go back one month
      if month(mdate) == 1     // going to december of previous year
         mdate := stod( str(val(CURRENTYEAR)-1, 4) + '12' + CURRENTDAY)
      else
         //ÄÄÄÄÄ check for validity of current date in previous month
         //ÄÄÄÄÄ i.e., cannot go from March 31 to February 31, etcetera
         tempdate := ctod('')
         do while empty(tempdate)
            tempdate := stod(CURRENTYEAR + if(month(mdate) < 11, '0', '') + ;
                        ltrim(str(month(mdate) - 1)) + CURRENTDAY)
            mdate--
         enddo
         mdate := tempdate
      endif

   case keypress == K_PGDN        // go forward one month
      mdate := NextMonth(mdate)

   case keypress == K_HOME        // go to first day
      newrow := FIRSTDAY_ROW
      newcol := FIRSTDAY_COL
      mdate := stod(substr(dtos(mdate), 1, 6) + '01')

   case keypress == K_END         // go to last day
      newrow := LASTDAY_ROW
      newcol := LASTDAY_COL
      mdate := stod(substr(dtos(mdate), 1, 6) + str(LASTDAY_NUMBER, 2))

   case keypress == K_ENTER        // view appointments
      redraw := ViewAppts(! CURRENTAPPTS)

   case keypress == 115 .or. keypress == 83      // text search
      asize(aFinds, 0)
      nType := gfAlert("What would you like to search?", ;
               { "Who", "Description", "Notes" })
      if lastkey() <> K_ESC
         xx := 0
         mstring := space(20)
         ColorSet(C_MESSAGE)
         buffer := shadowbox(11, 18, 13, 61, 2)
         @ 12, 20 ssay "Text to search for:"
         @ row(), col() + 1 get mstring
         setcursor(1)
         read
         setcursor(0)
         ByeByeBox(buffer)
         if lastkey() <> K_ESC .and. ! empty(mstring)
            mstring := trim(mstring)
            go top
            locate for upper(mstring) $ ;
                    upper({ appt->userid, appt->brief, appt->comments }[nType])
            do while found() .and. xx < 12   // max of 12 finds for now
               aadd(aFinds, dtoc(appt->date) + [  ] + appt->time + [ - ] + ;
                            appt->endtime + [ ] + appt->brief + str(recno(), 6))
               xx++
               continue
            enddo
            if xx > 0
               buffer := ColorSet(C_ERRORMESSAGE, .t.)
               xx := apick(6, 2, 19, 78, aFinds, buffer,,,,,buffer,,,,, ;
                           'Finds for "' + mstring + '"')
               if xx > 0
                  //ÄÄÄÄÄ note: check for length of current date format
                  //ÄÄÄÄÄ because it won't always be 8 (thanks Raymond Low)
                  mdate := ctod(substr(aFinds[xx], 1, len(set(_SET_DATEFORMAT))))
                  redraw := .t.    // gotta redo the calendar screen
                  //ÄÄÄÄÄ if we searched through notes, ask if they want to view 'em
                  if nType == 3
                     if Yes_No("View these notes now")
                        go val(substr(aFinds[xx], 75))
                        Appt_Notes()
                     endif
                  endif
               endif
            else
               Err_Msg( { 'No finds for "' + mstring + '"' } )
            endif
         endif
      endif

   case keypress == 74 .or. keypress == 106     // jump to other date
      xx := mdate
      ColorSet(C_MESSAGE)
      buffer := shadowbox(11, 25, 13, 54, 2)
      @ 12, 27 ssay "Date to jump to:"
      @ row(), col() + 1 get xx
      setcursor(1)
      read
      setcursor(0)
      ByeByeBox(buffer)
      if lastkey() <> K_ESC .and. ! empty(xx)
         redraw := .t.
         mdate := xx
      endif

   case keypress == 67 .or. keypress == 99      // move to system date
      newrow := SYSTEMDATE_ROW
      newcol := SYSTEMDATE_COL
      mdate := date()
      redraw := .t.

   case keypress == 80 .or. keypress == 112     // print appts
      if reccount() = 0
         Err_Msg( { 'File is currently empty' } )
      else
         xx := Yes_No2( { "Print for week or selected dates" }, 12, ;
                          " Week ", " Selected Dates ")
         if lastkey() <> K_ESC
            if xx
               ApptPrintW()
            else
               aDates := Grab_Dates('Print')
               if lastkey() <> K_ESC
                  ApptPrintD(STARTDATE, ENDDATE)
               endif
            endif
         endif
      endif

   case keypress == 68 .or. keypress == 100     // delete appts
      if reccount() = 0
         Err_Msg( { 'File is currently empty' } )
      else
         aDates := Grab_Dates('Delete')
         if lastkey() <> K_ESC
            dbseek( dtos(STARTDATE), .t.)
            if ! eof()
               xx := recno()
               count while appt->date >= STARTDATE .and. ;
                           appt->date <= ENDDATE to numappts
               if numappts > 0
                  if Yes_No('You are about to delete ' + ltrim(str(numappts)) + ;
                            ' appointments between ' + dtoc(STARTDATE) + ;
                            ' and ' + dtoc(ENDDATE), 'Do you want to continue')
                     go xx
                     delete while appt->date >= STARTDATE .and. ;
                                  appt->date <= ENDDATE .and. rlock()
                     if appt->date <= ENDDATE .and. ! eof()
                        Err_Msg( { 'Only deleted appointments up to ' + ;
                                    dtoc(appt->date) } )
                     endif
                     redraw := .t.    // gotta redo the calendar screen
                  endif
               else
                  Err_Msg( { 'No appointments fall within the dates ' + ;
                     dtoc(STARTDATE) + ' and ' + dtoc(ENDDATE) } )
               endif
            endif
         endif
      endif

   case keypress == 84 .or. keypress == 116     // show daily time blocks
      Appt_Day()
      loop

   case keypress == 87 .or. keypress == 119     // show weekly time blocks
      Appt_Week(mfile)
      loop

   case keypress == 77 .or. keypress == 109     // m - schedule meeting
      appt_meet(tdate)
      mdate := tdate

   case keypress == K_ESC
      exit

   otherwise                  // any other keystroke
      loop

   endcase

   //ÄÄÄÄÄ if we changed months or a recurring appointment was added, redraw calendar
   if month(tdate) <> month(mdate) .or. redraw
      calendbox(.t., mtop, mleft, mdate, maincolor, , datecoords)
   else
      setcolor('+' + maincolor)

      //ÄÄÄÄÄ check if previous date had appointments (for display purposes)
      if dbseek( dtos(tdate) )
         setcolor('i')
      //ÄÄÄÄÄ check if previous date was a holiday
      elseif lHolidays .and. holidays->( dbseek(tdate) )
         setcolor('w/r')
      endif

      @ CURRENTDAY_ROW, CURRENTDAY_COL ssay str(day(tdate), 2)

      //ÄÄÄÄÄ check if new date has appointments (for display purposes)
      if ( CURRENTAPPTS := dbseek(dtos(mdate)) )
         setcolor('*i')
      //ÄÄÄÄÄ check if new date is a holiday
      elseif lHolidays .and. holidays->( dbseek(mdate) )
         setcolor('*+w/r')
      else
         setcolor('*+' + maincolor)
      endif

      @ newrow, newcol ssay str(day(mdate),2)

      //ÄÄÄÄÄ store new row/column coordinates for highlighted date
      CURRENTDAY_ROW := newrow
      CURRENTDAY_COL := newcol
   endif
enddo

//ÄÄÄÄÄ close APPT.DBF if necessary
if lHad2Open
   dbCloseArea()
endif

select(nWorkArea)

//ÄÄÄÄÄ close HOLIDAYS.DBF if necessary
if lOpenHolidays
   holidays->( dbCloseArea() )
endif

//ÄÄÄÄÄ restore hot-key
if hotkey <> 0
   setkey( hotkey, bOldblock )
endif

set(_SET_SCOREBOARD, oldscore)    // in case you were keeping SCORE
set(_SET_DELETED, olddelete)
GFRestEnv()
return nil

* end function PopDate()
*--------------------------------------------------------------------*


/*
   Function:  VIEWAPPTS
*/
static function viewappts(lNewDay)
static oBrowse
local nMaxRow := maxrow()
local column
local buffer_[2]
local key
local mtime
local mendtime
local mdate
local ele := 1
local ret_val := .f.
local getlist := {}
#ifdef MOUSE
local aPos
local nMRow
local nMCol
local aHotSpots := { { nMaxRow-1,  5,  7, 65 }, ;
                     { nMaxRow-1, 12, 15, 69 }, ;
                     { nMaxRow-1, 20, 25, 68 }, ;
                     { nMaxRow-1, 30, 33, 77 }, ;
                     { nMaxRow-1, 38, 51, 82 }, ;
                     { nMaxRow-1, 56, 60, 78 }, ;
                     { nMaxRow-1, 65, 72, 27 } }
#endif

restscreen(15, 02, nMaxRow, 79, winbuff) // remove daily appt window first
//ÄÄÄÄÄ we only need to create the TBrowse object on the first time in
if oBrowse == NIL
   oBrowse := TBrowseDB(15, 3, nMaxRow - 2, 75)
   oBrowse:headSep := "Í"
   oBrowse:skipBlock := { |SkipCnt| AwSkipIt(SkipCnt) }
   column := TBColumnNew( "Who", fieldblock( "USERID" ) )
   oBrowse:addColumn(column)
   column := TBColumnNew( "Start", fieldblock( "TIME" ) )
   oBrowse:addColumn(column)
   column := TBColumnNew( "End", fieldblock( "ENDTIME" ) )
   oBrowse:addColumn(column)
   column := TBColumnNew( "Appointment Description", { || field->BRIEF + ;
             if(len(trim(field->comments)) > 2, chr(251), chr(32)) } )
   oBrowse:addColumn(column)
else
   oBrowse:goTop()
endif
//ÄÄÄÄÄ we must always reset colorSpec because the user might have changed
//ÄÄÄÄÄ the color since our last visit to this function
oBrowse:colorSpec := ColorSet(C_APPOINTMENT, .T.) + ',' + "+W/N"
seek dtos(tdate)
ColorSet(C_APPOINTMENT)
buffer_[1] := ShadowBox(14, 02, nMaxRow - 1, 76, 2, 'Appointments for ' + dateword(tdate))
@ nMaxRow-1,  6 ssay "dd"
@ nMaxRow-1, 13 ssay "dit"
@ nMaxRow-1, 21 ssay "elete"
@ nMaxRow-1, 31 ssay "ove"
@ nMaxRow-1, 39 ssay "ecurring appt"
@ nMaxRow-1, 57 ssay "otes"
@ nMaxRow-1, 69 ssay "exit"
@ nMaxRow-1,  5 ssay "A" color "I"
@ nMaxRow-1, 12 ssay "E" color "I"
@ nMaxRow-1, 20 ssay "D" color "I"
@ nMaxRow-1, 30 ssay "M" color "I"
@ nMaxRow-1, 38 ssay "R" color "I"
@ nMaxRow-1, 56 ssay "N" color "I"
@ nMaxRow-1, 65 ssay "Esc" color "I"

//ÄÄÄÄÄ draw arrows for mouse usage
#ifdef MOUSE

@ oBrowse:nBottom+1, oBrowse:nLeft-1  say chr(27) color "I"
@ oBrowse:nBottom+1, oBrowse:nRight   say chr(26) color "I"
@ oBrowse:nBottom+1, oBrowse:nRight+1 say chr(25) color "I"
@ oBrowse:nTop-1,    oBrowse:nRight+1 say chr(24) color "I"

#endif

while key <> K_ESC
   while ( key := inkey() ) == 0 .and. ! oBrowse:stabilize()
   end
   if lNewDay
      key := asc("A")    // force immediate Add mode below
   elseif key == 0
      key := ginkey(0, "KEY")
   endif
   //ÄÄÄÄÄ deal with the keypress

   #ifdef MOUSE
   do case
      case key == K_RIGHT_DOWN
         key := K_ESC

      case key == K_LEFT_DOWN .or. key == K_LEFT_DBLCLICK
         nMRow := LastRow()
         nMCol := LastCol()

         if nMRow >= oBrowse:nTop  .and. nMRow <= oBrowse:nBottom .and. ;
            nMCol >= oBrowse:nLeft .and. nMCol <= oBrowse:nRight
            oBrowse:rowPos := nMRow - oBrowse:nTop - 1
            oBrowse:refreshAll()
         else
            aPos := getmousepos()
            do case
               //ÄÄÄÄÄ did they click on the up arrow?
               case aPos[1] == oBrowse:nTop-1 .and. aPos[2] == oBrowse:nRight+1
                  key := K_PGUP
               //ÄÄÄÄÄ did they click on the down arrow?
               case aPos[1] == oBrowse:nBottom+1 .and. aPos[2] == oBrowse:nRight+1
                  key := K_PGDN
               //ÄÄÄÄÄ did they click on the left arrow?
               case aPos[1] == oBrowse:nBottom+1 .and. aPos[2] == oBrowse:nLeft-1
                  if oBrowse:leftVisible == oBrowse:freeze + 1
                     key := K_LEFT
                  else
                     key := K_CTRL_LEFT
                  endif
               //ÄÄÄÄÄ did they click on the right arrow?
               case aPos[1] == oBrowse:nBottom+1 .and. aPos[2] == oBrowse:nRight
                  if oBrowse:rightVisible == oBrowse:colCount
                     key := K_RIGHT
                  else
                     key := K_CTRL_RIGHT
                  endif
               otherwise
                  aeval( aHotSpots, {| a | iif( nMRow == a[ 1 ] .and. ;
                                                nMCol >= a[ 2 ] .and. ;
                                                nMCol <= a[ 3 ],      ;
                                                key := a[ 4 ], )} )
            endcase
         endif
   endcase
   #endif

   do case
      case key == K_UP
         oBrowse:up()
      case key == K_LEFT
         oBrowse:left()
      case key == K_RIGHT
         oBrowse:right()
      case key == K_DOWN
         oBrowse:down()
      case key == K_CTRL_PGUP
         oBrowse:goTop()
      case key == K_CTRL_PGDN
         oBrowse:goBottom()
      case key == K_PGUP .or. key == K_HOME
         oBrowse:pageUp()
      case key == K_PGDN .or. key == K_END
         oBrowse:pageDown()
      case key == K_ESC
         //ÄÄÄÄÄ if we forced an exit because they deleted or moved the
         //ÄÄÄÄÄ final appointment for this date, we must be sure to
         //ÄÄÄÄÄ return .T. to the calling routine so that the calendar
         //ÄÄÄÄÄ box will be redrawn
         if appt->date <> tdate
            ret_val := .t.
         endif
      case key == 68 .or. key == 100             // Delete
         IF Yes_No('This appointment will be deleted', 'Continue')
            Lock_Appt(.T.)
         ENDIF
         oBrowse:refreshAll()
      case key == 65 .or. key == 97              // Add Record
         if Appt_Maint('A', lNewDay)
            oBrowse:refreshAll()
         endif
         lNewDay := .f.
      case key == 77 .or. key == 109            // Move appt
         ColorSet(C_MESSAGE)
         mdate := ctod("")
         buffer_[2] := shadowbox(nMaxRow-3, 26, nMaxRow-1, 53, 2, 'Move appointment')
         @ nMaxRow-2,28 ssay 'Enter new date:'
         @ row(), col() + 1 get mdate
         setcursor(1)
         read
         setcursor(0)
         ByeByeBox(buffer_[2])
         if lastkey() <> K_ESC .and. ! empty(mdate)
            if NoConflict("E", mdate, appt->userid, appt->time, appt->endtime, .f.)
               Lock_Appt(mdate)
               oBrowse:refreshAll()
            endif
         endif
      case key == 69 .or. key == 101   // Edit Record
         Appt_Maint('E')
         oBrowse:refreshAll()   // not just "Current" in case of network apps
      case key == 82 .or. key == 114    // Recurring appt
         Appt_Recur()
         //ÄÄÄÄÄ force a refresh of the calendar screen after we exit
         //ÄÄÄÄÄ the appointment window!
         ret_val := .t.
         oBrowse:refreshAll()
      case key == 78 .or. key == 110    // view notes
         Appt_Notes()
         if lastkey() <> K_ESC
            oBrowse:refreshCurrent()
         endif
   endcase
enddo
ByeByeBox(buffer_[1])
return ret_val

* end static function ViewAppts()
*--------------------------------------------------------------------*


/*
   Function: AwSkipIt()
   Purpose:  Pseudo-filter to only show appts for highlighted day
*/
static function awskipit(nSkipCnt)
local movement := 0
do case
   case nSkipCnt == 0
      skip 0

   case nSkipCnt > 0
      do while movement < nSkipCnt .and. appt->date <= tdate .and. ! eof()
         skip 1
         movement++
      enddo
      //ÄÄÄÄÄ make sure that we are on the right date - if not, back up to it
      do while (appt->date > tdate .or. eof()) .and. ! bof()
         skip -1
         movement--
      enddo
      if bof() .or. appt->date <> tdate   // hey!  no more appts for this date!!
         keyboard chr(K_ESC)
      endif

   case nSkipCnt < 0
      do while movement > nSkipCnt .and. appt->date >= tdate
         skip -1
         if bof()
            exit
         endif
         movement--
      enddo
      //ÄÄÄÄÄ make sure that we are on the right date - if not, move up to it
      do while appt->date < tdate .and. ! eof()
         skip
         movement++
      enddo
      if eof() .or. appt->date <> tdate   // hey!  no more appts for this date!!
         keyboard chr(K_ESC)
      endif

endcase
return movement

* end static function AwSkipIt()
*--------------------------------------------------------------------*


/*
   Function: LOCK_APPT()  -- used for moving and deleting appts
*/
static function lock_appt(mdate)
if rlock()
   if valtype(mdate) = "D"
      replace appt->date with mdate
   else                      // kill it
      delete
      skip
   endif
   unlock
else
   err_msg( { NETERR_MSG } )
endif
return nil

* end static function Lock_Appt()
*--------------------------------------------------------------------*


/*
   Function: APPT_MAINT
*/
static function Appt_Maint(mode, lNewDay)
local oldscrn
local muserid
local mtime
local mendtime
local mbrief
local ret_val := .t.
local cur_row
local mstart := "  :  "
local app_ok
local getlist := {}
gfsaveenv( { maxrow() - 2, 00, maxrow(), maxcol() } )
default lNewDay to .f.
cur_row := if(lNewDay, 18, row() )
muserid  := if(mode == 'A', space(8), appt->userid)
mtime    := if(mode == 'A', mstart, appt->time)
mendtime := if(mode == 'A', mstart, appt->endtime)
mbrief   := if(mode == 'A', space(50), appt->brief)
ColorSet(C_CALENDAR)
scroll(22, 00, 24, 79, 0)
@ 23,24 ssay 'save edits'
@ 23,44 ssay 'exit without saving'
@ 23,17 ssay 'Ctrl-W' color 'I'
@ 23,40 ssay 'Esc' color 'I'
setcolor('+w/bg,i')
oldscrn := shadowbox(cur_row - 1, 1, cur_row + 1, maxcol() - 2, 4)
@ cur_row,  3 get muserid picture '@!' valid ! empty(muserid)
@ cur_row,  12 get mtime picture '##:##' ;
      valid val(substr(mtime,1,2)) < 24 .and. val(substr(mtime,4)) < 60
@ cur_row, 18 get mendtime picture '##:##' valid mendtime == mstart .or. ;
      (val(substr(mendtime,1,2)) < 24 .and. val(substr(mendtime,4)) < 60 .and. ;
      mendtime >= mtime) .or. lastkey() == K_UP
@ cur_row, 24 get mbrief
setcursor(1)
read
setcursor(0)
if (lastkey() <> K_ESC .and. (val(mtime)>0 .or. ! empty(mbrief))) .and. ;
                         noconflict(mode, tdate, muserid, mtime, mendtime, .f.)
   if mode == 'A'      // adding record
      append blank
      app_ok := ! neterr()
   else
      app_ok := rlock()
   endif
   if app_ok
      //ÄÄÄÄÄ note that if user left ending time blank, we will replace it
      //ÄÄÄÄÄ with the starting time
      replace appt->date with tdate, appt->time with mtime, ;
              appt->brief with mbrief, ;
              appt->endtime with if(mendtime == mstart, mtime, mendtime), ;
              appt->userid with muserid
   else
      err_msg( { NETERR_MSG } )
   endif
   unlock
elseif lNewDay
   //ÄÄÄÄÄ what this means is that either the user escaped without adding an
   //ÄÄÄÄÄ appt for a new day -- we must then bust out back to the calendar
   //ÄÄÄÄÄ window upon returning to the TBROWSE() section above
   ret_val := ! lNewDay
   if ! ret_val
     keyboard chr(K_ESC)
   endif
endif
byebyebox(oldscrn)
gfrestenv()
return ret_val

* end static function Appt_Maint()
*--------------------------------------------------------------------*


/*
   Function: Appt_Recur()
   Calls: Appt_CDate()
        : MextMonth()    (function in CALENDAR.PRG)
*/
static function Appt_Recur
local end
local start
local curr_area
local mdom := Appt_Dom(tdate)
local mmonth
local sel
local getlist := {}
local cTime
local cEndtime
local cBrief
local cUserid
local lOldConfirm
//ÄÄÄÄÄ we only need the 6th option if current day is, in fact, a weekday
local choices := {'Every ' + gfday(tdate), ;
                  'Every other ' + gfday(tdate), ;
                  'Every ' + appt_cdate(day(tdate)) + ' of the month', ;
                  'Every day', ;
                  'Every ' + appt_cdate(mdom) + ' ' + gfday(tdate) }
gfsaveenv(.t.)
if dow(tdate) > 1 .and. dow(tdate) < 7
   aadd(choices, 'Every weekday')
endif
colorset(C_MESSAGE)
sel := apick(16, 48, 17 + len(choices), 72, choices,,,,,,,,,,,'Recurring Appt')
if sel > 0
   ColorSet(C_CALENDAR)
   shadowbox(18, 49, 21, 71, 2)
   setcolor('+' + setcolor())
   end := tdate
   lOldConfirm := set(_SET_CONFIRM, .t.)
   @ 19,50 ssay 'Ending date:'
   @ 20,50 ssay '(Press Enter to add)'
   @ 19, 63 get end picture '@d' valid end >= tdate
   setcursor(1)
   read
   setcursor(0)
   set(_SET_CONFIRM, lOldConfirm)
   if lastkey() <> K_ESC
      cTime    := appt->time
      cEndtime := appt->endtime
      cBrief   := appt->brief
      cUserid  := appt->userid
      waiton('Adding recurring appointments... please wait')
      start := tdate
      do while start <= end
         if start <> tdate // no need to add it again for the starting date!
            if noconflict("A", start, appt->userid, appt->time, appt->endtime, .t.)
               dbappend()
               if ! neterr()
                  appt->date    := start
                  appt->time    := cTime
                  appt->endtime := cEndtime
                  appt->brief   := cBrief
                  appt->userid  := cUserid
                  dbunlock()
               else
                  err_msg( { NETERR_MSG } )
               endif
            endif
         endif
         //ÄÄÄÄÄ increment date by appropriate interval
         do case
            case sel == 1 .or. sel == 2
               start += sel * 7
            case sel == 3
               start := nextmonth(start)
            case sel == 4
               start++
            case sel == 5
               start := nextmonth(start)
               do while start <= end
                  //ÄÄÄÄÄ first determine 1st day of next month
                  start := stod(substr(dtos(start), 1, 6) + "01")
                  //ÄÄÄÄÄ go to the correct day of the week
                  do while dow(start) <> dow(tdate)
                     start++
                  enddo
                  //ÄÄÄÄÄ add the appropriate number of weeks
                  mmonth := cmonth(start)
                  start += 7 * (mdom - 1)
                  if cmonth(start) <> mmonth
                     err_msg( { "There is no " + appt_cdate(mdom) + " " + ;
                                cdow(tdate) + " in " + mmonth } )
                  else
                     exit
                  endif
               enddo

            case sel == 6
               start += if(dow(start) < 6, 1, 3)
         endcase
      enddo
      waitoff()
   endif
endif
gfrestenv()
return nil

* end static function Appt_Recur()
*--------------------------------------------------------------------*


/*
   Function: APPT_NOTES()
   Calls: MEMEDIT()      (function in MEMEDIT.PRG)
*/
static function Appt_Notes(editing)
local mcomments
field userid, brief
gfsaveenv( { 16, 00, maxrow(), maxcol() }, 1, '+w/' + if(iscolor(), 'rb', 'n'))
shadowbox(16, 00, maxrow(), maxcol(), 2, 'Notes for ' + trim(userid) + ;
          ' ( ' + trim(brief) + ')', , , 'Ctrl-W to save, Esc to exit')
mcomments := memoedit(appt->comments, 17, 01, maxrow()-1, maxcol()-1, .t., ;
             'memo_udf')
gfrestenv()
#ifdef MOUSE
if lastkey() <> K_ESC .and. lastkey() <> K_RIGHT_DOWN
#else
if lastkey() <> K_ESC
#endif
   if rlock()
      replace appt->comments with mcomments
      unlock
   else
      err_msg( { NETERR_MSG } )
   endif
endif
return nil

* end static function Appt_Notes()
*--------------------------------------------------------------------*


/*
   Function: MEMO_UDF()
*/
function memo_udf(stat, line, col)
local nRetVal := 0
local nCurrentRow := row()
#ifdef MOUSE
if lastkey() == K_ESC .or. lastkey() == K_RIGHT_DOWN
#else
if lastkey() == K_ESC
#endif
   setcursor(0)
   tone(MUSIC_ALERT, 1)
   tone(MUSIC_ALERT, 1)
   ColorSet(C_ERRORMESSAGE)
   shadowbox(nCurrentRow + 2, 29, nCurrentRow + 4, 50, 2)
   @ nCurrentRow + 3, 31 ssay 'Notes not updated!'
   inkey(2)
   nRetVal := 27
endif
return nRetVal

* end function Memo_UDF()
*--------------------------------------------------------------------*


/*
   Function: ApptPrintD()
   Calls: PRINTOK()      (function in PRINTOK.PRG)
        : APPT_HEAD()
*/
static function ApptPrintD(dStart, dEnd)
local nPage := 1
local xx
local nLines
local lNotes := yes_no('Do you want to include notes')
if lastkey() <> K_ESC
   waiton()
   if printok()
      appt_headd(@nPage, dStart, dEnd)
      dbseek(dtos(dStart), .t.)
      do while appt->date >= dStart .and. appt->date <= dEnd
         if prow() > 59
            appt_headd(@nPage, dStart, dEnd)
         endif
         if ! empty(appt->time) .or. ! empty(appt->brief)  // weed out blanks
            @ prow()+2,01  say appt->userid
            @ prow(),  10  say dtoc(appt->date)
            @ prow(),  20  say appt->time
            @ prow(),  27  say appt->endtime
            @ prow(),  34  say substr(appt->brief, 1, 45)
            if lNotes    // print memofield also
               nLines := mlcount(appt->comments, 50)
               for xx := 1 to nLines
                  if prow() > 59
                     appt_headd(@nPage, dStart, dEnd)
                  endif
                  @ prow()+1, 10 say trim(memoline(appt->comments, 50, xx))
               next
            endif
         endif
         skip
      enddo
      eject
   endif
   set device to screen
   waitoff()
endif
return nil

* end static function ApptPrintD()
*--------------------------------------------------------------------*


/*
   Function: Appt_HeadD()
   Heading for appointment report (range of dates)
*/
static function Appt_HeadD(nPage, dStart, dEnd)
@ 0,1 say dtoc(date())
CENTER(0, 'Appointments for ' + dtoc(dStart) + ' through ' + dtoc(dEnd))
@ 0,71 say 'Page ' + ltrim(str(nPage++))
@ prow()+2, 1 say 'Who'
@ prow(),  12 say 'Date'
@ prow(),  20 say 'Start'
@ prow(),  28 say 'End'
@ prow(),  47 say 'Appointment description'
@ prow()+1,01 say '---'
@ prow(),  10 say replicate('-',8)
@ prow(),  20 say replicate('-',5) + '  ' + replicate('-',5)
@ prow(),  34 say replicate('-',45)
return nil

* end static function Appt_HeadD()
*--------------------------------------------------------------------*


/*
   Function: Appt_CDate()
   Returns day # and 'st, th, nd' (e.g., '2nd, 3rd...')
*/
static function Appt_CDate(mday)
local mtag, mtagstr := {'st', 'nd', 'rd'}
if (mday > 3 .and. mday < 21) .or. (mday > 23 .and. mday < 31)
   mtag := 'th'
else
   mtag := mtagstr[mday % 10]
endif
return ltrim(str(mday)) + mtag

* end static function Appt_CDate()
*--------------------------------------------------------------------*


/*
    Function: Appt_Show()
    Displays appointments for highlighted date while in calendar
*/
static function appt_show(lAppts)
local appts := {}, xx, oldcolor
local nMaxRow := maxrow()
if lAppts
   oldcolor := ColorSet(C_CALENDAR)
   shadowbox(15, 02, nMaxRow - 1, 77, 1, 'appointments for ' + dtoc(tdate))
   seek dtos(tdate)
   xx := 16
   do while tdate == appt->date .and. xx < nMaxRow - 1
      @ xx++, 03 ssay appt->userid + ' ' + appt->time + ' - ' + ;
                   appt->endtime + ' ' + appt->brief
      skip
   enddo
   //ÄÄÄÄÄ there are more appointments for this date than can fit on screen!
   if tdate == appt->date
      @ nMaxRow-1, 37 ssay ' more '
   endif
   setcolor(oldcolor)
else
   restscreen(15, 02, nMaxRow, 79, winbuff)
endif
return nil

* end static function Appt_Show()
*--------------------------------------------------------------------*


/*
   Function: GRAB_DATES()
   Get starting and ending date for printing/deleting appts
*/
static function Grab_Dates(msg)
local buffer, aDates := { tdate, tdate }, oldcolor, getlist := {}
oldcolor := ColorSet(C_MESSAGE)
buffer := shadowbox(12, 27, 15, 52, 2, msg + ' appointments')
@ 13,29 ssay 'Starting date: '
@ 14,29 ssay 'Ending date: '
@ 13,44 get STARTDATE
@ 14,44 get ENDDATE valid ENDDATE >= STARTDATE
setcursor(1)
read
setcursor(0)
ByeByeBox(buffer)
return aDates

* end static function Grab_Dates()
*--------------------------------------------------------------------*


/*
   Function: Appt_Day()
   Displays used and available time blocks for highlighted date
*/
static function appt_day
static times[65]
local minutes, xx, yy, zz, nMarker, lastuser, muserid, nKey
local lContinue := .t.
if dbseek( dtos(tdate) )
   gfsaveenv(.t.)
   do while lContinue
      afill(times, 176)
      nMarker := recno()
      yy   := 0
      lastuser := '%^@'
      do while appt->date == tdate .and. ! eof()
         if lastuser <> appt->userid
            yy++
            lastuser := appt->userid
         endif
         skip
      enddo
      ColorSet(C_WAITMESSAGE)
      shadowbox(0, 1, 5+yy, 77, 2, 'Appointment summary for ' + ;
                dtoc(tdate) + ' (' + chr(176) + chr(177) + ;
                ' = available, ' + chr(219) + ' = used)', , , ;
                'Press M to schedule a meeting')
      @ 2, 11 ssay replicate("Ä", 9) + " A.M. " + replicate("Ä", 9) + "ÄÅÄ"
      @ 2, 38 ssay replicate("Ä", 16) + " P.M. " + replicate("Ä", 16)
      @ 3, 11 ssay '6   7   8   9   10  11  12  1   2   3   4   5   6   7   8   9   10'
      @ 4+yy, 11 ssay '6   7   8   9   10  11  12  1   2   3   4   5   6   7   8   9   10'
      goto nMarker
      zz := 0
      dispbegin()
      do while appt->date == tdate .and. ! eof()
         muserid := appt->userid
         zz++
         //ÄÄÄÄÄ we will alternate between two different background characters:
         //ÄÄÄÄÄ (ASCII 176 and 177) so that each person's line is distinct
         afill(times, 176 + (zz % 2))
         do while muserid == appt->userid .and. appt->date == tdate .and. ! eof()
            if val(left(appt->time, 2)) > 5 .and. ;
               val(substr(appt->time, 1, 2)) < 22
               xx := (val(left(appt->time, 2)) - 6) * 4 + 1 + ;
                     int(val(substr(appt->time, 4)) / 15)
               times[xx] := 219
               //ÄÄÄÄÄ determine time differential (in minutes) between
               //ÄÄÄÄÄ starting and ending times for this appointment
               minutes := val(left(appt->endtime,2)) * 60 + ;
                          val(substr(appt->endtime, 4)) - ;
                          val(left(appt->time, 2)) * 60 - ;
                          val(substr(appt->time, 4))
               do while minutes > 15 .and. xx <= 64
                  times[++xx] := 219
                  minutes -= 15
               enddo
            endif
            skip
         enddo
         @ 3 + zz, 2 ssay muserid
         setpos(3 + zz, 11)
         for xx := 1 to 65
             dispout(chr(times[xx]))
         next
      enddo
      dispend()
      nKey := ginkey(0)
      if upper(chr(nKey)) == "M"
         appt_meet(tdate)
         scroll(4, 2, 3 + yy, 76)
         goto nMarker
      else
         lContinue := .f.
      endif
   enddo
   gfrestenv()
endif
return nil

* end static function Appt_Day()
*--------------------------------------------------------------------*


/*
   Function: NoConflict()
   Ensure that this appt is not creating a conflict with time
*/
static function noconflict(mode, mdate, muserid, start, end, recurring)
local ret_val := .t.
local marker := recno()
field date, userid, time, endtime
set order to 2   // make userid primary search field
go top
seek muserid + dtos(mdate)
do while mdate == date .and. userid == muserid .and. ! eof()
   if (mode == 'A' .or. marker <> recno())      .and. ;
       ( (start >= time .and. start < endtime) .or.  ;
       (end > time .and. end <= endtime)       .or.  ;
       (start <= time .and. end >= endtime) )
      ret_val := .f.
      exit
   endif
   skip
enddo
set order to 1   // switch back to date as primary search field
go marker
if ! ret_val
   ret_val := yes_no('This appointment creates a conflict' + ;
                     if(recurring, ' on ' + dtoc(mdate), ''), ;
                     'Do you wish to add it anyway')
endif
return ret_val

* end static function NoConflict()
*--------------------------------------------------------------------*


/*
  Function: Appt_Week()
  Displays summary of morning/afternoon appts for the next week
*/
static function appt_week(masterfile)
local mfile, xx, yy, zz, num_recs, pdate, ndate, mcol := 11, mrow, muserid, ;
      oldcolor, buffer1, buffer2, nWorkArea := select(), times_[12], ;
      mstart, mend, nKey := 0
field userid, date, time, endtime
ColorSet(C_MESSAGE)

// we only want to look at this week, so reset date to monday.
// note: if we are on a Sunday, look at the upcoming week
//       if we are on a Saturday, look at the previous week
pdate := dow(tdate)
if pdate == 1
   pdate := tdate + 1
else
   pdate := tdate - (pdate - 2)
endif

mfile := randfile(masterfile)
copy to (mfile) for appt->date >= pdate .and. appt->date < pdate + 5
use (mfile) new exclusive
pack
if lastrec() > 0
   index on userid to (mfile) unique
   count to num_recs
   index on userid + dtos(date) + time to (mfile)
   go top
   buffer1 := shadowbox(0, 1, 3+num_recs, 77, 1, ;
              'Weekly appointment summary (' + chr(176) + chr(177) + ;
              ' = available, ' + chr(219) + ' = used)', , , ;
              'Press M to schedule a meeting')
   ndate := pdate
   buffer2 := replicate('Í',12)

   for xx = 0 to 4
      @ 1, mcol + (xx * 13) + 1 ssay left(cdow(ndate), 3) + ' ' + ;
                                    str(month(ndate), 2) + '/' + ;
                                    if(day(ndate) < 10, '0', '') + ;
                                    ltrim(str(day(ndate), 2))
      @ 2, mcol + (xx * 13) ssay buffer2
      ndate++

      if dow(ndate) = 1
         ndate++
         mcol += 2
      elseif dow(ndate) = 7
         ndate += 2
         mcol += 2
      endif
   next

   muserid := userid

   for mrow = 1 to num_recs
      if muserid <> userid
         muserid := userid
      endif

      mcol := 11
      zz   := -1
      @ mrow + 2, 2 ssay muserid

      if eof()
         exit
      endif

      for yy = 0 to 6
         if userid <> muserid .or. eof()
            muserid := userid
            exit
         endif
         muserid := userid

         //ÄÄÄÄÄ if we are on a sunday, find the next weekday record and
         //ÄÄÄÄÄ leave an add'l space on screen to denote this break
         if dow(pdate + yy) = 1
            do while date == pdate + yy
               skip
            enddo
            mcol += 2
            loop
         endif

         //ÄÄÄÄÄ if we are on a saturday, find the next weekday record
         if dow(pdate + yy) = 7
            do while date = pdate + yy
               skip
            enddo
            loop
         endif
         zz++
         //ÄÄÄÄÄ again, alternate between two different background characters
         //ÄÄÄÄÄ (ascii 176 and 177) so that each person's line is distinct
         afill(times_, 176 + (mrow % 2))
         if date = pdate + yy
            do while date = pdate + yy .and. ;
                     muserid = userid .and. ! eof()
               if val(left(time, 2)) > 5
                  mstart := val(left(time, 2)) - 5
                  //ÄÄÄÄÄ the min() function ensures that we won't blow up
                  //ÄÄÄÄÄ our array with a subscript greater than 12
                  mend := min(val(left(endtime, 2)) - 5, 12)
                  for xx = mstart to mend
                     times_[xx] := 219
                  next
               endif
               skip
            enddo
            dispbegin()
            setpos(mrow + 2, mcol + zz * 13)
            aeval(times_, { | hour | qqout(chr(hour)) })
            dispend()
         endif
      next
   next
   setcolor(oldcolor)
   use
   nKey := ginkey(0)
   byebyebox(buffer1)
else
   Err_Msg( { "No appointments for the week of " + dtoc(pdate) + " - " + ;
              dtoc(pdate + 4) } )
endif
ferase(mfile + '.dbf')
ferase(mfile + '.dbt')
ferase(mfile + indexext())
select(nWorkArea)
if upper(chr(nKey)) == "M"
   appt_meet(tdate)
endif
return nil

* end static function Appt_Week()
*--------------------------------------------------------------------*


/*
   Function: ApptPrintW()
   Calls: PRINTOK()      (function in PRINTOK.PRG)
        : APPT_HEAD()
*/
static function apptprintw()
local page, xx, buffer, muserid := padr("ALL", 8), mfile, n, d, num_recs, ;
      mstart := tdate - (dow(tdate) - 2), nWorkArea, mdbf, mcol, mdate,     ;
      maxrow, aday, arow, mbrief, puserid, adata[150], getlist := {}
field userid, date, time, endtime, brief
ColorSet(C_MESSAGE)
buffer := shadowbox(12, 28, 14, 51, 2)
@ 13, 30 ssay 'Print for:'
@ row(), col() + 1 get muserid picture "@!" valid ! empty(muserid)
setcursor(1)
read
setcursor(0)
ByeByeBox(buffer)
if lastkey() <> K_ESC
   waiton()
   mdbf := randfile("appt")
   nWorkArea = select()
   mcol := 11
   if muserid = 'ALL'
      copy to (mdbf) for appt->date >= mstart .and. appt->date < mstart + 5
   else
      copy to (mdbf) for appt->date >= mstart .and. appt->date < mstart + 5 ;
                               .and. appt->userid == muserid
   endif
   use (mdbf) new exclusive
   pack
   if lastrec() = 0
      err_msg( { 'No records found!' } )
   else
      index on userid to (mdbf) unique
      count to num_recs
      index on userid + dtos(date) + time to (mdbf)
      go top
      if printok()
         page := maxrow := 0
         Appt_HeadW(@page, mstart)
         arow := 7
         for xx = 1 to num_recs
            muserid := userid
            maxrow := 0
            afill (adata,space(13))
            do while muserid == userid .and. ! eof()
               mdate := date
               d     := 1
               aday  := dow(date) - 1
               adata[aday] = ' ' + time + '-' + endtime
               do while mdate = date .and. ;
                        muserid = userid .and. ! eof()
                  mbrief := brief
                  adata[++d * 5 - (5-aday)] = substr(mbrief, 1, 13)
                  skip
                  if mdate = date .and. muserid == userid
                     adata[++d * 5 - (5-aday)] := replicate('Ä',13)
                     adata[++d * 5 - (5-aday)] := ' ' + time + '-' + endtime
                  endif
               enddo
               maxrow := max(maxrow, d)
            enddo
            @ arow,0 say 'º' + muserid + 'º'
            for n = 1 to 5
               @ arow, (n * 14) - 4 say adata[n]
               if n < 5
                  @ arow, (n * 14) + 9 say '³'
               endif
            next
            puserid := 'º' + space(8) + 'º'
            for n = 6 to (maxrow * 5)
               d = n % 5
               if d = 0
                  d = 5
               endif
               if d = 1
                  @ arow, 79 say 'º'
                  arow++
                  if arow > 56
                     Appt_HeadW(@page, mstart)
                     arow := 7
                     puserid := 'º  ' + muserid + '   º'
                  endif
                  @ arow,0 say puserid
                  puserid := 'º' + space(8) + 'º'
               else
                  @ arow,(d*14)-5 say '³'
               endif
               @ arow,(d*14)-4 say left(adata[n], 13)
            next
            @ arow, 79 say 'º'
            arow++
            if xx < num_recs .and. ! eof()
               if arow > 52
                  Appt_HeadW(@page, mstart)
                  arow := 7
               else
                  @ arow++,0 say 'ÌÍÍÍÍÍÍÍÍÎ' + replicate('ÍÍÍÍÍÍÍÍÍÍÍÍÍØ',4) ;
                                 + 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ¹'
               endif
            endif
         next
         @ arow,0 say 'ÈÍÍÍÍÍÍÍÍÊ' + replicate('ÍÍÍÍÍÍÍÍÍÍÍÍÍÏ',4) + ;
                      'ÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
         eject
      endif
      set device to screen
   endif
   waitoff()
   use
   select(nWorkArea)
   ferase(mdbf + '.dbf')
   ferase(mdbf + '.dbt')
   ferase(mdbf + indexext())
endif
return nil

* end static function Appt_PrintW()
*--------------------------------------------------------------------*


/*
   Function: Appt_HeadW()
   Heading for appointment report (weekly)
*/
static function appt_headw(page, mstart)
local xx
if page > 0
   @ row(),0 say 'ÈÍÍÍÍÍÍÍÍÊ' + replicate('ÍÍÍÍÍÍÍÍÍÍÍÍÍÏ',4) + 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
   eject
endif
@ 1, 1 say dtoc(date())
CENTER(1, 'Appointments for ' + dtoc(mstart) + ' through ' + dtoc(mstart + 4))
@ 1,73 say 'page ' + ltrim(str(++page))
@ 4, 0 say 'ÉÍÍÍÍÍÍÍÍË' + replicate('ÍÍÍÍÍÍÍÍÍÍÍÍÍÑ',4) + 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
@ 5, 0 say 'º Emp ID º'
for xx = 1 to 5
   @ 5, xx * 14 - 3 say left(gfday(mstart + xx - 1), 3) + '-'
   @ 5, xx * 14 + 2 say str(day(mstart + xx - 1), 2) + ' ' + ;
                       left(gfmonth(mstart + xx - 1), 3)
   if xx < 5
      @ 5, xx * 14 + 9 say '³'
   endif
next
@ 5, 79 say 'º'
@ 6,  0 say 'ÌÍÍÍÍÍÍÍÍÎ' + replicate('ÍÍÍÍÍÍÍÍÍÍÍÍÍØ',4) + 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ¹'
return nil

* end static function Appt_HeadW()
*--------------------------------------------------------------------*


/*
   Function: Appt_Meet()
   Schedule a meeting
*/
static function appt_meet(dDate)
local getlist:={}
local cStart := "00:00"
local cEnd   := "00:00"
local cDescrip := space(50)
local cUser
local nUsers := 0
local aUsers := {}
local x
local lOk
local lContinue
field date, userid, time, endtime, brief
default dDate to ctod('')
gfsaveenv(.t., , '+gr/n')
shadowbox(0, 6, 3, 73, 2, 'Schedule Meeting')
@ 1, 8 ssay 'Date:'
@ 1,29 ssay 'Start time:'
@ 1,54 ssay 'Ending time:'
@ 2, 8 ssay 'Description:'
@ 1,14 get dDate
@ 1,42 get cStart picture "##:##" valid val(substr(cStart,1,2)) < 24 .and. ;
                                        val(substr(cStart,4)) < 60
@ 1,67 get cEnd picture "##:##" valid ( val(substr(cEnd,1,2)) < 24 .and. ;
                                      val(substr(cEnd,4)) < 60   .and. ;
                                      cEnd >= cStart ) .or. lastkey() == K_UP
@ 2,21 get cDescrip
setcursor(1)
read
if lastkey() <> K_ESC .and. ! empty(dDate) .and. ! empty(cDescrip) .and. ;
                            ( cStart <> "00:00" .or. cEnd <> "00:00" )
   shadowbox(6, 30, 8, 49, 2, 'Add User')
   shadowbox(11, 35, 23, 44, 2, 'Users')
   lContinue := .t.
   do while lContinue
      cUser := "<DONE>  "
      @ 7, 32 ssay 'User ID:'
      @ 7, 41 get cUser picture '@K@!' valid ! empty(cUser) .and. ;
                  CheckUser(aUsers, dDate, cStart, cEnd)
      read
      lContinue := ( lastkey() <> K_ESC ) .and. trim(cUser) <> "<DONE>"
      if lContinue
         aadd(aUsers, cUser)
         @ ++nUsers + 11, 36 say cUser
      elseif empty(aUsers)
         lContinue := ! Yes_No("Are you sure you want to abort this process")
      endif
   enddo
endif
if nUsers > 0
   waiton('Adding appointments... please wait')
   for x := 1 to nUsers
      append blank
      if ! neterr()
         date := dDate
         time := cStart
         endtime := cEnd
         brief := cDescrip
         userid := aUsers[x]
         unlock
      else
         err_msg( { NETERR_MSG } )
      endif
   next
   waitoff()
endif
gfrestenv()
return nil

* end static function Appt_Meet()
*--------------------------------------------------------------------*


/*
    Function: CheckUser()
    Purpose:  Validation for user selection when scheduling meeting
*/
static function checkuser(aUsers, dDate, cStart, cEnd)
local oGet := getactive()
local cUser := oGet:varGet()
local lRetVal := .f.
if ascan(aUsers, cUser) > 0
   err_msg( { "This user has already been selected" } )
   oGet:varPut("<DONE>  ")   // reset get value
else
   lRetVal := NoConflict("A", dDate, cUser, cStart, cEnd, .f.)
endif
return lRetVal

* end static function CheckUser()
*--------------------------------------------------------------------*


/*
    Function: Appt_Dom()
    Determine which day of month, e.g., 2nd Monday, 3rd Tuesday, etc
*/
static function Appt_Dom(mdate)
local mday := cdow(mdate), ret_val := 0, mmonth := month(mdate)
do while month(mdate) == mmonth
   mdate -= 7
   ret_val++
enddo
return ret_val

* end static function Appt_Dom()
*--------------------------------------------------------------------*

* eof popdate.prg
