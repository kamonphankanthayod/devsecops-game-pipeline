# 1. กำหนด Provider เป็น AWS และเลือก Region ให้ตรงกับที่ตกลงกันไว้
provider "aws" {
  region = "us-east-1"
}

# 2. สร้าง S3 Bucket สำหรับเก็บไฟล์ tfstate (สมุดจดของ Terraform)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "dev-tf-bucket-0116-v3" # เปลี่ยนชื่อให้ไม่ซ้ำใครในโลก ต้อง match กับ backend.tf ใน EKS-TF, jenkins-server ด้วย

  # ป้องกันการเผลอกดลบ Bucket นี้ทิ้งโดยไม่ตั้งใจ (ถ้าอยากลบจริงๆ ต้องมาแก้ค่านี้เป็น false ก่อน)
  force_destroy = true 
}

# 3. เปิดระบบ Versioning เพื่อเก็บประวัติไฟล์ State (เผื่อพังจะได้ย้อนกลับได้)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. [DevSecOps Bonus!] บังคับเข้ารหัสไฟล์ State ที่เก็บบน S3 (Server-Side Encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 5. สร้าง DynamoDB Table สำหรับทำ State Locking (ป้องกันคนในทีมรันโค้ดชนกัน)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "Lock-Files"
  billing_mode = "PAY_PER_REQUEST" # จ่ายตามที่เรียกใช้งานจริง (เหมาะกับ Lab)
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # S = String
  }
}

# 6. แสดงผลลัพธ์ชื่อ Bucket และชื่อ Table ออกมาทางหน้าจอตอนสร้างเสร็จ
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "นำชื่อนี้ไปใส่ในไฟล์ backend.tf ของ Jenkins และ EKS"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "ชื่อของ DynamoDB Table สำหรับ Lock State"
}