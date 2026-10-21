Service Desk Application (Mobile & Backend)

ระบบแจ้งซ่อมและบริการงานช่วยเหลือ (Service Desk / Help Desk) แบบครบวงจร ประกอบด้วย Mobile Application พัฒนาด้วย Flutter และระบบหลังบ้าน Node.js REST API ร่วมกับฐานข้อมูล MariaDB / MySQL

ภาพรวมของระบบ

ระบบนี้ถูกออกแบบขึ้นเพื่ออำนวยความสะดวกในการแจ้งปัญหาด้านไอทีและติดตามสถานะงานซ่อม:
- Mobile Frontend : พัฒนาด้วย Flutter รองรับ Android, iOS และ Web
- Backend API: พัฒนาด้วย Express.js (Node.js) มีระบบยืนยันตัวตนด้วย JSON Web Token (JWT)
- Database: จัดเก็บข้อมูลผู้ใช้และรายการ Ticket ด้วย MariaDB/MySQL

---



 1. ระบบยืนยันตัวตน (Authentication & Authorization)
- สมัครสมาชิก (Register) และเข้าสู่ระบบ (Login)
- การแบ่งระดับสิทธิ์ผู้ใช้:
  - User (ผู้ใช้งานทั่วไป): แจ้งปัญหาใหม่, ดูประวัติและติดตามสถานะเคสของตนเอง, แก้ไขรายละเอียดเคสที่ยังไม่ปิด
  - Admin (ผู้ดูแลระบบ): ดูแลและจัดการเคสทั้งหมดในระบบ, อัปเดตสถานะการดำเนินงาน (Open -> In Progress -> Resolved), ลบเคส

 2. แดชบอร์ดสรุปผล (Dashboard)
- แสดงจำนวนเคสสรุปตามสถานะ: Open (เปิดเคส), In Progress (กำลังดำเนินการ), Resolved (แก้ไขแล้ว)
- แสดงรายการเคสล่าสุดพร้อมทางลัดสำหรับการสร้างรายการแจ้งซ่อมใหม่

3. จัดการรายการแจ้งซ่อม (Ticket Management)
- สร้าง Ticket ใหม่:
  - กำหนดหมวดหมู่ Computer, Network, Software, Other
  - เลือกระดับความเร่งด่วน
  - ระบุหัวข้อและรายละเอียดปัญหา
- ค้นหาและกรอง (Search & Filter): ค้นหาคำในหัวข้อเคส และกรองแยกตามสถานะหรือหมวดหมู่
- ดูรายละเอียด Ticket: แสดงข้อมูลวันเวลาที่แจ้ง, ผู้แจ้ง, และไทม์ไลน์สถานะ

โครงสร้างโฟลเดอร์ (Project Structure)

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
