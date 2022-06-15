targetScope = 'subscription'

var hubResourceGroupName = 'vwan_hub'
var workload1ResourceGroupName = 'vwan_workload1'
var workload2ResourceGroupName = 'vwan_workload2'

// 1. Deploy 3 Resource Groups
module hubResourceGroup 'modules/resource-group/rg.bicep' = {
  name: hubResourceGroupName
  params: {
    rgName: hubResourceGroupName
    location: deployment().location
  }
}

module workload1ResourceGroup 'modules/resource-group/rg.bicep' = {
  name: workload1ResourceGroupName
  params: {
    rgName: workload1ResourceGroupName
    location: deployment().location
  }
}

module workload2ResourceGroup 'modules/resource-group/rg.bicep' = {
  name: workload2ResourceGroupName
  params: {
    rgName: workload2ResourceGroupName
    location: deployment().location
  }
}

// 2. Deploy VWAN
module vwan 'modules/vwan/vwan.bicep' = {
  name: 'vwan'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    parLocation: deployment().location
  }
  dependsOn: [
    hubResourceGroup
  ]
}

// 3. Deploy Hub
module hub 'modules/hub/hub.bicep' = {
  name: 'hub'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
  }
  dependsOn: [
    vwan
  ]
}

// 4. Deploy Workload 1
module workload1 'modules/workload1/workload1.bicep' = {
  name: 'workload1'
  scope: resourceGroup(workload1ResourceGroup.name)
  params: {
  }
  dependsOn: [
    vwan
    workload1ResourceGroup
  ]
}

// 5. Deploy Workload 2
module workload2 'modules/workload2/workload2.bicep' = {
  name: 'workload2'
  scope: resourceGroup(workload2ResourceGroup.name)
  params: {
  }
  dependsOn: [
    vwan
    workload2ResourceGroup
  ]
}

// 6. Deploy Peerings
module hub_peering 'modules/vwan/peering.bicep' = {
  name: 'hub_peering'
  params: {
    parRemoteVirtualNetworkResourceId: hub.outputs.vnetId
    parVirtualWanHubResourceId: vwan.outputs.outVirtualHubId
  }
  dependsOn: [
    vwan
    hub
  ]
}

module workload1_peering 'modules/vwan/peering.bicep' = {
  name: 'workload1_peering'
  params: {
    parRemoteVirtualNetworkResourceId: workload1.outputs.vnetId
    parVirtualWanHubResourceId: vwan.outputs.outVirtualHubId
  }
  dependsOn: [
    hub
    workload1
  ]
}

module workload2_peering 'modules/vwan/peering.bicep' = {
  name: 'workload2_peering'
  params: {
    parRemoteVirtualNetworkResourceId: workload2.outputs.vnetId
    parVirtualWanHubResourceId: vwan.outputs.outVirtualHubId
  }
  dependsOn: [
    hub
    workload2
  ]
}

// 7. Set default route table to azure firewall
// module vwan_rt 'modules/vwan/routetable.bicep' = {
//   name: 'vwan_rt'
//   scope: resourceGroup(hubResourceGroup.name)
//   params: {
//     resVhubName: vwan.outputs.outVirtualHubName
//     resAzureFirewallId: hub.outputs.azureFirewallId
//   }
//   dependsOn: [
//     hub_peering
//   ]
// }
