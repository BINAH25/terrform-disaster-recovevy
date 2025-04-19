# vpc
region              = "us-west-2"
vpc_cidr            = "11.0.0.0/16"
vpc_name            = "dr-proj-us-west-vpc"
cidr_public_subnet  = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet = ["11.0.3.0/24", "11.0.4.0/24"]
availability_zones  = ["us-west-2a", "us-west-2b"]

# security group
alb_sg_name         = "dr-alb-sg"
ec2_sg_name         = "dr-ec2-sg"
db_sg_name          = "dr-database-sg"
security_group_cidr = "0.0.0.0/0"

# database
db_password       = "Louis123"
db_username       = "louis"
db_name           = "file_server"
db_instance_class = "db.t3.micro"
db_identifier     = "postgres-db"
db_subnet_name    = "dr-project-subnet-group"
db_engine         = "postgres"
storage_type      = "gp2"

# alb
project_name = "dr-project"
#route53
domain_name = "seyram.site"
alternative_names = ["www.seyram.site"]

# EC2 VARIABLES
instance_name = "dr-project-ec2-pilot"
key_name      = "louis"