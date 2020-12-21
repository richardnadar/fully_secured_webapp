provider "aws" {
  region = "ap-south-1"
  profile = "richie"
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_vpc" "myownvpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc1"
  }
}


resource "aws_subnet" "mysub_private" {
  vpc_id     = aws_vpc.myownvpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my_private_sub"
  }
}


resource "aws_subnet" "mysub_public" {
  vpc_id     = aws_vpc.myownvpc1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "my_public_sub"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.myownvpc1.id

  tags = {
    Name = "Internetgateway"
  }
}

#Creaton of Routing table and associating it with our Internet Gateway
resource "aws_route_table" "my_route" {
  depends_on = [aws_internet_gateway.my_gateway, ]
  vpc_id = aws_vpc.myownvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = {
    Name = "RoutingTable"
  }
}

resource "aws_route_table_association" "route_resource" {
  depends_on = [ aws_route_table.my_route, ]
  subnet_id      = aws_subnet.mysub_public.id
  route_table_id = aws_route_table.my_route.id
}

resource "aws_security_group" "sg_for_wordpress" {
  name        = "allow_wp"
  description = "Allow ssh and http"
  vpc_id      = aws_vpc.myownvpc1.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
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
    Name = "wpsecgrp"
  }
}

resource "aws_security_group" "sg_for_mysql" {
  name        = "allow_mysql"
  description = "Allow wordpress to MySQL"
  vpc_id      = aws_vpc.myownvpc1.id

  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_for_wordpress.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sqlsecgrp"
  }
}


# To launch instance for wordpress in public subnet of our VPC, so that it can connect with outside world
resource "aws_instance" "mywp_os" {
  count = var.instance_count

  ami                         = var.wordpress_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.mysub_public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg_for_wordpress.id]

  tags = {
    Name = "mywpos"
  }
}

# To launch instance for mysql in private subnet of our VPC
resource "aws_instance" "mysql_os" {
  count = var.instance_count

  ami                         = var.mysql_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.mysub_private.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg_for_mysql.id]

  tags = {
    Name = "mysqlos"
  }
}