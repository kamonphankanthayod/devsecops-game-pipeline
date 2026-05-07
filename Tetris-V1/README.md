# React Tetris V1

Tetris game built with React

<h1 align="center">
  <img alt="React tetris " title="#React tetris desktop" src="./images/game.jpg" />
</h1>


## วิธีการรันบน Local (Local Development)

### 1. ความต้องการของระบบ
* **Node.js**: เวอร์ชัน 16, 18 หรือ 20
* **npm**: เวอร์ชัน 8 ขึ้นไป

### 2. ขั้นตอนการติดตั้ง
เปิด Terminal ในโฟลเดอร์ `Tetris-V1` แล้วรันคำสั่ง:

```bash
# ติดตั้ง dependencies
npm install
```

### 3. การเริ่มรันเกม
```bash
# สำหรับ Node.js v17+ (แก้ปัญหา OpenSSL)
export NODE_OPTIONS=--openssl-legacy-provider
```

```bash
# เริ่มรันโหมด Development
npm start
```

จากนั้นเปิด Browser ไปที่ http://localhost:3000