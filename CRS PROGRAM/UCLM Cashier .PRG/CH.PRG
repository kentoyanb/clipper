# include "INKEY.CH"
# include "DBINFO.CH"
# include "BOX.CH"
# include "SETCURS.CH"

Function cashier(mSerial)   // pass machine serial number (mSerial)

 Local oldscreen
 Local oldcolor
 Local counter,ar :={},l
 Local username   :=space(08)
 Local info       := {}
 Local cSN        :=space(15)

 Local file_menu  := {{"@Payment Code Entry      "}  ,;
                      {"@Cashier User Name Entry "}  ,;
                      {"@Reprint / Cancel payment"}  ,;
                      {"@Move payment to other term"},;
                      {"M@ove payment to other account file"},;
                      {"@Exit Terminate    "} }

 Local file_opr    := { {|| if(cpassword({7},@username) ,ch01(),.F.)},;
                        {|| if(cpassword({8,9},@username) ,ch02(),.F.)},;
                        {|| if(cpassword({9},@username) ,chmain(),.F.)},;
                        {|| if(cpassword({7,8,9},@username) ,chmove(),.F.)},;
                        {|| if(cpassword({7,8,9},@username) ,chtran(),.F.)},;
                        {|| tone(500)   }  }


 Local pay_men :=        {{"@U.C.L.M. College Account    "} , ;
                          {"@Elementary & High School    "} , ;
                          {"@Short Course Accounts       "} , ;
                          {"@M.E.T.C. Nautical & Marine  "} , ;
                          {"M@iscellaneous & Other Income"} , ;
                          {"@Return to Main Menu         "}}

 Local pay_opr :=        {{|| if(cpassword({7,8,9},@username),ch03a(username),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),ch03b(username),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),ch03d(username),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),ch03c(username),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),ch03e(username),.F.)}, ;
                          {|| tone(500)   }  }

 Local rep_menu   :=     {{"@Summary of Daily Collection (List)      "} ,;
                          {"@General informative report of collection"} ,;
                          {"Summary of @Cancelled Payment            "} ,;
                          {"Summary of @Daily Collection (By Cashier)"} ,;
                          {"Summary @of all payments student's account"},;
                          {"@Return to Main Menu       "}}

 Local rep_opr :=        {{|| if(cpassword({7,8,9},@username),chrep01(),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),chrep03(),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),chrep04(),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),chrep05(),.F.)}, ;
                          {|| if(cpassword({7,8,9},@username),chrep06(),.F.)},;
                          {|| tone(500)   }}

 Local chmenu     := {{"@Payments Entry    "} , ;
                      {"@Summary & Reports "} , ;
                      {"@File Maintainance "} , ;
                      {"@Exit Terminate    "} }

 Local chmenuopr  :=  { {|| menu(7,5,"Payment Classifications Menu",pay_men,pay_opr)}, ;
                        {|| menu(8,10,"Summary and Reports",rep_menu,rep_opr)         }, ;
                        {|| menu(5,5,"File Maintainance Menu",file_menu,file_opr ) }, ;
                        {|| tone(500)   }  }


//bParent()

//aadd(ar,{"one","two"})
//aadd(ar,{"three","four"})
//aadd(ar,{"five","six"})
//l := ascan(ar,{|a| a[1] == "five"})
//? l
//? ar[l,1],ar[l,2]
//quit

  memvar->cSN := mSerial

  SET(_SET_SCOREBOARD, .F.)
  SET(_SET_DELETED,    .T.)
  SET(_SET_DATEFORMAT,"MM/DD/YYYY")
  oldcolor := setcolor()
  setcolor("W/B")
  oldscreen := SaveScr(1,0,maxrow(),maxcol(),.T.)
  @ 0, 0 Say " ON LINE CASHIER SYSTEM - UNIVERSITY OF CEBU (LAPU-LAPU AND MANDAUE)*                " COLOR "W+/R+"
  For Counter := 2 to maxrow()-4
   @  Counter,1 say replicate("°",maxcol()-1)
  Next
  setcolor(oldcolor)

  oldcolor := setcolor()
  setcolor("W+/B")
// @ 01,2 say PADC("University of Cebu Lapulapu & Mandaue",maxcol()-3,"")
// @ 02,2 say PADC("A.C. Cortes Avenue, Mandaue City Philippines 6014.",maxcol()-3,"")
// @ 03,2 say PADC("®® Cashier System ¯¯",maxcol()-3,"")

 @ 21,2 say PADR("By: Tope J. Esguerra & Leonardo Hoyla Jr."+space(07)+;
        "NET-ID: "+getenv("STATION"),maxcol()-3,"")
 @ 22,2 say PADR("All Rights Reserved"+space(30)+"  USER: "+getenv("USER"),;
        maxcol()-3,maxcol()-3,"")
 @ 23,2 say PADR("Copyright (c) 2000-2001 Version 1."+;
        space(13)+"TODAY IS: "+cmonth(date())+;
        space(01)+trim(transform(DAY(date()),"99"))+","+;
        space(01)+trim(transform(YEAR(date()),"9999")),maxcol()-3,"")
   setcolor(oldcolor)
   RDDSETDEFAULT("DBFCDX")
   REQUEST DBFCDX
    if is_valid_copy() == .T.

       if empty(memvar->cSN)
          lmsgbox({"Machine Serial # not found . . ."})
       else
          menu(3,3,"CASHIER MAIN MENU",chmenu,chmenuopr)
       endif
    endif
   SET(_SET_SCOREBOARD, .T.)
   SET(_SET_CURSOR, SC_NORMAL)
   RestScr(oldscreen)
   CLS
Return Nil


