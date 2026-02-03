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




####### Security Group #######