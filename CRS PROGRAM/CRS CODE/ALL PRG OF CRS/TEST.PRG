function main
local begtime, endtime, num1, num2, xbegtime, xendtime, counter, lapse
local timez := "                               "
begtime := 1731
endtime := 1831
cls
num1 := val(left(str(begtime),len(str(begtime))-1))
num2 := val(left(str(endtime),len(str(endtime))-1))
xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1)) / 6)
xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1)) / 6)

lapse := (xendtime - xbegtime) / 0.5

for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
    timez := stuff(timez,counter+1,1,"X")
next counter

@ 6, 2 say endtime
@ 7, 2 say begtime
@ 8, 2 say  "      1 1 1                   1"
@ 9, 2 say  "7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0"
@ 10, 2 say  timez
return nil
