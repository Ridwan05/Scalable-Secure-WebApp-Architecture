resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "webappVPC"
  }
}

# Create 6 Subnets
resource "aws_subnet" "subnets" {
  for_each = {
    "Subnet1" = {
      cidr_block        = var.cidr_blocks[0]
      availability_zone = var.availability_zone[0]
      tags              = { "Name" = "Subnet1" }
    }
    "Subnet2" = {
      cidr_block        = var.cidr_blocks[1]
      availability_zone = var.availability_zone[1]
      tags              = { "Name" = "Subnet2" }
    }
    "Subnet3" = {
      cidr_block        = var.cidr_blocks[2]
      availability_zone = var.availability_zone[2]
      tags              = { "Name" = "Subnet3" }
    }
    "Subnet4" = {
      cidr_block        = var.cidr_blocks[3]
      availability_zone = var.availability_zone[0]
      tags              = { "Name" = "Subnet4" }
    }
    "Subnet5" = {
      cidr_block        = var.cidr_blocks[4]
      availability_zone = var.availability_zone[1]
      tags              = { "Name" = "Subnet4" }
    }
    "Subnet6" = {
      cidr_block        = var.cidr_blocks[5]
      availability_zone = var.availability_zone[2]
      tags              = { "Name" = "Subnet6" }
    }
  }
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags                    = each.value.tags

}

# Create internet gateway
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    "Name" = "Mygw"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "privNat" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.subnets["Subnet1"].id
}

# Create route to the internet
resource "aws_route_table" "my_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }

  tags = {
    "Name" = "myRtb"
  }
}

# Create private route
resource "aws_route_table" "priv_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.privNat.id

  }

  tags = {
    "Name" = "private_route"
  }
}

# Make Subnet1, Subnet2 & Subnet3, public subnets
resource "aws_route_table_association" "myRtb" {
  for_each = {
    "a" = { subnet_id = aws_subnet.subnets["Subnet1"].id }
    "b" = { subnet_id = aws_subnet.subnets["Subnet2"].id }
    "c" = { subnet_id = aws_subnet.subnets["Subnet3"].id }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.my_rtb.id
}

# Make Subnet4, Subnet5 & Subnet6, private subnets
resource "aws_route_table_association" "privRtb" {
  for_each = {
    "a" = { subnet_id = aws_subnet.subnets["Subnet4"].id }
    "b" = { subnet_id = aws_subnet.subnets["Subnet5"].id }
    "c" = { subnet_id = aws_subnet.subnets["Subnet6"].id }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.priv_rtb.id
}

# Create security to allow access within the VPC and from the loadbalancer
resource "aws_security_group" "ec2web_access" {
  name        = "allow_ec2web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.my_vpc.cidr_block]
    security_groups = [aws_security_group.elbweb_access.id]
  }
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.my_vpc.cidr_block]
    security_groups = [aws_security_group.elbweb_access.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "ec2web_access"
  }
}

# Create security to allow access from the internet to the loadbalncer
resource "aws_security_group" "elbweb_access" {
  name        = "allow_elbweb_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "elbweb_access"
  }
}

# Create security group for the RDS
resource "aws_security_group" "db_sg" {
  name        = "Database SG"
  description = "Allow inbound traffic from application layer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allow traffic from application layer"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database SG"
  }
}

