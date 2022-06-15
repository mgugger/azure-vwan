@description('Region in which the resource group was created. Default: {resourceGroup().location}')
param parLocation string = resourceGroup().location

@description('Prefix value which will be prepended to all resource names. Default: alz')
param parCompanyPrefix string = 'azlz'

@description('The IP address range in CIDR notation for the vWAN virtual Hub to use. Default: 10.0.0.0/24')
param parVirtualHubAddressPrefix string = '10.0.0.0/24'

@description('Switch to enable/disable Virtual Hub deployment. Default: true')
param parVirtualHubEnabled bool = true

@description('Switch to enable/disable VPN Gateway deployment. Default: false')
param parVpnGatewayEnabled bool = false

@description('Switch to enable/disable ExpressRoute Gateway deployment. Default: false')
param parExpressRouteGatewayEnabled bool = false

@description('Prefix Used for Virtual WAN. Default: {parCompanyPrefix}-vwan-{parLocation}')
param parVirtualWanName string = '${parCompanyPrefix}-vwan-${parLocation}'

@description('Prefix Used for Virtual WAN Hub. Default: {parCompanyPrefix}-hub-{parLocation}')
param parVirtualWanHubName string = '${parCompanyPrefix}-vhub-${parLocation}'

@description('Prefix Used for VPN Gateway. Default: {parCompanyPrefix}-vpngw-{parLocation}')
param parVpnGatewayName string = '${parCompanyPrefix}-vpngw-${parLocation}'

@description('Prefix Used for ExpressRoute Gateway. Default: {parCompanyPrefix}-ergw-{parLocation}')
param parExpressRouteGatewayName string = '${parCompanyPrefix}-ergw-${parLocation}'

@description('The scale unit for this VPN Gateway: Default: 1')
param parVpnGatewayScaleUnit int = 1

@description('The scale unit for this ExpressRoute Gateway: Default: 1')
param parExpressRouteGatewayScaleUnit int = 1

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}

// Virtual WAN resource
resource resVwan 'Microsoft.Network/virtualWans@2021-05-01' = {
  name: parVirtualWanName
  location: parLocation
  tags: parTags
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    type: 'Standard'
  }
}

resource resVhub 'Microsoft.Network/virtualHubs@2021-05-01' = if (parVirtualHubEnabled && !empty(parVirtualHubAddressPrefix)) {
  name: parVirtualWanHubName
  location: parLocation
  tags: parTags
  properties: {
    addressPrefix: parVirtualHubAddressPrefix
    sku: 'Standard'
    virtualWan: {
      id: resVwan.id
    }
  }
}

resource resVpnGateway 'Microsoft.Network/vpnGateways@2021-05-01' = if (parVirtualHubEnabled && parVpnGatewayEnabled) {
  name: parVpnGatewayName
  location: parLocation
  tags: parTags
  properties: {
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: ''
      peerWeight: 5
    }
    virtualHub: {
      id: resVhub.id
    }
    vpnGatewayScaleUnit: parVpnGatewayScaleUnit
  }
}

resource resErGateway 'Microsoft.Network/expressRouteGateways@2021-05-01' = if (parVirtualHubEnabled && parExpressRouteGatewayEnabled) {
  name: parExpressRouteGatewayName
  location: parLocation
  tags: parTags
  properties: {
    virtualHub: {
      id: resVhub.id
    }
    autoScaleConfiguration: {
      bounds: {
        min: parExpressRouteGatewayScaleUnit
      }
    }
  }
}

// Output Virtual WAN name and ID
output outVirtualWanName string = resVwan.name
output outVirtualWanId string = resVwan.id

// Output Virtual WAN Hub name and ID
output outVirtualHubName string = resVhub.name
output outVirtualHubId string = resVhub.id
