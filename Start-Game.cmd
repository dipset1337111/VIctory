@echo off
setlocal
set "game=C:\Project Leonida\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe"
if not exist "%game%" goto missing
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0br\target\release\Run-Walk.ps1" -Game "%game%"
pause
exit /b
:missing
echo Game file not found: "%game%"
pause
exit /b 1
