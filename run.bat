@echo off
chcp 65001 >nul

echo =====================================
echo 🧟‍♂️ The Last Deadzone Revive Setup 🧟‍♂️
echo =====================================

where python >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Python is not installed or not in PATH.
    pause
    exit /b 1
)

echo ⬆️ Updating pip...
python -m pip install --upgrade pip

if exist "api_server\requirements.txt" (
    echo 📦 Installing dependencies api_server...
    pip install -r api_server\requirements.txt
) else (
    echo ⚠️ No requirements.txt found in api_server\
)

if exist "socket_server\requirements.txt" (
    echo 📦 Installing dependencies socket_server...
    pip install -r socket_server\requirements.txt
) else (
    echo ⚠️ No requirements.txt found in socket_server\
)

if exist "file_server\requirements.txt" (
    echo 📦 Installing dependencies file_server...
    pip install -r file_server\requirements.txt
) else (
    echo ⚠️ No requirements.txt found in file_server\
)

start "File server" cmd /k "cd file_server && python main.py"
start "API server" cmd /k "cd api_server && python main.py"
start "Socket server" cmd /k "cd socket_server && python main.py"