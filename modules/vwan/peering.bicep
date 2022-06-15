targetScope = 'subscription'

@description('Virtual WAN Hub resource ID. No default')
param parVirtualWanHubResourceId string

@description('Remote Spoke virtual network resource ID. No default')
param parRemoteVirtualNetworkResourceId string

var varVwanSubscriptionId = split(parVirtualWanHubResourceId, '/')[2]

var varVwanResourceGroup = split(parVirtualWanHubResourceId, '/')[4]

var varSpokeVnetName = split(parRemoteVirtualNetworkResourceId, '/')[8]

var varModhubVirtualNetworkConnectionDeploymentName = take('deploy-vnet-peering-vwan-${varSpokeVnetName}', 64)

// The hubVirtualNetworkConnection resource is implemented as a separate module because the deployment scope could be on a different subscription and resource group
module modhubVirtualNetworkConnection 'hubVirtualNetworkConnection.bicep' = {
  scope: resourceGroup(varVwanSubscriptionId, varVwanResourceGroup)  
  name: varModhubVirtualNetworkConnectionDeploymentName
    params: {
    parVirtualWanHubResourceId: parVirtualWanHubResourceId
    parRemoteVirtualNetworkResourceId: parRemoteVirtualNetworkResourceId
  }
}

output outHubVirtualNetworkConnectionName string = modhubVirtualNetworkConnection.outputs.outHubVirtualNetworkConnectionName
output outHubVirtualNetworkConnectionResourceId string = modhubVirtualNetworkConnection.outputs.outHubVirtualNetworkConnectionResourceId
