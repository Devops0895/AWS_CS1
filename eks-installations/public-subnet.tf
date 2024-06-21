resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name        = "${terraform.workspace}-public_subnet_1"
    Subnet-Type = "public"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name        = "${terraform.workspace}-public_subnet_2"
    Subnet-Type = "public"
  }
}