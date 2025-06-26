# Define new configuration
$NewSwitchName = "InternalNATSwitch"
$NewSubnet = "172.xxx.100.0/24"
$NewGateway = "172.xxx.100.1"
$NatName = "NewNATNetwork"
$NewInternalIP = "172.xxx.100.9"

# Remove all static NAT mappings
Get-NetNatStaticMapping | Remove-NetNatStaticMapping -Confirm:$false

# Remove all NAT networks
Get-NetNat | Remove-NetNat -Confirm:$false

# Remove existing internal switch (if it exists)
$existingSwitch = Get-VMSwitch -Name $NewSwitchName -ErrorAction SilentlyContinue
if ($existingSwitch) {
    Remove-VMSwitch -Name $NewSwitchName -Force
}

# Create new internal switch
New-VMSwitch -SwitchName $NewSwitchName -SwitchType Internal

# Wait for the virtual adapter to appear
$adapterName = "vEthernet ($NewSwitchName)"
$adapter = $null
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Seconds 2
    $adapter = Get-NetAdapter | Where-Object { $_.Name -eq $adapterName }
    if ($adapter) { break }
}

if (-not $adapter) {
    Write-Error "Virtual adapter '$adapterName' not found."
    return
}

# Assign IP address to the adapter
New-NetIPAddress -IPAddress $NewGateway -PrefixLength 24 -InterfaceIndex $adapter.ifIndex

# Create new NAT network
New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $NewSubnet

# Add new static NAT mappings
Add-NetNatStaticMapping -NatName $NatName -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 500 -InternalIPAddress $NewInternalIP -InternalPort 500
Add-NetNatStaticMapping -NatName $NatName -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 4500 -InternalIPAddress $NewInternalIP -InternalPort 4500

Write-Host "✅ NAT switch, network, and static mappings successfully recreated."
