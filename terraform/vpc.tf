resource "aws_vpc" "historynet" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "historynet"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.historynet.id
  tags   = merge(var.tags, { Name = "historynet-igw" })
}
