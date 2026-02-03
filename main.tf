##### Creating VPC #####

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "My_VPC"
  }
}

##### Creating Subnet #####

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_CIDR
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet_1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnet_CIDR
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private_Subnet_1"
  }
}


##### Creating Internet Gateway #####

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My_Internet_Gateway"
  }
}


##### Creating NAT Gateway #####

resource "aws_eip" "nat_eip" {

  tags = {
    Name = "Nat_EIP"
  }
}

resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "My_Nat_Gateway"
  }
}



##### Creating Public Route Table #####

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Public_Route_Table"
  }
}

resource "aws_route" "Public-RT-route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id

}


resource "aws_route_table_association" "public_rt_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}





##### Creating Private Route Table #####

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private_Route_Table"
  }
}

resource "aws_route" "Private-RT-route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.my_nat_gw.id

}


resource "aws_route_table_association" "private_rt_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}




####### Security Group #######      || Web-Tier Security Group

resource "aws_security_group" "web_tier_sg" {
  name        = "Web_Tier_SG"
  description = "Security Group for Public Web Tier Instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow inbound traffic from Web-Tier SG"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow inbound traffic from Web-Tier SG"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow inbound traffic from Web-Tier SG"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "Web_Tier_SG"
  }
}



####### Security Group #######      || App-Tier Security Group

resource "aws_security_group" "app_tier_sg" {
  name        = "App_Tier_SG"
  description = "Security Group for Private App Tier Instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    description     = "Allow inbound traffic from Web-Tier SG"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    description     = "Allow inbound traffic from Web-Tier SG"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "Allow inbound traffic from Web-Tier SG"
    security_groups = [aws_security_group.web_tier_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "Web_Tier_SG"
  }
}



########## Creating EC2 Instances ##########   || Web Tier EC2 Instance

resource "aws_instance" "web_tier_instance" {

  ami                         = var.web-ec2-ami
  instance_type               = var.web-ec2-instance-type
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.web_tier_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Web_Tier_Instance"
  }
}


########## Creating EC2 Instances ##########   || App Tier EC2 Instance

resource "aws_instance" "app_tier_instance" {

  ami                         = var.web-ec2-ami
  instance_type               = var.web-ec2-instance-type
  subnet_id                   = aws_subnet.private_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.app_tier_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "App_Tier_Instance"
  }
}