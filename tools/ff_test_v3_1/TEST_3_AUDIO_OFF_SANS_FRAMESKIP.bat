@echo off
call "%~dp0LANCER_TEST_FF.bat" OFF_NOSKIP "%~1"
exit /b %ERRORLEVEL%
