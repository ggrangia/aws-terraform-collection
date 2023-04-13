transit_gateway_rt_names = ["Standard_NonProd", "Standard_Prod", "Shared_Services_NonProd", "Shared_Services_Prod", "Global"]
acc1_vpc = {
  "vpc1" : {
    "cidr" = "10.0.1.0/24"
    "type" = "Standard_NonProd"
  },
  "vpc2" : {
    "cidr" = "10.100.2.0/24"
    "type" = "Standard_Prod"
  },
  "vpc3" : {
    "cidr" = "10.0.2.0/24"
    "type" = "Shared_Services_NonProd"
  }
}

acc2_vpc = {
  "vpc1" : {
    "cidr" = "10.0.3.0/24"
    "type" = "Standard_NonProd"
  },
  "vpc2" : {
    "cidr" = "10.100.3.0/24"
    "type" = "Standard_Prod"
  },
  "vpc3" : {
    "cidr" = "10.0.4.0/24"
    "type" = "Global"
  }
}
