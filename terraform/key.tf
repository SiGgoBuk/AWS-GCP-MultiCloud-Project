# 1. SSH Private Key 생성
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. AWS EC2 Key Pair 생성
resource "aws_key_pair" "generated_key" {
  key_name   = "historykey"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# 3. Windows에 폴더 생성 (C:\historykey)
resource "null_resource" "create_historykey_dir" {
  provisioner "local-exec" {
    command = "powershell.exe -Command \"New-Item -ItemType Directory -Path 'C:\\historykey' -Force\""
  }
}

# 4. Private Key 파일 생성
resource "local_file" "private_key_pem" {
  depends_on      = [null_resource.create_historykey_dir]
  filename        = "C:/historykey/historykey.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}
