targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
@description('Password for the Windows VM')
param winVMPassword string //no value specified, so user will get prompted for it during deployment

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module hvhost './nestedhyperv.bicep' = {
  scope: rg
  name: 'hvhost'
  params: {
    location: location
    tags: tags
    winVmUser: 'adminuser'
    winVmPassword: winVMPassword //no value specified, so user will get prompted for it during deployment
  }
}

output winVmUser string = hvhost.outputs.winVmUser
output Jumphost_VM_private_IP_address string = hvhost.outputs.Jumphost_VM_private_IP_address
output natGatewayPublicIpAddress string = hvhost.outputs.natGatewayPublicIpAddress
