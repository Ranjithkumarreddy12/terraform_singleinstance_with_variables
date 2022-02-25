#AWS credentials
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

#VCP resource section. resource name is "VPC"
resource "aws_vpc" "VPC" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
    }
}

#Internet Gateway resource section. resource name is "IGW"
resource "aws_internet_gateway" "IGW" {
    vpc_id = "${aws_vpc.VPC.id}"
	tags = {
        Name = "my_IGW"
    }
}

# Public Subnet resourec section. resource name is "public_subnet"
resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.VPC.id}"
    availability_zone = var.avz
    cidr_block = var.public_cidr
    tags = {
        Name = var.public_subnet
    }
}

#Private Subnet resource section. resource name is "private_subnet"
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.VPC.id}"
    availability_zone = var.avz
    cidr_block = var.private_cidr
    tags = {
        Name = var.private_subnet
    }
}

#Routing Table resource section. resource name "public_routing_table"
resource "aws_route_table" "public_routing_table" {
    vpc_id = "${aws_vpc.VPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.IGW.id}"
    }
    tags = {
        Name = "public_routing_table"
    }
}

resource "aws_route_table" "private_routing_table" {
    vpc_id = "${aws_vpc.VPC.id}"
    tags = {
        Name = "private_routing_table"
    }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

resource "aws_route_table_association" "terraform-private" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#Security Group resource section. resource name is "sg"
resource "aws_security_group" "sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.VPC.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

# Ec2 instance resource section. recource name is "Ubuntu_Server" 
resource "aws_instance" "Ubuntu_Server" {
    ami = var.ami
    instance_type = "t2.micro"
    key_name = var.keyname
    subnet_id = "${aws_subnet.public_subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.sg.id}"]
    associate_public_ip_address = true	
    tags = {
        Name = var.instance_name
    }
}