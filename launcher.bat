@echo off
setlocal enabledelayedexpansion

:: Check if this is called for dependency installation only
if "%1"=="--install-only" goto :install_deps

:: Navigate to the Python application directory
cd /d "%~dp0\Python_For_Education\python_for_education"

:: Try to find and run Python
call :find_python
if !PYTHON_FOUND!==0 (
    echo Error: No se pudo encontrar Python instalado en el sistema.
    echo.
    echo Por favor, ejecute el instalador nuevamente o instale Python manualmente.
    echo Descarga: https://python.org
    pause
    exit /b 1
)

:: Run the main application using pythonw.exe (no console window)
:: Try pythonw.exe first (windowless Python execution)
if exist "%LOCALAPPDATA%\Programs\Python\Python313\pythonw.exe" (
    start "" "%LOCALAPPDATA%\Programs\Python\Python313\pythonw.exe" interfaz.py
) else if exist "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" (
    start "" "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" interfaz.py
) else if exist "C:\Program Files\Python313\pythonw.exe" (
    start "" "C:\Program Files\Python313\pythonw.exe" interfaz.py
) else if exist "C:\Program Files\Python312\pythonw.exe" (
    start "" "C:\Program Files\Python312\pythonw.exe" interfaz.py
) else if exist "C:\Program Files\Python311\pythonw.exe" (
    start "" "C:\Program Files\Python311\pythonw.exe" interfaz.py
) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\pythonw.exe" (
    start "" "%LOCALAPPDATA%\Programs\Python\Python311\pythonw.exe" interfaz.py
) else (
    :: Fallback: use regular python but hide console window
    start "" /min !PYTHON_EXE! interfaz.py
)

:: Exit immediately without waiting or showing any output
exit /b 0

:install_deps
:: Navigate to the Python application directory for dependency installation
cd /d "%~dp0\Python_For_Education\python_for_education"

call :find_python
if !PYTHON_FOUND!==0 (
    echo Error: No se pudo encontrar Python para instalar dependencias.
    exit /b 1
)

echo Instalando dependencias de Python...
!PYTHON_EXE! install.py >nul 2>&1
if !errorlevel! neq 0 (
    echo Error al instalar dependencias.
    exit /b 1
)
echo Dependencias instaladas correctamente.
exit /b 0

:find_python
set PYTHON_FOUND=0
set PYTHON_EXE=

:: Try py launcher first (most reliable)
py --version >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_EXE=py
    set PYTHON_FOUND=1
    goto :eof
)

:: Try python command
python --version >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_EXE=python
    set PYTHON_FOUND=1
    goto :eof
)

:: Try specific Python installations
if exist "C:\Program Files\Python313\python.exe" (
    set PYTHON_EXE="C:\Program Files\Python313\python.exe"
    set PYTHON_FOUND=1
    goto :eof
)

if exist "C:\Program Files\Python312\python.exe" (
    set PYTHON_EXE="C:\Program Files\Python312\python.exe"
    set PYTHON_FOUND=1
    goto :eof
)

if exist "C:\Program Files\Python311\python.exe" (
    set PYTHON_EXE="C:\Program Files\Python311\python.exe"
    set PYTHON_FOUND=1
    goto :eof
)

:: Try user-specific installations
if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" (
    set PYTHON_EXE="%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    set PYTHON_FOUND=1
    goto :eof
)

if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
    set PYTHON_EXE="%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    set PYTHON_FOUND=1
    goto :eof
)

goto :eof