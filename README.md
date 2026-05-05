# devsecops-game-pipeline
End-to-end DevSecOps CI/CD pipeline to build, scan, and deploy a containerized game on AWS Kubernetes using Jenkins, Trivy, Docker, and security best practices.

Some Terraform configurations in this repository are adapted from
[End-to-End-Kubernetes-DevSecOps-Tetris-Project](https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project)


Original work licensed under the Apache License 2.0.


# DevSecOps Pipeline: Infrastructure Setup Guide

คู่มือนี้อธิบายขั้นตอนการสร้างโครงสร้างพื้นฐาน (Infrastructure as Code) บน AWS สำหรับโปรเจค DevSecOps (Jenkins, EKS, Kubernetes) เพื่อใช้สำหรับ Deploy เกม Tetris 

เนื่องจากเราใช้งาน **AWS Learner Lab** กรุณาทำตามขั้นตอนอย่างระมัดระวัง โดยเฉพาะเรื่องการตั้งค่า Credentials ที่มีการหมดอายุ

## Prerequisites (สิ่งที่ต้องเตรียม)
1. ติดตั้ง `git`, `terraform` และ `aws-cli` ไว้ในเครื่อง
2. บัญชี AWS Learner Lab ที่กดปุ่ม **Start Lab** เรียบร้อยแล้ว (มีไฟสีเขียวติด)

---

## Step 1: Clone Repository
เริ่มต้นด้วยการดึงโค้ดโปรเจคลงมาที่เครื่อง Local:
```bash
git clone https://github.com/kamonphankanthayod/devsecops-game-pipeline.git
cd devsecops-game-pipeline
```

---

## Step 2: Configure AWS Learner Lab Credentials
เนื่องจาก AWS Lab Account มีการเปลี่ยน Key ทุกๆ 3-4 ชั่วโมง ห้ามตั้งค่าผ่าน /etc/environment ถาวร ให้ใช้วิธีนี้แทน:

1. ไปที่หน้าเว็บ AWS Learner Lab คลิกแท็บ AWS Details -> Show (ตรงข้อความ AWS CLI)

2. ก๊อปปี้โค้ดทั้ง 3 บรรทัด (aws_access_key_id, aws_secret_access_key, aws_session_token)

3. เปิด Terminal แล้วรันคำสั่ง:
```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

4. วางโค้ดที่ก๊อปปี้มาลงไป (หากมีของเก่า ให้ลบของเก่าทิ้งให้หมดก่อน) หน้าตาต้องเป็นแบบนี้:
```
[default]
aws_access_key_id=ASIAXQLG2E2H5CBHXJQ4
aws_secret_access_key=t4l8WvbdG+K06280oLqMxJxsmUNLUCgp7bhNb9md
aws_session_token=IQoJb3JpZ2luX2VjELT//////////wEaCXVzLXdlc3QtMiJHMEUCIQCv/7r7s66M7fq1brIzlFoK7jav8EgW0aijOENQwuPbNQIgJwrDSbCmyZRuW++62yNpNlZbf94eTIMQykTdp>
region=us-east-1
```
กด Ctrl+O -> Enter เพื่อเซฟ และ Ctrl+X เพื่อออก

---

## Step 3: Bootstrap Backend (ทำเฉพาะครั้งแรกหรือตอนย้าย Account)
เราจำเป็นต้องสร้าง S3 Bucket และ DynamoDB Table เพื่อใช้เก็บและล็อกไฟล์ State ของ Terraform

1. เข้าไปที่โฟลเดอร์ Bootstrap:
```bash
cd terraform/bootstrap-backend
```

2. รันคำสั่งสร้าง Backend:
```bash
terraform init
terraform apply --auto-approve
```

3. เมื่อรันเสร็จ ระบบจะแสดง **ชื่อ S3 Bucket และ Dynamodb Table** ออกมา ให้เช็คชื่อนั้นได้กับในไฟล์ `terraform/jenkins-server/backend.tf` และ `terraform/EKS-TF/backend.tf` ว่ามีความสอดคล้องกัน

---

## Step 4: Provision Jenkins Server & KeyPair
เมื่อมีที่เก็บ State แล้ว เราจะมาสร้างโรงงาน CI/CD (Jenkins Server) กัน

1. ย้ายไปที่โฟลเดอร์ `jenkins-server`:
```bash
cd ../jenkins-server
```

2. รันคำสั่งสร้างเครื่อง Jenkins:
```bash
terraform init
terraform apply -var-file=variables.tfvars --auto-approve
```

> **Note:** ในขั้นตอนนี้ Terraform จะสร้าง Key Pair อัตโนมัติ และดาวน์โหลดไฟล์ `.pem` ลงมาไว้ในโฟลเดอร์นี้ พร้อมตั้งค่า `chmod 400` ให้เรียบร้อย (ไม่ต้องไปสร้างมือผ่านเว็บ AWS Console)

3. ระบบจะใช้เวลาประมาณ 5-8 นาที ในการติดตั้ง Jenkins, Docker, Terraform และเครื่องมืออื่นๆ ผ่าน user_data (ทำงานอยู่เบื้องหลัง)

> **Pro Tip**: หากต้องการดูสถานะการติดตั้งแบบ Real-time ให้ใช้ไฟล์ .pem ที่ได้มา SSH เข้าไปในเครื่อง แล้วรันคำสั่ง:
```tail -f /var/log/cloud-init-output.log```
(กด Ctrl+C เพื่อออกเมื่อติดตั้งเสร็จสิ้น)

---

## Step 5: Configure Jenkins & Verify Tools
ตรวจสอบความพร้อมของเครื่องมือและตั้งค่าเริ่มต้นให้กับ Jenkins

1. SSH เข้าไปในเครื่อง Jenkins (ใช้ Public IP จาก AWS Console):
```bash
ssh -i "cs365-project-key.pem" ubuntu@<Public-IPv4-Address>
```
 
2. ลองตรวจสอบเวอร์ชันเครื่องมือเพื่อความชัวร์:
```bash
jenkins --version
docker --version
docker ps
terraform --version
kubectl version --client
aws --version
trivy --version
```

3. ดึงรหัสผ่านเริ่มต้นของ Jenkins:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
 
4. เปิดเบราว์เซอร์ไปที่ ```http://<Public-IPv4-Address>:8080``` นำรหัสผ่านที่ได้ไปกรอกเพื่อ Unlock

5. เมื่อปลดล็อกแล้ว ให้คลิกเลือก `Install suggested plugins` และรอระบบติดตั้ง

6. สร้าง Admin User(Create First Admin User) (ตัวอย่าง: Username admin-test / Password admin-test) แล้วกด `Save and Continue`

7. กด `Save and Finish` และกด `Start using Jenkins` ก็จะเข้าสู่หน้า Dashboard ที่มีข้อความ "Welcome to Jenkins!"

---

## Step 6: Deploy the EKS Cluster using Jenkins
ใช้ Jenkins รัน Terraform เพื่อสร้าง EKS Cluster แบบอัตโนมัติ

1. ไปที่ Jenkins Dashboard -> Manage Jenkins(ไอคอนฟันเฟือง) -> Plugins -> Available plugins

2. ค้นหาและติดตั้ง Plugins เหล่านี้ (ไม่ต้อง Restart):
```
AWS Credentials
Pipeline: AWS Steps
Pipeline: Stage View
Rebuilder
```

3. ไปที่ Manage Jenkins -> Credentials -> System -> Global credentials และเพิ่ม AWS Credentials แล้วกรอก
- ID: `aws-key`
- Access Key ID: `<aws_access_key_id>`
- Secret Access Key: `<aws_secret_access_key>`
แล้วกด Create

6. กลับมาหน้าแรก กด New Item สร้าง Pipeline Job ชื่อ `eks-deploy-aws` 

7. Select an item type เลือก `Pipeliine` กด OK แล้วนำโค้ดที่เขียนไว้ในไฟล์ `Jenkins-Pipeline-Code/Jenkinsfile-EKS-Terraform` มาวางลงในส่วนของ Pipeline Script

8. ให้แก้โค้ดบรรทัดนี้ ด้วย key ของ AWS Learner Lab Credentials
```
environment {
        AWS_ACCESS_KEY_ID = 'XXXXXX'
        AWS_SECRET_ACCESS_KEY = 'XXXXX'
        AWS_SESSION_TOKEN = 'XXXXX'
        AWS_DEFAULT_REGION = 'us-east-1'
    }
```
จะได้ คล้ายๆแบบนี้
```
environment {
        AWS_ACCESS_KEY_ID = 'ASIAXQLG2E2H5CBHXJQ4'
        AWS_SECRET_ACCESS_KEY = 't4l8WvbdG+K06280oLqMxJxsmUNLUCgp7bhNb9md'
        AWS_SESSION_TOKEN = 'IQoJb3JpZ2luX2VjELT//////////wEaCXVzLXdlc3QtMiJHMEUCIQCv/7r7s66M7fq1brIzlFoK7jav8EgW0aijOENQwuPbNQIgJwrDSbCmyZRuW++62yNpNlZbf94eTIMQykTdpP0QiQ0qvwIIfRABGgw1MTYxNDg1Njk3NDMiDFZHMeY2ZCbFyPjzSyqcAt29WtTucVIwt/MuJIvtrdcgoA6+61EiGfE1yBZoVVhyxS4PMLEgA9lqp3zuI9LaWC2suZhSrac+ZQN29nmGHSpR2u83W1ijRxrnDEBbjofjvYwvU4vS4N7j2PG77DMZTXISYWbA+S+YJQ0vlh4qW2WMJO4hqxCHX/1G/Pvj3ZRqcy2Qs5tUE0IK6oEFBmicj1zhjOcLRMdMo47+FLJbfUmgGLu0hYWrx2rBVezzuR53GO1FQ+7Sl8bEM+f+wdp1dkbwnBRq8xgN/3DYtvxOsGYuJIYHgLNSiz/0HaAVWR+Bka3VR4WoTkv9tOYAZWn8N/hTd67G3KQIs/rhDP48d4jXF4ei+aQFLDWr0mU5puAL9xdBBMV4J2sGVupkMKzZ5c8GOp0B5mCFAjz8QzextmSatVX7r3310wCaLFpXRiGz2EjSNG1E/V0+v5LDmK/23bB97z7ja0MjFL0srm0dIDwoFiQlIk/RxtrqNv7g0ihjgnZnTK8WpnzkmGHMQVhz2WyWHMdfeFKCjld9LIN2c1QFrGH20uKFXahbJ9lmdt7oYC1cZUBPysp65N/mpDnI7iIU8uvamdj6/Vrf7VXHNLtWTw=='
        AWS_DEFAULT_REGION = 'us-east-1'
    }
```

9. กด Save แล้วกด Build Now

> *Note:* โค้ด Pipeline ชุดนี้จะทำงานโดยไปดึงโค้ด Terraform จาก GitHub ในโฟลเดอร์ terraform/EKS-TF มาทำงานสร้างระบบให้เองอัตโนมัติ

10. หลังจาก Pipeline รันผ่านแล้ว ให้รันคำสั่งเช็คความสมบูรณ์จากเครื่อง Jenkins:
```bash
aws eks update-kubeconfig --region us-east-1 --name Tetris-EKS-Cluster
kubectl get nodes
```

---

## Step 7: Team Access & Next Steps (การเข้าถึงระบบของสมาชิกในทีม)
เมื่อโครงสร้างพื้นฐานทั้งหมดสร้างเสร็จสมบูรณ์ สมาชิกในทีมสามารถเข้าถึงระบบเพื่อทำงานในส่วนของ CI/CD และ GitOps ได้ตามรายละเอียดดังนี้:

1. การเข้าใช้งาน Jenkins (สำหรับจัดการ CI Pipeline)
* **URL:** `http://<Jenkins-EC2-Public-IP>:8080` (ตรวจสอบ IP ล่าสุดได้จาก AWS Console)
* **Username/Password:** `admin-test` / `admin-test` (หรือตามที่ผู้ดูแลระบบตั้งค่าไว้)
* **Next Step:** เข้าไปสร้าง Pipeline สแกนโค้ด, Build Docker Image และ Push ขึ้น Registry

2. การเชื่อมต่อ EKS Cluster (สำหรับจัดการ CD & GitOps)
* **Cluster Name:** `Tetris-EKS-Cluster` 
* **Region:** `us-east-1`
* **วิธีเชื่อมต่อ:** สมาชิกทุกคนที่ต้องการจัดการ Cluster ต้องอัปเดตไฟล์ `~/.aws/credentials` ในเครื่องตัวเองให้เป็น Key ปัจจุบันของ AWS Lab Account จากนั้นรันคำสั่ง:
```bash
aws eks update-kubeconfig --region us-east-1 --name Tetris-EKS-Cluster
```
ทดสอบการเชื่อมต่อ:
```bash
kubectl get nodes
```
* **Next Step:** เมื่อตรวจสอบสถานะ Node เป็น Ready สามารถดำเนินการติดตั้ง ArgoCD เพื่อทำ GitOps ต่อไปได้

## Step 8: Clean Up Resources (การลบล้างระบบเพื่อประหยัดเครดิต)

> **Pro Tip:** เมื่อทำงานเสร็จในแต่ละวัน ควรทำลายระบบทิ้งเพื่อป้องกันเครดิต Learner Lab หมด โดยต้องทำลายย้อนลำดับการสร้างเสมอ (ปลายทาง -> ต้นทาง)

1. ทำลาย EKS Cluster ก่อน (สำคัญมาก)
เพื่อให้แน่ใจว่า Load Balancer และ Node ถูกลบเกลี้ยง ให้เข้าไปที่ `Jenkins Dashboard` แล้วแล้วเลือก `eks-deploy-aws` แล้ว `Build with parameters` แล้วเลือก `Terraform-Action` เป็น `destroy` แล้ว กด `build` ได้เลย

2. ทำลาย Jenkins Server
เมื่อ EKS หายไปแล้ว ค่อยถอยกลับมาลบเครื่อง Jenkins:
```bash
cd ../terraform/jenkins-server
terraform destroy -var-file=variables.tfvars --auto-approve
```
3. สิ่งที่ไม่ต้องทำลาย: Bootstrap Backend
ไม่ต้องเข้าไปรัน destroy ในโฟลเดอร์ bootstrap-backend ให้ปล่อย S3 Bucket และ DynamoDB ทิ้งไว้ข้ามวันได้เลย (กินเครดิตน้อยมาก) เพื่อที่จะได้รัน terraform apply สร้างระบบกลับมาได้ทันทีโดยไม่ต้องไปแก้ไฟล์โค้ดใหม่ หรือถ้าอยากทำลาย 
```bash
cd ../terraform/bootstrap-backend
terraform destroy
```
