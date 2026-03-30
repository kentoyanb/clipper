# include "box.ch"
# include "inkey.ch"
# include "setcurs.ch"

/*---------------------------------------------------------------------------*/
Function search_studno(studno,stud_stat)
Local Retval :=  .F.
       Do Case
          Case _1search(studno,stud_stat) == .T. // short term
                 Retval := .T.
          Case _2search(studno,stud_stat) == .T. // basic ed
                 Retval := .T.
          Case _3search(studno,stud_stat) == .T. // uclm college
                 Retval := .T.
          Case _4search(studno,stud_stat) == .T. // metc college
                 Retval := .T.
          Otherwise
                 Retval := .F.
       Endcase
Return Retval
/*---------------------------------------------------------------------------*/


Function _1search(studno,stud_stat)
Local Retval := .F.
Local stmast  := "F:\crunlib\short\stmast.dbf"
Local stmasti := "F:\crunlib\short\cdx\stmast.cdx"


// Search at Short Term Master Files
     dbusearea(.T.,"DBFCDX",stmast,"stmast",.T.,.F.)
     dbsetindex(stmasti)
     set order to tag tidno
      stmast->(dbgotop())

       If stmast->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(stmast->stud_num)
           stud_stat[02] :=  trim(stmast->stud_last)
           stud_stat[03] :=  trim(stmast->stud_first)
           stud_stat[04] :=  trim(stmast->stud_mid)+'.'
           stud_stat[05] :=  "ST"  // Short Term Code
           stud_stat[06] :=  " "   // Suppose to be Major
           stud_stat[07] :=  " "   // Short Term dont have year level
           stud_stat[08] :=  space(04)
           stud_stat[09] :=  " "   // No Specific Term Description
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
        Endif
  stmast->(dbclosearea())
 Return Retval



Function _2search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\erunlib\e999sm1p.dbf"
Local sm1pi   := "F:\erunlib\cdx\e999sm1p.cdx"


// Search at ELEMENTARY & HIGH SCHOOL MASTER FILE

   dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
   dbsetindex(sm1pi)
   set order to tag tidno
   sm1p->(dbgotop())

          If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1grade)
           stud_stat[06] :=  " "                  // Suppose to be for major
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schyr)
           stud_stat[09] :=  eget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
          Endif
 sm1p->(dbclosearea())
 Return Retval


Function _3search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\crunlib\c999sm1p.dbf"
Local sm1pi   := "F:\crunlib\cdx\c999sm1p.cdx"


// Search at UCLM Master File

   dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
     dbsetindex(sm1pi)
     set order to tag tidno
     sm1p->(dbgotop())

       If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  trim(sm1p->sm1majcod)
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schtrm)
           stud_stat[09] :=  get_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,10 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
       Endif

 sm1p->(dbclosearea())
 Return Retval

Function _4search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\metc\crunlib\c999sm1p.dbf"
Local sm1pi   := "F:\metc\crunlib\c999sm1p.cdx"


// Search at METC Master File
     dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
     dbsetindex(sm1pi)
      set order to tag C999SM11
      sm1p->(dbgotop())
        If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  " "   // Suppose to be Major but METC dont Have
           stud_stat[07] :=  Alltrim(str(sm1p->sm1yrlevl))
           stud_stat[08] :=  transform(str(sm1p->sm1schtrm),"9999")
           stud_stat[09] :=  mget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           @ 14,09 say IF(!empty(stud_stat[02]),PADR(stud_stat[02],25,' '),'')
           @ 15,09 say IF(!empty(stud_stat[03]),PADR(stud_stat[03],25,' '),'')
           @ 16,09 say IF(!empty(stud_stat[04]),PADR(stud_stat[04],25,' '),'')
           @ 18,16 say IF(!empty(stud_stat[11]),PADR(stud_stat[11],10,' '),'')
           @ 18,28 say IF(!empty(stud_stat[06]),PADR(stud_stat[06],03,' '),'')
           @ 19,08 say IF(!empty(stud_stat[07]),PADR(stud_stat[07],03,' '),'')
           @ 20,22 say IF(!empty(stud_stat[08]),PADR(stud_stat[08],05,' '),'')
           Retval := .T.
        Endif
  sm1p->(dbclosearea())
Return Retval


   
/*----------------------------------------------------------------------------*/

 Function Pop_menu(nTop,nLeft,nBottom,nRight,aItems)
 Local cScreen
 Local nChoice
 Local cLastcolor := Setcolor("W+/B,W+/BG,,,GR+/B")
 cScreen := SaveScreen(nTop,nLeft,nBottom,nRight)
 @ nTop,nLeft,nBottom,nRight BOX B_THICK
 nChoice := ACHOICE(++nTop,++nLeft,--nBottom,--nRight,aItems)
  If Lastkey() == K_ESC
    nchoice := 0
  Endif
 Restscreen(--nTop,--nLeft,++nBottom,++nRight,cScreen)
 Setcolor(cLastcolor)
 Return nChoice

/*----------------------------------------------------------------------------*/

 Function BROWUC(studno)
  Local sm1p        := "F:\crunlib\c999sm1p.dbf"
  Local sm1pi       := "F:\crunlib\cdx\c999sm1p.cdx"
  Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Course","Mjr","YR."}
  Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","X","9."}
  Local stud_fields := {1,2,3,4,5,8,9,10}
  dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
  dbsetindex(sm1pi)
  dbsetorder("last_nam")
  gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)
  sm1p->(dbclosearea())
 Return Nil

 Function BROWME(studno)
 Local sm1p        := "F:\metc\crunlib\c999sm1p.dbf"
 Local sm1pi       := "F:\metc\crunlib\c999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Level","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","9"}
 Local stud_fields := {1,2,3,4,6,12,13}

  dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
  dbsetindex(sm1pi)
  dbsetorder("C999SM12")
  gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)
  sm1p->(dbclosearea())
 Return Nil

 Function BROWST(studno)
 Local stmast       := "F:\crunlib\short\stmast.dbf"
 Local stmasti      := "F:\crunlib\short\cdx\stmast.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X."}
 Local stud_fields := {1,2,3,4}

 dbusearea(.T.,"DBFCDX",stmast,"stmast",.T.,.F.)
 dbsetindex(stmasti)
 dbsetorder("tlstnam")
 gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)
 stmast->(dbclosearea())
 Return Nil

 Function BROWEL(studno)
 Local sm1p        := "F:\erunlib\e999sm1p.dbf"
 Local sm1pi       := "F:\erunlib\cdx\e999sm1p.cdx"
 Local stud_header := {" ID-NO. ","Last Name","First Name","M.I.","Sex","Level","YR."}
 Local stud_pic    := {"99999999","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","XXXXXXXXXXXXXXXXXXXXXXXXXXXXX","X.","X","XX","X","9."}
 Local stud_fields := {1,3,2,4,5,7,8}

 dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
 dbsetindex(sm1pi)
 dbsetorder("tname1")
 gbrow(1,5,22,75,@studno,stud_header,stud_fields,stud_pic,1)
 sm1p->(dbclosearea())
 Return Nil

/*----------------------------------------------------------------------------*/
  Function ForceAppend(studno,stud_stat)
   Local cScreen
   Local nChoice
   Local getlist := {}
   Local cLastcolor := Setcolor("W+/B,W+/BG,,,GR+/B")
   Local last_name  := space(20)
   Local first_name := space(20)
   Local mid_name   := space(1)
   Local defa_stud

  cScreen := SaveScreen(10,10,15,50)
  @ 10,10 clear to 15,50
  @ 10,10,15,50 BOX B_THICK
     @ 11,13 say "Last  Name : " get last_name  pict "@!" valid !empty(last_name)
     @ 12,13 say "First Name : " get first_name pict "@!" valid !empty(first_name)
     @ 13,13 say "Middle     : " get mid_name   pict "@!"
  Read

  defa_stud := "нннннннн"
  keyboard chr(13)

  Getactive():Varput(defa_stud)
   stud_stat[01] :=  studno
   stud_stat[02] :=  last_name
   stud_stat[03] :=  first_name
   stud_stat[04] :=  mid_name+'.'
   stud_stat[05] :=  ""
   stud_stat[06] :=  ""
   stud_stat[07] :=  ""
   stud_stat[08] :=  ""

  Restscreen(10,10,15,50,cScreen)
  Setcolor(cLastcolor)
  Return Nil

/*-------------------------------------------------------------------------*/

 Function scope_box(nTop,nLeft,nBottom,nRight,top_scope,bottom_scope)
 Local cScreen
 Local getlist    := {}
 Local oldcursor  := SETCURSOR(SC_SPECIAL1)
 Local cLastcolor := Setcolor("W+/B,W+/BG,,,GR+/B")
 cScreen := SaveScreen(nTop,nLeft,nBottom,nRight)

 @ nTop,nLeft Clear To nBottom, nRight
 @ nTop,nLeft,nBottom,nRight BOX B_THICK

 @ nTop+2,nLeft+3 say "Upper Scope : " get top_scope
 @ nTop+4,nLeft+3 say "Lower Scope : " get bottom_scope
 Read

  
    top_scope     := if(!empty(top_scope),alltrim(top_scope),space(20))
    bottom_scope  := if(!empty(bottom_scope),alltrim(bottom_scope),space(20))

 Restscreen(nTop,nLeft,nBottom,nRight,cScreen)
 SETCURSOR(oldcursor)
 Setcolor(cLastcolor)
 Return Nil

/*----------------------------------------------------------------------------*/

Function xsearch_studno(studno,stud_stat)
Local Retval :=  .F.
       Do Case
          Case x_1search(studno,stud_stat) == .T.
                 Retval := .T.
          Case x_2search(studno,stud_stat) == .T.
                 Retval := .T.
          Case x_3search(studno,stud_stat) == .T.
                 Retval := .T.
          Case x_4search(studno,stud_stat) == .T.

                 Retval := .T.
          Otherwise
                 Retval := .F.
       Endcase
Return Retval
/*---------------------------------------------------------------------------*/


Function x_1search(studno,stud_stat)
Local Retval := .F.
Local stmast  := "F:\crunlib\short\stmast.dbf"
Local stmasti := "F:\crunlib\short\cdx\stmast.cdx"


// Search at Short Term Master Files
     dbusearea(.T.,"DBFCDX",stmast,"stmast",.T.,.F.)
     dbsetindex(stmasti)
     set order to tag tidno
      stmast->(dbgotop())

       If stmast->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(stmast->stud_num)
           stud_stat[02] :=  trim(stmast->stud_last)
           stud_stat[03] :=  trim(stmast->stud_first)
           stud_stat[04] :=  trim(stmast->stud_mid)+'.'
           stud_stat[05] :=  "ST"  // Short Term Code
           stud_stat[06] :=  " "   // Suppose to be Major
           stud_stat[07] :=  " "   // Short Term dont have year level
           stud_stat[08] :=  space(04)
           stud_stat[09] :=  " "   // No Specific Term Description
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           Retval := .T.
        Endif
  stmast->(dbclosearea())
 Return Retval



Function x_2search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\erunlib\e999sm1p.dbf"
Local sm1pi   := "F:\erunlib\cdx\e999sm1p.cdx"


// Search at ELEMENTARY & HIGH SCHOOL MASTER FILE

   dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
   dbsetindex(sm1pi)
   set order to tag tidno
   sm1p->(dbgotop())

          If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1grade)
           stud_stat[06] :=  " "                  // Suppose to be for major
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schyr)
           stud_stat[09] :=  eget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           Retval := .T.
          Endif
 sm1p->(dbclosearea())
 Return Retval


Function x_3search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\crunlib\c999sm1p.dbf"
Local sm1pi   := "F:\crunlib\cdx\c999sm1p.cdx"


// Search at UCLM Master File

   dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
     dbsetindex(sm1pi)
     set order to tag tidno
     sm1p->(dbgotop())

       If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  trim(sm1p->sm1majcod)
           stud_stat[07] :=  trim(sm1p->sm1yrlvl)
           stud_stat[08] :=  trim(sm1p->sm1schtrm)
           stud_stat[09] :=  get_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           Retval := .T.
       Endif

 sm1p->(dbclosearea())
 Return Retval

Function x_4search(studno,stud_stat)
Local Retval := .F.
Local sm1p    := "F:\metc\crunlib\c999sm1p.dbf"
Local sm1pi   := "F:\metc\crunlib\c999sm1p.cdx"


// Search at METC Master File
     dbusearea(.T.,"DBFCDX",sm1p,"sm1p",.T.,.F.)
     dbsetindex(sm1pi)
      set order to tag C999SM11
      sm1p->(dbgotop())
        If sm1p->(dbseek(trim(studno)))  == .T.
           stud_stat[01] :=  trim(sm1p->sm1idno)
           stud_stat[02] :=  trim(sm1p->sm1lstnam)
           stud_stat[03] :=  trim(sm1p->sm1fstnam)
           stud_stat[04] :=  trim(sm1p->sm1midnam)+'.'
           stud_stat[05] :=  trim(sm1p->sm1colcod)
           stud_stat[06] :=  " "   // Suppose to be Major but METC dont Have
           stud_stat[07] :=  Alltrim(str(sm1p->sm1yrlevl))
           stud_stat[08] :=  transform(str(sm1p->sm1schtrm),"9999")
           stud_stat[09] :=  mget_term_desc(stud_stat[08])
           stud_stat[10] :=  get_cour_desc(stud_stat[05]+stud_stat[06])
           stud_stat[11] :=  get_cour_abbr(stud_stat[05]+stud_stat[06])
           Retval := .T.
        Endif
  sm1p->(dbclosearea())
Return Retval

  
