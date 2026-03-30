// # include "sixcdx.ch"

 Function Test1()

 Local sm1p  := "f:\metc\crunlib\c999sm1p.dbf"
 Local sm1pi := "f:\metc\crunlib\c999sm1p.cdx"
 Local info  := {}

 RDDSETDEFAULT("DBFCDX")
 request DBFCDX


 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)

 set order to tag c999sm13
 sm1p->(dbgotop())

 do while !eof()
  ? sm1p->sm1colcod+' '+str(sm1p->sm1yrlevl)+' '+sm1p->sm1idno+' '+sm1p->sm1lstnam+' '+sm1p->sm1fstnam+' '+sm1p->sm1midnam
   skip
   loop
 enddo
 sm1p->(dbclosearea())

 Return Nil



