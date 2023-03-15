resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = "${var.private_subnet[count.index]}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.private}"
  }
}

resource "aws_eip" "lb" {
  vpc      = true
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     =  aws_subnet.private.id


  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "example" {
  vpc_id = data.aws_vpc.vpc.id
}



  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }

resource "aws_route_table_association" "a" {
  subnet_id      =  aws_subnet.private.id

  route_table_id = aws_route_table" "example"
}


terraform {
  backend "s3" {
    bucket =  "3.devops.candidate.exam"
    key    = "javed.shaikh/terraform.tfstate
    region =  "eu-west-1"
  }
}
