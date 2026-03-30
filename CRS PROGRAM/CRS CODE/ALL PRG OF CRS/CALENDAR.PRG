/*
  Program: CALENDAR.PRG
  System: GRUMPFISH LIBRARY
  Author: Greg Lief
  Copyright (c) 1988-93, Greg Lief
  CA-Clipper 5.x Version
  Compile instructions: clipper calendar /n /w

  Procs & Fncts: CALENDBOX()
               : NEXTMONTH()

  NOT FOR USE AS STAND-ALONE!!  CALLED BY GETDATE() and POPDATE
*/

/*
   Function: CALENDBOX

   Called by: POPDATE      (procedure in POPDATE.PRG)
              GETDATE()    (function  in GETDATE.PRG)

   Notes: Manipulates DateCoords array, which stores row and column
          coordinates for the first, last, current, and system dates
*/

#define GRUMP_CALENDAR   // see GRUMP.CH
#include "grump.ch"

function calendbox(lUseAppts, nTop, nLeft, dCurrent, cMainColor, lFirstLoop, ;
                   datecoords)
static calendscrn
local lHasAppts
local lHaveLastDay
local cHeading
local tdate
local tmonth
local nRow := 5
local nWorkArea
local lHolidays := select("holidays") <> 0
default lFirstLoop to .f.
if lFirstLoop
   ColorSet(cMainColor)
   shadowbox(nTop, nLeft, nTop+12, nLeft+21, 1)
   @ nTop +  3, nLeft +  1 ssay "Su Mo Tu We Th Fr Sa"
   @ nTop +  1, nLeft + 21 ssay "º"
   @ nTop +  2, nLeft      ssay "Ì" + replicate("Í",20) + "¹"
   @ nTop +  4, nLeft      ssay "Ì" + replicate("Í",20) + "¹"
   @ nTop + 12, nLeft      ssay "È" + replicate("Í",20) + "¼"
   calendscrn := savescreen(nTop, nLeft, nTop+13, nLeft+23)
else
   restscreen(nTop, nLeft, nTop+13, nLeft+23, calendscrn)
endif
setcolor('+' + cMainColor)
cHeading := gfmonth(dCurrent) + ' ' + str(year(dCurrent), 4)
if len(cHeading) < 14
   cHeading := space((14 - len(cHeading)) / 2) + cHeading + ;
               space((14 - len(cHeading)) / 2 + 1)
endif
@ nTop + 1, nLeft + 4 ssay cHeading
tdate := dCurrent
tdate := stod(substr(dtos(tdate), 1, 6) + '01')  // 1st day of month
tmonth := month(tdate)
lHaveLastDay := .f.   // flag for storing coordinates of last day of month
CURRENTAPPTS := .f.
do while .t.
   lHasAppts := .f.  // flag for whether a date should be shown in inverse
   // test for new week
   if (day(tdate) > 1 .or. month(tdate) <> tmonth) .and. dow(tdate) = 1
      nRow++
   endif
   if nRow > 11
      exit
   endif
   // no need to seek for appointments for current date unless we are
   // using the appointment tracker
   if lUseAppts
      if dbseek( dtos(tdate) )
         lHasAppts := .t.
         //ÄÄÄÄÄ set flag true if this date is the current date
         //ÄÄÄÄÄ so that we know to display its appts in draw_appts
         if tdate == dCurrent
            CURRENTAPPTS := .t.
         endif
      endif
   endif
   do case
      case lUseAppts .and. lHasAppts
         setcolor(if(tdate == dCurrent, '*n/w', 'i'))
      case lHolidays .and. holidays->( dbseek(tdate) )
         setcolor(if(tdate == dCurrent, '*+', '') + 'w/r')
      case month(tdate) == month(dCurrent)
         setcolor(if(tdate == dCurrent, '*', '') + '+' + cMainColor)
      otherwise
         ColorSet(cMainColor)
   endcase
   @ nTop+nRow, nLeft + (dow(tdate) - 1) * 3 + 1 ssay str(day(tdate), 2)
   do case

      //ÄÄÄÄÄ first day of month
      case day(tdate) == 1 .and. month(tdate) == tmonth
         FIRSTDAY_ROW := row()
         FIRSTDAY_COL := col() - 2

      //ÄÄÄÄÄ last day of month
      case month(tdate + 1) <> tmonth  .and. ! lHaveLastDay
         LASTDAY_ROW := row()
         LASTDAY_COL := col() - 2
         LASTDAY_NUMBER := day(tdate)
         lHaveLastDay := .t.
   endcase

   //ÄÄÄÄÄ current day
   if tdate == dCurrent
      CURRENTDAY_ROW := row()
      CURRENTDAY_COL := col()-2
   endif

   //ÄÄÄÄÄ system date
   if tdate == date()
      SYSTEMDATE_ROW := row()
      SYSTEMDATE_COL := col()-2
   endif
   tdate++     // increment date counter
enddo
ColorSet(cMainColor)
return nil

* end function CalendBox()
*--------------------------------------------------------------------*


/*
   Function: NEXTMONTH()

   Purpose:  Validate date when skipping forward one month, i.e.,
             cannot go from March 31 to April 31, etcetera

   Called by: GETDATE()
            : POPDATE        (procedure in POPDATE.PRG)
            : RECURRING      (procedure in POPDATE.PRG)
*/
function nextmonth(dOriginal)
local dRetVal := ctod('')
if month(dOriginal) == 12    // going to January of next year
   dRetVal := stod(str(val(substr(dtos(dOriginal), 1, 4)) + 1, 4) + '01' + ;
              substr(dtos(dOriginal), 7))
else
   do while empty(dRetVal)
      dRetVal := stod(substr(dtos(dOriginal), 1, 4) + ;
                 if(month(dOriginal) < 9, '0', '') + ;
                 ltrim(str(month(dOriginal) + 1)) + substr(dtos(dOriginal), 7))
      dOriginal--
   enddo
endif
return dRetVal

* end function NextMonth()
*--------------------------------------------------------------------*

* eof calendar.prg
