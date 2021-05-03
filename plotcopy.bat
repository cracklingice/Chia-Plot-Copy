@ECHO off
CLS
setlocal
rem ### settings - Cannot have spaces in destination directory - EX: P:\Plots ###
rem
set destination=P:\Plots
rem
rem ### end settings do not edit below this line ###
if not %destination:~-1%==\ set destination=%destination%\
if not exist %destination% echo Destination does not exist.  Please check configuration. & pause & goto :EOF
title Chia Plot Copy %~dp0 to %destination%
echo %date% %time:~0,-3% Started Plot Copy & echo %time:~0,-3% %date% Started Plot Copy >> plotcopylog.txt
set first=1
:LOOP
FOR %%G IN (plot*.plot) DO (
  call :set %%G
  GOTO ONLYONCE
  )
:ONLYONCE
if not defined plotname goto timer
echo %date% %time:~0,-3% Plot found: starting move
:start
set _time=%time: =0%
set _hh=%_time:~0,2%
if %_hh:~0,1% equ 0 set _hh=%_time:~1,1%
set _mm=%_time:~3,2%
if %_mm:~0,1% equ 0 set _mm=%_time:~4,1%
set _ss=%_time:~6,2%
if %_ss:~0,1% equ 0 set _ss=%_time:~7,1%
set /a strt=(%_hh%*3600)+(%_mm%*60)+%_ss%
:rename
REN %plotname% %plotname%.tmp
echo %time:~0,-3% %date% Renamed %plotname% to %plotname%.tmp >> plotcopylog.txt
MOVE %plotname%.tmp %destination% > nul
echo %time:~0,-3% %date% Moved %plotname%.tmp to %destination% >> plotcopylog.txt
REN %destination%%plotname%.tmp %plotname%
echo %time:~0,-3% %date% Renamed %destination%%plotname%.tmp to %plotname% >> plotcopylog.txt
:end
set _time2=%time: =0%
set _hh2=%_time2:~0,2%
if %_hh2:~0,1% equ 0 set _hh2=%_time2:~1,1%
set _mm2=%_time2:~3,2%
if %_mm2:~0,1% equ 0 set _mm2=%_time2:~4,1%
set _ss2=%_time2:~6,2%
if %_ss2:~0,1% equ 0 set _ss2=%_time2:~7,1%
set /a end=(%_hh2%*3600)+(%_mm2%*60)+%_ss2%
set strt=%strt%
set end=%end%
if %strt% gtr %end% set /a end=%end%+86400
set /a diff=%end%-%strt%
set /a hh=%diff/3600
set /a mm=%diff%/60
:reduce
if %mm% gtr 60 set /a mm=%mm%-60 & goto reduce
set /a ss=(%diff%-(%diff%/60*60))
set timess=
if %ss% gtr 0 set "timess= %ss% second"
if %ss% gtr 1 set "timess= %ss% seconds"
set timemm=
if %mm% gtr 0 if %mm% lss 60 set "timemm= %mm% minute"
if %mm% gtr 1 if %mm% lss 60 set "timemm= %mm% minutes"
set timehh=
if %hh% gtr 0 set "timehh= %hh% hour"
if %hh% gtr 1 set "timehh= %hh% hours"
if %hh% gtr 0 set "timed=%timehh%"
if %mm% gtr 0 set "timed=%timed%%timemm%"
if %ss% gtr 0 set "timed=%timed%%timess%"
:outputtaskcompletiontime
find /c "%date% Moved" plotcopylog.txt > copylog.tmp
for /f "delims=" %%x in (copylog.tmp) do set times=%%x
set times=%times:~28,4%
echo %date% %time:~0,-3% Plot moved in%timed%. %times% Plots moved today. & echo %time:~0,-3% %date% Plot moved in%timed%. %times% Plots moved today. >> plotcopylog.txt
del copylog.tmp
set plotname=
set timed=
goto loop
goto :eof
:timer
timeout /t 60 /nobreak > nul
goto loop
goto :eof
:set
set plotname=%1
goto :eof
endlocal