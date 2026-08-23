# CPE 333 Operating Systems (1/2026)

คลังเก็บซอร์สโค้ดและรายงานสำหรับรายวิชา **CPE 333 Operating Systems** ภาควิชาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี (KMUTT)

---

## 📁 โครงสร้างไดเรกทอรี (Directory Structure)

```text
CPE333_OS/
├── .gitignore             # ไฟล์กำหนดรายการที่ไม่ต้องนำเข้า Git
├── README.md              # เอกสารอธิบายภาพรวมของ Repository
└── PS02/                  # Problem Session 2: Process Creation & Pipes
    ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C และ LaTeX
    ├── src/               # ซอร์สโค้ดภาษา C สำหรับการทดลอง
    │   ├── q1_1_helloworld.c  # ข้อ 1.1: fork() แบบไม่มี wait()
    │   └── q1_2_wait.c        # ข้อ 1.2: fork() แบบมี wait()
    ├── docs/              # เอกสารและรายงาน LaTeX
    │   ├── REPORT.tex     # ไฟล์รายงานหลัก (LaTeX Source)
    │   ├── REPORT.pdf     # รายงานฉบับสมบูรณ์ (PDF)
    │   ├── PS02_2026.md   # โจทย์การทดลอง
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    └── result/            # ผลลัพธ์จากการทดลองจริง
        └── q1_verified.txt # ผลการรันตรวจสอบข้อ 1
```

---

## 🛠️ การใช้งานและคำสั่งคอมไพล์

### 1. การคอมไพล์โค้ด C (`PS02/src`)

สามารถคอมไพล์โค้ด C แต่ละไฟล์ได้ด้วย `gcc`:

```bash
cd PS02/src
gcc -Wall -Wextra -o q1_1 q1_1_helloworld.c
gcc -Wall -Wextra -o q1_2 q1_2_wait.c
```

### 2. การคอมไพล์รายงาน LaTeX (`PS02/docs`)

เนื่องจากรายงานใช้ฟอนต์ภาษาไทยผ่านแพ็กเกจ `fontspec` ต้องคอมไพล์ด้วย **`XeLaTeX`**:

```bash
cd PS02/docs
xelatex REPORT.tex
```
*(รันคำสั่ง 2 รอบ เพื่อให้สารบัญและเลขหน้าอัปเดตอย่างถูกต้อง)*

---

## 👥 ผู้จัดทำ (Group Members)

- นายภูมิพัฒน์ อภิวาทธนะพงศ์ (67070501035)
- นายวิรชัช ทองอุทัยศรี (67070501041)
- นายเจษฎา เกียรติกมลวงศ์ (67070501080)
