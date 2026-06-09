#######################################################
# ALB + Target Group + Listener + Target Attachment
#######################################################

# ALB용 Security Group (80 포트 오픈)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.historynet.id # 사용 중인 VPC 리소스 이름으로 변경

  # 인터넷에서 ALB로 80 포트 허용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB에서 나가는 트래픽 전체 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.alb_sg.id, aws_default_security_group.default.id]

  tags = {
    Name = "web-alb"
  }
}

# Target Group (EC2 두 대를 HTTP 80 포트로 붙일 예정)
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.historynet.id # VPC 리소스 이름 맞게 수정

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "web-tg"
  }
}

# ALB Listener (80 -> Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Target Group Attachment – web_a
resource "aws_lb_target_group_attachment" "web_a" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_a.id
  port             = 80
}

# Target Group Attachment – web_b
resource "aws_lb_target_group_attachment" "web_b" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_b.id
  port             = 80
}
