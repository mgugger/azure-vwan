param location string = resourceGroup().location

resource workload2_nsg_protected 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'workload2_nsg_protected'
  location: location
  tags: {}
  properties: {
    securityRules: [
      {
        name: 'allow_vnet_inbound'
        properties: {
          description: 'allow all traffic between subnets'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 3500
          direction: 'Inbound'
        }
      }
      {
        name: 'inbound_deny_catchall'
        properties: {
          description: 'Deny all inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
      {
        name: 'deny_catchall'
        properties: {
          description: 'Deny all outbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 4000
          direction: 'Outbound'
        }
      }
    ]
  }
}

output nsgId string = workload2_nsg_protected.id
