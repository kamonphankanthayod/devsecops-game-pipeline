# 1. สร้างตัวกุญแจ (Private/Public Key)
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. นำ Public Key ไปลงทะเบียนใน AWS
resource "aws_key_pair" "jenkins_key" {
  key_name   = "cs365-project-key" # ชื่อกุญแจบนหน้าเว็บ AWS
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# 3. นำ Private Key มาสร้างเป็นไฟล์ .pem ลงในเครื่องของคุณ และตั้งสิทธิ์ 400 ให้เลย
resource "local_file" "private_key_pem" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/cs365-project-key.pem"
  file_permission = "0400"
}