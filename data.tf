data "aws_nat_gateway" "nat" {
  id = "nat-07863fc48f5b99110"
}

data "aws_vpc" "vpc" {
  id = "vpc-0de2bfe0f5fc540e0"
}

data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}
