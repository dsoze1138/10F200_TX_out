@echo off
@if "%1."=="." goto End
@pushd %1
@echo Cleaning folder: %1
REM Remove files generated by compiler

rem Removing *.$$$ files...
if exist *.$$$ del *.$$$ /f /q

rem Removing *.bkx files...
if exist *.bkx del *.bkx /f /q

rem Removing *.cod files...
if exist *.cod del *.cod /f /q

rem Removing *.cof files...
if exist *.cof del *.cof /f /q

rem Removing *.i files...
if exist *.i del *.i /f /q

rem Removing *.obj files...
if exist *.obj del *.obj /f /q

rem Removing *.err files...
if exist *.err del *.err /f /q

rem Removing *.o files...
if exist *.o del *.o /f /q

rem Removing *.rlf files...
if exist *.rlf del *.rlf /f /q

rem Removing *.sym files...
if exist *.sym del *.sym /f /q

rem Removing *.sdb files...
if exist *.sdb del *.sdb /f /q

rem Removing *.lst files...
if exist *.lst del *.lst /f /q

rem Removing *.wat files...
if exist *.wat del *.wat /f /q

rem Removing *.cce files...
if exist *.cce del *.cce /f /q

rem Removing *.lde files...
if exist *.lde del *.lde /f /q

rem Removing *.hxl files...
if exist *.hxl del *.hxl /f /q

rem Removing *.i files...
if exist *.i del *.i /f /q

rem Removing untitled.mcw file...
if exist untitled.mcw del untitled.mcw /f /q

rem Removing *.map files...
if exist *.map del *.map /f /q

rem Removing *.elf files...
if exist *.elf del *.elf /f /q

rem Removing *.mptags files...
if exist *.mptags del *.mptags /f /q

rem Removing *.tagsrc files...
if exist *.tagsrc del *.tagsrc /f /q

rem Removing MPLAB 8 files...
for %%I IN (*.mcp) do if exist %%~nI.mcs del %%~nI.mcs /f /q
for %%I IN (*.mcp) do if exist %%~nI.mcw del %%~nI.mcw /f /q

rem Removing XC8 and HTC compiler files...
if exist *.d   del *.d   /f /q
if exist *.p1  del *.p1  /f /q
if exist *.pre del *.pre /f /q
if exist *.dep del *.dep /f /q
if exist funclist del funclist /f /q
if exist startup.as del startup.as /f /q
for %%I IN (*.mcp) do if exist %%~nI.cmf del %%~nI.cmf /f /q
for %%I IN (*.mcp) do if exist %%~nI.as del %%~nI.as /f /q

rem Removing *.hex files...
if exist *.hex del *.hex /f /q

rem Removing RIUSBLogFile.txt files...
if exist RIUSBLogFile.txt del RIUSBLogFile.txt /f /q

@popd
:End
