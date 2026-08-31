# CPE 333 Operating Systems (1/2026)

คลังเก็บซอร์สโค้ดและรายงานสำหรับรายวิชา **CPE 333 Operating Systems** ภาควิชาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี (KMUTT)

| Problem Session | หัวข้อ | ข้อที่ทำ | รายงาน |
| --- | --- | --- | --- |
| **PS02** | Process Creation & Pipes | 1--5 | [`PS02/docs/PS02.pdf`](PS02/docs/PS02.pdf) |
| **PS03** | Process Manipulation and Monitoring | 1, 2, 5 | [`PS03/docs/PS03.pdf`](PS03/docs/PS03.pdf) |

---

## 📁 โครงสร้างไดเรกทอรี (Directory Structure)

```text
CPE333_OS/
├── .clangd                # การตั้งค่า C/C++ Language Server
├── .gitattributes         # บังคับให้ไฟล์ .sh และ Makefile เป็น LF (ต้องรันบน Linux/WSL)
├── .gitignore             # รายการไฟล์ที่ไม่นำเข้า Git
├── README.md              # เอกสารอธิบายภาพรวมของ Repository
├── PS02/                  # Problem Session 2: Process Creation & Pipes
│   ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C และ LaTeX
│   ├── src/               # ซอร์สโค้ดภาษา C สำหรับการทดลอง (ครบทั้ง 5 ข้อ)
│   │   ├── q1_1_helloworld.c        # ข้อ 1.1: fork() แบบไม่มี wait()
│   │   ├── q1_2_wait.c              # ข้อ 1.2: fork() แบบมี wait()
│   │   ├── q2_1_child_first.c       # ข้อ 2.1: Child ตายก่อน (Zombie Process)
│   │   ├── q2_2_parent_first.c      # ข้อ 2.2: Parent ตายก่อน (Orphan Process & Reparent)
│   │   ├── q3_forkcount.c           # ข้อ 3: หาจำนวน fork() สูงสุด (Recursive chain)
│   │   ├── q4_pipe.c                # ข้อ 4: สื่อสารผ่าน pipe() (Child -> Parent)
│   │   ├── q5_1_sender_reads_own.c  # ข้อ 5.1: ผู้ส่งลองอ่าน pipe ตนเอง
│   │   ├── q5_2_read_before_send.c  # ข้อ 5.2: ผู้รับ read() ก่อนผู้ส่ง write()
│   │   └── q5_3_many_messages.c     # ข้อ 5.3: ผู้ส่ง write() หลายข้อความติดกัน
│   ├── docs/              # เอกสารและรายงาน LaTeX
│   │   ├── PS02.tex       # ไฟล์รายงานหลัก (LaTeX Source)
│   │   ├── PS02.pdf       # รายงานฉบับสมบูรณ์ (PDF)
│   │   ├── PS02_2026.md   # โจทย์การทดลอง
│   │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
│   └── result/            # ผลลัพธ์จากการทดลองจริง
│       ├── q1_verified.txt # ผลการทดลองข้อ 1
│       ├── q2_verified.txt # ผลการทดลองข้อ 2
│       ├── q3_verified.txt # ผลการทดลองข้อ 3
│       ├── q4_verified.txt # ผลการทดลองข้อ 4
│       └── q5_verified.txt # ผลการทดลองข้อ 5
└── PS03/                  # Problem Session 3: Process Manipulation and Monitoring
    ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C, LaTeX และเก็บผลการทดลองซ้ำ
    ├── src/               # ซอร์สโค้ดและสคริปต์ของการทดลอง (ข้อ 1, 2, 5)
    │   ├── q1_burn.c      # ข้อ 1: CPU burner ใช้วัดผลของค่า nice เป็นตัวเลข
    │   ├── q1_sigdemo.c   # ข้อ 1: process ที่ดักจับ SIGTERM/SIGINT เพื่อแสดงว่าทำไมต้องมี SIGKILL
    │   ├── ss1_1.sh       # ข้อ 2: สคริปต์ sleep รวม 10 วินาที (เทียบ foreground กับ background)
    │   ├── ss1_2.sh       # ข้อ 2: สคริปต์ sleep 1000 วินาที (ใช้ทดลอง CTRL+Z, fg, bg)
    │   ├── PS3.c          # ข้อ 5: STCF (Shortest Time-to-Completion First) scheduler
    │   ├── run_q1.sh      # สคริปต์เก็บผลการทดลองข้อ 1 (ps/top, nice/renice, kill)
    │   ├── run_q2.sh      # สคริปต์เก็บผลการทดลองข้อ 2 (ใช้ pseudo terminal เพื่อให้กด CTRL+Z ได้)
    │   └── run_q5.sh      # สคริปต์เก็บผลการทดลองข้อ 5 (รันทั้งสามเคสและ diff กับเฉลย)
    ├── material/          # ไฟล์ตั้งต้นที่โจทย์ให้มา (ไม่ได้แก้ไข)
    │   ├── PS3.c          # โครงโปรแกรมก่อนเติมฟังก์ชัน scheduler
    │   ├── case1.csv      # ข้อมูลทดสอบชุดที่ 1
    │   ├── case2.csv      # ข้อมูลทดสอบชุดที่ 2 (มีช่วง IDLE)
    │   └── case3.csv      # ข้อมูลทดสอบชุดที่ 3 (pid ในไฟล์ไม่เรียงลำดับ)
    ├── docs/              # เอกสารและรายงาน LaTeX
    │   ├── PS03.tex       # ไฟล์รายงานหลัก (LaTeX Source)
    │   ├── PS03.pdf       # รายงานฉบับสมบูรณ์ (เนื้อหา 15 หน้า ไม่รวมปกและสารบัญ)
    │   ├── PS03_2026.md   # โจทย์การทดลอง
    │   ├── q5_result_screenshot.png # screenshot ผลการรัน scheduler ตามที่โจทย์ข้อ 5 กำหนด
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    └── result/            # ผลลัพธ์จากการทดลองจริง (ทุกบรรทัดที่อ้างในรายงานมาจากที่นี่)
        ├── q1_verified.txt # ผลการทดลองข้อ 1
        ├── q2_verified.txt # ผลการทดลองข้อ 2 (transcript จาก terminal จริง)
        └── q5_verified.txt # ผลการทดลองข้อ 5
```

---

## 🛠️ การใช้งานและคำสั่งคอมไพล์

### 1. การใช้ Makefile (แนะนำ)

ทั้ง `PS02/` และ `PS03/` มี `Makefile` ของตัวเอง ใช้คำสั่งเดียวกันได้:

```bash
cd PS02        # หรือ cd PS03

# คอมไพล์โปรแกรมภาษา C ทั้งหมดใน src/
make build

# คอมไพล์รายงาน LaTeX เป็น PDF
make pdf

# ล้างไฟล์คอมไพล์ชั่วคราว
make clean
```

เฉพาะ `PS03/` มีเป้าหมายเพิ่มสำหรับ **เก็บผลการทดลองใหม่ทั้งหมด** (ใช้เวลาประมาณ 3 นาที และต้องรันบน Linux หรือ WSL):

```bash
cd PS03

make result        # เก็บผลใหม่ทั้งสามข้อ ทับไฟล์ใน result/
make result-q1     # เก็บเฉพาะข้อ 1
make result-q2     # เก็บเฉพาะข้อ 2
make result-q5     # เก็บเฉพาะข้อ 5
```

---

### 2. การคอมไพล์โปรแกรม C ด้วยตนเอง

**PS02 (`PS02/src`)**

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

**PS03 (`PS03/src`)**

```bash
cd PS03/src

# ข้อ 1: เครื่องมือสำหรับทดลอง nice และ signal
gcc -Wall -Wextra -O0 -o q1_burn q1_burn.c     # ต้องใช้ -O0 ไม่งั้นคอมไพเลอร์จะตัดลูปคำนวณทิ้ง
gcc -Wall -Wextra -o q1_sigdemo q1_sigdemo.c

# ข้อ 2: สคริปต์เชลล์ ต้องเพิ่มสิทธิ์ให้รันได้ก่อน
chmod +x ss1_1.sh ss1_2.sh
./ss1_1.sh          # รันแบบ foreground
./ss1_1.sh &        # รันแบบ background
./ss1_2.sh          # แล้วกด CTRL+Z จากนั้นลอง jobs / fg / bg

# ข้อ 5: STCF scheduler (ไฟล์ .csv ต้องอยู่โฟลเดอร์เดียวกับไฟล์ที่รันได้)
gcc -Wall -Wextra -o PS3 PS3.c
cp ../material/case*.csv .
./PS3 case1.csv
./PS3 case2.csv
./PS3 case3.csv
```

---

### 3. การคอมไพล์รายงาน LaTeX

เนื่องจากรายงานใช้ฟอนต์ภาษาไทยผ่านแพ็กเกจ `fontspec` ต้องคอมไพล์ด้วย **`XeLaTeX`**:

```bash
cd PS02/docs && xelatex PS02.tex && xelatex PS02.tex
cd PS03/docs && xelatex PS03.tex && xelatex PS03.tex
```
*(รันคำสั่ง 2 รอบ เพื่อให้สารบัญและเลขหน้าอัปเดตอย่างถูกต้อง)*

ค่าตั้งต้นใช้ฟอนต์ **TH Sarabun New** ถ้าคอมไพล์บน Overleaf หรือเครื่องที่ไม่มีฟอนต์นี้ ให้สลับไปใช้ตัวเลือก (B) ที่คอมเมนต์ไว้ในส่วนหัวของไฟล์ `.tex` ซึ่งใช้ `Noto Serif Thai` แทน

---

## 🧪 สภาพแวดล้อมที่ใช้ทดลอง

การทดลองทั้งหมดรันบน **Ubuntu 24.04.1 LTS (WSL2 บน Windows 11)** kernel `6.6.87.2-microsoft-standard-WSL2` คอมไพเลอร์ `gcc 13.3.0` และ shell `GNU bash 5.2.21`

ข้อควรทราบสำหรับ PS03:

- **ข้อ 1** เครื่องที่ใช้มี 22 CPU ถ้าปล่อยให้โปรแกรมทดสอบวิ่งอิสระจะไม่เห็นผลของค่า `nice` เลย เพราะไม่มีการแย่ง CPU เกิดขึ้นจริง สคริปต์เก็บผลจึงใช้ `taskset -c 0` บังคับให้ทุก process ทดสอบอยู่บน CPU แกนเดียวกัน
- **ข้อ 2** คำสั่ง `jobs`, `fg`, `bg` และการกด `CTRL+Z` ใช้ได้เฉพาะ shell แบบ interactive ที่มี tty จริง สคริปต์ `run_q2.sh` จึงใช้ `script(1)` สร้าง pseudo terminal ขึ้นมาก่อน
- สคริปต์ใน `src/` ทุกไฟล์ต้องมี line ending เป็น LF ซึ่งบังคับไว้แล้วใน `.gitattributes`

---

## 👥 ผู้จัดทำ (Group Members)

- นายภูมิพัฒน์ อภิวาทธนะพงศ์ (67070501035)
- นายวิรชัช ทองอุทัยศรี (67070501041)
- นายเจษฎา เกียรติกมลวงศ์ (67070501080)
