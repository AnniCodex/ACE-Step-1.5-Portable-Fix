@echo off
cd /d "%~dp0"

set "LOG=%~dp0fix_ace_step.log"
> "%LOG%" echo ACE-Step 1.5 Fix Log
>> "%LOG%" echo.

echo ========================================
echo  ACE-Step 1.5 - Post-Extraction Fix
echo ========================================
echo.
echo Log: %LOG%
echo.
echo Press any key to start...
pause >nul

REM ============================================
REM STEP 1 - Python folder
REM ============================================
echo.
echo [1/6] Python folder... & echo [1/6] Python folder... >> "%LOG%"
set "PY=%~dp0python_embedded\python.exe"
if not exist "%PY%" goto :s1_ren
echo   OK: already correct & echo   OK: already correct >> "%LOG%"
goto :s2

:s1_ren
if not exist "%~dp0python_embeded\python.exe" goto :s1_err
echo   Renaming... & echo   Renaming... >> "%LOG%"
ren "%~dp0python_embeded" "python_embedded"
timeout /t 2 /nobreak >nul
if exist "%PY%" goto :s1_ok
echo   ERR: rename failed & echo   ERR: rename failed >> "%LOG%"
goto :s2

:s1_ok
echo   OK: renamed & echo   OK: renamed >> "%LOG%"
goto :s2

:s1_err
echo   ERR: no python folder & echo   ERR: no python folder >> "%LOG%"

REM ============================================
REM STEP 2 - Git
REM ============================================
:s2
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo [2/6] Git... & echo [2/6] Git... >> "%LOG%"
set "GIT="
if exist "%~dp0PortableGit\bin\git.exe" goto :s2_port
where git >nul 2>&1
if errorlevel 1 goto :s2_err
for /f "tokens=*" %%i in ('where git') do if not defined GIT set "GIT=%%i"
echo   OK: system git & echo   OK: system git >> "%LOG%"
goto :s3

:s2_port
set "GIT=%~dp0PortableGit\bin\git.exe"
echo   OK: PortableGit & echo   OK: PortableGit >> "%LOG%"
goto :s3

:s2_err
echo   ERR: git not found & echo   ERR: git not found >> "%LOG%"

REM ============================================
REM STEP 3 - Git config
REM ============================================
:s3
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo [3/6] Git config... & echo [3/6] Git config... >> "%LOG%"
if not defined GIT goto :s3_skip
if not exist "%~dp0.git" goto :s3_nogit
"%GIT%" config --local --unset http.proxy >nul 2>&1
"%GIT%" config --local --unset https.proxy >nul 2>&1
echo   OK: proxy removed & echo   OK: proxy removed >> "%LOG%"
"%GIT%" remote set-url origin https://github.com/ace-step/ACE-Step-1.5.git >nul 2>&1
echo   OK: remote https & echo   OK: remote https >> "%LOG%"
goto :s4

:s3_skip
echo   SKIP: no git & echo   SKIP: no git >> "%LOG%"
goto :s4

:s3_nogit
echo   SKIP: no .git & echo   SKIP: no .git >> "%LOG%"

REM ============================================
REM STEP 4 - pip
REM ============================================
:s4
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo [4/6] pip... & echo [4/6] pip... >> "%LOG%"
if not exist "%PY%" goto :s4_nopy
"%PY%" -m pip --version >nul 2>&1
if not errorlevel 1 goto :s4_ok
echo   Installing pip... & echo   Installing pip... >> "%LOG%"
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%~dp0get-pip.py' -UseBasicParsing } catch { exit 1 }" >nul 2>&1
if not exist "%~dp0get-pip.py" goto :s4_dl
"%PY%" "%~dp0get-pip.py" >nul 2>&1
del "%~dp0get-pip.py" >nul 2>&1
"%PY%" -m pip --version >nul 2>&1
if errorlevel 1 goto :s4_fail

:s4_ok
echo   OK: pip available & echo   OK: pip available >> "%LOG%"
goto :s5

:s4_dl
echo   ERR: download failed & echo   ERR: download failed >> "%LOG%"
goto :s5

:s4_fail
echo   ERR: pip install failed & echo   ERR: pip install failed >> "%LOG%"
goto :s5

:s4_nopy
echo   ERR: python not found & echo   ERR: python not found >> "%LOG%"

REM ============================================
REM STEP 5 - DCW
REM ============================================
:s5
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo [5/6] DCW... & echo [5/6] DCW... >> "%LOG%"
if not exist "%PY%" goto :s5_skip
"%PY%" -m pip --version >nul 2>&1
if errorlevel 1 goto :s5_skip
"%PY%" -c "import pywt" >nul 2>&1
if not errorlevel 1 goto :s5_pywt_ok
echo   Installing PyWavelets... & echo   Installing PyWavelets... >> "%LOG%"
"%PY%" -m pip install --quiet PyWavelets >nul 2>&1
:s5_pywt_ok
"%PY%" -c "import pywt" >nul 2>&1
if errorlevel 1 goto :s5_pywt_err
echo   OK: PyWavelets & echo   OK: PyWavelets >> "%LOG%"
goto :s5_ptw
:s5_pywt_err
echo   ERR: PyWavelets & echo   ERR: PyWavelets >> "%LOG%"
:s5_ptw
"%PY%" -c "import pytorch_wavelets" >nul 2>&1
if not errorlevel 1 goto :s5_ptw_ok
echo   Installing pytorch_wavelets... & echo   Installing pytorch_wavelets... >> "%LOG%"
"%PY%" -m pip install --quiet git+https://github.com/fbcotter/pytorch_wavelets >nul 2>&1
:s5_ptw_ok
"%PY%" -c "import pytorch_wavelets" >nul 2>&1
if errorlevel 1 goto :s5_ptw_err
echo   OK: pytorch_wavelets & echo   OK: pytorch_wavelets >> "%LOG%"
goto :s6
:s5_ptw_err
echo   WARN: pytorch_wavelets & echo   WARN: pytorch_wavelets >> "%LOG%"
goto :s6
:s5_skip
echo   SKIP: pip unavailable & echo   SKIP: pip unavailable >> "%LOG%"

REM ============================================
REM STEP 6 - Update
REM ============================================
:s6
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo [6/6] Update... & echo [6/6] Update... >> "%LOG%"
if not defined GIT goto :s6_skip
if not exist "%~dp0.git" goto :s6_nogit
"%GIT%" fetch origin >nul 2>&1
if errorlevel 1 goto :s6_fetch
for /f "tokens=*" %%i in ('"%GIT%" rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH=%%i"
if "%BRANCH%"=="" set "BRANCH=main"
if /i "%BRANCH%"=="HEAD" set "BRANCH=main"
for /f "tokens=*" %%i in ('"%GIT%" rev-parse --short HEAD 2^>nul') do set "LOCAL=%%i"
for /f "tokens=*" %%i in ('"%GIT%" rev-parse --short origin/%BRANCH% 2^>nul') do set "REMOTE=%%i"
if "%REMOTE%"=="" set "REMOTE=%LOCAL%"
echo   Branch: %BRANCH% & echo   Branch: %BRANCH% >> "%LOG%"
echo   Current: %LOCAL% & echo   Current: %LOCAL% >> "%LOG%"
echo   Remote: %REMOTE% & echo   Remote: %REMOTE% >> "%LOG%"
if "%LOCAL%"=="%REMOTE%" goto :s6_ok
echo   Updating... & echo   Updating... >> "%LOG%"
"%GIT%" stash push -m "auto-backup" >nul 2>&1
"%GIT%" reset --hard origin/%BRANCH% >nul 2>&1
if errorlevel 1 goto :s6_err
echo   OK: updated to %REMOTE% & echo   OK: updated to %REMOTE% >> "%LOG%"
goto :done

:s6_ok
echo   OK: already up to date & echo   OK: already up to date >> "%LOG%"
goto :done

:s6_fetch
echo   ERR: fetch failed & echo   ERR: fetch failed >> "%LOG%"
goto :done

:s6_err
echo   ERR: reset failed & echo   ERR: reset failed >> "%LOG%"
goto :done

:s6_skip
echo   SKIP: no git & echo   SKIP: no git >> "%LOG%"
goto :done

:s6_nogit
echo   SKIP: no .git & echo   SKIP: no .git >> "%LOG%"

REM ============================================
REM DONE
REM ============================================
:done
timeout /t 2 /nobreak >nul
echo. & echo. >> "%LOG%"
echo === DONE === & echo === DONE === >> "%LOG%"
echo. & echo. >> "%LOG%"
echo Log saved: %LOG%
echo.
echo ========================================
echo  Press any key to close...
echo ========================================
pause