# PS06 — คำสั่งที่ต้องพิมพ์เองใน terminal และภาพหน้าจอที่ต้องถ่าย

เอกสารนี้ไม่ใช่รายงาน แต่เป็น script การทำงานร่วมกัน: **คุณพิมพ์คำสั่งใน terminal เอง**
แล้วพิมพ์ชื่อภาพ (เช่น `s03`) มาในแชต → Claude จะถ่ายภาพหน้าต่างนั้นให้ เซฟลง
`PS06/result/screenshots/` ตัดขอบภาพด้วย `PS06/tools/crop_shot.ps1` แล้วเปิดดูเพื่อยืนยันว่าภาพใช้ได้ก่อนไปขั้นถัดไป

## เตรียมตัวก่อนเริ่ม

1. เปิด **Windows Terminal → Ubuntu (WSL)** ให้หน้าต่างอยู่หน้าสุด (ไม่ต้อง maximize ก็ได้
   แต่อย่าให้หน้าต่างอื่นทับ)
2. ขยาย font ให้ใหญ่พอ: กด `Ctrl` + `Shift` + `+` ประมาณ 2–3 ครั้ง (ราว 14–16 pt)
   เพราะภาพจะถูกย่อลงเมื่อนำไปวางในรายงาน ถ้า font เล็กจะอ่านไม่ออก
3. พิมพ์ `clear` ก่อนทุกครั้งที่จะถ่ายภาพใหม่ เพื่อให้ในภาพเห็นเฉพาะคำสั่งของขั้นนั้น
4. ถ้าเจอปัญหา/error ให้พิมพ์ `err <ข้อความ>` มาในแชต Claude จะบันทึกไว้ใน
   `PS06/result/notes.txt` และเขียนเป็นหัวข้อ "ปัญหาที่พบ" ในรายงาน

> คำสั่งที่ขึ้นต้นด้วย `sudo` จะถาม password ของ Ubuntu — พิมพ์ในหน้าต่าง terminal เท่านั้น
> ไม่ต้องพิมพ์ password มาในแชต (ตอนพิมพ์ password จะไม่มีตัวอักษรแสดงบนหน้าจอ ถือว่าปกติ)

---

## ข้อ 1.2 — เพิ่มและลด swap space บน Linux (ภาพ s01–s09)

### s01 — ดูสถานะ swap เดิมก่อนแก้ไข

```bash
clear; free -h; echo; swapon --show; echo; cat /proc/swaps
```

ต้องเห็น: `Swap: 4.0Gi` และ swap เดิมเป็น partition `/dev/sdc`

### s02 — สร้าง file สำหรับใช้เป็น swap ขนาด 2 GiB

```bash
clear; sudo fallocate -l 2G /swapfile; ls -lh /swapfile
```

ต้องเห็น: file `/swapfile` ขนาด `2.0G`
(ถ้า `fallocate` ใช้ไม่ได้ ให้ใช้ `sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress` แทน)

### s03 — ตั้งสิทธิ์ให้ปลอดภัยและ format เป็น swap area

```bash
clear; sudo chmod 600 /swapfile; ls -lh /swapfile; sudo mkswap /swapfile
```

ต้องเห็น: สิทธิ์เปลี่ยนเป็น `-rw-------` และข้อความ `Setting up swapspace version 1` พร้อม UUID

### s04 — เปิดใช้งาน swap file

```bash
clear; sudo swapon /swapfile; swapon --show; cat /proc/swaps
```

ต้องเห็น: มีสองบรรทัดคือ `/dev/sdc` (partition) และ `/swapfile` (file)

### s05 — ยืนยันว่า swap เพิ่มขึ้นจริง

```bash
clear; free -h; free -h --si
```

ต้องเห็น: `Swap` total เปลี่ยนจาก `4.0Gi` เป็น `6.0Gi`

### s06 — ทำให้ถาวร (เพิ่มบรรทัดใน /etc/fstab)

```bash
clear; echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; sudo systemctl daemon-reload; systemctl --no-pager list-units --type=swap
```

ผลที่ได้จริง: บรรทัด `/swapfile none swap sw 0 0` เข้า `/etc/fstab` สำเร็จ แต่ systemd ตอบ
`0 loaded units listed` คือ **ไม่สร้าง swap unit ให้** ซึ่งเป็นพฤติกรรมเฉพาะของ WSL2
(ดูสาเหตุในขั้น s06b)

### s06b — ทำไม systemd ถึงไม่รับ swap entry บน WSL2 (หลักฐานของสาเหตุ)

```bash
clear; systemd-detect-virt --container; journalctl -b --no-pager | grep -i "ignoring swap entry"; sudo swapoff /swapfile; swapon --show; sudo swapon -a; swapon --show
```

ต้องเห็น:

- `systemd-detect-virt --container` ตอบ `wsl` คือ systemd มองว่ากำลังทำงานอยู่ใน container
- บรรทัดจาก journal: `systemd-fstab-generator: Running in a container, ignoring swap entry for /swapfile`
- หลัง `swapoff` เหลือ swap เดียว แล้วพอสั่ง `swapon -a` ซึ่งอ่าน `/etc/fstab` โดยตรง
  `/swapfile` กลับมาอีกครั้ง แปลว่าบรรทัดใน fstab ถูกต้อง แต่ตัว systemd ต่างหากที่ข้ามมันไป

### s07 — ลด swap: ปิดการใช้งาน swap file

```bash
clear; sudo swapoff /swapfile; swapon --show; free -h
```

ต้องเห็น: เหลือแค่ `/dev/sdc` และ `Swap` total กลับเป็น `4.0Gi`

### s08 — ลบ file และคืนค่า /etc/fstab ให้เหมือนเดิม

```bash
clear; sudo sed -i '\|^/swapfile|d' /etc/fstab; sudo rm -f /swapfile; cat /etc/fstab; ls -lh /swapfile; free -h
```

ต้องเห็น: `/etc/fstab` ไม่มีบรรทัด swapfile แล้ว, `ls` ฟ้อง `No such file or directory`
(ถือว่าถูกต้อง) และ `Swap: 4.0Gi`

### s09 — ปรับ vm.swappiness (แนวโน้มที่ kernel จะย้าย page ลง swap)

```bash
clear; cat /proc/sys/vm/swappiness; sudo sysctl vm.swappiness=10; cat /proc/sys/vm/swappiness; sudo sysctl vm.swappiness=60; cat /proc/sys/vm/swappiness
```

ต้องเห็น: `60` → `10` → `60` (ตั้งค่าถาวรทำได้โดยเพิ่ม `vm.swappiness=10` ใน `/etc/sysctl.conf`)

---

## ตารางเช็กลิสต์ภาพ

| ชื่อภาพ | ชื่อ file ที่จะเซฟ | สถานะ |
|---|---|---|
| s01 | `s01_swap_baseline.png` | ✔ |
| s02 | `s02_fallocate.png` | ✔ |
| s03 | `s03_mkswap.png` | ✔ |
| s04 | `s04_swapon.png` | ✔ |
| s05 | `s05_free_after_add.png` | ✔ |
| s06 | `s06_fstab.png` | ✔ |
| s06b | `s06b_container_ignored.png` | ✔ |
| s07 | `s07_swapoff.png` | ✔ |
| s08 | `s08_cleanup.png` | ✔ |
| s09 | `s09_swappiness.png` | ✔ |

---

## ข้อ 2 — Linux VM Monitoring ด้วย `free` และ `vmstat` (ภาพ s10–s18)

### s10 — รัน `free` แบบไม่มี argument

```bash
clear; free
```

ต้องเห็น: ตารางสองแถว `Mem:` และ `Swap:` เป็นหน่วย KiB (ตัวเลขดิบ ไม่มีหน่วยกำกับ)

### s11 — `free -h` เพื่อใช้อธิบายทุกฟิลด์

```bash
clear; free -h
```

ต้องเห็น: ตารางเดียวกันแต่อ่านง่าย มีหน่วย Gi / Mi กำกับ — ภาพนี้จะเป็นภาพอ้างอิงหลักของข้อ 2

### s12 — ดู argument ทั้งหมดที่ `free` มี

```bash
clear; free --help
```

ต้องเห็น: รายการ option ทั้งหมด ถ้าล้นจอให้ย่อ font ด้วย `Ctrl` `-` ก่อนถ่าย แล้วค่อยขยายกลับ

### s13 — argument ที่ 1 ของ `free`: `-w` กับ `-t`

```bash
clear; free -h; free -h -w -t
```

ต้องเห็น: ภาพเดียวเทียบกันให้ชัด แบบปกติมีคอลัมน์ `buff/cache` รวมกัน ส่วน `-w` แยกเป็น
`buffers` กับ `cache` คนละคอลัมน์ และ `-t` เพิ่มแถว `Total:` ที่รวม Mem กับ Swap เข้าด้วยกัน

### s14 — argument ที่ 2 ของ `free`: `-s` กับ `-c`

```bash
clear; free -h -s 2 -c 3
```

ต้องเห็น: ตารางพิมพ์ซ้ำ 3 รอบ ห่างกันรอบละ 2 วินาที (ใช้เฝ้าดูหน่วยความจำขณะรันงานหนัก)

### s15 — ยืนยันว่ามี `vmstat` แล้วหรือต้องติดตั้ง

```bash
clear; which vmstat; dpkg -l procps | tail -3; vmstat --version
```

ต้องเห็น: path ของ `vmstat`, บรรทัด package `procps` สถานะ `ii` และเลข version
(ถ้าเครื่องไหนไม่มี ให้ติดตั้งด้วย `sudo apt update && sudo apt install -y procps`)

### s16 — รัน `vmstat` แบบไม่มี argument

```bash
clear; vmstat
```

ต้องเห็น: หัวตาราง 6 กลุ่ม (`procs`, `memory`, `swap`, `io`, `system`, `cpu`) กับข้อมูลหนึ่งแถว
ซึ่งเป็นค่าเฉลี่ยสะสมตั้งแต่บูตเครื่อง — ภาพนี้ใช้อธิบายทุกคอลัมน์

### s17 — argument ที่ 1 ของ `vmstat`: `-S M` กับการระบุ interval/count

```bash
clear; vmstat -S M 1 5
```

ต้องเห็น: 5 แถว เก็บตัวอย่างทุก 1 วินาที หน่วยเป็น MB แทน KB
แถวแรกเป็นค่าเฉลี่ยตั้งแต่บูต แถวที่ 2 เป็นต้นไปคือค่าจริงของช่วงนั้น ๆ

**ถ้าอยากให้คอลัมน์ `bi/bo` และ `cs` ขยับให้เห็นชัด (ไม่บังคับ):** เปิด terminal อีกหน้าต่าง
พิมพ์ `dd if=/dev/zero of=~/bigfile bs=1M count=2048; sync` แล้วค่อยรันคำสั่ง s17 ในหน้าต่างเดิม
เสร็จแล้วลบด้วย `rm ~/bigfile`

### s18 — argument ที่ 2 ของ `vmstat`: `-s` ตารางสรุปตัวนับสะสม

```bash
clear; vmstat -s -S M
```

ต้องเห็น: รายการตัวนับประมาณ 30 บรรทัดตั้งแต่ total memory ถึง boot time
**บรรทัดยาว ให้กด `Ctrl` `-` ย่อ font ก่อนถ่าย** เพื่อให้เห็นครบทุกบรรทัดในภาพเดียว

---

## ตารางเช็กลิสต์ภาพข้อ 2

| ชื่อภาพ | ชื่อ file ที่จะเซฟ | สถานะ |
|---|---|---|
| s10 | `s10_free_plain.png` | ✔ |
| s11 | `s11_free_h.png` | ✔ |
| s12 | `s12_free_help.png` | ✔ |
| s13 | `s13_free_wide_total.png` | ✔ |
| s14 | `s14_free_seconds_count.png` | ✔ |
| s15 | `s15_vmstat_installed.png` | ✔ |
| s16 | `s16_vmstat_plain.png` | ✔ |
| s17 | `s17_vmstat_mb_interval.png` | ✔ |
| s18 | `s18_vmstat_stats.png` | ☐ |

---

## ข้อ 3 — Windows VM Monitoring ด้วย Resource Monitor (ภาพ s19–s21)

ขั้นนี้ทำฝั่ง Windows ไม่ใช่ใน Ubuntu

### s19 — เปิด Resource Monitor จาก PowerShell

1. เปิดหน้าต่าง **PowerShell** (tab ใหม่ใน Windows Terminal ก็ได้)
2. พิมพ์คำสั่งด้านล่าง **แต่ยังไม่ต้องกด Enter** แล้วบอก `s19` เพื่อถ่ายภาพคำสั่งก่อน

```powershell
resmon
```

3. ถ่ายเสร็จแล้วค่อยกด Enter เพื่อเปิด Resource Monitor

### s20 — แท็บ Memory ของ Resource Monitor

1. ใน Resource Monitor คลิกแท็บ **Memory**
2. ขยายหน้าต่างให้ใหญ่ที่สุด (กดปุ่ม maximize) เพื่อให้เห็นครบทั้งสามส่วน คือ
   ตาราง process ด้านบน, แถบ **Physical Memory** ตรงกลาง และกราฟด้านขวา
3. ถ้าส่วนใดถูกพับอยู่ ให้คลิกลูกศรบนหัวข้อนั้นเพื่อกางออก
4. บอก `s20` เพื่อถ่ายภาพ

### s21 — ส่วน Physical Memory (ตัดมาจาก s20)

Claude จะตัดเฉพาะส่วนแถบ Physical Memory ออกมาจากภาพ s20 ให้เอง
ใช้ตอบข้อ 3.3 ที่ให้สรุปตัวเลขในส่วนนี้เป็นย่อหน้า ไม่ต้องถ่ายเพิ่ม

---

## ตารางเช็กลิสต์ภาพข้อ 3

| ชื่อภาพ | ชื่อ file ที่จะเซฟ | สถานะ |
|---|---|---|
| s19 | `s19_resmon_command.png` | ✔ |
| s20 | `s20_resmon_memory_tab.png` | ✔ |
| s21 | `s21_physical_memory.png` | ✔ |
