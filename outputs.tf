output "vpc_id" {
  value = module.vpc_primary.dr_project_vpc
}

output "public_subnets" {
  value = module.vpc_primary.dr_project_public_subnets
}

output "private_subnets" {
  value = module.vpc_primary.dr_project_private_subnets
}

output "alb_sg_name" {
  value = module.security_group_primary.load_security_g_name
}

output "ec2_sg_name" {
  value = module.security_group_primary.ec2_security_g_name
}

output "database_sg_name" {
  value = module.security_group_primary.database_security_g_name
}

output "db_hostname" {
  value = module.rds_primary.db_hostname

}

output "alb_dns_name" {
  value = module.alb.alb_dns
}
# output "ec2_public_ip_address" {
#   value = module.ec2_primary.terra_demo_proj_ec2_instance

# }