# Login to Azure if not already logged in
# Connect-AzAccount

# Get all resource groups containing 'onpremsim'
$resourceGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "*onpremsim*" }

Write-Host "Found $($resourceGroups.Count) resource groups containing 'onpremsim'"

foreach ($rg in $resourceGroups) {
    $rgName = $rg.ResourceGroupName
    Write-Host "`nProcessing resource group: $rgName"

    # Match 'onpremsim' followed by a number anywhere in the name
    if ($rgName -match "onpremsim(\d+)") {
        $number = $matches[1]
        $subnet = "172.$number.100.0/24"
        $gatewayName = "lng-onpremsim$number"

        Write-Host "Extracted number: $number"
        Write-Host "Subnet: $subnet"
        Write-Host "Gateway name: $gatewayName"

        # Look for VM named 'hv-host'
        $vm = Get-AzVM -ResourceGroupName $rgName -Name "hv-host" -ErrorAction SilentlyContinue
        if ($vm) {
            Write-Host "Found VM 'hv-host' in $rgName"

            $nic = Get-AzNetworkInterface -ResourceGroupName $rgName | Where-Object { $_.VirtualMachine.Id -eq $vm.Id }
            if ($nic) {
                $pipId = $nic.IpConfigurations[0].PublicIpAddress.Id

                # Extract name and resource group from the public IP resource ID
                $pipParts = $pipId -split "/"
                $pipName = $pipParts[-1]
                $pipRg = $pipParts[4]
                $pip = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $pipRg
                $publicIp = $pip.IpAddress

                Write-Host "Public IP: $publicIp"

                if ($publicIp) {
                    New-AzLocalNetworkGateway `
                        -Name $gatewayName `
                        -ResourceGroupName $rgName `
                        -Location $vm.Location `
                        -GatewayIpAddress $publicIp `
                        -AddressPrefix $subnet

                    Write-Host "✅ Created Local Network Gateway '$gatewayName'"
                } else {
                    Write-Warning "⚠️ Public IP address not found for VM 'hv-host' in $rgName"
                }
            } else {
                Write-Warning "⚠️ NIC not found for VM 'hv-host' in $rgName"
            }
        } else {
            Write-Warning "⚠️ VM 'hv-host' not found in $rgName"
        }
    } else {
        Write-Warning "⚠️ Resource group name '$rgName' does not contain 'onpremsim' followed by a number"
    }
}
