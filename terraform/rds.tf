# Subnet group (RDS는 여러 서브넷이 필요)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "historynet-rds-subnet-group"
  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = {
    Name = "sample-rds-subnet-group"
  }
}

# RDS 인스턴스
resource "aws_db_instance" "mysql" {
  identifier           = "mysql8"
  engine               = "mysql"
  engine_version       = "8.0.43"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp3"
  username             = "admin"
  password             = "History2026!"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.mysql_sg.id,
    aws_default_security_group.default.id
  ]

  db_name             = "history"
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az            = false
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name = "mysql8"
  }
}
