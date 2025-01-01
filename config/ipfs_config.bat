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