# 1. Private Hosted Zone 생성
resource "aws_route53_zone" "inter_local" {
  name    = "cloud.local"
  comment = "Private hosted zone for internal DNS"

  vpc {
    vpc_id = aws_vpc.historynet.id
  }

  tags = {
    "Name" = "cloud.local"
  }
}

# 2. CNAME 레코드 생성: mydb.inter.local → RDS 엔드포인트
resource "aws_route53_record" "rds_cname" {
  zone_id = aws_route53_zone.inter_local.zone_id
  name    = "db.cloud.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.mysql.address]
}
