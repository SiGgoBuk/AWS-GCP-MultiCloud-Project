#######################################################
# WAS NLB + Target Group + Listener + Attachments
#######################################################

# Network Load Balancer (WAS용)
resource "aws_lb" "was_nlb" {
  name               = "was-nlb"
  load_balancer_type = "network"
  internal           = true # 내부용 NLB (필요하면 false로 바꿔서 퍼블릭으로)

  # 보통 WAS가 있는 프라이빗 서브넷 2개 사용
  subnets = [
    aws_subnet.was_a.id,
    aws_subnet.was_b.id
  ]

  tags = {
    Name = "was-nlb"
  }
}

# Target Group (WAS 인스턴스 대상, TCP 5000)
resource "aws_lb_target_group" "was_tg" {
  name        = "was-tg"
  port        = 5000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.historynet.id # 사용 중인 VPC 리소스 이름에 맞게 수정

  health_check {
    protocol            = "TCP"
    port                = "5000"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name = "was-tg"
  }
}

# NLB Listener (5000 -> Target Group)
resource "aws_lb_listener" "was_listener" {
  load_balancer_arn = aws_lb.was_nlb.arn
  port              = 5000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was_tg.arn
  }
}

# Target Group Attachment – was_a
resource "aws_lb_target_group_attachment" "was_a" {
  target_group_arn = aws_lb_target_group.was_tg.arn
  target_id        = aws_instance.was_a.id
  port             = 5000
}

# Target Group Attachment – was_b
resource "aws_lb_target_group_attachment" "was_b" {
  target_group_arn = aws_lb_target_group.was_tg.arn
  target_id        = aws_instance.was_b.id
  port             = 5000
}

#######################################################
# Route 53 Private Hosted Zone + was.cloud.local 레코드
#######################################################

resource "aws_route53_record" "was_cloud_local" {
  zone_id = aws_route53_zone.inter_local.id
  name    = "was.cloud.local"
  type    = "A"

  alias {
    name                   = aws_lb.was_nlb.dns_name
    zone_id                = aws_lb.was_nlb.zone_id
    evaluate_target_health = true
  }
}
