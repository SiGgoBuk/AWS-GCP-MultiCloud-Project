# ---------- Public ----------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.historynet.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "public subnet-a"
    Tier = "public"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.historynet.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "public subnet-b"
    Tier = "public"
  })
}

# ---------- Private: WEB ----------
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = var.azs[0]
  tags = merge(var.tags, {
    Name = "web-a"
    Tier = "private"
  })
}

resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.azs[1]
  tags = merge(var.tags, {
    Name = "web-b"
    Tier = "private"
  })
}

# ---------- Private: WAS ----------
resource "aws_subnet" "was_a" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = var.azs[0]
  tags = merge(var.tags, {
    Name = "was-a"
    Tier = "private"
  })
}

resource "aws_subnet" "was_b" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.azs[1]
  tags = merge(var.tags, {
    Name = "was-b"
    Tier = "private"
  })
}

# ---------- Private: DB ----------
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = var.azs[0]
  tags = merge(var.tags, {
    Name = "db-a"
    Tier = "private"
  })
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.historynet.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = var.azs[1]
  tags = merge(var.tags, {
    Name = "db-b"
    Tier = "private"
  })
}
