@echo off
REM ============================================================
REM Authentication System Testing Script (Windows Batch)
REM 
REM Usage: run-tests.bat
REM
REM This script performs all critical tests for the auth system
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo  Therapy Booking Backend - Test Suite
echo ============================================================
echo.

set API_URL=http://localhost:8000
set PASS_COUNT=0
set FAIL_COUNT=0

REM ============================================================
REM Test 1: Registration - Doctor
REM ============================================================
echo [TEST 1] Registration - Doctor
echo.

set TIMESTAMP=%RANDOM%
set EMAIL=doctor_%TIMESTAMP%@test.com
set PASSWORD=DocPass123
set FULLNAME=Dr. Test User
set USERTYPE=doctor

for /f "delims=" %%i in ('powershell -Command "[System.DateTime]::Now.Ticks"') do set TIMESTAMP=%%i
set EMAIL=doctor_%TIMESTAMP%@test.com

echo Request:
echo   POST %API_URL%/api/auth/register
echo   Email: %EMAIL%
echo   Password: %PASSWORD%
echo   UserType: %USERTYPE%
echo   FullName: %FULLNAME%
echo.

powershell -Command ^
  "$response = Invoke-WebRequest -Uri '%API_URL%/api/auth/register' -Method POST -ContentType 'application/json' -Body '{\"email\":\"%EMAIL%\",\"password\":\"%PASSWORD%\",\"userType\":\"%USERTYPE%\",\"fullName\":\"%FULLNAME%\"}' -UseBasicParsing 2>&1; ^
   Write-Host 'Status: ' $response.StatusCode; ^
   Write-Host 'Response: ' $response.Content; ^
   if ($response.StatusCode -eq 201) { Write-Host 'PASS' -ForegroundColor Green } else { Write-Host 'FAIL' -ForegroundColor Red }"

echo.
echo ============================================================
echo Note: For complete testing, use:
echo - Postman (import provided collection)
echo - PowerShell scripts in tests/ directory
echo - cURL commands in QUICK_START.md
echo ============================================================
echo.

pause
