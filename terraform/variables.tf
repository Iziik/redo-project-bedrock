# resource "aws_subnet" "private_az1" {
#   vpc_id            = aws_vpc.altsch_vpc.id
#   cidr_block        = "10.0.0.128/26"
#   availability_zone = local.zone1

#   tags = {
#     Name                                                   = "${local.env}-private_subnet-${local.zone1}"
#     "kubernetes.io/role/internal-elb"                      = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }

# resource "aws_subnet" "private_az2" {
#   vpc_id            = aws_vpc.altsch_vpc.id
#   cidr_block        = "10.0.0.192/26"
#   availability_zone = local.zone2

#   tags = {
#     Name                                                   = "${local.env}-private_subnet-${local.zone2}"
#     "kubernetes.io/role/internal-elb"                      = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.altsch_vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    Name                                                   = "${local.env}-public_subnet-${local.zone1}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.altsch_vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    Name                                                   = "${local.env}-public_subnet-${local.zone2}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.altsch_vpc.id

  tags = {
    Name = "${local.env}-igw"
  }
}

# resource "aws_route_table" "private-rt" {
#   vpc_id = aws_vpc.altsch_vpc.id # Replace with your actual VPC ID

#   route {
#     cidr_block = "0.0.0.0/0"            # Destination: Anywhere
#     nat_gateway_id = aws_nat_gateway.natgw.id       # Replace with your Internet Gateway ID
#   }

#   tags = {
#     Name = "${local.env}-private"
#   }
# }

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.altsch_vpc.id # Replace with your actual VPC ID

  route {
    cidr_block = "0.0.0.0/0"                 # Destination: Anywhere
    gateway_id = aws_internet_gateway.igw.id # Replace with your Internet Gateway ID
  }
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = "local"
  }
  tags = {
    Name = "${local.env}-public"
  }
}

# resource "aws_route_table_association" "private_az1" {
#   subnet_id      = aws_subnet.private_az1.id
#   route_table_id = aws_route_table.private-rt.id
# }

# resource "aws_route_table_association" "private_az2" {
#   subnet_id      = aws_subnet.private_az2.id
#   route_table_id = aws_route_table.private-rt.id
# }

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public-rt.id
}

# resource "aws_eip" "natgw" {
#   domain = "vpc"

#   tags = {
#     Name = "${local.env}-natgw"
#   }
# }

# resource "aws_nat_gateway" "natgw" {
#   allocation_id = aws_eip.natgw.id
#   subnet_id = aws_subnet.public_az1.id

#   tags = {
#     Name = "${local.env}-nat"
#   }
# }