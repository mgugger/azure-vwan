@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param virtualNetworkId string

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}

@description('Region in which the resource group was created. Default: {resourceGroup().location}')
param parLocation string = resourceGroup().location

@description('Prefix value which will be prepended to all resource names. Default: alz')
param parCompanyPrefix string = 'azlz'

@description('Azure Firewall Tier associated with the Firewall to deploy. Default: Standard ')
@allowed([
  'Standard'
  'Premium'
])
param parAzFirewallTier string = 'Standard'

@description('Azure Firewall Name. Default: {parCompanyPrefix}-fw-{parLocation}')
param parAzFirewallName string = '${parCompanyPrefix}-fw-${parLocation}'

@description('Switch to enable/disable Azure Firewall DNS Proxy. Default: false')
param parAzFirewallDnsProxyEnabled bool = false

@allowed([
  '1'
  '2'
  '3'
])
@description('Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAzFirewallAvailabilityZones array = []

@description('Azure Firewall Policies Name. Default: {parCompanyPrefix}-fwpol-{parLocation}')
param parAzFirewallPoliciesName string = '${parCompanyPrefix}-azfwpolicy-${parLocation}'

resource firewallPip 'Microsoft.Network/publicIPAddresses@2020-03-01' = {
  name: 'hub-afw-pip001'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: parAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: {
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
    }
    sku: {
      tier: parAzFirewallTier
    }
  }
}

resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: parAzFirewallName
  location: parLocation
  tags: parTags
  zones: (!empty(parAzFirewallAvailabilityZones) ? parAzFirewallAvailabilityZones : json('null'))
  properties: {
    ipConfigurations: [
      {
        name: 'hub-fw-pip001'
        properties: {
          subnet: {
            id: '${virtualNetworkId}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: firewallPip.id
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  }
}

output azureFirewallId string = resAzureFirewall.id
