@echo off
setlocal enabledelayedexpansion

REM Set working directory
set "WORK_DIR=%USERPROFILE%\ipfs_setup"

REM Clean up previous setup if exists
if exist "%WORK_DIR%" (
    echo Removing existing setup directory...
    rmdir /s /q "%WORK_DIR%"
)

REM Create a fresh working directory
echo Creating working directory...
mkdir "%WORK_DIR%"
cd "%WORK_DIR%"

REM Define URLs for Kubo
set "KUBO_URL=https://dist.ipfs.tech/kubo/v0.32.1/kubo_v0.32.1_windows-amd64.zip"

REM Download Kubo
echo Downloading Kubo...
curl -L "%KUBO_URL%" -o "kubo.zip"
if not exist "kubo.zip" (
    echo Failed to download Kubo. Exiting.
    exit /b
)

REM Remove existing IPFS configuration directory
echo Cleaning up existing IPFS configuration...
if exist "%USERPROFILE%\.ipfs" (
    rmdir /s /q "%USERPROFILE%\.ipfs"
)

REM Extract Kubo using tar
echo Extracting Kubo...
tar -xvf "kubo.zip" -C "%WORK_DIR%"
if errorlevel 1 (
    echo Extraction failed. Ensure tar is installed and available in PATH. Exiting.
    exit /b
)

REM Locate the Kubo directory (assuming it's named "kubo" in the zip)
set "KUBO_DIR=%WORK_DIR%\kubo"

REM Verify the existence of IPFS binary
if not exist "%KUBO_DIR%\ipfs.exe" (
    echo IPFS binary not found in %KUBO_DIR%. Exiting.
    exit /b
)

REM Add Kubo directory to PATH
set PATH=%KUBO_DIR%;%PATH%
echo Added Kubo to PATH.

REM Verify IPFS installation
echo Verifying IPFS installation...
ipfs --version
if errorlevel 1 (
    echo IPFS command not recognized. Exiting.
    exit /b
)

REM Initialize IPFS
echo Initializing IPFS...
ipfs init
if errorlevel 1 (
    echo IPFS initialization failed. Exiting.
    exit /b
)

REM Create Python script for swarm key generation
echo Creating Python script for swarm key generation...
echo import os > "%WORK_DIR%\generate_swarm_key.py"
echo import secrets >> "%WORK_DIR%\generate_swarm_key.py"
echo key = secrets.token_hex(32) >> "%WORK_DIR%\generate_swarm_key.py"
echo with open("swarm.key", "w") as f: >> "%WORK_DIR%\generate_swarm_key.py"
echo     f.write(f"/key/swarm/psk/1.0.0/^n/base16/^n{key}") >> "%WORK_DIR%\generate_swarm_key.py"

REM Generate swarm key using Python
echo Generating swarm key...
cd "%WORK_DIR%"
python "generate_swarm_key.py"
if not exist "swarm.key" (
    echo Failed to generate swarm key. Exiting.
    exit /b
)

REM Move swarm key to IPFS directory
echo Moving swarm key to IPFS configuration directory...
move /y "swarm.key" "%USERPROFILE%\.ipfs\swarm.key"

:: Define path to IPFS config file
set "configFile=C:\Users\Oren\.ipfs\config"

:: Backup the original config file
echo Backing up original config file...
copy "%configFile%" "%configFile%.bak"

:: Start updating the config file
echo Updating IPFS config...

:: Use PowerShell to modify the JSON content directly in the config file
powershell -Command "(Get-Content '%configFile%' | ForEach-Object { $_ -replace '\"Bootstrap\": \[.*?\]', '\"Bootstrap\": []' }) | Set-Content '%configFile%'"

powershell -Command "(Get-Content '%configFile%' | ForEach-Object { $_ -replace '\"Routing\": \{ \"Type\": \"auto\" \}', '\"Routing\": { \"Type\": \"dht\" }' }) | Set-Content '%configFile%'"

powershell -Command "(
    $configFile = '%configFile%'
    $swarmKey = Get-Content '%USERPROFILE%\.ipfs\swarm.key' | Out-String | Trim
    $content = Get-Content $configFile
    $content = $content -replace '\"Swarm\": \{.*?\}', '\"Swarm\": { \"AddrFilters\": [ \"/ip4/0.0.0.0/tcp/0\", \"/ip6/::/tcp/0\" ], \"PrivateKey\": \"/key/swarm/psk/1.0.0/base16/' + $swarmKey + '\" }'
    $content | Set-Content $configFile
)"

:: End the process
echo Config file updated successfully!

REM Start the IPFS daemon
echo Starting IPFS daemon...
ipfs daemon
