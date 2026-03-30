
// O R I G I N A L  R O O M T I M E  A V A I L A B I L I T Y  V I E W E R

static function xproomtimeavail(cterm,cdesc,room1,room2)
local abtext := {},ncol,nmaxcol := 80, npage := 0, nctr := 0, afile,;
      cdayx,lused:=.f.,nctr1:=0
local num1, num2, xbegtime, xendtime, lapse, counter, daycounter, element
local dayz := {"Monday     ", ;
               "Tuesday    ", ;
               "Wednesday  ", ;
               "Thursday   ", ;
               "Friday     ", ;
               "Saturday   "}

fask(10,"   Initializing File(s)...   ",{" Ok "},memvar->colorarray[06],.f.,nil)
if ! createdummy(memvar->cdummy+"D",{{"RMNO"        ,"C",04,0},;
                                     {"DayNum"      ,"C",01,0},;
                                     {"RMTIME"      ,"C",31,0}},{||cdxromtime()}) .or. ;
   ! createdummy(memvar->cdummy+"H",{{"RMNO"        ,"C",04,0},;
                                     {"Desc"        ,"C",15,0}},{||cdxromtimh()})
        dbcloseall()
        return(nil)
endif
memvar->header := memvar->cdummy+"H"
memvar->detail := memvar->cdummy+"D"
if(afile := openwcheck({{,,(memvar->header+".TXT"),"header",_DBF_EXCLUSIVE,,1},;
                        {,,(memvar->detail+".TXT"),"detail",_DBF_EXCLUSIVE,,1}})) == nil
        dbcloseall()
        return(nil)
endif
header->(__dbzap());header->(dbreindex())
detail->(__dbzap());detail->(dbreindex())
ncol := titlepos(alltrim(memvar->ccompanyname),nmaxcol)
aadd(abtext,{||chr(27)+"Date: "+displaydate(date())+space(ncol-16)+alltrim(memvar->ccompanyname)+space(nmaxcol-ncol-len(alltrim(memvar->ccompanyname))-10)+"Page "+str(++npage,3)})
aadd(abtext,{||"Time: "+Time()+space(titlepos("MARITIME EDUCATION AND TRAINING CENTER",nmaxcol)-14)+;
                                              "MARITIME EDUCATION AND TRAINING CENTER"})
aadd(abtext,{||space(titlepos("ROOM SCHEDULE AVAILABILITY",nmaxcol))+;
                              "ROOM SCHEDULE AVAILABILITY"})
aadd(abtext,{||space(titlepos(alltrim(cdesc),nmaxcol))+alltrim(cdesc)})
aadd(abtext,{||""})
aadd(abtext,{||replicate("-",140)})
aadd(abtext,{||""})

*-----------------------
* Set Scope for Room No.
*-----------------------

if (len(alltrim(room1)) + len(alltrim(room1))) > 0
   if len(alltrim(room1)) > 0
      if len(alltrim(room2)) == 0
         room2 := room1
      endif
      cyytskdp->(sx_setscope(_TOP_SCOPE   ,room1))
      cyytskdp->(sx_setscope(_BOTTOM_SCOPE,room2))
   endif
endif

cyytskdp->(dbgotop())

do while ! cyytskdp->(eof())
   fask(10,"  Gathering Information for Room No. "+cyytskdp->skdrom+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   if (c999room->(dbseek(cyytskdp->skdrom))) .and. !(c999room->status $ "LM")
       for daycounter := 1 to 6
           if substr(cyytskdp->skddayx,daycounter,1) =="X"
               num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
               num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
               xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
               xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
               lapse := (xendtime - xbegtime)/0.5

               if ! detail->(dbseek(cyytskdp->skdrom+transform(daycounter,"9")))
                   detail->(dbappend())
                   detail->rmno := cyytskdp->skdrom
                   detail->daynum := transform(daycounter,"9")
                   detail->rmtime := space(31)
                   if ! header->(dbseek(cyytskdp->skdrom))
                        header->(dbappend())
                        header->rmno := cyytskdp->skdrom
                        header->desc := c999room->type
                   endif
               else
                   detail->(reclock())
               endif
               for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
                   if substr(detail->rmtime,counter+1,1) != "Ü"
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"Ü")
                   else
                      detail->rmtime := stuff(detail->rmtime,counter+1,1,"*")
                   endif
               next counter
               detail->(dbcommit())
               detail->(dbunlock())
               if nextkey() == K_ESC
                       exit
               endif
           endif
       next daycounter
   endif
   cyytskdp->(dbskip())
enddo

cyytskdp->(clearscope())

** Printing Data **
element := 0
pageprint(abtext)
//header->(dbgotop())
c999room->(dbgotop())
//do while ! header->(eof())
do while ! c999room->(eof())
   fask(10,"  Printing Room No. "+c999room->roomno+"  ",{" Ok "},memvar->colorarray[06],.f.,nil)
   detail->(sx_settagorder(2))
//   if detail->(c999room->roomno)
   if ! c999room->status $ "LM"
        if empty(c999room->type)
           outexpr(prow()+01,00,c999room->roomno)
        else
           outexpr(prow()+01,00,c999room->roomno + " ==> " + c999room->type)
        endif
        outexpr(prow()+01,00,   "                          1 1 1                   1")
        outexpr(prow()+01,00,   "                    7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0")
        detail->(sx_settagorder(1))
        detail->(sx_setscope(_TOP_SCOPE   ,c999room->roomno))
        detail->(sx_setscope(_BOTTOM_SCOPE,c999room->roomno))
        for daycounter := 1 to 6
           if detail->(dbseek(c999room->roomno+transform(daycounter,"9")))
              outexpr(prow()+01,00,"      "+dayz[daycounter]+"   "+detail->rmtime)
           else
              outexpr(prow()+01,00,"      "+dayz[daycounter])
           endif
        next daycounter
        detail->(clearscope())
        if (element += 1) == 5
           outexpr(prow()+01,00,chr(12)+chr(13))
           pageprint(abtext)
           element := 0
        else
           outexpr(prow()+01,00,"")
        endif
   endif
//   header->(dbskip())
   c999room->(dbskip())
enddo
__eject()
closewcheck(afile)
return(nil)

