# Provider Info
provider "aws" {
  region = "us-west-2"
  access_key = local.access_key
  secret_key = local.secret_key
}

# Create VPC
resource "aws_vpc" "akamai_app_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Akamai Three Tiered Application VPC - Test by Virgilio"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "akamai_app_gw" {
  vpc_id = aws_vpc.akamai_app_vpc.id
  tags = {
    Name = "Akamai Internet Gateway - Test by Virgilio"
  }
}

# Create Custom Route Table
resource "aws_route_table" "akamai_app_route_table" {
  vpc_id = aws_vpc.akamai_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.akamai_app_gw.id
  }

  tags = {
    Name = "Akamai Route Table - Test by Virgilio"
  }
}

# Create a Subnet
resource "aws_subnet" "akamai_app_subnet" {
  vpc_id            = aws_vpc.akamai_app_vpc.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Akamai Application Subnet - Test by Virgilio"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "akamai_app_rta" {
  subnet_id      = aws_subnet.akamai_app_subnet.id
  route_table_id = aws_route_table.akamai_app_route_table.id
}

# Create Security Group
resource "aws_security_group" "akamai_app_sg" {
  name        = "akamai_app_sg"
  description = "Security group for Akamai Three Tiered Application - Test by Virgilio"
  vpc_id      = aws_vpc.akamai_app_vpc.id

  # Allow HTTP and SSH from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Akamai Security Group - Test by Virgilio"
  }
}


#deploy EC2 instances 

resource "aws_instance" "akamai_app_instance_lb" {
  ami                      = "ami-00448a337adc93c05"
  instance_type            = "t2.micro"
  availability_zone        = "us-west-2a"
  subnet_id                = aws_subnet.akamai_app_subnet.id
  vpc_security_group_ids   = [aws_security_group.akamai_app_sg.id]
  associate_public_ip_address = true
  key_name                 = "virgilio-key-pair"
  private_ip               = "192.168.0.11"

  tags = {
    Name = "Akamai LB - Test by Virgilio"
  }
}

resource "aws_instance" "akamai_app_instance_web" {
  ami                      = "ami-00448a337adc93c05"
  instance_type            = "t2.micro"
  availability_zone        = "us-west-2a"
  subnet_id                = aws_subnet.akamai_app_subnet.id
  vpc_security_group_ids   = [aws_security_group.akamai_app_sg.id]
  associate_public_ip_address = true
  key_name                 = "virgilio-key-pair"
  private_ip               = "192.168.0.12"

  tags = {
    Name = "Akamai WEB - Test by Virgilio"
  }
}

resource "aws_instance" "akamai_app_instance_db" {
  ami                      = "ami-00448a337adc93c05"
  instance_type            = "t2.micro"
  availability_zone        = "us-west-2a"
  subnet_id                = aws_subnet.akamai_app_subnet.id
  vpc_security_group_ids   = [aws_security_group.akamai_app_sg.id]
  associate_public_ip_address = true
  key_name                 = "virgilio-key-pair"
  private_ip               = "192.168.0.13"

  tags = {
    Name = "Akamai DB - Test by Virgilio"
  }
}

# Output Public IP Addresses
output "lb_public_ip" {
  value = aws_instance.akamai_app_instance_lb.public_ip
}

output "web_public_ip" {
  value = aws_instance.akamai_app_instance_web.public_ip
}

output "db_public_ip" {
  value = aws_instance.akamai_app_instance_db.public_ip
}
