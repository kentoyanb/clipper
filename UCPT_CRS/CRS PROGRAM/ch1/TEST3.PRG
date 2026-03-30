 # DEFINE LINES_18    chr(27) + 'C' + chr(10)
 # DEFINE LINES_88    chr(27) + 'C' + chr(88)

 Function test3()
    Local i := 0
    Local x := 1
    set device to printer
    
0,0 say LINES_88
    @ 0,0 say LINES_18
    setprc(0,0)
     For i := 1 to 50
       @ x,10 say i
      if i % 10 == 0
         x :=1
         eject
         setprc(0,0)
      endif
      x++
     Next
    @ 0,0 say LINES_18
 Return Nil

 
