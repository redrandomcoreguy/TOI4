@echo off
rem Installs the "toi4" command on Windows: double-click this file, or run install.bat in a terminal.
rem Remove it again with:  install.bat --uninstall   (or: toi4 --uninstall)
rem It finds Python 3.8 to 3.14, adds windows-curses if Python lacks curses, then runs: toi4.py --install --tidy
rem Installing also tidies this folder: it deletes .git, LICENSE and README.md, so only the game is left.
rem (A .git folder with commits that aren't on GitHub yet is kept.)
setlocal
set "PAUSE_AT_END="
echo %cmdcmdline% | findstr /i /c:"%~nx0" >nul && set "PAUSE_AT_END=1"
set "GAME=%~dp0toi4.py"
if not exist "%GAME%" (
    echo Can't find toi4.py next to install.bat.
    goto fail
)

set "PY="
for %%V in (3.14 3.13 3.12 3.11 3.10 3.9 3.8) do (
    if not defined PY (
        py -%%V -c "import sys" >nul 2>&1 && set "PY=py -%%V"
    )
)
if not defined PY (
    python -c "import sys; sys.exit(not (3, 8) <= sys.version_info[:2] <= (3, 14))" >nul 2>&1 && set "PY=python"
)
if not defined PY (
    echo Python 3.8 to 3.14 wasn't found.
    echo Get Python 3.14 from https://www.python.org/downloads/windows/ and tick "Add python.exe to PATH".
    echo Python 3.15 doesn't work yet: windows-curses, which the game needs, isn't out for it yet.
    goto fail
)

if /i "%~1"=="--uninstall" (
    %PY% "%GAME%" --uninstall
    goto done
)
%PY% -c "import curses" >nul 2>&1
if errorlevel 1 (
    echo Installing windows-curses, which Python on Windows needs for terminal games...
    %PY% -m pip install --user windows-curses
    if errorlevel 1 goto fail
)
%PY% "%GAME%" --install --tidy
if errorlevel 1 goto fail

:done
if defined PAUSE_AT_END pause
exit /b 0

:fail
echo Installation failed.
if defined PAUSE_AT_END pause
exit /b 1
