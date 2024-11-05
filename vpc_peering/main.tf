locals {
  region1 = "us-east-2"
  region2 = "us-west-1"

  vpc1_cidr       = "10.0.0.0/16"
  subnet1_cidr    = "10.0.0.0/24"
  ec2_private_ip1 = "10.0.0.5"

  vpc2_cidr       = "10.1.0.0/16"
  subnet2_cidr    = "10.1.0.0/24"
  ec2_private_ip2 = "10.1.0.5"
}

#Creates two basic VPCs in two different regions to be peered

module "vpc_region1" {
  source            = "./modules/vpc"
  vpc_cidr_block    = local.vpc1_cidr
  subnet_cidr_block = local.subnet1_cidr
}

module "vpc_region2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.region2
  }
  vpc_cidr_block    = local.vpc2_cidr
  subnet_cidr_block = local.subnet2_cidr
}

#Creates two EC2 instances with security groups to test 
#pinging each other before and after the peer connection between the vpcs

module "ec2_region1" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc_region1.vpc_id
  subnet_id  = module.vpc_region1.subnet_id
  private_ip = local.ec2_private_ip1
}

module "ec2_region2" {
  source = "./modules/ec2"
  providers = {
    aws = aws.region2
  }
  vpc_id     = module.vpc_region2.vpc_id
  subnet_id  = module.vpc_region2.subnet_id
  private_ip = local.ec2_private_ip2
}

#VPC Peering

resource "aws_vpc_peering_connection" "peer1" {
  vpc_id      = module.vpc_region1.vpc_id
  peer_vpc_id = module.vpc_region2.vpc_id
  peer_region = local.region2
}

#The peering needs to be accepted before taking effect

resource "aws_vpc_peering_connection_accepter" "peer1" {
  provider                  = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

#Adding routes to route tables
#Besides doing the peering it is necessary to create a route for the traffic to flow between VPCs

resource "aws_route" "peering_route_rt_vpc1" {
  route_table_id            = module.vpc_region1.default_rt_id
  destination_cidr_block    = local.vpc2_cidr                     #Map VPC2 cidrs into VPC1 route table
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id #Route Target
}

resource "aws_route" "peering_route_rt_vpc2" {
  provider                  = aws.region2
  route_table_id            = module.vpc_region2.default_rt_id
  destination_cidr_block    = local.vpc1_cidr                     #Map VPC1 cidrs into VPC2 route table
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id #Route Target
}