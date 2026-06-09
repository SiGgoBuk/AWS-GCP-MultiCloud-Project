# --- Security Groups ---
# bastion-sg : SSH, ICMP만 전체 허용
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Bastion SG: allow SSH and ICMP from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bastion-sg" }
}

# web-sg : HTTP(80), SSH(22), ICMP 전체 허용
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Web SG: allow HTTP/SSH/ICMP from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

# was-sg : TCP 5000, SSH(22), ICMP 전체 허용
resource "aws_security_group" "was_sg" {
  name        = "was-sg"
  description = "WAS SG: allow TCP/5000, SSH, ICMP from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "App TCP 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "was-sg" }
}

# mysql-sg : MySQL(3306)만 전체 허용
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "MySQL SG: allow TCP 3306 from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mysql-sg" }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Redis SG: allow TCP 6379 from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "Redis TCP 6379"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "redis-sg" }
}

# web-lg-sg : HTTP(80), HTTPS(443) 전체 허용
resource "aws_security_group" "web_lg_sg" {
  name        = "web-lg-sg"
  description = "Web Load Gateway SG: allow HTTP and HTTPS from anywhere"
  vpc_id      = aws_vpc.historynet.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-lg-sg" }
}
