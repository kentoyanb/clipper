# Include "grump.ch"
# Include "shadowb.ch"
# Include "setcurs.ch"
# Include "inkey.ch"
# Include "Tbrowse.ch"
# Include "Abrowse.ch"
# Include "dbinfo.ch"
# Include "box1.ch"
# Include "achoice.ch"
# Define  Y_BLUE    "GR+/B"         // Yellow text, Blue background
# Define  W_MAGE    "+W/RB"         // White text, Magenta background
# Define  W_BLUE    "+W/B"          // White text, Blue background
# Define  GET_COLOR "+W/R,+W/R"   // Get color
# Define  CLABEL    "+W/BG"
# Define  MTR_INCREMENT 10
# Define  FMESSAGE1 "    ESC - Previous         F4 - Lookup       F3 - Update      F9 - Recover    "
# Define  FMESSAGE2 "    F6 - Print Study Load  F7 - W/During     F8 - W/After     F10 - Save      "
# Define  SUB_CLOSE    "is already close."
# Define  SUB_CONFLICT "is conlict with "
# Define  SUB_DUPLICATE "is already entered."

Function Menu
   Local nch:=0, ach1_:={}, nrow:=0, ren:=0, course,sect,skdcod,i
   LOCAL ach_ :={;
    {" Entry"                                         , {||prj06()      }},;
    {" Print Study Load"                              , {||prj01()      }},;
    {" Print Grade Sheet"                             , {||prj03("p")   }},;
    {" Grade Entry"                                   , {||prj03("e")   }},;
    {" Transcript of Records Laser(8.5 x 14)"         , {||prj05()      }},;
    {" Transcript of Records Laser(8.5 x 12)"         , {||prj05a()     }},;
    {" Index All Moving Files"                        , {||IMFile()     }},;
    {" Index All Fix Files"                           , {||IFFile()     }},;
    {" Grade Printing"                                , {||prj07()      }},;
    {" Withdraw from STSP"                            , {||prj08()      }},;
    {" Form XIX"                                      , {||prj09("f19") }},;
    {" Enrollment list"                               , {||prj09("el")  }},;
    {" Students Enrolled by Term & Subject"           , {||prj10()      }},;
    {" Instructor Load"                               , {||prj11("l")   }},;
    {" Instructor Schedule"                           , {||prj11("s")   }},;
    {" Students Enrolled by Term & Date Enrolled"     , {||prj12()      }},;
    {" Students Enrolled by Term/Course/Level/Status" , {||prj13()      }},;
    {" Forward to STSP"                               , {||prj19()      }},;
    {" Temporary Study Load Printing"                 , {||prj14()      }},;
    {" NROTC Grade Printing"                          , {||prj15()      }},;
    {" Summary of Subject Schedule Block/Alpha"       , {||prj16()      }},;
    {" Teacher's Load Entry"                          , {||prj17()      }},;
    {" List of Teachers with Load"                    , {||prj18()      }},;
    {" Summary of closed subjects"                    , {||prj20("C")   }},;
    {" Summary of subject without Instructor"         , {||prj20("I")   }},;
    {" Summary of students by classification"         , {||prj21()      }},;
    {" Daily enrollment statistics"                   , {||prj22()      }},;
    {" Curricullum Entry"                             , {||prj23()      }},;
    {" Schedule Entry"                                , {||prj24()      }},;
    {" Browse Subject Status"                         , {||prj25("20021")}},;
    {" Summary of Room Utilization"                   , {||prj26() }},;
    {" Mark dissolve subjects"                        , {||prj27() }},;
    {" Browse Students Address"                       , {||prj28() }},;
    {" Revert Student Status"                         , {||prj29() }},;
    {" List of Student with Enrollment Cancelled"     , {||prj30() }},;
    {" List of Subject by Schedule"                   , {||prj31() }},;
    {" Students Enrolled by Term w/ Units"            , {||prj32() }},;
    {" Recalculate Actual Size"                       , {||prj35() }},;
    {" Block Section Entry"                           , {||prj36(.T.,space(5),space(3),space(2),space(5),.t.,.t.) }},;
    {" Arrange Merge Subject"                         , {||prj37()}},;
    {" Student Mailing Grade"                         , {||prj38()}},;
    {" Browse Student Enrollment History"             , {||prj39()}},;
    {" Consolidate Double ID number to One"           , {||prj40()}},;
    {" Removal From Dissolve Subjects"                , {||prj41()}},;
    {" List of Students Withdrawn"                    , {||prj42()}},;
    {" Dean's List"                                   , {||prj43()}},;
    {" Copy SKDCOD from SKDP file to SECP file"       , {||prj44()}},;
    {" Hold Student"                                  , {||prj45()}},;
    {" Append New Student from ENRP to ACCP"          , {||prj46()}},;
    {" List of Hold Students"                         , {||prj47()}},;
    {" New Enrollment List"                           , {||prj48()}},;
    {" Grade/Clearance Acknowledgment Sheet"          , {||prj49()}},;
    {" Form IX"                                       , {||prj50()}}}

   cls

   set century on
   set epoch to 1980
   Set Scoreboard OFf
   SET(_SET_DELETED,.T.)
//   prj06()

   AEVAL(ach_,{|ele| AADD(ach1_,ele[1])})
//   ASORT(ach1_)
   Do While .T.
      nch := aChoice(0,0,23,79,ach1_,.T.,,nrow)
      IF nch == 0
         EXIT
      ELSE
         EVAL(ach_[nch,2])
      ENDIF
      nrow := nch
   Enddo

   CLS
   Set Color To
Return Nil
*-------------------------------------------------------------------------------
STATIC FUNCTION OpenDB(vterm)
   LOCAL retval := .F.
   LOCAL adbf_ :={;
       {"skdp", "f:\sc\hoyla\c"+Substr(vTerm,3,3)+"skdp.dbf",;
        "f:\sc\hoyla\cdx\c"+Substr(vTerm,3,3)+"skdp.cdx"},;
       {"secp", "f:\sc\hoyla\c"+Substr(vTerm,3,3)+"secp.dbf",;
        "f:\sc\hoyla\cdx\c"+Substr(vTerm,3,3)+"secp.cdx"}}
    retval := LoadDBF(adbf_)
RETURN retval
*-------------------------------------------------------------------------------
