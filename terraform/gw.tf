# 퍼블릭 라우팅 테이블 (IGW 경로)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.historynet.id
  tags   = merge(var.tags, { Name = "historynet-public-rt" })
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# NAT 게이트웨이 (각 AZ 1개씩) - 퍼블릭 서브넷에 위치
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "historynet-nat-eip-a" })
}
resource "aws_nat_gateway" "a" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat_a.id
  tags          = merge(var.tags, { Name = "historynet-nat-a" })
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "historynet-nat-eip-b" })
}
resource "aws_nat_gateway" "b" {
  subnet_id     = aws_subnet.public_b.id
  allocation_id = aws_eip.nat_b.id
  tags          = merge(var.tags, { Name = "historynet-nat-b" })
  depends_on    = [aws_internet_gateway.this]
}

# 프라이빗 라우팅 테이블 (AZ별 NAT 경로)
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.historynet.id
  tags   = merge(var.tags, { Name = "historynet-private-rt-a" })
}
resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
}
# web/was/db -a 연결
resource "aws_route_table_association" "web_a" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.private_a.id
}
resource "aws_route_table_association" "was_a" {
  subnet_id      = aws_subnet.was_a.id
  route_table_id = aws_route_table.private_a.id
}
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.historynet.id
  tags   = merge(var.tags, { Name = "historynet-private-rt-b" })
}
resource "aws_route" "private_b_nat" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.b.id
}
# web/was/db -b 연결
resource "aws_route_table_association" "web_b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.private_b.id
}
resource "aws_route_table_association" "was_b" {
  subnet_id      = aws_subnet.was_b.id
  route_table_id = aws_route_table.private_b.id
}
resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.private_b.id
}
