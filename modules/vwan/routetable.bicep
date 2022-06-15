param resVhubName string
param resAzureFirewallId string

resource resVhubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2021-05-01' = {
  name: '${resVhubName}/defaultRouteTable'
  properties: {
    labels: [
      'default'
    ]
    routes: [
      {
        name: 'default-to-azfw'
        destinations: [
          '0.0.0.0/0'
        ]
        destinationType: 'CIDR'
        nextHop: resAzureFirewallId
        nextHopType: 'ResourceID'
      }
    ]
  }
}
