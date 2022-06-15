param vnetNamePrefix string
param subnets array
param location string = resourceGroup().location
param vnetAddressSpace array

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vnetNamePrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
    subnets: subnets
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetSubnets array = vnet.properties.subnets
