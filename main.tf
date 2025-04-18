
############## PRIMARY REGION SETUP ######################################

module "vpc_primary" {
  source                  = "./modeules/vpc"
  providers = {
    aws = aws.primary
  }

  vpc_cidr                = var.vpc_cidr
  cidr_private_subnet     = var.cidr_private_subnet
  cidr_public_subnet      = var.cidr_public_subnet
  vpc_name                = var.vpc_name
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "security_group_primary" {
  source              = "./modeules/security_group"
  providers = {
    aws = aws.primary
  }

  vpc_id              = module.vpc_primary.dr_project_vpc
  ec2_sg_name         = var.ec2_sg_name
  alb_sg_name         = var.alb_sg_name
  db_sg_name          = var.db_sg_name
  security_group_cidr = var.security_group_cidr
}

module "rds_primary" {
  providers = {
    aws = aws.primary
  }

  source            = "./modeules/rds"
  storage_type      = var.storage_type
  db_engine         = var.db_engine
  db_subnet_name    = var.db_subnet_name
  db_identifier     = var.db_identifier
  private_subnets   = module.vpc_primary.dr_project_private_subnets
  db_instance_class = var.db_instance_class
  db_security_group = module.security_group_primary.database_security_g_name
  db_name           = var.db_name
  db_password       = var.db_password
  db_username       = var.db_username
}

module "acm_primary" {
  source = "./modeules/acm"
  providers = {
    aws = aws.primary
  }

  domain_name = var.domain_name
  alternative_names = var.alternative_names
  hosted_zone_id = module.route53_primary.hosted_zone_id
}

module "ec2_primary" {
  providers = {
    aws = aws.primary
  }

  source = "./modeules/ec2"
  instance_name = var.instance_name
  key_name = var.key_name
  subnet_id = module.vpc_primary.dr_project_public_subnets[0]
  security_group_ids = [module.security_group_primary.ec2_security_g_name]
  associate_public_ip_address = var.associate_public_ip_address
  user_data_install_docker = file("./scripts/install_docker.sh")
}
module "alb_primary" {
  providers = {
    aws = aws.primary
  }

  source = "./modeules/alb"
  vpc_id = module.vpc_primary.dr_project_vpc
  alb_sg_id = module.security_group_primary.load_security_g_name
  public_subnets = module.vpc_primary.dr_project_public_subnets
  project_name = var.project_name
  target_id = module.ec2_primary.instance_id
  acm_cert_arn = module.acm.acm_cert_arn
}

module "route53_primary" {
  source = "./modeules/route53"
  providers = {
    aws = aws.primary
  }
  domain_name         = var.domain_name
  alb_dns_name        = module.alb_primary.alb_dns
  alb_zone_id         = module.alb_primary.alb_zone_id
  failover_role       = "PRIMARY"
  create_health_check = true
  health_check_fqdn   = var.domain_name
}

############## SECONDARY REGION SETUP FOR DR ######################################

module "vpc_dr" {
  source                  = "./modeules/vpc"
  providers = {
    aws = aws.dr
  }

  vpc_cidr                = var.vpc_cidr
  cidr_private_subnet     = var.cidr_private_subnet
  cidr_public_subnet      = var.cidr_public_subnet
  vpc_name                = var.vpc_name
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "security_group_dr" {
  source              = "./modeules/security_group"
  providers = {
    aws = aws.dr
  }

  vpc_id              = module.vpc_dr.dr_project_vpc
  ec2_sg_name         = var.ec2_sg_name
  alb_sg_name         = var.alb_sg_name
  db_sg_name          = var.db_sg_name
  security_group_cidr = var.security_group_cidr
}


module "rds_dr" {
  source                  = "./modules/rds"
  providers = {
    aws = aws.dr
  }

  replicate_from_primary  = true
  source_db_arn           = module.rds_primary.db_instance_arn
  db_identifier           = var.db_identifier
  db_instance_class       = var.db_instance_class
  db_security_group       = module.security_group_dr.database_security_g_name
  private_subnets         = module.vpc_dr.dr_project_private_subnets
  db_subnet_name          = var.db_subnet_name
}


module "alb_dr" {
  providers = {
    aws = aws.dr
  }

  source             = "./modules/alb"
  vpc_id             = module.vpc_dr.dr_project_vpc
  alb_sg_id          = module.security_group_dr.load_security_g_name
  public_subnets     = module.vpc_dr.dr_project_public_subnets
  project_name       = var.project_name
  target_id          = module.ec2_dr.instance_id
  acm_cert_arn       = module.acm_dr.acm_cert_arn
}

module "acm_dr" {
  source = "./modules/acm"
  providers = {
    aws = aws.dr
  }

  domain_name        = var.domain_name
  alternative_names  = var.alternative_names
  hosted_zone_id     = module.route53_dr.hosted_zone_id
}


module "route53_dr" {
  providers = {
    aws = aws.dr
  }
  source = "./modeules/route53"
  domain_name         = var.domain_name
  alb_dns_name        = module.alb_dr.alb_dns
  alb_zone_id         = module.alb_dr.alb_zone_id
  failover_role       = "SECONDARY"
  create_health_check = true
  health_check_fqdn   = var.domain_name
  create_www          = false
}
