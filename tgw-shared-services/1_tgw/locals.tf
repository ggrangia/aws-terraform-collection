locals {
  tgw_rt_name_id_map = { for x in aws_ec2_transit_gateway_route_table.tgw_rt : x.tags["Name"] => x.id }
  tgw_rt_log_env = {
    "POWERTOOLS_SERVICE_NAME" : "tgw_rt_propagation",
    "LOG_LEVEL" : "DEBUG"
  }

  tgw_rt_prop_lambda_env = merge(local.tgw_rt_name_id_map, local.tgw_rt_log_env)
}
