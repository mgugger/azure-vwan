module workload2_nsg_protected 'nsg_protected.bicep' = {
  name: 'workload2_nsg_protected'
  params: {
    location: resourceGroup().location
  }
}

module workload2vnet '../vnet/vnet.bicep' = {
  name: 'workload2vnet'
  params: {
    location: resourceGroup().location
    vnetAddressSpace: [
        '10.0.3.0/24'
    ]
    vnetNamePrefix: 'azlz_workload2'
    subnets: [
      {
        properties: {
          addressPrefix: '10.0.3.0/26'
        }
        name: 'Frontend'
      }
      {
        properties: {
          addressPrefix: '10.0.3.64/26'
          networkSecurityGroup: {
            id: workload2_nsg_protected.outputs.nsgId
          }
        }
        name: 'Backend'
      }
    ]
  }
}

output vnetId string = workload2vnet.outputs.vnetId
