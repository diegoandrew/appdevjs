@echo off



:: Before running we need to see if the user has Java in their path.
:: Instructions here
:: http://introcs.cs.princeton.edu/java/15inout/windows-cmd.html
:: Ignore the part about the JDK. The JRE will be fine for our purposes
:: Note, on 64-bit Windows, my path was:
:: C:\Program Files (x86)\Java\jre7\bin
call java -version >NUL 2>&1 || (echo Java not found. Please install or ensure it is in your path. & GOTO:EOF)


:: current directory at time of execution (cleanup will return here)
set _=%CD%

:: set path to script path
cd %~dps0

:: grab the root directory
:: (assumes we are in ROOT/documentation/instdocs.bat)
:: basename command from:
:: http://stackoverflow.com/a/3432895/1026991
cd ../
set FILE=%CD%
for /F %%i in ("%FILE%") do set BASENAME=%%~ni
echo %BASENAME%
set ROOT=%BASENAME%
cd %~dp0




echo setup...

rd /Q/S ..\..\documentjs > nul
rd /Q/S ..\..\steal > nul
rd /Q/S ..\..\%ROOT%_back > nul

xcopy /Q/S/I ..\web\scripts\documentjs ..\..\documentjs
xcopy /Q/S/I ..\web\scripts\steal ..\..\steal
xcopy /Q/S/I summary.ejs ..\

md ..\..\%ROOT%_back
move /Y ..\server\node_modules ..\..\%ROOT%_back\
move /Y ..\server\test ..\..\%ROOT%_back\


del /Q docs.html > nul
rd /Q/S docs > nul


cd ..\..\

echo rendering docs...
call documentjs\doc.bat %ROOT% > %~dps0\docs_output.txt


::path correction in docs

echo make path corrections
%~dps0\sed -e "s/\.\.\//\.\.\/web\/scripts\//" %~dps0\..\docs.html > %~dps0\docs.html
move %~dps0\..\docs %~dps0\docs


::cleanup

echo cleanup...
move /Y %ROOT%_back\node_modules %ROOT%\server\
move /Y %ROOT%_back\test %ROOT%\server\
rd /Q/S %ROOT%_back
rd /Q/S documentjs
rd /Q/S steal
del /Q %ROOT%\summary.ejs > nul
del /Q %ROOT%\docs.html
:: Return to starting directory
cd  %_%
