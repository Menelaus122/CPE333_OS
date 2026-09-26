# CPE 333 Operating Systems (1/2026)

คลังเก็บซอร์สโค้ดและรายงานสำหรับรายวิชา **CPE 333 Operating Systems** ภาควิชาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี (KMUTT)

| Problem Session | หัวข้อ | ข้อที่ทำ | รายงาน |
| --- | --- | --- | --- |
| **PS02** | Process Creation & Pipes | 1--5 | [`PS02/docs/PS02.pdf`](PS02/docs/PS02.pdf) |
| **PS03** | Process Manipulation and Monitoring | 1, 2, 5 | [`PS03/docs/PS03.pdf`](PS03/docs/PS03.pdf) |
| **PS04** | Memory class and API in C programming | 1--3 | [`PS04/docs/PS04.pdf`](PS04/docs/PS04.pdf) |
| **Mini-Project 1** | Compile และติดตั้ง Ubuntu kernel ใหม่ | – | [`Miniproj1/docs/MiniProject1_Report.docx`](Miniproj1/docs/MiniProject1_Report.docx) |
| **PS06** | Virtual Memory | 1–3 | [`PS06/docs/PS06.pdf`](PS06/docs/PS06.pdf) · [`PS06_Report.docx`](PS06/docs/PS06_Report.docx) |
| **PS07** | Concurrency and Thread (race condition) | Task 1–3 | [`PS07/docs/PS07.pdf`](PS07/docs/PS07.pdf) · [`PS07_Report.docx`](PS07/docs/PS07_Report.docx) |

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
├── PS03/                  # Problem Session 3: Process Manipulation and Monitoring
│   ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C, LaTeX และเก็บผลการทดลองซ้ำ
│   ├── src/               # ซอร์สโค้ดและสคริปต์ของการทดลอง (ข้อ 1, 2, 5)
│   │   ├── q1_burn.c      # ข้อ 1: CPU burner ใช้วัดผลของค่า nice เป็นตัวเลข
│   │   ├── q1_sigdemo.c   # ข้อ 1: process ที่ดักจับ SIGTERM/SIGINT เพื่อแสดงว่าทำไมต้องมี SIGKILL
│   │   ├── ss1_1.sh       # ข้อ 2: สคริปต์ sleep รวม 10 วินาที (เทียบ foreground กับ background)
│   │   ├── ss1_2.sh       # ข้อ 2: สคริปต์ sleep 1000 วินาที (ใช้ทดลอง CTRL+Z, fg, bg)
│   │   ├── PS3.c          # ข้อ 5: STCF (Shortest Time-to-Completion First) scheduler
│   │   ├── run_q1.sh      # สคริปต์เก็บผลการทดลองข้อ 1 (ps/top, nice/renice, kill)
│   │   ├── run_q2.sh      # สคริปต์เก็บผลการทดลองข้อ 2 (ใช้ pseudo terminal เพื่อให้กด CTRL+Z ได้)
│   │   └── run_q5.sh      # สคริปต์เก็บผลการทดลองข้อ 5 (รันทั้งสามเคสและ diff กับเฉลย)
│   ├── material/          # ไฟล์ตั้งต้นที่โจทย์ให้มา (ไม่ได้แก้ไข)
│   │   ├── PS3.c          # โครงโปรแกรมก่อนเติมฟังก์ชัน scheduler
│   │   ├── case1.csv      # ข้อมูลทดสอบชุดที่ 1
│   │   ├── case2.csv      # ข้อมูลทดสอบชุดที่ 2 (มีช่วง IDLE)
│   │   └── case3.csv      # ข้อมูลทดสอบชุดที่ 3 (pid ในไฟล์ไม่เรียงลำดับ)
│   ├── docs/              # เอกสารและรายงาน LaTeX
│   │   ├── PS03.tex       # ไฟล์รายงานหลัก (LaTeX Source)
│   │   ├── PS03.pdf       # รายงานฉบับสมบูรณ์ (เนื้อหา 15 หน้า ไม่รวมปกและสารบัญ)
│   │   ├── PS03_2026.md   # โจทย์การทดลอง
│   │   ├── q5_result_screenshot.png # screenshot ผลการรัน scheduler ตามที่โจทย์ข้อ 5 กำหนด
│   │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
│   └── result/            # ผลลัพธ์จากการทดลองจริง (ทุกบรรทัดที่อ้างในรายงานมาจากที่นี่)
│       ├── q1_verified.txt # ผลการทดลองข้อ 1
│       ├── q2_verified.txt # ผลการทดลองข้อ 2 (transcript จาก terminal จริง)
│       └── q5_verified.txt # ผลการทดลองข้อ 5
├── PS04/                  # Problem Session 4: Memory class and API in C programming
│   ├── Makefile           # คำสั่งอัตโนมัติสำหรับคอมไพล์ C, LaTeX และเก็บผลการทดลองซ้ำ
│   ├── src/               # ซอร์สโค้ดและสคริปต์ของการทดลอง (ข้อ 1--3)
│   │   ├── q1_static.c        # ข้อ 1: โค้ดตามใบงาน มี static ในลูป while
│   │   ├── q1_auto.c          # ข้อ 1: โค้ดเดิมที่ลบคำว่า static ออก (Step 2)
│   │   ├── q2_extern.c        # ข้อ 2: โค้ดตามใบงาน มี extern ทั้งใน main() และ display()
│   │   ├── q2_noextern.c      # ข้อ 2: โค้ดเดิมที่ลบคำว่า extern ใน main() ออก (Step 2)
│   │   ├── q2_shared_main.c   # ข้อ 2: ตัวอย่างการใช้ extern จริง ฝั่งที่ประกาศตัวแปร
│   │   ├── q2_shared_def.c    # ข้อ 2: ตัวอย่างการใช้ extern จริง ฝั่งที่นิยามตัวแปร
│   │   ├── q3_alloc.c         # ข้อ 3: โค้ดตามใบงาน ยังคอมเมนต์ส่วนของ b ไว้
│   │   ├── q3_alloc_b.c       # ข้อ 3: โค้ดเดิมที่เปิดคอมเมนต์ malloc(b) และ free(b) (Step 4)
│   │   ├── q3_regions.c       # ข้อ 3: โปรแกรมตรวจสอบ อ่าน /proc/self/maps ของตัวเอง
│   │   ├── run_q1.sh          # สคริปต์เก็บผลข้อ 1 (คอมไพล์ทั้งแบบ PIE และ -no-pie)
│   │   ├── run_q2.sh          # สคริปต์เก็บผลข้อ 2 (รวม nm/readelf และการทดสอบ linker)
│   │   └── run_q3.sh          # สคริปต์เก็บผลข้อ 3 (malloc / realloc / free)
│   ├── docs/              # เอกสารและรายงาน LaTeX
│   │   ├── PS04.tex       # ไฟล์รายงานหลัก (LaTeX Source)
│   │   ├── PS04.pdf       # รายงานฉบับสมบูรณ์ (เนื้อหา 13 หน้า รวมปกและสารบัญ)
│   │   ├── PS4_2026_OS.md # โจทย์การทดลอง
│   │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
│   └── result/            # ผลลัพธ์จากการทดลองจริง (ทุกบรรทัดที่อ้างในรายงานมาจากที่นี่)
│       ├── q1_verified.txt # ผลการทดลองข้อ 1 (Static Storage Class)
│       ├── q2_verified.txt # ผลการทดลองข้อ 2 (Extern Storage Class)
│       └── q3_verified.txt # ผลการทดลองข้อ 3 (malloc / realloc / free)
├── Miniproj1/             # Mini-Project 1: Compile และติดตั้ง Ubuntu kernel ใหม่ (ทำใน VMware Virtual Machine)
    ├── docs/
    │   ├── MiniProject1_Report.docx # รายงานฉบับสมบูรณ์ (Word) ผลลัพธ์ทุกขั้นเป็นภาพหน้าจอจริง
    │   ├── COMMANDS.md              # คำสั่งที่ใช้ใน Virtual Machine ตามลำดับ และรายการภาพหลักฐาน
    │   ├── MiniProject1_2026.md     # โจทย์ Mini-Project
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    └── result/
        └── screenshots/     # ภาพหน้าจอจาก Virtual Machine ที่ใช้ในรายงาน (s01–s19)
├── PS06/                  # Problem Session 6: Virtual Memory (หลักฐานเป็นภาพหน้าจอทั้งหมด)
    ├── Makefile           # คำสั่งสร้างรายงาน PDF และ .docx
    ├── docs/
    │   ├── PS06.tex       # ไฟล์รายงานหลัก (LaTeX Source) เป็นต้นทางของทั้ง PDF และ .docx
    │   ├── PS06.pdf       # รายงานฉบับสมบูรณ์ (PDF) 22 หน้า
    │   ├── PS06_Report.docx # รายงานฉบับ Word สร้างจาก PS06.tex ไฟล์เดียวกัน
    │   ├── COMMANDS.md    # คำสั่งที่พิมพ์ใน terminal ตามลำดับ และรายการภาพหลักฐาน s01–s21
    │   ├── PS06_2026.md   # โจทย์การทดลอง
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    ├── tools/             # เครื่องมือช่วยทำรายงาน (ไม่ใช่ส่วนหนึ่งของคำตอบ)
    │   ├── build_report.js  # อ่าน PS06.tex แล้วสร้าง PS06_Report.docx
    │   ├── crop_shot.ps1    # ตัดพื้นที่ว่างท้ายภาพหน้าจอ terminal ออกอัตโนมัติ
    │   └── crop_region.ps1  # ตัดภาพตามพิกัด ใช้กับหน้าต่างที่ตัดอัตโนมัติไม่ได้
    └── result/
        ├── notes.txt      # ปัญหาและข้อสังเกตที่พบระหว่างทดลอง
        └── screenshots/   # ภาพหน้าจอหลักฐานทั้งหมด (s01–s21)
└── PS07/                  # Problem Session 7: Concurrency and Thread (race condition บนบัญชีเงินฝากร่วม)
    ├── Makefile           # คอมไพล์ ps7 ตามคำสั่งในใบงาน และสร้างรายงาน PDF / .docx
    ├── src/
    │   └── ps7.c          # บัญชีเงินฝากร่วมที่ ATM หลาย thread ฝาก/ถอนพร้อมกันโดยไม่มี lock (มีโหมด yield สำหรับ Task 3)
    ├── docs/
    │   ├── PS07.tex       # ไฟล์รายงานหลัก (LaTeX Source) เป็นต้นทางของทั้ง PDF และ .docx
    │   ├── PS07.pdf       # รายงานฉบับสมบูรณ์ (PDF) 9 หน้า รวมปก สารบัญ และภาคผนวกซอร์สโค้ด
    │   ├── PS07_Report.docx # รายงานฉบับ Word สร้างจาก PS07.tex ไฟล์เดียวกัน
    │   ├── COMMANDS.md    # คำสั่งที่พิมพ์ใน terminal ตามลำดับ และรายการภาพหลักฐาน t01–t07
    │   ├── problem_session_7_concurrency_and_thread.md # โจทย์การทดลอง
    │   └── KMUTT_CI_Primary_Logo-Full-1200x1200.png # โลโก้ มจธ.
    ├── tools/
    │   └── build_report.js  # อ่าน PS07.tex แล้วสร้าง PS07_Report.docx (ต่อยอดจากของ PS06)
    └── result/
        ├── notes.txt      # การเลือกจำนวนรายการต่อ thread และข้อสังเกตก่อนถ่ายภาพ
        └── screenshots/   # ภาพหน้าจอหลักฐานทั้งหมด (t01–t07)
```

---

## 🛠️ การใช้งานและคำสั่งคอมไพล์

### 1. การใช้ Makefile (แนะนำ)

ทั้ง `PS02/`, `PS03/`, `PS04/` และ `PS07/` มี `Makefile` ของตัวเอง ใช้คำสั่งเดียวกันได้ (`PS07/` มี `make docx` เพิ่มสำหรับฉบับ Word):

```bash
cd PS02        # หรือ cd PS03 / cd PS04

# คอมไพล์โปรแกรมภาษา C ทั้งหมดใน src/
make build

# คอมไพล์รายงาน LaTeX เป็น PDF
make pdf

# ล้างไฟล์คอมไพล์ชั่วคราว
make clean
```

`PS03/` และ `PS04/` มีเป้าหมายเพิ่มสำหรับ **เก็บผลการทดลองใหม่ทั้งหมด** (ต้องรันบน Linux หรือ WSL):

```bash
cd PS03                    # ใช้เวลาประมาณ 3 นาที

make result        # เก็บผลใหม่ทั้งสามข้อ ทับไฟล์ใน result/
make result-q1     # เก็บเฉพาะข้อ 1
make result-q2     # เก็บเฉพาะข้อ 2
make result-q5     # เก็บเฉพาะข้อ 5
```

```bash
cd PS04                    # ใช้เวลาไม่ถึงนาที

make result        # เก็บผลใหม่ทั้งสามข้อ ทับไฟล์ใน result/
make result-q1     # เก็บเฉพาะข้อ 1
make result-q2     # เก็บเฉพาะข้อ 2
make result-q3     # เก็บเฉพาะข้อ 3
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

**PS04 (`PS04/src`)**

โจทย์ PS04 กำหนดให้คอมไพล์โปรแกรมชุดเดียวกันสองแบบ คือแบบปกติ (เป็น PIE โดยปริยาย) และแบบ `-no-pie` เพื่อเทียบว่าที่อยู่ของตัวแปรเปลี่ยนไปอย่างไร

```bash
cd PS04/src

# ข้อ 1: Static Storage Class (Step 1--3 แบบปกติ, Step 4 แบบ -no-pie)
gcc -Wall -Wextra -o q1_static q1_static.c
gcc -Wall -Wextra -o q1_auto   q1_auto.c
gcc -Wall -Wextra -no-pie -o q1_static_nopie q1_static.c
gcc -Wall -Wextra -no-pie -o q1_auto_nopie   q1_auto.c

# ข้อ 2: Extern Storage Class
gcc -Wall -Wextra -o q2_extern   q2_extern.c
gcc -Wall -Wextra -o q2_noextern q2_noextern.c
gcc -Wall -Wextra -no-pie -o q2_extern_nopie   q2_extern.c
gcc -Wall -Wextra -no-pie -o q2_noextern_nopie q2_noextern.c

# ข้อ 2: ตัวอย่างการใช้ extern แชร์ตัวแปรข้ามไฟล์ ต้องลิงก์สองไฟล์เข้าด้วยกัน
gcc -Wall -Wextra -o q2_shared q2_shared_main.c q2_shared_def.c

# ข้อ 3: malloc / realloc / free (โจทย์ระบุให้คอมไพล์แบบปกติเท่านั้น)
gcc -Wall -Wextra -o q3_alloc   q3_alloc.c
gcc -Wall -Wextra -o q3_alloc_b q3_alloc_b.c
gcc -Wall -Wextra -o q3_regions q3_regions.c
```

**PS07 (`PS07/src`)**

คอมไพล์ตามคำสั่งในใบงานทุกตัวอักษร และตั้งใจไม่ใส่ `-O` เพราะ `-O2` อาจรวบลูปทั้งลูปเหลือการบวกครั้งเดียวจน race condition แทบไม่ปรากฏ

```bash
cd PS07/src
gcc -o ps7 ps7.c -lpthread

./ps7 1 1000000                    # Task 1: thread เดียว ต้องได้ diff=+0 OK ทุกครั้ง
./ps7 4 1000000                    # Task 2: 4 thread (ฝาก 2 ถอน 2) ผลเปลี่ยนทุกครั้ง
taskset -c 0 ./ps7 4 1000000       # Task 2: บังคับให้อยู่บน CPU ตัวเดียว ส่วนใหญ่ OK บางครั้งผิดเป็นก้อน
./ps7 4 100000 yield               # Task 3: sched_yield() ระหว่าง load กับ store
taskset -c 0 ./ps7 4 100000 yield  # Task 3: CPU ตัวเดียว ผิดทุกครั้ง ใกล้ +100000 หรือ -100000
```

> **หมายเหตุ:** โค้ดต้นฉบับจากใบงานประกาศ `void main()` ซึ่งไม่ตรงมาตรฐาน C การคอมไพล์ด้วย `-Wall -Wextra` จึงมี warning `[-Wmain]` ติดมาทุกไฟล์ และไฟล์ `q2_noextern.c` มี warning `[-Wuninitialized]` เพิ่มอีกหนึ่งข้อ ทั้งสองอย่างเป็นส่วนหนึ่งของผลการทดลองที่ต้องอธิบายในรายงาน จึงคงโค้ดไว้ตามใบงานทุกตัวอักษร ส่วน `q3_regions.c` ที่เขียนขึ้นเองคอมไพล์ผ่านโดยไม่มี warning

---

### 3. การคอมไพล์รายงาน LaTeX

เนื่องจากรายงานใช้ฟอนต์ภาษาไทยผ่านแพ็กเกจ `fontspec` ต้องคอมไพล์ด้วย **`XeLaTeX`**:

```bash
cd PS02/docs && xelatex PS02.tex && xelatex PS02.tex
cd PS03/docs && xelatex PS03.tex && xelatex PS03.tex
cd PS04/docs && xelatex PS04.tex && xelatex PS04.tex
cd PS06/docs && xelatex PS06.tex && xelatex PS06.tex
cd PS07/docs && xelatex PS07.tex && xelatex PS07.tex
```
*(รันคำสั่ง 2 รอบ เพื่อให้สารบัญและเลขหน้าอัปเดตอย่างถูกต้อง)*

รายงานของ PS06 และ PS07 มีฉบับ Word ด้วย สร้างจากไฟล์ `.tex` ชุดเดียวกันเพื่อไม่ให้เนื้อหาสองฉบับหลุดกัน:

```bash
node PS06/tools/build_report.js     # อ่าน PS06/docs/PS06.tex -> PS06/docs/PS06_Report.docx
node PS07/tools/build_report.js     # อ่าน PS07/docs/PS07.tex -> PS07/docs/PS07_Report.docx
```
*(ต้องการ Node.js และ package `docx` เปิดไฟล์ใน Word ครั้งแรกให้กด `Ctrl` `A` แล้ว `F9` เพื่ออัปเดตสารบัญ)*

ค่าตั้งต้นใช้ฟอนต์ **TH Sarabun New** ถ้าคอมไพล์บน Overleaf หรือเครื่องที่ไม่มีฟอนต์นี้ ให้สลับไปใช้ตัวเลือก (B) ที่คอมเมนต์ไว้ในส่วนหัวของไฟล์ `.tex` ซึ่งใช้ `Noto Serif Thai` แทน

---

## 🧪 สภาพแวดล้อมที่ใช้ทดลอง

การทดลองของ PS02–PS04, PS06 และ PS07 รันบน **Ubuntu 24.04.1 LTS (WSL2 บน Windows 11)** kernel `6.6.87.2-microsoft-standard-WSL2` คอมไพเลอร์ `gcc 13.3.0` และ shell `GNU bash 5.2.21` ส่วนข้อ 3 ของ PS06 ทำบน **Windows 11 Home Single Language (build 26200)** ซึ่งเป็นเครื่องเดียวกันกับที่ WSL2 ทำงานอยู่

ข้อควรทราบสำหรับ PS03:

- **ข้อ 1** เครื่องที่ใช้มี 22 CPU ถ้าปล่อยให้โปรแกรมทดสอบวิ่งอิสระจะไม่เห็นผลของค่า `nice` เลย เพราะไม่มีการแย่ง CPU เกิดขึ้นจริง สคริปต์เก็บผลจึงใช้ `taskset -c 0` บังคับให้ทุก process ทดสอบอยู่บน CPU แกนเดียวกัน
- **ข้อ 2** คำสั่ง `jobs`, `fg`, `bg` และการกด `CTRL+Z` ใช้ได้เฉพาะ shell แบบ interactive ที่มี tty จริง สคริปต์ `run_q2.sh` จึงใช้ `script(1)` สร้าง pseudo terminal ขึ้นมาก่อน
- สคริปต์ใน `src/` ทุกไฟล์ต้องมี line ending เป็น LF ซึ่งบังคับไว้แล้วใน `.gitattributes`

ข้อควรทราบสำหรับ PS04:

- **ทั้งสามข้อ** ต้องรันบนเครื่องเดียวกันตามที่ใบงานกำหนด (*All steps must be executed on the same machine*) สคริปต์ `run_qN.sh` แต่ละไฟล์จึงคอมไพล์และรันทุกกรณีของข้อนั้นจบในการเรียกครั้งเดียว
- **ที่อยู่ที่พิมพ์ออกมาจะไม่ซ้ำเดิม** ในการรันแต่ละครั้ง เพราะ `gcc` ของ Ubuntu สร้างไบนารีแบบ PIE เป็นค่าเริ่มต้น (`--enable-default-pie`) ทำงานร่วมกับ ASLR ของเคอร์เนล (`/proc/sys/kernel/randomize_va_space` = 2) การรันซ้ำจึงได้ตัวเลขต่างจากที่บันทึกไว้ใน `result/` แต่ **ความสัมพันธ์ระหว่างตัวเลข** เช่น ระยะห่างระหว่างสมาชิกอาร์เรย์ หรือการที่ที่อยู่ใน `main()` กับ `display()` ตรงกัน จะเหมือนเดิมเสมอ
- **ถ้าต้องการตัวเลขที่ซ้ำเดิมทุกครั้ง** ให้รันผ่าน `setarch -R <program>` ซึ่งปิด ASLR เฉพาะ process ลูก สคริปต์เก็บผลใช้วิธีนี้เป็นกรณีควบคุม และใช้ในข้อ 3 เพื่อให้เทียบที่อยู่ของสองโปรแกรมกันได้ตรง ๆ

ข้อควรทราบสำหรับ PS06:

- **หลักฐานทุกขั้นเป็นภาพหน้าจอ ไม่ใช่ log ข้อความ** เพราะใบงานกำหนดให้แสดงภาพผลการรันคำสั่ง (ข้อ 1.2 ระบุ *with screenshots* และข้อ 2 ระบุ *Please capture the output image*) จึงไม่มีไฟล์ `result/*_verified.txt` เหมือน PS อื่น คำสั่งทั้งหมดอยู่ใน `PS06/docs/COMMANDS.md` และภาพอยู่ใน `PS06/result/screenshots/`
- **swap ของ WSL2 เป็น partition ที่ Windows จัดการให้** (`/dev/sdc` ขนาด 4 GiB = 25% ของ RAM ที่ virtual machine มองเห็น) การทดลองข้อ 1 จึงเพิ่ม swap ด้วยวิธี swap file แทนการแก้ partition เดิม และคืนค่าระบบกลับหมดเมื่อจบการทดลอง
- **systemd บน WSL2 ไม่รับ swap entry ใน `/etc/fstab`** เพราะ `systemd-detect-virt --container` ตอบ `wsl` ทำให้ `systemd-fstab-generator` ข้ามบรรทัด swap ทิ้ง (เห็นได้จาก journal) ถ้าต้องการให้ถาวรต้องใช้ `swapon -a` ผ่าน `[boot] command` ใน `/etc/wsl.conf` หรือกำหนด `swap=` ใน `.wslconfig` ฝั่ง Windows
- **แถวแรกของ `vmstat` เป็นค่าเฉลี่ยตั้งแต่บูต ไม่ใช่ค่าปัจจุบัน** และบนเครื่องนี้คอลัมน์ `cs` ของแถวนั้นรายงานเป็น 0 ทั้งที่ `vmstat -s` นับได้ 261,886 ครั้ง ให้อ่านค่าจากแถวที่เก็บตัวอย่างเป็นช่วง เช่น `vmstat 1 5` แทน
- **รายงานมีสองฉบับจากต้นฉบับเดียว** คือ `PS06.pdf` (XeLaTeX) และ `PS06_Report.docx` ที่ `tools/build_report.js` อ่าน `PS06.tex` ไปสร้างให้ ถ้าแก้เนื้อหาต้องแก้ที่ `.tex` แล้ว build ใหม่ทั้งสองฉบับ

ข้อควรทราบสำหรับ PS07:

- **ผลของ Task 2 และ Task 3 ไม่มีวันซ้ำกับที่บันทึกไว้** เพราะนั่นคือพฤติกรรม non-deterministic ที่การทดลองต้องการแสดง ตัวเลขในรายงานอ่านจากภาพหน้าจอใน `PS07/result/screenshots/` ส่วนคำสั่งที่ใช้ถ่ายแต่ละภาพอยู่ใน `PS07/docs/COMMANDS.md`
- **เครื่องที่ใช้มี 22 CPU** thread ทั้ง 4 ตัวจึงทำงานพร้อมกันจริง race condition ปรากฏแทบทุกครั้งแม้ไม่บังคับ context switch การทดลองจึงรันซ้ำอีกชุดด้วย `taskset -c 0` เพื่อให้ทุก thread อยู่บน CPU ตัวเดียว ซึ่งจะสลับกันได้เฉพาะเมื่อ kernel ขัดจังหวะ (หลักการเดียวกับการทดลอง `nice` ของ PS03)
- **โหมด `yield` ใช้ `sched_yield()`** ไม่ใช่ `pthread_yield()` เพราะ glibc 2.34 ขึ้นไปประกาศเลิกใช้ฟังก์ชันหลังแล้ว และจำนวนรายการต่อ thread ลดเหลือ 100,000 เพราะทุกรอบต้องเข้า kernel หนึ่งครั้ง
- **รายงานมีสองฉบับจากต้นฉบับเดียว** เหมือน PS06 `PS07/tools/build_report.js` ต่อยอดจากของ PS06 ให้รองรับ `\mbox{}` และ `\lstinputlisting` และให้รายการลำดับเลขแต่ละชุดเริ่มนับใหม่
- **รายงานเขียนแบบสั้นตามที่ใบงานขอ** (*a short report*) มีเฉพาะคำอธิบายโค้ดส่วนสำคัญ ผลการรัน Task 1–3 การอภิปรายสาเหตุ และภาคผนวกซอร์สโค้ดฉบับเต็มที่ดึงจาก `src/ps7.c` โดยตรงด้วย `\lstinputlisting`

ข้อควรทราบสำหรับ Mini-Project 1:

- **ทำใน Virtual Machine ไม่ใช่ WSL** เพราะต้องติดตั้งและบูต kernel ใหม่จริง ใช้ VMware Workstation 17 Player กับ Ubuntu 24.04.5 LTS (12 vCPU, RAM 12 GB, ดิสก์ 100 GB) ซึ่งบูตแบบ BIOS จึงไม่มี Secure Boot มาขวาง kernel แบบ `linux-image-unsigned`
- **Ubuntu 24.04.5 ใช้ kernel HWE** (`7.0.0-31-generic`) source package จึงเป็น `linux-hwe-7.0` และต้องแก้ `debian.hwe-7.0/changelog` ไม่ใช่ `debian.master/changelog` ตามตัวอย่างในคู่มือ ดูชื่อ folder ที่ถูกต้องได้จาก `debian/debian.env`
- เปลี่ยนเลข ABI เป็น 999 และเพิ่ม `pr_notice()` ใน `start_kernel()` ได้ kernel `7.0.0-999-generic` ใช้เวลา build 1 ชั่วโมง 46 นาทีบน 12 vCPU
- **ไม่มี Makefile หรือสคริปต์เก็บผล** เหมือน PS อื่น เพราะต้องทำทีละขั้นใน Virtual Machine และ reboot ระหว่างทาง ขั้นตอนทั้งหมดอยู่ใน `Miniproj1/docs/COMMANDS.md` และหลักฐานทุกขั้นเป็นภาพหน้าจอใน `Miniproj1/result/screenshots/`

---

## 👥 ผู้จัดทำ (Group Members)

- นายภูมิพัฒน์ อภิวาทธนะพงศ์ (67070501035)
- นายวิรชัช ทองอุทัยศรี (67070501041)
- นายเจษฎา เกียรติกมลวงศ์ (67070501080)

Mini-Project 1 ทำร่วมกับสมาชิกจากอีกกลุ่มหนึ่ง รวมเป็น 7 คน รายชื่อทั้งหมดอยู่ในหน้าปกของรายงาน
