##################################
# Provider
##################################
provider "aws" {
  region  = "ca-central-1"
}

##################################
# 1. Create VPC
##################################
resource "aws_vpc" "production_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production-vpc"
  }
}

##################################
# 2. Internet Gateway
##################################
resource "aws_internet_gateway" "production_gw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "production-gw"
  }
}

##################################
# 3. Route Table
##################################
resource "aws_route_table" "production_rt" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_gw.id
  }

  tags = {
    Name = "production-rt"
  }
}

##################################
# 4. Subnet
##################################
resource "aws_subnet" "production_subnet" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "production-subnet"
  }
}

##################################
# 5. Route Table Association
##################################
resource "aws_route_table_association" "production_assoc" {
  subnet_id      = aws_subnet.production_subnet.id
  route_table_id = aws_route_table.production_rt.id
}


##################################
# 6. Security Group
##################################
resource "aws_security_group" "allow_web" {
  name   = "allow_web"
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "allow_web"
  }
}

# SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

##################################
# 7. Network Interface
##################################
resource "aws_network_interface" "production_nic" {
  subnet_id       = aws_subnet.production_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

##################################
# 8. Elastic IP
##################################
resource "aws_eip" "production_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.production_nic.id
  associate_with_private_ip = "10.0.1.50"

  depends_on = [aws_internet_gateway.production_gw]
}

##################################
# 9. EC2 Instance + Apache
##################################
resource "aws_instance" "web_server" {
  ami               = "ami-0abac8735a38475db"
  instance_type     = "t3.micro"
  availability_zone = "ca-central-1a"
  key_name          = "Sana"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.production_nic.id
  }

  //Comment to check git wasef

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl start apache2
    systemctl enable apache2
    echo "Your very first web server" > /var/www/html/index.html
  EOF

  tags = {
    Name = "web-server"
  }
}
