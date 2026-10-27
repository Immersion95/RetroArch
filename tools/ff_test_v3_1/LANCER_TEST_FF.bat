@echo off
setlocal EnableExtensions DisableDelayedExpansion
title RetroArch - test fast-forward V3.1
set "RA_MODE=%~1"
set "RA_EXE=%~2"
set "RA_FF_TEST_FRAMESKIP="
set "RA_EXPECT_SKIP=-1"
set "RA_VALIDATOR=%~dp0VERIFIER_CAPTURE.ps1"
if /I "%RA_MODE%"=="ON" goto mode_on
if /I "%RA_MODE%"=="OFF" goto mode_off
if /I "%RA_MODE%"=="OFF_NOSKIP" goto mode_noskip
echo ERREUR : lancer TEST_1_AUDIO_ON.bat ou TEST_2_AUDIO_OFF.bat.
goto failure
:mode_on
set "RA_FF_TEST_AUDIO=1"
set "RA_AUDIO_BOOL=true"
set "RA_FF_TEST_CASE=audio_on"
goto select_exe
:mode_noskip
set "RA_FF_TEST_FRAMESKIP=0"
set "RA_EXPECT_SKIP=0"
:mode_off
set "RA_FF_TEST_AUDIO=0"
set "RA_AUDIO_BOOL=false"
set "RA_FF_TEST_CASE=audio_off"
if /I "%RA_MODE%"=="OFF_NOSKIP" set "RA_FF_TEST_CASE=audio_off_noskip"
:select_exe
if defined RA_EXE goto exe_selected
if exist "%~dp0retroarch_ff_test_v3_1.exe" set "RA_EXE=%~dp0retroarch_ff_test_v3_1.exe"
if defined RA_EXE goto exe_selected
echo Selectionner retroarch_ff_test_v3_1.exe du nouveau build GitHub Actions.
set /p "RA_EXE=Glisser cet executable ici, puis Entree : "
if not defined RA_EXE goto no_exe
:exe_selected
set "RA_EXE=%RA_EXE:"=%"
for %%I in ("%RA_EXE%") do set "RA_EXE=%%~fI"
if not exist "%RA_EXE%" goto no_exe
if exist "%RA_EXE%\*" goto no_exe
if not exist "%RA_VALIDATOR%" goto no_validator
:new_capture
set "RA_CAPTURE=%~dp0captures_ff_v3_1\%RA_FF_TEST_CASE%_%RANDOM%_%RANDOM%"
if exist "%RA_CAPTURE%" goto new_capture
mkdir "%RA_CAPTURE%"
if errorlevel 1 goto capture_error
set "RA_FRAME_TRACE=1"
set "RA_FRAME_TRACE_FILE=%RA_CAPTURE%\retroarch_frame_trace.csv"
>"%RA_CAPTURE%\test.cfg" echo config_save_on_exit = "false"
>>"%RA_CAPTURE%\test.cfg" echo audio_enable = "%RA_AUDIO_BOOL%"
if /I "%RA_MODE%"=="OFF_NOSKIP" >>"%RA_CAPTURE%\test.cfg" echo fastforward_frameskip = "false"
echo.
echo Test : %RA_FF_TEST_CASE%
echo Meme jeu, meme core, meme renderer pour tous les essais.
echo Charger le jeu et commencer dans un passage fluide, puis presser F12.
echo 4 s normales, 1-2 s avance rapide, 5 s normales.
echo Ouvrir le menu 1-2 s, fermer, jouer 5 s, puis quitter normalement.
echo Ne pas sauvegarder de configuration ou d'override pendant le test.
echo.
for %%I in ("%RA_EXE%") do pushd "%%~dpI"
if errorlevel 1 goto capture_error
if exist "build-info.txt" copy /y "build-info.txt" "%RA_CAPTURE%\build-info.txt" >nul
"%RA_EXE%" --appendconfig "%RA_CAPTURE%\test.cfg" --verbose --log-file "%RA_CAPTURE%\retroarch.log"
set "RA_EXIT=%ERRORLEVEL%"
popd
powershell.exe -NoLogo -NoProfile -Command "$code = [IO.File]::ReadAllText($env:RA_VALIDATOR); & ([scriptblock]::Create($code)) -CaptureDirectory $env:RA_CAPTURE -ExpectedAudio $env:RA_FF_TEST_AUDIO -ExpectedFrameskip $env:RA_EXPECT_SKIP -Executable $env:RA_EXE -ProgramExit $env:RA_EXIT"
set "RA_CHECK=%ERRORLEVEL%"
if not "%RA_CHECK%"=="0" echo Verification incomplete ou echouee : lire le resultat ci-dessus.
echo.
pause
exit /b %RA_CHECK%
:no_exe
echo ERREUR : executable V3_1 introuvable. Telecharger le nouveau build Actions.
goto failure
:no_validator
echo ERREUR : VERIFIER_CAPTURE.ps1 manque a cote des BAT.
goto failure
:capture_error
echo ERREUR : impossible de preparer le dossier de capture ou le lancement.
:failure
echo.
pause
exit /b 1
