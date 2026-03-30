
do while ! cyytskdp->(eof())
   if (c999room->(dbseek(cyytskdp->skdrom))) .and. (c999room->status != "M") .and. ;
       substr(cyytskdp->skddayx,1,1) =="X"
       num1 := val(left(str(cyytskdp->skdbegtimx),len(str(cyytskdp->skdbegtimx))-1))
       num2 := val(left(str(cyytskdp->skdendtimx),len(str(cyytskdp->skdendtimx))-1))
       xbegtime := val(left(str(num1),len(str(num1))-1)) + (val(right(str(num1),1))/6)
       xendtime := val(left(str(num2),len(str(num2))-1)) + (val(right(str(num2),1))/6)
       lapse := (xendtime - xbegtime)/0.5

       if ! roomfile->(dbseek(cyytskdp->skdrom))
           roomfile->(dbappend())
           roomfile->rmno := cyytskdp->skdrom
           roomfile->desc := c999room->type
           roomfile->rmtime := space(31)
       else
           roomfile->(reclock())
       endif
       for counter := ((xbegtime-7)*2) to (((xbegtime-7)*2)+lapse-1)
           roomfile->rmtime := stuff(roomfile->rmtime,counter+1,1,"X")
       next counter
       roomfile->(dbcommit())
       roomfile->(dbunlock())
       if nextkey() == K_ESC
               exit
       endif
   endif
   cyytskdp->(dbskip())
enddo

