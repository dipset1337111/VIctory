@echo off
setlocal
set "root=C:\Project Leonida\NVIDIA-Test"
set "game=C:\Project Leonida\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe"
if not exist "%root%\victory-watchdog.exe" goto missing
if not exist "%root%\D3D12\D3D12Core.dll" goto missing
if not exist "%game%" goto missing
cd /d "%root%" || goto missing
set "VICTORY_NO_WATCHDOG=1"
set "VICTORY_HOME=%root%\SeriesS-Check"
set "VICTORY_CACHE_DIR=%root%\NVIDIA-Test\cache"
set "VICTORY_DATA_DIR=%root%\NVIDIA-Test\data"
set "VICTORY_STREAMLINE_DIR=%root%\NVIDIA-Test\nvidia-sdk\Streamline\bin\x64"
if not exist "%VICTORY_HOME%" mkdir "%VICTORY_HOME%"
if not exist "%VICTORY_HOME%" goto missing
> "%VICTORY_HOME%\victory-settings.txt" echo VICTORY_MENU_CONSOLE=series-s
>> "%VICTORY_HOME%\victory-settings.txt" echo VICTORY_MENU_FRAMEGEN=1
>> "%VICTORY_HOME%\victory-settings.txt" echo VICTORY_MENU_DLSS=quality
>> "%VICTORY_HOME%\victory-settings.txt" echo VICTORY_MFG_UNLOCKER=0
"%root%\victory-watchdog.exe" play "%game%" --series-s --dlss quality --framegen --set VICTORY_WARMUP_RESTART=0 --set VICTORY_NO_WATCHDOG=1
echo Exit code: %errorlevel%
echo Logs: "%VICTORY_HOME%\logs"
pause
exit /b
:missing
echo Could not open the installed game, NVIDIA test folder, or D3D12 runtime.
pause
