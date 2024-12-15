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
echo     f.write(f"/key/swarm/psk/1.0.0/\n/base16/\n{key}") >> "%WORK_DIR%\generate_swarm_key.py"

REM Generate swarm key using Python
echo Generating swarm key...
python "%WORK_DIR%\generate_swarm_key.py"
if not exist "swarm.key" (
    echo Failed to generate swarm key. Exiting.
    exit /b
)

REM Move swarm key to IPFS directory
echo Moving swarm key to IPFS configuration directory...
move /y "swarm.key" "%USERPROFILE%\.ipfs\swarm.key"

REM Modify IPFS configuration for private network
echo Configuring IPFS for private network...

REM Remove default bootstrap peers
ipfs bootstrap rm --all

REM Set Routing Type to DHT
ipfs config Routing.Type dht

REM Disable public gateways
ipfs config --json Gateway.PublicGateways "null"

REM Configure Swarm Addresses
ipfs config --json Addresses.Swarm "["/ip4/0.0.0.0/tcp/4001", "/ip6/::/tcp/4001"]"

REM Disable MDNS discovery
ipfs config --json Discovery.MDNS.Enabled false

REM Disable Public DHT
ipfs config --json Discovery.PublicDHT false

REM Force private networking
setx LIBP2P_FORCE_PNET 1

REM Verify configuration
echo Verifying IPFS configuration...
ipfs config show

REM Optional: Get and display Peer ID
echo Getting Peer ID...
ipfs id

REM Start IPFS daemon
echo Starting IPFS daemon...
ipfs daemon
if errorlevel 1 (
    echo Failed to start IPFS daemon. Exiting.
    exit /b
)

echo Private IPFS network setup complete.
pause