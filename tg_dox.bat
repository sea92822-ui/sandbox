@echo off
chcp 65001 >nul
title TG DOX v4.0 - SHERLOCK + PHONE
color 0A

echo ============================================
echo  TG DOX v4.0 - SHERLOCK + PHONE
echo ============================================
echo.

echo 1 - Poisk po username
echo 2 - Poisk po nomeru telefona
echo.
set /p mode="Vyberi (1/2): "

if "%mode%"=="1" (
    set /p query="Vvedite username Telegram (bez @): "
    if "%query%"=="" goto error
    set script=%~dp0sherlock_check.ps1
    powershell -ExecutionPolicy Bypass -File "%script%" -username "%query%"
    goto end
)

if "%mode%"=="2" (
    echo.
    echo Primery formatov:
    echo   +48 794 607 124  (Poland)
    echo   79123456789      (Russia)
    echo   1234567890       (USA)
    echo.
    set /p query="Vvedite nomer telefona (s probelami ili bez): "
    if "%query%"=="" goto error
    set script=%~dp0phone_check.ps1
    powershell -ExecutionPolicy Bypass -File "%script%" -phone "%query%"
    goto end
)

echo Oshibka: vyberi 1 ili 2
pause
exit /b

:error
echo Oshibka: pustoy zapros!
pause
exit /b

:end
pause
