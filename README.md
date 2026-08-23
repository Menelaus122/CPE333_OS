# CPE 333 Operating Systems (1/2026)

คลังเก็บซอร์สโค้ดและรายงานสำหรับรายวิชา **CPE 333 Operating Systems** ภาควิชาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี (KMUTT)

---

## 📁 โครงสร้างไดเรกทอรี (Directory Structure)

```text
CPE333_OS/
├── .clangd                # การตั้งค่า C/C++ Language Server
├── .gitignore             # รายการไฟล์ที่ไม่นำเข้า Git
├── README.md              # เอกสารอธิบายภาพรวมของ Repository
└── PS02/                  # Problem Session 2: Process Creation & Pipes
    ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C และ LaTeX
    ├── src/               # ซอร์สโค้ดภาษา C สำหรับการทดลอง (ครบทั้ง 5 ข้อ)
    │   ├── q1_1_helloworld.c        # ข้อ 1.1: fork() แบบไม่มี wait()
    │   ├── q1_2_wait.c              # ข้อ 1.2: fork() แบบมี wait()
    │   ├── q2_1_child_first.c       # ข้อ 2.1: Child ตายก่อน (Zombie Process)
    │   ├── q2_2_parent_first.c      # ข้อ 2.2: Parent ตายก่อน (Orphan Process & Reparent)
    │   ├── q3_forkcount.c           # ข้อ 3: หาจำนวน fork() สูงสุด (Recursive chain)
    │   ├── q4_pipe.c                # ข้อ 4: สื่อสารผ่าน pipe() (Child -> Parent)
    │   ├── q5_1_sender_reads_own.c  # ข้อ 5.1: ผู้ส่งลองอ่าน pipe ตนเอง
    │   ├── q5_2_read_before_send.c  # ข้อ 5.2: ผู้รับ read() ก่อนผู้ส่ง write()
    │   └── q5_3_many_messages.c     # ข้อ 5.3: ผู้ส่ง write() หลายข้อความติดกัน
    ├── docs/              # เอกสารและรายงาน LaTeX
    │   ├── PS02.tex       # ไฟล์รายงานหลัก (LaTeX Source)
    │   ├── PS02.pdf       # รายงานฉบับสมบูรณ์ (PDF)
    │   ├── PS02_2026.md   # โจทย์การทดลอง
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    └── result/            # ผลลัพธ์จากการทดลองจริง
        ├── q1_verified.txt # ผลการทดลองข้อ 1
        ├── q2_verified.txt # ผลการทดลองข้อ 2
        ├── q3_verified.txt # ผลการทดลองข้อ 3
        ├── q4_verified.txt # ผลการทดลองข้อ 4
        └── q5_verified.txt # ผลการทดลองข้อ 5
```

---

## 🛠️ การใช้งานและคำสั่งคอมไพล์

### 1. การใช้ Makefile (แนะนำ)

สามารถใช้คำสั่ง `make` ในไดเรกทอรี `PS02/` เพื่อคอมไพล์ทั้งหมดได้โดยอัตโนมัติ:

```bash
cd PS02

# คอมไพล์โปรแกรมภาษา C ทั้งหมดใน src/
make build

# คอมไพล์รายงาน LaTeX เป็น PDF
make pdf

# ล้างไฟล์คอมไพล์ชั่วคราว
make clean
```

---

### 2. การคอมไพล์โปรแกรม C ด้วยตนเอง (`PS02/src`)

```bash
cd PS02/src

# ข้อ 1: fork() & wait()
gcc -Wall -Wextra -o q1_1 q1_1_helloworld.c
gcc -Wall -Wextra -o q1_2 q1_2_wait.c

# ข้อ 2: Zombie & Orphan
gcc -Wall -Wextra -o q2_1 q2_1_child_first.c
gcc -Wall -Wextra -o q2_2 q2_2_parent_first.c

# ข้อ 3: Fork Limit (รันผ่าน ulimit -u เพื่อความปลอดภัย)
gcc -Wall -Wextra -o q3_forkcount q3_forkcount.c
ulimit -u 300 && ./q3_forkcount

# ข้อ 4: Pipe Communication
gcc -Wall -Wextra -o q4_pipe q4_pipe.c

# ข้อ 5: Pipe Edge Cases
gcc -Wall -Wextra -o q5_1 q5_1_sender_reads_own.c
gcc -Wall -Wextra -o q5_2 q5_2_read_before_send.c
gcc -Wall -Wextra -o q5_3 q5_3_many_messages.c
```

---

### 3. การคอมไพล์รายงาน LaTeX (`PS02/docs`)

เนื่องจากรายงานใช้ฟอนต์ภาษาไทยผ่านแพ็กเกจ `fontspec` ต้องคอมไพล์ด้วย **`XeLaTeX`**:

```bash
cd PS02/docs
xelatex PS02.tex
xelatex PS02.tex
```
*(รันคำสั่ง 2 รอบ เพื่อให้สารบัญและเลขหน้าอัปเดตอย่างถูกต้อง)*

---

## 👥 ผู้จัดทำ (Group Members)

- นายภูมิพัฒน์ อภิวาทธนะพงศ์ (67070501035)
- นายวิรชัช ทองอุทัยศรี (67070501041)
- นายเจษฎา เกียรติกมลวงศ์ (67070501080)
