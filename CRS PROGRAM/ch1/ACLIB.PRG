*------------------------------------------------------------------------------*
* aclib.prg - accounting system library
* By: Leonardo E. Hoyla Jr.
* April 3, 2001
*------------------------------------------------------------------------------*
# INCLUDE "grump.ch"
# INCLUDE "shadowb.ch"
# INCLUDE "setcurs.ch"
# INCLUDE "inkey.ch"
# INCLUDE "Tbrowse.ch"
# INCLUDE "Abrowse.ch"
# INCLUDE "dbinfo.ch"
# INCLUDE "achoice.ch"
# INCLUDE "prj_ch.ch"
# INCLUDE "ac_ch.ch"
# INCLUDE "box.ch"
# DEFINE  SUB_DUPLICATE "is already entered."
# DEFINE DEF_HSEP   "ÂÄ"
# DEFINE DEF_CSEP   "³"
# DEFINE DEF_FSEP   "ÁÄ"

* ---------------------------------------------------------------------------- *
* GetTerm() - to get/accept term entered by the user                           *
* Parameter :                                                                  *
*    cprompt = prompts the user                                                *
*    y , x   = screen coordinates
*    fc      = .T. if want to check if the term is closed otherwise .F.                                         *
* ---------------------------------------------------------------------------- *                          *
Function GetTerm(cprompt,y,x,cColor,fc)
   STATIC vterm
   Local Getlist  := {}, oldcolor := SETCOLOR()
   LOCAL rfield_  := {1}

   IF vterm == NIL
      vterm := SPACE(5)
   ENDIF
   IF cColor == NIL
      cColor := "W+/B"
   ENDIF
   SET(_SET_COLOR,cColor)
   IF OpenTerm()
      Do While .T.
         @ MAXROW()-1,1 Say MESSAGE2
         Setkey( K_F4, { || acBrow (TERMCOORD_,TERMHEADS_,TERMCOLS_,"term",1,rfield_)})
         @ y, x Say cprompt COLOR Y_BLUE GET vTerm PICTURE "#####"
         Read
         Setkey(K_F4,Nil)
         Do Case
            Case Lastkey() = 27 // .OR. (EMPTY(vterm) .AND. LASTKEY() == K_RETURN)
                 vTerm := Space(5)
                 Exit
            Case Lastkey() = K_RETURN
                 If EMPTY(vterm)
                    Tone(700)
                    LOOP
                 Endif
                 If term->(DBSeek(vTerm)) == .T.
                    IF term->termstatus == "C" .AND. fc
                       lMsgBox({"Term is already closed"})
                    ELSE
                       @ y, x+(Len(cprompt)+1) Say term->termcode +;
                       "  - " + strTerm(vterm)
                       Exit
                    ENDIF
                 Else
                    Tone(700)
                 Endif
         Endcase
         @ y, x Clear TO y,78
      Enddo
      term->(DBCloseArea())
  ELSE
      vterm := SPACE(5)
  ENDIF
  SET(_SET_COLOR,oldcolor)
Return vTerm

* ------------------------------------------------------------------------------
* GetIDnumber() - to get/accept student id number and check
* Parameter :
*    cprompt = prompts the user
*    y , x   = screen coordinates
*    nColor  = new color
*    cont    = .T. if want to exit even if the id is not found
* Return Value:
*    asm1p   = an array containing the id,lastname etc.
* Example: please refer to the "prj_ch.ch" file
* ------------------------------------------------------------------------------
Function GetIDnumber(cprompt,y,x,nColor,cont)
   STATIC idno
   Local Getlist:={}, sm1p_:={}, found:=.F.,;
         oldcolor := SETCOLOR()

   IF VALTYPE(nColor)=="U" .OR. EMPTY(nColor)
      nColor := "B/BG,W+/R,,,W+/B"
   ENDIF

   IF idno == NIL
      idno := SPACE(8)
   ENDIF

   ASIZE(sm1p_,0)
   ASIZE(sm1p_,9)
   sm1p_[SM1IDNO]   := SPACE(8)
   sm1p_[SM1LNME]   := SPACE(15)
   sm1p_[SM1FNME]   := SPACE(24)
   sm1p_[SM1MNME]   := SPACE(1)
   sm1p_[SM1COLCOD] := SPACE(2)
   sm1p_[SM1MAJCOD] := SPACE(1)
   sm1p_[SM1YRLVL]  := SPACE(1)
   sm1p_[SM1LASTTRM]:= SPACE(5)
   sm1p_[SM1SEX]    := SPACE(1)

   SET(_SET_COLOR,nColor)
   DO WHILE .T.
      found := .F.
      @ 23,1 Say MESSAGE2 COLOR W_BLUE
      SETKEY(K_F4,{||acBrow(SM1PCOORD_,SM1PHEADS_,SM1PCOLS_,"sm1p",2,{1})})
      @ y, x Say cprompt Color Y_BLUE GET idno PICTURE "########"
      Read
      Setkey(K_F4,Nil)
      IF LASTKEY() = K_ESC
         EXIT
      ENDIF
      DBSELECTAREA("sm1p")
      ORDSETFOCUS("tidno")
      IF sm1p->(DBSEEK(idno))
         sm1p_[SM1IDNO]   := sm1p->sm1idno
         sm1p_[SM1LNME]   := sm1p->sm1lstnam
         sm1p_[SM1FNME]   := sm1p->sm1fstnam
         sm1p_[SM1MNME]   := sm1p->sm1midnam
         sm1p_[SM1COLCOD] := sm1p->sm1colcod
         sm1p_[SM1MAJCOD] := sm1p->sm1majcod
         sm1p_[SM1YRLVL]  := sm1p->sm1yrlvl
         sm1p_[SM1LASTTRM]:= sm1p->sm1schtrm
         sm1p_[SM1SEX]    := sm1p->sm1sex
         found := .T.
         EXIT
      ELSE
         if cont
            exit
         else
            ALERT("ID number not found is SM1P!")
         endif
      ENDIF
   ENDDO
   SET(_SET_COLOR,oldcolor)
RETURN sm1p_
* ------------------------------------------------------------------------------
* GetIDaccp() - to get/accept student id number and check
* Parameter :
*    cprompt = prompts the user
*    y , x   = screen coordinates
*    cFlag   = (s) for sm1p, (a) for accp, and (b) for both
* Return Value:
*    accp_   = an array containing the id,lastname etc.
* Example: please refer to the "prj_ch.ch" file
* ------------------------------------------------------------------------------
FUNCTION GetIDaccp(idno)
   Local Getlist:={}, accp_:={}, found:=.F.

   ASIZE(accp_,0)
   ASIZE(accp_,18)
   accp_[ACCIDNO]    := SPACE(8)
   accp_[ACCLNME]    := SPACE(15)
   accp_[ACCFNME]    := SPACE(24)
   accp_[ACCMNME]    := SPACE(1)
   accp_[ACCFEEYR]   := SPACE(2)
   accp_[ACCTOTUNT]  := 0
   accp_[ACCFEEUNT]  := 0
   accp_[ACCASST]    := 0
   accp_[ACCOLDBAL]  := 0
   accp_[ACCADJ]     := 0
   accp_[ACCDISC]    := 0
   accp_[ACCTOTDUE]  := 0
   accp_[ACCAMTPAID] := 0
   accp_[ACCBALTOT]  := 0
   accp_[ACCTUITION] := 0
   accp_[ACCOTHERS]  := 0
   accp_[ACCMISC]    := 0
   accp_[ACCLAB]     := 0
   found := .F.
   DBSELECTAREA("accp")
   ORDSETFOCUS("cidno")
   IF accp->(DBSeek(idno))
      accp_[ACCIDNO]    := accp->accidno
      accp_[ACCLNME]    := accp->acclname
      accp_[ACCFNME]    := accp->accfname
      accp_[ACCMNME]    := accp->accmname
      accp_[ACCFEEYR]   := accp->accfeeyr
      accp_[ACCTOTUNT]  := accp->accsytunt
      accp_[ACCFEEUNT]  := accp->accfeeunt
      accp_[ACCASST]    := accp->accsytass
      accp_[ACCOLDBAL]  := accp->accbalold
      accp_[ACCADJ]     := accp->accadj
      accp_[ACCDISC]    := accp->accsytadsc
      accp_[ACCTOTDUE]  := accp->accduetot
      accp_[ACCAMTPAID] := accp->accamtpd
      accp_[ACCBALTOT]  := accp->accbaltot
      accp_[ACCTUITION] := accp->accsyttui
      accp_[ACCOTHERS]  := accp->accsytoth
      accp_[ACCMISC]    := accp->accsytmisc
      accp_[ACCLAB]     := accp->accsytlab
      found := .T.
   ENDIF
RETURN accp_
* ---------------------------------------------------------------------------- *
* FIDenrp() - to check if the student already in enrp                          *
* Parameter :                                                                  *
*    idno = id number to search                                                *
* Return Value:                                                                *
*    RetVal = True if found otherwise false                                    *
* ---------------------------------------------------------------------------- *
FUNCTION FIDenrp(idno)
   LOCAL RetVal,status,course,yrlvl
   SELECT enrp
   SET ORDER TO TAG Tenrid
   IF enrp->(DBSEEK(idno)) == .T.
      RetVal := .T.
      status := enrp->enrenrst
      course := enrp->enrcolcod+enrp->enrmajcod
      yrlvl  := enrp->enryrlvl
   ELSE
      RetVal := .F.
      status := " "
      course := ""
      yrlvl  := ""
   ENDIF
RETURN {RetVal,status,course,yrlvl}
* ---------------------------------------------------------------------------- *
* Fsection() - to check if section is valid or existing
* Parameter :
*    course = course ex. AE
*    vsect  = 1A
*    w_major= True if want to INCLUDE major in searching sections otherwise false
* Return Value:
*    RetVal = True if found otherwise false
*    asect  = array of sections that belongs to course
* ---------------------------------------------------------------------------- *
FUNCTION FSection(course,vsect,w_major)
   LOCAL RetVal            // True if found else false
   LOCAL skey              // section search key
   LOCAL asect := {}       // an array or list of sections found if any
   LOCAL cors  := BachAss(SUBSTR(course,1,2))
   LOCAL major := SUBSTR(course,3,1)

   SELECT skdp
   IF w_major
      SET ORDER TO TAG Tsection2
      IF skdp->(DBSEEK(cors+major+vsect)) == .T.
         RetVal := .T.
      ELSE
         RetVal := .F.
      ENDIF
      SET ORDER TO TAG Tcodmaj
      skey := cors+major
      skdp->(DBGOTOP())
      IF skdp->(DBSEEK(skey)) == .T.
         DO WHILE skdp->skdcolcod+skdp->skdmajcod+skdp->skdsec = skey
            IF (ASCAN(asect,skdp->skdsec) = 0) .AND. ;
               ((skdp->skdsec <> SPACE(3)) .AND. (skdp->skdsec <> "ANY"))
               AADD(asect,skdp->skdsec)
            ENDIF
            SKIP
         ENDDO
      ENDIF
   ELSE
      SET ORDER TO TAG Tsection1
      IF skdp->(DBSEEK(cors+vsect)) == .T.
         RetVal := .T.
      ELSE
         RetVal := .F.
      ENDIF
      SET ORDER TO TAG Tcolcod
      skey := cors
      skdp->(DBGOTOP())
      IF skdp->(DBSEEK(skey)) == .T.
         DO WHILE skdp->skdcolcod = skey
            IF (ASCAN(asect,skdp->skdsec) = 0) .AND. ;
               ((skdp->skdsec <> SPACE(3)) .AND. (skdp->skdsec <> "ANY"))
               AADD(asect,skdp->skdsec)
            ENDIF
            SKIP
         ENDDO
      ENDIF
   ENDIF
RETURN {RetVal,asect}
*-------------------------------------------------------------------------------
*  aAddSubBlank() - add a blank to the array of subjects
*  Parameter : (pass by reference)
*    ar   = array to be added
*    tsub = number of element in an array
*-------------------------------------------------------------------------------
FUNCTION aAddSubBlank(ar,tsub)
   ar[CODE    , tsub] := SPACE(5)
   ar[SUBCOD  , tsub] := SPACE(12)
   ar[SUBTYP  , tsub] := SPACE(1)
   ar[BEGTIM  , tsub] := SPACE(5)
   ar[ENDTIM  , tsub] := SPACE(5)
   ar[MDN     , tsub] := SPACE(2)
   ar[DAY1    , tsub] := SPACE(4)
   ar[ROOM    , tsub] := SPACE(4)
   ar[COLCOD  , tsub] := SPACE(2)
   ar[ACTSIZ  , tsub] := SPACE(4)
   ar[UNIT    , tsub] := SPACE(4)
   ar[DAY2    , tsub] := SPACE(7)
   ar[BEGTIMX , tsub] := SPACE(5)
   ar[ENDTIMX , tsub] := SPACE(5)
   ar[SPLSKD  , tsub] := SPACE(5)
RETURN NIL
*------------------------------------------------------------------------------*
* GSubenrp() - to collect subjects enrolled
*    Parameter :
*       idno = student id number including withdrawn
*    Return Value :
*       tsub = total subject enrolled including withdrawn
*------------------------------------------------------------------------------*
FUNCTION GSubenrp(idno)
   LOCAL aSubject                       // an array of subjects
   LOCAL vSkdcod := SPACE(5)            // pointer to hold the field name
                                        //  of the subject code
   LOCAL i := 0                         // counter
   LOCAL enrprn := 0                    // enrp record number pointer
   LOCAL tsub :=0                       // total subjects found

   SELECT enrp
   SET ORDER TO TAG Tenrid
   IF enrp->(DBSEEK(idno)) == .T.
      enrprn := RECNO()
      FOR i := 1 TO 16
         vSkdcod := "enrskd" + Padl(i,2,"0")
         IF enrp->&vSkdcod <> "00000"
            Select skdp
            Set Order To 1
            If skdp->(DBSeek(enrp->&vSkdcod)) == .T.
                tsub++
                aSubject := {skdp->skdcod,skdp->skdsubcod,skdp->skdsubtyp,;
                skdp->skdbegtim,skdp->skdendtim,skdp->skdmdn,skdp->skdday,;
                skdp->skdrom,skdp->skdcolcod,skdp->skdactsiz,skdp->skdunt,;
                skdp->skddayx,skdp->skdbegtimx,skdp->skdendtimx,skdp->skdsplskd}
                ArraySub(aSubject,tsub,.F.)
            ENDIF
         ENDIF
         SELECT enrp
         SET ORDER TO TAG Tenrid
         GO enrprn
      NEXT
   ENDIF
RETURN tsub
*------------------------------------------------------------------------------*
* GSubskdp() - list of subjects with in the Section
*  Parameter :
*    cors_major = course and major
*    vsect      = section
*    mFlag      = major flag, true if major is INCLUDEd for searching otherwise false
*  Return Value :
*    tsub       = total subjects found in a particular section
*------------------------------------------------------------------------------*
FUNCTION GSubskdp(cors_maj,vsect,mFlag)
   LOCAL aSubject                       // an array of subjects
   LOCAL sKey                           // search key
   LOCAL cors   := BachAss(SUBSTR(cors_maj,1,2))   // course w/o major
   LOCAL cormaj := BachAss(SUBSTR(cors_maj,1,2))+SUBSTR(cors_maj,3,1)
   LOCAL tsub :=0                       // total subjects found

   SELECT skdp
   skdp->(DBGOTOP())
   IF mFlag
      SET ORDER TO TAG Tsection2
      sKey := cormaj+vsect
   ELSE
      SET ORDER TO TAG Tsection1
      sKey := cors+vsect
   ENDIF
   SETCOLOR(W_BLUE)
   IF skdp->(DBSEEK(sKey)) == .T.
      GO RECNO()
      DO WHILE sKey == IF(mFlag,;
         skdp->skdcolcod+skdp->skdmajcod+skdp->skdsec,;
         skdp->skdcolcod+skdp->skdsec)
         DO WHILE skdp->(DBRLOCK()) == .F.
         ENDDO
         skdp->(DBRLOCK())
         skdp->skdactsiz++
         skdp->(DBCOMMIT())
         skdp->(DBUNLOCK())
         tsub++
         aSubject := {skdp->skdcod,skdp->skdsubcod,skdp->skdsubtyp,;
            skdp->skdbegtim,skdp->skdendtim,skdp->skdmdn,skdp->skdday,;
            skdp->skdrom,skdp->skdcolcod,skdp->skdactsiz,skdp->skdunt,;
            skdp->skddayx,skdp->skdbegtimx,skdp->skdendtimx,skdp->skdsplskd}
            ArraySub(aSubject,tsub,.F.)
         SKIP
      ENDDO
   ENDIF
RETURN tsub
*------------------------------------------------------------------------------*
*  FindSub() - find subject from SKDP file
*  Parameter :
*     skdcod = search key
*  Return Value :
*     retval = return the value of skdcod if found otherwise return ""
*------------------------------------------------------------------------------*
FUNCTION FindSub(skdcod)
   LOCAL retval

   SELECT skdp
   SET ORDER TO TAG Tcod
   IF skdp->(DBSEEK(skdcod)) == .T.
      retval := {.T.,skdp->skdsplskd}
   ELSE
      retval := {.F.,""}
   ENDIF
RETURN skdcod
*------------------------------------------------------------------------------*
*  ArraySub() - an array of subjects provided from GSubenrp() & GSubskdp()
*    Parameter :
*       asubject = an array of subjects to be added to this array
*       count    = row position of the subject added
*       initial  = .T. to initialize aSub back to zero element
*------------------------------------------------------------------------------*
FUNCTION ArraySub(asubject,acount,initial)
   LOCAL i := 0
   STATIC aSub

   IF initial
      aSub := {}
   ENDIF
   SETCOLOR(W_BLUE)
   IF acount = 1
      aSub := Array(15,25)
   ENDIF
   IF acount > 0
      FOR i := 1 TO 15
         aSub[i,acount]:= asubject[i]
      NEXT i
   ENDIF
RETURN aSub
/*-----------------------------------------------------------------------------*
  SelectDB() - to select an open database and index.
  Parameter :
     dbf  = database name, path is optional
     dbi  = database index name, path is optional
*/
Function SelectDB(dbf,dbi)
   Select &dbf
   If dbi <> ""
      Set Order To Tag &dbi
   Endif
Return Nil
/*-----------------------------------------------------------------------------*
   Send printer codes
   Parameter :
     string = printer codes
     line   = no. of lines each page
     ex. bold etc.
*/
Function PrintStyle(string,line)
   Local r := Prow() , c := Pcol(), strcde := ""
   Do Case
      Case string = "bold_on"
           strcde := Chr(27) + "E"
      Case string = "bold_off"
           strcde := Chr(27) + "F"
      Case string = "italic_on"
           strcde =  Chr(27) + Chr(52)
      Case string = "italic_off"
           strcde =  Chr(27) + Chr(53)
      Case string = "condensed_on"
           strcde := Chr(15)
      Case string = "condensed_off"
           strcde := Chr(18)
      Case string = "enlarge_on"
           strcde := Chr(27) + 'W' + Chr(1)
      Case string = "enlarge_off"
           strcde := Chr(27) + 'W' + Chr(0)
      Case string = "double_strike_on"
           strcde := Chr(27) + 'G'
      Case string = "double_strike_off"
           strcde := Chr(27) + 'H'
      Case string = "line"
           strcde := Chr(27) + 'C' + Chr(line)
   Endcase
   @ r, c Say strcde
   Setprc(r,c)
Return ""
*-------------------------------------------------------------------------------
*  GetCourse() - to get course
*  Parameter:
*     fprompt - true if want to display cprompt
*     cprompt - Entry prompt
*     vcors   - initial value of course and major use for get and search
*     y       - Row get position
*     x       - Column get position
*  Return Value:
*     - Return an array
*       1. Course code and major code ex. AEE
*       2. Description abreviation and major ex. BSED E
*       3. Full description ex. B.S. IN EDUCATION MAJOR IN ENGLISH
*     - Nil if no selected course or ESC is pressed
*-------------------------------------------------------------------------------
Function GetCourse(fprompt,cprompt,vcors,y,x)
   Local Getlist := {}, desabr:="", desful:="", rfield_:={1,2}

   Select colp
   Set Order To Tag Tcodmaj
   Do While .T.
      IF fprompt
         SETKEY(K_F4,{||acBrow(COLPCOORD_,COLPHEADS_,COLPCOLS_,"colp",2,rfield_)})
//         Setkey(K_F4,{ || BrowDB(5,14,16,66,"colp")})
         @ y, x Say cprompt Color Y_BLUE Get vcors Pict "@!" Color NORM_COLOR
         Read
         Setkey(K_F4,Nil)
         If Lastkey() == K_ESC
            vcors := Nil
            Exit
         Endif
      ENDIF

      Set Order To Tag Tcodmaj
      If colp->(DBSeek(vcors)) == .T. .OR. vcors == "ALL"
         IF fprompt
            @ y, x+(Len(cprompt)+1) Say vcors Color W_BLUE
         ENDIF
         vcors  := IF(vcors="ALL",vcors,colp->colcod+colp->colmajcod)
         desabr := colp->coldesabr + " " + colp->colmajcod
         desful := colp->coldesful
         Exit
      ELSE
         vcors := SPACE(3)
      Endif
      IF !fprompt
         EXIT
      ENDIF
   Enddo
Return If(vcors==SPACE(3),Nil,{vcors,desabr,desful})
*------------------------------------------------------------------------------*
Function Sect(vCourse)
  Local lIndex := Getenv("USER")
  Select secp
  Index On secp->seccolcod+secp->seccod To &lIndex For secp->seccolcod = "II"
//  BrowDB(5,25,15,35,"secp")
Return Nil
*------------------------------------------------------------------------------*
*  Section() - Retrieving the block section code                               *
*  Parameter :                                                                 *
*      ntop,nlft,nbot,nfrht = Four screen coordinates                          *
*      course  = Colcod and Major ex. AEM - B.S. Education Major in Math       *
*      asect   = section                                                       *
*      w_major = .T. if major is INCLUDEd for searching otherwise .F.          *
*------------------------------------------------------------------------------*
Function Section(ntop, nlft, nbot, nrht, asec, course, w_major)
   Local scrSec,nRow := 1
   Local nChoice,nElement
   Local browbuff
   Local temp
   Local oldcolor  := Setcolor()
   Local oldcursor := Setcursor()

   Setkey(K_F4,Nil)
   Setcolor("+W/BG,+W/R")
   Setcursor(.F.)

//   browbuff = PopBox(ntop, nlft, nbot, nrht, 6, 10, .T.)

   @ ntop, nlft Clear To nbot, nrht
   @ ntop, nlft, nbot, nrht Box B_SINGLE

   IF LEN(asec) > 0
      Do While .T.
         nChoice := Achoice(ntop+1,nlft+1,nbot-1,nrht-1,aSec,.T.,"UDF1",nRow)
         Do Case
            Case Lastkey() == K_F4
               nRow := nChoice
               BrowSect(6,3,course+asec[nChoice],.F.)
            Case Lastkey() == K_RETURN
               GetActive():Varput(aSec[nChoice])
               Exit
            Case nChoice == 0
               Exit
         Endcase
      Enddo
   ENDIF
   Setcolor(oldcolor)
   Setcursor(oldcursor)
//   Keyboard Chr(K_PGDN)
//   Byebyebox(browbuff)
Return Nil

Function UDF1( nMode, nElement, nRow)
   Local nKey := Lastkey()
   Local RetVal 
   Do Case
      Case nKey == K_F4
         Return 1
      Case nKey == K_RETURN
         Return 1
      Case nKey == K_ESC
         Return 0
      Otherwise
         Return 2
   Endcase
Return Nil

* ----------------------------------------------------------------------------
* Function BrowSect() - Browse subjects within a block section
* Parameter :
*     vCourse = Course and Major ex. AEE
*     w_major = .T. if want to INCLUDE major in searching otherwise .F.
*     y, x    = screen coordinates
* ----------------------------------------------------------------------------
Function BrowSect(y, x, vCourse, w_major)
   Local i,seccod,tUnt := 0
   Local aSubject := {}
   Local vTemp,browbuff
   LOCAL lCourse := BachAss(Substr(vCourse,1,2))+SUBSTR(vCourse,3,4)
   Local lCourse1:= Substr(vCourse,3,3)
   Local lCourse2:= ""      // colcod+majcod+skdrescod
   LOCAL foot    := GetCourse(.F.,,SUBSTR(lCourse,1,3),,)[2]+" - "+SUBSTR(lCourse,4,3)

   Select skdp
   IF w_major = .T.
      Set Order To Tag Tsection2
   ELSE
      SET ORDER TO TAG Tsection1
   ENDIF
   skdp->(DBGotop())
   If skdp->(DBSeek(IF(w_major,lCourse,SUBSTR(lCourse,1,2)+SUBSTR(lCourse,4,3)))) == .T.
      Do While IF(w_major==.F.,skdp->skdcolcod+skdp->skdsec,;
               skdp->skdcolcod+skdp->skdmajcod+skdp->skdsec)==;
               IF(w_major,vCourse,SUBSTR(lCourse,1,2)+SUBSTR(lCourse,4,3))
            vTemp := skdp->skdcod + "    " + skdp->skdsubcod + "   "  + ;
                  skdp->skdsubtyp + "  " + skdp->skdbegtim + " - " + ;
                  skdp->skdendtim + "   " + skdp->skdmdn + "   "   + ;
                  skdp->skdday + "   " + skdp->skdrom + "    "     + ;
                  Ltrim(Str(skdp->skdunt))
            tUnt := tUnt + skdp->skdunt
            Aadd(aSubject,vTemp)
            lCourse2 := skdp->skdcolcod+skdp->skdmajcod+skdp->skdrescod
         Skip
      Enddo


      Aadd(aSubject,REPLICATE("-",71))
      Aadd(aSubject,foot+SPACE(30)+"TOTAL UNITS     : " + Ltrim(Str(tUnt)))

      If w_major == .F.
//         browbuff =  PopBox(y, x,y+Len(aSubject)+1, x+Len(aSubject[1])+3, 5, 10)
         achoice(y+1,x+2,y+Len(aSubject)+1,x+(Len(aSubject[1])+2),aSubject)
//         Byebyebox(browbuff)
      Endif
   Else
      ErrorTone()
      ALERT("Section not found!")
   Endif
Return If(w_major==.F.,Nil,{aSubject,lCourse2})

// ----- Bachelor vs. bscodes -----------------------------------------------

Function BachAss(vCode)
   Local lCourse := ""

   Select colp
   Set Order To Tag Tcod
   colp->(DBSeek(vcode))
   If colp->bscode<>Space(2)
      lCourse := colp->bscode
   Else
      lCourse := Substr(vCode,1,2)
   Endif
Return lCourse

// --------- Screen Header -----------------------------------------------------

Function SHeader(eHeader)
   STATIC oldcolor, oldcursor, buff := ""
   Local mDte :=CTOD("")
   Local dte  := ctod('  /  /  ')

//   dte := Date()
//   Showtime( 0, 70, .F., "+w/b", .T., .T. )

//   IF LEN(buff) == 0
      oldcolor  := SETCOLOR()
      oldcursor := SETCURSOR()
      Set(_SET_INTENSITY  , .T.          )
      Set(_SET_DATEFORMAT , "MM/DD/YYYY" )
      Set(_SET_SCOREBOARD , .F.          )
      Set(_SET_CONFIRM    , .T.          )
      SetColor("W/B")
//      buff := SaveScr(0,0,MAXROW(),MAXCOL())
      lBox(1, 0, MAXROW(), MAXCOL(),"W+/B")
      @ 0, 0 Say " ACCOUNTING SYSTEM - UNIVERSITY OF CEBU (LAPU-LAPU AND MANDAUE)                 " COLOR "W+/R+"
      @ 1,39-(Len(eHeader)/2) SAY eHeader COLOR "B+/W+"
//   ELSE
      SET(_SET_COLOR,oldcolor)
      SET(_SET_CURSOR,oldcursor)
//      RestScr(buff)
//      ASIZE(buff,0)
//   ENDIF
RETURN NIL
*------------------------------------------------------------------------------*
*  Screen Entry for enrollment                                                 *
*------------------------------------------------------------------------------*
Function scrEntry
   Setcolor(Y_BLUE)
   @ 4,  2 Say "Last Name   :"
   @ 5,  2 Say "First Name  :"
   @ 6,  2 Say "Mid Initial :"
   @ 7,  2 Say "Gender      :"
   @ 4, 45 Say "Course / Major :"
   @ 5, 45 Say "Year Level     :"
   @ 6, 45 Say "Section        :"
   @ 7, 45 Say "Classification :    [C,H,O,R,S,T]"
   SetColor(W_BLUE)
   @ 8, 2 TO 8, 77
/*
   @ 8,   2, 20, 77 Box B_SINGLE
   @ 10,  2, 20,  9 Box B_SINGLE
   @ 10,  9, 20, 30 Box B_SINGLE
   @ 10, 30, 20, 56 Box B_SINGLE
   @ 10, 56, 20, 65 Box B_SINGLE
   @ 10, 65, 20, 73 Box B_SINGLE
   @ 10, 73, 20, 77 Box B_SINGLE
   @ 10,  2 Say Chr(195)
   @ 10, 77 Say Chr(180)
   @ 20,  2 Say Chr(192)
   @ 20, 77 Say Chr(217)
   @ 10,  9 Say Chr(194)
   @ 10, 30 Say Chr(194)
   @ 10, 56 Say Chr(194)
   @ 10, 65 Say Chr(194)
   @ 10, 73 Say Chr(194)
   @ 20,  9 Say Chr(193)
   @ 20, 30 Say Chr(193)
   @ 20, 56 Say Chr(193)
   @ 20, 65 Say Chr(193)
   @ 20, 73 Say Chr(193)
   @  9,  3 Say "Skdcod        Subject               Schedule           CCSize   Units  Rem" Color "W+/R,R/B"
   @ 21, 2 Say "Status :" Color Y_BLUE
   @ 21, 46 Say "Total Units :" Color Y_BLUE
*/
Return Nil

Function  ErrorTone()
   Setcursor(SC_NONE)
   Tone(900)
   Tone(700)
   Tone(500)
   Setcursor(SC_NORMAL)
Return Nil

//** Function WAS_IN
//** The Function is used to determine either the inputted key is within
//** the range of valid keys in the keyboard

Function Was_in (key)
Local flag := .F.
   If key>31 .AND. key<166
      Flag:=.T.
   Else
      Flag:=.F.
   Endif
Return flag

// ----- strTerm - Convert term to string --------------------------------------
Function strTerm(vTerm)
   Local vt
   Local vt1 := Substr(vTerm,1,4)

   If Substr(vTerm,5,1) == "1"
      vt := "FIRST SEMESTER  " + Str(Val(vt1)-1,4) + "-" + vt1
   Elseif Substr(vTerm,5,1) == "2"
      vt := "SECOND SEMESTER  " + Str(Val(vt1)-1,4) + "-" + vt1
   Elseif Substr(vTerm,5,1) == "3"
      vt := "THIRD SEMESTER  " + Str(Val(vt1)-1,4) + "-" + vt1
   Elseif Substr(vTerm,5,1) == "4"
      vt := "SUMMER  " + vt1
   Endif
Return vt
*-------------------------------------------------------------------------------
* IsNumeric() - to determine if all characters in a string is a number/period
* Parameter :
*   s : string to be evaluated
* Return Value : (array)
*   retval[1] := .T. if all character in a string is a number of a dot(.).
*   retval[2] := converted numeric value if retval[1] is .T.
*-------------------------------------------------------------------------------
FUNCTION IsNumeric(s)
   LOCAL lNumChar := "0123456789. "
   LOCAL i, retval:=.T., c, num := ""
   DO CASE
      CASE VALTYPE(s) == "C"
         IF !EMPTY(s)
            i:=1
            DO WHILE i <= LEN(ALLTRIM(s))
               c := SUBSTR(s,i,1)
               IF AT(c,lNumChar) = 0
                  retval := .F.
                  EXIT
               ENDIF
               IF c <> " "
                  num += c
               ENDIF
               i++
            ENDDO
         ELSE
            retval := .F.
         ENDIF
      CASE VALTYPE(s) == "N"
         retval := .T.
      OTHERWISE
         retval := .F.
   ENDCASE
RETURN {retval,IF(retval==.T.,VAL(num),s)}

Function All(abbr)
   GetActive():Varput(IF(abbr,"A","ALL"))
   Keyboard Chr(K_RETURN)
Return Nil

*-------------------------------------------------------------------------------
* lMsgBox() - to display message box and options horizontally
* Parameter :
*    msg    = an array of message (required)
*    opt    = an array of option (optional)
*    mcolor = an array of color (optional)
*        ex. mcolor[1] for title color
*            mcolor[2] for background color
*            mcolor[3] for text/message color
*            mcolor[4] for option color
*    title  = title of the message box (optional)
* Return Value:
*    retval = 0 no selection,1 for first option, 2 for second and so on.
*-------------------------------------------------------------------------------
FUNCTION lMsgBox(msg,opt,mcolor,title,DispType)
   LOCAL dtitcolor := "G+/RB"+"*"
   LOCAL dbcolor   := "W+/RB"
   LOCAL dtxtcolor := "N/W"         //"W+/RB+"
   LOCAL doptcolor := "N/W,GR+/B+"  //"GR+/RB,GR+/B+"
   LOCAL msg1:= {}, lmsg:=0, buff, x1, y1, x2, y2, lpd:=0, rpd:=0
   LOCAL lenopt := 0, opt1 := {}, stCol := 0, optprm := 0, nch := 0
   LOCAL titcolor := IF(VALTYPE(mcolor)=="U",dtitcolor,;
                     IF(VALTYPE(mcolor[1])=="U",dtitcolor,mcolor[1]))
   LOCAL bcolor   := IF(VALTYPE(mcolor)=="U",dbcolor,;
                     IF(VALTYPE(mcolor[2])=="U",dbcolor,mcolor[2]))
   LOCAL txtcolor := IF(VALTYPE(mcolor)=="U",dtxtcolor,;
                     IF(VALTYPE(mcolor[3])=="U",dtxtcolor,mcolor[3]))
   LOCAL optcolor := IF(VALTYPE(mcolor)=="U",doptcolor,;
                     IF(VALTYPE(mcolor[4])=="U",doptcolor,mcolor[4]))
   LOCAL lenmess := 0, maxstrlen := 0, scr
   LOCAL oldcolor := SETCOLOR(),oldcursor := SETCURSOR(), i

   SET(_SET_CURSOR,SC_NONE)
   IF VALTYPE(msg) <> "A"
      msg := {"Error! no message found"}
      lmsg := 1
   ELSE
      lmsg += LEN(msg)
   ENDIF
   IF VALTYPE(opt) <> "A"
      opt := {"Ok"}
   ENDIF
   IF VALTYPE(title) <> "U"
      lmsg++
   ENDIF
   lmsg++

   // determine the lenght of the longest element in an array
   AEVAL(msg, {|x| lenmess := MAX(lenmess,LEN(x))})

   // determine the exact length of all options
   AEVAL(opt,{|x|lenopt += (LEN(x)+4)})

   // add one space before and after the option
   AEVAL(opt,{|x| AADD(opt1,x:=" "+x+" ")})

   // determine the maximun length of window
   maxstrlen := MAX(lenopt,MAX(lenmess,IF(VALTYPE(title)=="U",1,LEN(title))))

   // add space before an element so that it will be centered
   AEVAL(msg,{|x|lpd:=INT((maxstrlen-LEN(x))/2),;
         AADD(msg1,x := REPLICATE(" ",lpd)+x)})

   stCol := (MAXCOL()/2)-(lenopt/2)  // starting column of the options

   y1 := (MAXROW()-lmsg)/2
   x1 := (MAXCOL()-maxstrlen)/2
   y2 := y1+lmsg
   x2 := x1+maxstrlen+1
   SETCOLOR(dbcolor)
  
   buff := SaveScr(y1-1,x1-1,y2+1,x2+1)
   NBox(y1-1,x1-1,y2+1,x2+1,"W","W+","N")

   //* display title if any
   IF VALTYPE(title) <> "U"
      @ y1,40-(LEN(title)/2) SAY title COLOR "R/W"
   ENDIF

   //* display the messages
   FOR i := 1 TO LEN(msg)
       @ IF(VALTYPE(title)=="U",y1-1+i,y1+i),x1+1 SAY msg1[i] COLOR "N/W"  //dtxtcolor
   NEXT
   @ y2,stCol SAY ""
   SETCOLOR(optcolor)

   //* display the options
   FOR i := 1 TO LEN(opt1)
       @y2,COL()+2 PROMPT opt1[i]
   NEXT
   MENU TO optprm
   SETCURSOR(oldcursor)
   SETCOLOR(oldcolor)
   RestScr(buff)
RETURN optprm
*-------------------------------------------------------------------------------
* lMsgBox() - to display message box and options horizontally
* Parameter :
*    msg    = an array of message (required)
*    opt    = an array of option (optional)
*    mcolor = an array of color (optional)
*        ex. mcolor[1] for title color
*            mcolor[2] for background color
*            mcolor[3] for text/message color
*            mcolor[4] for option color
*    title  = title of the message box (optional)
* Return Value:
*    retval = 0 no selection,1 for first option, 2 for second and so on.
*-------------------------------------------------------------------------------
FUNCTION hMsgBox(msg,opt,mcolor,title)
   LOCAL dtitcolor := "G+/RB"+"*"
   LOCAL dbcolor   := "W+/RB"
   LOCAL dtxtcolor := "N/W"         //"W+/RB+"
   LOCAL doptcolor := "N/W,GR+/B+"  //"GR+/RB,GR+/B+"
   LOCAL msg1:= {}, lmsg:=0, buff, x1, y1, x2, y2, lpd:=0, rpd:=0
   LOCAL lenopt := 0, opt1 := {}, stCol := 0, optprm := 0, nch := 0
   LOCAL titcolor := IF(VALTYPE(mcolor)=="U",dtitcolor,;
                     IF(VALTYPE(mcolor[1])=="U",dtitcolor,mcolor[1]))
   LOCAL bcolor   := IF(VALTYPE(mcolor)=="U",dbcolor,;
                     IF(VALTYPE(mcolor[2])=="U",dbcolor,mcolor[2]))
   LOCAL txtcolor := IF(VALTYPE(mcolor)=="U",dtxtcolor,;
                     IF(VALTYPE(mcolor[3])=="U",dtxtcolor,mcolor[3]))
   LOCAL optcolor := IF(VALTYPE(mcolor)=="U",doptcolor,;
                     IF(VALTYPE(mcolor[4])=="U",doptcolor,mcolor[4]))
   LOCAL lenmess := 0, maxstrlen := 0, scr
   LOCAL oldcolor := SETCOLOR(),oldcursor := SETCURSOR(), i

   SET(_SET_CURSOR,SC_NONE)
   IF VALTYPE(msg) <> "A"
      msg := {"Error! no message found"}
      lmsg := 1
   ELSE
      lmsg += LEN(msg)
   ENDIF

   IF VALTYPE(opt) <> "A"
      opt := {"Ok"}
   ENDIF
   IF VALTYPE(title) <> "U"
      lmsg++
   ENDIF
   lmsg++

   // determine the lenght of the longest element of an array
   AEVAL(msg, {|x| lenmess := MAX(lenmess,LEN(x))})

   // determine the lenght of the longest element of an option
   AEVAL(opt, {|x| lenopt := MAX(lenopt,LEN(x))})

   // add one space before and after the option
   AEVAL(opt,{|x| AADD(opt1,x:=PADR(" "+x,lenopt+2," "))})

   // determine the maximun length of window
   maxstrlen := MAX(lenopt,MAX(lenmess,IF(VALTYPE(title)=="U",1,LEN(title))))

   // add space before an element so that it will be centered
   AEVAL(msg,{|x|lpd:=INT((maxstrlen-LEN(x))/2),;
         AADD(msg1,x:=PADC(x,lenopt+2," "))})

   stCol := (MAXCOL()/2)-(lenopt/2)  // starting column of the options

   y1 := (MAXROW()/2)-(lmsg/2)
   x1 := stCol
   y2 := y1+lmsg
   x2 := x1+maxstrlen+1
   SETCOLOR(dbcolor)
  
   buff := SaveScr(y1-1,x1-1,y2+1,x2+1)
   NBox(y1-1,x1-1,y2+1,x2+1,"W","W+","N")
  
   //* display title if any
   IF VALTYPE(title) <> "U"
      @ y1,(MAXCOL()/2)-(LEN(title)/2) SAY title COLOR "R/W"
   ENDIF

   //* display the messages
   FOR i := 1 TO LEN(msg)
       @ IF(VALTYPE(title)=="U",y1-1+i,y1+i),x1 SAY msg1[i] COLOR "W+/R"  //dtxtcolor
   NEXT

   SETCOLOR(optcolor)
   //* display the options
   FOR i := 1 TO LEN(opt1)
       @y1+(LEN(msg)-1)+i,stCol PROMPT opt1[i]
   NEXT
   MENU TO optprm
   SETCURSOR(oldcursor)
   SETCOLOR(oldcolor)
   RestScr(buff)
RETURN optprm
*-------------------------------------------------------------------------------
FUNCTION tbMethods(b,nkey)
   LOCAL fkey := 0, retval
   LOCAL tb_methods :={ ;
           {K_DOWN,       {|b| b:down()}}, ;
           {K_UP,         {|b| b:up()}}, ;
           {K_PGDN,       {|b| b:pagedown()}}, ;
           {K_PGUP,       {|b| b:pageup()}}, ;
           {K_CTRL_PGUP,  {|b| b:gotop()}}, ;
           {K_CTRL_PGDN,  {|b| b:gobottom()}}, ;
           {K_RIGHT,      {|b| b:right()}}, ;
           {K_LEFT,       {|b| b:left()}}, ;
           {K_HOME,       {|b| b:home()}}, ;
           {K_END,        {|b| b:end()}}, ;
           {K_CTRL_LEFT,  {|b| b:panleft()}}, ;
           {K_CTRL_RIGHT, {|b| b:panright()}}, ;
           {K_CTRL_HOME,  {|b| b:panhome()}}, ;
           {K_CTRL_END,   {|b| b:panend()}}}
   fkey := ASCAN(tb_methods, {|elem| nKey = elem[1]})
   IF fkey <> 0
      EVAL(tb_methods[fkey, 2], b)
      retval := .T.
   ELSE
      retval := .F.
   ENDIF
RETURN retval
*-------------------------------------------------------------------------------
*  DispName() - if enrolled, display the name of the student on the screen
*  Parameter :
*     idno = id number to search from SM1P file
*     fdis = .T. if want to display the result, otherwise false
*  Return Value:
*     stud = the complete name of the student
*-------------------------------------------------------------------------------
FUNCTION DispName(idno,fdis)
   LOCAL stud := " "
   SELECT sm1p
   SET ORDER TO TAG Tidno
   sm1p->(DBSEEK(idno))
   stud := sm1p->sm1idno+" "+sm1p->sm1lstnam+" "+;
           sm1p->sm1fstnam+" "+sm1p->sm1midnam
   IF fdis
      @ 12,13 SAY stud
   ENDIF
   SELECT enrp
RETURN stud

FUNCTION SaveSM1P(asm1p,vterm,schtrm)
      SELECT sm1p
      SET ORDER TO TAG Tidno
      IF sm1p->(DBSEEK(asm1p[IDNUMBER])) == .F.
         sm1p->(DBAPPEND())
         sm1p->sm1idno   := asm1p[IDNUMBER]
         sm1p->sm1lstnam := asm1p[LASTNAME]
         sm1p->sm1fstnam := asm1p[FIRSTNAME]
         sm1p->sm1midnam := asm1p[MIDNAME]
         sm1p->sm1sex    := asm1p[SEX]
         sm1p->sm1schtrm := SPACE(5)
      ENDIF

      schtrm := sm1p->sm1schtrm
      DO WHILE sm1p->(DBRLOCK()) == .F.
      ENDDO
      sm1p->(DBRLOCK())
      sm1p->sm1colcod := asm1p[COURSE]
      sm1p->sm1majcod := asm1p[MAJOR]
      sm1p->sm1yrlvl  := asm1p[YEARLVL]
      sm1p->sm1cls    := asm1p[CLASS]
      sm1p->sm1schtrm := vterm
      sm1p->(DBCOMMIT())
      sm1p->(DBUNLOCK())
RETURN NIL
*-------------------------------------------------------------------------------
*  GCourse() - the course abbriviation
*  Parameter :
*    colcodx = course & major to search
*  Return Value:
*    course  = the course abbriviation if found, otherwise SPACE(12)
*-------------------------------------------------------------------------------
FUNCTION GCourse(colcodx)
   LOCAL course := SPACE(12)
   SELECT colp
   SET ORDER TO TAG Tcodmaj
   IF colp->(DBSEEK(colcodx))
      course := TRIM(colp->coldesabr) + " " + colp->colmajcod
   ENDIF
   SELECT enrp1
RETURN course

/*  $DOC$
 *  $FUNCNAME$
 *     FT_MIL2MIN()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Convert time in military format to number of minute of day.
 *  $SYNTAX$
 *     FT_MIL2MIN( <cMILTIME> ) -> nMINUTE
 *  $ARGUMENTS$
 *     <cMILTIME>  character string of form hhmm, where 0<=hh<24.
 *  $RETURNS$
 *     <nMINOFDAY>  numeric value representing minute of day.
 *  $DESCRIPTION$
 *     Converts time in military format to number of minute of the day.
 *  $EXAMPLES$
 *     FT_MIL2MIN( "1729" ) -> 1049
 *  $SEEALSO$
 *     FT_MIN2MIL() FT_CIV2MIL() FT_MIL2CIV() FT_SYS2MIL()
 *  $END$
 */

function FT_MIL2MIN(cMILTIME)
return int(val(left(cMILTIME,2))*60 + val(right(cMILTIME,2)))

/*  $DOC$
 *  $FUNCNAME$
 *     FT_MIN2MIL()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Convert minute of day to military format time.
 *  $SYNTAX$
 *     FT_MIN2MIL( <nMINUTE> ) -> cMILTIME
 *  $ARGUMENTS$
 *     <nMINUTE>  numeric integer representing minute of day.
 *  $RETURNS$
 *     <cMILTIME>  character string of form hhmm, where 0<=hh<24.
 *  $DESCRIPTION$
 *     Converts minute of the day to military format time.
 *  $EXAMPLES$
 *     FT_MIN2MIL( 279 ) -> 0439
 *  $SEEALSO$
 *     FT_MIL2MIN() FT_MIL2CIV() FT_CIV2MIL() FT_SYS2MIL()
 *  $END$
 */

function FT_MIN2MIL(nMIN)
  nMIN := nMIN%1440
return right("00" + ltrim(str(INT(nMIN/60))),2) + ;
       right("00" + ltrim(str(INT(nMIN%60))),2)
/*  $DOC$
 *  $FUNCNAME$
 *     FT_MIL2CIV()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Convert time in military format to civilian format.
 *  $SYNTAX$
 *     FT_MIL2CIV( <cCIVTIME> ) -> dMILTIME
 *  $ARGUMENTS$
 *     <cMILTIME>  character string of form hhmm, where 0<=hh<24.
 *  $RETURNS$
 *     <cCIVTIME>  character string of form hh:mm (am,pm,n or m),
 *        where 0<hh<12.
 *  $DESCRIPTION$
 *     Converts time from military to civilian format
 *  $EXAMPLES$
 *     FT_MIL2CIV( "1640" ) ->  4:40 pm
 *
 *     FT_MIL2CIV( "0440" ) ->  4:40 am
 *
 *     FT_MIL2CIV( "1200" ) -> 12:00 n
 *
 *     FT_MIL2CIV( "0000" ) and FT_MIL2CIV( "2400" ) -> 12:00 m
 *
 *     Caution:  leading blanks are irrelevant.
 *  $SEEALSO$
 *     FT_CIV2MIL() FT_SYS2MIL() FT_MIL2MIN() FT_MIN2MIL()
  *  $END$
 */

function FT_MIL2CIV(cMILTIME)
  local cHRS,cMINS,nHRS,cCIVTIME

  nHRS  := val(LEFT(cMILTIME,2))
  cMINS := right(cMILTIME,2)

  do case
     case (nHRS == 24 .OR. nHRS == 0) .AND. (cMINS == "00")  // Midnight
        cCIVTIME = "12:00 m"
     case (nHRS == 12)                                       // Noon to 12:59pm
        if cMINS == "00"
           cCIVTIME = "12:00 n"
        else
           cCIVTIME = "12:" + cMINS + " pm"
        endif
     case (nHRS < 12)                                    && AM
        if nHRS == 0
           cHRS = "12"
        else
           cHRS = right("  " + ltrim(str(int(nHRS))),2)
        endif
        cCIVTIME = cHRS + ":" + cMINS + " am"

  otherwise                                           && PM
     cCIVTIME = right("  " + ltrim(str(int(nHRS - 12))), 2) + ;
                ":" + cMINS + " pm"
  endcase
return cCIVTIME

/*  $DOC$
 *  $FUNCNAME$
 *     FT_CIV2MIL()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Convert usual civilian format time to military time.
 *  $SYNTAX$
 *     FT_CIV2MIL( <cCIVTIME> ) -> cMILTIME
 *  $ARGUMENTS$
 *     <cCIVTIME>  character string of form hh:mm (am,pm,n or m),
 *        where 0<hh<12.
 *  $RETURNS$
 *     <cMILTIME>  character string of form hhmm, where 0<=hh<24.
 *  $DESCRIPTION$
 *     Converts time from 12-hour civilian format to military.
 *  $EXAMPLES$
 *     FT_CIV2MIL( " 5:40 pm" ) -> 1740
 *
 *     FT_CIV2MIL( " 5:40 am" ) -> 0540
 *
 *     FT_CIV2MIL( "12:00 n" ) -> 1200
 *
 *     FT_CIV2MIL( "12:00 m" ) -> 0000
 *
 *     Caution:  leading blanks are irrelevant; p,a,n,m must be preceded by
 *               one and only one space.
 *  $SEEALSO$
 *     FT_MIL2CIV() FT_SYS2MIL() FT_MIL2MIN() FT_MIN2MIL()
 *  $END$
 */

function FT_CIV2MIL(cTIME)
  local cKEY, cMILTIME
  *** Insure leading 0's
  cTIME = REPLICATE("0", 3 - at(":", ltrim(cTIME))) + ltrim(cTIME)
  *** Adjust for popular use of '12' for first hour after noon and midnight
  if left(ltrim(cTIME),2) == "12"
     cTIME = stuff(cTIME, 1, 2, "00")
  endif
  *** am, pm, noon or midnight
  cKEY = substr(ltrim(cTIME), 7, 1)
  do case
     case upper(cKEY) == "N"                           && noon
        if left(cTIME,2) + substr(cTIME,4,2) == "0000"
           cMILTIME = "1200"
        else
           cMILTIME = "    "
        endif
     case upper(cKEY) == "M"                           && midnight
        if left(cTIME,2) + substr(cTIME,4,2) == "0000"
           cMILTIME = "0000"
        else
           cMILTIME = "    "
        endif
     case upper(cKEY) == "A"                           && am
        cMILTIME = right("00" + ltrim(str(val(left(cTIME,2)))),2) + ;
                   substr(cTIME,4,2)
     case upper(cKEY) == "P"                           && pm
        cMILTIME = right("00" + ltrim(str(val(left(cTIME,2))+12)),2) + ;
                   substr(cTIME,4,2)
     otherwise
        cMILTIME = "    "                              && error
  endcase
return cMILTIME
/*  $DOC$
 *  $FUNCNAME$
 *     FT_SYS2MIL()
 *  $CATEGORY$
 *     Date/Time
 *  $ONELINER$
 *     Convert system time to military time format.
 *  $SYNTAX$
 *     FT_SYS2MIL() -> cMILTIME
 *  $ARGUMENTS$
 *     none
 *  $RETURNS$
 *     <cMILTIME>  character string of form hhmm, where 0<=hh<24.
 *  $DESCRIPTION$
 *     Return current system time as character string in military format.
 *  $EXAMPLES$
 *     FT_SYS2MIL() -> 1623
 *  $SEEALSO$
 *     FT_MIL2CIV() FT_CIV2MIL()
 *  $END$
 */
function FT_SYS2MIL()
return left(stuff(time(),3,1,""),4)
*--------------------------------------------------------------------------------
*  TmpFile() - return the last temporary file + 1
*  Parameter:
*     ext = file extension
*--------------------------------------------------------------------------------
Function TmpFile(ext)
  Local i:=0, tmp:=""

  IF ext == NIL
     ext := ".txt"
  ENDIF
  Do While .T.
     i++
     tmp := "Temp"+Padl(i,3,"0")+ext
     If !File(tmp)
        Exit
     Endif
  Enddo
Return tmp
*-------------------------------------------------------------------------------
*  SaveScr() - Save postion of the screen
*  Parameter :
*    x1,y1,x2,y2 = x & y coordinates
*    lb  = .T. if want to draw a box otherwise false
*    bc  = background color
*  Return Value :
*    an array containing the screen coordinates, and the name of the screen
*    that has been saved.
*-------------------------------------------------------------------------------
FUNCTION SaveScr(x1,y1,x2,y2,lb, bc)
   LOCAL scr := SAVESCREEN(x1,y1,x2,y2)
   IF bc == NIL
      bc := "W+/B+"
   ENDIF
   IF lb == NIL
      lb := .F.
   ENDIF
   IF lb
      lBox(x1,y1,x2,y2,bc)
   ENDIF
RETURN {x1,y1,x2,y2,scr}
*-------------------------------------------------------------------------------
*  RestScr() - restore the screen
*  Parameter :
*    scr_ = an array of screen coordinates, and the name of the screen
*           that has been saved.
*-------------------------------------------------------------------------------
FUNCTION RestScr(scr_)
   RESTSCREEN(scr_[1],scr_[2],scr_[3],scr_[4],scr_[5])
RETURN NIL
*-------------------------------------------------------------------------------
*  lBox() - create a box
*  Parameter :
*    x1,y1,x2,y2 = screen coordinates
*    bcol        = box color
*-------------------------------------------------------------------------------
FUNCTION lBox(y1,x1,y2,x2,bcol)
   LOCAL oldcolor := SETCOLOR()
   IF bcol == NIL
      bcol := "W/B+"
   ENDIF
   SETCOLOR(bcol)
//   DISPBOX(y1,x1,y2,x2,CHR(1)+CHR(8+1))
   @ y1, x1, y2, x2 Box Replicate(" ",9)
   @ y1, x1, y2, x2 BOX B_THICK
   SETCOLOR(oldcolor)
RETURN NIL
*-------------------------------------------------------------------------------
* LoadDBF() - generic dbf loader
* Parameter :
*    adbf_ = an array of dbf and cdx
*-------------------------------------------------------------------------------
FUNCTION LoadDBF(adbf_)
   LOCAL i:=0, retval:=.F., dba, dbf, cdx, notfound_ := {}
   LOCAL bDBF := {||dba:=adbf_[i,1],dbf:=adbf_[i,2],cdx:=adbf_[i,3]}

   RDDSETDEFAULT ("DBFCDX")
   REQUEST DBFCDX

   DO WHILE i <> LEN(adbf_)
      i++
      EVAL(bDbf)
      IF !FILE(dbf)
          AADD(notfound_,dbf)
      ENDIF
      IF !FILE(cdx) .AND. !EMPTY(cdx)
          AADD(notfound_,cdx)
      ENDIF
      IF FILE(dbf)
         DbuseArea(.T.,"DBFCDX",dbf,(dba),.T.,.F.)
         IF !EMPTY(cdx)
            (dba)->(OrdListAdd(cdx))
         ENDIF
         retval := .T.
      ENDIF
   ENDDO
   IF LEN(notfound_) > 0
      lMsgBox(notfound_,,,"FILE NOT FOUND")
      DBCLOSEALL()
      retval := .F.
   ENDIF
RETURN retval
*-------------------------------------------------------------------------------
Function OpenTerm()
   LOCAL retval := .F.
   LOCAL adbf_ :={{"term","f:\crunlib\term.dbf","f:\crunlib\cdx\term.cdx"}}
   retval := LoadDBF(adbf_)
RETURN retval
*-------------------------------------------------------------------------------
FUNCTION NBox(y1,x1,y2,x2,bckcol,uprcol,lowcol)
  LOCAL scr,bcol := "/"+bckcol, oldcolor := SETCOLOR()
  SETCOLOR(bcol)
  @ y1,x1,y2,x2 BOX REPLICATE(" ",9)
  @ y1,x1 TO y1,x2 COLOR uprcol+bcol
  @ y1,x1 TO y2,x1 COLOR uprcol+bcol

  @ y2,x1 TO y2,x2 COLOR lowcol+bcol
  @ y1,x2 TO y2,x2 COLOR lowcol+bcol

  @ y1,x1 SAY "Ú" COLOR uprcol+bcol
  @ y2,x1 SAY "À" COLOR uprcol+bcol
  @ y1,x2 SAY "¿" COLOR lowcol+bcol
  @ y2,x2 SAY "Ù" COLOR lowcol+bcol
  SET(_SET_COLOR,oldcolor)
RETURN NIL
*-------------------------------------------------------------------------------

FUNCTION RefreshBrow(b)

   b:GoBottom()

   b:refreshAll()

   DO WHILE NEXTKEY() == 0 .AND. !b:stabilize()
   ENDDO

RETURN NIL

*-------------------------------------------------------------------------------

function TermEnrolled(vterm)
   local a,b

   do case
      case right(vterm,1) == "1"
           a := "1ST SEMESTER"
      case right(vterm,1) == "2"
           a := "2ND SEMESTER"
      case right(vterm,1) == "4"
           a := "SUMMER"
   endcase

   b := str(val(left(vterm,4))-1,4)+"-"+left(vterm,4)

return {a,b}

*-------------------------------------------------------------------------------

function UDF4(nMode, nElement, nRow)
   local nkey := lastkey()

   do case
      case nkey == K_ESC
           return 0
      case nkey == K_F6
           return 0
      otherwise
           return 2
   endcase
return nil

*-------------------------------------------------------------------------------

