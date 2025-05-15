@echo off
chcp 65001 >nul

echo ================================
echo 🧟‍♂️ The Last Deadzone Revive Setup 🧟‍♂️
echo ================================

where python >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Python is not installed or not in PATH.
    pause
    exit /b 1
)

echo ⬆️ Updating pip...
python -m pip install --upgrade pip

if exist "serverlet\requirements.txt" (
    echo 📦 Installing dependencies...
    pip install -r serverlet\requirements.txt
) else (
    echo ⚠️ No requirements.txt found in serverlet\
)

start "API Server" cmd /k "cd serverlet && python api_serverlet.py"
start "Socket Server" cmd /k "cd serverlet && python socket_serverlet.py"

echo 🚀 Starting web server at http://localhost:8000...
python -m http.server 8000

pause