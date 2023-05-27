locals {
  tgw_rt_name_id_map = { for x in aws_ec2_transit_gateway_route_table.tgw_rt : x.tags["Name"] => x.id }
  tgw_rt_log_env = {
    "POWERTOOLS_SERVICE_NAME" : "tgw_rt_propagation",
    "LOG_LEVEL" : "DEBUG"
  }

  tgw_rt_prop_lambda_env = merge(local.tgw_rt_name_id_map, local.tgw_rt_log_env)

  network_cidr = "10.0.0.0/8"

  // "public" CIDR
  secondary_cidr_blocks = ["100.64.0.0/26"]
  public_subnets        = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]
  // Only one RT is returned
  rt_vpc_map_acc1_pvt   = { for k in keys(module.acc1) : k => module.acc1[k].private_route_table_ids[0] }
  rt_vpc_map_acc1_intra = { for k in keys(module.acc1) : k => module.acc1[k].intra_route_table_ids[0] }

  rt_vpc_map_acc2_pvt   = { for k in keys(module.acc2) : k => module.acc2[k].private_route_table_ids[0] }
  rt_vpc_map_acc2_intra = { for k in keys(module.acc2) : k => module.acc2[k].intra_route_table_ids[0] }
}
