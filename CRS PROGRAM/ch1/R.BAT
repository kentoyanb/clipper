@ echo off
cls
clipper %1 
rtlink fi %1,sysfnc,elfnc,boxfnc /pll:base52
pause
%1
