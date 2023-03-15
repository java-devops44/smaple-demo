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
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
