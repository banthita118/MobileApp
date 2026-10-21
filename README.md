# 📱 Service Desk Application (Mobile & Backend)

ระบบแจ้งซ่อมและบริการงานช่วยเหลือ (Service Desk / Help Desk) แบบครบวงจร ประกอบด้วย Mobile Application ที่พัฒนาด้วย **Flutter** และระบบหลังบ้าน **Node.js REST API** ร่วมกับฐานข้อมูล **MariaDB / MySQL**

---

## 📑 สารบัญ
- [ภาพรวมของระบบ](#-ภาพรวมของระบบ)
- [ฟีเจอร์เด่น (Key Features)](#-ฟีเจอร์เด่น-key-features)
- [โครงสร้างโฟลเดอร์ (Project Structure)](#-โครงสร้างโฟลเดอร์-project-structure)
- [ข้อกำหนดเบื้องต้น (Prerequisites)](#-ข้อกำหนดเบื้องต้น-prerequisites)
- [วิธีติดตั้งและเริ่มต้นใช้งาน (Getting Started)](#-วิธีติดตั้งและเริ่มต้นใช้งาน-getting-started)
  - [1. การติดตั้งฐานข้อมูล (Database)](#1-การติดตั้งฐานข้อมูล-database)
  - [2. การรัน Backend API](#2-การรัน-backend-api)
  - [3. การรัน Mobile App (Flutter)](#3-การรัน-mobile-app-flutter)
- [เอกสาร API (API Reference)](#-เอกสาร-api-api-reference)
- [การตั้งค่า Environment Variables](#-การตั้งค่า-environment-variables)

---

## 🌟 ภาพรวมของระบบ

ระบบนี้ถูกออกแบบขึ้นเพื่ออำนวยความสะดวกในการแจ้งปัญหาด้านไอทีและติดตามสถานะงานซ่อม:
- **Mobile Frontend**: พัฒนาด้วย Flutter รองรับ Android, iOS และ Web พร้อม UI ที่ทันสมัย ใช้งานง่าย
- **Backend API**: พัฒนาด้วย Express.js (Node.js) มีระบบยืนยันตัวตนด้วย JSON Web Token (JWT)
- **Database**: จัดเก็บข้อมูลผู้ใช้และรายการ Ticket ด้วย MariaDB/MySQL

---

## ✨ ฟีเจอร์เด่น (Key Features)

### 🔐 1. ระบบยืนยันตัวตน (Authentication & Authorization)
- สมัครสมาชิก (Register) และเข้าสู่ระบบ (Login)
- การแบ่งระดับสิทธิ์ผู้ใช้:
  - **User (ผู้ใช้งานทั่วไป)**: แจ้งปัญหาใหม่, ดูประวัติและติดตามสถานะเคสของตนเอง, แก้ไขรายละเอียดเคสที่ยังไม่ปิด
  - **Admin (ผู้ดูแลระบบ)**: ดูแลและจัดการเคสทั้งหมดในระบบ, อัปเดตสถานะการดำเนินงาน (Open -> In Progress -> Resolved), ลบเคส

### 📊 2. แดชบอร์ดสรุปผล (Dashboard)
- แสดงจำนวนเคสสรุปตามสถานะ: **Open (เปิดเคส)**, **In Progress (กำลังดำเนินการ)**, **Resolved (แก้ไขแล้ว)**
- แสดงรายการเคสล่าสุดพร้อมทางลัดสำหรับการสร้างรายการแจ้งซ่อมใหม่

### 📝 3. จัดการรายการแจ้งซ่อม (Ticket Management)
- **สร้าง Ticket ใหม่**:
  - กำหนดหมวดหมู่: Computer, Network, Software, Other
  - เลือกระดับความเร่งด่วน: Low, Medium, High, Urgent
  - ระบุหัวข้อและรายละเอียดปัญหา
- **ค้นหาและกรอง (Search & Filter)**: ค้นหาคำในหัวข้อเคส และกรองแยกตามสถานะหรือหมวดหมู่
- **ดูรายละเอียด Ticket**: แสดงข้อมูลวันเวลาที่แจ้ง, ผู้แจ้ง, และไทม์ไลน์สถานะ

---

## 📁 โครงสร้างโฟลเดอร์ (Project Structure)

```plaintext
MobileApp/
├── backend/                  # ระบบหลังบ้าน Node.js + Express
│   ├── auth.js               # Middleware ตรวจสอบ JWT Authentication
│   ├── db.js                 # การเชื่อมต่อฐานข้อมูล MariaDB Pool
│   └── server.js             # API Routes & Controller หลัก
├── database/                 # สคริปต์ฐานข้อมูล
│   └── schema.sql            # ตาราง users, tickets
├── my_app/                   # แอปพลิเคชัน Flutter
│   ├── lib/
│   │   ├── models/           # ข้อมูล User และ Ticket Data Model
│   │   ├── screens/          # หน้าจอแอป (Login, Dashboard, Tickets, Profile)
│   │   ├── services/         # ApiService สำหรับติดต่อ Backend
│   │   ├── theme/            # ธีม สี และสไตล์ของแอป
│   │   ├── widgets/          # Component สำหรับนำกลับมาใช้ซ้ำ (TicketCard ฯลฯ)
│   │   └── main.dart         # จุดเริ่มต้นของแอปพลิเคชัน
│   └── pubspec.yaml          # การตั้งค่า dependencies ของ Flutter
├── .env.example              # ตัวอย่างการตั้งค่า Environment Variables
├── .gitignore                # การละเว้นไฟล์ที่ไม่ต้องการนำขึ้น Git
├── package.json              # การตั้งค่า dependencies ของ Node.js
└── README.md                 # เอกสารแนะนำโปรเจกต์
```

---

## 🛠 ข้อกำหนดเบื้องต้น (Prerequisites)

ก่อนเริ่มรันโปรเจกต์ กรุณาตรวจสอบว่ามีเครื่องมือต่อไปนี้ติดตั้งอยู่ในเครื่อง:
- [Node.js](https://nodejs.org/) (เวอร์ชัน 18 ขึ้นไป)
- [MySQL](https://www.mysql.com/) หรือ [MariaDB](https://mariadb.org/) (สามารถใช้ผ่าน [XAMPP](https://www.apachefriends.org/))
- [Flutter SDK](https://flutter.dev/) (เวอร์ชัน 3.13 ขึ้นไป)

---

## 🚀 วิธีติดตั้งและเริ่มต้นใช้งาน (Getting Started)

### 1. การติดตั้งฐานข้อมูล (Database)
1. เปิดโปรแกรมจำลอง MySQL (เช่น XAMPP Control Panel แล้วกด Start โมดูล **MySQL**)
2. เข้าไปที่ phpMyAdmin (`http://localhost/phpmyadmin`) หรือผ่าน MySQL CLI
3. นำเข้าไฟล์ [schema.sql](file:///d:/MobileApp/database/schema.sql) หรือรันคำสั่ง:
   ```sql
   CREATE DATABASE IF NOT EXISTS service_desk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE service_desk;
   -- รันคำสั่งสร้างตาราง users และ tickets จาก database/schema.sql
   ```

### 2. การรัน Backend API
1. เปิด Terminal ในโฟลเดอร์โปรเจกต์หลัก (`MobileApp`)
2. ติดตั้ง Dependencies:
   ```bash
   npm install
   ```
3. คัดลอกไฟล์ `.env.example` เป็น `.env` และแก้ไขค่าตามเครื่องของคุณ:
   ```bash
   cp .env.example .env
   ```
4. เริ่มต้นเซิร์ฟเวอร์ Backend:
   ```bash
   # โหมดพัฒนา (Watch mode)
   npm run dev

   # หรือรันปกติ
   npm start
   ```
   *เซิร์ฟเวอร์จะทำงานที่: `http://localhost:3000`*

### 3. การรัน Mobile App (Flutter)
1. สลับเข้าไปที่โฟลเดอร์ `my_app`:
   ```bash
   cd my_app
   ```
2. ดาวน์โหลดแพ็กเกจของ Flutter:
   ```bash
   flutter pub get
   ```
3. **การตั้งค่า IP สำหรับเชื่อมต่อ Backend**:
   - หากทดสอบบน **เครื่องคอมพิวเตอร์ (Chrome / Windows Desktop)**: ใช้ `http://localhost:3000/api` ได้ทันที
   - หากทดสอบบน **มือถือจริงผ่าน Wi-Fi**: ตรวจสอบหมายเลข IPv4 ของเครื่องคอมพิวเตอร์ และตั้งค่า `_baseUrl` ใน `lib/services/api_service.dart` ให้ตรงกับ IP ของเครื่องเซิร์ฟเวอร์ (เช่น `http://192.168.1.xxx:3000/api`)
4. สั่งรันแอปพลิเคชัน:
   ```bash
   flutter run
   ```

---

## 📡 เอกสาร API (API Reference)

### Authentication
| Method | Endpoint | สิทธิ์ | รายละเอียด |
|---|---|---|---|
| `POST` | `/api/auth/register` | Public | ลงทะเบียนสมาชิกใหม่ |
| `POST` | `/api/auth/login` | Public | เข้าสู่ระบบและรับ JWT Token |
| `GET` | `/api/auth/me` | User / Admin | ดึงข้อมูลโปรไฟล์ของผู้ใช้งานปัจจุบัน |

### Tickets
| Method | Endpoint | สิทธิ์ | รายละเอียด |
|---|---|---|---|
| `GET` | `/api/tickets` | User / Admin | ดึงรายการเคส (User เห็นเฉพาะของตน, Admin เห็นทั้งหมด) |
| `POST` | `/api/tickets` | User / Admin | สร้างรายการแจ้งซ่อมใหม่ |
| `PUT` | `/api/tickets/:id` | User / Admin | อัปเดตข้อมูลเคส (Admin สามารถปรับเปลี่ยนสถานะได้) |
| `DELETE` | `/api/tickets/:id` | Admin Only | ลบรายการเคสออกจากระบบ |

---

## ⚙️ การตั้งค่า Environment Variables

ค่าตัวแปรในไฟล์ `.env`:
```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=service_desk
JWT_SECRET=your_jwt_secret_here
FRONTEND_URL=http://127.0.0.1:5500
```