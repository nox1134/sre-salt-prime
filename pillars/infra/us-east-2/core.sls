infra:
  us-east-2:
    core:
      host_ips:
{#- sort host_ips with the following external vim command:
!sort -n -t . -k 2,2 -k 3,3 -k 4,4 -k 5,5
#}
        ###_DMZ                 10.22.10.0
        bastion__core:          10.22.10.10
        wikijs__core:           10.22.10.12
        #_NAT_Gateway:          10.22.10.13
        chapters__prod:         10.22.10.14
        podcast__prod:          10.22.10.15
        biztool__prod:          10.22.10.17
        chapters__stage:        10.22.10.18
        redirects__core:        10.22.10.19
        openglam__prod:         10.22.10.21
        licbuttons__prod:       10.22.10.24
        dispatch__prod:         10.22.10.25
        opencovid__prod:        10.22.10.27
        ccorg__stage:           10.22.10.26
        cert__prod:             10.22.10.29
        ###_Private-One         10.22.11.0
        salt-prime__core:       10.22.11.11
        ccengine__prod:         10.22.11.13
        misc__prod:             10.22.11.15
        ###_Private-Two         10.22.12.0
      subnets:
        dmz:
          cidr: 10.22.10.0/24
          az: us-east-2a
          route_table: internet_core_route-table
          tag_routing: Internet Gateway
        private-one:
          cidr: 10.22.11.0/24
          az: us-east-2b
          route_table: nat_core_route-table
          tag_routing: NAT Gateway
        private-two:
          cidr: 10.22.12.0/24
          az: us-east-2c
          route_table: nat_core_route-table
          tag_routing: NAT Gateway
