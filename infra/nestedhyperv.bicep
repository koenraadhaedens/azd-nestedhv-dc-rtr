targetScope = 'resourceGroup'

param tags object

@description('The Windows version for Windows hyperv-host VM.')
param windowsOSVersion string = '2025-Datacenter'

@description('Size for Windows hyper-vhost VM')
param winVmSize string = 'Standard_D8s_v7'

@description('Username for Windows hyperv-host VM')
param winVmUser string

@description('Password for Windows hyperv-host VM. The password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following: 1) Contains an uppercase character 2) Contains a lowercase character 3) Contains a numeric digit 4) Contains a special character 5) Control characters are not allowed')
@secure()
param winVmPassword string

@description('DNS Label for Windows hyperv-host VM.')
param winVmDnsPrefix string

@description('Location for all resources.')
param location string = resourceGroup().location

var hostvnetName = 'hostvnet'
var mgmtSubnetName = 'hvhostSubnet'
var mgmtSubnetPrefix = '10.30.10.0/24'
var hostvnetPrefix = '10.30.0.0/16'
var winhvhostname = 'hv-host'
var winVmNicName = '${winhvhostname}NIC'
var winNsgName = 'hvHostNsg'
var winhvhostPublicIpName = 'winhvhostnamePublicIp'

resource hostvnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: hostvnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hostvnetPrefix
      ]
    }
    enableDdosProtection: false
  }
}

resource hostvnet_mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: hostvnet
  name: mgmtSubnetName
  properties: {
    addressPrefix: mgmtSubnetPrefix
  }
}

resource winhvhost 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: winhvhostname
  location: location
  tags: tags
  properties: {
    securityProfile: {
      securityType: 'Standard'
    }
    hardwareProfile: {
      vmSize: winVmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          lun: 2
          createOption: 'Empty'
          diskSizeGB: 256
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: winhvhostname
      adminUsername: winVmUser
      adminPassword: winVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: winVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource winVmNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: winVmNicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'winhvhostIpConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: winhvhostPublicIp.id
          }
          subnet: {
            id: hostvnet_mgmtSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: winNsg.id
    }
  }
}

resource winNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: winNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'NSG_RULE_INBOUND_RDP'
        properties: {
          description: 'Allow inbound RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource winhvhostPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  sku: {
    name: 'Standard'
  }
  name: winhvhostPublicIpName
  location: location
  tags: tags
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: toLower(winVmDnsPrefix)
    }
  }
}

resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = {
  name: 'customScriptExtension'
  location: location
  tags: tags
  parent: winhvhost
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/koenraadhaedens/azd-nestedhv-dc-rtr/refs/heads/main/infra/customscript.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File customscript.ps1'
    }
  }
}

output Jumphost_VM_IP_address string = winhvhostPublicIp.properties.ipAddress
output winVmUser string = winVmUser
