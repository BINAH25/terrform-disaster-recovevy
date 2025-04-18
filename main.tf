
module "vpc" {
  source                  = "./modeules/vpc"
  vpc_cidr                = var.vpc_cidr
  cidr_private_subnet     = var.cidr_private_subnet
  cidr_public_subnet      = var.cidr_public_subnet
  vpc_name                = var.vpc_name
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "security_group" {
  source              = "./modeules/security_group"
  vpc_id              = module.vpc.dr_project_vpc
  ec2_sg_name         = var.ec2_sg_name
  alb_sg_name         = var.alb_sg_name
  db_sg_name          = var.db_sg_name
  security_group_cidr = var.security_group_cidr
}

module "rds" {
  source            = "./modeules/rds"
  storage_type      = var.storage_type
  db_engine         = var.db_engine
  db_subnet_name    = var.db_subnet_name
  db_identifier     = var.db_identifier
  private_subnets   = module.vpc.dr_project_private_subnets
  db_instance_class = var.db_instance_class
  db_security_group = module.security_group.database_security_g_name
  db_name           = var.db_name
  db_password       = var.db_password
  db_username       = var.db_username
}

module "acm" {
  source = "./modeules/acm"
  domain_name = var.domain_name
  alternative_names = var.alternative_names
  hosted_zone_id = module.route53.hosted_zone_id
}
module "ec2" {
  source = "./modeules/ec2"
  instance_name = var.instance_name
  key_name = var.key_name
  subnet_id = module.vpc.dr_project_public_subnets[0]
  security_group_ids = [module.security_group.ec2_security_g_name]
  associate_public_ip_address = var.associate_public_ip_address
  user_data_install_docker = file("./scripts/install_docker.sh")
}
module "alb" {
  source = "./modeules/alb"
  vpc_id = module.vpc.dr_project_vpc
  alb_sg_id = module.security_group.load_security_g_name
  public_subnets = module.vpc.dr_project_public_subnets
  project_name = var.project_name
  target_id = module.ec2.instance_id
  acm_cert_arn = module.acm.acm_cert_arn
}

module "route53" {
  source = "./modeules/route53"
  domain_name = var.domain_name
  alb_dns_name = module.alb.alb_dns
  alb_zone_id = module.alb.alb_zone_id
}

