module hubvnet '../vnet/vnet.bicep' = {
  name: 'hubvnet'
  params: {
    location: resourceGroup().location
    vnetAddressSpace: [
        '10.0.1.0/24'
    ]
    vnetNamePrefix: 'azlz'
    subnets: [
      {
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
        name: 'AzureFirewallSubnet'
      }
    ]
  }
}

module firewall '../firewall/firewall.bicep' = {
  name: 'firewall'
  params: {
    parLocation: resourceGroup().location
    virtualNetworkId: hubvnet.outputs.vnetId
  }
  dependsOn: [
    hubvnet
  ]
}

// module bastion '../bastion/bastion.bicep' = {
//   name: 'bastion'
//   params: {
//     vnetName: hubvnet.outputs.vnetName
//     location: resourceGroup().location
//     addressPrefix: '10.0.1.64/26'
//   }
//   dependsOn: [
//     hubvnet
//   ]
// }


output azureFirewallId string = firewall.outputs.azureFirewallId
output vnetId string = hubvnet.outputs.vnetId
