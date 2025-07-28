resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'DC-Subnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow-Kerberos'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '88'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-RPC'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '135'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-LDAP'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-LDAP-UDP'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-DNS-TCP'
        properties: {
          priority: 140
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-DNS-UDP'
        properties: {
          priority: 150
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // Add other rules as needed (e.g., SMB, Global Catalog)
    ]
  }
}
