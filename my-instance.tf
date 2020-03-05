data "aws_availability_zones" "available" {}

provider "aws" {
access_key = var.aws_access_key
secret_key = var.aws_secret_key
region = var.aws_region
skip_requesting_account_id = true
}

# This is the resource for vpc

resource "aws_vpc" "terraform_vpc" {
  cidr_block       = var.VpcCidr
  instance_tenancy = "dedicated"
  tags = {
    Name = var.environment
  }
}

# This is the resource for aws_internet_gateway

resource "aws_internet_gateway" "terraform_gw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = var.environment
  }
}

resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
 tags = {
    Name = "Public-Subnet-1 var.environment"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Public-Subnet-2 var.environment"
  }
}



resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  tags  = {
    Name = "private-Subnet-1 var.environment"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-Subnet-2 var.environment"
  }
}

resource "aws_eip" "elastic-ip-for-nat-gw-1" {
  vpc                       = true
  depends_on                = [aws_internet_gateway.terraform_gw,]
}

resource "aws_eip" "elastic-ip-for-nat-gw-2" {
  vpc                       = true
  depends_on                = [aws_internet_gateway.terraform_gw,]
}

resource "aws_nat_gateway" "nat-gw1" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw-1.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "NAT-GW1 var.environment"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw-1,]
}

resource "aws_nat_gateway" "nat-gw2" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw-2.id
  subnet_id     = aws_subnet.public-subnet-2.id
  tags = {
    Name = "NAT-GW2 var.environment"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw-2,]
}

resource "aws_route_table" "private-route-table1" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "Private-Route-Table1 var.environment"
  }
}

resource "aws_route" "nat-gw-route1" {
  route_table_id         = aws_route_table.private-route-table1.id
  nat_gateway_id         = aws_nat_gateway.nat-gw1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private-route-table2" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags  = {
    Name = "Private-Route-Table2 var.environment"
  }
}

resource "aws_route" "nat-gw-route2" {
  route_table_id         = aws_route_table.private-route-table2.id
  nat_gateway_id         = aws_nat_gateway.nat-gw2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private-route-table1.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-route-2-association" {
  route_table_id = aws_route_table.private-route-table2.id
  subnet_id      = aws_subnet.private-subnet-2.id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "Public-Route-Table var.environment"
  }
}

resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-route-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}


resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.terraform_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

}

# Create the Security Group
resource "aws_security_group" "Web_Server_Security_Group" {
  vpc_id       = aws_vpc.terraform_vpc.id
  name         = "My Web Server Security Group"
  description  = "My Web Server Security Group"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "My Web Server Security Group"
   Description = "My Web Serer Security Group"
  }
}

# Create the Security Group for LB
resource "aws_security_group" "LB_Security_Group" {
  vpc_id       = aws_vpc.terraform_vpc.id
  name         = "My LB Security Group"
  description  = "My LB Security Group"
  
  # allow ingress of port 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
   Name = "My LB Security Group"
   Description = "My LB Security Group"
  }
}

resource "aws_launch_configuration" "WebApp-Lauch" {
  image_id        = "ami-0d1cd67c26f5fca19"
  instance_type   = "t2.micro"
  #security_groups = [aws_security_group.Web_Server_Security_Group.id]
  user_data = <<-EOF
              #!/bin/bash
              #install docker
              apt-get update
              apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y docker-ce
              usermod -aG docker ubuntu
              docker run -p 8080:8080 tomcat:8.0
              echo "Hello, World" > index.html
              EOF
   ebs_block_device {
    device_name = "/dev/sdk"
    snapshot_id = "snap-097268252a2890bea"
    volume_size = 10
    volume_type = "io1"
    iops = 300
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "Auto-Scaling-Group" {
  availability_zones = [data.aws_availability_zones.available.names[0]]
  launch_configuration = aws_launch_configuration.WebApp-Lauch.id
  min_size = 1
  max_size = 2
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

/*
resource "aws_instance" "web_server" {
ami = "ami-061392db613a6357b"
instance_type = "t2.small"
tags ={
Name = "terraform_server"
}
}
*/
output "terraform-VPCID" {
  value = aws_vpc.terraform_vpc.id
  description = "A reference to the created VPC"
}

output "terraform-private-route1" {
  value = aws_route_table.private-route-table1
  description = "Private Routing AZ1"
}

output "terraform-private-route2" {
  value = aws_route_table.private-route-table2
  description = "Private Routing AZ2"
}

output "terraform-public-route" {
  value = aws_route_table.public-route-table
  description = "Public Routing"
}

output "terraform-public-subnet1" {
  value = aws_subnet.public-subnet-1
  description = "Public Routing AZ1"
}

output "terraform-public-subnet2" {
  value = aws_subnet.public-subnet-2
  description = "Public Routing AZ2"
}
output "terraform-private-subnet1" {
  value = aws_subnet.private-subnet-1
  description = "Private Routing AZ1"
}
output "terraform-private-subnet2" {
  value = aws_subnet.private-subnet-2
  description = "Private Routing AZ2"
