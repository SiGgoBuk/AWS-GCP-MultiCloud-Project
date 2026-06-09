# Amazon Linux 2023 (x86_64) 최신 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Bastion : Public-a 서브넷, 사설IP 10.0.0.10 + 공인IP 할당
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public_a.id
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  private_ip                  = cidrhost(aws_subnet.public_a.cidr_block, 10)

  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
    dnf install -y mysql-community-client --nogpgcheck
  EOF

  tags = { Name = "bastion", Role = "bastion" }
}

# EIP 할당
resource "aws_eip" "bastion_ip" {
  instance = aws_instance.bastion.id
}


# Web : web-a/b -> 각각 .10
resource "aws_instance" "web_a" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.web_a.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id,aws_default_security_group.default.id]
  private_ip             = cidrhost(aws_subnet.web_a.cidr_block, 10)
  depends_on = [ aws_lb.was_nlb ]
  tags = {
    Name = "web-a"
    Role = "web"
  }

  user_data = <<EOF
#!/bin/bash
set -xe

# 패키지 업데이트
dnf update -y

# NGINX 설치
dnf install -y nginx

# nginx lb.conf 생성
tee /etc/nginx/conf.d/lb.conf > /dev/null << 'EOT'
upstream backend_servers {
    server was.cloud.local:5000;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOT

# NGINX 활성화 및 즉시 시작
systemctl start nginx
systemctl enable nginx
EOF
}

resource "aws_instance" "web_b" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.web_b.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id,aws_default_security_group.default.id]
  private_ip             = cidrhost(aws_subnet.web_b.cidr_block, 10)
  depends_on = [ aws_lb.was_nlb ]
  tags = {
    Name = "web-b"
    Role = "web"
  }

  user_data = <<EOF
#!/bin/bash
set -xe

# 패키지 업데이트
dnf update -y

# NGINX 설치
dnf install -y nginx

# nginx lb.conf 생성
tee /etc/nginx/conf.d/lb.conf > /dev/null << 'EOT'
upstream backend_servers {
    server was.cloud.local:5000;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOT

# NGINX 활성화 및 즉시 시작
systemctl start nginx
systemctl enable nginx
EOF
}


# WAS : was-a/b -> 각각 .10
resource "aws_instance" "was_a" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.was_instance_type
  subnet_id              = aws_subnet.was_a.id
  key_name               = var.key_name
  vpc_security_group_ids = [
    aws_security_group.was_sg.id,
    aws_default_security_group.default.id
  ]
  private_ip             = cidrhost(aws_subnet.was_a.cidr_block, 10)

  tags = {
    Name = "was-a"
    Role = "was"
  }

  # user_data 변경 시 인스턴스 재생성
  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
set -x

##############################################
# 기본 패키지 설치
##############################################
dnf install -y python3-pip git

##############################################
# 개발 및 DB 관련 패키지 설치
##############################################
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
dnf install -y mysql-community-devel --nogpgcheck
dnf groupinstall -y "Development Tools"
dnf install -y gcc python3-devel openssl-devel zlib zlib-devel
dnf install -y mariadb-connector-c-devel pkgconf-pkg-config
dnf install -y mariadb-connector-c

##############################################
# Python 패키지 설치 (로그 남김)
##############################################
pip3 install --no-cache-dir \
  Flask \
  Flask-WTF \
  Flask-Login \
  Flask-MySQLdb \
  mysqlclient \
  Flask-Session \
  Werkzeug \
  redis \
  >> /var/log/pip-install.log 2>&1

##############################################
# WAS 애플리케이션 배포
##############################################
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

git clone https://github.com/frodo5020/myapp.git
chown -R ec2-user:ec2-user /home/ec2-user/app

##############################################
# systemd 서비스 등록
##############################################
tee /etc/systemd/system/mywas.service > /dev/null << 'EOT'
[Unit]
Description=Flask Web App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/myapp
ExecStart=/usr/bin/python3 /home/ec2-user/app/myapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable mywas
systemctl start mywas

EOF
}

resource "aws_instance" "was_b" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.was_instance_type
  subnet_id              = aws_subnet.was_b.id
  key_name               = var.key_name
  vpc_security_group_ids = [
    aws_security_group.was_sg.id,
    aws_default_security_group.default.id
  ]
  private_ip             = cidrhost(aws_subnet.was_b.cidr_block, 10)

  tags = {
    Name = "was-b"
    Role = "was"
  }

  # user_data 변경 시 인스턴스 재생성
  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
set -x

##############################################
# 기본 패키지 설치
##############################################
dnf install -y python3-pip git

##############################################
# 개발 및 DB 관련 패키지 설치
##############################################
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
dnf install -y mysql-community-devel --nogpgcheck
dnf groupinstall -y "Development Tools"
dnf install -y gcc python3-devel openssl-devel zlib zlib-devel
dnf install -y mariadb-connector-c-devel pkgconf-pkg-config
dnf install -y mariadb-connector-c

##############################################
# Python 패키지 설치 (로그 남김)
##############################################
pip3 install --no-cache-dir \
  Flask \
  Flask-WTF \
  Flask-Login \
  Flask-MySQLdb \
  mysqlclient \
  Flask-Session \
  Werkzeug \
  redis \
  >> /var/log/pip-install.log 2>&1

##############################################
# WAS 애플리케이션 배포
##############################################
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

git clone https://github.com/frodo5020/myapp.git
chown -R ec2-user:ec2-user /home/ec2-user/app

##############################################
# systemd 서비스 등록
##############################################
tee /etc/systemd/system/mywas.service > /dev/null << 'EOT'
[Unit]
Description=Flask Web App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/myapp
ExecStart=/usr/bin/python3 /home/ec2-user/app/myapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable mywas
systemctl start mywas

EOF
}
