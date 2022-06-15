module workload1_nsg_protected 'nsg_protected.bicep' = {
  name: 'workload1_nsg_protected'
  params: {
    location: resourceGroup().location
  }
}

module workload1vnet '../vnet/vnet.bicep' = {
  name: 'workload1vnet'
  params: {
    location: resourceGroup().location
    vnetAddressSpace: [
        '10.0.2.0/24'
    ]
    vnetNamePrefix: 'azlz_workload1'
    subnets: [
      {
        properties: {
          addressPrefix: '10.0.2.0/26'
        }
        name: 'Frontend'
      }
      {
        properties: {
          addressPrefix: '10.0.2.64/26'
          networkSecurityGroup: {
            id: workload1_nsg_protected.outputs.nsgId
          }
        }
        name: 'Backend'
      }
    ]
  }
}

output vnetId string = workload1vnet.outputs.vnetId
